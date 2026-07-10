--[[
Kiki Utils by Kiki
		Version 14.2

		ChangeLog :
			- 1.0 : January, 14th 2005 : Module created. Added KU_SelfOrTarget and KU_Attack functions.
			- 1.1 : February, 2nd 2005 : Added Druid (works for warrior) ShapeShift hook, so it can enter Fight mode (if /ku attack is on) if it has a hostile target.
			- 1.2 : February, 3rd 2005 : Merge own MouseLook into KikiUtils (real MouseLook like DAoC one). Added slash commands (with help). Added localization. First public release.
							February, 4th 2005 : Added help message for unknown /ku command.
			- 1.3 : February, 5th 2005 : Fixed the weird bug of starting to run sometimes (was CAMERAORSELECTORMOVESTICKY issue). Fixed the game AutoFollow-AutoRun bug (see features).
			- 1.4 : February, 6th 2005 : Added a really simple clock (24h format).
							February, 12th 2005 : Config variables are now saved per Toon, per server.
							February, 15th 2005 : Fixed graphic bug after first load if tabs are locked.
			- 1.5 : February, 26th 2005 : Added the new all-in-one shift key for druids
			- 1.6 : March, 2nd 2005 : Added the new cool Tracking Check Warning.
							March, 15th 2005 : Now using UNKNOWNOBJECT to detect unknown entity
			- 1.7 : March, 26th 2005 : Added the new cool KU_TotemKiller function.
			- 1.8 : March, 26th 2005 : Fixed a bug in KU_TotemKiller, if no unit near you
			- 1.9 : March, 29th 2005 : Changed the KU_TotemKiller to loop all totems with the same name (if many) and not already dead. All-in-one druid morph key now unmounts you if you are riding your mount.
							March, 31th 2005 : Renamed 'All-in-one' keybind to 'Easy travel'. Added mount/unmount to 'Easy travel' keybind. Added new bindings for 'Easy morph'.
			- 2.0 : April, 1st 2005 : Now EasyTravel keybind cast Aqua form if swimming, can cast Travel if standing still but fighting.
			- 2.1 : April, 2nd 2005 : Now correctly shift to aqua if standing still in water (with EasyTravel key). In some zones, cannot detect if moving -> shift to Travel.
							April, 5th 2005 : Added new 'Bip' option.
			- 2.2 : April, 18th 2005 : Removed some useless array declaration (reduce memory usage). Reduced Moving detection CPU usage. Added new HideClassBar option (hidecb).
							April, 19th 2005 : HideClassBar is now correctly checked at startup. If quest description speed is the default game value, then it is increased.
			- 2.3 : June, 3rd 2005 : Saving 'MaxTargets' param as an int.
			- 2.4 : June, 15th 2005 : Added possibility to show quest levels in your QuestLog
							June, 16th 2005 : Now using custom tooltip to search bags for mount
			- 2.5 : June, 22th 2005 : Added minimap ping name display.
							June, 23th 2005 : Added possibility to move the clock (and lock its position). Fixed a possible Error in "/ku targets" command.
							June, 24th 2005 : Added German localization (thanks Edur).
			- 2.6 : July, 11th 2005 : QuestLevel is now properly set at startup.
			- 2.7 : July, 20th 2005 : Changed Mount buff detection (more accurate, not fooled by hunter aspects). Correctly resets MouseLook and shapeshift state after zonning.
							August, 17th 2005 : Blizz changed something in the PLAYER_AURAS_CHANGED that caused a bug with mounting. Fixed
							August, 22th 2005 : Added support for spell mounts (warlock & paladin).
							August, 23th 2005 : Fixed bug with warlock mount (french), and fixed warrior's mount issue.
			- 2.8 : September, 14th 2005 : Removed RegisterForSave call. Variables are now correctly saved in the new SavedVariables folder. Updated toc (#1700). Fixed vars init when disconnect/reconnect and /reloadui (thanks blizz for the undocumented new behaviour changes).
			- 2.9 : November, 21th 2005 : Added support for Shaman's Ghost Wolf (and fixed a bug in EasyMount Key
			- 3.0 : December, 27th 2005 : Fixed Ghost Wolf buf not always detected. Added Hunter's Cheetah to the EasyTravel key.
			- 3.1 : January, 4th 2006 : Fixed Tooltip parsing functions for 1.9. Updated TOC.
			- 3.2 : January, 31th 2006 : Fixed HideCB option that changes channeling frame position.
			- 3.3 : March, 28th 2006 : Added an option to Bip when you dodge an attack. Fixed localization errors.
							March, 29th 2006 : Fixed Tooltip parsing code, mouselook code, and updated toc... for 1.10.
			- 3.5 : April, 6th 2006 : Fixed mount detection error.
							May, 10th 2006 : Changed "dodge" option to "youdodge", and added "targetdodge" and "youparry" options
			- 3.6 : June, 27th 2006 : Updated TOC for 1.11.
							Slightly changed the "Force Attack mode" key binding. Now if you are a hunter, and out of melee range, it will autoshot instead of melee attacking.
							Fixed a missing translation (deDE and enUS).
			- 3.7 : July, 28th 2006 :
							Automatically equip druid Idols depending on the form (Human Idol can be set with "/ku idol" command)
							Human Idol not changed if druid is in combat (to prevent the casting delay to occur). It will be as soon as the druid is no longer in combat.
			- 3.8 : August, 30th 2006 :
							Updated TOC. New option : "/ku aqmount". Allow automatic usage of Ahn'Qiraj mount in the temple, if set with this option
			- 3.9 : September, 19th 2006 :
							Fixed SCT display
							Added FCT support
			- 4.0 : September, 29th 2006 : Removed "/ku mount" command. Added "/ku mounts" "/ku addmount" and "/ku delmount" to handle multiple mounts. When multiple mounts are specified, one is picked randomly.
			- 4.1 : October, 3rd 2006 : Fixed WeaponQuickSwap dependency. Fixed DefaultIdol swapping code. Fixed "swapidol" option always "on" issue. Some cleanup. Optimized some part of the code (buff parsing).
			- 5.0 : November, 22th 2006 : Updated for WoW 2.0
								Working stuff:
								 - Mouselook
								 - Easy travel keys: random mount, or travel forms (ghostwolf or druid form) depending on combat/movement state
								 - Force auto attack or auto shot/shot if out of melee range
								Disabled stuff:
								 - Totem killer
								 - Auto fight
								 - KU_SelfOrTarget() (included in the default UI)
								 - KU_Attack() (but replaced by keybind FORCEATTACK)
							 All other macros/features are working.
			- 5.0.1 : December, 6th 2006 : Official release, small fixes
			- 5.0.2 : December, 8th 2006 : Handle 2 keys per binding
			- 5.1 : December, 15th 2006 : Added support for mouseover spell ('/ku mos' '/ku addmos' '/ku delmos'). Added bindings for curing (disease, curse, poison, magic)
			- 5.2 : December, 15th 2006 : Removed '/ku mos' commands, but added '/ku binds' '/ku addbind' and '/ku delbind' commands. You can assign spell/macro/items/clicks/actions to any key, on any target.
			- 5.3 : January, 4th 2007 : Added '/ku hidegryphon" command. Added '/ku bfmm' command.
			- 5.4 : January, 12th 2007 : Fixed QuestLevel display
			- 5.5 : February, 13th 2007 : Added flying mounts support. Added a new binding to force a "normal-non flying" mount in outland to be selected
			- 5.6 : February, 19th 2007 : Added druid flight form support. Fixed unmorph for druids before lvl 30
			- 5.7 : Auguest, 31th 2007 : Improved mount macro for a better flying mount support. No longer printing TrackWarning if you are in a BG
			- 5.8 : October, 17th 2007 : Added "focus" as valid unit
			- 5.9 : November, 21th 2007 : Allowing druids to shift directly from any form to any other one
			- 6.0 : February, 22th 2008 : Druid forms changes: Added TreeOfLife and Moonkin keybindings. Changed the way bindings work: when in a form, this same form binding don't morph out to human (except for 'easy travel' binding). Now when in cat form, using cat binding will cast Prowl.
			- 7.0 : August, 24th 2008 : Ready for WotLK
			- 7.1 : September, 16th 2008 : Added "percent" config option
			- 7.2 : October, 7th 2008 : Using per realm SV now
			- 7.3 : November, 19th 2008 : Now detecting flyable sub-area because blizzard [flyable] returns true in northrend if you are lvl<77 or in wintergrasp
			- 7.4 : August, 4th 2009 : Updated QuestLog hook for patch 3.2
			- 7.5 : August, 5th 2009 : Autodetecting Cold Weather Flying spell
			- 7.6 : August, 14th 2009 : Added "bags" option. Allowing flying mounts in wintergrasp, when battle not engaged. Added warning message when incorrect aura detected
			- 7.7 : September, 23th 2009 : Fixed continent being incorrectly detected sometimes
			- 7.8 : October, 28th 2009 : Added a new "mount" type used in battlegrounds only (/ku addbgmount /ku delbgmount)
			- 8.0 : September, 16th 2010 : Updated for cataclysm. "track" option temporarily removed. Added Azeroth flight detection
			- 8.1 : October, 13th 2010 : Altered "clock" option, to show/hide blizzard minimap clock frame
			- 8.2 : October, 25th 2010 : Now savings bindings per talent tree. Detecting prot talent tree (DK/Pal/War) without proper threat spell (Blood Presence/Righteous Fury/Defensive Stance) in instance
			- 8.3:
			 - October, 28th 2010: Fixed lua error with bindings
			 - November, 24th 2010: Allowing flying mounts in dalaran. Fixed flying mounts in wintergrasp
			- 8.4:
			 - December, 4th 2010: Fixed lua error with bindings (really, this time)
			- 8.5:
			 - December, 27th 2010: Removed 'hidecb' feature
			- 8.6:
			 - July, 5th 2011: Added a new "mount" type used in instances only (/ku addinstmount /ku delinstmount)
			- 9.1:
			 - Feb, 6th 2014: Fixed for WoW 5.4
			- 9.2:
			 - Nov, 10th 2014: Fixed for WoW 6.0
			- 9.3:
			 - Jan, 4th 2015: Added SpeedOfLight to auto-travel key
			- 9.4:
			 - Jan, 19th 2015: Attempt to fix Taint issues
			- 9.5:
			 - Jan, 20th 2015: Added 'Leave Vehicle' to auto-travel key
			- 9.6:
			 - Feb, 4th 2015: Added Tiger's Lust to auto-travel key
			- 9.7:
			 - Jul, 23th 2016: Fixed for WoW 7.0
		- 9.8:
		 - Oct, 15th 2016: Many fixes
		- 9.9:
		 - Oct, 26th 2016: Fixed invalid key binding after spec change
		- 10.0:
		 - June, 24th 2017: Fixed mount commands, spell command
		- 11.0:
		 - September, 28th 2020: SL Support
		- 11.1:
		 - December, 29th 2020: Added purge to smart dispel keybind for shaman. Fixed Battlefield Minimap (/ku bfmm)
		- 11.2:
		 - April, 7th 2021:
			- Added an option to hide blizzard spell activation overlay
			- Added hunter tranqshot to dispel keybinding
			- Fixed hunter autoshot
			- Fixed monk mistweaving dispel keybinding
			- Added option to auto change souldbinds (/ku sb)
		- 12.0:
		 - Nov, 1st 2022:
			- Removed unused old code
		- 12.1:
		 - Nov, 27th 2022:
			- Added Evoker's Expunge
		- 14.3:
		 - July, 10th 2026:
			- Added automatic per-spec swapping of Omnium Folio runes (12.0.7). Set your
			  runes, "/ku omnium save", and they re-apply whenever you switch to that spec.
			  Commands: /ku omnium save|apply|clear|status

		Features :
			- Easy mounts : Auto detecting special mounts (AQ40 mostly) and using them when needed. You can specify any number of mounts, one will be used randomly.
			- Easy travel keybind (mostly for druids/shamans/hunters) : When in human form and moving -> shift into travel form (or cast your mount if standing still, or cast Aqua if swimming). In any form -> get back to human form (or unmount if on your mount).
			- Easy morph keybinds (druids) : When in human form shift to (bear/cat/aqua/travel). In any form shift back to human. You can use the same key as 'Quick travel' using ALT/CTRL/SHIFT key mods.
			- Can play a sound to bip you, when you are called in guild, party or raid channel.
			- MouseLook : Real DAoC mouse look mode. Key1 switch to and from MouseLook on each press. Hold Key2 to move the camera (when in MouseLook mode).
				In MouseLook mode, Button1 and Button2 are remapped to MoveForward and MoveBackward. MouseLook mode does NOT break follow mode.
			- [DISABLED] TotemKiller : Automatically selects the nearest totem matching your criteria and cast a spell on it : KU_TotemKiller(spellname,totem1[,totem2 ...]). It will try to target the first totem in the list, then second if first not found, and so on.
			- [REMOVED] Tabs hide : Prevents the chat tabs to be displayed, when you let the mouse over a chat window.
			- Class bar hide : Can hide the class specific bar (stealth, morph, stance).
			- [DISABLED] AutoFight : Automatically enters FightMode (calls the KU_Attack function) when you have shapeshifted (or changed battle stance) and if you have a hostile target.
			- Can print a warning if you don't have any tracking active (herb,ore, humanoid, ...)
			- Simple, small, 24h format clock
			- This AddOn fixes the AutoRun bug when you start following a target (following a target break the autorun but the game doesn't notice it, and you have to hit twice AutoRun button to re-run again).
				With this when you are following a target, you break auto-follow by hitting AutoRun key just once (and so start auto-running).
			- [DISABLED] KU_SelfOrTarget() function : Automatically cast a spell on yourself if you have anything but a friendly target.
			- [DISABLED] KU_Attack() function : Switch to Fight mode.
			- KU_IsAttacking() function : Returns 1 or 0, depending on your Fight mode (actually swinging weapons).
			- KU_IsAutorun() function : Returns 1 or 0, depending if you are in AutoRun mode or not.
			- KU_HasShapeChanged() function : Returns 1 if your shape (or stance) has changed since last call.
			- Can show quest levels in your QuestLog
			- Shows who clicked on the minimap

		Notes :
			- MouseLook does not break /follow
			- MouseLook does not have the bug of weird autorun if activated while pressing a mouse button

		Known bugs :
			- When switching to 'tablock on' while a chat tab is displayed, it will stay displayed forever (or until you disable tablock)

	Thanks to Chandora for command parsing code taken from his great Gatherer AddOn.
	Thanks to sarf and Alexander for his hints and help.
	Thanks to Telo for ideas taken from his clock' AddOn.
	Thanks to Moof for his help on finding functions ;)
	Thanks to erps for improvment ideas.
	Thanks to waz and all FC members for support :)
]]

--------------- Saved variables ---------------
--KU_Config = { HideChatTabs = false, HideClassBar = false, EnableClock = false, TrackWarning = false, QuestLevel = false, MountBag = -1, MountSlot = -1, MaxTargets = 20, LockClock = false };
KU_Config = {};
KU_CharConfig = {};

--------------- Shared variables ---------------
KU_FollowModeOn = 0;
KU_MouseLookOn = 0;
KU_MouseCamera = 0;
KU_MustToggleMouseLook = false;

--------------- Local enums ---------------
local EnumSoulBindCheck = { Nothing = 1, CheckOnly = 2, Apply = 3 }
local EnumSoulBindType = { Spec = "Spec", PvP = "PvP", Instance = "Instance", Raid = "Raid" }

--------------- Aliases ---------------
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

--------------- Local variables ---------------
local KU_VERSION = GetAddOnMetadata("KikiUtils", "Version");
local KU_IS_ATTACK = 0;
local KU_IS_MOUNTING = 0;
local KU_IS_MOVING = 0;
local KU_LAST_SHAPE = -1;
local KU_IS_AUTORUN = 0;
local KU_IS_COMBAT = 0;
local KU_CHECK_PALADIN_SEAL = 0;
local KU_IsWarlock = false;
local KU_IsDruid = false;
local KU_IsMage = false;
local KU_IsMonk = false;
local KU_IsHunter = false;
local KU_IsRogue = false;
local KU_IsShaman = false;
local KU_IsPaladin = false;
local KU_IsDK = false;
local KU_IsDH = false;
local KU_IsEvoker = false;
local KU_IsGhostWolf = 0;
local KU_CurrentTime = 0;
local KU_TimeLastSouldBindPathApplied = 0;
local KU_TimeToCheckForSoulbind = 0;
local KU_NeedToCheckForSoulbind = EnumSoulBindCheck.Nothing;
local KU_SoulBindTypeToApply = EnumSoulBindType.Spec;
local KU_SoulBindPathsToApply = {};
local KU_SoulBindIDToApply = 0;
-- Omnium Folio (aka "Runes of Power"), added in patch 12.0.7. It is a generic
-- C_Traits tree (like dragonriding), NOT a soulbind, so it uses a completely
-- different API. We auto-swap its choice runes per spec, like the soulbinds above.
local KU_OMNIUM_TREE_ID = 1186;
local KU_OmniumConfigID = nil; -- resolved lazily + cached for the session
local KU_NeedToCheckForOmnium = EnumSoulBindCheck.Nothing;
local KU_TimeToCheckForOmnium = 0;
local KU_MustSwapDefaultIdol = false;
local KU_GainAttacks = "";
local KU_CurrentZone = nil;
local KU_Clock_LastTime = 0;
local KU_TrackCheck_LastTime = 0;
local KU_VarsLoaded = false;
local KU_NeedInitToonSpecific = true;
local KU_PlayerOfRealm = nil;
local KU_LastPosition = nil;
local KU_MustCheckMount = 1;
local KU_MMPing_LABEL_DECAY_TIME = 5;
local KU_MMPing_StartTime = 0;
local KU_OldBindingB1 = nil;
local KU_OldBindingB2 = nil;
local KU_OldBindingCB1 = nil;
local KU_OldBindingCB2 = nil;
local KU_OldBindingAB1 = nil;
local KU_OldBindingAB2 = nil;
local KU_OldBindingSB1 = nil;
local KU_OldBindingSB2 = nil;
local KU_MustCheckGhostWolfState = true;
local KU_MustCheckCheetahState = true;
local KU_HasUseMount = false;
local pendingSetupMacro = false;
local pendingSetupForceAttackMacro = false;
local pendingSetupBindings = false;
local KU_SubZoneRegistered = false;
local KU_ActiveTree = nil;
local KU_MustRestoreMusic = false;
local KU_FROSTWOLF_WAR_WOLF_SPELLID = 164222;
local KU_SPEED_OF_LIGHT_SPELLID = 85499;
local KU_DIVINE_STEED_SPELLID = 190784;
local KU_NextRaidTargetPosition = 1;
local KU_RaidTargetGUIDs = {};
local KU_RaidTargetCycleOrderIndex = { 7, 2, 1, 4, 3, 5 }

