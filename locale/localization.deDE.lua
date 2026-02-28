local _, HRT = ...

if GetLocale() ~= "deDE" then return end

local L = HRT.Localization

-- Generel

L["addon.version"] = "Version"

-- Combat Time Tracker

L["tracker.unknown"] = "unbekannt"
L["tracker.button-reset"] = "Reset"
L["tracker.wait-combat"] = "Warte auf Kampf..."

-- Chat

L["chat.new-record"] = "Neue Bestzeit für %s (%s). (%s)"
