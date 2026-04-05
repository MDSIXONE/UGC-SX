---@class SettlementTip_C:UUserWidget
---@field Image_0 UImage
---@field Image_2 UImage
---@field Settlementtip UTextBlock
--Edit Below--
local SettlementTip = { bInitDoOnce = false }

function SettlementTip:Construct()
	-- ugcprint("[SettlementTip] Construct 琚皟鐢?)
	self:LuaInit()
end

function SettlementTip:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- ugcprint("[SettlementTip] LuaInit 瀹屾垚")
	
	-- 缁戝畾鏂囨湰棰滆壊灞炴€?
	if self.Settlementtip then
		self.Settlementtip:BindingProperty("ColorAndOpacity", self.Settlementtip_ColorAndOpacity, self)
		-- ugcprint("[SettlementTip] 鏂囨湰棰滆壊缁戝畾鎴愬姛")
	end
end

function SettlementTip:Settlementtip_ColorAndOpacity(ReturnValue)
	return {}
end

return SettlementTip
