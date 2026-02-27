local addonName, HRT = ...

local L = HRT.Localization
local Utils = HRT.Utils

local BattleTimeTracker = {}

local startTime = 0
local currentDBKey = nil

local resetButton
local bossNameText
local difficultyText
local bestTimeBar
local timerText

--------------
--- Frames ---
--------------

local battleTimeTrackerFrame

----------------------
--- Local funtions ---
----------------------

local function UpdateTimerFrame(self, elapsed)
    local currentTime = GetTime() - startTime

    local minutes = math.floor(currentTime / 60)
    local seconds = math.floor(currentTime % 60)
    local milliseconds = math.floor((currentTime * 1000) % 1000)
    timerText:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

    if currentDBKey and HRT.data.timeTracker[currentDBKey] then
        local bestTime = HRT.data.timeTracker[currentDBKey]
        local remainingTime = bestTime - currentTime

        if remainingTime > 0 then
            bestTimeBar:SetValue(remainingTime)
            bestTimeBar:SetStatusBarColor(0, 1, 0)
        else
            bestTimeBar:SetValue(bestTime)
            bestTimeBar:SetStatusBarColor(1, 0, 0)
        end
    end
end

----------------------
--- Frame Funtions ---
----------------------

function InitializeFrames()
	battleTimeTrackerFrame = CreateFrame("Frame", "BossTimerFrame", UIParent)
	battleTimeTrackerFrame:SetSize(160, 85)

	battleTimeTrackerFrame:SetMovable(true)
	battleTimeTrackerFrame:EnableMouse(true)
	battleTimeTrackerFrame:RegisterForDrag("LeftButton")
	battleTimeTrackerFrame:SetScript("OnDragStart", battleTimeTrackerFrame.StartMoving)

	battleTimeTrackerFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		if HoratumSettings then
			HoratumSettings.point = point
			HoratumSettings.relativePoint = relativePoint
			HoratumSettings.xOfs = xOfs
			HoratumSettings.yOfs = yOfs
		end
	end)

	local bg = battleTimeTrackerFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(battleTimeTrackerFrame,true)
	bg:SetColorTexture(0, 0, 0, 0.6)

	timerText = battleTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
	timerText:SetPoint("TOP", battleTimeTrackerFrame, "TOP", 0, -10)
	timerText:SetText("00:00.000")

	bestTimeBar = CreateFrame("StatusBar", nil, battleTimeTrackerFrame)
	bestTimeBar:SetSize(140, 10)
	bestTimeBar:SetPoint("TOP", timerText, "BOTTOM", 0, -5)
	bestTimeBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

	local barBg = bestTimeBar:CreateTexture(nil, "BACKGROUND")
	--barBg:SetAllPoints(bg,true)
	barBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

	bossNameText = battleTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bossNameText:SetPoint("TOP", bestTimeBar, "BOTTOM", 0, -5)
	bossNameText:SetText(L["tracker.wait-fight"])

	difficultyText = battleTimeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	difficultyText:SetPoint("TOP", bossNameText, "BOTTOM", 0, -2)
	difficultyText:SetText("")

	local closeButton = CreateFrame("Button", nil, battleTimeTrackerFrame)
	closeButton:SetSize(20, 20)
	closeButton:SetPoint("TOPRIGHT", battleTimeTrackerFrame, "TOPRIGHT", -2, -2)

	local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	closeText:SetPoint("CENTER")
	closeText:SetText("X")

	closeButton:SetScript("OnEnter", function() closeText:SetTextColor(1, 0, 0) end)
	closeButton:SetScript("OnLeave", function() closeText:SetTextColor(1, 0.82, 0) end)

	closeButton:SetScript("OnClick", function()
		battleTimeTrackerFrame:Hide()
		if HoratumSettings then
			HoratumSettings.isVisible = false
		end
	end)

	resetButton = CreateFrame("Button", nil, battleTimeTrackerFrame)
	resetButton:SetSize(16, 16)
	resetButton:SetPoint("BOTTOMRIGHT", battleTimeTrackerFrame, "BOTTOMRIGHT", -4, 4)

	resetButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
	resetButton:SetPushedTexture("Interface\\Buttons\\UI-RefreshButton")

	local pushedTexture = resetButton:GetPushedTexture()
	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("CENTER", resetButton, "CENTER", 1, -1)
	pushedTexture:SetSize(16, 16)

	resetButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

	resetButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Reset", 1, 1, 1)
		GameTooltip:Show()
	end)
	resetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

	resetButton:SetScript("OnClick", function()
		if not currentDBKey then
			timerText:SetText("00:00.000")
			bestTimeBar:SetMinMaxValues(0, 1)
			bestTimeBar:SetValue(1)
			bestTimeBar:SetStatusBarColor(0.5, 0.5, 0.5)
			bossNameText:SetText(L["tracker.wait-fight"])
			difficultyText:SetText("-")
		end
	end)

	battleTimeTrackerFrame:ClearAllPoints()
    battleTimeTrackerFrame:SetPoint(HoratumSettings.point, UIParent, HoratumSettings.relativePoint, HoratumSettings.xOfs, HoratumSettings.yOfs)

    if HoratumSettings.isVisible then
        battleTimeTrackerFrame:Show()
    else
        battleTimeTrackerFrame:Hide()
    end

	bestTimeBar:SetMinMaxValues(0, 1)
    bestTimeBar:SetValue(1)
    bestTimeBar:SetStatusBarColor(0.5, 0.5, 0.5)
end

---------------------
--- Main funtions ---
---------------------

function BattleTimeTracker:Initialize()
    InitializeFrames()
end

function BattleTimeTracker:EncounterStart(encounterKey, encounterName)
    resetButton:Hide()

	currentDBKey = encounterKey

    battleTimeTrackerFrame:Show()

    HoratumSettings.isVisible = true

    startTime = GetTime()
    bossNameText:SetText(encounterName)

    local _, _, _, difficultyName = GetInstanceInfo()
    difficultyText:SetText(difficultyName or L["tracker.unknown"])

    if HRT.data.timeTracker[currentDBKey] then
        local best = HRT.data.timeTracker[currentDBKey]
        bestTimeBar:SetMinMaxValues(0, best)
        bestTimeBar:SetValue(best)
        bestTimeBar:SetStatusBarColor(0, 1, 0)
    else
        bestTimeBar:SetMinMaxValues(0, 1)
        bestTimeBar:SetValue(1)
        bestTimeBar:SetStatusBarColor(0, 0.5, 1)
    end

    battleTimeTrackerFrame:SetScript("OnUpdate", UpdateTimerFrame)
end

function BattleTimeTracker:EncounterEnd(encounterKey, encounterName, success)
    battleTimeTrackerFrame:SetScript("OnUpdate", nil)

    currentDBKey = nil

    resetButton:Show()

    local finalTime = GetTime() - startTime
    local minutes = math.floor(finalTime / 60)
    local seconds = math.floor(finalTime % 60)
    local milliseconds = math.floor((finalTime * 1000) % 1000)

    timerText:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

    if success == 1 then
        local oldBest = HRT.data.timeTracker[encounterKey]
        if not oldBest or finalTime < oldBest then
			HRT.data.timeTracker[encounterKey] = finalTime

			local _, _, _, difficultyName = GetInstanceInfo()
			local diffText = difficultyName or L["tracker.unknown"]

			Utils:PrintMessage(L["chat.new-record"]:format(encounterName, diffText, string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)))
        end
    end
end

function BattleTimeTracker:Show()
	battleTimeTrackerFrame:Show()
end

HRT.BattleTimeTracker = BattleTimeTracker
