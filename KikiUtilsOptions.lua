--[[
	KikiUtils Options Panel
	Graphical configuration interface for KikiUtils addon.
	Opened via /ku options
]]

-------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------
local PANEL_WIDTH = 780
local PANEL_HEIGHT = 560
local SIDEBAR_WIDTH = 155
local CONTENT_PADDING = 10
local MOUNT_ROW_HEIGHT = 38
local SEARCH_ROW_HEIGHT = 34
local MAX_SEARCH_RESULTS = 80
local MOUNT_ICON_SIZE = 32
local SECTION_SPACING = 12
local CHECKBOX_SPACING = 28
local BIND_ROW_HEIGHT = 40
local BIND_ICON_SIZE = 32

-------------------------------------------------------------------
-- Mount categories definition
-------------------------------------------------------------------
local MOUNT_CATEGORIES = {
	{ key = "Mounts",       label = "Ground" },
	{ key = "FlightMounts", label = "Flying" },
	{ key = "BGMounts",     label = "Battleground" },
	{ key = "INSTMounts",   label = "Instance" },
	{ key = "DFMounts",     label = "Dragonflight" },
	{ key = "AQMounts",     label = "AQ40" },
}

-------------------------------------------------------------------
-- General options definition
-------------------------------------------------------------------
local GENERAL_OPTIONS = {
	{ section = "Display" },
	{ key = "EnableClock",                label = "Show Minimap Clock",                 apply = true },
	{ key = "LockClock",                  label = "Lock Clock Position",                apply = true },
	{ key = "HideSpellActivationOverlay", label = "Hide Spell Activation Overlay",      apply = true },
	{ key = "ShowPercent",                label = "Show Health/Mana Percent on Target", apply = true },
	{ section = "Combat" },
	{ key = "AttackGain",                 label = "Show Extra Attack Gains" },
	{ key = "Dodge",                      label = "Play Sound on Your Dodge" },
	{ key = "TargetDodge",                label = "Play Sound on Target's Dodge" },
	{ key = "Parry",                      label = "Play Sound on Your Parry" },
	{ key = "AutoDisableMusic",           label = "Auto-disable Music on Boss Fight" },
	{ section = "Miscellaneous" },
	{ key = "DebugMode",                  label = "Debug Mode",                         apply = true },
}

-------------------------------------------------------------------
-- Local state
-------------------------------------------------------------------
local mainFrame = nil
local activeCategoryIndex = 1
local activeMountTabIndex = 1
local mountNeedsUpdate = false
local categoryPanels = {}
local categoryButtons = {}
local mountTabButtons = {}
local mountListFrames = {}
local mountScrollChild = nil
local searchScrollChild = nil
local searchEditBox = nil
local searchResultFrames = {}
local generalScrollChild = nil
local bindListFrames = {}
local bindScrollChild = nil
local bindAddForm = nil
local bindDeleteConfirm = nil

-------------------------------------------------------------------
-- Binding types and units supported by KikiUtils
-------------------------------------------------------------------
local BIND_TYPES = { "spell", "action", "item", "macro", "click" }
local BIND_UNITS = { "none", "target", "player", "mouseover", "focus",
	"party1", "party2", "party3", "party4",
	"targettarget" }

-------------------------------------------------------------------
-- Config helpers (directly accessing the global SavedVariable)
-------------------------------------------------------------------
local function GetConfig(key)
	if KU_CharConfig == nil then return false end
	local val = KU_CharConfig[key]
	if val == nil then return false end
	return val
end

local function SetConfig(key, value)
	if KU_CharConfig == nil then KU_CharConfig = {} end
	KU_CharConfig[key] = value
end

local function GetConfigString(key)
	if KU_CharConfig == nil then return "" end
	local val = KU_CharConfig[key]
	if val == nil then return "" end
	return val
end

local function GetConfigInt(key, default)
	if KU_CharConfig == nil then return default end
	local val = KU_CharConfig[key]
	if val == nil then return default end
	return val
end

-------------------------------------------------------------------
-- Apply config change (calls visual effects via KU_API)
-------------------------------------------------------------------
local function ApplyConfigChange(key)
	if KU_API and KU_API.ApplyConfigChange then
		KU_API.ApplyConfigChange(key)
	end
end

-------------------------------------------------------------------
-- Mount helper functions
-------------------------------------------------------------------
local function FindMountInfoByName(mountName)
	local mountIDs = C_MountJournal.GetMountIDs()
	for _, mountID in ipairs(mountIDs) do
		local name, spellID, icon, _, _, _, _, _, _, _, owned = C_MountJournal.GetMountInfoByID(mountID)
		if name == mountName then
			return mountID, name, spellID, icon, owned
		end
	end
	return nil
end

local function GetMountIcon(mountName)
	local _, _, _, icon = FindMountInfoByName(mountName)
	return icon or 134400 -- Question mark icon fallback
end

local function GetMountsForCategory(catKey)
	local mounts = GetConfig(catKey)
	if mounts and type(mounts) == "table" then
		return mounts
	end
	return {}
end

local function AddMountToCategory(catKey, mountName)
	local mounts = GetConfig(catKey)
	if not mounts or type(mounts) ~= "table" then
		mounts = {}
	end
	-- Check for duplicate
	for _, name in ipairs(mounts) do
		if name == mountName then
			return false, "Mount already in this list"
		end
	end
	tinsert(mounts, mountName)
	SetConfig(catKey, mounts)
	-- Refresh mount macros
	if not InCombatLockdown() then
		if KU_SetupMountMacros then KU_SetupMountMacros() end
	else
		mountNeedsUpdate = true
	end
	return true
end

local function RemoveMountFromCategory(catKey, index)
	local mounts = GetConfig(catKey)
	if mounts and type(mounts) == "table" and index >= 1 and index <= #mounts then
		local name = mounts[index]
		tremove(mounts, index)
		if #mounts == 0 then
			SetConfig(catKey, nil)
		end
		-- Refresh mount macros
		if not InCombatLockdown() then
			if KU_SetupMountMacros then KU_SetupMountMacros() end
		else
			mountNeedsUpdate = true
		end
		return true, name
	end
	return false
end

-------------------------------------------------------------------
-- Handle pending mount macro updates after combat
-------------------------------------------------------------------
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function()
	if mountNeedsUpdate then
		mountNeedsUpdate = false
		if KU_SetupMountMacros then KU_SetupMountMacros() end
	end
end)

-------------------------------------------------------------------
-- UI Helper: Create a section header
-------------------------------------------------------------------
local function CreateSectionHeader(parent, text, yOffset)
	local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	header:SetPoint("TOPLEFT", 10, yOffset)
	header:SetText(text)
	header:SetTextColor(1, 0.82, 0)

	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetColorTexture(0.6, 0.5, 0.2, 0.6)
	line:SetHeight(1)
	line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
	line:SetPoint("RIGHT", parent, "RIGHT", -10, 0)

	return header, yOffset - header:GetStringHeight() - 6
