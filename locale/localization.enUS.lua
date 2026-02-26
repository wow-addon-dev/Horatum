local _, HRT = ...

HRT.localization = setmetatable({},{__index=function(self,key)
        geterrorhandler()("Horatum (Debug): Missing entry for '" .. tostring(key) .. "'")
        return key
    end})

local L = HRT.localization

-- Generel

L["addon.version"] = "Version"

-- Tracker

L["tracker.unknown"] = "unknown"
L["tracker.wait-fight"] = "Waiting for boss fight..."

-- Chat

L["chat.new-record"] = "New best time for %s (%s). (%s)"
