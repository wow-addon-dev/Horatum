local addonName, HRT = ...

local CombatTimeTracker = HRT.modules.CombatTimeTracker
local Options = HRT.modules.Options
local Utils = HRT.modules.Utils

local isInCombat = false

--------------
--- Frames ---
--------------

local HoratumFrame = CreateFrame("Frame", "Horatum")

-----------------------
--- Local Functions ---
-----------------------

local function SlashCommand(msg, editbox)
	if not msg or strtrim(msg) == "" then
		if not InCombatLockdown() then
			Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)
		else
			Utils:PrintDebug("In combat. The options menu cannot be opened.")
		end
	elseif strtrim(msg) == "show" then
		CombatTimeTracker:Show()
	else
		Utils:PrintDebug("These arguments are not accepted.")
	end
end

------------------------
--- Public Functions ---
------------------------

function HoratumFrame:OnEvent(event, ...)
	self[event](self, event, ...)
end

function HoratumFrame:ADDON_LOADED(_, addOnName)
	if addOnName == addonName then
		Utils:InitializeDatabase()
		Utils:InitializeMinimapButton()
		Options:Initialize()
		CombatTimeTracker:Initialize()

		Utils:OpenSettingsOnLoading()

		Utils:PrintDebug("Addon fully loaded.")
	end
end

function HoratumFrame:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, groupSize)
	Utils:PrintDebug("Event 'ENCOUNTER_START' fired. Payload: encounterID=" .. tostring(encounterID) .. ", encounterName=" .. tostring(encounterName) .. ", difficultyID=" .. tostring(difficultyID) .. ", groupSize=" .. tostring(groupSize))

	isInCombat = CombatTimeTracker:EncounterStart(encounterID, encounterName, difficultyID)

	if isInCombat then
		Utils:PrintDebug("The encounter has started.")
	end
end

function HoratumFrame:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
	Utils:PrintDebug("Event 'ENCOUNTER_END' fired. Payload: encounterID=" .. tostring(encounterID) .. ", encounterName=" .. tostring(encounterName) .. ", difficultyID=" .. tostring(difficultyID) .. ", groupSize=" .. tostring(groupSize) .. ", success=" .. tostring(success))

	if isInCombat then
		CombatTimeTracker:EncounterEnd(success)
		isInCombat = false

		Utils:PrintDebug("The encounter has ended.")
	end
end

HoratumFrame:RegisterEvent("ADDON_LOADED")
HoratumFrame:RegisterEvent("ENCOUNTER_START")
HoratumFrame:RegisterEvent("ENCOUNTER_END")
HoratumFrame:SetScript("OnEvent", HoratumFrame.OnEvent)

SLASH_Horatum1, SLASH_Horatum2 = '/hrt', '/horatum'

SlashCmdList["Horatum"] = SlashCommand
