local addonName, HRT = ...

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = HRT.Localization

-- Current module
local Options = HRT.Modules.Options

-- Module imports
local CombatTimeTracker = HRT.Modules.CombatTimeTracker
local Utils = HRT.Modules.Utils

-- Variables
local minimapButtonProxy = setmetatable({}, {
	__index = function(_, key)
		if key == "hide" then
			return not HRT.Settings.general["minimap-button"]["hide"]
		end
	end,
	__newindex = function(_, key, value)
		if key ~= "hide" then
			return
		end

		HRT.Settings.general["minimap-button"]["hide"] = not value

		if value then
			Utils.minimapButton:Show(addonName)
		else
			Utils.minimapButton:Hide(addonName)
		end
	end,
})

------------------------
--- Module Functions ---
------------------------

function Options:Initialize()
	local category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.general"]))

	-- Notification
	AWL.Settings:AddCheckbox(category, {
		variableTable	= HRT.Settings.general,
		settingKey		= addonName .. "_notification",
		variableName	= "notification",
		name			= L["options.general.notification.name"],
		tooltip			= L["options.general.notification.tooltip"],
		default			= true
	})

	-- Minimap Button
	AWL.Settings:AddCheckbox(category, {
		variableTable	= minimapButtonProxy,
		settingKey		= addonName .. "_hide",
		variableName	= "hide",
		name			= L["options.general.minimap-button.name"],
		tooltip			= L["options.general.minimap-button.tooltip"],
		default			= true
	})

	-- Debug Mode
	AWL.Settings:AddCheckbox(category, {
		variableTable	= HRT.Settings.general,
		settingKey		= addonName .. "_debug-mode",
		variableName	= "debug-mode",
		name			= L["options.general.debug-mode.name"],
		tooltip			= L["options.general.debug-mode.tooltip"],
		default			= false
	})

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.combat-time-tracker"]))

	-- Scale
	AWL.Settings:AddSlider(category, {
		variableTable	= HRT.Settings.combatTimeTracker,
		settingKey		= addonName .. "_scale",
		variableName	= "scale",
		name			= L["options.combat-time-tracker.scale.name"],
		tooltip			= L["options.combat-time-tracker.scale.tooltip"],
		default			= 100, minValue = 50, maxValue = 150, step = 1,
		formatter		= function(value) return value .. " %" end,
		onClick			= function()
			CombatTimeTracker:Show()
			CombatTimeTracker:SetScale()
		end
	})

	-- Background Transparency
	AWL.Settings:AddSlider(category, {
		variableTable	= HRT.Settings.combatTimeTracker,
		settingKey		= addonName .. "_background-transparency",
		variableName	= "background-transparency",
		name			= L["options.combat-time-tracker.background-transparency.name"],
		tooltip			= L["options.combat-time-tracker.background-transparency.tooltip"],
		default			= 60, minValue = 0, maxValue = 100, step = 1,
		formatter		= function(value) return value .. " %" end,
		onClick			= function()
			CombatTimeTracker:Show()
			CombatTimeTracker:SetBackgroundTransparency()
		end
	})

	-- Profiles Section
	AWL.Settings:AddProfilesSection(layout, {
		useAccountProfile			= Utils:IsAccountProfile(),
		onSwitchProfile				= function()
			Utils:ToggleProfileMode()
			ReloadUI()
		end,
		onDeleteCharacterProfiles	= function()
			Utils:ResetAllCharacterProfiles()
			ReloadUI()
		end
	})

	-- About Section
	AWL.Settings:AddAboutSection(layout, addonName)

	Settings.RegisterAddOnCategory(category)

	Addon:SetMainCategoryId(category:GetID())
end
