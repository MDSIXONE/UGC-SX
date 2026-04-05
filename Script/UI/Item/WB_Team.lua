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
	-- Initialize widget state and bindings.
	self:LuaInit()

	-- Guard condition before running this branch.
	if self.Button_0 then
		self.Button_0.OnClicked:Add(self.OnCloseClicked, self)
		-- Continue registering UI interaction callbacks.
	end

	-- Keep this section consistent with the original UI flow.
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
	-- Keep this section consistent with the original UI flow.
end

-- Show.
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

	-- Guard condition before running this branch.
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

-- Hide.
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

-- Create player slots.
function WB_Team:CreatePlayerSlots(bSkipServerRequest)
	-- Guard condition before running this branch.

	if not self.WrapBox_0 then
		-- Exit early when requirements are not met.
		return
	end
	self.WrapBox_0:ClearChildren()

	-- Local helper value for this logic block.
	local AllPCs = UGCGameSystem.GetAllPlayerController()
	local PlayerCount = CountTableItems(AllPCs)
	if not AllPCs or PlayerCount == 0 then
		-- Exit early when requirements are not met.
		return
	end

	-- Local helper value for this logic block.

	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_TeamSlot.WB_TeamSlot_C'))
	if not SlotClass then
		-- Exit early when requirements are not met.
		return
	end

	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- Exit early when requirements are not met.
		return
	end

	-- Guard condition before running this branch.
	if not bSkipServerRequest then
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_RequestTeamPanelPlayers")
	end

	-- Local helper value for this logic block.
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
	-- Keep this section consistent with the original UI flow.

	self.SlotWidgets = {} -- 
	local AddedPlayerKeys = {}

	-- Local helper value for this logic block.
	local TeamPanelPlayerData = PlayerController.TeamPanelPlayerData
	local TeamPanelCount = CountTableItems(TeamPanelPlayerData)
	if TeamPanelCount > 0 then
		-- Configuration table used by this widget.

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
						playerName = "閺堫亞鐓￠悳鈺侇啀"
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

		-- Exit early when requirements are not met.
		return
	end

	-- Local helper value for this logic block.

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
					playerName = "閺堫亞鐓￠悳鈺侇啀"
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

					-- Local helper value for this logic block.
					local isCaptain = false
					if PlayerController.TeamCaptainPlayerKey and PlayerController.TeamCaptainPlayerKey == playerKey then
						isCaptain = true
					end

					slotWidget:SetPlayerInfo(playerName, iconUrl, playerKey, isSelf, sameTeam, isCaptain, combatPower)

					-- Guard condition before running this branch.
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

	-- Keep this section consistent with the original UI flow.
end

-- Update slot state.
function WB_Team:UpdateSlotState(targetPlayerKey, state)
	-- ugcprint("[WB_Team] UpdateSlotState: PlayerKey=" .. tostring(targetPlayerKey) .. ", state=" .. tostring(state))
	if self.SlotWidgets and self.SlotWidgets[targetPlayerKey] then
		self.SlotWidgets[targetPlayerKey]:SetState(state)
	end
end

-- Handle close button click.
function WB_Team:OnCloseClicked()
	-- Execute the next UI update step.
	self:Hide()
end

return WB_Team
