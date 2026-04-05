---@class xuemai_C:UUserWidget
---@field Image_0 UImage
---@field Image_1 UImage
---@field XUEMAIBUTTUN UButton
--Edit Below--
local xuemai = { bInitDoOnce = false } 

function xuemai:Construct()
	self:LuaInit()
	self.bBloodlineEnabled = false
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if playerState then
		if playerState.UGCBloodlineEnabled ~= nil then
			self.bBloodlineEnabled = (playerState.UGCBloodlineEnabled == true)
		elseif playerState.GameData then
			self.bBloodlineEnabled = (playerState.GameData.BloodlineEnabled == true)
		end
	end
	self:UpdateImages()
end

function xuemai:OnToggleClicked()
	local playerController = UGCGameSystem.GetLocalPlayerController()
	if not playerController then return end

	self.bBloodlineEnabled = not self.bBloodlineEnabled
	self:UpdateImages()

	-- 通过MMainUI显示提示
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.ShowTip then
		if self.bBloodlineEnabled then
			pc.MMainUI:ShowTip("血脉已开启")
		else
			pc.MMainUI:ShowTip("血脉已关闭")
		end
	end

	UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_SetBloodlineEnabled", self.bBloodlineEnabled)
end

function xuemai:UpdateImages()
	if self.bBloodlineEnabled then
		if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Visible) end
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Collapsed) end
	else
		if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Collapsed) end
		if self.Image_1 then self.Image_1:SetVisibility(ESlateVisibility.Visible) end
	end
end

function xuemai:LuaInit()
	if self.bInitDoOnce then return end
	self.bInitDoOnce = true
	if self.XUEMAIBUTTUN then
		self.XUEMAIBUTTUN.OnClicked:Add(self.OnToggleClicked, self)
	end
end

return xuemai