end

-------------------------------------------------------------------
-- UI Helper: Create a checkbox
-------------------------------------------------------------------
local function CreateCheckbox(parent, label, x, y, configKey, applyAfter)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetPoint("TOPLEFT", x, y)
	cb:SetSize(26, 26)

	local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	text:SetText(label)
	cb.label = text

	cb:SetChecked(GetConfig(configKey) == true)
	cb:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		SetConfig(configKey, checked)
		if applyAfter then
			ApplyConfigChange(configKey)
		end
	end)

	return cb
end

-------------------------------------------------------------------
-- UI Helper: Create an input row (label + editbox)
-------------------------------------------------------------------
local function CreateInputRow(parent, label, x, y, width, configKey, isNumber, applyAfter)
	local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	lbl:SetPoint("TOPLEFT", x, y)
	lbl:SetText(label)

	local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	eb:SetSize(width, 22)
	eb:SetPoint("TOPLEFT", x + 6, y - 18)
	eb:SetAutoFocus(false)
	eb:SetFontObject(GameFontHighlightSmall)

	if isNumber then
		eb:SetText(tostring(GetConfigInt(configKey, "")))
	else
		eb:SetText(GetConfigString(configKey))
	end

	eb:SetScript("OnEnterPressed", function(self)
		local val = self:GetText()
		if isNumber then
			val = tonumber(val)
			if val then SetConfig(configKey, val) end
		else
			if val == "" then
				SetConfig(configKey, nil)
			else
				SetConfig(configKey, val)
			end
		end
		if applyAfter then ApplyConfigChange(configKey) end
		self:ClearFocus()
	end)
	eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

	return eb, y - 44
end

-------------------------------------------------------------------
-- UI Helper: Create a slider (label + slider + live value)
-------------------------------------------------------------------
local function CreateSlider(parent, label, x, y, width, configKey, minVal, maxVal, step, default, applyAfter)
	local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	lbl:SetPoint("TOPLEFT", x, y)
	lbl:SetText(label)

	local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	slider:SetWidth(width)
	slider:SetPoint("TOPLEFT", x + 6, y - 20)
	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValueStep(step)
	slider:SetObeyStepOnDrag(true)

	local current = GetConfigInt(configKey, default)
	slider:SetValue(current)

	-- OptionsSliderTemplate exposes Low/High/Text via global name; nil name -> use children
	if slider.Low then slider.Low:SetText(tostring(minVal)) end
	if slider.High then slider.High:SetText(tostring(maxVal)) end

	local valText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	valText:SetPoint("LEFT", slider, "RIGHT", 10, 0)
	valText:SetText(tostring(current))

	slider:SetScript("OnValueChanged", function(self, value)
		value = math.floor(value + 0.5)
		valText:SetText(tostring(value))
		SetConfig(configKey, value)
		if applyAfter then ApplyConfigChange(configKey) end
	end)

	return slider, y - 46
end

-------------------------------------------------------------------
-- Create the main options frame
-------------------------------------------------------------------
local function CreateMainFrame()
	local f = CreateFrame("Frame", "KikiUtilsOptionsFrame", UIParent, "BackdropTemplate")
	f:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
	f:SetPoint("CENTER")
	f:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	f:SetBackdropColor(0.05, 0.05, 0.1, 0.92)
	f:SetBackdropBorderColor(0.6, 0.5, 0.2, 1)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(100)
	f:Hide()

	-- Title
	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -12)
	title:SetText("Kiki Utils - Options")
	title:SetTextColor(1, 0.82, 0)

	-- Version
	local version = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	version:SetPoint("TOP", title, "BOTTOM", 0, -2)
	local ver = C_AddOns and C_AddOns.GetAddOnMetadata("KikiUtils", "Version") or "?"
	version:SetText("v" .. ver)
	version:SetTextColor(0.6, 0.6, 0.6)

	-- Close button
	local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", -2, -2)

	-- Escape to close
	tinsert(UISpecialFrames, "KikiUtilsOptionsFrame")

	return f
end

-------------------------------------------------------------------
-- Create the sidebar with category buttons
-------------------------------------------------------------------
local function CreateSidebar(parent)
	local sidebar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	sidebar:SetPoint("TOPLEFT", 8, -42)
	sidebar:SetPoint("BOTTOMLEFT", 8, 8)
	sidebar:SetWidth(SIDEBAR_WIDTH)
	sidebar:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	sidebar:SetBackdropColor(0.1, 0.1, 0.15, 0.7)
	sidebar:SetBackdropBorderColor(0.4, 0.35, 0.15, 0.8)

	local categories = { "General", "Mounts", "Binds" }
	for i, catName in ipairs(categories) do
		local btn = CreateFrame("Button", nil, sidebar)
		btn:SetSize(SIDEBAR_WIDTH - 16, 32)
		btn:SetPoint("TOPLEFT", 8, -8 - (i - 1) * 36)

		local bg = btn:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.3, 0.25, 0.1, 0)
		btn.bg = bg

		local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		text:SetPoint("LEFT", 10, 0)
		text:SetText(catName)
		btn.text = text

		local hl = btn:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetColorTexture(0.4, 0.35, 0.15, 0.3)

		btn:SetScript("OnClick", function()
			activeCategoryIndex = i
			KU_Options_ShowCategory(i)
		end)

		categoryButtons[i] = btn
	end

	return sidebar
end

-------------------------------------------------------------------
-- Category button highlight
-------------------------------------------------------------------
local function UpdateCategoryHighlight()
	for i, btn in ipairs(categoryButtons) do
		if i == activeCategoryIndex then
			btn.bg:SetColorTexture(0.4, 0.35, 0.1, 0.6)
			btn.text:SetTextColor(1, 0.82, 0)
		else
			btn.bg:SetColorTexture(0, 0, 0, 0)
			btn.text:SetTextColor(1, 1, 1)
		end
	end
end

-------------------------------------------------------------------
-- Create the content area frame
-------------------------------------------------------------------
local function CreateContentArea(parent)
	local content = CreateFrame("Frame", nil, parent)
	content:SetPoint("TOPLEFT", SIDEBAR_WIDTH + 16, -42)
	content:SetPoint("BOTTOMRIGHT", -8, 8)
	return content
end

