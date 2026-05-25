local addonName, HRT = ...

local L = HRT.Localization

local Utils = HRT.modules.Utils

---------------------
--- Main Functions ---
---------------------

function Horatum_CompartmentOnEnter(self, button)
	GameTooltip:ClearAllPoints()
	GameTooltip:SetOwner(button, "ANCHOR_LEFT")

	GameTooltip_SetTitle(GameTooltip, addonName)
	GameTooltip_AddNormalLine(GameTooltip, HRT.ADDON_VERSION .. " (" .. HRT.ADDON_BUILD_DATE .. ")")
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip_AddHighlightLine(GameTooltip, L["minimap-button.tooltip"])

	GameTooltip:Show()
end

function Horatum_CompartmentOnLeave()
    GameTooltip:Hide()
end

function Horatum_CompartmentOnClick(_, button)
    if button == "LeftButton" then
		if HRT.modules.CombatTimeTracker:IsShown() then
			HRT.modules.CombatTimeTracker:Hide()
		else
			HRT.modules.CombatTimeTracker:Show()
		end
    elseif button == "RightButton" then
		if not InCombatLockdown() then
			Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)
		else
			Utils:PrintDebug("In combat. The options menu cannot be opened.")
		end
    end
end
