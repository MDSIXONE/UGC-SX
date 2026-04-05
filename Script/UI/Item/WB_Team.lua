---@class WB_Team_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field WrapBox_0 UWrapBox
--Edit Below--
local WB_Team = { bInitDoOnce = false }

local function CountTableItems(t)
	if not t then
		return 0
	end

	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function GetValidPawnByPC(PC)
	if not PC then
		return nil
	end

	local pawn = PC.Pawn
	if (not pawn or not UGCObjectUtility.IsObjectValid(pawn)) and PC.K2_GetPawn then
		pawn = PC:K2_GetPawn()
	end

	if pawn and UGCObjectUtility.IsObjectValid(pawn) then
		return pawn
	end

	return nil
end

function WB_Team:Construct()
	-- ugcprint("[WB_Team] Construct 琚皟鐢?)
	self:LuaInit()

	-- 缁戝畾鍏抽棴鎸夐挳
	if self.Button_0 then
		self.Button_0.OnClicked:Add(self.OnCloseClicked, self)
		-- ugcprint("[WB_Team] Button_0 鍏抽棴鎸夐挳缁戝畾鎴愬姛")
	end

	-- 寤惰繜5绉掑垱寤虹帺瀹舵Ы浣嶏紝绛夋墍鏈夌帺瀹禤awn鐢熸垚
	UGCTimerUtility.CreateLuaTimer(
		5.0,
		function()
			self:CreatePlayerSlots()
		end,
		false,
		"WB_Team_CreateSlots"
	)
end

function WB_Team:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	-- ugcprint("[WB_Team] LuaInit 瀹屾垚")
end

-- 鍏ㄥ睆鏄剧ず闃熶紞鐣岄潰锛堝弬鑰?shenyin锛?
function WB_Team:Show()
	self:SetVisibility(ESlateVisibility.Visible)

	if self.bHasShownAtLeastOnce == nil then
		self.bHasShownAtLeastOnce = true
		self.bHideSelfLeaveThisOpen = true
	else
		self.bHideSelfLeaveThisOpen = false
	end

	if not self.bFullScreenLayerApplied then
		local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
		if MainControlPanel then
			if MainControlPanel.MainControlBaseUI then
				UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
			end
			if MainControlPanel.ShootingUIPanel then
				UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
			end
		end

		local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
		if SkillPanel then
			UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
		end

		self.bFullScreenLayerApplied = true
	end

	if self.CreatePlayerSlots then
		self:CreatePlayerSlots()
	end

	-- 鎵撳紑鐣岄潰鍚庢寔缁交閲忓埛鏂帮紝閬垮厤闃熶紞鍙樻洿鏃跺繀椤诲叧寮€鐣岄潰鎵嶆洿鏂?
	if not self.AutoRefreshTimer then
		self.AutoRefreshTimer = UGCTimerUtility.CreateLuaTimer(
			1.0,
			function()
				if self:GetVisibility() == ESlateVisibility.Visible then
					self:CreatePlayerSlots()
				end
			end,
			true,
			"WB_Team_AutoRefresh_" .. tostring(self)
		)
	end
end

-- 鍏抽棴闃熶紞鐣岄潰骞舵仮澶嶈闅愯棌鐨勪富鐣岄潰灞?
function WB_Team:Hide()
	if self.AutoRefreshTimer then
		UGCTimerUtility.RemoveLuaTimer(self.AutoRefreshTimer)
		self.AutoRefreshTimer = nil
	end

	self.bHideSelfLeaveThisOpen = false

	if self.bFullScreenLayerApplied then
		local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
		if MainControlPanel then
			if MainControlPanel.MainControlBaseUI then
				UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
			end
			if MainControlPanel.ShootingUIPanel then
				UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
			end
		end

		local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
		if SkillPanel then
			UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
		end

		self.bFullScreenLayerApplied = false
	end

	self:SetVisibility(ESlateVisibility.Collapsed)
end

-- 鍔ㄦ€佸垱寤虹帺瀹舵Ы浣?
function WB_Team:CreatePlayerSlots(bSkipServerRequest)
	-- ugcprint("[WB_Team] 寮€濮嬪垱寤虹帺瀹舵Ы浣?)

	if not self.WrapBox_0 then
		-- ugcprint("[WB_Team] 閿欒锛氭湭鎵惧埌WrapBox_0")
		return
	end
	self.WrapBox_0:ClearChildren()

	-- 浣跨敤 GetAllPlayerController 鑾峰彇鐜╁鍒楄〃锛堟瘮浠呬緷璧?Pawn 鏇寸ǔ瀹氾級
	local AllPCs = UGCGameSystem.GetAllPlayerController()
	local PlayerCount = CountTableItems(AllPCs)
	if not AllPCs or PlayerCount == 0 then
		-- ugcprint("[WB_Team] 娌℃湁鎵惧埌鐜╁鎺у埗鍣?)
		return
	end

	-- ugcprint("[WB_Team] 鐜╁鎺у埗鍣ㄦ暟閲? " .. tostring(PlayerCount))

	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_TeamSlot.WB_TeamSlot_C'))
	if not SlotClass then
		-- ugcprint("[WB_Team] 閿欒锛氭棤娉曞姞杞絎B_TeamSlot绫?)
		return
	end

	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- ugcprint("[WB_Team] 閿欒锛氭棤娉曡幏鍙栫帺瀹舵帶鍒跺櫒")
		return
	end

	-- 瀹㈡埛绔姹傛湇鍔＄鍚屾鍏ㄤ綋鐜╁鏁版嵁锛堣閬垮鎴风浠呰兘鑾峰彇鑷韩PC鐨勯檺鍒讹級
	if not bSkipServerRequest then
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_RequestTeamPanelPlayers")
	end

	-- 鑾峰彇鏈湴鐜╁鐨?PlayerKey 鍜?TeamID
	local LocalPawn = GetValidPawnByPC(PlayerController)
	local LocalPlayerKey = -1
	local LocalTeamID = -1
	if PlayerController then
		LocalPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PlayerController)
	end
	if LocalPawn then
		LocalTeamID = UGCPawnAttrSystem.GetTeamID(LocalPawn)
	elseif PlayerController.PlayerState and PlayerController.PlayerState.TeamID then
		LocalTeamID = PlayerController.PlayerState.TeamID
	end
	-- ugcprint("[WB_Team] 鏈湴鐜╁ PlayerKey: " .. tostring(LocalPlayerKey) .. ", TeamID: " .. tostring(LocalTeamID))

	self.SlotWidgets = {}  -- 淇濆瓨妲戒綅寮曠敤锛宬ey=PlayerKey
	local AddedPlayerKeys = {}

	-- 浼樺厛浣跨敤鏈嶅姟绔悓姝ョ殑鍏ㄤ綋鐜╁鍒楄〃
	local TeamPanelPlayerData = PlayerController.TeamPanelPlayerData
	local TeamPanelCount = CountTableItems(TeamPanelPlayerData)
	if TeamPanelCount > 0 then
		-- ugcprint("[WB_Team] 浣跨敤鏈嶅姟绔悓姝ョ帺瀹跺垪琛紝鏁伴噺: " .. tostring(TeamPanelCount))

		local TeamMemberCountMap = {}
		for _, data in pairs(TeamPanelPlayerData) do
			if data then
				local teamID = tonumber(data.TeamID) or -1
				if teamID >= 0 then
					TeamMemberCountMap[teamID] = (TeamMemberCountMap[teamID] or 0) + 1
				end
			end
		end
		local localTeamCount = TeamMemberCountMap[LocalTeamID] or 0

		for _, data in pairs(TeamPanelPlayerData) do
			if data then
				local playerKey = tonumber(data.PlayerKey) or -1
				if playerKey > 0 and not AddedPlayerKeys[playerKey] then
					AddedPlayerKeys[playerKey] = true

					local playerName = data.PlayerName
					if not playerName or playerName == "" then
						playerName = "鏈煡鐜╁"
					end

					local iconUrl = data.IconUrl or ""
					local pawnTeamID = tonumber(data.TeamID) or -1
					local combatPower = math.floor(tonumber(data.CombatPower) or 0)

					local isSelf = (playerKey == LocalPlayerKey)
					local sameTeam = (LocalTeamID >= 0 and pawnTeamID >= 0 and pawnTeamID == LocalTeamID)

					local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
					if slotWidget then
						self.WrapBox_0:AddChild(slotWidget)

						local isCaptain = false
						if PlayerController.TeamCaptainPlayerKey and PlayerController.TeamCaptainPlayerKey == playerKey then
							isCaptain = true
						end

						slotWidget:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain, combatPower)

						if sameTeam and not isSelf then
							if PlayerController.bIsTeamCaptain then
								slotWidget:SetState("kick")
							else
								slotWidget:SetState("hidden")
							end
						elseif isSelf and PlayerController.bIsTeamCaptain == false and localTeamCount > 1 and not self.bHideSelfLeaveThisOpen then
							slotWidget:SetState("selfleave")
						elseif not isSelf and not sameTeam then
							local targetTeamCount = TeamMemberCountMap[pawnTeamID] or 0
							if targetTeamCount >= 2 then
								slotWidget:SetState("request")
							else
								slotWidget:SetState("invite")
							end
						end

						self.SlotWidgets[playerKey] = slotWidget
					end
				end
			end
		end

		-- ugcprint("[WB_Team] 鐜╁妲戒綅鍒涘缓瀹屾垚")
		return
	end

	-- ugcprint("[WB_Team] 鏈嶅姟绔帺瀹跺垪琛ㄤ负绌猴紝浣跨敤鏈湴鍙鐜╁鍏滃簳")

	local localTeamCount = 0
	if LocalTeamID >= 0 then
		local localTeamMembers = UGCTeamSystem.GetPlayerPawnsByTeamID(LocalTeamID)
		localTeamCount = CountTableItems(localTeamMembers)
	end

	for _, PC in pairs(AllPCs) do
		if PC then
			local playerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PC)
			if playerKey and playerKey > 0 and not AddedPlayerKeys[playerKey] then
				AddedPlayerKeys[playerKey] = true

				local Pawn = GetValidPawnByPC(PC)
				local PlayerState = PC.PlayerState or (Pawn and Pawn.PlayerState) or UGCGameSystem.GetPlayerStateByPlayerController(PC)

				local playerName = ""
				if Pawn then
					playerName = UGCPawnAttrSystem.GetPlayerName(Pawn) or ""
				end
				if (not playerName or playerName == "") and PlayerState and PlayerState.PlayerName then
					playerName = PlayerState.PlayerName
				end
				if not playerName or playerName == "" then
					playerName = "鏈煡鐜╁"
				end

				local iconUrl = ""
				if PlayerState then
					local PK = UGCPlayerStateSystem.GetPlayerKeyInt64(PlayerState)
					local AccountInfo = UGCPlayerStateSystem.GetPlayerAccountInfo(PK)
					if AccountInfo then
						iconUrl = AccountInfo.IconUrl or ""
					end
				end

				local pawnTeamID = -1
				if Pawn then
					pawnTeamID = UGCPawnAttrSystem.GetTeamID(Pawn)
				elseif PlayerState and PlayerState.TeamID then
					pawnTeamID = PlayerState.TeamID
				end

				local combatPower = 0
				if PlayerState then
					combatPower = tonumber(PlayerState.UGCPlayerCombatPower) or 0
					if combatPower <= 0 and PlayerState.GetCombatPower then
						combatPower = tonumber(PlayerState:GetCombatPower()) or 0
					end
				end
				if combatPower <= 0 and Pawn and UGCObjectUtility.IsObjectValid(Pawn) then
					local maxHp = math.floor(UGCAttributeSystem.GetGameAttributeValue(Pawn, 'HealthMax') or 100)
					local attack = math.floor(UGCAttributeSystem.GetGameAttributeValue(Pawn, 'Attack') or 20)
					local magic = math.floor(UGCAttributeSystem.GetGameAttributeValue(Pawn, 'Magic') or 10)
					combatPower = math.floor(maxHp * 0.05 + attack * 0.7 + magic * 0.25)
				end

				local isSelf = (playerKey == LocalPlayerKey)
				local sameTeam = (LocalTeamID >= 0 and pawnTeamID >= 0 and pawnTeamID == LocalTeamID)

				local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
				if slotWidget then
					self.WrapBox_0:AddChild(slotWidget)

					-- 鍒ゆ柇璇ョ帺瀹舵槸鍚︽槸闃熼暱
					local isCaptain = false
					if PlayerController.TeamCaptainPlayerKey and PlayerController.TeamCaptainPlayerKey == playerKey then
						isCaptain = true
					end

					slotWidget:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain, combatPower)

					-- 鏍规嵁闃熼暱鐘舵€佽缃纭殑鎸夐挳
					if sameTeam and not isSelf then
						if PlayerController.bIsTeamCaptain then
							slotWidget:SetState("kick")
						else
							slotWidget:SetState("hidden")
						end
					elseif isSelf and PlayerController.bIsTeamCaptain == false and localTeamCount > 1 and not self.bHideSelfLeaveThisOpen then
						slotWidget:SetState("selfleave")
					elseif not isSelf and not sameTeam then
						local targetTeamCount = 0
						if pawnTeamID >= 0 then
							local targetTeamMembers = UGCTeamSystem.GetPlayerPawnsByTeamID(pawnTeamID)
							targetTeamCount = CountTableItems(targetTeamMembers)
						end

						if targetTeamCount >= 2 then
							slotWidget:SetState("request")
						else
							slotWidget:SetState("invite")
						end
					end

					self.SlotWidgets[playerKey] = slotWidget
				end
			end
		end
	end

	-- ugcprint("[WB_Team] 鐜╁妲戒綅鍒涘缓瀹屾垚")
end

-- 鏇存柊鎸囧畾鐜╁妲戒綅鐨勭姸鎬?
function WB_Team:UpdateSlotState(targetPlayerKey, state)
	-- ugcprint("[WB_Team] UpdateSlotState: PlayerKey=" .. tostring(targetPlayerKey) .. ", state=" .. tostring(state))
	if self.SlotWidgets and self.SlotWidgets[targetPlayerKey] then
		self.SlotWidgets[targetPlayerKey]:SetState(state)
	end
end

-- 鍏抽棴鎸夐挳鐐瑰嚮
function WB_Team:OnCloseClicked()
	-- ugcprint("[WB_Team] 鍏抽棴鎸夐挳琚偣鍑?)
	self:Hide()
end

return WB_Team
