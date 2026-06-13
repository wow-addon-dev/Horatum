local addonName, HRT = ...

HRT.settings = HRT.settings or {}
HRT.data = HRT.data or {}
HRT.state = HRT.state or {}
HRT.modules = HRT.modules or {}

local AWL = ArcaneWizardLibrary

AWL:NewAddon(addonName, {
	debugEnabled = function()
		return HRT.settings.general and HRT.settings.general["debug-mode"]
	end
})
