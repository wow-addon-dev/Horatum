local addonName, HRT = ...

local L = HRT.Localization

---------------------
--- Main Funtions ---
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
		if HRT.CombatTimeTracker:IsShown() then
			HRT.CombatTimeTracker:Hide()
		else
			HRT.CombatTimeTracker:Show()
		end
    elseif button == "RightButton" then
        Settings.OpenToCategory(HRT.MAIN_CATEGORY_ID)
    end
end
