local addonName, HRT = ...

local L = HRT.localization

local Utils = {}

-----------------------
--- Helper Funtions ---
-----------------------

---------------------
--- Main Funtions ---
---------------------

function Utils:PrintDebug(msg)
    if true then
		DEFAULT_CHAT_FRAME:AddMessage(ORANGE_FONT_COLOR:WrapTextInColorCode(addonName .. " (Debug): ")  .. msg)
	end
end

function Utils:PrintMessage(msg)
    DEFAULT_CHAT_FRAME:AddMessage(NORMAL_FONT_COLOR:WrapTextInColorCode(addonName .. ": ") .. msg)
end

function Utils:InitializeDatabase()
    -- Settings
    if (not HoratumSettings) then
        HoratumSettings = { point = "CENTER", relativePoint = "CENTER", xOfs = 0, yOfs = 150, isVisible = true }
    end

	if (not HoratumKillTimes) then
        HoratumKillTimes = {}
    end

    HRT.data = {}
    HRT.data.settings = HoratumSettings
	HRT.data.killTimes = HoratumKillTimes
end

HRT.utils = Utils
