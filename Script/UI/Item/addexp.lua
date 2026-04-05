---@class addexp_C:UUserWidget
---@field Image_1 UImage
---@field Image_2 UImage
---@field TUNSHIBUTTUN UButton
--Edit Below--
local addexp = { bInitDoOnce = false } 

function addexp:Construct()
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
	end, false, "addexp_mode1002_hide")
	self.bDirectExpEnabled = true
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if playerState then
		self.bDirectExpEnabled = (playerState.UGCDirectExpEnabled == nil) and true or playerState.UGCDirectExpEnabled
	end
	self:UpdateImages()
end

function addexp:OnToggleClicked()
	self.bDirectExpEnabled = not self.bDirectExpEnabled
	self:UpdateImages()

	-- 通过MMainUI显示提示
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.ShowTip then
		if self.bDirectExpEnabled then
			pc.MMainUI:ShowTip("吞噬模式已关闭")
		else
			pc.MMainUI:ShowTip("吞噬模式已开启")
		end
	end

	local playerPawn = UGCGameSystem.GetLocalPlayerPawn()
	if not playerPawn then return end
	local playerController = playerPawn:GetController()
	if not playerController then return end
	UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_SetDirectExpEnabled", self.bDirectExpEnabled)
end

function addexp:UpdateImages()
	if self.bDirectExpEnabled then
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Visible) end
		if self.Image_2 then self.Image_2:SetVisibility(ESlateVisibility.Collapsed) end
	else
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Collapsed) end
		if self.Image_2 then self.Image_2:SetVisibility(ESlateVisibility.Visible) end
	end
end

function addexp:LuaInit()
	if self.bInitDoOnce then return end
	self.bInitDoOnce = true
	if self.TUNSHIBUTTUN then
		self.TUNSHIBUTTUN.OnClicked:Add(self.OnToggleClicked, self)
	end
end

return addexp
