---@class SettlementTip_C:UUserWidget
---@field Image_0 UImage
---@field Image_2 UImage
---@field Settlementtip UTextBlock
--Edit Below--
local SettlementTip = { bInitDoOnce = false }

function SettlementTip:Construct()
	-- Initialize widget state and bindings.
	self:LuaInit()
end

function SettlementTip:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.Settlementtip then
		self.Settlementtip:BindingProperty("ColorAndOpacity", self.Settlementtip_ColorAndOpacity, self)
		-- Continue binding additional widget properties.
	end
end

function SettlementTip:Settlementtip_ColorAndOpacity(ReturnValue)
	return {}
end

return SettlementTip
