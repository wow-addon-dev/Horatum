local _, HRT = ...

local L =  HRT.Localization

local Dialog = {}

--------------
--- Frames ---
--------------

local copyAddressDialog
local deleteDataDialog

---------------------
--- Main Funtions ---
---------------------

function Dialog:Initialize()
    copyAddressDialog = CreateFrame("Frame", "Horatum_CopyAdressDialog", UIParent, "Horatum_CopyAdressDialogTemplate")
	deleteDataDialog = CreateFrame("Frame", "Horatum_DeleteDataDialog", UIParent, "Horatum_DeleteDataDialogTemplate")
end

function Dialog:ShowCopyAddressDialog(address)
    if (not copyAddressDialog:IsShown()) and (not deleteDataDialog:IsShown()) then
        copyAddressDialog:ShowDialog(address)
    end
end

function Dialog:ShowDeleteDataDialog()
    if (not copyAddressDialog:IsShown()) and (not deleteDataDialog:IsShown()) then
        deleteDataDialog:ShowDialog()
    end
end

HRT.Dialog = Dialog
