local addonName, HRT = ...

local L = HRT.Localization

local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

local Utils = HRT.modules.Utils

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