local strfind = string.find;
local strupper = string.upper;
local strlower = string.lower;

--------------- Internal functions ---------------
function KU_ChatDebug(str)
	if (DEFAULT_CHAT_FRAME)
	then
		DEFAULT_CHAT_FRAME:AddMessage("KikiUtils Debug : " .. str, 1.0, 0, 0);
	end
end

function kud(str)
	KU_ChatDebug(tostring(str));
end

function kud2(...)
	for i = 1, select("#", ...)
	do
		KU_ChatDebug(tostring(select(i, ...)));
	end
end

local function KU_ChatPrint(str, r, g, b)
	if (DEFAULT_CHAT_FRAME)
	then
		DEFAULT_CHAT_FRAME:AddMessage("KikiUtils : " .. str, r or 1.0, g or 0.7, b or 0.15);
	end
end

local function GetSpellInfo(spellID)
	local t = C_Spell.GetSpellInfo(spellID)
	if t ~= nil
	then
		return t.name
	end
	return nil
end

local function GetSpellLink(spellID)
	if C_Spell and C_Spell.GetSpellLink then
		return C_Spell.GetSpellLink(spellID)
	end
	return nil
end

--------------- Config functions ---------------

local function KU_SetToonConfig(type, value)
	KU_CharConfig[type] = value;
	--[[if (not KU_Config) then return; end
	if (not KU_Config.users) then KU_Config.users = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm]) then KU_Config.users[KU_PlayerOfRealm] = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm].options) then KU_Config.users[KU_PlayerOfRealm].options = {}; end
	
	KU_Config.users[KU_PlayerOfRealm].options[type] = value;]]
end

local function KU_GetToonConfig(type)
	local value = KU_CharConfig[type];
	if (value == nil)
	then
		return false;
	end
	return value;
	--[[if (not KU_Config) then return false; end
	if (not KU_PlayerOfRealm) then return false; end
	if (not KU_Config.users) then KU_Config.users = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm]) then KU_Config.users[KU_PlayerOfRealm] = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm].options) then KU_Config.users[KU_PlayerOfRealm].options = {}; end
	value = KU_Config.users[KU_PlayerOfRealm].options[type];
	if (not value) then return false; end
	return value;]]
end

local function KU_GetToonConfigString(type)
	local value = KU_CharConfig[type];
	if (value == nil)
	then
		return "";
	end
	return value;
	--[[if (not KU_Config) then return ""; end
	if (not KU_PlayerOfRealm) then return ""; end
	if (not KU_Config.users) then KU_Config.users = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm]) then KU_Config.users[KU_PlayerOfRealm] = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm].options) then KU_Config.users[KU_PlayerOfRealm].options = {}; end
	value = KU_Config.users[KU_PlayerOfRealm].options[type];
	if (not value) then return ""; end
	return value;]]
end

local function KU_GetToonConfigInt(type, default)
	local value = KU_CharConfig[type];
	if (value == nil)
	then
		return default;
	end
	return value;
	--[[if (not KU_Config) then return default; end
	if (not KU_PlayerOfRealm) then return default; end
	if (not KU_Config.users) then KU_Config.users = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm]) then KU_Config.users[KU_PlayerOfRealm] = {}; end
	if (not KU_Config.users[KU_PlayerOfRealm].options) then KU_Config.users[KU_PlayerOfRealm].options = {}; end
	value = KU_Config.users[KU_PlayerOfRealm].options[type];
	if (not value) then return default; end
	return value;]]
end


--------------- Hooked functions ---------------

local function KU_GetScreenHeight(firstCol)
	if (firstCol)
	then
		return GetScreenHeight() - MinimapCluster:GetHeight() - 20;
	else
		return GetScreenHeight() - 20;
	end
end

function KU_updateContainerFrameAnchors()
	local CONTAINER_OFFSET_Y = KU_GetToonConfigInt("AdjustBags", 70);
	local containerScale = KU_GetToonConfigInt("ScaleBags", 1.0);

	local screenHeight = KU_GetScreenHeight(true) / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	local xOffset = CONTAINER_OFFSET_X / containerScale;
	local yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	local freeScreenHeight = screenHeight - yOffset;
	local previousBag;
	local firstBagInMostRecentColumn;
	for index, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
		frame:SetScale(containerScale);
		if index == 1 then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset);
			firstBagInMostRecentColumn = frame;
		elseif (freeScreenHeight < frame:GetHeight()) or previousBag:IsCombinedBagContainer() then
			-- Start a new column
			screenHeight = KU_GetScreenHeight(false) / containerScale
			freeScreenHeight = screenHeight - yOffset;
			frame:SetPoint("BOTTOMRIGHT", firstBagInMostRecentColumn, "BOTTOMLEFT", -11, 0);
			firstBagInMostRecentColumn = frame;
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", previousBag, "TOPRIGHT", 0, CONTAINER_SPACING);
		end

		previousBag = frame;
		freeScreenHeight = freeScreenHeight - frame:GetHeight();
	end
end

--------------- Init functions ---------------

local function KU_CheckDisableMusic()
	if (KU_GetToonConfig("AutoDisableMusic") and KU_MustRestoreMusic == false and GetCVar("Sound_EnableMusic") == "1")
	then
		if (UnitExists("target") and UnitLevel("target") == -1) -- Boss
		then
			KU_MustRestoreMusic = true;
			Sound_ToggleMusic();
		end
	end
end

local function KU_CheckRestoreMusic()
	if (KU_MustRestoreMusic)
	then
		if (GetCVar("Sound_EnableMusic") ~= "1")
		then
			Sound_ToggleMusic();
		end
		KU_MustRestoreMusic = false;
	end
end

local function KU_CheckTalentTree(fromTalentChange)
	local tree = GetSpecialization();
	local firstTime = false
	if (KU_ActiveTree == nil)  -- First time
	then
		if (not tree or tree == 0) -- To prevent Bliz bug (PLAYER_TALENT_UPDATE is triggered when you zone)
		then
			return;
		end
		firstTime = true
	end

	if (KU_ActiveTree ~= tree) -- First time, or spec changed
	then
		-- Get player's spec
		KU_ActiveTree = tree;
		-- Setup new bindings
		KU_BindingsSetKeys();
		-- Check Soulbind tree in a second
		if firstTime or not fromTalentChange
		then
			KU_NeedToCheckForSoulbind = EnumSoulBindCheck.CheckOnly
			KU_SoulBindTypeToApply = EnumSoulBindType.Spec
			KU_TimeToCheckForSoulbind = KU_CurrentTime + 6.0
			-- On login/zone we only warn (never silently restage traits at load)
			KU_NeedToCheckForOmnium = EnumSoulBindCheck.CheckOnly
			KU_TimeToCheckForOmnium = KU_CurrentTime + 6.0
		else
			KU_NeedToCheckForSoulbind = EnumSoulBindCheck.Apply
			KU_SoulBindTypeToApply = EnumSoulBindType.Spec
			KU_TimeToCheckForSoulbind = KU_CurrentTime + 0.5
			-- Real spec change -> actually re-apply the saved Omnium runes
			KU_NeedToCheckForOmnium = EnumSoulBindCheck.Apply
			KU_TimeToCheckForOmnium = KU_CurrentTime + 0.5
		end
	end
end

local function KU_CheckAndInitDefault(name, value)
	if (KU_CharConfig[name] == nil)
	then
		KU_SetToonConfig(name, value);
	end
end

local function KU_InitDefaults()
	KU_CheckAndInitDefault("DebugMode", false);
	KU_CheckAndInitDefault("HideClassBar", false);
	KU_CheckAndInitDefault("EnableClock", true);
	KU_CheckAndInitDefault("LockClock", false);
	KU_CheckAndInitDefault("TrackWarning", false);
	KU_CheckAndInitDefault("ShowPercent", false);
	KU_CheckAndInitDefault("QuestLevel", true);
	KU_CheckAndInitDefault("SwapIdol", false);
	KU_CheckAndInitDefault("AttackGain", false);
	KU_CheckAndInitDefault("Dodge", false);
	KU_CheckAndInitDefault("TargetDodge", false);
	KU_CheckAndInitDefault("Parry", false);
end

local function KU_ImportGlobalConfig()
	if (KU_CharConfig == nil or KU_CharConfig.TrackWarning == nil) -- Never imported
	then
		if (KU_Config and KU_Config.users and KU_Config.users[KU_PlayerOfRealm] and KU_Config.users[KU_PlayerOfRealm].options)
		then
			for name, value in pairs(KU_Config.users[KU_PlayerOfRealm].options)
			do
				KU_CharConfig[name] = value;
			end
			KU_InitDefaults();
		else
			KU_InitDefaults();
		end
	end
end

local function KU_GetSelectedSoulBindBranches(soulbindID)
	local tree = KU_BuildSoulBindTree(soulbindID)

	local selectedNodes = {}
	local singleChoice = true

	for _, nodes in ipairs(tree)
	do
		if #nodes > 1
		then
			if singleChoice == true
			then
				for _, node in ipairs(nodes)
				do
					if node.state == Enum.SoulbindNodeState.Selected
					then
						tinsert(selectedNodes, node.ID)
					end
				end
				singleChoice = false
			end
		else
			singleChoice = true
		end
	end

	return selectedNodes
end

