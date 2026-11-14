--[[
	KikiUtils - Dispel Alert Icon

	Shows a large, non-interactive icon (near the center of the screen) while the
	player has a debuff THIS character can dispel.

	Design note (WoW 12.1 "Secret Auras"):
		12.0 made aura FIELDS secret. 12.1 sealed aura ACCESS: every index / slot /
		instanceID lookup (C_UnitAuras.GetDebuffDataByIndex, GetAuraDataByIndex, ...)
		HARD-ERRORS when called from addon-tainted code while auras are secret --

			GetDebuffDataByIndex(): Auras cannot be accessed when secret
			while tainted by 'KikiUtils'

		-- and auras are secret in combat, in raid encounters, in Mythic+ and in
		rated PvP, i.e. exactly when this icon is useful. So the old "scan the
		player's debuffs, pick one, feed its values into widget setters" loop is
		gone for good: there is no flag to test and no pcall to hide behind, the
		entry point itself is closed.

		The replacement is the AuraContainer / AuraButton widget pair:

		  - WE create and style the display; BLIZZARD fills and drives it.
		  - Which aura qualifies is a Blizzard-side filter string, evaluated in
		    secure code. Ours is "HARMFUL|RAID_PLAYER_DISPELLABLE" = a harmful
		    aura that THIS character can actually dispel -- the real per-spell
		    test 12.0 forced us to fake with the isRaid proxy.
		  - PRESENCE IS BLIZZARD'S. The button shows and hides itself, and we
		    never learn whether it is visible (that is a secret), so nothing in
		    this file may branch on "is a debuff up".

	☠ THE RULE THAT SHAPES EVERYTHING BELOW:
		once the aura button exists, NOTHING inside its subtree may be written
		from our (tainted) code while auras are secret. Not the button, not the
		frames and textures WE created under it:

			calling 'SetSize' on bad self (Attempt to access forbidden object
			from code tainted by an AddOn)

		The first port of this file put the marching-ants border inside the
		button and moved it from an OnUpdate -- 73 errors in seconds. Access
		restrictions not descending to our own child regions is a Blizzard
		implementation detail, not a contract; DandersFrames built its whole
		aura layer on that assumption and got bitten by this exact error twice
		on later builds (see its Features/ElementAppearance.lua:1443).

		So the subtree is written ONCE, inside initializeFrame -- which Blizzard
		calls before the forbidden state is applied -- and then left alone. What
		still has to change at runtime is handled from OUTSIDE it:

		  * The dispel-cooldown dim is an alpha on `gate`, our own frame ABOVE
		    the container. Alpha cascades DOWN into the button subtree without
		    ever writing to it. Free, legal, works mid-combat.
		  * The alert border is Blizzard's own: four plain strips registered with
		    AddDispelTypeTexture, which it shows, hides and tints by dispel type
		    (magic / curse / poison / disease) with zero Lua per frame.
		  * The stacks toggle is the one remaining in-subtree write. It is
		    pcall'd and re-applied on PLAYER_REGEN_ENABLED, because a checkbox
		    gets flipped out of combat, where the button is not forbidden.

	Lost to the above, deliberately, with no workaround available:
		* The scale bump on a new debuff -- it needs a presence edge, and
		  presence is unreadable. Script handlers and animation groups are also
		  inert inside the subtree (onUpdateMode=disabled propagates down).
		* The MARCHING-ANTS border around the live icon: animating it means
		  per-frame writes to forbidden objects. The ants survive only on the
		  unlocked placeholder, which lives on our own frame and is never shown
		  in combat. The native dispel-type border replaces them on the real icon.
		* Desaturating the icon while our dispel is on cooldown (in-subtree
		  write on a combat path). The gate alpha carries that state alone now.
]]

-------------------------------------------------------------------
-- Tunables
-------------------------------------------------------------------
local DEFAULT_SIZE   = 64
local MIN_SIZE       = 32
local MAX_SIZE       = 128
local PLACEHOLDER    = 134400            -- question-mark icon (non secret)
local BORDER_THICK   = 3                 -- native dispel-type border strips
local ICON_INSET     = 4                 -- gap between icon and the border

