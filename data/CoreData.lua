local addonName, HRT = ...

HRT.ADDON_AUTHOR = C_AddOns.GetAddOnMetadata(addonName, "Author")
HRT.ADDON_VERSION = C_AddOns.GetAddOnMetadata(addonName, "Version")
HRT.ADDON_BUILD_DATE = C_AddOns.GetAddOnMetadata(addonName, "X-BuildDate")

HRT.GAME_VERSION = GetBuildInfo()

HRT.LINK_GITHUB = C_AddOns.GetAddOnMetadata(addonName, "X-Github")
HRT.LINK_CURSEFORGE = C_AddOns.GetAddOnMetadata(addonName, "X-Curseforge")
HRT.LINK_WAGO = C_AddOns.GetAddOnMetadata(addonName, "X-Wago")

HRT.MEDIA_PATH = "Interface\\AddOns\\" .. addonName .. "\\media\\"

HRT.GAME_TYPE_VANILLA = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
HRT.GAME_TYPE_TBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
---@diagnostic disable-next-line: undefined-global
HRT.GAME_TYPE_MISTS = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)
HRT.GAME_TYPE_MAINLINE = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)

HRT.GAME_FLAVOR = "unknown"

if HRT.GAME_TYPE_VANILLA then
	HRT.GAME_FLAVOR = "Classic"
elseif HRT.GAME_TYPE_TBC then
	HRT.GAME_FLAVOR = "Burning Crusade - Classic Anniversary Edition"
elseif HRT.GAME_TYPE_MISTS then
	HRT.GAME_FLAVOR = "Mist of Pandaria - Classic"
elseif HRT.GAME_TYPE_MAINLINE then
	HRT.GAME_FLAVOR = "Retail"
end