local function KU_ApplySouldBindBranches(soulbindID, selectedNodes, checkOnly)
	local currentNodes = KU_GetSelectedSoulBindBranches(soulbindID)
	KU_SoulBindIDToApply = soulbindID
	KU_SoulBindPathsToApply = {}
	for i, nodeID in ipairs(selectedNodes)
	do
		if currentNodes[i] ~= nodeID
		then
			tinsert(KU_SoulBindPathsToApply, nodeID)
		end
	end

	if #KU_SoulBindPathsToApply == 0
	then
		if not checkOnly
		then
			KU_ChatPrint("Soulbind Path already set", 0.2, 1.0, 0.2)
		end
	else
		if checkOnly
		then
			KU_Announce("Soulbind Path is not the correct one for type " .. KU_SoulBindTypeToApply, 1.0, 0.2, 0.2)
			KU_SoulBindPathsToApply = {}
			return
		end

		if C_Soulbinds.CanSwitchActiveSoulbindTreeBranch()
		then
			local sbName = C_Soulbinds.GetSoulbindData(soulbindID).name
			KU_ChatPrint("Changing Soulbind Path for " .. sbName .. ": " .. tostring(#KU_SoulBindPathsToApply) .. " to change")
		else
			KU_SoulBindPathsToApply = {}
			KU_Announce(
				"WARNING: Cannot change Soulbind Path, " .. tostring(#KU_SoulBindPathsToApply) .. " should be changed!",
				1.0, 0.1, 0.1)
		end
	end
end

local function KU_CheckApplySoulBind()
	if KU_NeedToCheckForSoulbind ~= EnumSoulBindCheck.Nothing and KU_CurrentTime >= KU_TimeToCheckForSoulbind
	then
		local action = KU_NeedToCheckForSoulbind
		KU_NeedToCheckForSoulbind = EnumSoulBindCheck.Nothing

		local sb = KU_GetSoulBinds(C_Covenants.GetActiveCovenantID())
		local sbType = sb[KU_SoulBindTypeToApply]
		if sbType ~= nil
		then
			local currentID = C_Soulbinds.GetActiveSoulbindID()
			if sbType.ID ~= currentID
			then
				local sbName = C_Soulbinds.GetSoulbindData(sbType.ID).name
				if action == EnumSoulBindCheck.CheckOnly
				then
					KU_Announce("Current Soulbind is " .. C_Soulbinds.GetSoulbindData(currentID).name .. " instead of " .. sbName,
						1.0, 0.2, 0.2)
					return
				end
				local canActivate, reason = C_Soulbinds.CanActivateSoulbind(sbType.ID)
				if canActivate
				then
					KU_ChatPrint("Activating Soulbind " .. sbName)
					C_Soulbinds.ActivateSoulbind(sbType.ID)
				else
					KU_Announce("WARNING: Cannot change Soulbind to " .. sbName .. ": " .. reason, 1.0, 0.1, 0.1)
					return
				end
			end
			-- Add a small delay
			KU_TimeLastSouldBindPathApplied = KU_CurrentTime
			KU_ApplySouldBindBranches(sbType.ID, sbType.branches, action == EnumSoulBindCheck.CheckOnly)
		end
	end
end

local function KU_CheckApplySoulBindBranches()
	if KU_CurrentTime >= (KU_TimeLastSouldBindPathApplied + 1.5)
	then
		if #KU_SoulBindPathsToApply > 0
		then
			local currentID = C_Soulbinds.GetActiveSoulbindID()
			if currentID ~= KU_SoulBindIDToApply
			then
				KU_SoulBindPathsToApply = {}
				KU_Announce("WARNING: Cannot change Soulbind Path, wrong Soulbind active!", 1.0, 0.2, 0.2)
				return
			end

			local sbName = C_Soulbinds.GetSoulbindData(currentID).name
			local nodeID = tremove(KU_SoulBindPathsToApply)
			local node = C_Soulbinds.GetNode(nodeID)
			local spellID = node.spellID
			if spellID == 0
			then
				spellID = C_Soulbinds.GetConduitSpellID(node.conduitID, node.conduitRank)
			end
			KU_ChatPrint(" - Changing branch to " .. tostring(GetSpellLink(spellID)) .. " for " .. sbName)
			C_Soulbinds.SelectNode(nodeID)
			KU_TimeLastSouldBindPathApplied = KU_CurrentTime
			if #KU_SoulBindPathsToApply == 0
			then
				KU_ChatPrint("Soulbind Path applied", 0.2, 1.0, 0.2)
			end
		end
	end
end

--------------- Omnium Folio (Runes of Power) ---------------
-- The Omnium Folio is a generic C_Traits system (same machinery as dragonriding),
-- so we read/write it through C_Traits, NOT C_Soulbinds. We only touch "choice"
-- nodes (the runes where you pick 1-of-N); purchased/unlocked runes are left alone.

-- Resolve the folio's traits config ID WITHOUT needing its UI open. It is a
-- "generic" trait system; rather than hardcode a systemID that could change, we
-- scan the trait systems and keep the one whose config owns the Omnium tree.
local function KU_GetOmniumConfigID()
	if KU_OmniumConfigID ~= nil
	then
		return KU_OmniumConfigID
	end
	if not (C_Traits and C_Traits.GetConfigIDBySystemID and C_Traits.GetConfigInfo)
	then
		return nil
	end
	for systemID = 1, 40
	do
		local configID
		pcall(function() configID = C_Traits.GetConfigIDBySystemID(systemID) end)
		if configID and configID ~= 0
		then
			local info
			pcall(function() info = C_Traits.GetConfigInfo(configID) end)
			if info and type(info.treeIDs) == "table"
			then
				for _, tid in ipairs(info.treeIDs)
				do
					if tid == KU_OMNIUM_TREE_ID
					then
						KU_OmniumConfigID = configID
						return configID
					end
				end
			end
		end
	end
	-- Fallback: read it straight off the live folio frame. Try to load (not show)
	-- the landing page addon first so this can still work if the systemID scan
	-- came up empty and the player hasn't opened the folio yet this session.
	if C_AddOns and C_AddOns.LoadAddOn
	then
		pcall(C_AddOns.LoadAddOn, "Blizzard_ExpansionLandingPage")
	end
	local elp = _G.ExpansionLandingPage
	local ov = elp and elp.Overlay
	local mlo = ov and ov.MidnightLandingOverlay
	local rof = mlo and mlo.RunesOfPowerFrame
	if rof and rof.GetConfigID
	then
		local ok, id = pcall(rof.GetConfigID, rof)
		if ok and id and id > 0
		then
			KU_OmniumConfigID = id
			return id
		end
	end
	return nil
end

-- Best-effort human readable name for a folio rune entry (its spell name).
local function KU_OmniumEntryName(configID, entryID)
	local name
	pcall(function()
		local e = C_Traits.GetEntryInfo(configID, entryID)
		local def = e and e.definitionID and C_Traits.GetDefinitionInfo(e.definitionID)
		local spellID = def and (def.overriddenSpellID or def.spellID)
		if spellID
		then
			name = GetSpellInfo(spellID)
		end
	end)
	return name or ("rune #" .. tostring(entryID))
end

-- Snapshot the currently selected folio choice runes as { [nodeID] = entryID }.
-- Returns {} when there is nothing to choose, or nil when the folio can't be read.
local function KU_GetOmniumSelection()
	local configID = KU_GetOmniumConfigID()
	if not configID
	then
		return nil
	end
	local selection = {}
	local ok = pcall(function()
		local nodes = C_Traits.GetTreeNodes(KU_OMNIUM_TREE_ID)
		if type(nodes) ~= "table"
		then
			return
		end
		for _, nodeID in ipairs(nodes)
		do
			local n = C_Traits.GetNodeInfo(configID, nodeID)
			if n
			then
				local isChoice = (n.entryIDs and #n.entryIDs > 1)
					or (Enum and Enum.TraitNodeType and n.type == Enum.TraitNodeType.Selection)
				if isChoice and n.activeEntry and n.activeEntry.entryID
				then
					selection[nodeID] = n.activeEntry.entryID
				end
			end
		end
	end)
	if not ok
	then
		return nil
	end
	return selection
end

-- Per-toon Omnium selections, keyed by spec (KU_ActiveTree) exactly like the soulbinds.
local function KU_GetOmniumStore()
	local store = KU_GetToonConfig("Omnium")
	if type(store) ~= "table"
	then
		store = {}
		KU_SetToonConfig("Omnium", store)
	end
	return store
end

-- State-machine step (called every frame, mirrors KU_CheckApplySoulBind): when a
-- spec change scheduled a check/apply, stage the saved runes and commit them.
local function KU_CheckApplyOmnium()
	if KU_NeedToCheckForOmnium == EnumSoulBindCheck.Nothing or KU_CurrentTime < KU_TimeToCheckForOmnium
	then
		return
	end
	-- Never stage/commit traits during combat; retry shortly after.
	if InCombatLockdown()
	then
		KU_TimeToCheckForOmnium = KU_CurrentTime + 1.0
		return
	end

	local action = KU_NeedToCheckForOmnium
	KU_NeedToCheckForOmnium = EnumSoulBindCheck.Nothing

	if KU_ActiveTree == nil
	then
		return
	end
	local store = KU_GetOmniumStore()
	local wanted = store[KU_ActiveTree]
	if type(wanted) ~= "table" or next(wanted) == nil
	then
		return -- nothing saved for this spec -> feature is a no-op here
	end

	local configID = KU_GetOmniumConfigID()
	if not configID
	then
		return -- folio not resolvable yet; stay silent in the automatic path
	end

	-- Which saved choice nodes currently differ from what we want?
	local changes, count = {}, 0
	local okRead = pcall(function()
		for nodeID, entryID in pairs(wanted)
		do
			local n = C_Traits.GetNodeInfo(configID, nodeID)
			local cur = n and n.activeEntry and n.activeEntry.entryID
			if cur ~= entryID
			then
				changes[nodeID] = entryID
				count = count + 1
			end
		end
	end)
	if not okRead
	then
		return
	end

	if count == 0
	then
		return -- already correct, nothing to do (stay quiet)
	end

	if action == EnumSoulBindCheck.CheckOnly
	then
		KU_Announce("Omnium runes differ from the ones saved for this spec", 1.0, 0.4, 0.2)
		return
	end

	-- Apply: stage each selection, then commit the config in one go.
	local staged = 0
	for nodeID, entryID in pairs(changes)
	do
		local ok = false
		pcall(function() ok = C_Traits.SetSelection(configID, nodeID, entryID) end)
		if ok
		then
			staged = staged + 1
		end
	end
	if staged == 0
	then
		KU_OmniumConfigID = nil -- cached config may be stale; force a re-resolve next time
		KU_Announce("Omnium: WARNING could not stage rune changes", 1.0, 0.1, 0.1)
		return
	end

	local committed = false
	pcall(function() committed = C_Traits.CommitConfig(configID) end)
	if committed
	then
		KU_ChatPrint("Omnium runes updated for this spec (" .. tostring(staged) .. " changed)", 0.2, 1.0, 0.2)
	else
		pcall(function() if C_Traits.RollbackConfig then C_Traits.RollbackConfig(configID) end end)
		KU_Announce("Omnium: WARNING failed to apply rune changes (in combat or restricted area?)", 1.0, 0.1, 0.1)
	end
end

-- /ku omnium status : list what is saved for the current spec + live state.
local function KU_OmniumStatus(spec, store)
	local configID = KU_GetOmniumConfigID()
	KU_ChatPrint("Omnium runes for spec #" .. tostring(spec) .. ":")
	if not configID
	then
		KU_ChatPrint("  Folio config not found (open the Omnium Folio once, then retry)", 1.0, 0.6, 0.15)
	end
	local saved = store[spec]
	if type(saved) ~= "table" or next(saved) == nil
	then
		KU_ChatPrint("  Nothing saved yet - use /ku omnium save")
		return
	end
	for nodeID, entryID in pairs(saved)
	do
		local name = configID and KU_OmniumEntryName(configID, entryID) or ("rune #" .. tostring(entryID))
		local marker = ""
		if configID
		then
			local cur
			pcall(function()
				local n = C_Traits.GetNodeInfo(configID, nodeID)
				cur = n and n.activeEntry and n.activeEntry.entryID
			end)
			marker = (cur == entryID) and " |cff20ff20(active)|r" or " |cffff8000(not active)|r"
		end
		KU_ChatPrint("  - " .. name .. marker)
	end
end

-- /ku omnium <save|apply|clear|status>
local function KU_OmniumCommand(param)
	param = param and strlower(param) or ""
	local spec = KU_ActiveTree or GetSpecialization()
	if spec == nil or spec == 0
	then
		KU_ChatPrint("Omnium: no active specialization detected yet", 1.0, 0.2, 0.2)
		return
	end
	local store = KU_GetOmniumStore()

	if param == "save"
	then
		if not KU_GetOmniumConfigID()
		then
			KU_ChatPrint("Omnium: folio config not found (open the Omnium Folio once, then retry)", 1.0, 0.2, 0.2)
			return
		end
		local sel = KU_GetOmniumSelection()
		if not sel or next(sel) == nil
		then
			KU_ChatPrint("Omnium: no selectable rune found to save yet", 1.0, 0.6, 0.15)
			return
		end
		store[spec] = sel
		local n = 0
		for _ in pairs(sel) do n = n + 1 end
		KU_ChatPrint("Omnium runes saved for this spec (" .. tostring(n) .. " choice" .. (n > 1 and "s" or "") .. ")", 0.2, 1.0, 0.2)
	elseif param == "apply"
	then
		if type(store[spec]) ~= "table" or next(store[spec]) == nil
		then
			KU_ChatPrint("Omnium: nothing saved for this spec (use /ku omnium save first)", 1.0, 0.2, 0.2)
			return
		end
		KU_NeedToCheckForOmnium = EnumSoulBindCheck.Apply
		KU_TimeToCheckForOmnium = KU_CurrentTime
		KU_ChatPrint("Omnium: applying saved runes for this spec...")
	elseif param == "clear"
	then
		store[spec] = nil
		KU_ChatPrint("Omnium: cleared saved runes for this spec", 0.2, 1.0, 0.2)
	elseif param == "" or param == "status"
	then
		KU_OmniumStatus(spec, store)
	else
		KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "omnium " .. param)
	end
end

-- Track self-sent chat messages to avoid Kstring/secret string comparison in 12.0.5
local KU_LastSentChatMsg = nil
hooksecurefunc("SendChatMessage", function(msg, chatType)
	if chatType == "GUILD" or chatType == "PARTY" or chatType == "RAID" then
		KU_LastSentChatMsg = msg
	end
end)

local function KU_MustBip(str)
	local comp = KU_GetToonConfigString("BipStr");
	if ((comp ~= "") and strfind(string.lower(str), string.lower(comp)))
	then
		return true;
	else
		return false;
	end
end

local function KU_ChatBipFilter(self, event, msg, ...)
	if KU_LastSentChatMsg and KU_LastSentChatMsg == msg then
		KU_LastSentChatMsg = nil
		return false
	end
	KU_LastSentChatMsg = nil
	if KU_MustBip(msg) then
		PlaySoundFile("Interface\\AddOns\\KikiUtils\\coin.wav")
	end
	return false
end

function KU_GetInventoryName(bag, slot)
	local linktext = nil;

	if (bag == -1)
	then
		linktext = GetInventoryItemLink("player", slot);
	else
		linktext = GetContainerItemLink(bag, slot);
	end

	if (linktext)
	then
		local _, _, name = strfind(linktext, "^.*%[(.*)%].*$");
		return name;
	else
		return "";
	end
end

function KU_SearchMountSpell(s_name)
	for i = 1, 8 do
		name, texture, offset, numSpells = GetSpellTabInfo(i);
		for j = 1, offset + numSpells, 1 do
			spellname, spellrank = GetSpellName(j, 1);
			if (strfind(spellname, s_name) ~= nil)
			then
				--[[if(spellrank)
				then
					return spellname.."("..spellrank..")";
				else
					return spellname;
				end]]
				return spellname;
			end
		end
	end
	return nil;
end

local function KU_SearchMountInBags(partial_mount_name)
	local b = -1;
	local s = -1;
	local n = nil;
	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag) do
			local item_name = KU_GetInventoryName(bag, slot);
			if (strfind(item_name, partial_mount_name) ~= nil)
			then
				if (b == -1)
				then
					b = bag;
					s = slot;
					n = item_name;
				else
					KU_ChatPrint("Found multiple items with name '" ..
						partial_mount_name .. "' in your bags, please give a more precise name");
					return -1, -1, nil;
				end
			end
		end
	end
	return b, s, n;
end

local function KU_SearchIdolInBags(partial_idol_name)
	local b = -1;
	local s = -1;
	local n = nil;

	-- Search equipped idol
	local equipped = KU_GetInventoryName(-1, 18);
	if (strfind(equipped, partial_idol_name))
	then
		return -1, 18, equipped;
	end
	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag) do
			local item_name = KU_GetInventoryName(bag, slot);
			if (strfind(item_name, partial_idol_name) ~= nil)
			then
				if (b == -1)
				then
					b = bag;
					s = slot;
					n = item_name;
				else
					KU_ChatPrint("Found multiple items with name '" ..
						partial_idol_name .. "' in your bags, please give a more precise name");
					return -1, -1, nil;
				end
			end
		end
	end
	return b, s, n;
end

local function KU_SetNewDebugMode(printmsg)
	if (KU_GetToonConfig("DebugMode"))
	then
		if (printmsg)
		then
			KU_ChatPrint("Debug mode: Enabled");
		end
		KikiUtilsFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN");
		KikiUtilsFrame:RegisterEvent("MACRO_ACTION_FORBIDDEN");
		KikiUtilsFrame:RegisterEvent("ADDON_ACTION_BLOCKED");
		KikiUtilsFrame:RegisterEvent("MACRO_ACTION_BLOCKED");
	else
		if (printmsg)
		then
			KU_ChatPrint("Debug mode: Disabled");
		end
		KikiUtilsFrame:UnregisterEvent("ADDON_ACTION_FORBIDDEN");
		KikiUtilsFrame:UnregisterEvent("MACRO_ACTION_FORBIDDEN");
		KikiUtilsFrame:UnregisterEvent("ADDON_ACTION_BLOCKED");
		KikiUtilsFrame:UnregisterEvent("MACRO_ACTION_BLOCKED");
	end
end

local function KU_SetNewSpellActivationOverlay(printmsg)
	if (KU_GetToonConfig("HideSpellActivationOverlay"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_SPELL_ACT_OVRL_HIDDEN);
		end
		SpellActivationOverlayFrame:Hide();
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_SPELL_ACT_OVRL_SHOWN);
		end
		SpellActivationOverlayFrame:Show();
	end
end

local function KU_SetNewClassBar(printmsg)
	if (true) then return end -- Feature disabled
	if (KU_GetToonConfig("HideClassBar"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CLASS_BAR_HIDDEN);
		end
		ShapeshiftBarFrame:Hide();
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CLASS_BAR_SHOWN);
		end
		ShapeshiftBar_Update(); -- Call it to refresh
	end
end

local function KU_LoadRegExpr(str)
	local expr = string.gsub(str, "%.", "%%.");
	expr = string.gsub(expr, "%%d", "(%%d+)");
	expr = string.gsub(expr, "%%s", "(%.+)");
	return expr;
end

local function KU_SetClock(printmsg)
	if (KU_GetToonConfig("EnableClock"))
	then
		--KU_ClockFrame:Show();
		TimeManagerClockButton:Show();
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_CLOCK_ON);
		end
	else
		--KU_ClockFrame:Hide();
		TimeManagerClockButton:Hide();
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_CLOCK_OFF);
		end
	end
end

local function KU_SetClockLock(printmsg)
	if (KU_GetToonConfig("LockClock"))
	then
		--KU_ClockFrame:EnableMouse("false");
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_CLOCK_LOCK_ON);
		end
	else
		--KU_ClockFrame:EnableMouse("true");
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_CLOCK_LOCK_OFF);
		end
	end
end

local function KU_SetNewTrack(printmsg)
	if (KU_GetToonConfig("TrackWarning"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_TRACK_ON);
		end
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_TRACK_OFF);
		end
	end
end

local function KU_SetShowPercent(printmsg)
	if (KU_GetToonConfig("ShowPercent"))
	then
		KU_ChatPrint("Showing percent value");
	else
		KU_ChatPrint("Hidding percent value");
	end
	TextStatusBar_UpdateTextString(TargetFrameHealthBar);
	TextStatusBar_UpdateTextString(TargetFrameManaBar);
end

local function KU_SetNewBags(printmsg)
	local v1 = KU_GetToonConfigInt("AdjustBags", nil);
	local v2 = KU_GetToonConfigInt("ScaleBags", nil);
	if (v1 ~= nil or v2 ~= nil)
	then
		-- Check for conversion
		if (tonumber(v1) == nil)
		then
			KU_SetToonConfig("AdjustBags", 70); -- Set to default value: 70
		end
		if (tonumber(v2) == nil)
		then
			KU_SetToonConfig("ScaleBags", 1.0); -- Set to default value: 1.0
		end
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_BAGS_ON);
		end
		hooksecurefunc("UpdateContainerFrameAnchors", KU_updateContainerFrameAnchors);
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_BAGS_OFF);
		end
	end
end

local function KU_LossOfControlFrame_OnLoad(frame)
	local lossPos = KU_GetToonConfigString("LossOfControl");
	local _, _, x, y = strfind(lossPos, "^(-*[0-9]+),(-*[0-9]+)$");
	LossOfControlFrame:ClearAllPoints()
	LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", tonumber(x), tonumber(y))
end

local function KU_SetNewLossOfControl(printmsg)
	local lossPos = KU_GetToonConfigString("LossOfControl");
	if (lossPos ~= "")
	then
		-- Parse values
		local _, _, x, y = strfind(lossPos, "^(-*[0-9]+),(-*[0-9]+)$");
		if (printmsg)
		then
			KU_ChatPrint("Auto-setting Loss Of Control position to " .. x .. "," .. y);
		end
		if LossOfControlFrame
		then
			LossOfControlFrame:ClearAllPoints()
			LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", tonumber(x), tonumber(y))
		end
		--hooksecurefunc("LossOfControlFrame_OnLoad",KU_LossOfControlFrame_OnLoad);
	else
		if (printmsg)
		then
			KU_ChatPrint("No longer setting Loss Of Control Position");
		end
		LossOfControlFrame:ClearAllPoints()
		LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
	end
end

local function KU_SetNewSwapIdol(printmsg)
	if (KU_GetToonConfig("SwapIdol"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_SWAP_IDOL_ON);
		end
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_SWAP_IDOL_OFF);
		end
	end
end

local function KU_SetNewAttackGain(printmsg)
	if (KU_GetToonConfig("AttackGain"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_ATTACK_GAIN_ON);
		end
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_ATTACK_GAIN_OFF);
		end
	end
end

local function KU_SetNewYouDodge(printmsg)
	if (KU_GetToonConfig("Dodge"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_YOU_DODGE_ON);
		end
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_YOU_DODGE_OFF);
		end
	end
end

local function KU_SetNewTargetDodge(printmsg)
	if (KU_GetToonConfig("TargetDodge"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_TARGET_DODGE_ON);
		end
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_TARGET_DODGE_OFF);
		end
	end
end

local function KU_SetNewYouParry(printmsg)
	if (KU_GetToonConfig("Parry"))
	then
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_YOU_PARRY_ON);
		end
	else
		if (printmsg)
		then
			KU_ChatPrint(KU_CHAT_YOU_PARRY_OFF);
		end
	end
end

local function KU_Commands_ParamParse(param, OptionName, ConfigName, ConfigFunc)
	if (param == "off")
	then
		KU_SetToonConfig(ConfigName, false);
	elseif (param == "toggle")
	then
		KU_SetToonConfig(ConfigName, not KU_GetToonConfig(ConfigName));
	elseif (param == "on")
	then
		KU_SetToonConfig(ConfigName, true);
	else
		KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. OptionName);
		return;
	end
	if (ConfigFunc)
	then
		ConfigFunc(true);
	end
end