local DASH_LEN       = 7
local DASH_GAP       = 7
local DASH_THICK     = 3
local DASH_SPEED     = 34                -- pixels / second the dashes travel
local DASH_COLOR     = { 1.0, 0.85, 0.15 }

local DIM_ALPHA      = 0.4               -- gate alpha while our dispel is on cooldown

-- Blizzard-side aura filter. HARMFUL = debuffs; RAID_PLAYER_DISPELLABLE = the
-- player can remove it with a spell they actually have. Evaluated in secure code,
-- so it costs us nothing and leaks nothing.
local DISPEL_FILTER  = "HARMFUL|RAID_PLAYER_DISPELLABLE"

-- Per-class defensive dispel spells come from the shared global KU_DISPEL_SPELLS
-- (defined in KikiUtils.lua). Spell cooldowns are ordinary addon-readable state,
-- so unlike the aura side this gate is untouched by 12.1.

-------------------------------------------------------------------
-- State
-------------------------------------------------------------------
local frame                              -- ours: position, size, drag
local gate                               -- ours: alpha = the dispel-cooldown gate
local phTex                              -- placeholder art, shown while unlocked
local initialized = false

local container                          -- the AuraContainer (Blizzard-driven)
local stackHost                          -- in-subtree; written only via SafeStackAlpha

-- Marching ants: PLACEHOLDER ONLY. These textures are children of `frame`, never
-- of the aura button, which is the only reason they may be moved every frame.
local dashes = {}
local activeDashCount = 0
local dashPhase = 0
local dashThrottle = 0
local perimeter = 0
local borderW, borderH = 0, 0

local buildFailed = false                -- pre-12.1 client / API missing: stay quiet
local buildPending = false               -- waiting for PLAYER_REGEN_ENABLED
local stackDirty = false                 -- an in-subtree write that combat refused

-------------------------------------------------------------------
-- Config helpers (read the global SavedVariable directly, like the options file)
-------------------------------------------------------------------
local function Cfg(key, default)
	if KU_CharConfig == nil then return default end
	local v = KU_CharConfig[key]
	if v == nil then return default end
	return v
end

local function SetCfg(key, value)
	if KU_CharConfig == nil then KU_CharConfig = {} end
	KU_CharConfig[key] = value
end

local function Debug(msg)
	if not Cfg("DebugMode", false) then return end
	if KU_API and KU_API.ChatPrint then KU_API.ChatPrint("DispelIcon: " .. msg) end
end

-------------------------------------------------------------------
-- Marching-ants border for the UNLOCKED PLACEHOLDER
--
-- This is the positioning aid, not the alert: it draws on `frame`, is only ever
-- shown while the icon is unlocked, and is therefore never on screen in combat.
-- The live icon's border is Blizzard's (see InitializeSlot) precisely because
-- this per-frame treatment is illegal inside the button.
-------------------------------------------------------------------
local function EnsureDash(i)
	if dashes[i] then return dashes[i] end
	local t = frame:CreateTexture(nil, "OVERLAY")
	t:SetColorTexture(DASH_COLOR[1], DASH_COLOR[2], DASH_COLOR[3], 1)
	t:Hide()
	dashes[i] = t
	return t
end

-- Map a distance along the rectangle perimeter (BOTTOMLEFT origin, clockwise)
-- to a local (x, y) point plus orientation.
local function PerimeterPoint(d, W, H)
	if d < W then
		return d, 0, true               -- bottom edge, moving right
	end
	d = d - W
	if d < H then
		return W, d, false              -- right edge, moving up
	end
	d = d - H
	if d < W then
		return W - d, H, true           -- top edge, moving left
	end
	d = d - W
	return 0, H - d, false              -- left edge, moving down
end

local function HideDashes()
	for i = 1, #dashes do
		if dashes[i] then dashes[i]:Hide() end
	end
end

