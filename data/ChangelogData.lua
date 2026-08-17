local addonName, HRT = ...

local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
local buildDate = C_AddOns.GetAddOnMetadata(addonName, "X-BuildDate") or ""

HRT.CHANGELOG = {
	{
		version = version,
		date = buildDate ~= "" and buildDate or nil,
		entries = {
			"Added: Changelog window available from the options menu",
			"Added: Changelog window available through the 'changelog' slash command",
			"Removed: Version notice chat messages",
			"Minor code adjustments",
			"Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility"
		}
	},
	{
		version = "v2.20",
		date = "2026-08-14",
		entries = {
			"Added: World raid boss encounters are now tracked",
			"Removed: TOC version for patch 12.0.7 [retail]"
		}
	},
	{
		version = "v2.19",
		date = "2026-08-04",
		entries = {
			"Minor code adjustments"
		}
	},
	{
		version = "v2.18",
		date = "2026-07-28",
		entries = {
			"Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility"
		}
	},
	{
		version = "v2.17",
		date = "2026-07-18",
		entries = {
			"Added: Follower dungeon boss encounters are now tracked",
			"Minor code adjustments"
		}
	}
}