local function KU_Commands(command)
	local i, j, cmd, param = strfind(command, "^([^ ]+) (.+)$");
	if (not cmd) then cmd = command; end
	if (not cmd) then cmd = ""; end
	if (not param) then param = ""; end

	if ((cmd == "") or (cmd == "help"))
	then
		local cbHidden = "off";
		if (KU_GetToonConfig("HideClassBar")) then cbHidden = "on"; end
		local saoHidden = "off";
		if (KU_GetToonConfig("HideSpellActivationOverlay")) then saoHidden = "on"; end
		local clock = "off";
		if (KU_GetToonConfig("EnableClock")) then clock = "on"; end
		local clock_lock = "off";
		if (KU_GetToonConfig("LockClock")) then clock_lock = "on"; end
		local track = "off";
		if (KU_GetToonConfig("TrackWarning")) then track = "on"; end
		local level = "off";
		if (KU_GetToonConfig("QuestLevel")) then level = "on"; end
		local bags = "off";
		if (KU_GetToonConfigInt("AdjustBags", nil) ~= nil) then
			bags = "on: " ..
					tostring(KU_GetToonConfigInt("AdjustBags", nil));
		end
		local b_name = KU_GetToonConfigString("BipStr");
		local swapidol = "off";
		if (KU_GetToonConfig("SwapIdol")) then swapidol = "on"; end
		local i_name = KU_GetToonConfigString("DefaultIdol");
		local s_name = KU_GetToonConfigString("ShotName");
		local gains = "off";
		if (KU_GetToonConfig("AttackGain")) then gains = "on"; end
		local youdodge = "off";
		if (KU_GetToonConfig("Dodge")) then youdodge = "on"; end
		local targetdodge = "off";
		if (KU_GetToonConfig("TargetDodge")) then targetdodge = "on"; end
		local youparry = "off";
		if (KU_GetToonConfig("Parry")) then youparry = "on"; end
		local debugmode = "off";
		if (KU_GetToonConfig("DebugMode")) then debugmode = "on"; end
		local showpercent = "off";
		if (KU_GetToonConfig("ShowPercent")) then showpercent = "on"; end
		local automusic = "off";
		if (KU_GetToonConfig("AutoDisableMusic")) then automusic = "on"; end
		KU_ChatPrint("Usage:");
		KU_ChatPrint("  |cffffffff/ku hidesao (on|off|toggle)|r |cff2040ff[" .. saoHidden .. "]|r - " .. KU_CHAT_HELP_SAO);
		--KU_ChatPrint("  |cffffffff/ku hidecb (on|off|toggle)|r |cff2040ff["..cbHidden.."]|r - "..KU_CHAT_HELP_CLASSBAR);
		KU_ChatPrint("  |cffffffff/ku clock (on|off|toggle)|r |cff2040ff[" .. clock .. "]|r - " .. KU_CHAT_HELP_CLOCK);
		KU_ChatPrint("  |cffffffff/ku lock (on|off|toggle)|r |cff2040ff[" .. clock_lock .. "]|r - " ..
			KU_CHAT_HELP_CLOCK_LOCK);
		--KU_ChatPrint("  |cffffffff/ku track (on|off|toggle)|r |cff2040ff["..track.."]|r - "..KU_CHAT_HELP_TRACK);
		KU_ChatPrint("  |cffffffff/ku level (on|off|toggle)|r |cff2040ff[" .. level .. "]|r - " .. KU_CHAT_HELP_LEVEL);
		KU_ChatPrint("  |cffffffff/ku bags (on|off|toggle)|r |cff2040ff[" .. bags .. "]|r - " .. KU_CHAT_HELP_BAGS);
		KU_ChatPrint("  |cffffffff/ku gains (on|off|toggle)|r |cff2040ff[" .. gains .. "]|r - " .. KU_CHAT_HELP_ATTACK_GAIN);
		KU_ChatPrint("  |cffffffff/ku mounts|r - " .. KU_CHAT_HELP_MOUNTS);
		KU_ChatPrint("  |cffffffff/ku addmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " .. KU_CHAT_HELP_MOUNT_ADD);
		KU_ChatPrint("  |cffffffff/ku addflightmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " ..
			KU_CHAT_HELP_MOUNT_ADD_FLIGHT);
		KU_ChatPrint("  |cffffffff/ku addbgmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " .. KU_CHAT_HELP_MOUNT_ADD_BG);
		KU_ChatPrint("  |cffffffff/ku addinstmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " .. KU_CHAT_HELP_MOUNT_ADD_INST);
		KU_ChatPrint("  |cffffffff/ku delmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " .. KU_CHAT_HELP_MOUNT_DEL);
		KU_ChatPrint("  |cffffffff/ku delbgmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " .. KU_CHAT_HELP_MOUNT_DEL_BG);
		KU_ChatPrint("  |cffffffff/ku delinstmount <" .. KU_CHAT_HELP_MOUNT_NAME .. ">|r - " .. KU_CHAT_HELP_MOUNT_DEL_INST);
		KU_ChatPrint("  |cffffffff/ku bip <" .. KU_CHAT_HELP_BIP_NAME ..
			">|r |cff2040ff[" .. b_name .. "]|r - " .. KU_CHAT_HELP_BIP);
		KU_ChatPrint("  |cffffffff/ku youdodge (on|off|toggle)|r |cff2040ff[" .. youdodge .. "]|r - " ..
			KU_CHAT_HELP_YOU_DODGE);
		KU_ChatPrint("  |cffffffff/ku targetdodge (on|off|toggle)|r |cff2040ff[" ..
			targetdodge .. "]|r - " .. KU_CHAT_HELP_TARGET_DODGE);
		KU_ChatPrint("  |cffffffff/ku youparry (on|off|toggle)|r |cff2040ff[" .. youparry .. "]|r - " ..
			KU_CHAT_HELP_YOU_PARRY);
		KU_ChatPrint("  |cffffffff/ku obj [obj link]|r - " .. "Displays object name and ID");
		KU_ChatPrint("  |cffffffff/ku swapidol (on|off|toggle)|r |cff2040ff[" .. swapidol .. "]|r - " ..
			KU_CHAT_HELP_SWAP_IDOL);
		KU_ChatPrint("  |cffffffff/ku idol <" ..
			KU_CHAT_HELP_IDOL_NAME .. ">|r |cff2040ff[" .. i_name .. "]|r - " .. KU_CHAT_HELP_IDOL);
		KU_ChatPrint("  |cffffffff/ku shot <" ..
			KU_CHAT_HELP_SHOT_NAME .. ">|r |cff2040ff[" .. s_name .. "]|r - " .. KU_CHAT_HELP_SHOT);
		KU_ChatPrint("  |cffffffff/ku debug (on|off|toggle)|r |cff2040ff[" ..
			debugmode .. "]|r - " .. "Enables/Disables debug mode");
		KU_ChatPrint("  |cffffffff/ku binds|r - " .. KU_CHAT_HELP_SB_LIST);
		KU_ChatPrint("  |cffffffff/ku addbind <key> <type> <unit> <spell>|r - " .. KU_CHAT_HELP_SB_ADD);
		KU_ChatPrint("  |cffffffff/ku delbind <index>|r - " .. KU_CHAT_HELP_SB_DEL);
		KU_ChatPrint("  |cffffffff/ku bfmm|r - " .. KU_CHAT_HELP_BFMM);
		KU_ChatPrint("  |cffffffff/ku percent (on|off|toggle)|r |cff2040ff[" ..
			showpercent .. "]|r - " .. "Shows target frame health values AND percent");
		KU_ChatPrint("  |cffffffff/ku automusic (on|off|toggle)|r |cff2040ff[" ..
			automusic .. "]|r - " .. "Automatically disables music when fighting a boss");
		KU_ChatPrint("  |cffffffff/ku omnium (save|apply|clear|status)|r - " .. "Auto-swap Omnium Folio runes per spec (save current picks, they re-apply on spec change)");
		KU_ChatPrint("  |cffffffff/ku options|r - " .. "Open graphical options panel");
	elseif (cmd == "percent")
	then
		KU_Commands_ParamParse(param, "percent", "ShowPercent", KU_SetShowPercent);
	elseif (cmd == "debug")
	then
		KU_Commands_ParamParse(param, "debug", "DebugMode", KU_SetNewDebugMode);
	elseif (cmd == "rt")
	then
		local num = tonumber(param);
		if (num)
		then
			KU_SetToonConfig("RaidTarget", num);
		end
	elseif (cmd == "bfmm")
	then
		ToggleBattlefieldMap()
	elseif (cmd == "mount")
	then
		local _, _, _, mountid = strfind(param, "|c%x+|H(mount:(%d+):.*)|h%[.-%]|h|r");
		if (mountid)
		then
			--local name,link = GetSpellInfo(spellid);
			--if(name)
			--then
			--KU_ChatPrint("Spell name: '"..name.."' -- ID: "..spellid);
			--end
			KU_ChatPrint("Mount SpellID: " .. mountid)
			return;
		else
			local num = tonumber(param);
			if (num and num ~= 0)
			then
				local link = GetSpellLink(num);
				if (link)
				then
					KU_ChatPrint("Spell " .. num .. ": " .. link);
				else
					KU_ChatPrint("Spell not found in cache");
				end
			else
				KU_ChatPrint("Spell not found");
			end
		end
	elseif (cmd == "spell")
	then
		-- Match spell links: modern format may vary, be flexible
		local spellid = param:match("|c%x+|Hspell:(%d+)[^|]*|h%[.-%]|h|r")
		if (spellid)
		then
			spellid = tonumber(spellid)
			local name = GetSpellInfo(spellid);
			if (name)
			then
				KU_ChatPrint("Spell name: '" .. name .. "' -- ID: " .. spellid);
			else
				KU_ChatPrint("Spell ID: " .. spellid .. " (name not found)");
			end
			return;
		else
			local num = tonumber(param);
			if (num and num ~= 0)
			then
				local link = GetSpellLink(num);
				if (link)
				then
					KU_ChatPrint("Spell " .. num .. ": " .. link);
				else
					-- Fallback: try to get name at least
					local name = GetSpellInfo(num);
					if name then
						KU_ChatPrint("Spell " .. num .. ": '" .. name .. "' (no link available)");
					else
						KU_ChatPrint("Spell not found in cache");
					end
				end
			else
				KU_ChatPrint("Spell not found");
			end
		end
	elseif (cmd == "obj")
	then
		-- Match item links: use flexible pattern for modern WoW format
		-- Modern item links: |cFFxxxxxx|Hitem:ITEMID:...|h[Name]|h|r
		local itemlink, itemid = param:match("|c%x+|H(item:(%d+)[^|]*)|h%[.-%]|h|r")
		if (itemid)
		then
			itemid = tonumber(itemid)
			local name, link = C_Item.GetItemInfo(itemid)
			if (name)
			then
				KU_ChatPrint("Object name: '" .. name .. "' -- ID: " .. itemid);
			else
				KU_ChatPrint("Object ID: " .. itemid .. " (name not in cache, try again)");
			end
			return;
		else
			local num = tonumber(param);
			if (num and num ~= 0)
			then
				local name, link, rarity = C_Item.GetItemInfo(num);
				if (name == nil)
				then
					KU_ChatPrint("Object was not in local cache... requesting from server");
					local item = Item:CreateFromItemID(num);
					item:ContinueOnItemLoad(function()
						local n, l = C_Item.GetItemInfo(num);
						if n then
							KU_ChatPrint("Object '" .. n .. "': " .. (l or "no link"));
						else
							KU_ChatPrint("Object " .. num .. ": still not available");
						end
					end);
					return;
				end
				KU_ChatPrint("Object '" .. name .. "': " .. link);
			else
				KU_ChatPrint("Object not found");
			end
		end
	elseif (cmd == "automusic")
	then
		KU_Commands_ParamParse(param, "automusic", "AutoDisableMusic", nil);
	elseif (cmd == "hidesao")
	then
		KU_Commands_ParamParse(param, "hidesao", "HideSpellActivationOverlay", KU_SetNewSpellActivationOverlay);
	elseif (cmd == "hidecb")
	then
		--KU_Commands_ParamParse(param,"hidecb","HideClassBar",KU_SetNewClassBar);
		kud("'hidecb' feature disabled");
	elseif (cmd == "clock")
	then
		KU_Commands_ParamParse(param, "clock", "EnableClock", KU_SetClock);
	elseif (cmd == "lock")
	then
		KU_Commands_ParamParse(param, "lock", "LockClock", KU_SetClockLock);
		--[[elseif(cmd == "track")
	then
		KU_Commands_ParamParse(param,"track","TrackWarning",KU_SetNewTrack);]]
	elseif (cmd == "bags")
	then
		if (param == "off")
		then
			KU_SetToonConfig("AdjustBags", nil);
		else
			if (param == "")
			then
				KU_ChatPrint("Current bags parameters: Offset=" ..
					KU_GetToonConfigInt("AdjustBags", 70) .. " Scale=" .. KU_GetToonConfigInt("ScaleBags", 1.0));
				return;
			end
			local _, _, offsetStr, scaleStr = strfind(param, "([^ ]+) *([^ ]*)")
			local offset = tonumber(offsetStr);
			local scale = tonumber(scaleStr);
			if (offset == nil)
			then
				KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "bags");
				return;
			end
			KU_SetToonConfig("AdjustBags", offset);
			if (scale ~= nil)
			then
				KU_SetToonConfig("ScaleBags", scale);
			end
		end
		KU_SetNewBags(true);
	elseif (cmd == "loc")
	then
		if (param == "") or (param == nil)
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "loc");
			return;
		end
		local _, _, x, y = strfind(param, "^(-*[0-9]+),(-*[0-9]+)$");
		if x == nil or y == nil
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "loc");
			return;
		end
		KU_SetToonConfig("LossOfControl", param);
		KU_SetNewLossOfControl(true);
	elseif (cmd == "msbtarea")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "msbtarea");
			return;
		end;
		local param2 = strupper(param);
		for scrollAreaKey, scrollAreaName in MikSBT.IterateScrollAreas()
		do
			if (strupper(scrollAreaName) == param2)
			then
				KU_SetToonConfig("MSBT_Area", scrollAreaName);
				KU_ChatPrint("MikSBT notification set to area named '" .. param .. "'");
				return;
			end
		end
		KU_ChatPrint("Area named '" .. param .. "' not found in MikSBT areas");
	elseif (cmd == "mounts")
	then
		KU_ListMounts();
	elseif (cmd == "addmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "addmount");
			return;
		end;
		-- Check if we passed a link
		local passedName = nil;
		local _, _, _, linkSpellID = strfind(param, "|c%x+|H(mount:(%d+):.*)|h%[.-%]|h|r");
		if (linkSpellID)
		then
			linkSpellID = tonumber(linkSpellID);
		else
			passedName = strupper(param);
		end
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs)
		do
			local creatureName, spellID, icon, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned =
					C_MountJournal.GetMountInfoByID(mountID);
			if ((linkSpellID ~= nil and linkSpellID == spellID) or (passedName ~= nil and strfind(strupper(creatureName), passedName)))
			then
				if (not summonable)
				then
					KU_ChatPrint("This mount is not summonable by this character");
					return;
				end
				if (not owned)
				then
					KU_ChatPrint("You do not owned this mount");
					return;
				end
				local mounts = KU_GetToonConfig("Mounts");
				if (not mounts)
				then
					mounts = {};
				end
				tinsert(mounts, creatureName);
				KU_SetToonConfig("Mounts", mounts);
				KU_ChatPrint(KU_CHAT_MOUNT_SET .. creatureName .. "'");
				if (InCombatLockdown())
				then
					pendingSetupMacro = true;
				else
					KU_SetupMountMacros();
				end
				return;
			end
		end
		KU_ChatPrint(KU_CHAT_MOUNT_NOTFOUND .. param);
	elseif (cmd == "adddfmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "adddfmount");
			return;
		end;
		-- Check if we passed a link
		local passedName = nil;
		local _, _, _, linkSpellID = strfind(param, "|c%x+|H(mount:(%d+):.*)|h%[.-%]|h|r");
		if (linkSpellID)
		then
			linkSpellID = tonumber(linkSpellID);
		else
			passedName = strupper(param);
		end
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs)
		do
			local creatureName, spellID, icon, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned =
					C_MountJournal.GetMountInfoByID(mountID);
			if ((linkSpellID ~= nil and linkSpellID == spellID) or (passedName ~= nil and strfind(strupper(creatureName), passedName)))
			then
				if (not summonable)
				then
					KU_ChatPrint("This mount is not summonable by this character");
					return;
				end
				if (not owned)
				then
					KU_ChatPrint("You do not owned this mount");
					return;
				end
				local mounts = KU_GetToonConfig("DFMounts");
				if (not mounts)
				then
					mounts = {};
				end
				tinsert(mounts, creatureName);
				KU_SetToonConfig("DFMounts", mounts);
				KU_ChatPrint(KU_CHAT_MOUNT_SET .. creatureName .. "'");
				if (InCombatLockdown())
				then
					pendingSetupMacro = true;
				else
					KU_SetupMountMacros();
				end
				return;
			end
		end
		KU_ChatPrint(KU_CHAT_MOUNT_NOTFOUND .. param);
	elseif (cmd == "addflightmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "addflightmount");
			return;
		end;
		-- Check if we passed a link
		local passedName = nil;
		local _, _, _, linkSpellID = strfind(param, "|c%x+|H(mount:(%d+):.*)|h%[.-%]|h|r");
		if (linkSpellID)
		then
			linkSpellID = tonumber(linkSpellID);
		else
			passedName = strupper(param);
		end
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs)
		do
			local creatureName, spellID, icon, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned =
					C_MountJournal.GetMountInfoByID(mountID);
			if ((linkSpellID ~= nil and linkSpellID == spellID) or (passedName ~= nil and strfind(strupper(creatureName), passedName)))
			then
				if (not summonable)
				then
					KU_ChatPrint("This mount is not summonable by this character");
					return;
				end
				if (not owned)
				then
					KU_ChatPrint("You do not owned this mount");
					return;
				end
				local mounts = KU_GetToonConfig("FlightMounts");
				if (not mounts)
				then
					mounts = {};
				end
				tinsert(mounts, creatureName);
				KU_SetToonConfig("FlightMounts", mounts);
				KU_ChatPrint(KU_CHAT_MOUNT_SET .. creatureName .. "'");
				if (InCombatLockdown())
				then
					pendingSetupMacro = true;
				else
					KU_SetupMountMacros();
				end
				return;
			end
		end
		KU_ChatPrint(KU_CHAT_MOUNT_NOTFOUND .. param);
	elseif (cmd == "addbgmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "addbgmount");
			return;
		end;
		-- Check if we passed a link
		local passedName = nil;
		local _, _, _, linkSpellID = strfind(param, "|c%x+|H(mount:(%d+):.*)|h%[.-%]|h|r");
		if (linkSpellID)
		then
			linkSpellID = tonumber(linkSpellID);
		else
			passedName = strupper(param);
		end
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs)
		do
			local creatureName, spellID, icon, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned =
					C_MountJournal.GetMountInfoByID(mountID);
			if ((linkSpellID ~= nil and linkSpellID == spellID) or (passedName ~= nil and strfind(strupper(creatureName), passedName)))
			then
				if (not summonable)
				then
					KU_ChatPrint("This mount is not summonable by this character");
					return;
				end
				if (not owned)
				then
					KU_ChatPrint("You do not owned this mount");
					return;
				end
				local mounts = KU_GetToonConfig("BGMounts");
				if (not mounts)
				then
					mounts = {};
				end
				tinsert(mounts, creatureName);
				KU_SetToonConfig("BGMounts", mounts);
				KU_ChatPrint(KU_CHAT_MOUNT_SET .. creatureName .. "'");
				if (InCombatLockdown())
				then
					pendingSetupMacro = true;
				else
					KU_SetupMountMacros();
				end
				return;
			end
		end
		KU_ChatPrint(KU_CHAT_MOUNT_NOTFOUND .. param);
	elseif (cmd == "addinstmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "addinstmount");
			return;
		end;
		-- Check if we passed a link
		local passedName = nil;
		local _, _, _, linkSpellID = strfind(param, "|c%x+|H(mount:(%d+):.*)|h%[.-%]|h|r");
		if (linkSpellID)
		then
			linkSpellID = tonumber(linkSpellID);
		else
			passedName = strupper(param);
		end
		local mountIDs = C_MountJournal.GetMountIDs();
		for i, mountID in ipairs(mountIDs)
		do
			local creatureName, spellID, icon, active, summonable, source, isFavorite, isFactionSpecific, faction, unknown, owned =
					C_MountJournal.GetMountInfoByID(mountID);
			if ((linkSpellID ~= nil and linkSpellID == spellID) or (passedName ~= nil and strfind(strupper(creatureName), passedName)))
			then
				if (not summonable)
				then
					KU_ChatPrint("This mount is not summonable by this character");
					return;
				end
				if (not owned)
				then
					KU_ChatPrint("You do not owned this mount");
					return;
				end
				local mounts = KU_GetToonConfig("INSTMounts");
				if (not mounts)
				then
					mounts = {};
				end
				tinsert(mounts, creatureName);
				KU_SetToonConfig("INSTMounts", mounts);
				KU_ChatPrint(KU_CHAT_MOUNT_SET .. creatureName .. "'");
				if (InCombatLockdown())
				then
					pendingSetupMacro = true;
				else
					KU_SetupMountMacros();
				end
				return;
			end
		end
		KU_ChatPrint(KU_CHAT_MOUNT_NOTFOUND .. param);
	elseif (cmd == "delmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "delmount");
			return;
		end;
		local mounts = KU_GetToonConfig("FlightMounts");
		if (mounts)
		then
			for i, mount in ipairs(mounts)
			do
				if (strfind(strlower(mount), strlower(param)))
				then
					tremove(mounts, i);
					if (#mounts == 0)
					then
						KU_SetToonConfig("FlightMounts", nil);
					end
					KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL, mount));
					if (not KU_HasUseMount)
					then
						if (InCombatLockdown())
						then
							pendingSetupMacro = true;
						else
							KU_SetupMountMacros();
						end
					end
					return;
				end
			end
		end
		local mounts = KU_GetToonConfig("AQMounts");
		if (mounts)
		then
			for i, mount in ipairs(mounts)
			do
				if (strfind(strlower(mount), strlower(param)))
				then
					tremove(mounts, i);
					if (#mounts == 0)
					then
						KU_SetToonConfig("AQMounts", nil);
					end
					KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL, mount));
					if (not KU_HasUseMount)
					then
						if (InCombatLockdown())
						then
							pendingSetupMacro = true;
						else
							KU_SetupMountMacros();
						end
					end
					return;
				end
			end
		end
		local mounts = KU_GetToonConfig("Mounts");
		if (mounts)
		then
			for i, mount in ipairs(mounts)
			do
				if (strfind(strlower(mount), strlower(param)))
				then
					tremove(mounts, i);
					if (#mounts == 0)
					then
						KU_SetToonConfig("Mounts", nil);
					end
					KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL, mount));
					if (not KU_HasUseMount)
					then
						if (InCombatLockdown())
						then
							pendingSetupMacro = true;
						else
							KU_SetupMountMacros();
						end
					end
					return;
				end
			end
		end
		KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL_ERR, param));
	elseif (cmd == "deldfmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "deldfmount");
			return;
		end;
		local mounts = KU_GetToonConfig("DFMounts");
		if (mounts)
		then
			for i, mount in ipairs(mounts)
			do
				if (strfind(strlower(mount), strlower(param)))
				then
					tremove(mounts, i);
					if (#mounts == 0)
					then
						KU_SetToonConfig("DFMounts", nil);
					end
					KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL, mount));
					if (not KU_HasUseMount)
					then
						if (InCombatLockdown())
						then
							pendingSetupMacro = true;
						else
							KU_SetupMountMacros();
						end
					end
					return;
				end
			end
		end
		KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL_ERR, param));
	elseif (cmd == "delbgmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "delbgmount");
			return;
		end;
		local mounts = KU_GetToonConfig("BGMounts");
		if (mounts)
		then
			for i, mount in ipairs(mounts)
			do
				if (strfind(strlower(mount), strlower(param)))
				then
					tremove(mounts, i);
					if (#mounts == 0)
					then
						KU_SetToonConfig("BGMounts", nil);
					end
					KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL, mount));
					if (not KU_HasUseMount)
					then
						if (InCombatLockdown())
						then
							pendingSetupMacro = true;
						else
							KU_SetupMountMacros();
						end
					end
					return;
				end
			end
		end
		KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL_ERR, param));
	elseif (cmd == "delinstmount")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "delinstmount");
			return;
		end;
		local mounts = KU_GetToonConfig("INSTMounts");
		if (mounts)
		then
			for i, mount in ipairs(mounts)
			do
				if (strfind(strlower(mount), strlower(param)))
				then
					tremove(mounts, i);
					if (#mounts == 0)
					then
						KU_SetToonConfig("INSTMounts", nil);
					end
					KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL, mount));
					if (not KU_HasUseMount)
					then
						if (InCombatLockdown())
						then
							pendingSetupMacro = true;
						else
							KU_SetupMountMacros();
						end
					end
					return;
				end
			end
		end
		KU_ChatPrint(string.format(KU_CHAT_MOUNT_DEL_ERR, param));
	elseif (cmd == "sb")
	then
		if param == "" or param == nil
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "sb");
			return;
		end;
		local sb = KU_GetSoulBinds(C_Covenants.GetActiveCovenantID())
		if param == "save"
		then
			local soulbindID = C_Soulbinds.GetActiveSoulbindID()
			local selected = KU_GetSelectedSoulBindBranches(soulbindID)
			local typ = EnumSoulBindType.Spec
			local sbType = sb[typ]
			if sbType == nil
			then
				sb[typ] = {}
				sbType = sb[typ]
			end
			sbType.ID = soulbindID
			sbType.branches = selected
			KU_ChatPrint("Saved current soulbind tree for type " .. typ)
		elseif param == "apply"
		then
			local typ = EnumSoulBindType.Spec
			local sbType = sb[typ]
			if sbType == nil
			then
				KU_ChatPrint("No save soulbind tree to apply for type " .. typ)
				return
			end
			KU_SoulBindTypeToApply = typ
			KU_NeedToCheckForSoulbind = EnumSoulBindCheck.Apply
			KU_TimeToCheckForSoulbind = KU_CurrentTime
		else
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "sb " .. param);
		end
	elseif (cmd == "omnium")
	then
		KU_OmniumCommand(param);
	elseif (cmd == "binds")
	then
		KU_BindingsList();
	elseif (cmd == "addbind")
	then
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "addbind");
			return;
		end;
		local _, _, key, type, unit, spell = strfind(param, "([^ ]+) ([^ ]+) ([^ ]+) (.+)");
		if (not key or not spell or not type or not unit)
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "addbind");
			return;
		end
		if (not KU_CheckBindingType(type))
		then
			return;
		end
		if (not KU_CheckBindingUnit(unit))
		then
			return;
		end
		KU_AddSpellBinding(type, spell, unit, key);
	elseif (cmd == "delbind")
	then
		param = tonumber(param);
		if ((param == "") or (param == nil))
		then
			KU_ChatPrint(KU_CHAT_CMD_PARAM_ERROR .. "delbind");
			return;
		end;
		KU_DelSpellBinding(param);
	elseif (cmd == "bip")
	then
		if ((param == "") or (param == nil))
		then
			KU_SetToonConfig("BipStr", "");
			KU_ChatPrint(KU_CHAT_BIP_OFF);
		else
			KU_SetToonConfig("BipStr", param);
			KU_ChatPrint(KU_CHAT_BIP_SET .. param .. "'");
		end
	elseif (cmd == "swapidol")
	then
		KU_Commands_ParamParse(param, "swapidol", "SwapIdol", KU_SetNewSwapIdol);
	elseif (cmd == "idol")
	then
		if ((param == "") or (param == nil))
		then
			KU_SetToonConfig("DefaultIdol", "");
			KU_ChatPrint(KU_CHAT_IDOL_OFF);
		else
			local b, s, n = KU_SearchIdolInBags(param);
			if (s == -1)
			then
				KU_ChatPrint("Failed to find Idol partially named '" .. param .. "' in your equipment");
				return;
			end
			KU_SetToonConfig("DefaultIdol", n);
			KU_ChatPrint(KU_CHAT_IDOL_SET .. n .. "'");
		end
	elseif (cmd == "shot")
	then
		if ((param == "") or (param == nil))
		then
			KU_SetToonConfig("ShotName", "");
			KU_ChatPrint(KU_CHAT_SHOT_OFF);
		else
			KU_SetToonConfig("ShotName", param);
			KU_ChatPrint(KU_CHAT_SHOT_SET .. param .. "'");
		end
		if (InCombatLockdown())
		then
			pendingSetupForceAttackMacro = true;
		else
			KU_SetupForceAttackMacro();
		end
	elseif (cmd == "gains")
	then
		KU_Commands_ParamParse(param, "gains", "AttackGain", KU_SetNewAttackGain);
	elseif (cmd == "youdodge")
	then
		KU_Commands_ParamParse(param, "youdodge", "Dodge", KU_SetNewYouDodge);
	elseif (cmd == "targetdodge")
	then
		KU_Commands_ParamParse(param, "targetdodge", "TargetDodge", KU_SetNewTargetDodge);
	elseif (cmd == "youparry")
	then
		KU_Commands_ParamParse(param, "youparry", "Parry", KU_SetNewYouParry);
	elseif (cmd == "options")
	then
		KU_OpenOptionsPanel();
	else
		KU_ChatPrint(KU_CHAT_CMD_UNKNOWN);
	end
