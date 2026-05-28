local addonName, HRT = ...

local L = HRT.Localization

local AWL = ArcaneWizardLibrary

local Utils = {}

-----------------------
--- Local Functions ---
-----------------------

local function CopyTable(source)
	local target = {}

	for key, value in pairs(source) do
		if type(value) == "table" then
			target[key] = CopyTable(value)
		else
			target[key] = value
		end
	end

	return target
end

local function GetCharacterRealmKey()
	return AWL.Utils:GetCharacterRealmKey()
end

------------------------
--- Public Functions ---
------------------------

function Utils:PrintDebug(msg)
	local debugMode = HRT.settings
		and HRT.settings.general
		and HRT.settings.general["debug-mode"]

	if debugMode ~= false then
		DEFAULT_CHAT_FRAME:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(addonName .. " (Debug): ")  .. msg)
	end
end

function Utils:PrintMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR:WrapTextInColorCode(addonName .. ": ") .. msg)
end

function Utils:IsAccountProfile()
	local characterRealmKey = GetCharacterRealmKey()

	return Horatum_Options_v2.profileKeys[characterRealmKey]["use-account"]
end

function Utils:OpenSettingsOnLoading()
	local characterRealmKey = GetCharacterRealmKey()

	if Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] then
		Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)

		Horatum_Options_v2.profileKeys[characterRealmKey]["open-settings"] = false
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
	local hadDb = Horatum_Options_v2 ~= nil
	local createdDb = false
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
		createdDb = true
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

	self:PrintDebug(string.format(
		"InitializeDatabase: key=%s, hadDb=%s, createdDb=%s, createdProfile=%s, createdProfileKey=%s, activeProfile=%s",
		characterRealmKey,
		tostring(hadDb),
		tostring(createdDb),
		tostring(createdProfile),
		tostring(createdProfileKey),
		useAccountProfile and "account" or "character"
	))
end

function Utils:InitializeMinimapButton()
	local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Horatum", {
		type     = "launcher",
		text     = "Horatum",
		icon     = HRT.MEDIA_PATH .. "icon-round.blp",
		OnClick  = function(self, button)
			if button == "LeftButton" then
				if HRT.modules.CombatTimeTracker:IsShown() then
					HRT.modules.CombatTimeTracker:Hide()
				else
					HRT.modules.CombatTimeTracker:Show()
				end
			elseif button == "RightButton" then
				if not InCombatLockdown() then
					Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)
				else
					Utils:PrintDebug("In combat. The options menu cannot be opened.")
				end
			end
		end,
		OnTooltipShow = function(tooltip)
			GameTooltip_SetTitle(tooltip, addonName)
			GameTooltip_AddNormalLine(tooltip, HRT.ADDON_VERSION .. " (" .. HRT.ADDON_BUILD_DATE .. ")")
			GameTooltip_AddBlankLineToTooltip(tooltip)
			GameTooltip_AddHighlightLine(tooltip, L["minimap-button.tooltip"])
		end,
	})

	self.minimapButton = LibStub("LibDBIcon-1.0")
	self.minimapButton:Register("Horatum", LDB, HRT.settings.general["minimap-button"])
end

HRT.modules.Utils = Utils
