local addonName, HRT = ...

local L = HRT.Localization
local Utils = HRT.Utils

local CombatTimeTracker = {}

local startTime = 0
local isInCombat = false
local currentEncounterKey = nil

--------------
--- Frames ---
--------------

local combatTimeTrackerFrame

----------------------
--- Local funtions ---
----------------------

local function UpdateTimerFrame(self, elapsed)
    local currentTime = GetTime() - startTime

    local minutes = math.floor(currentTime / 60)
    local seconds = math.floor(currentTime % 60)
    local milliseconds = math.floor((currentTime * 1000) % 1000)
    combatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

    if currentEncounterKey and HRT.data.combatTime[currentEncounterKey] then
        local bestTime = HRT.data.combatTime[currentEncounterKey]
        local remainingTime = bestTime - currentTime

        if remainingTime > 0 then
            combatTimeTrackerFrame.timeBar:SetValue(remainingTime)
            combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
        else
            combatTimeTrackerFrame.timeBar:SetValue(bestTime)
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
		if not isInCombat then
			combatTimeTrackerFrame.timer:SetText("00:00.000")
			combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
			combatTimeTrackerFrame.timeBar:SetValue(1)
			combatTimeTrackerFrame.timeBar:SetStatusBarColor(0.5, 0.5, 0.5)
			combatTimeTrackerFrame.name:SetText(L["combat-time-tracker.wait-combat"])
			combatTimeTrackerFrame.difficulty:SetText("-")
		end
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

function CombatTimeTracker:EncounterStart(encounterKey, encounterName)
    combatTimeTrackerFrame.resetButton:Hide()
    combatTimeTrackerFrame:Show()

	startTime = GetTime()
	isInCombat = true
	currentEncounterKey = encounterKey
    HRT.options.combatTimeTracker["is-visible"] = true

    local _, _, _, difficultyName = GetInstanceInfo()
	combatTimeTrackerFrame.name:SetText(encounterName)
   	combatTimeTrackerFrame.difficulty:SetText(difficultyName or L["combat-time-tracker.unknown"])

    if HRT.data.combatTime[encounterKey] then
        local best = HRT.data.combatTime[encounterKey]
        combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, best)
        combatTimeTrackerFrame.timeBar:SetValue(best)
        combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 1, 0)
    else
        combatTimeTrackerFrame.timeBar:SetMinMaxValues(0, 1)
        combatTimeTrackerFrame.timeBar:SetValue(1)
        combatTimeTrackerFrame.timeBar:SetStatusBarColor(0, 0.5, 1)
    end

    combatTimeTrackerFrame:SetScript("OnUpdate", UpdateTimerFrame)
end

function CombatTimeTracker:EncounterEnd(encounterKey, encounterName, success)
    combatTimeTrackerFrame.resetButton:Show()
	combatTimeTrackerFrame:SetScript("OnUpdate", nil)

    isInCombat = false

    local finalTime = GetTime() - startTime
	local minutes = math.floor(finalTime / 60)
	local seconds = math.floor(finalTime % 60)
	local milliseconds = math.floor((finalTime * 1000) % 1000)
    combatTimeTrackerFrame.timer:SetText(string.format("%02d:%02d.%03d", minutes, seconds, milliseconds))

	local _, _, _, difficultyName = GetInstanceInfo()
	local difficultyText = difficultyName or L["combat-time-tracker.unknown"]

	local bestTime = HRT.data.combatTime[encounterKey]
	local encounter = HRT.data.combatEncounter[encounterKey]

	if not encounter then
		encounter = {
			victories = 0,
			wipes = 0
		}
		HRT.data.combatEncounter[encounterKey] = encounter
	end

    if success == 1 then
		encounter.victories = encounter.victories + 1
		HRT.data.combatEncounter[encounterKey] = encounter

		if not bestTime or finalTime < bestTime then
			HRT.data.combatTime[encounterKey] = finalTime
		end

		if not HRT.options.general["notification"] then return end

        if not bestTime or finalTime < bestTime then
			Utils:PrintMessage(L["chat.new-record"]:format(encounterName, difficultyText, string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)))
		else
			local oldMinutes = math.floor(bestTime / 60)
			local oldSsconds = math.floor(bestTime % 60)
			local oldMilliseconds = math.floor((bestTime * 1000) % 1000)

			Utils:PrintMessage(L["chat.current-record"]:format(encounterName, difficultyText, string.format("%02d:%02d.%03d", oldMinutes, oldSsconds, oldMilliseconds)))
		end

		if encounter.victories == 1 then
			Utils:PrintMessage(L["chat.first-victory"]:format(encounterName, difficultyText, encounter.wipes))
		else
			Utils:PrintMessage(L["chat.another-victory"]:format(encounterName, difficultyText, encounter.victories, encounter.wipes))
		end
	else
		encounter.wipes = encounter.wipes + 1
		HRT.data.combatEncounter[encounterKey] = encounter

		if not HRT.options.general["notification"] then return end

		if bestTime then
			local oldMinutes = math.floor(bestTime / 60)
			local oldSsconds = math.floor(bestTime % 60)
			local oldMilliseconds = math.floor((bestTime * 1000) % 1000)

			Utils:PrintMessage(L["chat.current-record"]:format(encounterName, difficultyText, string.format("%02d:%02d.%03d", oldMinutes, oldSsconds, oldMilliseconds)))
		end

		if encounter.wipes == 1 then
			Utils:PrintMessage(L["chat.first-wipe"]:format(encounterName, difficultyText, encounter.victories))
		else
			Utils:PrintMessage(L["chat.another-wipe"]:format(encounterName, difficultyText, encounter.victories, encounter.wipes))
		end
    end
end

function CombatTimeTracker:Show()
	combatTimeTrackerFrame:Show()
	HRT.options.combatTimeTracker["is-visible"] = true
end

function CombatTimeTracker:SetScale()
	combatTimeTrackerFrame:SetScale(HRT.options.combatTimeTracker["scale"] / 100)
end

function CombatTimeTracker:SetBackgroundTransparency()
	combatTimeTrackerFrame.background:SetColorTexture(0, 0, 0, HRT.options.combatTimeTracker["background-transparency"] / 100)
end

HRT.CombatTimeTracker = CombatTimeTracker