end

local function KU_OkToPrintCheckTrack()
	if (AK_GetCurrentBGIndexAndName and AK_GetCurrentBGIndexAndName() ~= 0)
	then
		return false;
	end
	return true;
end

local function KU_CheckTrack()
	--[[
	if(KU_GetToonConfig("TrackWarning"))
	then
		-- TrackWarning check
		local Hour, Minute = GetGameTime();
		
		if(KU_TrackCheck_LastTime ~= Minute) -- Check every minute
		then
			local icon = GetTrackingTexture();
			if(icon == nil and KU_OkToPrintCheckTrack())
			then
				UIErrorsFrame:AddMessage(KU_CHAT_TRACK_WARN, 0.1, 0.8, 0.1, 1.0, UIERRORS_HOLD_TIME);
			end
			KU_TrackCheck_LastTime = Minute;
		end
	end
	]] -- Disabled: Function GetTrackingTexture removed
end

--------------- From XML functions ---------------

---------------------------------------------------
-- MouseLook
---------------------------------------------------
local function KU_CheckDeferredMouseLookStart()
	if KU_MustToggleMouseLook
	then
		KU_ToggleMouseLook()
	end
end

local function KU_CheckDeferredMouseLookStop()
	if KU_MustToggleMouseLook
	then
		KU_ToggleMouseLook()
	end
end

_G.hooksecurefunc("TurnOrActionStop", function()
	KU_CheckDeferredMouseLookStart()
end)

_G.hooksecurefunc("CameraOrSelectOrMoveStop", function()
	KU_CheckDeferredMouseLookStart()
end)

_G.hooksecurefunc("MoveForwardStop", function()
	KU_CheckDeferredMouseLookStop()
end)

_G.hooksecurefunc("MoveBackwardStop", function()
	KU_CheckDeferredMouseLookStop()
end)

function KU_ToggleMouseLook()
	if (IsMouseButtonDown(1) or IsMouseButtonDown(2))
	then
		KU_MustToggleMouseLook = true;
		return;
	end

	KU_MustToggleMouseLook = false;
	if (not IsMouselooking() and KU_MouseLookOn == 1)
	then
		KU_MouseLookOn = 0;
	end
	if (KU_MouseLookOn == 0)
	then
		MouselookStart();
		KU_MouseLookOn = 1;
	else -- KU_MouseLookOn == 1 -->
		MouselookStop();
		KU_MouseLookOn = 0;
	end
end

function KU_SetupMouselook()
	if (not KU_MouselookButton) then
		CreateFrame("Button", "KU_MouselookButton");
		KU_MouselookButton:RegisterForClicks("AnyDown");
		KU_MouselookButton:SetScript("OnClick", function(self, button, down) KU_ToggleMouseLook() end);
	end
	ClearOverrideBindings(KU_MouselookButton);
	local key, key2 = GetBindingKey("KIKIUTILS_ML");
	if (key) then
		SetOverrideBindingClick(KU_MouselookButton, false, key, "KU_MouselookButton");
	end
	if (key2) then
		SetOverrideBindingClick(KU_MouselookButton, false, key2, "KU_MouselookButton");
	end
	if (key or key2)
	then
		SetMouselookOverrideBinding("BUTTON1", "MOVEFORWARD")
		SetMouselookOverrideBinding("BUTTON2", "MOVEBACKWARD")
	end
end

------- Thanks to Slouken for the new functions

local function _KU_UseMountInventory(mounts)
	local count = #mounts;

	if (count == 0)
	then
		return nil;
	end

	-- Get a random number, and try use it
	local num = math.random(count);
	return mounts[num];
end

function KU_GetMountToUse(dontgetflying)
	local landmount = nil;
	local flymount = nil;

	local inInstance, instanceType = IsInInstance();
	local currentZoneID = KU_GetCurrentMapID(Enum.UIMapType.Zone)
	local currentContinentID = KU_GetCurrentMapID()
	local currentDungeonID = KU_GetCurrentMapID(Enum.UIMapType.Dungeon)

	-- Check for Dragonflight mounts
	if currentContinentID == 1978 and not dontgetflying and (not inInstance or currentDungeonID == 2093)
	then
		local mounts = KU_GetToonConfig("DFMounts");
		if (mounts)
		then
			local name = _KU_UseMountInventory(mounts);
			if (name)
			then
				return name, nil;
			end
		end
	end

	-- Check for BG mounts
	if (inInstance and instanceType == "pvp")
	then
		local mounts = KU_GetToonConfig("BGMounts");
		if (mounts)
		then
			local name = _KU_UseMountInventory(mounts);
			if (name)
			then
				return name, nil;
			end
		end
	end

	-- Then check for INST mounts
	if (inInstance and (instanceType == "raid" or instanceType == "party"))
	then
		local mounts = KU_GetToonConfig("INSTMounts");
		if (mounts)
		then
			local name = _KU_UseMountInventory(mounts);
			if (name)
			then
				return name, nil;
			end
		end
	end

	--[[
	-- Then check for The Maw
	if currentZoneID == 1543 or currentZoneID == 1961 -- The Maw / Korthia
	then
		local has_creeper,creeper_name = KU_HasMount(344578) -- Corridor Creeper
		if has_creeper
		then
			landmount = creeper_name
		end
	end
	]]

	-- Then check for abyssal sea horse
	if (KU_CurrentZone == KU_ZONE_KELPTHAR or KU_CurrentZone == KU_ZONE_SHIMMERING_EXPANSE or KU_CurrentZone == KU_ZONE_ABYSSAL_DEPTHS)
	then
		local has_seahorse, sh_name = KU_HasMount(75207);
		if (has_seahorse)
		then
			landmount = sh_name;
		end
	end

	-- Then check for flying mounts
	if (not dontgetflying) -- Outland
	then
		local mounts = KU_GetToonConfig("FlightMounts");
		if (mounts)
		then
			local name = _KU_UseMountInventory(mounts);
			if (name)
			then
				flymount = name;
			end
		end
	end

	-- Then check for Frostwolf War Wolf
	if (KU_CurrentZone == KU_ZONE_NAGRAND)
	then
		--local has_mount,mount_name = KU_HasMount(KU_FROSTWOLF_WAR_WOLF_SPELLID); -- Don't work :/
		local has_mount = true;
		local mount_name = GetSpellInfo(KU_FROSTWOLF_WAR_WOLF_SPELLID);
		if (has_mount)
		then
			flymount = mount_name; -- Right now, return as a flyable mount, must check for WoD flying skill
		end
	end

	-- Check AQ mount
	if (KU_CurrentZone == KU_ZONE_TEMPLE_AHNQIRAJ) -- Ahn'Qiraj
	then
		local mounts = KU_GetToonConfig("AQMounts");
		if (mounts)
		then
			local name = _KU_UseMountInventory(mounts);
			if (name)
			then
				landmount = name;
			end
		end
	end

	-- Then check for other land mounts, if not already assigned
	if (landmount == nil)
	then
		local mounts = KU_GetToonConfig("Mounts");
		if (mounts)
		then
			local name = _KU_UseMountInventory(mounts);
			if (name)
			then
				landmount = name;
			end
		end
	end
	-- Return found mounts
	return landmount, flymount;
end

function KU_ListMounts()
	local mounts = KU_GetToonConfig("BGMounts");
	if (mounts)
	then
		KU_ChatPrint("Battleground Mounts:");
		for i, mount in ipairs(mounts)
		do
			KU_ChatPrint(" - " .. mount);
		end
	end

	local mounts = KU_GetToonConfig("INSTMounts");
	if (mounts)
	then
		KU_ChatPrint("Instance Mounts:");
		for i, mount in ipairs(mounts)
		do
			KU_ChatPrint(" - " .. mount);
		end
	end

	local mounts = KU_GetToonConfig("FlightMounts");
	if (mounts)
	then
		KU_ChatPrint("Flying Mounts:");
		for i, mount in ipairs(mounts)
		do
			KU_ChatPrint(" - " .. mount);
		end
	end

	local mounts = KU_GetToonConfig("AQMounts");
	if (mounts)
	then
		KU_ChatPrint("AQ Mounts:");
		for i, mount in ipairs(mounts)
		do
			KU_ChatPrint(" - " .. mount);
		end
	end

	local mounts = KU_GetToonConfig("DFMounts");
	if (mounts)
	then
		KU_ChatPrint("DragonFlight Mounts:");
		for i, mount in ipairs(mounts)
		do
			KU_ChatPrint(" - " .. mount);
		end
	end

	local mounts = KU_GetToonConfig("Mounts");
	if (mounts)
	then
		KU_ChatPrint("Mounts:");
		for i, mount in ipairs(mounts)
		do
			KU_ChatPrint(" - " .. mount);
		end
	end
end

local function KikiUtils_StartInitVars()
	local playerName = UnitName("player");
	if ((playerName) and (playerName ~= UNKNOWNOBJECT) and (playerName ~= UKNOWNBEING))
	then
		-- Initialize Toon specific stuff
		KU_PlayerOfRealm = playerName .. " of " .. GetRealmName();
		local _, clas = UnitClass("player");
		if (clas == "DRUID")
		then
			KU_IsDruid = true;
		elseif (clas == "WARLOCK")
		then
			KU_IsWarlock = true;
		elseif (clas == "MAGE")
		then
			KU_IsMage = true;
		elseif (clas == "MONK")
		then
			KU_IsMonk = true;
		elseif (clas == "HUNTER")
		then
			KU_IsHunter = true;
		elseif (clas == "ROGUE")
		then
			KU_IsRogue = true;
		elseif (clas == "SHAMAN")
		then
			KU_IsShaman = true;
		elseif (clas == "PALADIN")
		then
			KU_IsPaladin = true;
		elseif (clas == "DEATHKNIGHT")
		then
			KU_IsDK = true;
		elseif (clas == "DEMONHUNTER")
		then
			KU_IsDH = true;
		elseif (clas == "EVOKER")
		then
			KU_IsEvoker = true;
		end
		KU_ImportGlobalConfig(); -- Check for Global->Local settings convertion
		KU_CheckConvertBindings();
		KU_SetNewSpellActivationOverlay(false);
		KU_SetNewClassBar(false);
		KU_SetNewTrack(false);
		KU_SetNewBags(false);
		KU_SetNewLossOfControl(false);
		--KU_SetClock(false);
		KU_SetClockLock(false);
		KU_SetNewYouDodge(false);
		KU_SetNewAttackGain(false);
		KU_SetNewTargetDodge(false);
		KU_SetNewYouParry(false);
		KU_SetNewSwapIdol(false);
		KU_SetNewDebugMode(false);
		KU_CheckTalentTree(false);
		--
		KU_NeedInitToonSpecific = false;
		-- Check for Mounts convert
		local mounts = KU_GetToonConfig("FlightMounts");
		if (mounts)
		then
			if (type(mounts[1]) ~= "string")
			then
				local newmounts = {};
				for _, mount in ipairs(mounts)
				do
					if (mount.name)
					then
						tinsert(newmounts, mount.name);
					end
				end
				KU_ChatPrint("New version detected, 'FlightMounts' has been converted");
				KU_SetToonConfig("FlightMounts", newmounts);
			end
		end
		local mounts = KU_GetToonConfig("AQMounts");
		if (mounts)
		then
			if (type(mounts[1]) ~= "string")
			then
				local newmounts = {};
				for _, mount in ipairs(mounts)
				do
					if (mount.name)
					then
						tinsert(newmounts, mount.name);
					end
				end
				KU_ChatPrint("New version detected, 'AQMounts' has been converted");
				KU_SetToonConfig("AQMounts", newmounts);
			end
		end
		local mounts = KU_GetToonConfig("Mounts");
		if (mounts)
		then
			if (type(mounts[1]) ~= "string")
			then
				local newmounts = {};
				for _, mount in ipairs(mounts)
				do
					if (mount.name)
					then
						tinsert(newmounts, mount.name);
					end
				end
				KU_ChatPrint("New version detected, 'Mounts' has been converted");
				KU_SetToonConfig("Mounts", newmounts);
			end
		end
	end
