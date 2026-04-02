local addonName, HRT = ...

local L = HRT.Localization
local Utils = HRT.Utils

local CombatTimeTracker = {}

local THRESHOLD = 0.001

local startTime = 0
local currentBestVictory = 0
local currentEncounterID = 0
local currentDifficultyID = 0
local currentDifficultyName = nil
local currentOptionalID = 0
local currentOptionalInfo = nil
local currentEncounterName = nil

--------------
--- Frames ---
--------------

local combatTimeTrackerFrame

----------------------
--- Local Funtions ---
----------------------

local function EncounterCheck(difficultyID)
	local name, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minPlayers, maxPlayers, isUserSelectable = GetDifficultyInfo(difficultyID)

	Utils:PrintDebug(string.format(
		"Result from GetDifficultyInfo(): name=%s, instanceType=%s, isHeroic=%s, isChallengeMode=%s, displayHeroic=%s, displayMythic=%s, toggleDifficultyID=%s, isLFR=%s, minPlayers=%s, maxPlayers=%s, isUserSelectable=%s",
		tostring(name),	tostring(instanceType),	tostring(isHeroic),	tostring(isChallengeMode), tostring(displayHeroic), tostring(displayMythic), tostring(toggleDifficultyID), tostring(isLFR), tostring(minPlayers), tostring(maxPlayers), tostring(isUserSelectable)
	))

	if difficultyID == 1 then				-- Dungeon Normal
		return true, name, 0, nil
	elseif difficultyID == 2 then			-- Dungeon Heroisch
		return true, name, 0, nil
	elseif difficultyID == 23 then			-- Dungeon Mythisch
		return true, name, 0, nil
	elseif difficultyID == 24 then			-- Dungeon Zeitenwanderung
		return true, name, 0, nil
	elseif difficultyID == 3 then			-- Raid 10er Normal (legacy)
		return true, name, 0, nil
	elseif difficultyID == 4 then			-- Raid 25er Normal (legacy)
		return true, name, 0, nil
	elseif difficultyID == 5 then			-- Raid 10er Heroisch (legacy)
		return true, name, "0", nil
	elseif difficultyID == 6 then			-- Raid 25er Heroisch (legacy)
		return true, name, "0", nil
	elseif difficultyID == 9 then			-- Raid 40er (legacy)
		return true, name, "0", nil
	elseif difficultyID == 14 then			-- Raid Normal (flexibel)
		return true, name, "0", nil
	elseif difficultyID == 15 then			-- Raid Heroisch (flexibel)
		return true, name, "0", nil
	elseif difficultyID == 16 then			-- Raid Mythisch
		return true, name, "0", nil
	elseif difficultyID == 17 then			-- Raid Schlachtzugbrowser
		return true, name, "0", nil
	elseif difficultyID == 33 then			-- Raid Zeitenwanderung
		return true, name, "0", nil
	elseif difficultyID == 208  then		-- Tiefe
		local delveData1, delveData2, delveData3 = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6183), C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6184), C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6185)

		if delveData1 then
			if delveData1 and delveData1.tierText then
				return true, name, tonumber(delveData1.tierText), delveData1.tierText
			end
		elseif delveData2 and delveData2.shownState and delveData2.shownState == 1 then
			return true, name, 8, "?"
		elseif delveData3 and delveData3.shownState and delveData3.shownState == 1 then
			return true, name, 11, "??"
		end
	end

	return false, nil, 0, nil
end

local function GetDifficultyName(difficultyID, difficultyName)
	if difficultyName and difficultyID ~= 0 then
		if difficultyID == 208 then
			return difficultyName .. " " .. currentOptionalInfo
		else
			return difficultyName
		end
	end

	return L["combat-time-tracker.unknown"]
end

local function UpdateTimerFrame(self, elapsed)
    local currentTime = GetTime() - startTime

    local minutes = math.floor(currentTime / 60)
    local seconds = math.floor(currentTime % 60)
    local milliseconds = math.floor((currentTime * 1000) % 1000)
    combatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

    if currentBestVictory >= THRESHOLD then
        local remainingTime = currentBestVictory - currentTime

        if remainingTime > 0 then
            combatTimeTrackerFrame.timeBar:SetValue(remainingTime)
            combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
        else
            combatTimeTrackerFrame.timeBar:SetValue(currentBestVictory)
            combatTimeTrackerFrame.timeBar:SetStatusBarColor(1, 0, 0)
        end
    end
