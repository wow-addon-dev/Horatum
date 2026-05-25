local _, HRT = ...

HRT.Localization = setmetatable({},{__index=function(self,key)
	geterrorhandler()("Horatum (Debug): Missing entry for '" .. tostring(key) .. "'")
	return key
end})

local L = HRT.Localization

-- Options

L["options.general"] = "General Options"
L["options.general.notification.name"] = "Chat Notification"
L["options.general.notification.tooltip"] = "Activate or deactivate the notification in the chat after combat."
L["options.general.minimap-button.name"] = "Minimap Button"
L["options.general.minimap-button.tooltip"] = "When this is enabled, the minimap button is displayed."
L["options.general.debug-mode.name"] = "Debug Mode"
L["options.general.debug-mode.tooltip"] = "Enabling the debug mode displays additional information in the chat."

L["options.combat-time-tracker"] = "Combat Time Tracker"
L["options.combat-time-tracker.scale.name"] = "UI Scale"
L["options.combat-time-tracker.scale.tooltip"] = "Defines the size scaling of the Combat Time Tracker."
L["options.combat-time-tracker.background-transparency.name"] = "Background Transparency"
L["options.combat-time-tracker.background-transparency.tooltip"] = "Defines the background transparency of the Combat Time Tracker."

-- General

L["minimap-button.tooltip"] = "|cnLINK_FONT_COLOR:Left-click|r to show or hide the Combat Time Tracker.\n|cnLINK_FONT_COLOR:Right-click|r to open the options."

-- Chat

L["chat.current-record"] = "Your current best time for |cnGOLD_FONT_COLOR:%s|r (%s) is %s."
L["chat.new-record"] = "Your new best time for |cnGOLD_FONT_COLOR:%s|r (%s) is %s."

L["chat.first-victory"] = "This was your first victory over |cnGOLD_FONT_COLOR:%s|r (%s). (Wipes: %s)"
L["chat.another-victory"] = "You have defeated |cnGOLD_FONT_COLOR:%s|r (%s) before. (Victories: %s - Wipes: %s)"
L["chat.first-wipe"] = "This was your first defeat against |cnGOLD_FONT_COLOR:%s|r (%s). (Victories: %s)"
L["chat.another-wipe"] = "You have lost to |cnGOLD_FONT_COLOR:%s|r (%s) before. (Victories: %s - Wipes: %s)"

-- Combat Time Tracker

L["combat-time-tracker.button-reset"] = "Reset display"
L["combat-time-tracker.wait-combat"] = "Waiting for combat to begin..."
L["combat-time-tracker.dungeon"] = "Dungeon"
L["combat-time-tracker.raid"] = "Raid"
L["combat-time-tracker.delves-tier"] = "Tier"