end

function KU_Announce(msg, r, g, b)
	if (_G.SHOW_COMBAT_TEXT == "1")
	then
		CombatText_AddMessage(msg, COMBAT_TEXT_SCROLL_FUNCTION, r, g, b, "crit", nil);
	elseif (SCT and SCT.DisplayCustomEvent)
	then
		SCT:DisplayCustomEvent(msg, { r = r, g = g, b = b }, 1);
	elseif (MikSBT and MikSBT.DisplayMessage)
	then
		local fname = KU_GetToonConfigInt("MSBT_Area", nil) or MikSBT.DISPLAYTYPE_NOTIFICATION;
		MikSBT.DisplayMessage(msg, fname, true, r * 255, g * 255, b * 255);
	end
	KU_ChatPrint(msg, r, g, b);
end

local function KU_IsInPvEInstance()
	local inInstance, instanceType = IsInInstance();
	if (inInstance)
	then
		if (instanceType == "party" or instanceType == "raid")
		then
			return true;
		end
	end
	return false;
end

local function KU_GetResilience()
	--[[local melee = GetCombatRating(CR_CRIT_TAKEN_MELEE);
	local ranged = GetCombatRating(CR_CRIT_TAKEN_RANGED);
	local spell = GetCombatRating(CR_CRIT_TAKEN_SPELL);

	local minResilience = min(melee, ranged);
	minResilience = min(minResilience, spell);
	return minResilience;]]
	return GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN);
end

function KU_NoDefensiveStanceInPveInstance()
	local has_def, def_name = KU_HasSpell(71); -- Defensive Stance
	if (has_def and KU_IsInPvEInstance())
	then
		local name = UnitBuff("player", def_name);
		if (name == nil) -- If 'name' is nil, it means the buff is not active
		then
			return true;
		end
	end
	return false;
end

function KU_NoBloodPresenceInPveInstance()
	local has_blood, blood_name = KU_HasSpell(48263); -- Blood Presence
	if (has_blood and KU_IsInPvEInstance())
	then
		local name = UnitBuff("player", blood_name);
		if (name == nil) -- If 'name' is nil, it means the buff is not active
		then
			return true;
		end
	end
	return false;
end

function KU_NoRighteousFuryInPveInstance()
	local has_fury, fury_name = KU_HasSpell(25780); -- Righteous Fury
	if (has_fury and KU_IsInPvEInstance())
	then
		local name = UnitBuff("player", fury_name);
		if (name == nil) -- If 'name' is nil, it means the buff is not active
		then
			return true;
		end
	end
	return false;
end

function KU_HasSealOfCommandActiveInPveInstance()
	local has_command, seal_name = KU_HasSpell(20154); -- Seal of Righteousness
	if (has_command)
	then
		local name = UnitBuff("player", seal_name);
		if (name and KU_IsInPvEInstance()) -- If 'name' not nil, it means the buff is active
		then
			return seal_name;
		end
	end
	return nil;
end

function KU_HasRoleNotTank()
	local role = UnitGroupRolesAssigned("player");
	if (role ~= "NONE")
	then
		return (role ~= "TANK");
	end
	return false;
end

function KU_GetCurrentMapID(mapType)
	local mType = mapType or Enum.UIMapType.Continent
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID
	then
		local info = C_Map.GetMapInfo(mapID)
		if info
		then
			while info and info['mapType'] and info['mapType'] ~= mType
			do
				info = C_Map.GetMapInfo(info['parentMapID'])
			end
			if info and info['mapType'] == mType
			then
				return info['mapID']
			end
		end
	end
	return 0
end

local function KU_CheckSoulBindEnteringWorld()
	local inInstance = IsInInstance()
	if inInstance
	then
		local _, instanceType, difficulty = GetInstanceInfo()
		-- Mythic = 23
		if instanceType == "pvp"
		then
			kud("ENTERING INSTANCE: " .. tostring(instanceType) .. " -> " .. tostring(difficulty))
			KU_SoulBindTypeToApply = EnumSoulBindType.PvP
			KU_NeedToCheckForSoulbind = EnumSoulBindCheck.Apply
			KU_TimeToCheckForSoulbind = KU_CurrentTime + 0.5
		elseif instanceType == "party"
		then
			KU_SoulBindTypeToApply = EnumSoulBindType.Instance
			KU_NeedToCheckForSoulbind = EnumSoulBindCheck.CheckOnly
			KU_TimeToCheckForSoulbind = KU_CurrentTime + 2.0
		elseif instanceType == "raid"
		then
			kud("ENTERING INSTANCE: " .. tostring(instanceType) .. " -> " .. tostring(difficulty))
			KU_SoulBindTypeToApply = EnumSoulBindType.Raid
			KU_NeedToCheckForSoulbind = EnumSoulBindCheck.CheckOnly
			KU_TimeToCheckForSoulbind = KU_CurrentTime + 2.0
		end
	end
end