end

----------------------
--- Frame Funtions ---
----------------------

local function InitializeFrames()
	combatTimeTrackerFrame = CreateFrame("Frame", "HRT_CombatTimeTrackerFrame", UIParent)
	combatTimeTrackerFrame:SetWidth(160)
	combatTimeTrackerFrame:SetScale(HRT.options.combatTimeTracker["scale"] / 100)

	combatTimeTrackerFrame:SetMovable(true)
	combatTimeTrackerFrame:EnableMouse(true)
	combatTimeTrackerFrame:RegisterForDrag("LeftButton")
	combatTimeTrackerFrame:SetScript("OnDragStart", combatTimeTrackerFrame.StartMoving)
	combatTimeTrackerFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
		HRT.options.combatTimeTracker["point"] = point
		HRT.options.combatTimeTracker["relative-point"] = relativePoint
		HRT.options.combatTimeTracker["offset-x"] = xOfs
		HRT.options.combatTimeTracker["offset-y"] = yOfs
	end)

	combatTimeTrackerFrame.background = combatTimeTrackerFrame:CreateTexture(nil, "BACKGROUND")
	combatTimeTrackerFrame.background:SetAllPoints(combatTimeTrackerFrame,true)
	combatTimeTrackerFrame.background:SetColorTexture(0, 0, 0, HRT.options.combatTimeTracker["background-transparency"] / 100)

	combatTimeTrackerFrame.timer = combatTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
	combatTimeTrackerFrame.timer:SetPoint("TOP", combatTimeTrackerFrame, "TOP", 0, -10)
	combatTimeTrackerFrame.timer:SetText("00:00.000")

	combatTimeTrackerFrame.timeBar = CreateFrame("StatusBar", nil, combatTimeTrackerFrame)
	combatTimeTrackerFrame.timeBar:SetSize(140, 10)
	combatTimeTrackerFrame.timeBar:SetPoint("TOP", combatTimeTrackerFrame.timer, "BOTTOM", 0, -8)
	combatTimeTrackerFrame.timeBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
    combatTimeTrackerFrame.timeBar:SetValue(1)
    combatTimeTrackerFrame.timeBar:SetStatusBarColor(0.5, 0.5, 0.5)

	local timeBarBackground = combatTimeTrackerFrame.timeBar:CreateTexture(nil, "BACKGROUND")
	timeBarBackground:SetAllPoints(combatTimeTrackerFrame.timeBar, true)
	timeBarBackground:SetColorTexture(0.2, 0.2, 0.2, 0.8)

	local timeBarBorder = CreateFrame("Frame", nil, combatTimeTrackerFrame.timeBar, "BackdropTemplate")
	timeBarBorder:SetPoint("TOPLEFT", combatTimeTrackerFrame.timeBar, "TOPLEFT", -3, 3)
	timeBarBorder:SetPoint("BOTTOMRIGHT", combatTimeTrackerFrame.timeBar, "BOTTOMRIGHT", 3, -3)
	timeBarBorder:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 8
	})

	combatTimeTrackerFrame.name = combatTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	combatTimeTrackerFrame.name:SetPoint("TOP", combatTimeTrackerFrame.timeBar, "BOTTOM", 0, -8)
	combatTimeTrackerFrame.name:SetWidth(140)
	combatTimeTrackerFrame.name:SetWordWrap(false)
	combatTimeTrackerFrame.name:SetText(L["combat-time-tracker.wait-combat"])

	combatTimeTrackerFrame.difficulty = combatTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	combatTimeTrackerFrame.difficulty:SetPoint("TOP", combatTimeTrackerFrame.name, "BOTTOM", 0, -3)
	combatTimeTrackerFrame.difficulty:SetText("-")

	combatTimeTrackerFrame.closeButton = CreateFrame("Button", nil, combatTimeTrackerFrame, "UIPanelCloseButton")
	combatTimeTrackerFrame.closeButton:SetSize(16, 16)
	combatTimeTrackerFrame.closeButton:SetPoint("TOPRIGHT", combatTimeTrackerFrame, "TOPRIGHT", 4, 4)
	combatTimeTrackerFrame.closeButton:SetScript("OnClick", function()
		combatTimeTrackerFrame:Hide()
		HRT.options.combatTimeTracker["is-visible"] = false
	end)

	combatTimeTrackerFrame.resetButton = CreateFrame("Button", nil, combatTimeTrackerFrame)
	combatTimeTrackerFrame.resetButton:SetSize(16, 16)
	combatTimeTrackerFrame.resetButton:SetPoint("BOTTOMRIGHT", combatTimeTrackerFrame, "BOTTOMRIGHT", -4, 4)
	combatTimeTrackerFrame.resetButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
	combatTimeTrackerFrame.resetButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	combatTimeTrackerFrame.resetButton:SetPushedTexture("Interface\\Buttons\\UI-RefreshButton")

	local pushedTexture = combatTimeTrackerFrame.resetButton:GetPushedTexture()
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("CENTER", combatTimeTrackerFrame.resetButton, "CENTER", 1, -1)
	pushedTexture:SetSize(16, 16)

	combatTimeTrackerFrame.resetButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["combat-time-tracker.button-reset"], 1, 1, 1)
		GameTooltip:Show()
	end)
	combatTimeTrackerFrame.resetButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	combatTimeTrackerFrame.resetButton:SetScript("OnClick", function()
		combatTimeTrackerFrame.timer:SetText("00:00.000")
		combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
		combatTimeTrackerFrame.timeBar:SetValue(1)
		combatTimeTrackerFrame.timeBar:SetStatusBarColor(0.5, 0.5, 0.5)
		combatTimeTrackerFrame.name:SetText(L["combat-time-tracker.wait-combat"])
		combatTimeTrackerFrame.difficulty:SetText("-")
	end)

	local height = 10
    height = height + combatTimeTrackerFrame.timer:GetStringHeight()
    height = height + 7 + combatTimeTrackerFrame.timeBar:GetHeight()
    height = height + 7 + combatTimeTrackerFrame.name:GetStringHeight()
    height = height + 3 + combatTimeTrackerFrame.difficulty:GetStringHeight()
    height = height + 10

    combatTimeTrackerFrame:SetHeight(height)

	combatTimeTrackerFrame:ClearAllPoints()
    combatTimeTrackerFrame:SetPoint(HRT.options.combatTimeTracker["point"], UIParent, HRT.options.combatTimeTracker["relative-point"], HRT.options.combatTimeTracker["offset-x"], HRT.options.combatTimeTracker["offset-y"])

	if HRT.options.combatTimeTracker["is-visible"] then
        combatTimeTrackerFrame:Show()
    else
        combatTimeTrackerFrame:Hide()
    end
