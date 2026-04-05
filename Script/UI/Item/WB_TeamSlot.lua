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
		return "鎴樺姏: " .. tostring(UGCGameData.FormatNumber(powerValue))
	end
	return "鎴樺姏: " .. tostring(powerValue)
end
function WB_TeamSlot:Construct()
	-- ugcprint("[WB_TeamSlot] Construct 琚皟鐢?)
end
-- 澶栭儴璋冪敤锛氳缃帺瀹朵俊鎭紙鍦?AddChild 涔嬪悗璋冪敤锛?function WB_TeamSlot:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain, combatPower)
	-- ugcprint("[WB_TeamSlot] SetPlayerInfo: " .. tostring(playerName) .. ", PlayerKey=" .. tostring(playerKey) .. ", isSelf=" .. tostring(isSelf) .. ", sameTeam=" .. tostring(sameTeam))
	self.TargetPlayerKey = playerKey
	self.TargetPlayerName = playerName
	self.IsSelf = isSelf
	self.SameTeam = sameTeam
	self.TargetCombatPower = math.floor(tonumber(combatPower) or 0)
	if self.name then
		self.name:SetText(playerName or "鏈煡鐜╁")
	end
	if self.zhandoulidetail then
		self.zhandoulidetail:SetText(FormatCombatPowerText(self.TargetCombatPower))
	end
	-- 鍒濆鍖栧ご鍍?	if self.tou then
		local uid = UGCGameSystem.GetUIDByPlayerKey(playerKey)
		local gender = 0
		local frameLevel = 0
		local playerLevel = 1
		-- 灏濊瘯浠嶱layerState鑾峰彇鏇村淇℃伅
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
		-- ugcprint("[WB_TeamSlot] 澶村儚鍒濆鍖栧畬鎴? UID=" .. tostring(uid))
	end
	-- 闃熼暱鏄剧ず"闃熼暱"鏍囩
	if self.boss then
		if isCaptain then
			self.boss:SetText("闃熼暱")
			self.boss:SetVisibility(0)  -- Visible
		else
			self.boss:SetText("")
			self.boss:SetVisibility(1)  -- Collapsed
		end
	end
	-- 鑷繁闅愯棌濂藉弸鎸夐挳锛屽悓闃熶笖闈炶嚜宸辨樉绀猴紝涓嶅悓闃熼殣钘?	if self.Button_addfriend then
		if not isSelf and sameTeam then
			self.Button_addfriend:SetVisibility(0)  -- Visible
		else
			self.Button_addfriend:SetVisibility(1)  -- Collapsed
		end
	end
	-- 鍒濆鐘舵€侊細鑷繁鎴栧悓闃熼殣钘忥紝涓嶅悓闃熸樉绀洪個璇锋寜閽?	if isSelf or sameTeam then
		self:SetState("hidden")
	else
		self:SetState("invite")
	end
	-- 缁戝畾鎵€鏈夋寜閽偣鍑讳簨浠?	if not self.bButtonBound then
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
-- 璁剧疆鐘舵€?-- invite: 閭€璇风粍闃燂紙绱㈠紩0锛孊utton_0_added锛?-- request: 鐢宠鍏ラ槦锛堢储寮?锛孊utton_1_adding锛?-- kick: 闃熼暱韪汉锛堢储寮?锛孊utton_2_off锛?-- selfleave: 鑷繁閫€闃燂紙绱㈠紩3锛孊utton_3_selfoff锛?-- hidden: 闅愯棌鎸夐挳鍖哄煙
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
-- Button_0_added锛氶個璇风粍闃?function WB_TeamSlot:OnInviteClicked()
	-- ugcprint("[WB_TeamSlot] OnInviteClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if self.bInviteSent then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	self.bInviteSent = true
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SendTeamInvite", self.TargetPlayerKey)
		if PC.MMainUI and PC.MMainUI.ShowTip then
			PC.MMainUI:ShowTip("宸插彂鍑洪個璇?)
		end
	end
end
-- Button_1_adding锛氱敵璇峰叆闃?function WB_TeamSlot:OnRequestJoinClicked()
	-- ugcprint("[WB_TeamSlot] OnRequestJoinClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RequestJoinTeam", self.TargetPlayerKey)
	end
end
-- Button_2_off锛氳涪鍑洪槦浼嶏紙闃熼暱鎿嶄綔锛?function WB_TeamSlot:OnKickClicked()
	-- ugcprint("[WB_TeamSlot] OnKickClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_KickFromTeam", self.TargetPlayerKey)
		if PC.MMainUI and PC.MMainUI.ShowTip then
			local targetName = self.TargetPlayerName or tostring(self.TargetPlayerKey)
			PC.MMainUI:ShowTip("宸插皢" .. tostring(targetName) .. "韪㈠嚭闃熶紞")
		end
	end
end
-- Button_3_selfoff锛氳嚜宸遍€€鍑洪槦浼?function WB_TeamSlot:OnLeaveClicked()
	-- ugcprint("[WB_TeamSlot] OnLeaveClicked")
	local PC = UGCGameSystem.GetLocalPlayerController()
	if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Server_LeaveTeam")
		if PC.MMainUI and PC.MMainUI.ShowTip then
			PC.MMainUI:ShowTip("宸查€€鍑洪槦浼?)
		end
	end
end
-- Button_addfriend锛氭坊鍔犲ソ鍙?function WB_TeamSlot:OnAddFriendClicked()
	-- ugcprint("[WB_TeamSlot] OnAddFriendClicked, TargetPlayerKey=" .. tostring(self.TargetPlayerKey))
	if self.IsSelf then return end
	if not self.TargetPlayerKey or self.TargetPlayerKey == 0 then return end
	local targetUID = UGCGameSystem.GetUIDByPlayerKey(self.TargetPlayerKey)
	if targetUID then
		UGCGameSystem.AddFriend(targetUID)
	end
end
return WB_TeamSlot
