local _, HRT = ...

local L = HRT.Localization

Horatum_CopyAdressDialogMixin = {}

function Horatum_CopyAdressDialogMixin:OnLoad()
    self.Text:SetText(L["dialog.copy-address.text"])
	self:SetHeight(self:GetTop() - self.CloseButton:GetBottom() + 20)

    tinsert(UISpecialFrames, self:GetName())
end

function Horatum_CopyAdressDialogMixin:ShowDialog(address)
    self.EditBox:SetText(address)
	self.EditBox:HighlightText()
    self:Show()
end

Horatum_ResetOptionsDialogMixin = {}

function Horatum_ResetOptionsDialogMixin:OnLoad()
	self.Text:SetText(L["dialog.delete-data.text"])
	self:SetHeight(self:GetTop() - self.NoButton:GetBottom() + 20)

    tinsert(UISpecialFrames, self:GetName())
end

function Horatum_ResetOptionsDialogMixin:ShowDialog()
    self:Show()
end
