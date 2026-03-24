local addonName, HRT = ...

local L = HRT.Localization

local Dialog = {}
local DialogLib = LibStub("WoWAddonDevelopment_SharedDialogs", true)

---------------------
--- Main Funtions ---
---------------------

function Dialog:ShowCopyAddressDialog(address)
	DialogLib:ShowCopyAddressDialog(address, L["dialog.copy-address.text"])
end

function Dialog:ShowDeleteDataDialog()
    local function ResetLogic()
        ReloadUI()
    end

    DialogLib:ShowDeleteDataDialog(L["dialog.delete-data.text"], ResetLogic)
end

HRT.Dialog = Dialog