function KikiUtils_OnEvent(self, event, ...)
	if (event == "VARIABLES_LOADED")
	then
		KU_VarsLoaded = true;
	end
	if (KU_NeedInitToonSpecific)
	then
		if (KU_VarsLoaded == false or GetNumSpecializations() == 0)
		then
			return;
		end
		KikiUtils_StartInitVars();
	end

	-- Check Tracking
	KU_CheckTrack();
	-- Check events
	if (event == "PLAYER_ENTER_COMBAT")
	then
		KU_IS_ATTACK = 1;
	elseif (event == "PLAYER_LEAVE_COMBAT")
	then
		KU_IS_ATTACK = 0;
	elseif (event == "UNIT_AURA" or event == "UPDATE_SHAPESHIFT_FORMS")
	then
		if (event == "UNIT_AURA" and select(1, ...) ~= "player") then return; end
		local old = KU_IS_MOUNTING;
		KU_MustCheckGhostWolfState = true;
		KU_MustCheckCheetahState = true;
		local new = IsMounted();
		if (new ~= old) -- Mounting state changed
		then
			if (new)    -- Mounting
			then
				KU_HasUseMount = true;
			elseif (InCombatLockdown())
			then
				pendingSetupMacro = true;
			else
				KU_SetupMountMacros();
			end
		end
		KU_IS_MOUNTING = new;
	elseif (event == "AUTOFOLLOW_BEGIN")
	then
		if (KU_IS_AUTORUN == 1)
		then
			KU_ToggleAutoRun()
		end
		KU_FollowModeOn = 1;
	elseif (event == "AUTOFOLLOW_END")
	then
		if (KU_FollowModeOn == 1)
		then
			KU_FollowModeOn = 0;
		end
	elseif (event == "ZONE_CHANGED_NEW_AREA")
	then
		KU_CurrentZone = GetRealZoneText();
		-- Reset ClassBar
		KU_SetNewClassBar(false);
		if (InCombatLockdown()) -- Setup mount macro after zoning
		then
			pendingSetupMacro = true;
		else
			KU_SetupMountMacros();
		end
		-- Special case for Dalaran zone
		if (KU_CurrentZone == KU_ZONE_DALARAN)
		then
			KikiUtilsFrame:RegisterEvent("ZONE_CHANGED");
			KU_SubZoneRegistered = true;
		elseif (KU_SubZoneRegistered)
		then
			KikiUtilsFrame:UnregisterEvent("ZONE_CHANGED");
			KU_SubZoneRegistered = false;
		end
	elseif (event == "ZONE_CHANGED")
	then
		if (InCombatLockdown()) -- Setup mount macro after zoning
		then
			pendingSetupMacro = true;
		else
			KU_SetupMountMacros();
		end
	elseif (event == "PLAYER_ENTERING_WORLD")
	then
		if (KU_CurrentZone == nil) -- Get it here too, because when you /reloadui the ZONE_CHANGED is not called - Thanks blizzard
		then
			KU_CurrentZone = GetRealZoneText();
		end
		KU_LastPosition = {};
		--KU_LastPosition.x, KU_LastPosition.y = GetPlayerMapPosition("player");
		-- Reset variables
		KU_IS_ATTACK = 0;
		KU_IS_COMBAT = 0;
		KU_IS_MOVING = 0;
		KU_LAST_SHAPE = -1;
		KU_NextRaidTargetPosition = 1;
		KU_HasShapeChanged();
		-- Reset mouselook
		KU_FollowModeOn = 0;
		KU_MouseLookOn = 0;
		KU_MouseCamera = 0;
		-- Reset ClassBar
		KU_SetNewClassBar(false);
		--KU_GainAttacks = KU_LoadRegExpr(SPELLEXTRAATTACKSSELF);
		if (InCombatLockdown()) -- Setup mount macro after zoning
		then
			pendingSetupMacro = true;
		else
			KU_SetupMountMacros();
		end
		KU_SetClock(false);
		-- Check for Soulbind
		KU_CheckSoulBindEnteringWorld()
	elseif (event == "PLAYER_LEAVING_WORLD")
	then
		KU_CheckRestoreMusic();
	elseif (event == "PLAYER_TARGET_CHANGED" or (event == "UNIT_FACTION" and select(1, ...) == "target"))
	then
		local exists = UnitExists("target");
		local isdead = UnitIsDead("target");
		local canatk = UnitCanAttack("player", "target");
		if (exists == 1 and isdead == nil and canatk == 1)
		then
			if (KU_IS_COMBAT == 1)
			then
				KU_CheckDisableMusic();
			end
			if (KU_CHECK_PALADIN_SEAL == 1)
			then
				local seal_name = KU_HasSealOfCommandActiveInPveInstance();
				if (seal_name)
				then
					if (UnitLevel("target") == -1)
					then
						KU_Announce("WARNING: " .. seal_name .. " active on a boss!", 1, 0, 0);
						KU_CHECK_PALADIN_SEAL = 0; -- Ok, no longer need to check
					end
				end
			end
		end
		--[[elseif(event == "COMBAT_LOG_EVENT_UNFILTERED")
	then
		local _,eventType,_,_,_,_,_,destGUID = CombatLogGetCurrentEventInfo()
		if (eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED") and destGUID and destGUID ~= ""
		then
			for idx,id in pairs(KU_RaidTargetGUIDs)
			do
				if destGUID == id
				then
					KU_RaidTargetGUIDs[idx] = nil
					break
				end
			end
		end]]
	elseif (event == "PLAYER_REGEN_DISABLED")
	then
		KU_IS_COMBAT = 1;
		KU_NextRaidTargetPosition = 1;
		KU_CheckDisableMusic();
	elseif (event == "PLAYER_REGEN_ENABLED")
	then
		KU_IS_COMBAT = 0;
		KU_CheckRestoreMusic();
		KU_CHECK_PALADIN_SEAL = 0; -- Always reset at the end of the fight
		if (KU_MustSwapDefaultIdol and KU_LAST_SHAPE == 0)
		then
			KU_IdolSwap(0);
		end
		if (pendingSetupMacro)
		then
			KU_SetupMountMacros();
			pendingSetupMacro = false;
		end
		if (pendingSetupForceAttackMacro)
		then
			pendingSetupForceAttackMacro = false;
		end
		if (pendingSetupBindings)
		then
			KU_BindingsSetKeys();
			pendingSetupBindings = false;
		end
	elseif (event == "BAG_UPDATE")
	then
		KU_MustCheckMount = 1;
	elseif (event == "UNIT_COMBAT")
	then
		if (KU_GetToonConfig("Dodge") and select(1, ...) == "player" and select(2, ...) == "DODGE")
		then
			PlaySoundFile("Sound\\Doodad\\G_GongTroll01.wav");
		end
		local unit, msg = ...;
		if (KU_GetToonConfig("TargetDodge") and unit == "target" and msg == "DODGE")
		then
			PlaySoundFile("Interface\\AddOns\\KikiUtils\\overpower.wav");
		end
		if (KU_GetToonConfig("Parry") and unit == "player" and msg == "PARRY")
		then
			PlaySoundFile("Interface\\AddOns\\KikiUtils\\parry.wav");
		end
	elseif (event == "CHAT_MSG_SPELL_SELF_BUFF")
	then
		if (KU_GetToonConfig("AttackGain") and (SCT_Display_Message or CombatText_AddMessage))
		then
			local _, _, count, spell = strfind(select(1, ...), KU_GainAttacks);
			if (count)
			then
				if (SCT_Display_Message)
				then
					SCT_Display_Message(format(KU_CHAT_SCT_GAIN_ATTACKS, count, spell), { r = 0.2, g = 0.2, b = 0.9 });
				elseif (CombatText_AddMessage)
				then
					CombatText_AddMessage(format(KU_CHAT_SCT_GAIN_ATTACKS, count, spell), COMBAT_TEXT_SCROLL_FUNCTION, 0.2, 0.7,
						0.9);
				end
			end
		end
	elseif (event == "ADDON_ACTION_FORBIDDEN")
	then
		KU_ChatDebug("ADDON_ACTION_FORBIDDEN : Name=" .. tostring(select(1, ...)) .. " Fct=" .. tostring(select(2, ...)));
	elseif (event == "MACRO_ACTION_FORBIDDEN")
	then
		KU_ChatDebug("MACRO_ACTION_FORBIDDEN : Fct=" .. tostring(select(1, ...)));
	elseif (event == "ADDON_ACTION_BLOCKED")
	then
		KU_ChatDebug("ADDON_ACTION_BLOCKED : Name=" .. tostring(select(1, ...)) .. " Fct=" .. tostring(select(2, ...)));
	elseif (event == "MACRO_ACTION_BLOCKED")
	then
		KU_ChatDebug("MACRO_ACTION_BLOCKED : Fct=" .. tostring(select(1, ...)));
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED")
	then
		KU_CheckTalentTree(true);
	elseif (event == "COVENANT_CHOSEN")
	then
		KU_NeedToCheckForSoulbind = EnumSoulBindCheck.Apply
		KU_SoulBindTypeToApply = EnumSoulBindType.Spec
		KU_TimeToCheckForSoulbind = KU_CurrentTime + 0.5
	end
end

function KikiUtils_Clock_OnUpdate(self, elapsed)
	KU_Clock_LastTime = KU_Clock_LastTime + elapsed;

	if (KU_Clock_LastTime > 1.0) -- Update every second
	then
		local Hour, Minute = GetGameTime();
		KU_ClockText:SetText(format(TEXT(TIME_TWENTYFOURHOURS), Hour, Minute));
		KU_Clock_LastTime = 0;
	end
end

function KikiUtils_Moving_OnUpdate(self, elapsed)
	-- Check current position
	if (KU_LastPosition)
	then
		local x, y = GetPlayerMapPosition("player");
		if ((KU_LastPosition.x ~= x) or (KU_LastPosition.y ~= y))
		then
			KU_IS_MOVING = 1;
		else
			KU_IS_MOVING = 0;
		end
		KU_LastPosition.x = x;
		KU_LastPosition.y = y;
	end
end

--[[
function KikiUtils_MMPing_OnEvent(self,event,...)
	if(event == "MINIMAP_PING")
	then
		local unit = ...;
		--if(unit ~= "player")
		--then
			KU_MMPingText:SetText("Ping: "..UnitName(unit));
			KU_MMPingText:SetTextColor(0.8,0.8,0.0);
			KU_MMPingText:Show();
			KU_MMPing_StartTime = GetTime();
		--end
	end
end

function KikiUtils_MMPing_OnUpdate(self,elapsed)
	-- if a label is currently being displayed and if label decay is enabled
	if(KU_MMPing_StartTime ~= 0)
	then
		-- if the label has been displayed for longer than the decay time
		if((GetTime() - KU_MMPing_StartTime) > KU_MMPing_LABEL_DECAY_TIME)
		then
			-- clear the label
			KU_MMPingText:Hide();
			KU_MMPing_StartTime = 0;
			lastMOText = "";
		end
	end
end

function KikiUtils_MMPing_OnLoad(self)
	self:RegisterEvent("MINIMAP_PING");
end
]]

function KikiUtils_OnLoad(self)
	-- Print init message
	KU_ChatPrint("Version " .. KU_VERSION .. " " .. KU_CHAT_MISC_LOADED);

	-- Initialize Shape value
	KU_HasShapeChanged();

	-- Register events
	self:RegisterEvent("PLAYER_ENTER_COMBAT");
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	self:RegisterEvent("AUTOFOLLOW_BEGIN");
	self:RegisterEvent("AUTOFOLLOW_END");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_FACTION");
	--self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("UNIT_COMBAT");
	-- Chat bip handled via ChatFrame_AddMessageEventFilter (avoids Kstring issues in 12.0.5)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", KU_ChatBipFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", KU_ChatBipFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", KU_ChatBipFilter)
	--self:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	--self:RegisterEvent("UNIT_POWER_BAR_SHOW");
	self:RegisterEvent("COVENANT_CHOSEN");

	-- Initialize Slash commands
	SLASH_KU1 = "/ku";
	SlashCmdList["KU"] = function(msg)
		KU_Commands(msg);
	end
	SLASH_RL1 = "/rl";
	SlashCmdList["RL"] = function(msg)
		ReloadUI();
	end
end

--------------- Exported functions ---------------

function KU_SetNextRaidTarget(unit)
	local u = unit or "target"
	if CanBeRaidTarget(u)
	then
		local guid = UnitGUID(u)

		-- Clear GUID if target already has a symbol
		for idx, id in pairs(KU_RaidTargetGUIDs)
		do
			if guid == id
			then
				KU_RaidTargetGUIDs[idx] = nil
				SetRaidTarget(u, 0)
				return
			end
		end

		-- Then count elements
		local usedMarkers = 0
		for _, _ in pairs(KU_RaidTargetGUIDs)
		do
			usedMarkers = usedMarkers + 1
		end

		-- Check if all symbols are used
		if usedMarkers >= #KU_RaidTargetCycleOrderIndex
		then
			local index = KU_RaidTargetCycleOrderIndex[KU_NextRaidTargetPosition]
			KU_RaidTargetGUIDs[index] = nil
			usedMarkers = usedMarkers - 1
		end

		-- Search for an available index
		local index = 0
		local next = KU_NextRaidTargetPosition
		repeat
			index = KU_RaidTargetCycleOrderIndex[next]
			next = (next ~= #KU_RaidTargetCycleOrderIndex) and (next + 1) or 1
		until KU_RaidTargetGUIDs[index] == nil
		KU_RaidTargetGUIDs[index] = guid
		SetRaidTarget(u, index)
		KU_NextRaidTargetPosition = next
	else
		KU_ChatPrint("Cannot set raid target marker on " .. tostring(unit))
	end
end

function KU_IsAttacking()
	return KU_IS_ATTACK;
end

function KU_IsAutorun()
	return KU_IS_AUTORUN;
end

function KU_GetShapeId()
	return KU_LAST_SHAPE;
end

function KU_IsMoving()
	return KU_IS_MOVING;
end

function KU_IsInCombat()
	return KU_IS_COMBAT;
end

function KU_HasShapeChanged()
	local numForms = GetNumShapeshiftForms();
	local fileName, name, isActive, isCastable;

	--[[for i=1, NUM_SHAPESHIFT_SLOTS do
		if(i <= numForms)
		then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
			if(isActive)
			then
				if(KU_LAST_SHAPE ~= i)
				then
					KU_LAST_SHAPE = i;
					KU_IdolSwap(i);
					return 1;
				else
					return 0;
				end
			end
		end
	end
	if(KU_LAST_SHAPE ~= 0)
	then
		KU_LAST_SHAPE = 0;
		KU_IdolSwap(0);
		return 1;
	end]]
	return 0;
end

function KU_PrintZones(...)
	for i = 1, select("#", ...), 1 do
		KU_ChatDebug("Zone " .. i .. " : " .. select(i, ...));
	end
end

function KU_PrintZonesNames()
	KU_ChatDebug("Zone names for continent 1");
	KU_PrintZones(GetMapZones(1));
	KU_ChatDebug("Zone names for continent 2");
	KU_PrintZones(GetMapZones(2));
end

function KU_PrintContinentMaps(num)
	if (num == nil)
	then
		KU_ChatDebug("Usage: KU_PrintContinentMaps(ContinentNumber)");
		return;
	end
	KU_ChatDebug("Zone names for continent " .. num);
	KU_PrintZones(GetMapZones(num));
end

---------------------------------------------------
-- Binding (spells/items/...)
---------------------------------------------------

function KU_CheckBindingType(type)
	if (type == "spell") then
		return true;
	elseif (type == "action") then
		return true;
	elseif (type == "item") then
		return true;
	elseif (type == "macro") then
		return true;
	elseif (type == "click") then
		return true;
	end
	KU_ChatPrint(string.format(KU_CHAT_SB_TYPE_UNKNOWN, type));
	return false;
end

function KU_CheckBindingUnit(unit)
	if (unit == "none") then
		return true;
	end
	local new_unit = string.gsub(unit, "target", "");
	local count;

	if (new_unit == "") then -- Was target
		return true;
	elseif (new_unit == "player") then
		return true;
	elseif (new_unit == "mouseover") then
		return true;
	elseif (new_unit == "focus") then
		return true;
	end
	-- Check party
	_, _, count = strfind(new_unit, "party(%d+)");
	count = tonumber(count);
	if (count and count >= 1 and count <= 4)
	then
		return true;
	end
	-- Check raid
	_, _, count = strfind(new_unit, "raid(%d+)");
	count = tonumber(count);
	if (count and count >= 1 and count <= 39)
	then
		return true;
	end
	KU_ChatPrint(string.format(KU_CHAT_SB_UNIT_UNKNOWN, unit));
	return false;
end

function KU_CheckConvertBindings()
	local binds = KU_GetToonConfig("Bindings");

	if (not binds)
	then
		binds = {};
		KU_SetToonConfig("Bindings", binds);
	end

	if (binds[1] and binds[1].key)
	then
		local new_binds = {};
		new_binds[0] = binds;
		KU_SetToonConfig("Bindings", new_binds);
	end
end

function KU_GetBindings()
	local binds = KU_GetToonConfig("Bindings");

	if (binds == nil)
	then
		binds = {};
		KU_SetToonConfig("Bindings", binds);
	end

	if (KU_ActiveTree == nil)
	then
		return nil;
	end

	local tree_binds = binds[KU_ActiveTree];
	if (tree_binds == nil)
	then
		tree_binds = {};
		if (binds[0]) -- Use 'converted/no-tree' bindings
		then
			for _, bind in ipairs(binds[0])
			do
				tinsert(tree_binds, bind);
			end
		end
		binds[KU_ActiveTree] = tree_binds;
	end
	return tree_binds;
end

function KU_GetSoulBinds(covID)
	local binds = KU_GetToonConfig("SoulBinds");

	if (type(binds) == "boolean")
	then
		binds = {};
		KU_SetToonConfig("SoulBinds", binds);
	end

	if (KU_ActiveTree == nil)
	then
		return nil;
	end

	local tree_binds = binds[KU_ActiveTree];
	if (tree_binds == nil)
	then
		tree_binds = {};
		if (binds[0]) -- Use 'converted/no-tree' bindings
		then
			for _, bind in ipairs(binds[0])
			do
				tinsert(tree_binds, bind);
			end
		end
		binds[KU_ActiveTree] = tree_binds;
	end

	local cov_binds = tree_binds[covID];
	if (cov_binds == nil)
	then
		cov_binds = {};
		if (tree_binds["Spec"]) -- Move Spec bindings if exists
		then
			cov_binds["Spec"] = tree_binds["Spec"];
			tree_binds["Spec"] = nil;
		end
		tree_binds[covID] = cov_binds;
	end

	return cov_binds;
end

-- /run for _,node in ipairs(C_Soulbinds.GetSoulbindData(C_Soulbinds.GetActiveSoulbindID()).tree.nodes) do print(node.row) end
function KU_BuildSoulBindTree(soulbindID)
	local sbID = soulbindID or C_Soulbinds.GetActiveSoulbindID()
	local soulData = C_Soulbinds.GetSoulbindData(sbID)

	local tree = {}

	for _, node in ipairs(soulData.tree.nodes)
	do
		local index = node.row + 1
		if tree[index] == nil
		then
			tree[index] = {}
		end
		tinsert(tree[index], node)
	end

	return tree
end

function KU_AddSpellBinding(action_type, action_name, action_unit, key)
	local binds = KU_GetBindings();
	-- Check if key already assigned
	if (binds)
	then
		for _, infos in ipairs(binds)
		do
			if (strlower(infos.key) == strlower(key))
			then
				KU_ChatPrint(string.format(KU_CHAT_SB_KEY_ALREADY_ASSIGNED, infos.key, infos.name));
				return;
			end
		end
	end

	-- Add spell
	tinsert(binds, { name = action_name, type = action_type, unit = action_unit, key = key });
	KU_ChatPrint(string.format(KU_CHAT_SB_SPELL_ASSIGNED, key, action_type, action_name, action_unit));

	-- Update bindings
	if (InCombatLockdown())
	then
		pendingSetupBindings = true;
	else
		KU_BindingsSetKeys();
	end
end

function KU_DelSpellBinding(index)
	local binds = KU_GetBindings();

	local infos = binds[index];
	if (infos == nil)
	then
		KU_ChatPrint(string.format(KU_CHAT_SB_SPELL_NOT_FOUND, index));
		return;
	end

	-- Remove the spell
	tremove(binds, index);
	KU_ChatPrint(string.format(KU_CHAT_SB_SPELL_REMOVED, infos.name, infos.key));

	-- Update bindings
	if (InCombatLockdown())
	then
		pendingSetupBindings = true;
	else
		KU_BindingsSetKeys();
	end
end

function KU_BindingsList()
	local binds = KU_GetBindings();

	-- Search spell (and duplicate)
	KU_ChatPrint(KU_CHAT_SB_SPELLS_LISTING_START);
	if (binds)
	then
		for i, infos in ipairs(binds)
		do
			KU_ChatPrint(string.format(KU_CHAT_SB_SPELLS_LISTING_ITEM, i, infos.name, infos.key));
		end
	end
	KU_ChatPrint(KU_CHAT_SB_SPELLS_LISTING_END);
end

function KU_ClearBindings()
	local i = 1;
	local button = _G["KU_SB" .. i];
	while (button)
	do
		ClearOverrideBindings(button);
		i = i + 1;
		button = _G["KU_SB" .. i];
	end
end

function KU_BindingsSetKeys()
	if (InCombatLockdown())
	then
		pendingSetupBindings = true;
		return;
	end

	local binds = KU_GetBindings();
	local button;

	-- Clear previous bindings
	KU_ClearBindings();
	if (binds)
	then
		for i, infos in ipairs(binds)
		do
			-- Check button existance
			button = _G["KU_SB" .. i];
			if (button == nil)
			then
				button = CreateFrame("Button", "KU_SB" .. i, UIParent, "SecureActionButtonTemplate");
				button:SetWidth(1);
				button:SetHeight(1);
				button:RegisterForClicks("AnyUp", "AnyDown");
			end
			button:SetAttribute("type", infos.type);
			if (infos.unit ~= "none") then
				button:SetAttribute("unit", infos.unit);
			else
				button:SetAttribute("unit", "");
			end
			if (infos.type == "spell") then
				button:SetAttribute("spell", infos.name);
			elseif (infos.type == "action") then
				button:SetAttribute("action", infos.name);
			elseif (infos.type == "item") then
				button:SetAttribute("item", infos.name);
			elseif (infos.type == "macro") then
				button:SetAttribute("macrotext", infos.name);
			elseif (infos.type == "click") then
				button:SetAttribute("clickbutton", infos.name);
			end
			ClearOverrideBindings(button);
			SetOverrideBindingClick(button, nil, infos.key, button:GetName());
		end
	end
end

---------------------------------------------------
-- Druid relics
---------------------------------------------------
-- SPELLEXTRAATTACKSSELF = "Vous gagnez %d attaques supplémentaires grâce à %s."; -- You gain 3 extra attacks through Thrash.
-- ou SPELLEXTRAATTACKSSELF_SINGULAR (meme chose visiblement, a check en GB/DE)
function KU_SetRelic(name)
	-- First check inventory (not equipped ?)
	if (KU_GetInventoryName(-1, 18) ~= name) -- Not equipped
	then
		for bag = NUM_BAG_FRAMES, 0, -1
		do
			for slot = GetContainerNumSlots(bag), 1, -1
			do
				local item_name = KU_GetInventoryName(bag, slot);
				if (item_name == name)
				then
					PickupContainerItem(bag, slot);
					PickupInventoryItem(18);
					return;
				end
			end
		end
	else
	end
end

function KU_IdolSwap(new_shape)
	if (KU_IsDruid == false) then return; end             -- Not a druid, returns
	if (not KU_GetToonConfig("SwapIdol")) then return; end -- No auto swap, returns
	if (new_shape == 0)                                   -- Human
	then
		if (KU_IS_COMBAT == 1)                              -- In combat, delay the swap
		then
			KU_MustSwapDefaultIdol = true;
			return;
		end
		local default_idol = KU_GetToonConfigString("DefaultIdol");
		if (default_idol ~= "")
		then
			KU_SetRelic(default_idol);
		end
		KU_MustSwapDefaultIdol = false;
	elseif (new_shape == 1) -- Bear
	then
		KU_SetRelic(KU_IDOL_BRUTALITY);
		KU_MustSwapDefaultIdol = false;
	elseif (new_shape == 3) -- Cat
	then
		KU_SetRelic(KU_IDOL_FEROCITY);
		KU_MustSwapDefaultIdol = false;
	end
end

---------------------------------------------------
-- Easy Travel and Forms
---------------------------------------------------
local STANCE_BUTTONS = {};
local STANCE_PREBUTTONS = {};
local KU_FORM_BINDINGS = {
	[KU_FORMS_BEAR] = "KIKIUTILS_SKB",
	[KU_FORMS_DIRE_BEAR] = "KIKIUTILS_SKB",
	[KU_FORMS_CAT] = "KIKIUTILS_SKC",
	[KU_FORMS_AQUA] = "KIKIUTILS_SKA",
	[KU_FORMS_TRAVEL] = "KIKIUTILS_SKT",
	[KU_FORMS_MOONKIN] = "KIKIUTILS_SKM",
	[KU_FORMS_TREE] = "KIKIUTILS_SKTOL",
	[KU_FORMS_FLIGHT] = "KIKIUTILS_SKF",
	[KU_FORMS_SWIFT_FLIGHT] = "KIKIUTILS_SKF",
};

function KU_GetCurrentMapContinent()
	local currentMapId, TOP_MOST = C_Map.GetBestMapForUnit('player'), true
	if (currentMapId)
	then
		local currentContinentInfo = MapUtil.GetMapParentInfo(currentMapId, Enum.UIMapType.Continent, TOP_MOST)
		if (currentContinentInfo ~= nil)
		then
			return currentContinentInfo.mapID, currentContinentInfo.name
		else
			return KU_GetCurrentMap() -- Special case for Nazjatar that is already a top level map
		end
	end
	return 0, ""
end

function KU_GetCurrentMap()
	local currentMapId = C_Map.GetBestMapForUnit('player')
	if (currentMapId)
	then
		local currentContinentInfo = C_Map.GetMapInfo(currentMapId)
		if (currentContinentInfo ~= nil)
		then
			return currentContinentInfo.mapID, currentContinentInfo.name
		end
	end
	return 0, ""
end

function _KU_CreateMountMacros(landmount, flymount)
	local macrotext;
	local travel_name = nil;
	local ghost = nil;
	local mount_add = "";
	local flyable = false;
	local flyable_add = ",flyable";
	local nocombat_add = ",nocombat";
	local swim_add = "";
	local roll_name = nil;
	local death_advance = nil;
	local rush_name = nil;
	local blink_name = nil;
	local hover_name = nil;
	local burning_name = nil;

	if (landmount == GetSpellInfo(75207)) -- Abyssal Searhorse
	then
		swim_add = ",swimming";
	end

	if (KU_IsDruid)
	then
		local stanceSpellID = select(4, GetShapeshiftFormInfo(3));
		travel_name = select(2, KU_HasSpell(stanceSpellID));
		mount_add = "stance:0,";
	end

	if (KU_IsMage)
	then
		blink_name = GetSpellInfo(1953) -- Blink
	end

	if (KU_IsShaman)
	then
		ghost = KU_GHOST_WOLF;
	end

	if (KU_IsMonk)
	then
		roll_name = GetSpellInfo(109132); -- Roll
	end

	if (KU_IsDK)
	then
		death_advance = GetSpellInfo(48265) -- Death's Advance
	end

	if (KU_IsDH)
	then
		if KU_ActiveTree == 1
		then
			rush_name = GetSpellInfo(195072); -- Fel Rush
		end
	end

	-- Fix for the macro combat bug (/use [nocombat] not always trigger when out of combat when having a pet)
	if KU_IsWarlock
	then
		nocombat_add = "";
	end

	if KU_IsEvoker
	then
		hover_name = GetSpellInfo(358267) -- Hover
	end

	if KU_IsWarlock
	then
		burning_name = GetSpellInfo(111400) -- Burning Rush
	end

	-- OOC Macro
	macrotext = "";
	--[[if (C_Covenants.GetActiveCovenantID() == 3)
	then
		local numForms = GetNumShapeshiftForms()
		macrotext = macrotext ..
				"/cast [stance:" ..
				tostring(numForms + 1) ..
				"]" .. GetSpellInfo(324701) .. "\n/stopmacro [stance:" .. tostring(numForms + 1) .. "]\n"; -- Flicker
	end]]

	if (landmount)
	then
		if (flymount)
		then
			macrotext = macrotext ..
					"/use [" ..
					mount_add ..
					"nomounted,noswimming" ..
					nocombat_add ..
					flyable_add .. "]" .. flymount .. ";[" .. mount_add .. "nomounted" .. nocombat_add ..
					swim_add .. "]" .. landmount .. "\n";
		else
			macrotext = macrotext .. "/use [" .. mount_add .. "nomounted,noswimming" .. nocombat_add .. "]" .. landmount ..
					"\n";
		end
	end
	if (travel_name)
	then
		macrotext = macrotext .. "/cast ";
		if (travel_name) -- Have Flight form
		then
			macrotext = macrotext .. "[nomounted,stance:0,nocombat" .. flyable_add .. "]" .. travel_name .. ";";
		end
		macrotext = macrotext .. "[nomounted,stance:0]" .. travel_name;
		macrotext = macrotext .. "\n/cancelform [nostance:0]\n";
	end
	if (roll_name)
	then
		macrotext = macrotext .. "/cast [nomounted]" .. roll_name .. "\n";
	end
	if (blink_name)
	then
		macrotext = macrotext .. "/cast [nomounted]" .. blink_name .. "\n";
	end
	if (death_advance)
	then
		macrotext = macrotext .. "/cast [nomounted]" .. death_advance .. "\n";
	end
	if (rush_name)
	then
		macrotext = macrotext .. "/cast [nomounted]" .. rush_name .. "\n";
	end
	if (hover_name)
	then
		macrotext = macrotext .. "/cast [nomounted]" .. hover_name .. "\n";
	end
	if (burning_name)
	then
		macrotext = "/cancelaura " .. burning_name .. "\n" .. macrotext .. "/cast [nomounted]" .. burning_name .. "\n";
	end
	if (ghost)
	then
		if (landmount) -- Have a mount, cast ghost only in combat
		then
			macrotext = macrotext .. "/cast [nomounted,stance:0,combat]" ..
					ghost .. "\n" .. "/cancelaura [stance:1]" .. ghost .. "\n";
		else
			macrotext = macrotext .. "/cast [nomounted,stance:0]" .. ghost .. "\n" .. "/cancelaura [stance:1]" .. ghost .. "\n";
		end
	elseif (KU_IsPaladin)
	then
		local spd_of_light = GetSpellInfo(KU_SPEED_OF_LIGHT_SPELLID);
		if (spd_of_light)
		then
			macrotext = macrotext .. "/cast [nomounted]" .. spd_of_light .. "\n";
		end
		local has_steed, steed_name = KU_HasSpell(KU_DIVINE_STEED_SPELLID); -- Divine Steed
		if (has_steed)
		then
			macrotext = macrotext .. "/cast [nomounted]" .. steed_name .. "\n";
		end
	end
	macrotext = macrotext .. "/dismount [mounted]\n/leavevehicle [canexitvehicle]";
	return macrotext;
end

function KU_SetupMountMacros()
	if (KU_GetCurrentMap() == 0)
	then
		pendingSetupMacro = true
		return
	end

	local macrotext;

	--SetMapToCurrentZone(); -- Force a Map zone change, so that the GetCurrentMapContinent() won't return something incorrect

	macrotext = _KU_CreateMountMacros(KU_GetMountToUse());
	KU_ETB:SetAttribute("macrotext", macrotext);

	macrotext = _KU_CreateMountMacros(KU_GetMountToUse(true));
	KU_ETBN:SetAttribute("macrotext", macrotext);

	KU_HasUseMount = false;
end

function KikiUtils_RefreshStance()
	-- Pour etendre le code des stances du druide aux paladins (aura) et aux wars (postures), il suffirait peut etre de virer le "if isdruid" (et changer la fonction GetNumShapeshiftForms??)
	if (KU_IsDruid)
	then
		-- Create a list of stances
		local STANCE_LIST = {};
		for i = 1, GetNumShapeshiftForms()
		do
			local stanceSpellID = select(4, GetShapeshiftFormInfo(i));
			STANCE_LIST[i] = select(2, KU_HasSpell(stanceSpellID));
		end

		for i = 0, #STANCE_LIST
		do
			local b = STANCE_BUTTONS[i];
			if (not b)
			then
				b = CreateFrame("Button", "KU_SSEB" .. i, UIParent, "SecureActionButtonTemplate");
				b:SetWidth(1);
				b:SetHeight(1);
				b:RegisterForClicks("AnyUp", "AnyDown");
				b:SetAttribute("type", "macro");
				STANCE_BUTTONS[i] = b;
			end
			local key = nil;
			local key2 = nil;
			local binding_name = KU_FORM_BINDINGS[STANCE_LIST[i]];
			if (binding_name)
			then
				key, key2 = GetBindingKey(binding_name);
			end
			ClearOverrideBindings(b);
			if (key) then
				SetOverrideBindingClick(b, false, key, b:GetName());
			end
			if (key2) then
				SetOverrideBindingClick(b, false, key2, b:GetName());
			end

			if (i ~= 0)
			then
				if (STANCE_LIST[i] == KU_FORMS_CAT)
				then
					b:SetAttribute("macrotext",
						"/cast [nostealth,nocombat,stance:" ..
						i .. "]" .. KU_PROWL .. "; [stealth,stance:" .. i .. "]" .. KU_PROWL ..
						"; [nostance:" .. i .. "]" .. STANCE_LIST[i]);
				else
					b:SetAttribute("macrotext", "/cancelform\n/cast " .. STANCE_LIST[i]);
				end
			else
				b:SetAttribute("macrotext", "/cancelform");
			end
		end -- For
	end -- IsDruid

	if (KU_IsShaman)
	then
		local b = STANCE_BUTTONS[1];
		if (not b)
		then
			b = CreateFrame("Button", "KU_SSEB1", UIParent, "SecureActionButtonTemplate");
			b:SetWidth(1);
			b:SetHeight(1);
			b:RegisterForClicks("AnyUp", "AnyDown");
			STANCE_BUTTONS[1] = b;
		end
		ClearOverrideBindings(b);
		local key, key2 = GetBindingKey("KIKIUTILS_GW");
		if (key) then
			SetOverrideBindingClick(b, false, key, b:GetName());
		end
		if (key2) then
			SetOverrideBindingClick(b, false, key2, b:GetName());
		end
		b:SetAttribute("type", "spell");
		b:SetAttribute("spell", KU_GHOST_WOLF);
	end

	-- Create special button for easy travel
	if (not KU_ETB)
	then
		CreateFrame("Button", "KU_ETB", UIParent, "SecureActionButtonTemplate");
		KU_ETB:SetWidth(1);
		KU_ETB:SetHeight(1);
		KU_ETB:RegisterForClicks("AnyUp", "AnyDown");
		KU_ETB:SetAttribute("type", "macro");
		CreateFrame("Button", "KU_ETBN", UIParent, "SecureActionButtonTemplate");
		KU_ETBN:SetWidth(1);
		KU_ETBN:SetHeight(1);
		KU_ETBN:RegisterForClicks("AnyUp", "AnyDown");
		KU_ETBN:SetAttribute("type", "macro");
	end
	-- Set key overriding for easy travel
	ClearOverrideBindings(KU_ETB);
	local key, key2 = GetBindingKey("KIKIUTILS_SK");
	if (key) then
		SetOverrideBindingClick(KU_ETB, false, key, KU_ETB:GetName());
	end
	if (key2) then
		SetOverrideBindingClick(KU_ETB, false, key2, KU_ETB:GetName());
	end
	-- Set key overriding for easy travel 'normal'
	ClearOverrideBindings(KU_ETBN);
	local key, key2 = GetBindingKey("KIKIUTILS_SKN");
	if (key) then
		SetOverrideBindingClick(KU_ETBN, false, key, KU_ETBN:GetName());
	end
	if (key2) then
		SetOverrideBindingClick(KU_ETBN, false, key2, KU_ETBN:GetName());
	end

	-- Refresh mount macro
	KU_SetupMountMacros();
end

---------------------------------------------------
-- Force Attack or AutoShot Secure Button
---------------------------------------------------
function KU_SetupForceAttackMacro()
	local shot = KU_GetToonConfigString("ShotName");

	local macrotext = "/startattack\n";
	if (shot ~= "")
	then
		macrotext = macrotext .. "/cast [exists]" .. shot;
	end
	KU_FAB:SetAttribute("macrotext", macrotext);
end

local function KikiUtils_ForceAttack_Init()
	-- Create special button for easy travel
	if (not KU_FAB)
	then
		CreateFrame("Button", "KU_FAB", UIParent, "SecureActionButtonTemplate");
		KU_FAB:SetWidth(1);
		KU_FAB:SetHeight(1);
		KU_FAB:RegisterForClicks("AnyUp", "AnyDown");
	end
	-- Set key overriding for force-attack-or-shot
	ClearOverrideBindings(KU_FAB);
	local key, key2 = GetBindingKey("KIKIUTILS_ATTACK");
	if (key) then
		SetOverrideBindingClick(KU_FAB, false, key, "KU_FAB");
	end
	if (key2) then
		SetOverrideBindingClick(KU_FAB, false, key2, "KU_FAB");
	end
	KU_FAB:SetAttribute("type", "macro");
	KU_SetupForceAttackMacro();
end

local function KikiUtils_SetupCureButton(button, name, key_name, spellID)
	-- Create special button to handle curing
	if (not button)
	then
		button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate");
		button:SetWidth(1);
		button:SetHeight(1);
		button:RegisterForClicks("AnyUp", "AnyDown");
	end
	ClearOverrideBindings(button);
	-- Set key overriding
	local key, key2 = GetBindingKey(key_name);
	if (key) then
		SetOverrideBindingClick(button, false, key, button:GetName());
	end
	if (key2) then
		SetOverrideBindingClick(button, false, key2, button:GetName());
	end
	if (type(spellID) == "number")
	then
		button:SetAttribute("type", "spell");
		button:SetAttribute("spell", GetSpellInfo(spellID));
	else
		button:SetAttribute("type", "macro");
		button:SetAttribute("macrotext", spellID);
	end
end

local function KikiUtils_SetupCure()
	local _, cls = UnitClass("player");
	if (cls == "SHAMAN")
	then
		local dispelSpell = GetSpellInfo(51886) -- Cleanse Spirit (Curse/Magic)
		local purgeSpell = GetSpellInfo(370)  -- Purge
		local macroText = "/cast [harm] " .. purgeSpell .. " ; " .. dispelSpell;
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
	elseif (cls == "HUNTER")
	then
		--local dispelSpell = GetSpellInfo(51886) -- Cleanse Spirit (Curse/Magic)
		local tranqSpell = GetSpellInfo(19801) -- Tranquilizing Shot
		--local macroText = "/cast [harm] "..tranqSpell.." ; "..dispelSpell;
		local macroText = "/cast [harm] " .. tranqSpell
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
	elseif (cls == "DRUID")
	then
		local healSpell = GetSpellInfo(88423) -- Nature's Cure
		local otherSpell = GetSpellInfo(2782) -- Remove Corruption
		local sootheSpell = GetSpellInfo(2908) -- Soothe
		local macroText = "/cast [harm] " .. sootheSpell .. " ; [spec:4] " .. healSpell .. " ; " .. otherSpell;
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
	elseif (cls == "MAGE")
	then
		local dispelSpell = GetSpellInfo(475) -- Remove Curse
		local stealSpell = GetSpellInfo(30449) -- Spellsteal
		local macroText = "/cast [harm] " .. stealSpell .. " ; " .. dispelSpell;
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
	elseif (cls == "PALADIN")
	then
		local holySpell = GetSpellInfo(4987)  -- Cleanse
		local otherSpell = GetSpellInfo(213644) -- Cleanse Toxins
		local macroText = "/cast [spec:1] " .. holySpell .. " ; " .. otherSpell;
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
	elseif (cls == "MONK")
	then
		local dispelSpell = GetSpellInfo(115450) -- Detox (Poison/Disease)
		local otherSpell = GetSpellInfo(116095) -- Disable
		local macroText = "/cast [spec:3,harm] " .. otherSpell .. " ; " .. dispelSpell;
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
		--KikiUtils_SetupCureButton(KU_DB,"KU_DB","KIKIUTILS_DISPEL",115450);
	elseif (cls == "DEMONHUNTER")
	then
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", 278326); -- Consume Magic
	elseif (cls == "PRIEST")
	then
		local healSpell = GetSpellInfo(527)   -- Purify
		local otherSpell = GetSpellInfo(213634) -- Purify Disease
		local offSpell = GetSpellInfo(528)    -- Dispel Magic
		local macroText = "/cast [harm] " .. offSpell .. " ; [spec:3] " .. otherSpell .. " ; " .. healSpell;
		KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText);
	elseif (cls == "EVOKER")
	then
		local expungeSpell = GetSpellInfo(365585) -- Expunge
		local unravelSpell = GetSpellInfo(368432) -- Unravel
		local macroText
		if unravelSpell and expungeSpell then
			macroText = "/cast [harm] " .. unravelSpell .. " ; " .. expungeSpell
		elseif expungeSpell then
			macroText = "/cast " .. expungeSpell
		end
		if macroText then
			KikiUtils_SetupCureButton(KU_DB, "KU_DB", "KIKIUTILS_DISPEL", macroText)
		end
	end
end

local function KikiUtils_SetupRaidTarget()
	-- Create special button to handle curing
	if (not KU_RTB)
	then
		KU_RTB = CreateFrame("Button", "KU_RTB", UIParent, "SecureActionButtonTemplate");
		KU_RTB:SetWidth(1);
		KU_RTB:SetHeight(1);
		KU_RTB:RegisterForClicks("AnyUp", "AnyDown");
	end
	ClearOverrideBindings(KU_RTB);
	-- Set key overriding
	local key, key2 = GetBindingKey("KIKIUTILS_SET_RAID_TARGET");
	if (key) then
		SetOverrideBindingClick(KU_RTB, false, key, KU_RTB:GetName());
	end
	if (key2) then
		SetOverrideBindingClick(KU_RTB, false, key2, KU_RTB:GetName());
	end
	KU_RTB:SetAttribute("type", "macro");
	KU_RTB:SetAttribute("macrotext", "/script SetRaidTarget(\"target\"," .. KU_GetToonConfigInt("RaidTarget", 0) .. ")");
end

function KU_SetRaidTarget()
	SetRaidTarget("target", KU_GetToonConfigInt("RaidTarget", 0));
end

---------------------------------------------------
-- Secure Button Configuration Frame
---------------------------------------------------

local evFrame = CreateFrame("Frame");
evFrame:RegisterEvent("SPELLS_CHANGED");
evFrame:RegisterEvent("VARIABLES_LOADED");
evFrame:RegisterEvent("UPDATE_BINDINGS");
evFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
evFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

-- The pending change flag is required in case the player gets a new
-- form in combat, we want to delay the actual application of the
-- change until regen is enabled (i.e. out of combat)
local pendingChange = false;
local function evFrameOnEvent(self, event, ...)
	if (event == "PLAYER_REGEN_ENABLED")
	then
		if (pendingChange)
		then
			pendingChange = false;
			KU_SetupMouselook();
			KikiUtils_RefreshStance();
			KikiUtils_ForceAttack_Init();
			KikiUtils_SetupCure();
			--KikiUtils_SetupRaidTarget();
		end
	else
		if (KU_NeedInitToonSpecific)
		then
			KikiUtils_StartInitVars();
		end
		pendingChange = true;
		if (not InCombatLockdown())
		then
			pendingChange = false;
			KU_SetupMouselook();
			KikiUtils_RefreshStance();
			KikiUtils_ForceAttack_Init();
			KikiUtils_SetupCure();
			--KikiUtils_SetupRaidTarget();
		end
	end
end
local function evFrameOnUpdate(self, elapsed)
	KU_CurrentTime = KU_CurrentTime + elapsed
	KU_CheckApplySoulBind()
	KU_CheckApplySoulBindBranches()
	KU_CheckApplyOmnium()
end
evFrame:SetScript("OnEvent", evFrameOnEvent);
evFrame:SetScript("OnUpdate", evFrameOnUpdate);
------- Thanks to Iriel and DruidBar for the code

function KU_CapDisplayOfNumericValue(value)
	local strLen = strlen(value);
	local retString = value;
	if (strLen > 8) then
		retString = string.sub(value, 1, -7) .. "M";
	elseif (strLen > 5) then
		retString = string.sub(value, 1, -4) .. "K";
	end
	return retString;
end

function KU_TextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
	local fname = statusFrame:GetName();
	if (fname and (strfind(fname, "FrameHealthBar") or strfind(fname, "FrameManaBar")) and KU_GetToonConfig("ShowPercent"))
	then
		if ((tonumber(valueMax) ~= valueMax or valueMax > 0) and not (statusFrame.pauseUpdates)) then
			local valueDisplay = value;
			local valueMaxDisplay = valueMax;
			valueDisplay = KU_CapDisplayOfNumericValue(value);
			valueMaxDisplay = KU_CapDisplayOfNumericValue(valueMax);

			local textDisplay = GetCVar("statusTextDisplay");
			if (textDisplay ~= "NUMERIC" or statusFrame.showPercentage) or (value == 0 and statusFrame.zeroText) then
				return;
			else
				statusFrame.isZero = nil;
				local percent = tostring(math.ceil((value / valueMax) * 100)) .. "%";
				if (statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable))) then
					textString:SetText(statusFrame.prefix .. " " .. valueDisplay .. "/" .. valueMaxDisplay .. " (" .. percent ..
						")");
				else
					textString:SetText(valueDisplay .. " / " .. valueMaxDisplay .. " (" .. percent .. ")");
				end
			end
		end
	end
