local addonName, HRT = ...

local L = HRT.Localization
local Utils = HRT.Utils
local CombatTimeTracker = HRT.CombatTimeTracker

local AWL = ArcaneWizardLibrary

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

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.general"]))

    -- Notification
    AWL.Settings:AddCheckbox(category, {
        variableTable = HRT.options.general,
        settingKey    = addonName .. "_notification",
        variableName  = "notification",
        name          = L["options.general.notification.name"],
        tooltip       = L["options.general.notification.tooltip"],
        default       = true
    })

    -- Minimap Button
    AWL.Settings:AddCheckbox(category, {
        variableTable = minimapButtonProxy,
        settingKey    = addonName .. "_hide",
        variableName  = "hide",
        name          = L["options.general.minimap-button.name"],
        tooltip       = L["options.general.minimap-button.tooltip"],
        default       = true
    })


    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.combat-time-tracker"]))

    -- Scale
    AWL.Settings:AddSlider(category, {
        variableTable = HRT.options.combatTimeTracker,
        settingKey    = addonName .. "_scale",
        variableName  = "scale",
        name          = L["options.combat-time-tracker.scale.name"],
        tooltip       = L["options.combat-time-tracker.scale.tooltip"],
        default       = 100, minValue = 50, maxValue = 150, step = 1,
        formatter     = function(value) return value .. " %" end,
        onClick       = function()
            CombatTimeTracker:Show()
            CombatTimeTracker:SetScale()
        end
    })

    -- Background Transparency
    AWL.Settings:AddSlider(category, {
        variableTable = HRT.options.combatTimeTracker,
        settingKey    = addonName .. "_background-transparency",
        variableName  = "background-transparency",
        name          = L["options.combat-time-tracker.background-transparency.name"],
        tooltip       = L["options.combat-time-tracker.background-transparency.tooltip"],
        default       = 60, minValue = 0, maxValue = 100, step = 1,
        formatter     = function(value) return value .. " %" end,
        onClick       = function()
            CombatTimeTracker:Show()
            CombatTimeTracker:SetBackgroundTransparency()
        end
    })

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.other"]))

    -- Debug Mode
    AWL.Settings:AddCheckbox(category, {
        variableTable = HRT.options.other,
        settingKey    = addonName .. "_debug-mode",
        variableName  = "debug-mode",
        name          = L["options.other.debug-mode.name"],
        tooltip       = L["options.other.debug-mode.tooltip"],
        default       = false
    })

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.about"]))

    -- Game Version
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.game-version"],
        rightText = HRT.GAME_VERSION .. " (" .. HRT.GAME_FLAVOR .. ")"
    })

    -- Addon Version
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.addon-version"],
        rightText = HRT.ADDON_VERSION .. " (" .. HRT.ADDON_BUILD_DATE .. ")"
    })

    -- Library Version
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.lib-version"],
        rightText = AWL.ADDON_VERSION .. " (" .. AWL.ADDON_BUILD_DATE .. ")"
    })

    -- Author
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.author"],
        rightText = HRT.ADDON_AUTHOR,
        height    = 30
    })

    -- GitHub Link
    AWL.Settings:AddButton(layout, {
        name       = L["options.about.button-github.name"],
        buttonText = L["options.about.button-github.button"],
        tooltip    = L["options.about.button-github.tooltip"],
        onClick    = function()
			AWL.Dialogs:ShowLinkDialog(HRT.LINK_GITHUB)
		end
    })

    Settings.RegisterAddOnCategory(category)

    HRT.MAIN_CATEGORY_ID = category:GetID()
end

HRT.Options = Options
