---@class zdtunshi_C:UUserWidget
---@field Image_0 UImage
---@field Image_1 UImage
---@field ZDTUNSHIBUTTUN UButton
--Edit Below--
local zdtunshi = { bInitDoOnce = false }

function zdtunshi:Construct()
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
	end, false, "zdtunshi_mode1002_hide")
	self:RefreshFromPlayerState()
end

function zdtunshi:OnToggleClicked()
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.OnAutoTunshiClicked then
		pc.MMainUI:OnAutoTunshiClicked()
	end

	self:RefreshFromPlayerState()
end

function zdtunshi:SetToggleState(enabled)
	self.bAutoTunshiEnabled = (enabled == true)
	self:UpdateImages()
end

function zdtunshi:RefreshFromPlayerState()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	local enabled = false
	if playerState then
		enabled = (playerState.UGCAutoTunshiEnabled == true)
	end

	self:SetToggleState(enabled)
end

function zdtunshi:UpdateImages()
	if self.bAutoTunshiEnabled then
		if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Visible) end
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Collapsed) end
	else
		if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Collapsed) end
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Visible) end
	end
end

function zdtunshi:LuaInit()
	if self.bInitDoOnce then return end
	self.bInitDoOnce = true

	if self.ZDTUNSHIBUTTUN then
		self.ZDTUNSHIBUTTUN.OnClicked:Add(self.OnToggleClicked, self)
	end
end

return zdtunshi
