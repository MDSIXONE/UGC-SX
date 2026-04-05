---@class Settlement_2_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local Settlement_2 = { bInitDoOnce = false }

function Settlement_2:Construct()
	-- Initialize widget state and bindings.
	self:LuaInit()
	
	-- Execute the next UI update step.
	self:ExecuteNextStep()
end

function Settlement_2:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.sure then
		self.sure:SetVisibility(ESlateVisibility.Collapsed)
		-- Continue applying initial visibility settings.
	end
end

-- Execute next step.
function Settlement_2:ExecuteNextStep()
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.OnSureClicked then
		self.OnSureClicked()
	end
end

return Settlement_2