end

---------------------
--- Main funtions ---
---------------------

function CombatTimeTracker:Initialize()
    InitializeFrames()
end

function CombatTimeTracker:EncounterStart(encounterID, encounterName, difficultyID)
	currentEncounterID = encounterID
	currentDifficultyID = difficultyID
	currentEncounterName = encounterName

	local isValidEncounter, difficultyName, optionalID, optionalInfo = EncounterCheck(difficultyID)

	Utils:PrintDebug(string.format(
		"Result from EncounterCheck(): isValidEncounter=%s, difficultyName=%s, optionalID=%s, optionalInfo=%s",
		tostring(isValidEncounter),	tostring(difficultyName), tostring(optionalID), tostring(optionalInfo)
	))

	if not isValidEncounter then return false end

	startTime = GetTime()

	currentOptionalID = optionalID
	currentOptionalInfo = optionalInfo
	currentDifficultyName = GetDifficultyName(difficultyID, difficultyName)

    combatTimeTrackerFrame.resetButton:Hide()
    combatTimeTrackerFrame:Show()

    HRT.options.combatTimeTracker["is-visible"] = true

	combatTimeTrackerFrame.name:SetText(encounterName)
   	combatTimeTrackerFrame.difficulty:SetText(currentDifficultyName)

	if not HRT.data.combatEncounter[tostring(currentEncounterID)] then
         HRT.data.combatEncounter[tostring(currentEncounterID)] = {}
    end

    if not HRT.data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)] then
        HRT.data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)] = {}
    end

    if not HRT.data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)] then
        HRT.data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)] = {
			bestVictory = -1,
            victories = 0,
            wipes = 0
        }
    end

	local currentDataSet = HRT.data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)]
	currentBestVictory = currentDataSet.bestVictory

    if currentBestVictory >= THRESHOLD then
        combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, currentBestVictory)
        combatTimeTrackerFrame.timeBar:SetValue(currentBestVictory)
        combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
    else
        combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
        combatTimeTrackerFrame.timeBar:SetValue(1)
        combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 0.5, 1)
    end

    combatTimeTrackerFrame:SetScript("OnUpdate", UpdateTimerFrame)

	return true
