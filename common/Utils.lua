local addonName, HRT = ...

local L = HRT.Localization

local Utils = {}

---------------------
--- Main Funtions ---
---------------------

function Utils:PrintDebug(msg)
    if HRT.options.other["debug-mode"] then
		DEFAULT_CHAT_FRAME:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(addonName .. " (Debug): ")  .. msg)
	end
end

function Utils:PrintMessage(msg)
    DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR:WrapTextInColorCode(addonName .. ": ") .. msg)
end

function Utils:InitializeDatabase()
    if (not Horatum_Options) then
        Horatum_Options = {
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
				["is-visible"] = true
			},
			["combat-overview"] = {},
			["other"] = {}
		}
    end

	if not Horatum_CombatEncounterData_v2 then
        Horatum_CombatEncounterData_v2 = {}
    end

    HRT.options = {}
	HRT.options.general = Horatum_Options["general"]
    HRT.options.combatTimeTracker = Horatum_Options["combat-time-tracker"]
	HRT.options.other = Horatum_Options["other"]

	HRT.data = {}
	HRT.data.combatEncounter = Horatum_CombatEncounterData_v2
end

function Utils:InitializeMinimapButton()
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Horatum", {
        type     = "launcher",
        text     = "Horatum",
        icon     = HRT.MEDIA_PATH .. "icon-round.blp",
        OnClick  = function(self, button)
			if button == "LeftButton" then
				if HRT.CombatTimeTracker:IsShown() then
					HRT.CombatTimeTracker:Hide()
				else
					HRT.CombatTimeTracker:Show()
				end
			elseif button == "RightButton" then
                Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)
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
    self.minimapButton:Register("Horatum", LDB, HRT.options.general["minimap-button"])
end

HRT.Utils = Utils
