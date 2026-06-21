local addonName, HRT = ...

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = HRT.Localization

-- Current module
local CombatTimeTracker = HRT.Modules.CombatTimeTracker

-- Module imports
local Utils = HRT.Modules.Utils

-- Variables
local startTime = 0
local currentBestVictory = 0
local currentEncounterID = 0
local currentDifficultyID = 0
local currentDifficultyText = nil
local currentOptionalID = 0
local currentEncounterName = nil

--------------
--- Frames ---
--------------

local CombatTimeTrackerFrame

-----------------------
--- Local Functions ---
-----------------------

local function ParseDelveTier(tierText)
	if type(tierText) ~= "string" then
		return nil
	end

	return tonumber(tierText:match("%d+"))
end

local function EncounterInfo(difficultyID)
	local name, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minPlayers, maxPlayers, isUserSelectable = GetDifficultyInfo(difficultyID)

	Addon:PrintDebug(string.format(
		"Result from GetDifficultyInfo(): name=%s, instanceType=%s, isHeroic=%s, isChallengeMode=%s, displayHeroic=%s, displayMythic=%s, toggleDifficultyID=%s, isLFR=%s, minPlayers=%s, maxPlayers=%s, isUserSelectable=%s",
		tostring(name),	tostring(instanceType),	tostring(isHeroic),	tostring(isChallengeMode), tostring(displayHeroic), tostring(displayMythic), tostring(toggleDifficultyID), tostring(isLFR), tostring(minPlayers), tostring(maxPlayers), tostring(isUserSelectable)
	))

	if difficultyID == 1 then				-- Dungeon Normal
		return true, 0, L["combat-time-tracker.dungeon"] .. " - " .. name
	elseif difficultyID == 2 then			-- Dungeon Heroisch
		return true, 0, L["combat-time-tracker.dungeon"] .. " - " .. name
	elseif difficultyID == 23 then			-- Dungeon Mythisch
		return true, 0, L["combat-time-tracker.dungeon"] .. " - " .. name
	elseif difficultyID == 24 then			-- Dungeon Zeitenwanderung
		return true, 0, L["combat-time-tracker.dungeon"] .. " - " .. name
	elseif difficultyID == 3 then			-- Raid 10er Normal (legacy)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 4 then			-- Raid 25er Normal (legacy)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 5 then			-- Raid 10er Heroisch (legacy)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 6 then			-- Raid 25er Heroisch (legacy)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 9 then			-- Raid 40er (legacy)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 14 then			-- Raid Normal (flexibel)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 15 then			-- Raid Heroisch (flexibel)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 16 then			-- Raid Mythisch
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 17 then			-- Raid Schlachtzugbrowser
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 33 then			-- Raid Zeitenwanderung
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 220 then			-- Raid Geschichtenmodus
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 233 then			-- Raid Mythisch (flexibel)
		return true, 0, L["combat-time-tracker.raid"] .. " - " .. name
	elseif difficultyID == 208  then		-- Tiefe
		local delveData1, delveData2, delveData3 = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6183), C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6184), C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6185)

		if delveData1 and delveData1.tierText then
			local delveTier = ParseDelveTier(delveData1.tierText)

			if delveTier then
				return true, delveTier, name .. " - " .. L["combat-time-tracker.delves-tier"] .. " " .. delveTier
			end

			return false, 0, nil
		elseif delveData2 and delveData2.shownState and delveData2.shownState == 1 then
			return true, 8, name .. " - " .. L["combat-time-tracker.delves-tier"] .. " ?"
		elseif delveData3 and delveData3.shownState and delveData3.shownState == 1 then
			return true, 11, name .. " - " .. L["combat-time-tracker.delves-tier"] .. " ??"
		end
	end

	return false, 0, nil
end

local function UpdateTimerFrame(self, elapsed)
	local currentTime = GetTime() - startTime

	local minutes = math.floor(currentTime / 60)
	local seconds = math.floor(currentTime % 60)
	local milliseconds = math.floor((currentTime * 1000) % 1000)
	CombatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

	if currentBestVictory >= HRT.COMBAT_TIME_TRACKER_THRESHOLD then
		local remainingTime = currentBestVictory - currentTime

		if remainingTime > 0 then
			CombatTimeTrackerFrame.timeBar:SetValue(remainingTime)
			CombatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
		else
			CombatTimeTrackerFrame.timeBar:SetValue(currentBestVictory)
			CombatTimeTrackerFrame.timeBar:SetStatusBarColor(1, 0, 0)
		end
	end
end

-----------------------
--- Frame Functions ---
-----------------------