end

function CombatTimeTracker:EncounterEnd(success)
    combatTimeTrackerFrame.resetButton:Show()
	combatTimeTrackerFrame:SetScript("OnUpdate", nil)

    local finalTime = GetTime() - startTime

	Utils:PrintDebug("Unrounded time: " .. tostring(finalTime))

	if finalTime < THRESHOLD then
		finalTime = 0.001
	else
		finalTime = math.floor(finalTime * 1000 + 0.5) / 1000
	end

	Utils:PrintDebug("Rounded time: " .. tostring(finalTime))

	local minutes = math.floor(finalTime / 60)
	local seconds = math.floor(finalTime % 60)
	local milliseconds = math.floor((finalTime * 1000) % 1000)
    combatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

	local currentDataSet = HRT.data.combatEncounter[tostring(currentEncounterID)][tostring(currentDifficultyID)][tostring(currentOptionalID)]
	local bestVictory = currentDataSet.bestVictory
	local victories = currentDataSet.victories
	local wipes = currentDataSet.wipes

    if success == 1 then
		victories = victories + 1
		currentDataSet.victories = victories

		if bestVictory < THRESHOLD or finalTime < bestVictory then
			currentDataSet.bestVictory = finalTime
		end

		if HRT.options.general["notification"] then
			if bestVictory < THRESHOLD or finalTime < bestVictory then
				Utils:PrintMessage(L["chat.new-record"]:format(currentEncounterName, currentDifficultyName, string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)))
			else
				local bestVictoryMinutes = math.floor(bestVictory / 60)
				local bestVictorySsconds = math.floor(bestVictory % 60)
				local bestVictoryMilliseconds = math.floor((bestVictory * 1000) % 1000)

				Utils:PrintMessage(L["chat.current-record"]:format(currentEncounterName, currentDifficultyName, string.format("%02d:%02d.%03d", bestVictoryMinutes, bestVictorySsconds, bestVictoryMilliseconds)))
			end

			if victories == 1 then
				Utils:PrintMessage(L["chat.first-victory"]:format(currentEncounterName, currentDifficultyName, wipes))
			else
				Utils:PrintMessage(L["chat.another-victory"]:format(currentEncounterName, currentDifficultyName, victories, wipes))
			end
		end
	else
		wipes = wipes + 1
		currentDataSet.wipes = wipes

		if HRT.options.general["notification"] then
			if bestVictory >= THRESHOLD then
				local bestVictoryMinutes = math.floor(bestVictory / 60)
				local bestVictorySsconds = math.floor(bestVictory % 60)
				local bestVictoryMilliseconds = math.floor((bestVictory * 1000) % 1000)

				Utils:PrintMessage(L["chat.current-record"]:format(currentEncounterName, currentDifficultyName, string.format("%02d:%02d.%03d", bestVictoryMinutes, bestVictorySsconds, bestVictoryMilliseconds)))
			end

			if wipes == 1 then
				Utils:PrintMessage(L["chat.first-wipe"]:format(currentEncounterName, currentDifficultyName, victories))
			else
				Utils:PrintMessage(L["chat.another-wipe"]:format(currentEncounterName, currentDifficultyName, victories, wipes))
			end
		end
    end

	startTime = 0
	currentBestVictory = -1
	currentEncounterID = 0
	currentDifficultyID = 0
	currentDifficultyName = nil
	currentOptionalID = 0
	currentOptionalInfo = nil
	currentEncounterName = nil
end

function CombatTimeTracker:IsShown()
	return combatTimeTrackerFrame:IsShown()
end

function CombatTimeTracker:Show()
	combatTimeTrackerFrame:Show()
	HRT.options.combatTimeTracker["is-visible"] = true
end

function CombatTimeTracker:Hide()
	combatTimeTrackerFrame:Hide()
	HRT.options.combatTimeTracker["is-visible"] = false
end

function CombatTimeTracker:SetScale()
	combatTimeTrackerFrame:SetScale(HRT.options.combatTimeTracker["scale"] / 100)
end

function CombatTimeTracker:SetBackgroundTransparency()
	combatTimeTrackerFrame.background:SetColorTexture(0, 0, 0, HRT.options.combatTimeTracker["background-transparency"] / 100)
end

HRT.CombatTimeTracker = CombatTimeTracker