-------------------------------------------------------------------
-- GENERAL OPTIONS PANEL
-------------------------------------------------------------------
local function CreateGeneralPanel(parent)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetAllPoints()
	panel:Hide()

	-- Scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 4, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)

	local scrollChild = CreateFrame("Frame")
	scrollFrame:SetScrollChild(scrollChild)
	scrollChild:SetWidth(scrollFrame:GetWidth() or (PANEL_WIDTH - SIDEBAR_WIDTH - 60))
	generalScrollChild = scrollChild

	-- Dynamically set width after layout
	panel:SetScript("OnShow", function(self)
		scrollChild:SetWidth(scrollFrame:GetWidth())
	end)

	local yPos = -10

	-- Build checkboxes and sections
	for _, opt in ipairs(GENERAL_OPTIONS) do
		if opt.section then
			local _, newY = CreateSectionHeader(scrollChild, opt.section, yPos)
			yPos = newY - 4
		else
			CreateCheckbox(scrollChild, opt.label, 16, yPos, opt.key, opt.apply)
			yPos = yPos - CHECKBOX_SPACING
		end
	end

	-- Additional text options
	yPos = yPos - SECTION_SPACING
	local _, newY = CreateSectionHeader(scrollChild, "Text Options", yPos)
	yPos = newY - 4

	-- Bip keyword
	local _, newY2 = CreateInputRow(scrollChild, "Bip Keyword (alert on guild/party/raid chat):", 16, yPos, 200, "BipStr",
		false)
	yPos = newY2

	-- Loss of control position
	local _, newY3 = CreateInputRow(scrollChild, "Loss of Control Position (x,y e.g. 0,-200):", 16, yPos, 150,
		"LossOfControl",
		false, true)
	yPos = newY3

	yPos = yPos - SECTION_SPACING
	local _, newY4 = CreateSectionHeader(scrollChild, "Bags", yPos)
	yPos = newY4 - 4

	-- Bags offset
	local bagOffsetBox
	bagOffsetBox, yPos = CreateInputRow(scrollChild, "Bags Y-Offset (blank to disable):", 16, yPos, 80, "AdjustBags", true,
		true)

	-- Bags scale
	local bagScaleBox
	bagScaleBox, yPos = CreateInputRow(scrollChild, "Bags Scale:", 16, yPos, 80, "ScaleBags", true, true)

	-- Dispel / important-debuff alert icon
	yPos = yPos - SECTION_SPACING
	local _, newY5 = CreateSectionHeader(scrollChild, "Dispel Alert Icon", yPos)
	yPos = newY5 - 4

	local hint = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	hint:SetPoint("TOPLEFT", 16, yPos)
	hint:SetWidth(560)
	hint:SetJustifyH("LEFT")
	hint:SetText("|cff909090Shows a big icon when you have a debuff you can dispel, with a border coloured " ..
		"by dispel type. Unlock to drag/resize; a placeholder icon is shown while unlocked.|r")
	yPos = yPos - 40

	CreateCheckbox(scrollChild, "Enable Dispel Alert Icon", 16, yPos, "DispelIconEnable", true)
	yPos = yPos - CHECKBOX_SPACING
	CreateCheckbox(scrollChild, "Lock Position (click-through)", 16, yPos, "DispelIconLock", true)
	yPos = yPos - CHECKBOX_SPACING
	CreateCheckbox(scrollChild, "Show Stack Count", 16, yPos, "DispelIconShowStacks", true)
	yPos = yPos - CHECKBOX_SPACING
	CreateCheckbox(scrollChild, "React to your dispel's cooldown (dim when on CD)", 16, yPos, "DispelIconCheckCD", true)
	yPos = yPos - CHECKBOX_SPACING
	-- \194\187 = "\194\187" (U+00BB). Latin-1, so WoW's fonts have the glyph; the
	-- previous marker was U+21B3 and rendered as an empty box.
	CreateCheckbox(scrollChild, "   \194\187 Fully hide (instead of dimming) while on cooldown", 16, yPos, "DispelIconHideOnCD", true)
	yPos = yPos - CHECKBOX_SPACING - 6

	local sizeSlider
	sizeSlider, yPos = CreateSlider(scrollChild, "Icon Size:", 16, yPos, 200, "DispelIconSize", 32, 128, 1, 64, true)

	-- Set content height
	scrollChild:SetHeight(math.abs(yPos) + 20)

	categoryPanels[1] = panel
	return panel
end

-------------------------------------------------------------------
-- MOUNT TAB BUTTONS
-------------------------------------------------------------------
local function UpdateMountTabHighlight()
	for i, btn in ipairs(mountTabButtons) do
		if i == activeMountTabIndex then
			btn.bg:SetColorTexture(0.35, 0.3, 0.1, 0.7)
			btn.text:SetTextColor(1, 0.82, 0)
		else
			btn.bg:SetColorTexture(0.15, 0.15, 0.2, 0.5)
			btn.text:SetTextColor(0.8, 0.8, 0.8)
		end
	end
end

-------------------------------------------------------------------
-- Refresh the mount list for the current tab
-------------------------------------------------------------------
local function RefreshMountList()
	-- Clear old rows
	for _, row in ipairs(mountListFrames) do
		row:Hide()
		row:SetParent(nil)
	end
	wipe(mountListFrames)

	if not mountScrollChild then return end

	local catKey = MOUNT_CATEGORIES[activeMountTabIndex].key
	local mounts = GetMountsForCategory(catKey)
	local yPos = 0

	for i, mountName in ipairs(mounts) do
		local row = CreateFrame("Frame", nil, mountScrollChild, "BackdropTemplate")
		row:SetSize(mountScrollChild:GetWidth() - 4, MOUNT_ROW_HEIGHT)
		row:SetPoint("TOPLEFT", 2, -yPos)
		row:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 },
		})
		row:SetBackdropColor(0.12, 0.12, 0.18, 0.6)
		row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

		-- Mount icon
		local icon = row:CreateTexture(nil, "ARTWORK")
		icon:SetSize(MOUNT_ICON_SIZE, MOUNT_ICON_SIZE)
		icon:SetPoint("LEFT", 4, 0)
		icon:SetTexture(GetMountIcon(mountName))
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		-- Mount name
		local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		nameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
		nameText:SetPoint("RIGHT", row, "RIGHT", -36, 0)
		nameText:SetJustifyH("LEFT")
		nameText:SetText(mountName)
		nameText:SetWordWrap(false)

		-- Delete button
		local delBtn = CreateFrame("Button", nil, row)
		delBtn:SetSize(22, 22)
		delBtn:SetPoint("RIGHT", -6, 0)
		delBtn:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Pass-Up")
		delBtn:SetHighlightTexture("Interface/Buttons/UI-GroupLoot-Pass-Highlight")
		delBtn.mountIndex = i
		delBtn.catKey = catKey
		delBtn:SetScript("OnClick", function(self)
			local ok, removedName = RemoveMountFromCategory(self.catKey, self.mountIndex)
			if ok then
				RefreshMountList()
				UpdateMountTabHighlight() -- refresh counts
			end
		end)
		delBtn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Remove this mount")
			GameTooltip:Show()
		end)
		delBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

		-- Highlight on hover
		row:EnableMouse(true)
		row:SetScript("OnEnter", function(self)
			self:SetBackdropColor(0.2, 0.2, 0.3, 0.8)
			-- Show tooltip with mount info
			local mID, _, spellID, mIcon, owned = FindMountInfoByName(mountName)
			if mID then
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
				GameTooltip:SetMountBySpellID(spellID)
				GameTooltip:Show()
			end
		end)
		row:SetScript("OnLeave", function(self)
			self:SetBackdropColor(0.12, 0.12, 0.18, 0.6)
			GameTooltip:Hide()
		end)

		mountListFrames[i] = row
		yPos = yPos + MOUNT_ROW_HEIGHT + 2
	end

	-- Update scroll child height to fit content + drop zone
	local totalHeight = yPos + 80
	mountScrollChild:SetHeight(math.max(totalHeight, 100))

	-- Update tab labels with counts
	for i, cat in ipairs(MOUNT_CATEGORIES) do
		local count = #GetMountsForCategory(cat.key)
		local label = cat.label
		if count > 0 then
			label = label .. " (" .. count .. ")"
		end
		if mountTabButtons[i] then
			mountTabButtons[i].text:SetText(label)
		end
	end
