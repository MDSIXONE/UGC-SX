---@class zdshiqu_C:UUserWidget
---@field Image_0 UImage
---@field Image_1 UImage
---@field ZDSHIQUBUTTUN UButton
--Edit Below--
local zdshiqu = { bInitDoOnce = false }

function zdshiqu:Construct()
	self:LuaInit()
	local modeID = UGCMultiMode.GetModeID()
	if modeID and modeID == 1002 then
		self:SetVisibility(ESlateVisibility.Collapsed)
		return
	end
	UGCTimerUtility.CreateLuaTimer(2.0, function()
		local delayedModeID = UGCMultiMode.GetModeID()
		if delayedModeID and delayedModeID == 1002 then
			self:SetVisibility(ESlateVisibility.Collapsed)
		end
	end, false, "zdshiqu_mode1002_hide")
	self:RefreshFromPlayerState()
end

function zdshiqu:OnToggleClicked()
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.OnAutoPickupClicked then
		pc.MMainUI:OnAutoPickupClicked()
	end

	self:RefreshFromPlayerState()
end

function zdshiqu:SetToggleState(enabled)
	self.bAutoPickupEnabled = (enabled == true)
	self:UpdateImages()
end

function zdshiqu:RefreshFromPlayerState()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	local enabled = false
	if playerState then
		enabled = (playerState.UGCAutoPickupEnabled == true)
	end

	self:SetToggleState(enabled)
end

function zdshiqu:UpdateImages()
	if self.bAutoPickupEnabled then
		if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Visible) end
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Collapsed) end
	else
		if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Collapsed) end
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Visible) end
	end
end

function zdshiqu:LuaInit()
	if self.bInitDoOnce then return end
	self.bInitDoOnce = true

	if self.ZDSHIQUBUTTUN then
		self.ZDSHIQUBUTTUN.OnClicked:Add(self.OnToggleClicked, self)
	end
end

return zdshiqu
