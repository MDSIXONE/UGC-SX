---@class SettlementTip_C:UUserWidget
---@field Image_0 UImage
---@field Image_2 UImage
---@field Settlementtip UTextBlock
--Edit Below--
local SettlementTip = { bInitDoOnce = false }

function SettlementTip:Construct()
	ugcprint("[SettlementTip] Construct 被调用")
	self:LuaInit()
end

function SettlementTip:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	ugcprint("[SettlementTip] LuaInit 完成")
	
	-- 绑定文本颜色属性
	if self.Settlementtip then
		self.Settlementtip:BindingProperty("ColorAndOpacity", self.Settlementtip_ColorAndOpacity, self)
		ugcprint("[SettlementTip] 文本颜色绑定成功")
	end
end

function SettlementTip:Settlementtip_ColorAndOpacity(ReturnValue)
	return {}
end

return SettlementTip