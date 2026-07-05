local addonName, HRT = ...

HRT.Settings = HRT.Settings or {}
HRT.Data = HRT.Data or {}
HRT.State = HRT.State or {}
HRT.Modules = HRT.Modules or {}

HRT.Modules.CombatTimeTracker = HRT.Modules.CombatTimeTracker or {}
HRT.Modules.Options = HRT.Modules.Options or {}
HRT.Modules.Utils = HRT.Modules.Utils or {}

local AWL = ArcaneWizardLibrary

AWL:NewAddon(addonName)