local function InitializeFrames()
	CombatTimeTrackerFrame = CreateFrame("Frame", nil, UIParent)
	CombatTimeTrackerFrame:SetWidth(180)
	CombatTimeTrackerFrame:SetScale(HRT.Settings.combatTimeTracker["scale"] / 100)

	CombatTimeTrackerFrame:SetMovable(true)
	CombatTimeTrackerFrame:EnableMouse(true)
	CombatTimeTrackerFrame:RegisterForDrag("LeftButton")
	CombatTimeTrackerFrame:SetScript("OnDragStart", CombatTimeTrackerFrame.StartMoving)
	CombatTimeTrackerFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()

		local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
		HRT.Settings.combatTimeTracker["point"] = point
		HRT.Settings.combatTimeTracker["relative-point"] = relativePoint
		HRT.Settings.combatTimeTracker["offset-x"] = xOfs
		HRT.Settings.combatTimeTracker["offset-y"] = yOfs
	end)

	CombatTimeTrackerFrame.background = CombatTimeTrackerFrame:CreateTexture(nil, "BACKGROUND")
	CombatTimeTrackerFrame.background:SetAllPoints(CombatTimeTrackerFrame,true)
	CombatTimeTrackerFrame.background:SetColorTexture(0, 0, 0, HRT.Settings.combatTimeTracker["background-transparency"] / 100)

	CombatTimeTrackerFrame.timer = CombatTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
	CombatTimeTrackerFrame.timer:SetPoint("TOP", CombatTimeTrackerFrame, "TOP", 0, -15)
	CombatTimeTrackerFrame.timer:SetText("00:00.000")

	CombatTimeTrackerFrame.timeBar = CreateFrame("StatusBar", nil, CombatTimeTrackerFrame)
	CombatTimeTrackerFrame.timeBar:SetSize(160, 10)
	CombatTimeTrackerFrame.timeBar:SetPoint("TOP", CombatTimeTrackerFrame.timer, "BOTTOM", 0, -8)
	CombatTimeTrackerFrame.timeBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	CombatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
	CombatTimeTrackerFrame.timeBar:SetValue(1)
	CombatTimeTrackerFrame.timeBar:SetStatusBarColor(0.5, 0.5, 0.5)

	local timeBarBackground = CombatTimeTrackerFrame.timeBar:CreateTexture(nil, "BACKGROUND")
	timeBarBackground:SetAllPoints(CombatTimeTrackerFrame.timeBar, true)
	timeBarBackground:SetColorTexture(0.2, 0.2, 0.2, 0.8)

	local timeBarBorder = CreateFrame("Frame", nil, CombatTimeTrackerFrame.timeBar, "BackdropTemplate")
	timeBarBorder:SetPoint("TOPLEFT", CombatTimeTrackerFrame.timeBar, "TOPLEFT", -3, 3)
	timeBarBorder:SetPoint("BOTTOMRIGHT", CombatTimeTrackerFrame.timeBar, "BOTTOMRIGHT", 3, -3)
	timeBarBorder:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 8
	})

	CombatTimeTrackerFrame.name = CombatTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	CombatTimeTrackerFrame.name:SetPoint("TOP", CombatTimeTrackerFrame.timeBar, "BOTTOM", 0, -8)
	CombatTimeTrackerFrame.name:SetWidth(160)
	CombatTimeTrackerFrame.name:SetWordWrap(false)
	CombatTimeTrackerFrame.name:SetText(L["combat-time-tracker.wait-combat"])

	CombatTimeTrackerFrame.difficulty = CombatTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	CombatTimeTrackerFrame.difficulty:SetPoint("TOP", CombatTimeTrackerFrame.name, "BOTTOM", 0, -3)
	CombatTimeTrackerFrame.difficulty:SetWidth(140)
	CombatTimeTrackerFrame.difficulty:SetWordWrap(false)
	CombatTimeTrackerFrame.difficulty:SetText("-")

	CombatTimeTrackerFrame.closeButton = CreateFrame("Button", nil, CombatTimeTrackerFrame, "UIPanelCloseButton")
	CombatTimeTrackerFrame.closeButton:SetSize(16, 16)
	CombatTimeTrackerFrame.closeButton:SetPoint("TOPRIGHT", CombatTimeTrackerFrame, "TOPRIGHT", 4, 4)
	CombatTimeTrackerFrame.closeButton:SetScript("OnClick", function()
		CombatTimeTrackerFrame:Hide()
		HRT.Settings.combatTimeTracker["is-visible"] = false
	end)

	CombatTimeTrackerFrame.resetButton = CreateFrame("Button", nil, CombatTimeTrackerFrame)
	CombatTimeTrackerFrame.resetButton:SetSize(16, 16)
	CombatTimeTrackerFrame.resetButton:SetPoint("BOTTOMRIGHT", CombatTimeTrackerFrame, "BOTTOMRIGHT", -4, 4)
	CombatTimeTrackerFrame.resetButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
	CombatTimeTrackerFrame.resetButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	CombatTimeTrackerFrame.resetButton:SetPushedTexture("Interface\\Buttons\\UI-RefreshButton")

	local pushedTexture = CombatTimeTrackerFrame.resetButton:GetPushedTexture()
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("CENTER", CombatTimeTrackerFrame.resetButton, "CENTER", 1, -1)
	pushedTexture:SetSize(16, 16)

	CombatTimeTrackerFrame.resetButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["combat-time-tracker.button-reset"], 1, 1, 1)
		GameTooltip:Show()
	end)
	CombatTimeTrackerFrame.resetButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	CombatTimeTrackerFrame.resetButton:SetScript("OnClick", function()
		CombatTimeTrackerFrame.timer:SetText("00:00.000")
		CombatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
		CombatTimeTrackerFrame.timeBar:SetValue(1)
		CombatTimeTrackerFrame.timeBar:SetStatusBarColor(0.5, 0.5, 0.5)
		CombatTimeTrackerFrame.name:SetText(L["combat-time-tracker.wait-combat"])
		CombatTimeTrackerFrame.difficulty:SetText("-")
	end)

	local height = 15
	height = height + CombatTimeTrackerFrame.timer:GetStringHeight()
	height = height + 7 + CombatTimeTrackerFrame.timeBar:GetHeight()
	height = height + 7 + CombatTimeTrackerFrame.name:GetStringHeight()
	height = height + 3 + CombatTimeTrackerFrame.difficulty:GetStringHeight()
	height = height + 15

	CombatTimeTrackerFrame:SetHeight(height)

	CombatTimeTrackerFrame:ClearAllPoints()
	CombatTimeTrackerFrame:SetPoint(HRT.Settings.combatTimeTracker["point"], UIParent, HRT.Settings.combatTimeTracker["relative-point"], HRT.Settings.combatTimeTracker["offset-x"], HRT.Settings.combatTimeTracker["offset-y"])

	if HRT.Settings.combatTimeTracker["is-visible"] then
		CombatTimeTrackerFrame:Show()
	else
		CombatTimeTrackerFrame:Hide()
	end