local function UpdateDashes()
	if activeDashCount == 0 then return end
	local step = DASH_LEN + DASH_GAP
	for i = 0, activeDashCount - 1 do
		local d = (i * step + dashPhase) % perimeter
		local px, py, horiz = PerimeterPoint(d, borderW, borderH)
		local dash = dashes[i + 1]
		if horiz then
			dash:SetSize(DASH_LEN, DASH_THICK)
		else
			dash:SetSize(DASH_THICK, DASH_LEN)
		end
		dash:ClearAllPoints()
		dash:SetPoint("CENTER", frame, "BOTTOMLEFT", px, py)
		dash:Show()
	end
end

local function RebuildDashPool()
	local needed = math.max(4, math.floor(perimeter / (DASH_LEN + DASH_GAP)))
	for i = 1, needed do
		EnsureDash(i)
	end
	for i = needed + 1, #dashes do
		if dashes[i] then dashes[i]:Hide() end
	end
	activeDashCount = needed
end

-------------------------------------------------------------------
-- Layout
--
-- Nothing here reaches into the button. The container and the button are pinned
-- to `gate` with SetAllPoints and every region inside is anchored relatively, so
-- a size change propagates on its own -- which is what makes the icon resizable
-- without a single write to a forbidden object.
-------------------------------------------------------------------
local function UpdateLayout()
	local size = Cfg("DispelIconSize", DEFAULT_SIZE)
	if size < MIN_SIZE then size = MIN_SIZE elseif size > MAX_SIZE then size = MAX_SIZE end

	frame:SetSize(size, size)
	borderW, borderH = size, size
	perimeter = 2 * (borderW + borderH)

	phTex:ClearAllPoints()
	phTex:SetPoint("TOPLEFT", ICON_INSET, -ICON_INSET)
	phTex:SetPoint("BOTTOMRIGHT", -ICON_INSET, ICON_INSET)

	RebuildDashPool()
end

