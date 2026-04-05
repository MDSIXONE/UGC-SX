---@class WB_Team_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field WrapBox_0 UWrapBox
--Edit Below--
local WB_Team = { bInitDoOnce = false }

function WB_Team:Construct()
	ugcprint("[WB_Team] Construct 被调用")
	self:LuaInit()

	-- 绑定关闭按钮
	if self.Button_0 then
		self.Button_0.OnClicked:Add(self.OnCloseClicked, self)
		ugcprint("[WB_Team] Button_0 关闭按钮绑定成功")
	end

	-- 延迟5秒创建玩家槽位，等所有玩家Pawn生成
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
	ugcprint("[WB_Team] LuaInit 完成")
end

-- 动态创建玩家槽位
function WB_Team:CreatePlayerSlots()
	ugcprint("[WB_Team] 开始创建玩家槽位")

	if not self.WrapBox_0 then
		ugcprint("[WB_Team] 错误：未找到WrapBox_0")
		return
	end
	self.WrapBox_0:ClearChildren()

	-- 使用 GetAllPlayerPawn 获取所有玩家（包括不同队伍）
	local AllPawns = UGCGameSystem.GetAllPlayerPawn()
	if not AllPawns or #AllPawns == 0 then
		ugcprint("[WB_Team] 没有找到玩家Pawn")
		return
	end

	ugcprint("[WB_Team] 玩家Pawn数量: " .. tostring(#AllPawns))

	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_TeamSlot.WB_TeamSlot_C'))
	if not SlotClass then
		ugcprint("[WB_Team] 错误：无法加载WB_TeamSlot类")
		return
	end

	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		ugcprint("[WB_Team] 错误：无法获取玩家控制器")
		return
	end

	-- 获取本地玩家的 PlayerKey 和 TeamID
	local LocalPawn = PlayerController.Pawn
	local LocalPlayerKey = -1
	local LocalTeamID = -1
	if LocalPawn then
		LocalPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerPawn(LocalPawn)
		LocalTeamID = UGCPawnAttrSystem.GetTeamID(LocalPawn)
	end
	ugcprint("[WB_Team] 本地玩家 PlayerKey: " .. tostring(LocalPlayerKey) .. ", TeamID: " .. tostring(LocalTeamID))

	self.SlotWidgets = {}  -- 保存槽位引用，key=PlayerKey

	for i, Pawn in ipairs(AllPawns) do
		if Pawn then
			local playerName = UGCPawnAttrSystem.GetPlayerName(Pawn)
			if not playerName or playerName == "" then
				playerName = "未知玩家"
			end
			local iconUrl = ""
			local playerKey = UGCGameSystem.GetPlayerKeyByPlayerPawn(Pawn)
			local isSelf = (playerKey == LocalPlayerKey)
			local pawnTeamID = UGCPawnAttrSystem.GetTeamID(Pawn)
			local sameTeam = (pawnTeamID == LocalTeamID)

			-- 尝试从PlayerState获取头像信息
			local PlayerState = Pawn.PlayerState
			if PlayerState then
				local PK = UGCPlayerStateSystem.GetPlayerKeyInt64(PlayerState)
				local AccountInfo = UGCPlayerStateSystem.GetPlayerAccountInfo(PK)
				if AccountInfo then
					iconUrl = AccountInfo.IconUrl or ""
				end
			end

			local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
			if slotWidget then
				self.WrapBox_0:AddChild(slotWidget)
				-- 判断该玩家是否是队长
				local isCaptain = false
				if PlayerController.TeamCaptainPlayerKey and PlayerController.TeamCaptainPlayerKey == playerKey then
					isCaptain = true
				end
				slotWidget:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain)
				
				-- 根据队长状态设置正确的按钮
				if sameTeam and not isSelf then
					if PlayerController.bIsTeamCaptain then
						slotWidget:SetState("kick")
					else
						slotWidget:SetState("hidden")
					end
				elseif isSelf and PlayerController.bIsTeamCaptain == false then
					slotWidget:SetState("selfleave")
				elseif not isSelf and not sameTeam then
					local targetTeamMembers = UGCTeamSystem.GetPlayerPawnsByTeamID(pawnTeamID)
					local targetTeamCount = targetTeamMembers and #targetTeamMembers or 0
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

	ugcprint("[WB_Team] 玩家槽位创建完成")
end

-- 更新指定玩家槽位的状态
function WB_Team:UpdateSlotState(targetPlayerKey, state)
	ugcprint("[WB_Team] UpdateSlotState: PlayerKey=" .. tostring(targetPlayerKey) .. ", state=" .. tostring(state))
	if self.SlotWidgets and self.SlotWidgets[targetPlayerKey] then
		self.SlotWidgets[targetPlayerKey]:SetState(state)
	end
end

-- 关闭按钮点击
function WB_Team:OnCloseClicked()
	ugcprint("[WB_Team] 关闭按钮被点击")
	self:SetVisibility(1)  -- Collapsed
end

return WB_Team
