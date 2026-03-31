local addonName, HRT = ...

local L = HRT.Localization

local Utils = HRT.Utils
local Options = HRT.Options
local CombatTimeTracker = HRT.CombatTimeTracker

local isInCombat = false

--------------
--- Frames ---
--------------

local horatumFrame = CreateFrame("Frame", "Horatum")

----------------------
--- Local Funtions ---
----------------------

local function SlashCommand(msg, editbox)
    if not msg or msg:trim() == "" then
		Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)
	elseif msg:trim() == "show" then
		CombatTimeTracker:Show()
	else
        Utils:PrintDebug("These arguments are not accepted.")
	end
end

---------------------
--- Main Funtions ---
---------------------

function horatumFrame:OnEvent(event, ...)
	self[event](self, event, ...)
end

function horatumFrame:ADDON_LOADED(_, addOnName)
    if addOnName == addonName then
        Utils:InitializeDatabase()
		Utils:InitializeMinimapButton()
		Options:Initialize()
		CombatTimeTracker:Initialize()

        Utils:PrintDebug("Addon fully loaded.")
    end
end

function horatumFrame:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, groupSize)
	Utils:PrintDebug("Event 'ENCOUNTER_START' fired. Payload: encounterID=" .. tostring(encounterID) .. ", encounterName=" .. tostring(encounterName) .. ", difficultyID=" .. tostring(difficultyID) .. ", groupSize=" .. tostring(groupSize))

	isInCombat = CombatTimeTracker:EncounterStart(encounterID, encounterName, difficultyID)

	if isInCombat then
		Utils:PrintDebug("The encounter has started.")
	end
end

function horatumFrame:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
	Utils:PrintDebug("Event 'ENCOUNTER_END' fired. Payload: encounterID=" .. tostring(encounterID) .. ", encounterName=" .. tostring(encounterName) .. ", difficultyID=" .. tostring(difficultyID) .. ", groupSize=" .. tostring(groupSize) .. ", success=" .. tostring(success))

	if isInCombat then
		CombatTimeTracker:EncounterEnd(success)

		Utils:PrintDebug("The encounter has ended.")
	end
end

horatumFrame:RegisterEvent("ADDON_LOADED")
horatumFrame:RegisterEvent("ENCOUNTER_START")
horatumFrame:RegisterEvent("ENCOUNTER_END")
horatumFrame:SetScript("OnEvent", horatumFrame.OnEvent)

SLASH_Horatum1, SLASH_Horatum2 = '/hrt', '/horatum'

SlashCmdList["Horatum"] = SlashCommand
