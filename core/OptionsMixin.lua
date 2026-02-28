Horatum_OptionsTextMixin = {}

function Horatum_OptionsTextMixin:Init(initializer)
	local data = initializer:GetData()
	self.LeftText:SetTextToFit(data.leftText)
	self.RightText:SetTextToFit(data.rightText)
end
