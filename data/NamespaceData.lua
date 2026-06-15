local addonName, HRT = ...

HRT.Settings = HRT.Settings or {}
HRT.Data = HRT.Data or {}
HRT.State = HRT.State or {}
HRT.Modules = HRT.Modules or {}

local AWL = ArcaneWizardLibrary

AWL:NewAddon(addonName, {
	debugEnabled = function()
		return HRT.Settings.general and HRT.Settings.general["debug-mode"]
	end
})
