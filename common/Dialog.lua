local _, HRT = ...

local L =  HRT.Localization

local Dialog = {}

--------------
--- Frames ---
--------------

local copyAddressDialog
local resetOptionsDialog

---------------------
--- Main Funtions ---
---------------------

function Dialog:Initialize()
    copyAddressDialog = CreateFrame("Frame", "Horatum_CopyAdressDialog", UIParent, "Horatum_CopyAdressDialogTemplate")
	resetOptionsDialog = CreateFrame("Frame", "Horatum_ResetOptionsDialog", UIParent, "Horatum_ResetOptionsDialogTemplate")
end

function Dialog:ShowCopyAddressDialog(address)
    if (not copyAddressDialog:IsShown()) and (not resetOptionsDialog:IsShown()) then
        copyAddressDialog:ShowDialog(address)
    end
end

function Dialog:ShowResetOptionsDialog()
    if (not copyAddressDialog:IsShown()) and (not resetOptionsDialog:IsShown()) then
        resetOptionsDialog:ShowDialog()
    end
end

HRT.Dialog = Dialog