end

------------------------
--- Module Functions ---
------------------------

function CombatTimeTracker:Initialize()
	InitializeFrames()
end

function CombatTimeTracker:EncounterStart(encounterID, encounterName, difficultyID)
	currentEncounterID = encounterID
	currentDifficultyID = difficultyID
	currentEncounterName = encounterName

	local isValidEncounter, optionalID, difficulty = EncounterInfo(difficultyID)

	Addon:PrintDebug(string.format(
		"Result from EncounterInfo(): isValidEncounter=%s, optionalID=%s, difficulty=%s",
		tostring(isValidEncounter),	tostring(optionalID), tostring(difficulty)
	))

	if not isValidEncounter then return false end

	startTime = GetTime()

	currentOptionalID = optionalID
	currentDifficultyText = difficulty

	CombatTimeTrackerFrame.resetButton:Hide()
	CombatTimeTrackerFrame:Show()

	HRT.Settings.combatTimeTracker["is-visible"] = true

	CombatTimeTrackerFrame.name:SetText(encounterName)
	CombatTimeTrackerFrame.difficulty:SetText(currentDifficultyText)

	if not HRT.Data.combatEncounter[tostring(currentEncounterID)] then
			HRT.Data.combatEncounter[tostring(currentEncounterID)] = {}
	end

	if not HRT.Data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)] then
		HRT.Data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)] = {}
	end

	if not HRT.Data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)] then
		HRT.Data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)] = {
			bestVictory = -1,
			victories = 0,
			wipes = 0
		}
	end

	local currentDataSet = HRT.Data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)]
	currentBestVictory = currentDataSet.bestVictory

	if currentBestVictory >= HRT.COMBAT_TIME_TRACKER_THRESHOLD then
		CombatTimeTrackerFrame.timeBar:SetMinMaxValues(0, currentBestVictory)
		CombatTimeTrackerFrame.timeBar:SetValue(currentBestVictory)
		CombatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
	else
		CombatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
		CombatTimeTrackerFrame.timeBar:SetValue(1)
		CombatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 0.5, 1)
	end

	CombatTimeTrackerFrame:SetScript("OnUpdate", UpdateTimerFrame)

	return true
