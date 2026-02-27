local addonName, HRT = ...

local L = HRT.Localization

local Utils = HRT.Utils
local CombatTimeTracker = HRT.CombatTimeTracker

----------------------
--- Local funtions ---
----------------------

local function SlashCommand(msg, editbox)
    if not msg or msg:trim() == "" then
        CombatTimeTracker:Show()
	else
        Utils:PrintDebug("No arguments will be accepted.")
	end
end

--------------
--- Frames ---
--------------

local horatumFrame = CreateFrame("Frame", "Expositum")

---------------------
--- Main funtions ---
---------------------

function horatumFrame:OnEvent(event, ...)
	self[event](self, event, ...)
end

function horatumFrame:ADDON_LOADED(_, addOnName)
    if addOnName == addonName then
        Utils:InitializeDatabase()
		CombatTimeTracker:Initialize()

        Utils:PrintDebug("Addon fully loaded.")
    end
end

function horatumFrame:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, groupSize)
    local encounterKey = encounterID .. "_" .. difficultyID

	CombatTimeTracker:EncounterStart(encounterKey, encounterName)
end

function horatumFrame:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
    local encounterKey = encounterID .. "_" .. difficultyID

	CombatTimeTracker:EncounterEnd(encounterKey, encounterName, success)
end

horatumFrame:RegisterEvent("ADDON_LOADED")
horatumFrame:RegisterEvent("ENCOUNTER_START")
horatumFrame:RegisterEvent("ENCOUNTER_END")
horatumFrame:SetScript("OnEvent", horatumFrame.OnEvent)

SLASH_Horatum1, SLASH_Horatum2 = '/hrt', '/horatum'

SlashCmdList["Horatum"] = SlashCommand
