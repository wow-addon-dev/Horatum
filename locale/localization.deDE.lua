local _, HRT = ...

if GetLocale() ~= "deDE" then return end

local L = HRT.Localization

-- Options

L["options.general"] = "Allgemeine Einstellungen"
L["options.general.notification.name"] = "Chatbenachrichtigung"
L["options.general.notification.tooltip"] = "Aktiviere oder deaktiviere die Benachrichtigung im Chat nach einem Kampf."
L["options.general.minimap-button.name"] = "Minimap-Button"
L["options.general.minimap-button.tooltip"] = "Bei Aktivierung wird der Minimap-Button angezeigt."
L["options.general.debug-mode.name"] = "Debugmodus"
L["options.general.debug-mode.tooltip"] = "Die Aktivierung des Debugmodus zeigt zusätzliche Informationen im Chat an."

L["options.combat-time-tracker"] = "Kampfzeiten-Tracker"
L["options.combat-time-tracker.scale.name"] = "UI-Skalierung"
L["options.combat-time-tracker.scale.tooltip"] = "Legt die Größenskalierung des Kampfzeiten-Trackers fest."
L["options.combat-time-tracker.background-transparency.name"] = "Hintergrundtransparenz"
L["options.combat-time-tracker.background-transparency.tooltip"] = "Legt die Hintergrundtransparenz des Kampfzeiten-Trackers fest."

-- General

L["minimap-button.tooltip"] = "|cnLINK_FONT_COLOR:Linksklick|r zum Anzeigen oder Ausblenden des Kampfzeiten-Trackers.\n|cnLINK_FONT_COLOR:Rechtsklick|r zum Öffnen der Einstellungen."

-- Chat

L["chat.current-record"] = "Deine aktuelle Bestzeit für |cnGOLD_FONT_COLOR:%s|r (%s) ist %s."
L["chat.new-record"] = "Deine neue Bestzeit für |cnGOLD_FONT_COLOR:%s|r (%s) ist %s."

L["chat.first-victory"] = "Dies war dein erster Sieg über |cnGOLD_FONT_COLOR:%s|r (%s). (Niederlagen: %s)"
L["chat.another-victory"] = "Du hast |cnGOLD_FONT_COLOR:%s|r (%s) bereits besiegt. (Siege: %s - Niederlagen: %s)"
L["chat.first-wipe"] = "Dies war deine erste Niederlage gegen |cnGOLD_FONT_COLOR:%s|r (%s). (Siege: %s)"
L["chat.another-wipe"] = "Du hast gegen |cnGOLD_FONT_COLOR:%s|r (%s) bereits verloren. (Siege: %s - Niederlagen: %s)"

-- Combat Time Tracker

L["combat-time-tracker.button-reset"] = "Anzeige zurücksetzen"
L["combat-time-tracker.wait-combat"] = "Warte auf Kampfbeginn..."
L["combat-time-tracker.dungeon"] = "Dungeon"
L["combat-time-tracker.raid"] = "Schlachtzug"
L["combat-time-tracker.delves-tier"] = "Stufe"
