local addonName, HRT = ...

local L = HRT.localization
local Utils = HRT.utils

local TimeTracker = {}

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

local timeTrackerFrame

----------------------
--- Local funtions ---
----------------------

local function UpdateTimerFrame(self, elapsed)
    local currentTime = GetTime() - startTime

    local minutes = math.floor(currentTime / 60)
    local seconds = math.floor(currentTime % 60)
    local milliseconds = math.floor((currentTime * 1000) % 1000)
    timerText:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

    if currentDBKey and HoratumKillTimes[currentDBKey] then
        local bestTime = HoratumKillTimes[currentDBKey]
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
	timeTrackerFrame = CreateFrame("Frame", "BossTimerFrame", UIParent)
	timeTrackerFrame:SetSize(160, 85)

	timeTrackerFrame:SetMovable(true)
	timeTrackerFrame:EnableMouse(true)
	timeTrackerFrame:RegisterForDrag("LeftButton")
	timeTrackerFrame:SetScript("OnDragStart", timeTrackerFrame.StartMoving)

	timeTrackerFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
		if HoratumSettings then
			HoratumSettings.point = point
			HoratumSettings.relativePoint = relativePoint
			HoratumSettings.xOfs = xOfs
			HoratumSettings.yOfs = yOfs
		end
	end)

	local bg = timeTrackerFrame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(timeTrackerFrame,true)
	bg:SetColorTexture(0, 0, 0, 0.6)

	timerText = timeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
	timerText:SetPoint("TOP", timeTrackerFrame, "TOP", 0, -10)
	timerText:SetText("00:00.000")

	bestTimeBar = CreateFrame("StatusBar", nil, timeTrackerFrame)
	bestTimeBar:SetSize(140, 10)
	bestTimeBar:SetPoint("TOP", timerText, "BOTTOM", 0, -5)
	bestTimeBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")

	local barBg = bestTimeBar:CreateTexture(nil, "BACKGROUND")
	--barBg:SetAllPoints(bg,true)
	barBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

	bossNameText = timeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bossNameText:SetPoint("TOP", bestTimeBar, "BOTTOM", 0, -5)
	bossNameText:SetText(L["tracker.wait-fight"])

	difficultyText = timeTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	difficultyText:SetPoint("TOP", bossNameText, "BOTTOM", 0, -2)
	difficultyText:SetText("")

	local closeButton = CreateFrame("Button", nil, timeTrackerFrame)
	closeButton:SetSize(20, 20)
	closeButton:SetPoint("TOPRIGHT", timeTrackerFrame, "TOPRIGHT", -2, -2)

	local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	closeText:SetPoint("CENTER")
	closeText:SetText("X")

	closeButton:SetScript("OnEnter", function() closeText:SetTextColor(1, 0, 0) end)
	closeButton:SetScript("OnLeave", function() closeText:SetTextColor(1, 0.82, 0) end)

	closeButton:SetScript("OnClick", function()
		timeTrackerFrame:Hide()
		if HoratumSettings then
			HoratumSettings.isVisible = false
		end
	end)

	resetButton = CreateFrame("Button", nil, timeTrackerFrame)
	resetButton:SetSize(16, 16)
	resetButton:SetPoint("BOTTOMRIGHT", timeTrackerFrame, "BOTTOMRIGHT", -4, 4)

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
			difficultyText:SetText("")
		end
	end)

	timeTrackerFrame:ClearAllPoints()
    timeTrackerFrame:SetPoint(HoratumSettings.point, UIParent, HoratumSettings.relativePoint, HoratumSettings.xOfs, HoratumSettings.yOfs)

    if HoratumSettings.isVisible then
        timeTrackerFrame:Show()
    else
        timeTrackerFrame:Hide()
    end

	bestTimeBar:SetMinMaxValues(0, 1)
    bestTimeBar:SetValue(1)
    bestTimeBar:SetStatusBarColor(0.5, 0.5, 0.5)
end

---------------------
--- Main funtions ---
---------------------

function TimeTracker:Initialize()
    InitializeFrames()
end

function TimeTracker:EncounterStart(encounterKey, encounterName)
    resetButton:Hide()

	currentDBKey = encounterKey

        timeTrackerFrame:Show()
        if HoratumSettings then
            HoratumSettings.isVisible = true
        end

        startTime = GetTime()
        bossNameText:SetText(encounterName)

        local _, _, _, difficultyName = GetInstanceInfo()
        difficultyText:SetText(difficultyName or "unknown")

        if HoratumKillTimes[currentDBKey] then
            local best = HoratumKillTimes[currentDBKey]
            bestTimeBar:SetMinMaxValues(0, best)
            bestTimeBar:SetValue(best)
            bestTimeBar:SetStatusBarColor(0, 1, 0)
        else
            bestTimeBar:SetMinMaxValues(0, 1)
            bestTimeBar:SetValue(1)
            bestTimeBar:SetStatusBarColor(0, 0.5, 1)
        end

        timeTrackerFrame:SetScript("OnUpdate", UpdateTimerFrame)
end

function TimeTracker:EncounterEnd(encounterKey, encounterName, success)
    timeTrackerFrame:SetScript("OnUpdate", nil)

    currentDBKey = nil

    resetButton:Show()

    local finalTime = GetTime() - startTime
    local minutes = math.floor(finalTime / 60)
    local seconds = math.floor(finalTime % 60)
    local milliseconds = math.floor((finalTime * 1000) % 1000)

    timerText:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

    if success == 1 then
        local oldBest = HoratumKillTimes[encounterKey]
        if not oldBest or finalTime < oldBest then
			HoratumKillTimes[encounterKey] = finalTime

			local _, _, _, difficultyName = GetInstanceInfo()
			local diffText = difficultyName or "unknonw"

			Utils:PrintMessage(L["chat.new-record"]:format(encounterName, diffText, string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)))
        end
    end
end

HRT.timeTracker = TimeTracker