-------------------------------------------------------------------
-- Position (saved as an offset from UIParent's center)
-------------------------------------------------------------------
local function ApplyPosition()
	local x = Cfg("DispelIconX", 0)
	local y = Cfg("DispelIconY", 120) -- slightly above dead-center by default
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

local function SavePosition()
	local cx, cy = frame:GetCenter()
	local ucx, ucy = UIParent:GetCenter()
	if cx and ucx then
		SetCfg("DispelIconX", cx - ucx)
		SetCfg("DispelIconY", cy - ucy)
	end
	ApplyPosition()
end

-------------------------------------------------------------------
-- Dispel-spell readiness (combat-legal: spell cooldowns are ordinary addon
-- state, untouched by the aura sealing)
--   returns "none"     -> class/spec has no self-dispel we track
--           "ready"    -> a dispel is off cooldown
--           "cooldown" -> the dispel(s) are all on cooldown
-------------------------------------------------------------------
-- Is a single spell currently on its REAL cooldown (not merely the GCD)?
local function SpellOnRealCD(sid)
	local ok, ci = pcall(C_Spell.GetSpellCooldown, sid)
	if not ok or not ci then return false end
	-- isOnGCD -> the only thing ticking is the global cooldown: treat as ready.
	if ci.isOnGCD then return false end
	-- isActive (NeverSecret) is the cleanest "cooldown is running" flag in 12.0+.
	if ci.isActive ~= nil then
		return ci.isActive == true
	end
	-- Fallback: timeUntilEndOfStartRecovery is non-nil while in recovery.
	return ci.timeUntilEndOfStartRecovery ~= nil
end

local function GetDispelState()
	if not (C_Spell and C_Spell.GetSpellCooldown) then return "none" end
	local _, cls = UnitClass("player")
	local list = KU_DISPEL_SPELLS and KU_DISPEL_SPELLS[cls]
	if not list then return "none" end

	local hasAny = false
	for _, sid in ipairs(list) do
		local known = true
		if IsPlayerSpell then
			local ok, res = pcall(IsPlayerSpell, sid)
			known = ok and res
		end
		if known then
			hasAny = true
			if not SpellOnRealCD(sid) then
				return "ready" -- at least one dispel is available
			end
		end
	end

	if not hasAny then return "none" end
	return "cooldown"
end

-- Debug helper: prints the dispel state + per-spell CD status on change,
-- only when KikiUtils DebugMode is on. Handy to see which spellID matters.
local lastDbgState = nil
local function DebugDispel(state)
	if not Cfg("DebugMode", false) then return end
	if state == lastDbgState then return end
	lastDbgState = state
	local _, cls = UnitClass("player")
	local list = KU_DISPEL_SPELLS and KU_DISPEL_SPELLS[cls] or {}
	local parts = {}
	for _, sid in ipairs(list) do
		local known = true
		if IsPlayerSpell then
			local ok, res = pcall(IsPlayerSpell, sid)
			known = ok and res
		end
		local tag = tostring(sid) .. "=" .. (SpellOnRealCD(sid) and "CD" or "rdy")
		if not known then tag = tag .. "(unknown)" end
		parts[#parts + 1] = tag
	end
	Debug("state=" .. state .. " [" .. table.concat(parts, ", ") .. "]")
end

-------------------------------------------------------------------
-- The one remaining in-subtree write.
--
-- Protected and latched, not because it is expected to fail but because it is
-- expected to fail SOMETIMES: legal out of combat (the button is not forbidden
-- while auras are readable), refused while they are secret. A refusal re-arms on
-- PLAYER_REGEN_ENABLED instead of erroring, so the checkbox always lands -- just
-- possibly one combat later.
-------------------------------------------------------------------
local function SafeStackAlpha()
	if not stackHost then return end
	local ok = pcall(stackHost.SetAlpha, stackHost, Cfg("DispelIconShowStacks", false) and 1 or 0)
	stackDirty = not ok
end

-------------------------------------------------------------------
-- Button initialization -- Blizzard calls this once, when the container creates
-- the slot's button, and BEFORE the button becomes forbidden. It is the only
-- place this file may touch the subtree freely, so everything static is done
-- here and nothing is left to fix up later.
-------------------------------------------------------------------

-- "Color" style = Blizzard vertex-tints OUR texture by dispel type and assigns no
-- art of its own, which is what lets four plain strips become a type-coloured
-- border with no media file. Resolved BY NAME: the enum was renamed AND
-- renumbered in 68914, so a hardcoded number silently draws the wrong style.
local function DispelColorStyle()
	local newEnum = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
	if newEnum and newEnum.PreserveAsset ~= nil then return newEnum.PreserveAsset end
	local oldEnum = Enum and Enum.CustomAuraButtonBorderStyle              -- pre-68914
	if oldEnum and oldEnum.Color ~= nil then return oldEnum.Color end
	if _G.AuraButtonBorderStyle and _G.AuraButtonBorderStyle.Color ~= nil then
		return _G.AuraButtonBorderStyle.Color                              -- Blizzard's shim
	end
	return 3                                                               -- last resort
end

local function InitializeSlot(button)
	-- ☠ ANCHOR THE BUTTON HERE, not after AddAuraSlot returns. By then this
	-- callback has already run, which is exactly the point at which Blizzard
	-- applies the forbidden state -- so a build that happens while auras are
	-- secret (out of combat is not the same thing: a Mythic+ or an encounter
	-- keeps them secret) would have its anchor silently refused and leave the
	-- icon unpositioned. Inside the callback the write is guaranteed legal.
	button:SetAllPoints(gate)          -- one slot = one button, covering the icon

	-- Pure indicator: never eat a click, never pop a tooltip. This also keeps the
	-- drag-to-move on `frame` reachable while the icon is unlocked.
	if button.SetMouseClickEnabled  then button:SetMouseClickEnabled(false) end
	if button.SetMouseMotionEnabled then button:SetMouseMotionEnabled(false) end

	local host = CreateFrame("Frame", nil, button)
	host:SetAllPoints(button)

	local iconTex = host:CreateTexture(nil, "ARTWORK")
	iconTex:SetPoint("TOPLEFT", host, "TOPLEFT", ICON_INSET, -ICON_INSET)
	iconTex:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -ICON_INSET, ICON_INSET)
	iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	local cooldown = CreateFrame("Cooldown", nil, host, "CooldownFrameTemplate")
	cooldown:SetPoint("TOPLEFT", host, "TOPLEFT", ICON_INSET, -ICON_INSET)
	cooldown:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -ICON_INSET, ICON_INSET)
	cooldown:SetDrawEdge(true)
	cooldown:SetReverse(true)
	-- Numbers come from SetDurationText below, which is exact and does not depend
	-- on the "Show Numbers for Cooldowns" CVar the widget's own countdown needs.
	cooldown:SetHideCountdownNumbers(true)

	local durHost = CreateFrame("Frame", nil, host)
	durHost:SetAllPoints(host)
	local durText = durHost:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	durText:SetPoint("CENTER", host, "CENTER", 0, 0)

	stackHost = CreateFrame("Frame", nil, host)
	stackHost:SetAllPoints(host)
	stackHost:SetAlpha(Cfg("DispelIconShowStacks", false) and 1 or 0)
	local stackText = stackHost:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
	stackText:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -2, 2)
	stackText:SetJustifyH("RIGHT")

	-- Hand the regions over. From here on Blizzard fills them from the matched
	-- aura, in secure code: we never see the icon fileID, the expiration time or
	-- the stack count, and never need to.
	--
	-- ⚠ No formatter is passed to SetApplicationCount. Blizzard's formatter path
	-- calls FormatNumber(applications) in Lua with the SECRET stack count, which
	-- errors; the default (no options) rendering is the safe shape.
	if button.SetIcon             then pcall(button.SetIcon, button, iconTex) end
	if button.SetDurationCooldown then pcall(button.SetDurationCooldown, button, cooldown) end
	if button.SetDurationText     then pcall(button.SetDurationText, button, durText) end
	if button.SetApplicationCount then pcall(button.SetApplicationCount, button, stackText) end

	-- NATIVE ALERT BORDER: four plain strips Blizzard shows, hides and tints by
	-- dispel type. This replaces the marching ants on the live icon -- presence
	-- and colour both come from the engine, so it costs zero Lua per frame and
	-- never needs a write we are not allowed to make.
	--
	-- ☠ BORN DARK, revealed only once the bind succeeds. The strips are OUR art
	-- with the ENGINE'S colour: between creation and a completed registration
	-- nothing tints them, so a visible holder would render a plain WHITE box
	-- around every icon. The alpha lives on the holder, which is never handed to
	-- a setter, because Blizzard owns Alpha and VertexColor on a registered
	-- dispel texture.
	if button.AddDispelTypeTexture then
		local holder = CreateFrame("Frame", nil, host)
		holder:SetAllPoints(host)
		holder:SetAlpha(0)

		local T = BORDER_THICK
		local edges = {}
		for _, e in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
			local t = holder:CreateTexture(nil, "OVERLAY")
			t:SetColorTexture(1, 1, 1, 1)          -- white: the engine tints it
			if e == "TOP" then
				t:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
				t:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
				t:SetHeight(T)
			elseif e == "BOTTOM" then
				t:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 0, 0)
				t:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
				t:SetHeight(T)
			elseif e == "LEFT" then
				t:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
				t:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 0, 0)
				t:SetWidth(T)
			else
				t:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
				t:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
				t:SetWidth(T)
			end
			edges[#edges + 1] = t
		end

		-- AddDispelTypeTexture APPENDS, so one call per strip puts all four on the
		-- same button and they stay in sync by construction.
		local opts = {
			style           = DispelColorStyle(),
			showWhenHarmful = true,
			showWhenHelpful = false,
			showIcon        = false,
		}
		local ok = true
		for _, t in ipairs(edges) do
			local good = pcall(button.AddDispelTypeTexture, button, t, opts)
			ok = ok and good
		end
		if ok then
			holder:SetAlpha(1)
		else
			Debug("AddDispelTypeTexture failed; border disabled (icon still works)")
		end
	end
end

-------------------------------------------------------------------
-- Container build (once per session, out of combat only)
-------------------------------------------------------------------
-- Cached: the answer cannot change within a session, and BuildContainer re-enters
-- on every cooldown tick while a build is waiting out combat.
local supported = nil
local function ContainerSupported()
	if supported == nil then
		local toc = select(4, GetBuildInfo())
		supported = (type(toc) == "number" and toc >= 120100)
			and (AuraUtil and AuraUtil.IsValidFilterString ~= nil)
			and AuraUtil.IsValidFilterString(DISPEL_FILTER) and true or false
	end
	return supported
end

local function BuildContainer()
	if container or buildFailed then return end

	if not ContainerSupported() then
		buildFailed = true
		Debug("12.1 AuraContainer API unavailable, icon disabled")
		return
	end

	-- Creating an AuraContainer in lockdown is a hard client error that pcall does
	-- NOT catch. Defer to PLAYER_REGEN_ENABLED instead of risking it.
	if InCombatLockdown() then
		buildPending = true
		return
	end
	buildPending = false

	local ok, c = pcall(CreateFrame, "AuraContainer", nil, gate, "CustomAuraContainerTemplate")
	if not ok or not c then
		buildFailed = true
		Debug("CreateFrame(AuraContainer) failed: " .. tostring(c))
		return
	end
	container = c

	-- Build order is load-bearing and must not be reordered:
	--   SetAllPoints -> SetUnit -> AddAuraSlot(filter, initializeFrame) -> SetEnabled LAST.
	-- SetEnabled is what arms the aura parse and the UNIT_AURA registration; enabling
	-- before the slot is declared leaves the icon permanently stale.
	c:SetAllPoints(gate)
	pcall(function()
		if c.SetMouseClickEnabled  then c:SetMouseClickEnabled(false) end
		if c.SetMouseMotionEnabled then c:SetMouseMotionEnabled(false) end
	end)
	c:SetUnit("player")

	-- The button is created, styled and anchored inside InitializeSlot; there is
	-- deliberately nothing to do with the returned handle here.
	local okSlot, err = pcall(c.AddAuraSlot, c, "kuDispel", DISPEL_FILTER,
		{ initializeFrame = InitializeSlot })
	if not okSlot then
		buildFailed = true
		Debug("AddAuraSlot failed: " .. tostring(err))
		return
	end

	pcall(c.SetEnabled, c, Cfg("DispelIconEnable", false) == true)
end

-------------------------------------------------------------------
-- Main refresh
--
-- NOTE what is NOT here any more: any decision about whether a debuff exists.
-- The container answers that on its own, in secure code. This only applies OUR
-- state -- enabled, locked, dispel on cooldown -- and every write it makes lands
-- on a frame we own outside the button subtree.
-------------------------------------------------------------------
local function Refresh()
	if not initialized then return end

	if not Cfg("DispelIconEnable", false) then
		frame:Hide()
		if container then pcall(container.SetEnabled, container, false) end
		return
	end

	BuildContainer()

	-- The frame is a permanent, empty host: it carries no art of its own beyond
	-- the unlocked placeholder, so showing it always is not showing the icon.
	frame:Show()
	if container then pcall(container.SetEnabled, container, true) end

	-- Placeholder: nothing is on screen while no dispellable debuff is up, so
	-- unlocked mode paints a dummy (plus the marching ants) to drag and size
	-- against. Both live on `frame`, outside the button, and are never visible
	-- in combat -- which is what keeps the ants legal.
	local unlocked = not Cfg("DispelIconLock", false)
	phTex:SetShown(unlocked)
	if not unlocked then HideDashes() end

	-- Dispel cooldown gate. `gate` is OURS and sits above the container, so its
	-- alpha cascades into the button subtree without ever writing to it.
	local onCD = false
	if Cfg("DispelIconCheckCD", true) then
		local state = GetDispelState()
		DebugDispel(state)
		onCD = (state == "cooldown")
	end
	if onCD and Cfg("DispelIconHideOnCD", false) then
		gate:SetAlpha(0)
	elseif onCD then
		gate:SetAlpha(DIM_ALPHA)
	else
		gate:SetAlpha(1)
	end
end

-------------------------------------------------------------------
-- Lock / interactivity
-------------------------------------------------------------------
local function ApplyLockState()
	local locked = Cfg("DispelIconLock", false)
	-- Locked -> click-through (non interactive, pure indicator).
	frame:EnableMouse(not locked)
	if locked then
		frame.hint:Hide()
	else
		frame.hint:Show()
	end
end

-------------------------------------------------------------------
-- Frame creation
-------------------------------------------------------------------
local function CreateFrameOnce()
	if frame then return end

	frame = CreateFrame("Frame", "KU_DispelIconFrame", UIParent)
	frame:SetFrameStrata("HIGH")
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if not Cfg("DispelIconLock", false) then self:StartMoving() end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		SavePosition()
	end)
	frame:Hide()

	-- ★ THE GATE. Its only job is to own an alpha we are always allowed to write:
	-- it is ours, it sits ABOVE the container, and alpha cascades downward, so the
	-- dispel-cooldown dim reaches the aura button without touching it.
	gate = CreateFrame("Frame", nil, frame)
	gate:SetAllPoints(frame)

	-- Placeholder art lives on `frame`, NOT on `gate`: it must stay fully visible
	-- while positioning even when the gate is dimmed to zero.
	phTex = frame:CreateTexture(nil, "ARTWORK")
	phTex:SetTexture(PLACEHOLDER)
	phTex:SetDesaturated(true)
	phTex:Hide()

	-- Small "drag me" hint shown only while unlocked
	frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.hint:SetPoint("TOP", frame, "BOTTOM", 0, -2)
	frame.hint:SetText("|cffffd100Drag to move (unlocked)|r")

	-- Marching-ants driver for the placeholder only. Gated on "unlocked" rather
	-- than merely throttled: locked means the ants are hidden, so the whole pass
	-- is dead weight, and it guarantees this never runs while in combat.
	frame:SetScript("OnUpdate", function(_, elapsed)
		if perimeter <= 0 or activeDashCount == 0 then return end
		if Cfg("DispelIconLock", false) then return end
		dashThrottle = dashThrottle + elapsed
		if dashThrottle >= 0.016 then
			dashPhase = (dashPhase + DASH_SPEED * dashThrottle) % perimeter
			dashThrottle = 0
			UpdateDashes()
		end
	end)

	initialized = true