end

-------------------------------------------------------------------
-- Refresh search results
-------------------------------------------------------------------
local function RefreshSearchResults(filter)
	-- Clear old results
	for _, row in ipairs(searchResultFrames) do
		row:Hide()
		row:SetParent(nil)
	end
	wipe(searchResultFrames)

	if not searchScrollChild then return end
	if not filter or filter == "" then
		searchScrollChild:SetHeight(1)
		return
	end

	local filterUpper = string.upper(filter)
	local mountIDs = C_MountJournal.GetMountIDs()
	local results = {}

	for _, mountID in ipairs(mountIDs) do
		local name, spellID, icon, _, summonable, _, _, _, _, _, owned = C_MountJournal.GetMountInfoByID(mountID)
		if owned and name and string.find(string.upper(name), filterUpper, 1, true) then
			tinsert(results, { mountID = mountID, name = name, spellID = spellID, icon = icon, summonable = summonable })
			if #results >= MAX_SEARCH_RESULTS then break end
		end
	end

	local yPos = 0
	local catKey = MOUNT_CATEGORIES[activeMountTabIndex].key

	for i, info in ipairs(results) do
		local row = CreateFrame("Frame", nil, searchScrollChild)
		row:SetSize(searchScrollChild:GetWidth() - 4, SEARCH_ROW_HEIGHT)
		row:SetPoint("TOPLEFT", 2, -yPos)

		-- Icon
		local icon = row:CreateTexture(nil, "ARTWORK")
		icon:SetSize(28, 28)
		icon:SetPoint("LEFT", 4, 0)
		icon:SetTexture(info.icon)
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		-- Name
		local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		nameText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
		nameText:SetPoint("RIGHT", row, "RIGHT", -60, 0)
		nameText:SetJustifyH("LEFT")
		nameText:SetText(info.name)
		nameText:SetWordWrap(false)

		-- Add button
		local addBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		addBtn:SetSize(46, 22)
		addBtn:SetPoint("RIGHT", -4, 0)
		addBtn:SetText("Add")
		addBtn.mountName = info.name
		addBtn.summonable = info.summonable
		addBtn:SetScript("OnClick", function(self)
			if not self.summonable then
				if KU_API and KU_API.ChatPrint then
					KU_API.ChatPrint("This mount is not summonable by this character")
				end
				return
			end
			local ok, err = AddMountToCategory(catKey, self.mountName)
			if ok then
				RefreshMountList()
			elseif err and KU_API and KU_API.ChatPrint then
				KU_API.ChatPrint(err)
			end
		end)

		-- Gray out if not summonable
		if not info.summonable then
			nameText:SetTextColor(0.5, 0.5, 0.5)
			icon:SetDesaturated(true)
		end

		-- Tooltip
		row:EnableMouse(true)
		row:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetMountBySpellID(info.spellID)
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)

		searchResultFrames[i] = row
		yPos = yPos + SEARCH_ROW_HEIGHT + 1
	end

	searchScrollChild:SetHeight(math.max(yPos + 10, 1))
end

-------------------------------------------------------------------
-- Handle mount drop from cursor (drag & drop from Mount Journal)
-------------------------------------------------------------------
local function HandleMountDrop()
	local cursorType, cursorID = GetCursorInfo()
	if cursorType == "mount" then
		-- cursorID is the mountID
		local name, spellID, icon, _, summonable, _, _, _, _, _, owned = C_MountJournal.GetMountInfoByID(cursorID)
		if not name then
			ClearCursor()
			return false
		end
		if not owned then
			if KU_API and KU_API.ChatPrint then
				KU_API.ChatPrint("You do not own this mount")
			end
			ClearCursor()
			return false
		end
		if not summonable then
			if KU_API and KU_API.ChatPrint then
				KU_API.ChatPrint("This mount is not summonable by this character")
			end
			ClearCursor()
			return false
		end

		local catKey = MOUNT_CATEGORIES[activeMountTabIndex].key
		local ok, err = AddMountToCategory(catKey, name)
		ClearCursor()
		if ok then
			RefreshMountList()
			return true
		elseif err and KU_API and KU_API.ChatPrint then
			KU_API.ChatPrint(err)
		end
		return false
	end
	return false
end

