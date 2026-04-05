---@class WB_TeamSlot_C:UUserWidget
---@field boss UTextBlock
---@field Button_0_added UButton
---@field Button_1_adding UButton
---@field Button_2_off UButton
---@field Button_3_selfoff UButton
---@field Button_addfriend UButton
---@field Image_0 UImage
---@field Image_state UImage
---@field name UTextBlock
---@field tou tou_C
---@field WidgetSwitcher_1 UWidgetSwitcher
---@field zhandoulidetail UTextBlock
--Edit Below--
local WB_TeamSlot = { bInitDoOnce = false }
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local function FormatCombatPowerText(combatPower)
	local powerValue = math.floor(tonumber(combatPower) or 0)
	if UGCGameData and UGCGameData.FormatNumber then
		return "閹存ê濮? " .. tostring(UGCGameData.FormatNumber(powerValue))
	end
	return "閹存ê濮? " .. tostring(powerValue)
end
function WB_TeamSlot:Construct()
	-- Keep this section consistent with the original UI flow.
end
-- Set player info.
function WB_TeamSlot:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain, combatPower)
	-- ugcprint("[WB_TeamSlot] SetPlayerInfo: " .. tostring(playerName) .. ", PlayerKey=" .. tostring(playerKey) .. ", isSelf=" .. tostring(isSelf) .. ", sameTeam=" .. tostring(sameTeam))
	self.TargetPlayerKey = playerKey
	self.TargetPlayerName = playerName
	self.IsSelf = isSelf
	self.SameTeam = sameTeam
	self.TargetCombatPower = math.floor(tonumber(combatPower) or 0)
	if self.name then
		self.name:SetText(playerName or "閺堫亞鐓￠悳鈺侇啀")
	end
	if self.zhandoulidetail then
		self.zhandoulidetail:SetText(FormatCombatPowerText(self.TargetCombatPower))
	end
	-- Guard condition before running this branch.
	if self.tou then
		local uid = UGCGameSystem.GetUIDByPlayerKey(playerKey)
		local gender = 0
		local frameLevel = 0
		local playerLevel = 1
		-- Local helper value for this logic block.
		local AllPawns = UGCGameSystem.GetAllPlayerPawn()
		if AllPawns then
			for _, pawn in ipairs(AllPawns) do
				if pawn and UGCGameSystem.GetPlayerKeyByPlayerPawn(pawn) == playerKey then
					local ps = pawn.PlayerState
					if ps then
						gender = ps.PlatformGender or 0
						frameLevel = ps.SegmentLevel or 0
						playerLevel = ps.PlayerLevel or 1
					end
					break
				end
			end
		end
		self.tou:InitView(1, uid or 0, iconUrl or "", gender, frameLevel, playerLevel, false, isSelf)
		-- Keep this section consistent with the original UI flow.
	end
	-- Guard condition before running this branch.
	if self.boss then
		if isCaptain then
			self.boss:SetText("闂冪喖鏆?)
			self.boss:SetVisibility(0)  -- Visible
		else
			self.boss:SetText("")
			self.boss:SetVisibility(1)  -- Collapsed
		end
	end
	-- Guard condition before running this branch.
	if self.Button_addfriend then
		if not isSelf and sameTeam then
			self.Button_addfriend:SetVisibility(0)  -- Visible
		else
			self.Button_addfriend:SetVisibility(1)  -- Collapsed
		end
	end
	-- Guard condition before running this branch.
	if isSelf or sameTeam then
		self:SetState("hidden")
	else
		self:SetState("invite")
	end
	-- Guard condition before running this branch.
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
-- Set state.
function WB_TeamSlot:SetState(state)
	-- ugcprint("[WB_TeamSlot] SetState: " .. tostring(state) .. ", PlayerKey=" .. tostring(self.TargetPlayerKey))
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
-- Handle invite button click.
function WB_TeamSlot:OnInviteClicked()
	-- ugcprint("[WB_TeamSlot] OnInviteClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if self.bInviteSent then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	self.bInviteSent = true
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SendTeamInvite", self.TargetPlayerKey)
		if PC.MMainUI and PC.MMainUI.ShowTip then
			PC.MMainUI:ShowTip("瀹告彃褰傞崙娲€嬬拠?)
		end
	end
end
-- Handle request join button click.
function WB_TeamSlot:OnRequestJoinClicked()
	-- ugcprint("[WB_TeamSlot] OnRequestJoinClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RequestJoinTeam", self.TargetPlayerKey)
	end
end
-- Handle kick button click.
function WB_TeamSlot:OnKickClicked()
	-- ugcprint("[WB_TeamSlot] OnKickClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_KickFromTeam", self.TargetPlayerKey)
		if PC.MMainUI and PC.MMainUI.ShowTip then
			local targetName = self.TargetPlayerName or tostring(self.TargetPlayerKey)
			PC.MMainUI:ShowTip("瀹告彃鐨? .. tostring(targetName) .. "闊垹鍤梼鐔剁礊")
		end
	end
end
-- Handle leave button click.
function WB_TeamSlot:OnLeaveClicked()
	-- ugcprint("[WB_TeamSlot] OnLeaveClicked")
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_LeaveTeam")
		if PC.MMainUI and PC.MMainUI.ShowTip then
			PC.MMainUI:ShowTip("瀹告煡鈧偓閸戞椽妲︽导?)
		end
	end
end
-- Handle add friend button click.
function WB_TeamSlot:OnAddFriendClicked()
	-- ugcprint("[WB_TeamSlot] OnAddFriendClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	local targetUID = UGCGameSystem.GetUIDByPlayerKey(self.TargetPlayerKey)
	if targetUID then
		UGCGameSystem.AddFriend(targetUID)
	end
end
return WB_TeamSlot
