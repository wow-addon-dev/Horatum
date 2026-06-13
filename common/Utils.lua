local addonName, HRT = ...

local L = HRT.Localization

local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

local Utils = {}

-----------------------
--- Local Functions ---
-----------------------

local function CopyTable(source)
	return AWL.Utils:CopyTable(source)
end

local function GetCharacterRealmKey()
	return AWL.Utils:GetCharacterRealmKey()
end

------------------------
--- Public Functions ---
------------------------

function Utils:PrintDebug(msg)
	Addon:PrintDebug(msg)
end

function Utils:PrintMessage(msg)
	Addon:PrintMessage(msg)
end

function Utils:IsAccountProfile()
	local characterRealmKey = GetCharacterRealmKey()

	return Horatum_Options_v2.profileKeys[characterRealmKey]["use-account"]
end

function Utils:OpenSettingsOnLoading()
	local characterRealmKey = GetCharacterRealmKey()

	if Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] then
		Addon:OpenCategory()

		Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] = false
	end
end

function Utils:ToggleCombatTimeTracker()
	if HRT.modules.CombatTimeTracker:IsShown() then
		HRT.modules.CombatTimeTracker:Hide()
	else
		HRT.modules.CombatTimeTracker:Show()
	end
end

function Utils:ToggleProfileMode()
	local characterRealmKey = GetCharacterRealmKey()
	local useAccountProfile = self:IsAccountProfile()

	Horatum_Options_v2.profileKeys[characterRealmKey]["use-account"] = not useAccountProfile
	Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] = true
end

function Utils:ResetAllCharacterProfiles()
	local characterRealmKey = GetCharacterRealmKey()

	Horatum_Options_v2.profiles = {}
	Horatum_Options_v2.profileKeys = {}

	Horatum_Options_v2.profileKeys[characterRealmKey] = {
		["use-account"] = true,
		["open-settings"] = true
	}
end

function Utils:InitializeDatabase()
	local characterRealmKey = GetCharacterRealmKey()

	local createdProfile = false
	local createdProfileKey = false

	local defaults = {
		["general"] = {
			["minimap-button"] = {
				["hide"] = false
			}
		},
		["combat-time-tracker"] = {
			["point"] = "CENTER",
			["relative-point"] = "CENTER",
			["offset-x"] = 0,
			["offset-y"] = 150,
			["scale"] = 100,
			["background-transparency"] = 60,
			["is-visible"] = true
		},
		["combat-overview"] = {}
	}

	if not Horatum_Options_v2 then
		Horatum_Options_v2 = {
			["account"] = CopyTable(defaults),
			["profiles"] = {},
			["profileKeys"] = {}
		}
	end

	if not Horatum_Options_v2.profiles[characterRealmKey] then
		Horatum_Options_v2.profiles[characterRealmKey] = CopyTable(defaults)
		createdProfile = true
	end

	if not Horatum_Options_v2.profileKeys[characterRealmKey] then
		Horatum_Options_v2.profileKeys[characterRealmKey] = {
			["use-account"] = true,
			["open-settings"] = false
		}
		createdProfileKey = true
	end

	local useAccountProfile = Horatum_Options_v2.profileKeys[characterRealmKey]["use-account"]

	if useAccountProfile then
		HRT.settings.general = Horatum_Options_v2.account["general"]
		HRT.settings.combatTimeTracker = Horatum_Options_v2.account["combat-time-tracker"]
		HRT.settings.combatOverview = Horatum_Options_v2.account["combat-overview"]
	else
		HRT.settings.general = Horatum_Options_v2.profiles[characterRealmKey]["general"]
		HRT.settings.combatTimeTracker = Horatum_Options_v2.profiles[characterRealmKey]["combat-time-tracker"]
		HRT.settings.combatOverview = Horatum_Options_v2.profiles[characterRealmKey]["combat-overview"]
	end

	if not Horatum_CombatEncounterData_v2 then
		Horatum_CombatEncounterData_v2 = {}
	end

	HRT.data.combatEncounter = Horatum_CombatEncounterData_v2

	return {
		characterRealmKey = characterRealmKey,
		createdProfile = createdProfile,
		createdProfileKey = createdProfileKey,
		activeProfile = useAccountProfile and "account" or "character"
	}
end

function Utils:InitializeMinimapButton()
	self.minimapButton = Addon:RegisterMinimapButton({
		db = HRT.settings.general["minimap-button"],
		tooltip = L["minimap-button.tooltip"],
		onLeftClick = function()
			Utils:ToggleCombatTimeTracker()
		end
	})
end

HRT.modules.Utils = Utils
