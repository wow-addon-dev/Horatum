local _, HRT = ...

if GetLocale() ~= "deDE" then return end

local L = HRT.Localization

-- Options

L["options.combat-time-tracker"] = "Kampfzeiten-Tracker"
L["options.combat-time-tracker.scale.name"] = "UI-Skalierung"
L["options.combat-time-tracker.scale.tooltip"] = "Legt die Größenskalierung des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r fest."
L["options.combat-time-tracker.background-transparency.name"] = "Hintergrundtransparenz"
L["options.combat-time-tracker.background-transparency.tooltip"] = "Legt die Hintergrundtransparenz des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r fest."

L["options.other"] = "sonstige Einstellungen"
L["options.other.debug-mode.name"] = "Debugmodus"
L["options.other.debug-mode.tooltip"] = "Die Aktivierung des Debugmodus zeigt zusätzliche Informationen im Chat an."

L["options.about"] = "Über"
L["options.about.game-version"] = "Spielversion"
L["options.about.addon-version"] = "Addonversion"
L["options.about.author"] = "Autor"

L["options.about.button-delete-data.name"] = "Kampdaten löschen"
L["options.about.button-delete-data.tooltip"] = "Löscht alle Kampfdaten die bisher erfasst und gespeichert wurden. Dies beinhaltet die Bestzeiten und wie oft ein Boss besiegt wurde."
L["options.about.button-delete-data.button"] = "Löschen"

L["options.about.button-github.name"] = "Feedback & Hilfe"
L["options.about.button-github.tooltip"] = "Öffnet ein Popup-Fenster mit einem Link nach GitHub."
L["options.about.button-github.button"] = "GitHub |A:UI-Journeys-GreatVault-Tag-new:33:49|a"

-- Combat Time Tracker

L["combat-time-tracker.unknown"] = "unbekannt"
L["combat-time-tracker.button-reset"] = "Reset"
L["combat-time-tracker.wait-combat"] = "Warte auf Kampf..."

-- Dialog

L["dialog.copy-address.text"] = "Um den Link zu kopieren drücke STRG + C."
L["dialog.delete-data.text"] = "Sollen die kampfdaten wirklich gelöscht werden?\n|cnNORMAL_FONT_COLOR:Achtung:|r Es erfolgt ein automatischer Reload der Spieloberfläche!"

-- Chat

L["chat.new-record"] = "Neue Bestzeit für |cnGOLD_FONT_COLOR:%s|r (%s). (%s)"
