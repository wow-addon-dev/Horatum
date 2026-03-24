local _, HRT = ...

if GetLocale() ~= "deDE" then return end

local L = HRT.Localization

-- Options

L["options.general"] = "Allgemeine Einstellungen"
L["options.general.notification.name"] = "Chatbenachrichtigung"
L["options.general.notification.tooltip"] = "Aktiviere oder deaktiviere die Benachrichtung im Chat nach einem Kampf."
L["options.general.minimap-button.name"] = "Minimap Button"
L["options.general.minimap-button.tooltip"] = "Bei Aktivierung wird der Minimap Button angezeigt."

L["options.combat-time-tracker"] = "Kampfzeiten-Tracker"
L["options.combat-time-tracker.scale.name"] = "UI-Skalierung"
L["options.combat-time-tracker.scale.tooltip"] = "Legt die Größenskalierung des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r fest."
L["options.combat-time-tracker.background-transparency.name"] = "Hintergrundtransparenz"
L["options.combat-time-tracker.background-transparency.tooltip"] = "Legt die Hintergrundtransparenz des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r fest."

L["options.other"] = "Sonstige Einstellungen"
L["options.other.debug-mode.name"] = "Debugmodus"
L["options.other.debug-mode.tooltip"] = "Die Aktivierung des Debugmodus zeigt zusätzliche Informationen im Chat an."

L["options.about"] = "Über"
L["options.about.game-version"] = "Spielversion"
L["options.about.addon-version"] = "Addonversion"
L["options.about.author"] = "Autor"

L["options.about.button-delete-data.name"] = "???"
L["options.about.button-delete-data.tooltip"] = "???"
L["options.about.button-delete-data.button"] = "???"

L["options.about.button-github.name"] = "Feedback & Hilfe"
L["options.about.button-github.tooltip"] = "Öffnet ein Popup-Fenster mit einem Link nach GitHub."
L["options.about.button-github.button"] = "GitHub"

-- General

L["minimap-button.tooltip"] = "|cnLINK_FONT_COLOR:Linksklick|r zum anzeigen oder ausblenden des |cnGOLD_FONT_COLOR:Kampfzeiten-Tracker|r.\n|cnLINK_FONT_COLOR:Rechtsklick|r zum Öffnen der Einstellungen."

-- Dialog

L["dialog.copy-address.text"] = "Um den Link zu kopieren drücke STRG + C."
L["dialog.delete-data.text"] = "Sollen alle Addon Daten wirklich gelöscht werden?\n|cnNORMAL_FONT_COLOR:Achtung:|r Es erfolgt ein automatischer Reload der Spieloberfläche!"

-- Chat

L["chat.current-record"] = "Deine aktuelle Bestzeit für |cnGOLD_FONT_COLOR:%s|r (%s) ist %s."
L["chat.new-record"] = "Deine neue Bestzeit für |cnGOLD_FONT_COLOR:%s|r (%s) ist %s."

L["chat.first-victory"] = "Dies war dein erster Sieg über |cnGOLD_FONT_COLOR:%s|r (%s). (Niederlagen: %s)"
L["chat.another-victory"] = "Du hast |cnGOLD_FONT_COLOR:%s|r (%s) bereits einmal besiegt. (Siege: %s - Niederlagen: %s)"
L["chat.first-wipe"] = "Dies war deine erste Niederlage gegen |cnGOLD_FONT_COLOR:%s|r (%s). (Siege: %s)"
L["chat.another-wipe"] = "Du hast gegen |cnGOLD_FONT_COLOR:%s|r (%s) bereits einmal verloren. (Siege: %s - Niederlagen: %s)"

-- Combat Time Tracker

L["combat-time-tracker.unknown"] = "unbekannt"
L["combat-time-tracker.button-reset"] = "Zurücksetzten"
L["combat-time-tracker.wait-combat"] = "Warte auf Kampf..."
