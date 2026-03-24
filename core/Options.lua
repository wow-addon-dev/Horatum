local addonName, HRT = ...

local L = HRT.Localization
local Utils = HRT.Utils
local Dialog = HRT.Dialog
local CombatTimeTracker = HRT.CombatTimeTracker

local Options = {}

----------------------
--- Local Funtions ---
----------------------

local minimapButtonProxy = setmetatable({}, {
    __index = function(_, key)
        return not HRT.options.general["minimap-button"]["hide"]
    end,
    __newindex = function(_, key, value)
        HRT.options.general["minimap-button"]["hide"] = not value

        if value then
            Utils.minimapButton:Show("Horatum")
        else
            Utils.minimapButton:Hide("Horatum")
        end
    end,
})

---------------------
--- Main Funtions ---
---------------------

function Options:Initialize()
    local category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

	local variableTableGeneral = HRT.options.general
	local variableTableCombatTimeTracker = HRT.options.combatTimeTracker
	local variableTableOther = HRT.options.other

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.general"]))

    do
        local name = L["options.general.notification.name"]
        local tooltip = L["options.general.notification.tooltip"]
        local variable = "notification"
        local defaultValue = true

        local setting = Settings.RegisterAddOnSetting(category, addonName .. "_" .. variable, variable, variableTableGeneral, Settings.VarType.Boolean, name, defaultValue)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

	do
        local name = L["options.general.minimap-button.name"]
        local tooltip = L["options.general.minimap-button.tooltip"]
        local variable = "hide"
        local defaultValue = true

        local setting = Settings.RegisterAddOnSetting(category, addonName .. "_" .. variable, variable, minimapButtonProxy, Settings.VarType.Boolean, name, not defaultValue)

        Settings.CreateCheckbox(category, setting, tooltip)
    end

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.combat-time-tracker"]))

    do
        local name = L["options.combat-time-tracker.scale.name"]
        local tooltip = L["options.combat-time-tracker.scale.tooltip"]
        local variable = "scale"
        local defaultValue = 100

        local minValue = 50
        local maxValue = 150
        local step = 1

        local setting = Settings.RegisterAddOnSetting(category, addonName .. "_" .. variable, variable, variableTableCombatTimeTracker, Settings.VarType.Number, name, defaultValue)
		setting:SetValueChangedCallback(function(owner, settingObj, newValue)
			CombatTimeTracker:Show()
            CombatTimeTracker:SetScale()
        end)

		local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value .. " %" end)

        Settings.CreateSlider(category, setting, options, tooltip)
    end

    do
        local name = L["options.combat-time-tracker.background-transparency.name"]
        local tooltip = L["options.combat-time-tracker.background-transparency.tooltip"]
        local variable = "background-transparency"
        local defaultValue = 60

        local minValue = 0
        local maxValue = 100
        local step = 1

        local setting = Settings.RegisterAddOnSetting(category, addonName .. "_" .. variable, variable, variableTableCombatTimeTracker, Settings.VarType.Number, name, defaultValue)
		setting:SetValueChangedCallback(function(owner, settingObj, newValue)
			CombatTimeTracker:Show()
            CombatTimeTracker:SetBackgroundTransparency()
        end)

		local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value .. " %" end)

        Settings.CreateSlider(category, setting, options, tooltip)
    end

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.other"]))

    do
        local name = L["options.other.debug-mode.name"]
        local tooltip = L["options.other.debug-mode.tooltip"]
        local variable = "debug-mode"
        local defaultValue = false

        local setting = Settings.RegisterAddOnSetting(category, addonName .. "_" .. variable, variable, variableTableOther, Settings.VarType.Boolean, name, defaultValue)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.about"]))

	do
		local data = {
			leftText = L["options.about.game-version"],
			rightText = HRT.GAME_VERSION .. " (" .. HRT.GAME_FLAVOR .. ")",
		}

		local text = layout:AddInitializer(Settings.CreateElementInitializer("Horatum_OptionsText", data))

		function text:GetExtent()
			return 14
		end
	end

	do
		local data = {
			leftText = L["options.about.addon-version"],
			rightText = HRT.ADDON_VERSION .. " (" .. HRT.ADDON_BUILD_DATE .. ")"
		}

		local text = layout:AddInitializer(Settings.CreateElementInitializer("Horatum_OptionsText", data))

		function text:GetExtent()
			return 14
		end
	end

	do
		local data = {
			leftText = L["options.about.author"],
			rightText = HRT.ADDON_AUTHOR
		}

		local text = layout:AddInitializer(Settings.CreateElementInitializer("Horatum_OptionsText", data))
	end

	do
        local name = L["options.about.button-github.name"]
        local tooltip = L["options.about.button-github.tooltip"]
		local buttonText = L["options.about.button-github.button"]

        local function OnButtonClick()
            Dialog:ShowCopyAddressDialog(HRT.LINK_GITHUB)
        end

        local buttonInitializer = CreateSettingsButtonInitializer(name, buttonText, OnButtonClick, tooltip, true)
        layout:AddInitializer(buttonInitializer)
    end

    Settings.RegisterAddOnCategory(category)

	HRT.MAIN_CATEGORY_ID = category:GetID()
end

HRT.Options = Options
