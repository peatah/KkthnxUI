local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local CombatLogClearEntries = CombatLogClearEntries
local DoReadyCheck = DoReadyCheck
local EnableAddOn, DisableAllAddOns = EnableAddOn, DisableAllAddOns
local GetAddOnInfo = GetAddOnInfo
local GetCurrentResolution = GetCurrentResolution
local GetMouseFocus = GetMouseFocus
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetRaidRosterInfo = GetRaidRosterInfo
local GetScreenResolutions = GetScreenResolutions
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local IsInInstance = IsInInstance
local math_ceil = math.ceil
local math_floor = math.floor
local print, tostring, select = print, tostring, select
local ReloadUI = ReloadUI
local RestartGx = RestartGx
local SelectQuestLogEntry = SelectQuestLogEntry
local SetAbandonQuest = SetAbandonQuest
local SetCVar = SetCVar
local string_format, string_lower = string.format, string.lower
local ToggleHelpFrame = ToggleHelpFrame
local UnitInRaid = UnitInRaid

-- Fixes the issue when the dialog to release spirit does not come up.
SlashCmdList.RELEASE = function() RetrieveCorpse() RepopMe() end
_G.SLASH_RELEASE1 = "/release"

-- Ready check
SlashCmdList.RCSLASH = function() DoReadyCheck() end
_G.SLASH_RCSLASH1 = "/rc"

-- Help frame.
SlashCmdList.TICKET = function() ToggleHelpFrame() end
_G.SLASH_TICKET1 = "/gm"

-- Fix The CombatLog.
SlashCmdList.CLEARCOMBAT = function() CombatLogClearEntries() K.Print("|cffff0000Combatlog has been fixed.|r") end
_G.SLASH_CLEARCOMBAT1 = "/clearcombat"
_G.SLASH_CLEARCOMBAT2 = "/clfix"

-- Here we can restart wow's engine. could be use for sound issues and more.
SlashCmdList.GFXENGINE = function() RestartGx() end
_G.SLASH_GFXENGINE1 = "/restartgfx"
_G.SLASH_GFXENGINE2 = "/fixgfx"

-- Clear all quests in questlog
SlashCmdList.CLEARQUESTS = function()
	for i = 1, GetNumQuestLogEntries() do SelectQuestLogEntry(i) SetAbandonQuest() AbandonQuest() end
end
_G.SLASH_CLEARQUESTS1 = "/clearquests"
_G.SLASH_CLEARQUESTS2 = "/clquests"

-- KKTHNXUI help commands
SlashCmdList.UIHELP = function()
	for i, v in ipairs(L.SlashCommand.Help) do print("|cffffff00"..("%s"):format(tostring(v)).."|r") end
end
_G.SLASH_UIHELP1 = "/uicommands"
_G.SLASH_UIHELP2 = "/helpui"

_G.SLASH_SCALE1 = "/uiscale"
SlashCmdList["SCALE"] = function()
	SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
end

