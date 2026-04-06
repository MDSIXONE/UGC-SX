---@class addexp_C:UUserWidget
---@field Image_1 UImage
---@field Image_2 UImage
---@field TUNSHIBUTTUN UButton
--Edit Below--
local addexp = { bInitDoOnce = false } 

function addexp:Construct()
	self:LuaInit()
	self.bDirectExpEnabled = false
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if playerState then
		self.bDirectExpEnabled = playerState.UGCDirectExpEnabled or false
	end
	self:UpdateImages()
end

function addexp:OnToggleClicked()
	self.bDirectExpEnabled = not self.bDirectExpEnabled
	self:UpdateImages()

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