end

function CombatTimeTracker:EncounterEnd(success)
	CombatTimeTrackerFrame.resetButton:Show()
	CombatTimeTrackerFrame:SetScript("OnUpdate", nil)

	local finalTime = GetTime() - startTime

	Addon:PrintDebug(string.format(
		"Unrounded time: finalTime=%s",
		tostring(finalTime)
	))

	if finalTime < HRT.COMBAT_TIME_TRACKER_THRESHOLD then
		finalTime = 0.001
	else
		finalTime = math.floor(finalTime * 1000 + 0.5) / 1000
	end

	Addon:PrintDebug(string.format(
		"Rounded time: finalTime=%s",
		tostring(finalTime)
	))

	local minutes = math.floor(finalTime / 60)
	local seconds = math.floor(finalTime % 60)
	local milliseconds = math.floor((finalTime * 1000) % 1000)
	CombatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

	local currentDataSet = HRT.Data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)]
	local bestVictory = currentDataSet.bestVictory
	local victories = currentDataSet.victories
	local wipes = currentDataSet.wipes

	if success == 1 then
		victories = victories + 1
		currentDataSet.victories = victories

		if bestVictory < HRT.COMBAT_TIME_TRACKER_THRESHOLD or finalTime < bestVictory then
			currentDataSet.bestVictory = finalTime
		end

		if HRT.Settings.general["notification"] then
			if bestVictory < HRT.COMBAT_TIME_TRACKER_THRESHOLD or finalTime < bestVictory then
				Utils:PrintMessage(L["chat.new-record"]:format(currentEncounterName, currentDifficultyText, string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)))
			else
				local bestVictoryMinutes = math.floor(bestVictory / 60)
				local bestVictorySeconds = math.floor(bestVictory % 60)
				local bestVictoryMilliseconds = math.floor((bestVictory * 1000) % 1000)

				Utils:PrintMessage(L["chat.current-record"]:format(currentEncounterName, currentDifficultyText, string.format("%02d:%02d.%03d", bestVictoryMinutes, bestVictorySeconds, bestVictoryMilliseconds)))
			end

			if victories == 1 then
				Utils:PrintMessage(L["chat.first-victory"]:format(currentEncounterName, currentDifficultyText, wipes))
			else
				Utils:PrintMessage(L["chat.another-victory"]:format(currentEncounterName, currentDifficultyText, victories, wipes))
			end
		end
	else
		wipes = wipes + 1
		currentDataSet.wipes = wipes

		if HRT.Settings.general["notification"] then
			if bestVictory >= HRT.COMBAT_TIME_TRACKER_THRESHOLD then
				local bestVictoryMinutes = math.floor(bestVictory / 60)
				local bestVictorySeconds = math.floor(bestVictory % 60)
				local bestVictoryMilliseconds = math.floor((bestVictory * 1000) % 1000)

				Utils:PrintMessage(L["chat.current-record"]:format(currentEncounterName, currentDifficultyText, string.format("%02d:%02d.%03d", bestVictoryMinutes, bestVictorySeconds, bestVictoryMilliseconds)))
			end

			if wipes == 1 then
				Utils:PrintMessage(L["chat.first-wipe"]:format(currentEncounterName, currentDifficultyText, victories))
			else
				Utils:PrintMessage(L["chat.another-wipe"]:format(currentEncounterName, currentDifficultyText, victories, wipes))
			end
		end
	end

	startTime = 0
	currentBestVictory = -1
	currentEncounterID = 0
	currentDifficultyID = 0
	currentDifficultyText = nil
	currentOptionalID = 0
	currentEncounterName = nil
end

function CombatTimeTracker:IsShown()
	return CombatTimeTrackerFrame:IsShown()
end

function CombatTimeTracker:Show()
	CombatTimeTrackerFrame:Show()
	HRT.Settings.combatTimeTracker["is-visible"] = true
end

function CombatTimeTracker:Hide()
	CombatTimeTrackerFrame:Hide()
	HRT.Settings.combatTimeTracker["is-visible"] = false
end

function CombatTimeTracker:SetScale()
	CombatTimeTrackerFrame:SetScale(HRT.Settings.combatTimeTracker["scale"] / 100)
end

function CombatTimeTracker:SetBackgroundTransparency()
	CombatTimeTrackerFrame.background:SetColorTexture(0, 0, 0, HRT.Settings.combatTimeTracker["background-transparency"] / 100)
end