-- Disband party or raid (by Monolit)
function _G.DisbandRaidGroup()
	if InCombatLockdown() then return end
	if UnitInRaid("player") then
		SendChatMessage(L.Info.Disabnd, "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= K.Name then
				UninviteUnit(name)
			end
		end
	else
		SendChatMessage(L.Info.Disband, "PARTY")
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetNumGroupMembers(i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

StaticPopupDialogs.DISBAND_RAID = {
	text = L.Popup.DisbandRaid,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = _G.DisbandRaidGroup,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

SlashCmdList.GROUPDISBAND = function()
	StaticPopup_Show("DISBAND_RAID")
end
_G.SLASH_GROUPDISBAND1 = "/rd"

-- Enable lua error by command
function SlashCmdList.LUAERROR(msg)
	msg = string_lower(msg)
	if(msg == "on") then
		DisableAllAddOns()
		EnableAddOn("KkthnxUI")
		EnableAddOn("KkthnxUI_Config")
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif(msg == "off") then
		SetCVar("scriptErrors", 0)
		K.Print("|cffff0000Lua errors off.|r")
	else
		K.Print("|cffff0000/luaerror on - /luaerror off|r")
	end
end
_G.SLASH_LUAERROR1 = "/luaerror"

-- Convert party to raid
SlashCmdList.PARTYTORAID = function()
	if GetNumGroupMembers() > 0 then
		if UnitInRaid("player") and (UnitIsGroupLeader("player")) then
			ConvertToParty()
		elseif UnitInParty("player") and (UnitIsGroupLeader("player")) then
			ConvertToRaid()
		end
	else
		print("|cffff0000"..ERR_NOT_IN_GROUP.."|r")
	end
end
_G.SLASH_PARTYTORAID1 = "/toraid"
_G.SLASH_PARTYTORAID2 = "/toparty"
_G.SLASH_PARTYTORAID3 = "/convert"

-- Instance teleport
SlashCmdList.INSTTELEPORT = function()
	local inInstance = IsInInstance()
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
end
_G.SLASH_INSTTELEPORT1 = "/teleport"

-- Spec switching(by Monolit)
SlashCmdList.SPEC = function(spec)
	if K.Level >= SHOW_TALENT_LEVEL then
		if GetSpecialization() ~= tonumber(spec) then
			SetSpecialization(spec)
		end
	else
		print("|cffff0000"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL).."|r")
	end
end
_G.SLASH_SPEC1 = "/ss"
_G.SLASH_SPEC2 = "/spec"

-- Deadly boss mods testing.
SlashCmdList.DBMTEST = function() if K.CheckAddOn("DBM-Core") then DBM:DemoMode() end end
_G.SLASH_DBMTEST1 = "/dbmtest"

-- Clear chat
SlashCmdList.CLEARCHAT = function(cmd)
	cmd = cmd and strtrim(string_lower(cmd))
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		if f:IsVisible() or cmd == "all" then
			f:Clear()
		end
	end
end
_G.SLASH_CLEARCHAT1 = "/cc"
_G.SLASH_CLEARCHAT2 = "/clearchat"

-- Test blizzard alert frames
SlashCmdList.TEST_ACHIEVEMENT = function()
	PlaySound("LFG_Rewards")
	if not AchievementFrame then
		AchievementFrame_LoadUI()
	end
	AchievementAlertSystem:AddAlert(112)
	CriteriaAlertSystem:AddAlert(9023, "Doing great!")
	GuildChallengeAlertSystem:AddAlert(3, 2, 5)
	InvasionAlertSystem:AddAlert(678, "Legion", true, 1, 1)
	GarrisonShipFollowerAlertSystem:AddAlert(592, "Ship", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
	GarrisonBuildingAlertSystem:AddAlert("Barracks")
	LegendaryItemAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832:0:0:0:0:0:0:0:0:0:0\124h[Brutality Blade]\124h\124r")
	LootAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 100, 2, false, false, 0, false, false)
	LootUpgradeAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, nil, nil, false)
	MoneyWonAlertSystem:AddAlert(815)
	StorePurchaseAlertSystem:AddAlert("\124cffa335ee\124Hitem:180545::::::::::\124h[Mystic Runesaber]\124h\124r", "", "", 214)
	DigsiteCompleteAlertSystem:AddAlert(1)
	NewRecipeLearnedAlertSystem:AddAlert(204)
end
_G.SLASH_TEST_ACHIEVEMENT1 = "/testa"

-- Test Blizzard Extra Action Button
SlashCmdList.TEST_EXTRABUTTON = function()
	if ExtraActionBarFrame:IsShown() then
		ExtraActionBarFrame:Hide()
	else
		ExtraActionBarFrame:Show()
		ExtraActionBarFrame:SetAlpha(1)
		ExtraActionButton1:Show()
		ExtraActionButton1:SetAlpha(1)
		ExtraActionButton1.icon:SetTexture("Interface\\Icons\\spell_deathknight_breathofsindragosa")
		ExtraActionButton1.icon:Show()
		ExtraActionButton1.icon:SetAlpha(1)
	end
end
_G.SLASH_TEST_EXTRABUTTON1 = "/teb"

-- Grid on screen
local Grid
local BoxSize = 32

local function Grid_Show()
	if not Grid then
		_G.GridCreate()
	elseif Grid.BoxSize ~= BoxSize then
		Grid:Hide()
		_G.GridCreate()
	else
		Grid:Show()
	end
end

local function GridHide()
	if Grid then
		Grid:Hide()
	end
end

local isAligning = false
_G.SLASH_TOGGLE_GRID1 = "/align"
SlashCmdList.TOGGLE_GRID = function(arg)
	if isAligning then
		GridHide()
		isAligning = false
	else
		BoxSize = (math_ceil((tonumber(arg) or BoxSize) / 32) * 32)
		if BoxSize > 256 then BoxSize = 256 end
		Grid_Show()
		isAligning = true
	end
end

function _G.GridCreate()
	Grid = CreateFrame("Frame", nil, UIParent)
	Grid.BoxSize = BoxSize
	Grid:SetAllPoints(UIParent)

	local Size = K.Scale(2)
	local Width = GetScreenWidth()
	local Ratio = Width / GetScreenHeight()
	local Height = GetScreenHeight() * Ratio

	local WStep = Width / BoxSize
	local HStep = Height / BoxSize

	for i = 0, BoxSize do
		local Tx = Grid:CreateTexture(nil, "BACKGROUND")
		if i == BoxSize / 2 then
			Tx:SetColorTexture(1, 0, 0, 0.5)
		else
			Tx:SetColorTexture(0, 0, 0, 0.5)
		end
		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", i * WStep - (Size / 2), 0)
		Tx:SetPoint("BOTTOMRIGHT", Grid, "BOTTOMLEFT", i * WStep + (Size / 2), 0)
	end
	Height = GetScreenHeight()

	do
		local Tx = Grid:CreateTexture(nil, "BACKGROUND")
		Tx:SetColorTexture(1, 0, 0, 0.5)
		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", 0, -(Height / 2) + (Size / 2))
		Tx:SetPoint("BOTTOMRIGHT", Grid, "TOPRIGHT", 0, -(Height / 2 + Size / 2))
	end

	for i = 1, math_floor((Height / 2) / HStep) do
		local Tx = Grid:CreateTexture(nil, "BACKGROUND")
		Tx:SetColorTexture(0, 0, 0, 0.5)

		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", 0, -(Height / 2 + i * HStep) + (Size / 2))
		Tx:SetPoint("BOTTOMRIGHT", Grid, "TOPRIGHT", 0, -(Height / 2 + i * HStep + Size / 2))

		Tx = Grid:CreateTexture(nil, "BACKGROUND")
		Tx:SetColorTexture(0, 0, 0, 0.5)

		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", 0, -(Height / 2 - i * HStep) + (Size / 2))
		Tx:SetPoint("BOTTOMRIGHT", Grid, "TOPRIGHT", 0, -(Height / 2 - i * HStep + Size / 2))
	end
end

SlashCmdList.TEST_UI = function(msg)
	if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	if C.PulseCD.Enable == true then
		SlashCmdList.PulseCD()
	end
	if C.Unitframe.Enable == true then
		SlashCmdList.TEST_UF()
	end
	if C.Announcements.PullCountdown == true then
		SlashCmdList.PULLCOUNTDOWN()
	end
	if C.Loot.GroupLoot == true then
		SlashCmdList.TESTROLL()
	end
	SlashCmdList.DBMTEST()
	SlashCmdList.TEST_EXTRABUTTON()
	SlashCmdList.TEST_ACHIEVEMENT()
	SlashCmdList.TOGGLE_GRID()
end
_G.SLASH_TEST_UI1 = "/testui"

-- Reduce video settings to optimize performance
local function BoostUI()
	SetCVar("SSAO", 0)
	SetCVar("ShadowTextureSize", 1024)
	SetCVar("environmentDetail", 60)
	SetCVar("farclip", 500)
	SetCVar("groundeffectdensity", 16)
	SetCVar("groundeffectdist", 1)
	SetCVar("hwPCF", 1)
	SetCVar("hwPCF", 1)
	SetCVar("reflectionMode", 0)
	SetCVar("shadowMode", 0)
	SetCVar("showfootprintparticles", 0)
	SetCVar("skycloudlod", 1)
	SetCVar("timingmethod", 1)
	SetCVar("waterDetail", 0)
	SetCVar("weatherDensity", 0)
	RestartGx()
end

-- Add a warning so we do not piss people off.
StaticPopupDialogs.BOOST_UI = {
	text = L.Popup.BoostUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = BoostUI,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

_G.SLASH_BOOSTUI1 = "/boostfps"
_G.SLASH_BOOSTUI2 = "/boostui"
SlashCmdList.BOOSTUI = function() StaticPopup_Show("BOOST_UI") end