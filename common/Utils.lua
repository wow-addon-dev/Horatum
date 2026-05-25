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

local function GetCharKey()
	return AWL.Utils:GetCharKey()
end

------------------------
--- Public Functions ---
------------------------

function Utils:PrintDebug(msg)
	if HRT.settings.general["debug-mode"] then
		DEFAULT_CHAT_FRAME:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(addonName .. " (Debug): ")  .. msg)
	end
end

function Utils:PrintMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR:WrapTextInColorCode(addonName .. ": ") .. msg)
end

function Utils:IsAccountProfile()
	local charKey = GetCharKey()

	return Horatum_Options_v2.profileKeys[charKey]["use-account"]
end

function Utils:OpenSettingsOnLoading()
	local charKey = GetCharKey()

	if Horatum_Options_v2.profileKeys[charKey]["open-settings"] then
		Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)

		Horatum_Options_v2.profileKeys[charKey]["open-settings"] = false
	end
end

function Utils:ToggleProfileMode()
	local charKey = GetCharKey()
	local useAccountProfile = self:IsAccountProfile()

	Horatum_Options_v2.profileKeys[charKey]["use-account"] = not useAccountProfile
	Horatum_Options_v2.profileKeys[charKey]["open-settings"] = true
end

function Utils:ResetAllCharacterProfiles()
	local charKey = GetCharKey()

	Horatum_Options_v2.profiles = {}
	Horatum_Options_v2.profileKeys = {}

	Horatum_Options_v2.profileKeys[charKey] = {
		["use-account"] = true,
		["open-settings"] = true
	}
end

function Utils:InitializeDatabase()
	local charKey = GetCharKey()

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

	if not Horatum_Options_v2.profiles[charKey] then
		Horatum_Options_v2.profiles[charKey] = CopyTable(defaults)
	end

	if not Horatum_Options_v2.profileKeys[charKey] then
		Horatum_Options_v2.profileKeys[charKey] = {
			["use-account"] = true,
			["open-settings"] = false
		}
	end

	if Horatum_Options_v2.profileKeys[charKey]["use-account"] then
		HRT.settings.general = Horatum_Options_v2.account["general"]
		HRT.settings.combatTimeTracker = Horatum_Options_v2.account["combat-time-tracker"]
		HRT.settings.combatOverview = Horatum_Options_v2.account["combat-overview"]
	else
		HRT.settings.general = Horatum_Options_v2.profiles[charKey]["general"]
		HRT.settings.combatTimeTracker = Horatum_Options_v2.profiles[charKey]["combat-time-tracker"]
		HRT.settings.combatOverview = Horatum_Options_v2.profiles[charKey]["combat-overview"]
	end

	if not Horatum_CombatEncounterData_v2 then
		Horatum_CombatEncounterData_v2 = {}
	end

	HRT.data.combatEncounter = Horatum_CombatEncounterData_v2
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
