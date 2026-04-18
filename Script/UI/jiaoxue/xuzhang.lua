---@class xuzhang_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_4 UButton
---@field Button_5 UButton
---@field Button_6 UButton
---@field Button_7 UButton
---@field Button_8 UButton
---@field Button_9 UButton
---@field Button_10 UButton
---@field Button_11 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_8 UImage
---@field Image_9 UImage
---@field Image_10 UImage
---@field Image_11 UImage
---@field Image_12 UImage
---@field Image_13 UImage
---@field Image_14 UImage
---@field Image_15 UImage
---@field Image_16 UImage
---@field Image_17 UImage
---@field Image_18 UImage
---@field Image_19 UImage
---@field Image_20 UImage
---@field Image_21 UImage
---@field Image_22 UImage
---@field Image_23 UImage
---@field Image_24 UImage
---@field Image_25 UImage
---@field Image_27 UImage
---@field Image_28 UImage
---@field Image_29 UImage
---@field Image_30 UImage
---@field Image_31 UImage
---@field Image_32 UImage
---@field Image_33 UImage
---@field Image_34 UImage
---@field Image_35 UImage
---@field Image_36 UImage
---@field Image_37 UImage
---@field Image_38 UImage
---@field Image_39 UImage
---@field Image_40 UImage
---@field Image_41 UImage
---@field Image_42 UImage
---@field Image_44 UImage
---@field Image_45 UImage
---@field Image_46 UImage
---@field Image_47 UImage
---@field Image_48 UImage
---@field Image_49 UImage
---@field Image_50 UImage
---@field Image_51 UImage
---@field Image_53 UImage
---@field Image_54 UImage
---@field Image_58 UImage
---@field Image_59 UImage
---@field Image_62 UImage
---@field Image_63 UImage
---@field Image_64 UImage
---@field Image_126 UImage
---@field Image_127 UImage
---@field Image_128 UImage
---@field Image_129 UImage
---@field Image_130 UImage
---@field Image_131 UImage
---@field WidgetSwitcher_0 UWidgetSwitcher
--Edit Below--
local xuzhang = { bInitDoOnce = false } 
function xuzhang:Construct()
	self:LuaInit()
	self:ResetToDefaultPage()
	self:SetVisibility(ESlateVisibility.Collapsed)
end
function xuzhang:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	for buttonIndex = 0, 10 do
		local button = self["Button_" .. tostring(buttonIndex)]
		if button then
			local targetIndex = buttonIndex + 1
			button.OnClicked:Add(function()
				self:SwitchPage(targetIndex)
			end, self)
		end
	end
	if self.Button_11 then
		self.Button_11.OnClicked:Add(self.OnCloseClicked, self)
	end
end
function xuzhang:ResetToDefaultPage()
	self:SwitchPage(0)
end
function xuzhang:SwitchPage(index)
	if self.WidgetSwitcher_0 then
		self.WidgetSwitcher_0:SetActiveWidgetIndex(index)
	end
end
function xuzhang:ShowPanel()
	self:ResetToDefaultPage()
	self:SetVisibility(ESlateVisibility.Visible)
end
function xuzhang:OnCloseClicked()
	self:SetVisibility(ESlateVisibility.Collapsed)
end
-- function xuzhang:Tick(MyGeometry, InDeltaTime)
-- end
-- function xuzhang:Destruct()
-- end
return xuzhang