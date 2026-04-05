---@class WB_TeamSlot_C:UUserWidget
---@field boss UTextBlock
---@field Button_0_added UButton
---@field Button_1_adding UButton
---@field Button_2_off UButton
---@field Button_3_selfoff UButton
---@field Button_addfriend UButton
---@field Image_0 UImage
---@field Image_added UImage
---@field Image_adding UImage
---@field Image_off UImage
---@field Image_selfoff UImage
---@field Image_state UImage
---@field name UTextBlock
---@field touxiang UImage
---@field WidgetSwitcher_1 UWidgetSwitcher
---@field zhandoulidetail UTextBlock
--Edit Below--
local WB_TeamSlot = { bInitDoOnce = false }

function WB_TeamSlot:Construct()
	ugcprint("[WB_TeamSlot] Construct 被调用")
end

-- 外部调用：设置玩家信息（在 AddChild 之后调用）
function WB_TeamSlot:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain)
	ugcprint("[WB_TeamSlot] SetPlayerInfo: " .. tostring(playerName) .. ", PlayerKey=" .. tostring(playerKey) .. ", isSelf=" .. tostring(isSelf) .. ", sameTeam=" .. tostring(sameTeam))
	self.TargetPlayerKey = playerKey
	self.IsSelf = isSelf
	self.SameTeam = sameTeam

	if self.name then
		self.name:SetText(playerName or "未知玩家")
	end

	-- 队长显示"队长"标签
	if self.boss then
		if isCaptain then
			self.boss:SetText("队长")
			self.boss:SetVisibility(0)  -- Visible
		else
			self.boss:SetText("")
			self.boss:SetVisibility(1)  -- Collapsed
		end
	end

	-- 自己隐藏好友按钮，同队且非自己显示，不同队隐藏
	if self.Button_addfriend then
		if not isSelf and sameTeam then
			self.Button_addfriend:SetVisibility(0)  -- Visible
		else
			self.Button_addfriend:SetVisibility(1)  -- Collapsed
		end
	end

	-- 初始状态：自己或同队隐藏，不同队显示邀请按钮
	if isSelf or sameTeam then
		self:SetState("hidden")
	else
		self:SetState("invite")
	end

	-- 绑定所有按钮点击事件
	if not self.bButtonBound then
		self.bButtonBound = true
		if self.Button_0_added then
			self.Button_0_added.OnClicked:Add(self.OnInviteClicked, self)
		end
		if self.Button_1_adding then
			self.Button_1_adding.OnClicked:Add(self.OnRequestJoinClicked, self)
		end
		if self.Button_2_off then
			self.Button_2_off.OnClicked:Add(self.OnKickClicked, self)
		end
		if self.Button_3_selfoff then
			self.Button_3_selfoff.OnClicked:Add(self.OnLeaveClicked, self)
		end
		if self.Button_addfriend then
			self.Button_addfriend.OnClicked:Add(self.OnAddFriendClicked, self)
		end
	end
end

-- 设置状态
-- invite: 邀请组队（索引0，Button_0_added）
-- request: 申请入队（索引1，Button_1_adding）
-- kick: 队长踢人（索引2，Button_2_off）
-- selfleave: 自己退队（索引3，Button_3_selfoff）
-- hidden: 隐藏按钮区域
function WB_TeamSlot:SetState(state)
	ugcprint("[WB_TeamSlot] SetState: " .. tostring(state) .. ", PlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.WidgetSwitcher_1 then
		if state == "hidden" then
			self.WidgetSwitcher_1:SetVisibility(1)  -- Collapsed
		elseif state == "invite" then
			self.WidgetSwitcher_1:SetVisibility(0)
			self.WidgetSwitcher_1:SetActiveWidgetIndex(0)
			self.bInviteSent = false
		elseif state == "request" then
			self.WidgetSwitcher_1:SetVisibility(0)
			self.WidgetSwitcher_1:SetActiveWidgetIndex(1)
		elseif state == "kick" then
			self.WidgetSwitcher_1:SetVisibility(0)
			self.WidgetSwitcher_1:SetActiveWidgetIndex(2)
		elseif state == "selfleave" then
			self.WidgetSwitcher_1:SetVisibility(0)
			self.WidgetSwitcher_1:SetActiveWidgetIndex(3)
		end
	end
	self.CurrentState = state
end

-- Button_0_added：邀请组队
function WB_TeamSlot:OnInviteClicked()
	ugcprint("[WB_TeamSlot] OnInviteClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if self.bInviteSent then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	self.bInviteSent = true

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SendTeamInvite", self.TargetPlayerKey)
	end
end

-- Button_1_adding：申请入队
function WB_TeamSlot:OnRequestJoinClicked()
	ugcprint("[WB_TeamSlot] OnRequestJoinClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RequestJoinTeam", self.TargetPlayerKey)
	end
end

-- Button_2_off：踢出队伍（队长操作）
function WB_TeamSlot:OnKickClicked()
	ugcprint("[WB_TeamSlot] OnKickClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_KickFromTeam", self.TargetPlayerKey)
	end
end

-- Button_3_selfoff：自己退出队伍
function WB_TeamSlot:OnLeaveClicked()
	ugcprint("[WB_TeamSlot] OnLeaveClicked")

	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_LeaveTeam")
	end
end

-- Button_addfriend：添加好友
function WB_TeamSlot:OnAddFriendClicked()
	ugcprint("[WB_TeamSlot] OnAddFriendClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end

	local targetUID = UGCGameSystem.GetUIDByPlayerKey(self.TargetPlayerKey)
	if targetUID then
		UGCGameSystem.AddFriend(targetUID)
	end
end

return WB_TeamSlot
