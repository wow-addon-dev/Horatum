local addonName, HRT = ...

local L = HRT.localization

local Utils = HRT.utils
local TimeTracker = HRT.timeTracker

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
		TimeTracker:Initialize()

        Utils:PrintDebug("Addon fully loaded.")
    end
end

function horatumFrame:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, groupSize)
    local encounterKey = encounterID .. "_" .. difficultyID

	TimeTracker:EncounterStart(encounterKey, encounterName)
end

function horatumFrame:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
    local encounterKey = encounterID .. "_" .. difficultyID

	TimeTracker:EncounterEnd(encounterKey, encounterName, success)
end

horatumFrame:RegisterEvent("ADDON_LOADED")
horatumFrame:RegisterEvent("ENCOUNTER_START")
horatumFrame:RegisterEvent("ENCOUNTER_END")
horatumFrame:SetScript("OnEvent", horatumFrame.OnEvent)
