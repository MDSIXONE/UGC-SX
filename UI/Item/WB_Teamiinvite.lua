---@class WB_Teamiinvite_C:UUserWidget
---@field cancel UButton
---@field Image_0 UImage
---@field reject UButton
---@field sure UButton
--Edit Below--
local WB_Teamiinvite = { bInitDoOnce = false }

function WB_Teamiinvite:Construct()
	ugcprint("[WB_Teamiinvite] Construct 被调用")

	if self.sure then
		self.sure.OnClicked:Add(self.OnSureClicked, self)
		ugcprint("[WB_Teamiinvite] sure 按钮绑定成功")
	end

	if self.reject then
		self.reject.OnClicked:Add(self.OnRejectClicked, self)
		ugcprint("[WB_Teamiinvite] reject 按钮绑定成功")
	end

	if self.cancel then
		self.cancel.OnClicked:Add(self.OnCancelClicked, self)
		ugcprint("[WB_Teamiinvite] cancel 按钮绑定成功")
	end
end

-- 点击 sure：同意
function WB_Teamiinvite:OnSureClicked()
	ugcprint("[WB_Teamiinvite] sure 被点击, InviterPlayerKey=" .. tostring(self.InviterPlayerKey) .. ", IsJoinRequest=" .. tostring(self.IsJoinRequest))

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC and self.InviterPlayerKey then
		if self.IsJoinRequest then
			-- 队长同意申请入队
			UnrealNetwork.CallUnrealRPC(PC, PC, "Server_AcceptJoinRequest", self.InviterPlayerKey)
		else
			-- 被邀请者同意邀请
			UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RespondTeamInvite", self.InviterPlayerKey, true)
		end
	end

	self:RemoveFromParent()
end

-- 点击 reject：拒绝
function WB_Teamiinvite:OnRejectClicked()
	ugcprint("[WB_Teamiinvite] reject 被点击, InviterPlayerKey=" .. tostring(self.InviterPlayerKey) .. ", IsJoinRequest=" .. tostring(self.IsJoinRequest))

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC and self.InviterPlayerKey then
		if self.IsJoinRequest then
			-- 队长拒绝申请入队，不需要额外处理
		else
			-- 被邀请者拒绝邀请
			UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RespondTeamInvite", self.InviterPlayerKey, false)
		end
	end

	self:RemoveFromParent()
end

-- 点击 cancel：关闭UI（不回复）
function WB_Teamiinvite:OnCancelClicked()
	ugcprint("[WB_Teamiinvite] cancel 被点击，关闭UI")
	self:RemoveFromParent()
end

return WB_Teamiinvite