-------------------------------------------------------------------
-- MOUNTS PANEL
-------------------------------------------------------------------
local function CreateMountsPanel(parent)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetAllPoints()
	panel:Hide()

	-- Tab bar at top
	local tabBar = CreateFrame("Frame", nil, panel)
	tabBar:SetPoint("TOPLEFT", 4, -4)
	tabBar:SetPoint("TOPRIGHT", -4, -4)
	tabBar:SetHeight(30)

	local tabWidth = math.floor((tabBar:GetWidth() or (PANEL_WIDTH - SIDEBAR_WIDTH - 60)) / #MOUNT_CATEGORIES)
	-- Use fixed width for safety
	tabWidth = 90

	for i, cat in ipairs(MOUNT_CATEGORIES) do
		local btn = CreateFrame("Button", nil, tabBar)
		btn:SetSize(tabWidth, 26)
		btn:SetPoint("TOPLEFT", (i - 1) * (tabWidth + 2) + 2, -2)

		local bg = btn:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.15, 0.15, 0.2, 0.5)
		btn.bg = bg

		local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		text:SetPoint("CENTER")
		text:SetText(cat.label)
		btn.text = text

		local hl = btn:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetColorTexture(0.4, 0.35, 0.15, 0.3)

		btn:SetScript("OnClick", function()
			activeMountTabIndex = i
			UpdateMountTabHighlight()
			RefreshMountList()
			-- Clear search
			if searchEditBox then searchEditBox:SetText("") end
			RefreshSearchResults("")
		end)

		mountTabButtons[i] = btn
	end

	-- Mount list area (upper half)
	local listLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	listLabel:SetPoint("TOPLEFT", 8, -38)
	listLabel:SetText("Configured Mounts:")
	listLabel:SetTextColor(0.9, 0.8, 0.5)

	local listFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	listFrame:SetPoint("TOPLEFT", 4, -54)
	listFrame:SetPoint("RIGHT", -4, 0)
	listFrame:SetHeight(200)
	listFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	listFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.7)
	listFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

	local mountScroll = CreateFrame("ScrollFrame", "KU_MountListScrollFrame", listFrame, "UIPanelScrollFrameTemplate")
	mountScroll:SetPoint("TOPLEFT", 4, -4)
	mountScroll:SetPoint("BOTTOMRIGHT", -24, 4)

	mountScrollChild = CreateFrame("Frame")
	mountScroll:SetScrollChild(mountScrollChild)
	mountScrollChild:SetWidth(mountScroll:GetWidth() or 400)
	mountScrollChild:SetHeight(1)

	-- Fix scroll child width on show
	panel:HookScript("OnShow", function()
		C_Timer.After(0.01, function()
			mountScrollChild:SetWidth(mountScroll:GetWidth())
			RefreshMountList()
		end)
	end)

	-- Drop zone
	local dropZone = CreateFrame("Button", nil, panel, "BackdropTemplate")
	dropZone:SetPoint("TOPLEFT", 4, -260)
	dropZone:SetPoint("RIGHT", -4, 0)
	dropZone:SetHeight(44)
	dropZone:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	dropZone:SetBackdropColor(0.15, 0.2, 0.15, 0.5)
	dropZone:SetBackdropBorderColor(0.3, 0.5, 0.3, 0.7)

	local dropIcon = dropZone:CreateTexture(nil, "ARTWORK")
	dropIcon:SetSize(28, 28)
	dropIcon:SetPoint("LEFT", 10, 0)
	dropIcon:SetTexture("Interface/PaperDollInfoFrame/Character-Plus")

	local dropText = dropZone:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	dropText:SetPoint("LEFT", dropIcon, "RIGHT", 8, 0)
	dropText:SetText("Drag & Drop a mount here from your Mount Journal")
	dropText:SetTextColor(0.5, 0.9, 0.5)

	dropZone:SetScript("OnClick", function() HandleMountDrop() end)
	dropZone:SetScript("OnReceiveDrag", function() HandleMountDrop() end)

	-- Hover effect on drop zone when dragging a mount
	dropZone:SetScript("OnEnter", function(self)
		local cursorType = GetCursorInfo()
		if cursorType == "mount" then
			self:SetBackdropColor(0.2, 0.4, 0.2, 0.8)
			self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
		end
	end)
	dropZone:SetScript("OnLeave", function(self)
		self:SetBackdropColor(0.15, 0.2, 0.15, 0.5)
		self:SetBackdropBorderColor(0.3, 0.5, 0.3, 0.7)
	end)

	-- Search section (lower half)
	local searchLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	searchLabel:SetPoint("TOPLEFT", 8, -312)
	searchLabel:SetText("Search & Add Mount:")
	searchLabel:SetTextColor(0.9, 0.8, 0.5)

	searchEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	searchEditBox:SetSize(250, 22)
	searchEditBox:SetPoint("TOPLEFT", 14, -330)
	searchEditBox:SetAutoFocus(false)
	searchEditBox:SetFontObject(GameFontHighlightSmall)

	local searchInfoText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	searchInfoText:SetPoint("LEFT", searchEditBox, "RIGHT", 10, 0)
	searchInfoText:SetText("Type mount name to filter owned mounts")
	searchInfoText:SetTextColor(0.5, 0.5, 0.5)

	-- Throttled search
	local searchTimer = nil
	searchEditBox:SetScript("OnTextChanged", function(self, userInput)
		if not userInput then return end
		if searchTimer then searchTimer:Cancel() end
		searchTimer = C_Timer.NewTimer(0.25, function()
			RefreshSearchResults(self:GetText())
		end)
	end)
	searchEditBox:SetScript("OnEnterPressed", function(self)
		RefreshSearchResults(self:GetText())
		self:ClearFocus()
	end)
	searchEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

	-- Search results scroll frame
	local searchFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	searchFrame:SetPoint("TOPLEFT", 4, -356)
	searchFrame:SetPoint("BOTTOMRIGHT", -4, 8)
	searchFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	searchFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.7)
	searchFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

	local searchScroll = CreateFrame("ScrollFrame", "KU_SearchScrollFrame", searchFrame, "UIPanelScrollFrameTemplate")
	searchScroll:SetPoint("TOPLEFT", 4, -4)
	searchScroll:SetPoint("BOTTOMRIGHT", -24, 4)

	searchScrollChild = CreateFrame("Frame")
	searchScroll:SetScrollChild(searchScrollChild)
	searchScrollChild:SetWidth(searchScroll:GetWidth() or 400)
	searchScrollChild:SetHeight(1)

	-- Fix search scroll child width
	panel:HookScript("OnShow", function()
		C_Timer.After(0.02, function()
			if searchScroll:GetWidth() > 0 then
				searchScrollChild:SetWidth(searchScroll:GetWidth())
			end
		end)
	end)

	categoryPanels[2] = panel
	return panel
end

-------------------------------------------------------------------
-- BINDS PANEL
-------------------------------------------------------------------

-- Try to get a spell icon from spell name
local function GetSpellIconByName(spellName)
	if not spellName or spellName == "" then return nil end
	-- Try as a spellID number first
	local asNum = tonumber(spellName)
	if asNum then
		local info = C_Spell.GetSpellInfo(asNum)
		if info then return info.iconID end
	end
	-- Try as spell name
	local info = C_Spell.GetSpellInfo(spellName)
	if info then return info.iconID end
	return nil
end

local function GetBindingIcon(bind)
	if bind.type == "spell" then
		return GetSpellIconByName(bind.name) or 134400
	elseif bind.type == "item" then
		local _, _, _, _, icon = C_Item.GetItemInfoInstant(bind.name)
		return icon or 134400
	elseif bind.type == "macro" then
		return 134400 -- generic macro icon
	elseif bind.type == "action" then
		return 134400
	elseif bind.type == "click" then
		return 134400
	end
	return 134400
end

-- Forward declaration
local RefreshBindList

