---@class help_C:UUserWidget
---@field help_cancel UButton
---@field Image_0 UImage
--Edit Below--
local help = { bInitDoOnce = false } 

function help:Construct()
	self:LuaInit()
	-- Initialize the UI UI.
	self:SetVisibility(ESlateVisibility.Collapsed)
end

function help:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- Bind the button event.
	if self.help_cancel then
		self.help_cancel.OnClicked:Add(self.help_cancel_OnClicked, self)
	end
end

-- Handle the cancel action.
function help:help_cancel_OnClicked()
	-- Log that the button was clicked.
	self:SetVisibility(ESlateVisibility.Collapsed)
end

-- function help:Tick(MyGeometry, InDeltaTime)

-- end

-- function help:Destruct()

-- end

return help
