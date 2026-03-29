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

	local categories = { "General", "Mounts" }
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
	bagOffsetBox, yPos = CreateInputRow(scrollChild, "Bags Y-Offset (blank to disable):", 16, yPos, 80, "AdjustBags", true)

	-- Bags scale
	local bagScaleBox
	bagScaleBox, yPos = CreateInputRow(scrollChild, "Bags Scale:", 16, yPos, 80, "ScaleBags", true)

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
	end

	if mainFrame:IsShown() then
		mainFrame:Hide()
	else
		mainFrame:Show()
		KU_Options_ShowCategory(activeCategoryIndex)
	end
end