-------------------------------------------------------------------
-- Delete confirmation popup
-------------------------------------------------------------------
local function ShowDeleteBindConfirm(index, bindInfo, onConfirm)
	if bindDeleteConfirm then
		bindDeleteConfirm:Hide()
		bindDeleteConfirm:SetParent(nil)
		bindDeleteConfirm = nil
	end

	local popup = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
	popup:SetSize(360, 110)
	popup:SetPoint("CENTER", mainFrame, "CENTER", 0, 40)
	popup:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 14,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	popup:SetBackdropColor(0.1, 0.05, 0.05, 0.95)
	popup:SetBackdropBorderColor(0.8, 0.3, 0.3, 1)
	popup:SetFrameStrata("TOOLTIP")
	popup:SetFrameLevel(200)
	popup:EnableMouse(true)

	local msg = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	msg:SetPoint("TOP", 0, -14)
	msg:SetWidth(330)
	msg:SetText("Remove binding #" .. index .. "?\n" ..
		"|cffffffff[" .. bindInfo.key .. "]|r " .. bindInfo.type .. " '" .. bindInfo.name .. "' -> " .. bindInfo.unit)

	local yesBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
	yesBtn:SetSize(100, 24)
	yesBtn:SetPoint("BOTTOMLEFT", 40, 12)
	yesBtn:SetText("Delete")
	yesBtn:SetScript("OnClick", function()
		onConfirm()
		popup:Hide()
		popup:SetParent(nil)
		bindDeleteConfirm = nil
	end)

	local noBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
	noBtn:SetSize(100, 24)
	noBtn:SetPoint("BOTTOMRIGHT", -40, 12)
	noBtn:SetText("Cancel")
	noBtn:SetScript("OnClick", function()
		popup:Hide()
		popup:SetParent(nil)
		bindDeleteConfirm = nil
	end)

	bindDeleteConfirm = popup
	popup:Show()
end

-------------------------------------------------------------------
-- Dropdown helper (simple custom dropdown)
-------------------------------------------------------------------
local function CreateSimpleDropdown(parent, x, y, width, items, defaultValue)
	local container = CreateFrame("Frame", nil, parent)
	container:SetSize(width, 24)
	container:SetPoint("TOPLEFT", x, y)

	local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
	btn:SetAllPoints()
	btn:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	btn:SetBackdropColor(0.15, 0.15, 0.2, 0.9)
	btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)

	local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	text:SetPoint("LEFT", 6, 0)
	text:SetPoint("RIGHT", -18, 0)
	text:SetJustifyH("LEFT")
	text:SetText(defaultValue or items[1] or "")

	local arrow = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	arrow:SetPoint("RIGHT", -4, 0)
	arrow:SetText("v")

	container.selectedValue = defaultValue or items[1] or ""
	container.text = text

	function container:SetValue(val)
		self.selectedValue = val
		self.text:SetText(val)
	end

	function container:GetValue()
		return self.selectedValue
	end

	-- Menu frame
	local menuFrame = nil
	local closingMenu = false

	local function CloseMenu()
		if closingMenu then return end
		if menuFrame then
			closingMenu = true
			menuFrame:Hide()
			menuFrame:SetParent(nil)
			menuFrame = nil
			closingMenu = false
		end
	end

	btn:SetScript("OnClick", function(self)
		if menuFrame then
			CloseMenu()
			return
		end

		local mf = CreateFrame("Frame", nil, self, "BackdropTemplate")
		local itemHeight = 20
		local menuHeight = #items * itemHeight + 8
		mf:SetSize(width, menuHeight)
		mf:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
		mf:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 },
		})
		mf:SetBackdropColor(0.1, 0.1, 0.15, 0.98)
		mf:SetBackdropBorderColor(0.6, 0.5, 0.2, 1)
		mf:SetFrameStrata("TOOLTIP")
		mf:SetFrameLevel(210)
		mf:EnableMouse(true)

		for idx, item in ipairs(items) do
			local itemBtn = CreateFrame("Button", nil, mf)
			itemBtn:SetSize(width - 8, itemHeight)
			itemBtn:SetPoint("TOPLEFT", 4, -4 - (idx - 1) * itemHeight)

			local itemText = itemBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			itemText:SetPoint("LEFT", 4, 0)
			itemText:SetText(item)

			local hl = itemBtn:CreateTexture(nil, "HIGHLIGHT")
			hl:SetAllPoints()
			hl:SetColorTexture(0.4, 0.35, 0.15, 0.4)

			itemBtn:SetScript("OnClick", function()
				container:SetValue(item)
				CloseMenu()
				if container.OnValueChanged then
					container:OnValueChanged(item)
				end
			end)
		end

		menuFrame = mf

		-- Close when clicking elsewhere
		mf:SetScript("OnHide", function() CloseMenu() end)
	end)

	return container
end

-------------------------------------------------------------------
-- Handle spell drop from cursor (drag & drop from Spellbook)
-------------------------------------------------------------------
local function HandleSpellDropForBind(spellEditBox)
	local cursorType, id, subType, spellID = GetCursorInfo()
	if cursorType == "spell" then
		-- In modern WoW, the 4th return is the actual spellID
		local resolvedID = spellID or id
		local name = nil
		-- Try C_Spell.GetSpellInfo with the resolved ID
		local info = C_Spell.GetSpellInfo(resolvedID)
		if info and info.name then
			name = info.name
		end
		-- Fallback: try with id directly if spellID didn't work
		if not name and id ~= resolvedID then
			info = C_Spell.GetSpellInfo(id)
			if info and info.name then
				name = info.name
			end
		end
		-- Fallback: try C_Spell.GetSpellName
		if not name and C_Spell.GetSpellName then
			local ok, n = pcall(C_Spell.GetSpellName, resolvedID)
			if ok and n then name = n end
		end
		if name then
			spellEditBox:SetText(name)
			-- Auto-set type dropdown to spell
			if spellEditBox.typeDropdown then
				spellEditBox.typeDropdown:SetValue("spell")
			end
		end
		ClearCursor()
		return true
	elseif cursorType == "item" then
		local name = C_Item.GetItemInfo(id)
		if name then
			spellEditBox:SetText(name)
			if spellEditBox.typeDropdown then
				spellEditBox.typeDropdown:SetValue("item")
			end
		end
		ClearCursor()
		return true
	elseif cursorType == "macro" then
		local mName = GetMacroInfo(id)
		if mName then
			spellEditBox:SetText(mName)
			if spellEditBox.typeDropdown then
				spellEditBox.typeDropdown:SetValue("macro")
			end
		end
		ClearCursor()
		return true
	end
	return false
end

