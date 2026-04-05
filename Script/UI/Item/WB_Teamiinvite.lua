---@class WB_Teamiinvite_C:UUserWidget
---@field cancel UButton
---@field Image_1 UImage
---@field reject UButton
---@field sure UButton
---@field TextBlock_invitedetail UTextBlock
---@field tou tou_C
--Edit Below--
local WB_Teamiinvite = { bInitDoOnce = false }

function WB_Teamiinvite:GetInviterDisplayName()
	local playerKey = self.InviterPlayerKey
	if not playerKey or playerKey == 0 then
		return "鐜╁"
	end

	local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(playerKey)
	if playerPawn and UGCObjectUtility.IsObjectValid(playerPawn) then
		local playerName = UGCPawnAttrSystem.GetPlayerName(playerPawn)
		if playerName and playerName ~= "" then
			return playerName
		end
	end

	local playerState = UGCGameSystem.GetPlayerStateByPlayerKey(playerKey)
	if playerState and playerState.PlayerName and playerState.PlayerName ~= "" then
		return playerState.PlayerName
	end

	return tostring(playerKey)
end

function WB_Teamiinvite:UpdateInviteDetailText()
	if not self.TextBlock_invitedetail then
		return
	end

	local inviterName = self:GetInviterDisplayName()
	if self.IsJoinRequest then
		self.TextBlock_invitedetail:SetText(tostring(inviterName) .. " 鐢宠鍏ラ槦")
	else
		self.TextBlock_invitedetail:SetText(tostring(inviterName) .. " 閭€璇蜂綘鍏ラ槦")
	end
end

function WB_Teamiinvite:InitInviteAvatar()
	if not self.tou then
		return
	end

	local playerKey = self.InviterPlayerKey
	if not playerKey or playerKey == 0 then
		return
	end

	local uid = UGCGameSystem.GetUIDByPlayerKey(playerKey) or 0
	local iconUrl = ""
	local gender = 0
	local frameLevel = 0
	local playerLevel = 1

	local playerState = nil
	local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(playerKey)
	if playerPawn and UGCObjectUtility.IsObjectValid(playerPawn) then
		playerState = playerPawn.PlayerState
	end
	if not playerState then
		playerState = UGCGameSystem.GetPlayerStateByPlayerKey(playerKey)
	end

	if playerState then
		gender = playerState.PlatformGender or 0
		frameLevel = playerState.SegmentLevel or 0
		playerLevel = playerState.PlayerLevel or 1

		local PK = UGCPlayerStateSystem.GetPlayerKeyInt64(playerState)
		local AccountInfo = UGCPlayerStateSystem.GetPlayerAccountInfo(PK)
		if AccountInfo then
			iconUrl = AccountInfo.IconUrl or ""
		end
	end

	self.tou:InitView(1, uid, iconUrl, gender, frameLevel, playerLevel, false, false)
end

function WB_Teamiinvite:SetInviteData(playerKey, isJoinRequest)
	self.InviterPlayerKey = playerKey
	self.IsJoinRequest = (isJoinRequest == true)
	self:InitInviteAvatar()
	self:UpdateInviteDetailText()
end

function WB_Teamiinvite:Construct()
	-- Log this action.

	if self.sure then
		self.sure.OnClicked:Add(self.OnSureClicked, self)
		-- Log this action.
	end

	if self.reject then
		self.reject.OnClicked:Add(self.OnRejectClicked, self)
		-- Log this action.
	end

	if self.cancel then
		self.cancel.OnClicked:Add(self.OnCancelClicked, self)
		-- Log this action.
	end

	self:InitInviteAvatar()
	self:UpdateInviteDetailText()
end

-- Related UI logic.
function WB_Teamiinvite:OnSureClicked()
	-- Log this action.

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC and self.InviterPlayerKey then
		if self.IsJoinRequest then
			-- Related UI logic.
			UnrealNetwork.CallUnrealRPC(PC, PC, "Server_AcceptJoinRequest", self.InviterPlayerKey)
		else
			-- Related UI logic.
			UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RespondTeamInvite", self.InviterPlayerKey, true)
			if PC.MMainUI and PC.MMainUI.ShowTip then
				PC.MMainUI:ShowTip("宸插姞鍏ラ槦浼?)
			end
		end
	end

	self:RemoveFromParent()
end

-- Related UI logic.
function WB_Teamiinvite:OnRejectClicked()
	-- Log this action.

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC and self.InviterPlayerKey then
		if self.IsJoinRequest then
			-- Related UI logic.
			if PC.MMainUI and PC.MMainUI.ShowTip then
				PC.MMainUI:ShowTip("宸叉嫆缁?)
			end
		else
			-- Related UI logic.
			UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RespondTeamInvite", self.InviterPlayerKey, false)
			if PC.MMainUI and PC.MMainUI.ShowTip then
				PC.MMainUI:ShowTip("宸叉嫆缁?)
			end
		end
	end

	self:RemoveFromParent()
end

-- Related UI logic.
function WB_Teamiinvite:OnCancelClicked()
	-- Log this action.
	self:RemoveFromParent()
end

return WB_Teamiinvite
