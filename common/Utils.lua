local addonName, HRT = ...

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = HRT.Localization

-- Current module
local Utils = HRT.Modules.Utils

------------------------
--- Module Functions ---
------------------------

function Utils:PrintMessage(msg)
	Addon:PrintMessage(msg)
end

function Utils:IsAccountProfile()
	local characterRealmKey = AWL.Utils:GetCharacterRealmKey()

	return Horatum_Options_v2.profileKeys[characterRealmKey]["use-account"]
end

function Utils:OpenSettingsOnLoading()
	local characterRealmKey = AWL.Utils:GetCharacterRealmKey()

	if Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] then
		Addon:OpenCategory()

		Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] = false
	end
end

function Utils:ToggleCombatTimeTracker()
	if HRT.Modules.CombatTimeTracker:IsShown() then
		HRT.Modules.CombatTimeTracker:Hide()
	else
		HRT.Modules.CombatTimeTracker:Show()
	end
end

function Utils:ToggleProfileMode()
	local characterRealmKey = AWL.Utils:GetCharacterRealmKey()
	local useAccountProfile = self:IsAccountProfile()

	Horatum_Options_v2.profileKeys[characterRealmKey]["use-account"] = not useAccountProfile
	Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] = true
end

function Utils:ResetAllCharacterProfiles()
	local characterRealmKey = AWL.Utils:GetCharacterRealmKey()

	Horatum_Options_v2.profiles = {}
	Horatum_Options_v2.profileKeys = {}

	Horatum_Options_v2.profileKeys[characterRealmKey] = {
		["use-account"] = true,
		["open-settings"] = true
	}
end

function Utils:InitializeDatabase()
	local characterRealmKey = AWL.Utils:GetCharacterRealmKey()

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
			["account"] = AWL.Utils:CopyTable(defaults),
			["profiles"] = {},
			["profileKeys"] = {}
		}
	end

	if not Horatum_Options_v2.profiles[characterRealmKey] then
		Horatum_Options_v2.profiles[characterRealmKey] = AWL.Utils:CopyTable(defaults)
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
		HRT.Settings.general = Horatum_Options_v2.account["general"]
		HRT.Settings.combatTimeTracker = Horatum_Options_v2.account["combat-time-tracker"]
		HRT.Settings.combatOverview = Horatum_Options_v2.account["combat-overview"]
	else
		HRT.Settings.general = Horatum_Options_v2.profiles[characterRealmKey]["general"]
		HRT.Settings.combatTimeTracker = Horatum_Options_v2.profiles[characterRealmKey]["combat-time-tracker"]
		HRT.Settings.combatOverview = Horatum_Options_v2.profiles[characterRealmKey]["combat-overview"]
	end

	if not Horatum_CombatEncounterData_v2 then
		Horatum_CombatEncounterData_v2 = {}
	end

	HRT.Data.combatEncounter = Horatum_CombatEncounterData_v2

	return {
		characterRealmKey = characterRealmKey,
		createdProfile = createdProfile,
		createdProfileKey = createdProfileKey,
		activeProfile = useAccountProfile and "account" or "character"
	}
end

function Utils:InitializeMinimapButton()
	self.minimapButton = Addon:RegisterMinimapButton({
		db = HRT.Settings.general["minimap-button"],
		tooltip = L["minimap-button.tooltip"],
		onLeftClick = function()
			Utils:ToggleCombatTimeTracker()
		end
	})
end
