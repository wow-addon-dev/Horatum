local _, HRT = ...

if GetLocale() ~= "deDE" then return end

local L = HRT.Localization

-- Options

L["options.tracker"] = "Kampfzeiten-Tracker"
L["options.tracker.scale.name"] = "UI-Skalierung"
L["options.tracker.scale.tooltip"] = "Legt die Größenskalierung des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r fest."
L["options.tracker.background-transparency.name"] = "Hintergrundtransparenz"
L["options.tracker.background-transparency.tooltip"] = "Legt die Hintergrundtransparenz des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r fest."

L["options.other"] = "sonstige Einstellungen"
L["options.other.debug-mode.name"] = "Debugmodus"
L["options.other.debug-mode.tooltip"] = "Die Aktivierung des Debugmodus zeigt zusätzliche Informationen im Chat an."

L["options.about"] = "Über"
L["options.about.game-version"] = "Spielversion"
L["options.about.addon-version"] = "Addonversion"
L["options.about.author"] = "Autor"

L["options.about.button-github.name"] = "Feedback & Hilfe"
L["options.about.button-github.tooltip"] = "Öffnet ein Popup-Fenster mit einem Link nach GitHub."
L["options.about.button-github.button"] = "GitHub"

-- Combat Time Tracker

L["tracker.unknown"] = "unbekannt"
L["tracker.button-reset"] = "Reset"
L["tracker.wait-combat"] = "Warte auf Kampf..."

-- Dialog

L["dialog.copy-address.text"] = "Um den Link zu kopieren drücke STRG + C."

-- Chat

L["chat.new-record"] = "Neue Bestzeit für |cnGOLD_FONT_COLOR:%s|r (%s). (%s)"
