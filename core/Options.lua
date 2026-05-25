local addonName, HRT = ...

local L = HRT.Localization

local Utils = HRT.modules.Utils
local CombatTimeTracker = HRT.modules.CombatTimeTracker

local AWL = ArcaneWizardLibrary

local Options = {}

----------------------
--- Local Functions ---
----------------------

local minimapButtonProxy = setmetatable({}, {
    __index = function(_, key)
		if key == "hide" then
			return not HRT.settings.general["minimap-button"]["hide"]
		end
    end,
    __newindex = function(_, key, value)
		if key ~= "hide" then
			return
		end

        HRT.settings.general["minimap-button"]["hide"] = not value

        if value then
            Utils.minimapButton:Show("Horatum")
        else
            Utils.minimapButton:Hide("Horatum")
        end
    end,
})

local function ShowProfileSwitchConfirmation()
	local useAccountProfile = Utils:IsAccountProfile()

	AWL.Dialogs:ShowConfirmDialog(
		AWL.Profiles:GetSwitchConfirmText(useAccountProfile),
		function()
			Utils:ToggleProfileMode()
			ReloadUI()
		end
	)
end

local function ShowDeleteCharacterProfilesConfirmation()
	AWL.Dialogs:ShowConfirmDialog(
		AWL.Profiles:GetText("delete-character-profiles.confirm"),
		function()
			Utils:ResetAllCharacterProfiles()
			ReloadUI()
		end
	)
end

---------------------
--- Main Functions ---
---------------------

function Options:Initialize()
    local category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.general"]))

    -- Notification
    AWL.Settings:AddCheckbox(category, {
        variableTable = HRT.settings.general,
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

    -- Debug Mode
    AWL.Settings:AddCheckbox(category, {
        variableTable = HRT.settings.general,
        settingKey    = addonName .. "_debug-mode",
        variableName  = "debug-mode",
        name          = L["options.general.debug-mode.name"],
        tooltip       = L["options.general.debug-mode.tooltip"],
        default       = false
    })

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.combat-time-tracker"]))

    -- Scale
    AWL.Settings:AddSlider(category, {
        variableTable = HRT.settings.combatTimeTracker,
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
        variableTable = HRT.settings.combatTimeTracker,
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

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(AWL.Profiles:GetText("section-header")))

	-- Active Profile
	AWL.Settings:AddInfoText(layout, {
		leftText  = AWL.Profiles:GetText("profile-mode"),
		rightText = AWL.Profiles:GetModeText(Utils:IsAccountProfile())
	})

	-- Switch Profile
	AWL.Settings:AddButton(layout, {
		name       = AWL.Profiles:GetText("switch.name"),
		buttonText = AWL.Profiles:GetSwitchButtonText(Utils:IsAccountProfile()),
		tooltip    = AWL.Profiles:GetText("switch.tooltip"),
		onClick    = ShowProfileSwitchConfirmation
	})

	-- Delete Character Profiles
	AWL.Settings:AddButton(layout, {
		name       = AWL.Profiles:GetText("delete-character-profiles.name"),
		buttonText = AWL.Profiles:GetText("delete-character-profiles.button"),
		tooltip    = AWL.Profiles:GetText("delete-character-profiles.tooltip"),
		onClick    = ShowDeleteCharacterProfilesConfirmation
	})

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.about"]))

    -- Game Version
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.game-version"],
        rightText = HRT.GAME_VERSION .. " (" .. HRT.GAME_FLAVOR .. ")",
        height    = "compact"
    })

    -- Addon Version
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.addon-version"],
        rightText = HRT.ADDON_VERSION .. " (" .. HRT.ADDON_BUILD_DATE .. ")",
        height    = "compact"
    })

    -- Library Version
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.lib-version"],
        rightText = AWL.ADDON_VERSION .. " (" .. AWL.ADDON_BUILD_DATE .. ")",
        height    = "compact"
    })

    -- Author
    AWL.Settings:AddInfoText(layout, {
        leftText  = L["options.about.author"],
        rightText = HRT.ADDON_AUTHOR
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

HRT.modules.Options = Options
