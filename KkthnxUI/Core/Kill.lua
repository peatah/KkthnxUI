local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local type = type

-- Wow API
local CompactRaidFrameManager_UpdateShown = _G.CompactRaidFrameManager_UpdateShown
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local SetCVar = _G.SetCVar
local SetCVarBitfield = _G.SetCVarBitfield
local StaticPopup_Show = _G.StaticPopup_Show
local UnitAffectingCombat = _G.UnitAffectingCombat
local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local GetCVarBool = _G.GetCVarBool
local UIParent = _G.UIParent

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: addon, PetFrame_Update, PlayerFrame_AnimateOut
-- GLOBALS: Advanced_UIScaleSlider, Advanced_UseUIScale, BagHelpBox, CollectionsMicroButtonAlert, EJMicroButtonAlert
-- GLOBALS: HelpOpenTicketButtonTutorial, HelpPlate, HelpPlateTooltip, PremadeGroupsPvETutorialAlert, ReagentBankHelpBox
-- GLOBALS: InterfaceOptionsActionBarsPanelLockActionBars, InterfaceOptionsActionBarsPanelPickupActionKeyDropDown
-- GLOBALS: InterfaceOptionsActionBarsPanelRight, InterfaceOptionsActionBarsPanelRightTwo, InterfaceOptionsActionBarsPanelAlwaysShowActionBars
-- GLOBALS: InterfaceOptionsCombatPanelTargetOfTarget, InterfaceOptionsActionBarsPanelCountdownCooldowns, PlayerFrame
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesMakeLarger, InterfaceOptionsDisplayPanelRotateMinimap
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy, InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton
-- GLOBALS: LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, LE_FRAME_TUTORIAL_PET_JOURNAL, LE_FRAME_TUTORIAL_GARRISON_BUILDING
-- GLOBALS: PlayerFrame_AnimFinished, PlayerFrame_ToPlayerArt, PlayerFrame_ToVehicleArt, CompactRaidFrameManager
-- GLOBALS: SpellBookFrameTutorialButton, TalentMicroButtonAlert, TutorialFrameAlertButton, WorldMapFrameTutorialButton
-- GLOBALS: UIFrameHider, CompactUnitFrameProfiles, HidePartyFrame, ShowPartyFrame

-- Kill all stuff on default UI that we don"t need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("ADDON_LOADED")
DisableBlizzard:SetScript("OnEvent", function(self, event, addon)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if addon == "Blizzard_AchievementUI" then
		if C.Tooltip.Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	if C.Raidframe.Enable then
		if not CompactRaidFrameManager_UpdateShown then
			StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
		else
			K.KillMenuPanel(10, "InterfaceOptionsFrameCategoriesButton")

			if CompactRaidFrameManager then
				CompactRaidFrameManager:SetParent(UIFrameHider)
			end

			if CompactUnitFrameProfiles then
				CompactUnitFrameProfiles:UnregisterAllEvents()
			end
		end
	end

	if C.Unitframe.Enable then
		function _G.PetFrame_Update() end
		function _G.PlayerFrame_AnimateOut() end
		function _G.PlayerFrame_AnimFinished() end
		function _G.PlayerFrame_ToPlayerArt() end
		function _G.PlayerFrame_ToVehicleArt() end

		for i = 1, MAX_BOSS_FRAMES do
			local Boss = _G["Boss"..i.."TargetFrame"]
			local Health = _G["Boss"..i.."TargetFrame".."HealthBar"]
			local Power = _G["Boss"..i.."TargetFrame".."ManaBar"]

			Boss:UnregisterAllEvents()
			Boss.Show = K.Noop
			Boss:Hide()

			Health:UnregisterAllEvents()
			Power:UnregisterAllEvents()
		end

		for i = 1, MAX_PARTY_MEMBERS do
			local PartyMember = _G["PartyMemberFrame" .. i]
			local Health = _G["PartyMemberFrame" .. i .. "HealthBar"]
			local Power = _G["PartyMemberFrame" .. i .. "ManaBar"]
			local Pet = _G["PartyMemberFrame" .. i .."PetFrame"]
			local PetHealth = _G["PartyMemberFrame" .. i .."PetFrame" .. "HealthBar"]

			PartyMember:UnregisterAllEvents()
			PartyMember:SetParent(UIFrameHider)
			PartyMember:Hide()
			Health:UnregisterAllEvents()
			Power:UnregisterAllEvents()

			Pet:UnregisterAllEvents()
			Pet:SetParent(UIFrameHider)
			PetHealth:UnregisterAllEvents()

			HidePartyFrame()
			_G.ShowPartyFrame = K.Noop
			_G.HidePartyFrame = K.Noop
		end
	end

	K.KillMenuOption(true, "Advanced_UseUIScale")
	K.KillMenuOption(true, "Advanced_UIScaleSlider")

	if C.Cooldown.Enable then
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
		local DisableCD = GetCVarBool("countdownForCooldowns")
		if not DisableCD and not InCombatLockdown() then
			SetCVar("countdownForCooldowns", 0)
		end
	end

	if C.General.DisableTutorialButtons then
		BagHelpBox:Kill()
		CollectionsMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		HelpPlate:Kill()
		HelpPlateTooltip:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
		SpellBookFrameTutorialButton:Kill()
		TalentMicroButtonAlert:Kill()
		TutorialFrameAlertButton:Kill()
		WorldMapFrameTutorialButton:Kill()
	end

	if C.Unitframe.Enable then
		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")
	end

	if C.Nameplates.Enable then
		local PlateClassColor = GetCVarBool("ShowClassColorInNameplate")
		if not PlateClassColor and not InCombatLockdown() then
			SetCVar("ShowClassColorInNameplate", 1)
		end
		-- Hide the option to rescale, because we will do it from KkthnxUI settings.
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy")
	end

	if C.Chat.Enable then
		local ChatStyle = GetCVarBool("chatStyle")
		if not ChatStyle and not InCombatLockdown() then
			SetCVar("chatStyle", "im")
		end
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
		InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
		InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
		InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
		InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.0001)
		InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
		InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	end

	if C.Minimap.Enable then
		K.KillMenuOption(true, "InterfaceOptionsDisplayPanelRotateMinimap")
	end
end)