-------------------------------------------------------------------
-- Refresh the binds list
-------------------------------------------------------------------
RefreshBindList = function()
	-- Clear old rows
	for _, row in ipairs(bindListFrames) do
		row:Hide()
		row:SetParent(nil)
	end
	wipe(bindListFrames)

	if not bindScrollChild then return end

	local binds = KU_GetBindings and KU_GetBindings() or nil
	if not binds then
		bindScrollChild:SetHeight(40)
		return
	end

	local yPos = 0

	for i, info in ipairs(binds) do
		local row = CreateFrame("Frame", nil, bindScrollChild, "BackdropTemplate")
		row:SetSize(bindScrollChild:GetWidth() - 4, BIND_ROW_HEIGHT)
		row:SetPoint("TOPLEFT", 2, -yPos)
		row:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 10,
			insets = { left = 2, right = 2, top = 2, bottom = 2 },
		})
		row:SetBackdropColor(0.12, 0.12, 0.18, 0.6)
		row:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

		-- Icon
		local icon = row:CreateTexture(nil, "ARTWORK")
		icon:SetSize(BIND_ICON_SIZE, BIND_ICON_SIZE)
		icon:SetPoint("LEFT", 4, 0)
		icon:SetTexture(GetBindingIcon(info))
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		-- Key column
		local keyText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		keyText:SetPoint("LEFT", icon, "RIGHT", 6, 0)
		keyText:SetWidth(80)
		keyText:SetJustifyH("LEFT")
		keyText:SetText("|cff40ff40[" .. info.key .. "]|r")
		keyText:SetWordWrap(false)

		-- Type column
		local typeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		typeText:SetPoint("LEFT", keyText, "RIGHT", 4, 0)
		typeText:SetWidth(50)
		typeText:SetJustifyH("LEFT")
		local typeColors = {
			spell = "|cff71d5ff",
			item = "|cffa335ee",
			macro = "|cffff8000",
			action = "|cffffff00",
			click = "|cff00ff00",
		}
		local col = typeColors[info.type] or "|cffffffff"
		typeText:SetText(col .. info.type .. "|r")

		-- Name column
		local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		nameText:SetPoint("LEFT", typeText, "RIGHT", 4, 0)
		nameText:SetWidth(180)
		nameText:SetJustifyH("LEFT")
		nameText:SetText(info.name)
		nameText:SetWordWrap(false)

		-- Unit column
		local unitText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		unitText:SetPoint("LEFT", nameText, "RIGHT", 4, 0)
		unitText:SetWidth(75)
		unitText:SetJustifyH("LEFT")
		unitText:SetText("|cffaaaaaa" .. info.unit .. "|r")

		-- Delete button
		local delBtn = CreateFrame("Button", nil, row)
		delBtn:SetSize(22, 22)
		delBtn:SetPoint("RIGHT", -6, 0)
		delBtn:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Pass-Up")
		delBtn:SetHighlightTexture("Interface/Buttons/UI-GroupLoot-Pass-Highlight")
		delBtn.bindIndex = i
		delBtn:SetScript("OnClick", function(self)
			local idx = self.bindIndex
			local bInfo = binds[idx]
			if bInfo then
				ShowDeleteBindConfirm(idx, bInfo, function()
					KU_DelSpellBinding(idx)
					RefreshBindList()
				end)
			end
		end)
		delBtn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Remove this binding")
			GameTooltip:Show()
		end)
		delBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

		-- Row hover effect + tooltip for spells
		row:EnableMouse(true)
		row:SetScript("OnEnter", function(self)
			self:SetBackdropColor(0.2, 0.2, 0.3, 0.8)
			if info.type == "spell" then
				local spInfo = C_Spell.GetSpellInfo(info.name)
				if spInfo then
					GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
					GameTooltip:SetSpellByID(spInfo.spellID)
					GameTooltip:Show()
				end
			end
		end)
		row:SetScript("OnLeave", function(self)
			self:SetBackdropColor(0.12, 0.12, 0.18, 0.6)
			GameTooltip:Hide()
		end)

		bindListFrames[i] = row
		yPos = yPos + BIND_ROW_HEIGHT + 2
	end

	bindScrollChild:SetHeight(math.max(yPos + 20, 60))
end

