local addonName, HRT = ...

local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
local buildDate = C_AddOns.GetAddOnMetadata(addonName, "X-BuildDate") or ""
local currentVersion = version

if buildDate ~= "" then
	currentVersion = currentVersion .. " (" .. buildDate .. ")"
end

HRT.CHANGELOG_TEXT = table.concat({
	"|cffffd200" .. currentVersion .. "|r\n\n"
		.. "- Added: Changelog window available from the options menu\n"
		.. "- Removed: Version notice chat messages\n"
		.. "- Minor code adjustments\n"
		.. "- Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility",
	"|cffffd200v2.20 (2026-08-14)|r\n\n"
		.. "- Added: World raid boss encounters are now tracked\n"
		.. "- Removed: TOC version for patch 12.0.7 [retail]",
	"|cffffd200v2.19 (2026-08-04)|r\n\n"
		.. "- Minor code adjustments",
	"|cffffd200v2.18 (2026-07-28)|r\n\n"
		.. "- Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility",
	"|cffffd200v2.17 (2026-07-18)|r\n\n"
		.. "- Added: Follower dungeon boss encounters are now tracked\n"
		.. "- Minor code adjustments"
}, "\n\n")
