local _, HRT = ...

HRT.Localization = setmetatable({},{__index=function(self,key)
    geterrorhandler()("Horatum (Debug): Missing entry for '" .. tostring(key) .. "'")
    return key
end})

local L = HRT.Localization

-- Options

L["options.combat-time-tracker"] = "Combat Time Tracker"
L["options.combat-time-tracker.scale.name"] = "UI Scale"
L["options.combat-time-tracker.scale.tooltip"] = "Defines the size scaling of the |cnGOLD_FONT_COLOR:Combat Time Tracker|r."
L["options.combat-time-tracker.background-transparency.name"] = "Background Transparency"
L["options.combat-time-tracker.background-transparency.tooltip"] = "Defines the background transparency of the |cnGOLD_FONT_COLOR:Combat Time Tracker|r."

L["options.other"] = "Other Options"
L["options.other.debug-mode.name"] = "Debug Mode"
L["options.other.debug-mode.tooltip"] = "Enabling the debug mode displays additional information in the chat."

L["options.about"] = "About"
L["options.about.game-version"] = "Game Version"
L["options.about.addon-version"] = "Addon Version"
L["options.about.author"] = "Author"

L["options.about.button-delete-data.name"] = "Delete Combat Data"
L["options.about.button-delete-data.tooltip"] = "Deletes all combat data that had been recorded and saved up to that point. This includes best times and how often a boss was defeated."
L["options.about.button-delete-data.button"] = "Delete"

L["options.about.button-github.name"] = "Feedback & Help"
L["options.about.button-github.tooltip"] = "Opens a popup window with a link to GitHub."
L["options.about.button-github.button"] = "GitHub"

-- Combat Time Tracker

L["combat-time-tracker.unknown"] = "unknown"
L["combat-time-tracker.button-reset"] = "Reset"
L["combat-time-tracker.wait-combat"] = "Waiting for combat..."

-- Dialog

L["dialog.copy-address.text"] = "To copy the link press CTRL + C."
L["dialog.delete-data.text"] = "Do you really want to delete all combat data?\n|cnNORMAL_FONT_COLOR:Warning:|r The game interface will be automatically reloaded!"

-- Chat

L["chat.new-record"] = "New best time for |cnGOLD_FONT_COLOR:%s|r (%s). (%s)"