-------------------------------------------------------------------
-- Create the Binds panel
-------------------------------------------------------------------
local function CreateBindsPanel(parent)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetAllPoints()
	panel:Hide()

	-- Current spec info
	local specLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	specLabel:SetPoint("TOPLEFT", 8, -6)
	specLabel:SetTextColor(0.6, 0.6, 0.6)
	panel:SetScript("OnShow", function()
		local specIdx = GetSpecialization()
		local specName = specIdx and select(2, GetSpecializationInfo(specIdx)) or "Unknown"
		specLabel:SetText("Current Spec: " .. specName .. " (spec #" .. tostring(specIdx) .. ")")
	end)

	-- Bind list header
	local headerLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	headerLabel:SetPoint("TOPLEFT", 8, -22)
	headerLabel:SetText("Current Key Bindings:")
	headerLabel:SetTextColor(0.9, 0.8, 0.5)

	-- Column headers
	local colY = -36
	local colHeaders = {
		{ text = "",     x = 8,   w = 38 },
		{ text = "Key",  x = 46,  w = 80 },
		{ text = "Type", x = 130, w = 50 },
		{ text = "Name", x = 184, w = 180 },
		{ text = "Unit", x = 368, w = 75 },
	}
	for _, ch in ipairs(colHeaders) do
		local ct = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		ct:SetPoint("TOPLEFT", ch.x, colY)
		ct:SetWidth(ch.w)
		ct:SetJustifyH("LEFT")
		ct:SetText(ch.text)
		ct:SetTextColor(0.7, 0.65, 0.4)
	end

	-- Bind list scroll area
	local listFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	listFrame:SetPoint("TOPLEFT", 4, -50)
	listFrame:SetPoint("RIGHT", -4, 0)
	listFrame:SetHeight(230)
	listFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	listFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.7)
	listFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

	local bindScroll = CreateFrame("ScrollFrame", "KU_BindListScrollFrame", listFrame, "UIPanelScrollFrameTemplate")
	bindScroll:SetPoint("TOPLEFT", 4, -4)
	bindScroll:SetPoint("BOTTOMRIGHT", -24, 4)

	bindScrollChild = CreateFrame("Frame")
	bindScroll:SetScrollChild(bindScrollChild)
	bindScrollChild:SetWidth(bindScroll:GetWidth() or 500)
	bindScrollChild:SetHeight(1)

	panel:HookScript("OnShow", function()
		C_Timer.After(0.01, function()
			bindScrollChild:SetWidth(bindScroll:GetWidth())
			RefreshBindList()
		end)
	end)

	-- =============================================
	-- Add New Binding section
	-- =============================================
	local addLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	addLabel:SetPoint("TOPLEFT", 8, -288)
	addLabel:SetText("Add New Binding:")
	addLabel:SetTextColor(0.9, 0.8, 0.5)

	local addFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	addFrame:SetPoint("TOPLEFT", 4, -304)
	addFrame:SetPoint("BOTTOMRIGHT", -4, 8)
	addFrame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	addFrame:SetBackdropColor(0.1, 0.12, 0.1, 0.7)
	addFrame:SetBackdropBorderColor(0.3, 0.5, 0.3, 0.6)

	-- Row 1: Key + Type + Unit
	local row1Y = -10

	-- Key label + editbox
	local keyLabel = addFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	keyLabel:SetPoint("TOPLEFT", 10, row1Y)
	keyLabel:SetText("Key:")

	local keyEditBox = CreateFrame("EditBox", nil, addFrame, "InputBoxTemplate")
	keyEditBox:SetSize(100, 22)
	keyEditBox:SetPoint("TOPLEFT", 10, row1Y - 16)
	keyEditBox:SetAutoFocus(false)
	keyEditBox:SetFontObject(GameFontHighlightSmall)
	keyEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

	-- Type dropdown
	local typeLabel = addFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	typeLabel:SetPoint("TOPLEFT", 125, row1Y)
	typeLabel:SetText("Type:")

	local typeDropdown = CreateSimpleDropdown(addFrame, 125, row1Y - 16, 90, BIND_TYPES, "spell")

	-- Unit dropdown
	local unitLabel = addFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	unitLabel:SetPoint("TOPLEFT", 230, row1Y)
	unitLabel:SetText("Unit:")

	local unitDropdown = CreateSimpleDropdown(addFrame, 230, row1Y - 16, 110, BIND_UNITS, "none")

	-- Row 2: Spell/Action name + drop zone + Add button
	local row2Y = row1Y - 52

	local spellLabel = addFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellLabel:SetPoint("TOPLEFT", 10, row2Y)
	spellLabel:SetText("Spell / Action / Item / Macro Name:")

	local spellEditBox = CreateFrame("EditBox", nil, addFrame, "InputBoxTemplate")
	spellEditBox:SetSize(260, 22)
	spellEditBox:SetPoint("TOPLEFT", 10, row2Y - 16)
	spellEditBox:SetAutoFocus(false)
	spellEditBox:SetFontObject(GameFontHighlightSmall)
	spellEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	spellEditBox.typeDropdown = typeDropdown -- Link for auto-type-switch on drop

	-- Also accept drops directly on the editbox
	spellEditBox:SetScript("OnReceiveDrag", function(self) HandleSpellDropForBind(self) end)
	spellEditBox:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			local cursorType = GetCursorInfo()
			if cursorType == "spell" or cursorType == "item" or cursorType == "macro" then
				HandleSpellDropForBind(self)
			end
		end
	end)

	-- Spell drop zone
	local spellDrop = CreateFrame("Button", nil, addFrame, "BackdropTemplate")
	spellDrop:SetSize(140, 28)
	spellDrop:SetPoint("LEFT", spellEditBox, "RIGHT", 10, 0)
	spellDrop:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	spellDrop:SetBackdropColor(0.15, 0.2, 0.15, 0.6)
	spellDrop:SetBackdropBorderColor(0.3, 0.5, 0.3, 0.7)

	local spellDropText = spellDrop:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellDropText:SetPoint("CENTER")
	spellDropText:SetText("Drop spell here")
	spellDropText:SetTextColor(0.5, 0.9, 0.5)

	spellDrop:SetScript("OnClick", function() HandleSpellDropForBind(spellEditBox) end)
	spellDrop:SetScript("OnReceiveDrag", function() HandleSpellDropForBind(spellEditBox) end)
	spellDrop:SetScript("OnEnter", function(self)
		local cursorType = GetCursorInfo()
		if cursorType == "spell" or cursorType == "item" then
			self:SetBackdropColor(0.2, 0.4, 0.2, 0.8)
			self:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
		end
	end)
	spellDrop:SetScript("OnLeave", function(self)
		self:SetBackdropColor(0.15, 0.2, 0.15, 0.6)
		self:SetBackdropBorderColor(0.3, 0.5, 0.3, 0.7)
	end)

	-- When type changes to spell, hint the user
	typeDropdown.OnValueChanged = function(self, val)
		if val == "spell" then
			spellLabel:SetText("Spell / Action / Item / Macro Name: (or drop a spell)")
		else
			spellLabel:SetText("Spell / Action / Item / Macro Name:")
		end
	end

	-- Row 3: Status message + Add button
	local row3Y = row2Y - 46

	local statusText = addFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	statusText:SetPoint("TOPLEFT", 10, row3Y)
	statusText:SetWidth(320)
	statusText:SetJustifyH("LEFT")
	statusText:SetText("")

	local addBtn = CreateFrame("Button", nil, addFrame, "UIPanelButtonTemplate")
	addBtn:SetSize(110, 26)
	addBtn:SetPoint("TOPRIGHT", -12, row3Y + 2)
	addBtn:SetText("Add Binding")
	addBtn:SetScript("OnClick", function()
		local key = keyEditBox:GetText()
		local bType = typeDropdown:GetValue()
		local bUnit = unitDropdown:GetValue()
		local bName = spellEditBox:GetText()

		-- Validate
		if not key or key == "" then
			statusText:SetText("|cffff4040Error: Key is required|r")
			return
		end
		if not bName or bName == "" then
			statusText:SetText("|cffff4040Error: Name is required|r")
			return
		end
		if not KU_CheckBindingType(bType) then
			statusText:SetText("|cffff4040Error: Invalid type '" .. bType .. "'|r")
			return
		end
		if not KU_CheckBindingUnit(bUnit) then
			statusText:SetText("|cffff4040Error: Invalid unit '" .. bUnit .. "'|r")
			return
		end

		-- Check if key already assigned
		local binds = KU_GetBindings()
		if binds then
			for _, info in ipairs(binds) do
				if string.lower(info.key) == string.lower(key) then
					statusText:SetText("|cffff4040Error: Key '" .. key .. "' already assigned to '" .. info.name .. "'|r")
					return
				end
			end
		end

		KU_AddSpellBinding(bType, bName, bUnit, key)
		statusText:SetText("|cff40ff40Binding added: [" .. key .. "] " .. bType .. " '" .. bName .. "' -> " .. bUnit .. "|r")

		-- Clear form
		keyEditBox:SetText("")
		spellEditBox:SetText("")

		RefreshBindList()
	end)

	categoryPanels[3] = panel
	return panel
end

-------------------------------------------------------------------
-- Show / hide category panels
-------------------------------------------------------------------
function KU_Options_ShowCategory(index)
	for i, panel in pairs(categoryPanels) do
		if i == index then
			panel:Show()
		else
			panel:Hide()
		end
	end
	UpdateCategoryHighlight()

	if index == 2 then
		UpdateMountTabHighlight()
		RefreshMountList()
	elseif index == 3 then
		RefreshBindList()
	end
end

-------------------------------------------------------------------
-- Main open/close function
-------------------------------------------------------------------
function KU_OpenOptionsPanel()
	if not mainFrame then
		mainFrame = CreateMainFrame()
		local contentArea = CreateContentArea(mainFrame)
		CreateSidebar(mainFrame)
		CreateGeneralPanel(contentArea)
		CreateMountsPanel(contentArea)
		CreateBindsPanel(contentArea)
	end

	if mainFrame:IsShown() then
		mainFrame:Hide()
	else
		mainFrame:Show()
		KU_Options_ShowCategory(activeCategoryIndex)
	end
end
