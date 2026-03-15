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
    if (not HoratumOptions_v2) then
        HoratumOptions_v2 = {
			["general"] = {},
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

	if not HoratumOptions_v2["general"] then
        HoratumOptions_v2["general"] = {}
		HoratumOptions_v2["combat-overview"] = {}
    end

	if not HoratumCombatTimeData then
        HoratumCombatTimeData = {}
    end

	if not HoratumCombatEncounterData then
        HoratumCombatEncounterData = {}
    end

    HRT.options = {}
	HRT.options.general = HoratumOptions_v2["general"]
    HRT.options.combatTimeTracker = HoratumOptions_v2["combat-time-tracker"]
	HRT.options.other = HoratumOptions_v2["other"]

	HRT.data = {}
	HRT.data.combatTime = HoratumCombatTimeData
	HRT.data.combatEncounter = HoratumCombatEncounterData
end

HRT.Utils = Utils
