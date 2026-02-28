local addonName, HRT = ...

local L = HRT.Localization

local Utils = {}

-----------------------
--- Helper Funtions ---
-----------------------

---------------------
--- Main Funtions ---
---------------------

function Utils:PrintDebug(msg)
    if false then
		DEFAULT_CHAT_FRAME:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(addonName .. " (Debug): ")  .. msg)
	end
end

function Utils:PrintMessage(msg)
    DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR:WrapTextInColorCode(addonName .. ": ") .. msg)
end

function Utils:InitializeDatabase()
    if (not HoratumSettings) then
        HoratumSettings = { point = "CENTER", relativePoint = "CENTER", xOfs = 0, yOfs = 150, isVisible = true }
    end

	if (not HoratumCombatTimeTracker) then
        HoratumCombatTimeTracker = {}
    end

    HRT.data = {}
    HRT.data.settings = HoratumSettings
	HRT.data.combatTimeTracker = HoratumCombatTimeTracker
end

HRT.Utils = Utils