end

--hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",KU_TextStatusBar_UpdateTextStringWithValues);

function KU_PrintPoints(frame)
	if (frame == nil or frame.GetNumPoints == nil or frame.GetPoint == nil)
	then
		KU_ChatPrint("Passed parameter is not a frame");
		return;
	end
	local num = frame:GetNumPoints();
	KU_ChatPrint("Points for " .. frame:GetName() .. " (" .. num .. "):");
	for i = 1, num
	do
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(i);
		KU_ChatPrint(" " ..
			i ..
			"/" ..
			num ..
			": " ..
			tostring(point) ..
			" - " .. tostring(relativeTo) .. " - " .. tostring(relativePoint) .. " - " .. tostring(xOfs) .. " - " ..
			tostring(yOfs));
	end
end

function KU_HasMount(spellID)
	local mounts = C_MountJournal.GetMountIDs()
	for _, id in ipairs(mounts)
	do
		local name, sID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID =
				C_MountJournal.GetMountInfoByID(id)
		-- TODO: Check faction
		if sID == spellID
		then
			return isCollected, name
		end
	end
	return false, name
end

function KU_HasSpell(spellID)
	local name = GetSpellInfo(spellID); -- Always returns info if spellID is valid
	if (name)
	then
		local n = GetSpellInfo(name); -- Returns info only if spell is in your spellbook
		if (n and name == n)
		then
			return true, n;
		end
	end
	return false, nil;
end

function KU_HasFML()
	return KU_HasSpell(90267);
end

function KU_HasCWF()
	return KU_HasSpell(54197);
end

function KU_HasDPF() -- Draenor Pathfinder
	return KU_HasSpell(191645);
end

function KU_HasBIPF() -- Broken Isles Pathfinder
	return KU_HasSpell(233368);
end

-------------------------------------------------------------------
-- API table for Options Panel
-------------------------------------------------------------------
KU_API = {
	SetToonConfig = KU_SetToonConfig,
	GetToonConfig = KU_GetToonConfig,
	GetToonConfigString = KU_GetToonConfigString,
	GetToonConfigInt = KU_GetToonConfigInt,
	ChatPrint = KU_ChatPrint,
	ApplyConfigChange = function(name)
		if name == "EnableClock" then
			KU_SetClock(false)
		elseif name == "LockClock" then
			KU_SetClockLock(false)
		elseif name == "HideSpellActivationOverlay" then
			KU_SetNewSpellActivationOverlay(false)
		elseif name == "ShowPercent" then
			KU_SetShowPercent(false)
		elseif name == "DebugMode" then
			KU_SetNewDebugMode(false)
		elseif name == "LossOfControl" then
			KU_SetNewLossOfControl(false)
		elseif name == "ScaleBags" or name == "AdjustBags" then
			KU_updateContainerFrameAnchors()
		end
	end,
}

function KU_BuyItem(itemID, quantity)
	local itemName = GetItemInfo(itemID);
	if (itemName == nil)
	then
		KU_ChatPrint("Unknown Item of ID " .. itemID);
		return;
	end
	local numItems = GetMerchantNumItems();
	for i = 1, numItems
	do
		if (GetMerchantItemInfo(i) == itemName)
		then
			BuyMerchantItem(i, quantity);
			KU_ChatPrint("Bought Item of ID " .. itemID);
			return;
		end
	end
	KU_ChatPrint("Item of ID " .. itemID .. " not found in merchant window");
end
