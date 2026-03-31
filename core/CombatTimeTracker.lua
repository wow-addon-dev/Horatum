local addonName, HRT = ...

local L = HRT.Localization
local Utils = HRT.Utils

local CombatTimeTracker = {}

local startTime = 0
local currentBestTime = 0
local currentEncounterID = nil
local currentDifficultyID = nil
local currentDifficultyName = nil
local currentOptionalID = nil
local currentOptionalInfo = nil
local currentEncounterName = nil

--------------
--- Frames ---
--------------

local combatTimeTrackerFrame

----------------------
--- Local Funtions ---
----------------------

local function CheckInstance()
	local _, instanceType, difficultyID, difficultyName = GetInstanceInfo()

	Utils:PrintDebug("Result from GetInstanceInfo(): instanceType=" .. instanceType .. ", difficultyID=" .. difficultyID .. ", difficultyName=" .. difficultyName)

	if currentDifficultyID == tostring(difficultyID) then
		if difficultyID == 1 and instanceType == "party" then				-- Dugenon Normal
			return true, difficultyName, "0", nil
		elseif difficultyID == 2 and instanceType == "party"  then			-- Dugenon Heroisch
			return true, difficultyName, "0", nil
		elseif difficultyID == 23 and instanceType == "party"  then			-- Dugenon Mythisch
			return true, difficultyName, "0", nil
		elseif difficultyID == 14 and instanceType == "raid"  then			-- Raid Normal
			return true, difficultyName, "0", nil
		elseif difficultyID == 15 and instanceType == "raid"  then			-- Raid Heroisch
			return true, difficultyName, "0", nil
		elseif difficultyID == 16 and instanceType == "raid"  then			-- Raid Mythisch
			return true, difficultyName, "0", nil
		elseif difficultyID == 17 and instanceType == "raid"  then			-- Raid Schlachtzugbrowser
			return true, difficultyName, "0", nil
		elseif difficultyID == 208 and instanceType == "scenario"  then		-- Tiefe
			local delveData1, delveData2, delveData3 = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6183), C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6184), C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(6185)

			if delveData1 then
				if delveData1 and delveData1.tierText then
					return true, difficultyName, delveData1.tierText, delveData1.tierText
				end
			elseif delveData2 and delveData2.shownState and delveData2.shownState == 1 then
				return true, difficultyName, "8", "?"
			elseif delveData3 and delveData3.shownState and delveData3.shownState == 1 then
				return true, difficultyName, "11", "??"
			end
		end
	end

	return false, nil, nil, nil
end

local function GetDifficultyName(difficultyName)
	if difficultyName then
		if currentDifficultyID == "208" then
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

    if currentBestTime ~= 0 then
        local remainingTime = currentBestTime - currentTime

        if remainingTime > 0 then
            combatTimeTrackerFrame.timeBar:SetValue(remainingTime)
            combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
        else
            combatTimeTrackerFrame.timeBar:SetValue(currentBestTime)
            combatTimeTrackerFrame.timeBar:SetStatusBarColor(1, 0, 0)
        end
    end
end

----------------------
--- Frame Funtions ---
----------------------

function InitializeFrames()
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
	currentEncounterID = tostring(encounterID)
	currentDifficultyID = tostring(difficultyID)
	currentEncounterName = encounterName

	local isValidEncounter, difficultyName, optionalID, optionalInfo  = CheckInstance()

	Utils:PrintDebug("Result from CheckInstance(): isValidEncounter=".. tostring(isValidEncounter) .. ", difficultyName=" .. tostring(difficultyName) .. ", optionalID=" .. tostring(optionalID) .. ", optionalInfo=" .. tostring(optionalInfo))

	if not isValidEncounter then return false end

	startTime = GetTime()

	currentOptionalID = optionalID
	currentOptionalInfo = optionalInfo
	currentDifficultyName = GetDifficultyName(difficultyName)

    combatTimeTrackerFrame.resetButton:Hide()
    combatTimeTrackerFrame:Show()

    HRT.options.combatTimeTracker["is-visible"] = true

	combatTimeTrackerFrame.name:SetText(encounterName)
   	combatTimeTrackerFrame.difficulty:SetText(currentDifficultyName)

	if not HRT.data.combatEncounter[currentEncounterID] then
         HRT.data.combatEncounter[currentEncounterID] = {}
    end

    if not HRT.data.combatEncounter[currentEncounterID][currentDifficultyID] then
        HRT.data.combatEncounter[currentEncounterID][currentDifficultyID] = {}
    end

    if not HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID] then
		---@diagnostic disable-next-line: need-check-nil
        HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID] = {
			bestVictory = 0,
            victories = 0,
            wipes = 0
        }
    end

	local currentDataSet = HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID]
	currentBestTime = currentDataSet.bestVictory

    if currentBestTime ~= 0 then
        combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, currentBestTime)
        combatTimeTrackerFrame.timeBar:SetValue(currentBestTime)
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
	local minutes = math.floor(finalTime / 60)
	local seconds = math.floor(finalTime % 60)
	local milliseconds = math.floor((finalTime * 1000) % 1000)
    combatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

	local currentDataSet = HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID]
	local bestTime = currentDataSet.bestVictory
	local victories = currentDataSet.victories
	local wipes = currentDataSet.wipes

    if success == 1 then
		victories = victories + 1
		HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID].victories = victories

		if bestTime == 0 or finalTime < bestTime then
			HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID].bestVictory = finalTime
		end

		if HRT.options.general["notification"] then
			if bestTime == 0 or finalTime < bestTime then
				Utils:PrintMessage(L["chat.new-record"]:format(currentEncounterName, currentDifficultyName, string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)))
			else
				local oldMinutes = math.floor(bestTime / 60)
				local oldSsconds = math.floor(bestTime % 60)
				local oldMilliseconds = math.floor((bestTime * 1000) % 1000)

				Utils:PrintMessage(L["chat.current-record"]:format(currentEncounterName, currentDifficultyName, string.format("%02d:%02d.%03d", oldMinutes, oldSsconds, oldMilliseconds)))
			end

			if victories == 1 then
				Utils:PrintMessage(L["chat.first-victory"]:format(currentEncounterName, currentDifficultyName, wipes))
			else
				Utils:PrintMessage(L["chat.another-victory"]:format(currentEncounterName, currentDifficultyName, victories, wipes))
			end
		end
	else
		wipes = wipes + 1
		HRT.data.combatEncounter[currentEncounterID][currentDifficultyID][currentOptionalID].wipes = wipes

		if HRT.options.general["notification"] then
			if bestTime ~= 0 then
				local oldMinutes = math.floor(bestTime / 60)
				local oldSsconds = math.floor(bestTime % 60)
				local oldMilliseconds = math.floor((bestTime * 1000) % 1000)

				Utils:PrintMessage(L["chat.current-record"]:format(currentEncounterName, currentDifficultyName, string.format("%02d:%02d.%03d", oldMinutes, oldSsconds, oldMilliseconds)))
			end

			if wipes == 1 then
				Utils:PrintMessage(L["chat.first-wipe"]:format(currentEncounterName, currentDifficultyName, victories))
			else
				Utils:PrintMessage(L["chat.another-wipe"]:format(currentEncounterName, currentDifficultyName, victories, wipes))
			end
		end
    end

	startTime = 0
	currentBestTime = 0
	currentEncounterID = nil
	currentDifficultyID = nil
	currentDifficultyName = nil
	currentOptionalID = nil
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
