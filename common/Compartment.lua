local addonName, HRT = ...

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = HRT.Localization

-- Module imports
local Utils = HRT.Modules.Utils

-- Variables
local compartmentHandlers = Addon:CreateCompartmentHandlers({
	tooltip = L["minimap-button.tooltip"],
	onLeftClick = function()
		Utils:ToggleCombatTimeTracker()
	end
})

------------------------
--- Public Functions ---
------------------------

function Horatum_CompartmentOnEnter(self, button)
	compartmentHandlers.OnEnter(self, button)
end

function Horatum_CompartmentOnLeave()
	compartmentHandlers.OnLeave()
end

function Horatum_CompartmentOnClick(self, button)
	compartmentHandlers.OnClick(self, button)
end