end

-- Seed defaults for options that should start enabled (config is nil until set,
-- and a nil value would otherwise read as "off" in the checkbox).
local function InitDefaults()
	if KU_CharConfig == nil then return end
	if KU_CharConfig.DispelIconCheckCD == nil then
		KU_CharConfig.DispelIconCheckCD = true
	end
end

-------------------------------------------------------------------
-- Public: (re)apply config, called from the options panel & at load
-------------------------------------------------------------------
function KU_DispelIcon_ApplyConfig()
	InitDefaults()
	CreateFrameOnce()
	UpdateLayout()
	ApplyPosition()
	ApplyLockState()
	Refresh()
	SafeStackAlpha()
end

-------------------------------------------------------------------
-- Events
--
-- UNIT_AURA is deliberately NOT registered any more: its payload is fully secret
-- in 12.1 and the container refreshes itself. The only thing left to react to is
-- our own dispel spell's cooldown.
-------------------------------------------------------------------
local lastCDRefresh = 0
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("VARIABLES_LOADED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("SPELL_UPDATE_COOLDOWN")
ev:SetScript("OnEvent", function(_, event)
	if event == "SPELL_UPDATE_COOLDOWN" then
		-- Fires often in combat; throttle so the dispel-cooldown gate refreshes
		-- (e.g. re-lights the icon the moment the dispel comes back up).
		local now = GetTime()
		if now - lastCDRefresh >= 0.1 then
			lastCDRefresh = now
			Refresh()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- Out of combat the button is writable again: finish a deferred build and
		-- re-apply anything the lockdown refused.
		if buildPending then Refresh() end
		if stackDirty then SafeStackAlpha() end
	else
		KU_DispelIcon_ApplyConfig()
	end
end)
