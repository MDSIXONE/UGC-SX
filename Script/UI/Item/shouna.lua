---@class shouna_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field Image_1 UImage
--Edit Below--
local shouna = { bInitDoOnce = false } 

function shouna:Construct()
	-- Log this action.
	self:LuaInit()
	-- Log this action.
end

function shouna:LuaInit()
	if self.bInitDoOnce then
		-- Log this action.
		return
	end
	self.bInitDoOnce = true
	
	-- Log this action.
	
	-- Related UI logic.
	if self.Button_0 then
		-- Log this action.
		self.Button_0.OnPressed:Add(self.OnButtonClicked, self)
		-- Log this action.
	else
		-- Log this action.
	end
	
	if self.Image_0 then
		-- Log this action.
	else
		-- Log this action.
	end
	
	if self.Image_1 then
		-- Log this action.
	else
		-- Log this action.
	end
	
	-- Log this action.
end

function shouna:OnButtonClicked()
	-- Log this action.
	
	local pc = UGCGameSystem.GetLocalPlayerController()
	if not pc then
		-- Log this action.
		return
	end
	-- Log this action.
	
	if not pc.MMainUI then
		-- Log this action.
		return
	end
	-- Log this action.
	
	if pc.MMainUI.ToggleShounaButtons then
		-- Log this action.
		pc.MMainUI:ToggleShounaButtons()
	else
		-- Log this action.
	end
end

return shouna
