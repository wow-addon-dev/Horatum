local addonName, HRT = ...

local L = HRT.Localization

local Utils = {}

---------------------
--- Main Funtions ---
---------------------

function Utils:PrintDebug(msg)
    if HRT.data.options["debug-mode"] then
		DEFAULT_CHAT_FRAME:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(addonName .. " (Debug): ")  .. msg)
	end
end

function Utils:PrintMessage(msg)
    DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR:WrapTextInColorCode(addonName .. ": ") .. msg)
end

function Utils:InitializeDatabase()
    if (not HoratumOptions) then
        HoratumOptions = {
			["tracker-point"] = "CENTER",
			["tracker-relative-point"] = "CENTER",
			["tracker-xOfs"] = 0,
			["tracker-yOfs"] = 150,
			["tracker-is-visible"] = true
		}
    end

	if (not HoratumCombatTimeTracker) then
        HoratumCombatTimeTracker = {}
    end

    HRT.data = {}
    HRT.data.options = HoratumOptions
	HRT.data.combatTimeTracker = HoratumCombatTimeTracker
end

HRT.Utils = Utils
