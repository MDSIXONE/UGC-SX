---@class UGCPlayerController_C:BP_UGCPlayerController_C
---@field LotteryComponent LotteryComponent_C
---@field GiftPackComponent GiftPackComponent_C
---@field RankingListComponent RankingListComponent_C
---@field ShopV2Component ShopV2Component_C
--Edit Below--
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local UGCPlayerController = {}
local TEAM_ABSORB_EXP_SHARE_RATE = 0.1

local function GetPlayerNameByPlayerKey(PlayerKey)
    if not PlayerKey or PlayerKey <= 0 then
        return tostring(PlayerKey)
    end

    local Pawn = UGCGameSystem.GetPlayerPawnByPlayerKey(PlayerKey)
    if Pawn and UGCObjectUtility.IsObjectValid(Pawn) then
        local PlayerName = UGCPawnAttrSystem.GetPlayerName(Pawn)
        if PlayerName and PlayerName ~= "" then
            return PlayerName
        end
    end

    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerKey(PlayerKey)
    if PlayerState and PlayerState.PlayerName and PlayerState.PlayerName ~= "" then
        return PlayerState.PlayerName
    end

    return tostring(PlayerKey)
end

-- Global team captain data table, key=TeamID, value=PlayerKey of captain
TeamCaptainData = TeamCaptainData or {}

function UGCPlayerController:ReceiveBeginPlay()
    --ugcprint("========== UGCPlayerController:ReceiveBeginPlay started ==========")
    UGCPlayerController.SuperClass.ReceiveBeginPlay(self)
    
    -- Timer: grant initial equipment on first login
    local OBTimerDelegate = ObjectExtend.CreateDelegate(self, 
        function()
            if self:HasAuthority() == true then
                local Uid = UGCGameSystem.GetUIDByPlayerController(self)
                local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)
                
                -- Check if first time entering game
                if not Data.HasReceivedInitialEquipment then
                    --ugcprint("[UGCPlayerController] First login, granting initial equipment")
                    
                    local PlayerPawn = self:GetPlayerCharacterSafety()
                    UGCBackpackSystemV2.AddItemV2(PlayerPawn, 8310105, 1)
                    
                    -- Mark as received and save
                    Data.HasReceivedInitialEquipment = true
                    UGCPlayerStateSystem.SavePlayerArchiveData(Uid, Data)
                    --ugcprint("[UGCPlayerController] Initial equipment granted, flag saved")
                else
                    --ugcprint("[UGCPlayerController] Player already received initial equipment, skip")
                end
            end
        end
    )
    KismetSystemLibrary.K2_SetTimerDelegateForLua(OBTimerDelegate, self, 2, false)
    
    -- Create UI for local controller
    if self:IsLocalController() then
        --ugcprint("UGCPlayerController: This is local controller, creating UI")
        
        -- Create MainWidget
        local mainWidget = UGCGameData.GetUI(self, "MainWidget")
        if mainWidget then
            self.MainWidget = mainWidget
            mainWidget:AddToViewport(1000)
            --ugcprint("UGCPlayerController: MainWidget added to viewport, layer 1000")
        else
            --ugcprint("UGCPlayerController: Error - unable to create MainWidget")
        end
        
        -- Create MMainUI
        local mainUI = UGCGameData.GetUI(self, "MMainUI")
        if mainUI then
            self.MMainUI = mainUI
            mainUI:AddToViewport(1100)
            --ugcprint("UGCPlayerController: MMainUI added to viewport, layer 1100")
            
            if mainUI.TASK then
                --ugcprint("UGCPlayerController: MMainUI.TASK component exists")
            else
                --ugcprint("UGCPlayerController: Warning - MMainUI.TASK component missing")
            end
        else
            --ugcprint("UGCPlayerController: Error - unable to create MMainUI")
        end
        
        -- Register buy product delegate
        self:RegisterBuyProductDelegate()
    else
        --ugcprint("UGCPlayerController: Not local controller, skip UI creation")
    end
    
    --ugcprint("========== UGCPlayerController:ReceiveBeginPlay completed ==========")
    
    -- Delayed check: mode ID and level stage after 3 seconds
    if self:IsLocalController() then
        UGCTimerUtility.CreateLuaTimer(
            3.0, -- 3 second delay
            function()
                local currentModeID = UGCMultiMode.GetModeID()
                local currentStage = UGCLevelFlowSystem.GetCurrentLevelStage(self)
                
                -- ugcprint("[UGCPlayerController] ========== 3s check ==========")
                -- ugcprint("[UGCPlayerController] Current ModeID: " .. tostring(currentModeID))
                -- ugcprint("[UGCPlayerController] Current level stage: " .. tostring(currentStage))
                
                -- Log dungeon config for mode 1002
                if currentModeID == 1002 then
                    -- ugcprint("[UGCPlayerController] Dungeon config table path: " .. tostring(UGCGameData.FubenTablePath))
                    local MgrPath = UGCGameData.GetGameModeActorMgrConfig(currentModeID)
                    if MgrPath and MgrPath ~= "" then
                        -- ugcprint("[UGCPlayerController] Dungeon data table read success: " .. tostring(MgrPath))
                    else
                        -- ugcprint("[UGCPlayerController] Dungeon data table read failed or not configured")
                        -- ugcprint("[UGCPlayerController] MgrPath = " .. tostring(MgrPath))
                    end
                end
                
                if currentModeID == -99999 or currentModeID == 0 then
                    -- ugcprint("[UGCPlayerController] Hint: Currently in lobby mode")
                else
                    -- ugcprint("[UGCPlayerController] Currently in mode: " .. tostring(currentModeID) .. ", stage: " .. tostring(currentStage))
                end
                -- ugcprint("[UGCPlayerController] ================================")
            end,
            false, -- Not looping
            "CheckModeID_Timer"  -- Timer name
        )
    end
end

-- Register buy product result delegate
function UGCPlayerController:RegisterBuyProductDelegate()
    UGCTimerUtility.CreateLuaTimer(
        1,
        function()
            local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
            if CommodityOperationManager then
                CommodityOperationManager.BuyProductResultDelegate:Add(self.OnBuyProductResult, self)
                --ugcprint("[UGCPlayerController] Buy result delegate registered")
            else
                --ugcprint("[UGCPlayerController] Unable to get CommodityOperationManager")
            end
        end,
        false,
        "RegisterBuyProductDelegate"
    )
end

-- Buy product result callback
function UGCPlayerController:OnBuyProductResult(Result)
    -- ugcprint("[UGCPlayerController] Buy result callback received")
    
    -- Print result details
    if Result then
        for k, v in pairs(Result) do
            -- ugcprint("[UGCPlayerController] Result." .. tostring(k) .. " = " .. tostring(v))
        end
    end
    
    if Result and Result.bSucceeded then
        -- Calculate spend amount
        local spendAmount = 0
        if Result.TotalPrice and Result.TotalPrice > 0 then
            spendAmount = Result.TotalPrice
        elseif Result.ProductID then
            local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
            if CommodityOperationManager then
                local productData = CommodityOperationManager:GetProductData(Result.ProductID)
                if productData then
                    for pk, pv in pairs(productData) do
                        -- ugcprint("[UGCPlayerController] ProductData." .. tostring(pk) .. " = " .. tostring(pv))
                    end
                    local price = productData.SellingPrice or productData.Price or 0
                    local num = Result.Num or 1
                    spendAmount = price * num
                end
            end
        end
        if spendAmount <= 0 then
            spendAmount = Result.Num or 1
        end
        -- ugcprint(string.format("[UGCPlayerController] Purchase success, spend amount: %d", spendAmount))
        
        local playerState = UGCGameSystem.GetPlayerStateByPlayerController(self)
        if playerState then
            UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddSpendCount", spendAmount)
            UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddShopBuyCount")
        end
    else
        -- ugcprint("[UGCPlayerController] Purchase failed or result invalid")
    end
end

-- Available server RPCs
function UGCPlayerController:GetAvailableServerRPCs()
    return "Server_TeleportPlayer", "Server_RestoreFullHealth", "Server_DestroyNearbyCorpses", "Server_SetDirectExpEnabled", "Server_SetAutoTunshiEnabled", "Server_SetAutoPickupEnabled", "Server_SetBloodlineEnabled", "Server_NotifyLevelRewardFinish", "Server_NotifyTimeOutFinish", "Server_GiveRewards", "Server_SendTeamInvite", "Server_RespondTeamInvite", "Server_RequestJoinTeam", "Server_AcceptJoinRequest", "Server_KickFromTeam", "Server_LeaveTeam", "Server_ResumeTriggerBoxSpawning", "Server_BatchOpenBaoxiang", "Server_RequestTeamPanelPlayers"
end

-- Available client RPCs
function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_ShowTunshiSuccess", "Client_SetPlayerRotation", "Client_ShowSettlementUI", "Client_ShowSettlementTipUI", "Client_ShowSettlement2UI", "Client_OnPlayerLevelUp", "Client_ReceiveTeamInvite", "Client_TeamInviteResult", "Client_ReceiveJoinRequest", "Client_RefreshTeamUI", "Client_OnKickedFromTeam", "Client_ShowTaSettlementUI", "Client_UpdateJiangeFloor", "Client_OnP1Died", "Client_StartCountdown", "Client_SyncJiangeData", "Client_SyncShenyinData", "Client_ShowBaoxiangNumchoose", "Client_BeginTeamPanelPlayers", "Client_AddTeamPanelPlayer", "Client_EndTeamPanelPlayers", "Client_ShowBaoxiangReward", "Client_SyncJiangeRewardData", "Client_OnJiangeDailyClaimResult", "Client_OnJiangeForgeConsumeResult", "Client_RestoreMainUIAfterRespawn", "Client_OnExpBlockedByRebirth", "Client_SyncMobKillCount"
end

-- Client: show absorb success notification
function UGCPlayerController:Client_ShowTunshiSuccess(totalExp)
    --ugcprint("[Client] Client_ShowTunshiSuccess received, exp value: " .. tostring(totalExp))
    
    if not self:IsLocalController() then
        return
    end
    
    if self.MMainUI and self.MMainUI.tunshitip then
        if self.MMainUI.tunshitip.ShowTips then
            self.MMainUI.tunshitip:ShowTips("Absorb success +" .. tostring(totalExp))
            --ugcprint("[Client] Showing absorb tip: Absorb success +" .. tostring(totalExp))
        end
    end
end

-- Server: restore player full health
function UGCPlayerController:Server_RestoreFullHealth()
    --ugcprint("[Server] Server_RestoreFullHealth request received")
    
    local ok, err = pcall(function()
        local PlayerPawn = self.Pawn or self:K2_GetPawn()
        if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
            --ugcprint("[Server] Error: unable to get player Pawn")
            return
        end
        
        local maxHealth = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'HealthMax') or 100
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, 'Health', maxHealth)
        --ugcprint("[Server] Health set to: " .. tostring(maxHealth))
    end)
    
    if not ok then
        --ugcprint("[Server] Server_RestoreFullHealth error: " .. tostring(err))
    end
end

-- Server: teleport player to target location
function UGCPlayerController:Server_TeleportPlayer(X, Y, Z, Yaw)
    --ugcprint("[Server] Server_TeleportPlayer request received")
    --ugcprint("[Server] Target location: X=" .. tostring(X) .. " Y=" .. tostring(Y) .. " Z=" .. tostring(Z) .. " Yaw=" .. tostring(Yaw))
    
    local ok, err = pcall(function()
        local PlayerPawn = nil
        
        if self.Pawn and UGCObjectUtility.IsObjectValid(self.Pawn) then
            PlayerPawn = self.Pawn
        end
        
        if not PlayerPawn and self.K2_GetPawn then
            PlayerPawn = self:K2_GetPawn()
        end
        
        if not PlayerPawn then
            PlayerPawn = UGCPlayerControllerSystem.GetPlayerCharacter(self)
        end
        
        if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
            --ugcprint("[Server] Error: unable to get player Pawn")
            return
        end
        
        local TargetLocation = Vector.New(X, Y, Z)
        
        -- If Yaw is specified, also set rotation
        if Yaw and Yaw ~= 0 then
            -- Pitch=0, Roll=0, only set Yaw
            local newRotation = Rotator.New(0, Yaw, 0)
            
            -- Set both location and rotation
            PlayerPawn:K2_SetActorLocationAndRotation(TargetLocation, newRotation, false, nil, true)
            
            --ugcprint("[Server] Teleport location and rotation success! Yaw=" .. Yaw)
            
            -- Sync client rotation
        else
            -- Only set location
            PlayerPawn:K2_SetActorLocation(TargetLocation, false, nil, true)
            --ugcprint("[Server] Teleport location success")
        end
    end)
    
    if not ok then
        --ugcprint("[Server] Server_TeleportPlayer error: " .. tostring(err))
    end
end

-- Client: set player rotation
function UGCPlayerController:Client_SetPlayerRotation(Yaw)
    --ugcprint("[Client] Client_SetPlayerRotation received: Yaw=" .. tostring(Yaw))
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local newRotation = Rotator.New(0, Yaw, 0)
        PlayerPawn:K2_SetActorRotation(newRotation, false)
        
        if self.SetControlRotation then
            self:SetControlRotation(newRotation)
        end
        
        --ugcprint("[Client] Client rotation set: Yaw=" .. Yaw)
    end
end

-- Server: destroy nearby corpses and absorb exp
function UGCPlayerController:Server_DestroyNearbyCorpses()
    --ugcprint("[Server] Server_DestroyNearbyCorpses request received")
    
    if not self:HasAuthority() then
        --ugcprint("[Server] Error: not server, exit")
        return
    end
    
    local ok, err = pcall(function()
        local PlayerPawn = self.Pawn or self:K2_GetPawn()
        if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
            --ugcprint("[Server] Error: unable to get player Pawn")
            return
        end
        
        local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
        if not PlayerState then
            --ugcprint("[Server] Error: unable to get PlayerState")
            return
        end
        
        local playerLocation = PlayerPawn:K2_GetActorLocation()
        
        -- Get dead monsters list
        local deadMonsters = UGCGameData.DeadMonsters
        --ugcprint("[Server] Dead monsters count: " .. #deadMonsters)
        
        local destroyedCount = 0
        local totalExp = 0
        local remainingMonsters = {}
        
        -- Check each dead monster's distance
        for i, monster in ipairs(deadMonsters) do
            if monster and UGCObjectUtility.IsObjectValid(monster) then
                local monsterLocation = monster:K2_GetActorLocation()
                local diffX = playerLocation.X - monsterLocation.X
                local diffY = playerLocation.Y - monsterLocation.Y
                local diffZ = playerLocation.Z - monsterLocation.Z
                local distance = math.sqrt(diffX*diffX + diffY*diffY + diffZ*diffZ)
                
                -- Within absorb range (1000 units)
                if distance < 1000 then
                    if monster.MonsterID then
                        local monsterConfig = UGCGameData.GetMonsterConfig(monster.MonsterID)
                        if monsterConfig and monsterConfig.KillExp and monsterConfig.KillExp > 0 then
                            -- Get extra exp bonus
                            local ecexp = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'Ecexp') or 0
                            
                            -- Calculate exp with bonus
                            local baseExp = monsterConfig.KillExp
                            local bonusRate = 1 + 0.5 + (ecexp / 100)
                            local monsterExp = math.floor(baseExp * bonusRate)
                            totalExp = totalExp + monsterExp
                            
                            --ugcprint("[Server] Absorb monster ID=" .. monster.MonsterID .. ", baseExp: " .. baseExp .. ", Ecexp: " .. ecexp .. "%, bonusRate: " .. bonusRate .. ", finalExp: " .. monsterExp)
                            
                            -- Notify client of absorb success
                            UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowTunshiSuccess", monsterExp)
                        end
                    end
                    
                    monster:SetActorHiddenInGame(true)
                    monster:K2_DestroyActor()
                    destroyedCount = destroyedCount + 1
                else
                    table.insert(remainingMonsters, monster)
                end
            end
        end
        
        -- Update dead monsters list
        UGCGameData.DeadMonsters = remainingMonsters
        --ugcprint("[Server] Destroyed " .. destroyedCount .. " corpses, remaining " .. #remainingMonsters)
        
        -- Grant total exp
        if totalExp > 0 then
            --ugcprint("[Server] Absorb total exp: " .. totalExp)
            
            if PlayerState.AddExp then
                PlayerState:AddExp(totalExp)
                --ugcprint("[Server] Exp granted")
            end

            -- Share exp to team members
            local teamShareExp = math.floor(totalExp * TEAM_ABSORB_EXP_SHARE_RATE)
            if teamShareExp > 0 then
                local teamID = UGCPawnAttrSystem.GetTeamID(PlayerPawn)
                local teamPlayerStates = teamID and UGCTeamSystem.GetPlayerStatesByTeamID(teamID) or nil
                if teamPlayerStates then
                    for _, teammateState in ipairs(teamPlayerStates) do
                        if teammateState and teammateState ~= PlayerState and teammateState.AddExp then
                            teammateState:AddExp(teamShareExp)
                        end
                    end
                end
            end
            
            -- Add absorb VFX buff
            local buffPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tunshi.tunshi_C')
            local buffObj = UGCPersistEffectSystem.AddBuffByClass(PlayerPawn, buffPath, nil, 2, 1)
            
            if buffObj then
                --ugcprint("[Server] Absorb VFX buff added successfully")
            else
                --ugcprint("[Server] Absorb VFX buff failed to add")
            end
        end
    end)
    
    if not ok then
        --ugcprint("[Server] Server_DestroyNearbyCorpses error: " .. tostring(err))
    end
end

-- Server: set direct exp enabled
function UGCPlayerController:Server_SetDirectExpEnabled(isEnabled)
    --ugcprint("[Server] Server_SetDirectExpEnabled request: " .. tostring(isEnabled))
    
    if not self:HasAuthority() then
        --ugcprint("[Server] Error: not server, exit")
        return
    end
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        --ugcprint("[Server] Error: unable to get player Pawn")
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
    if not PlayerState then
        --ugcprint("[Server] Error: unable to get PlayerState")
        return
    end
    
    -- Delegate to PlayerState
    if PlayerState.Server_SetDirectExpEnabled then
        PlayerState:Server_SetDirectExpEnabled(isEnabled)
    end
end

-- Server: set bloodline enabled
function UGCPlayerController:Server_SetBloodlineEnabled(isEnabled)
    --ugcprint("[Server] Server_SetBloodlineEnabled request: " .. tostring(isEnabled))
    
    if not self:HasAuthority() then
        --ugcprint("[Server] Error: not server, exit")
        return
    end
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        --ugcprint("[Server] Error: unable to get player Pawn")
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
    if not PlayerState then
        --ugcprint("[Server] Error: unable to get PlayerState")
        return
    end
    
    -- Delegate to PlayerState
    if PlayerState.Server_SetBloodlineEnabled then
        PlayerState:Server_SetBloodlineEnabled(isEnabled)
    end
end

-- Server: set auto absorb enabled
function UGCPlayerController:Server_SetAutoTunshiEnabled(isEnabled)
    if not self:HasAuthority() then
        return
    end

    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        return
    end

    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
    if not PlayerState then
        return
    end

    if PlayerState.Server_SetAutoTunshiEnabled then
        PlayerState:Server_SetAutoTunshiEnabled(isEnabled)
    end
end

-- Server: set auto pickup enabled
function UGCPlayerController:Server_SetAutoPickupEnabled(isEnabled)
    if not self:HasAuthority() then
        return
    end

    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        return
    end

    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
    if not PlayerState then
        return
    end

    if PlayerState.Server_SetAutoPickupEnabled then
        PlayerState:Server_SetAutoPickupEnabled(isEnabled)
    end
end

-- ============ Settlement UI Functions ============

--- Client: show Settlement UI (level reward)
function UGCPlayerController:Client_ShowSettlementUI()
    -- ugcprint("[UGCPlayerController] Client_ShowSettlementUI called")
    
    if not self:IsLocalController() then
        return
    end

    if self.MMainUI and self.MMainUI.StopCountdown then
        self.MMainUI.CountdownTimeoutTriggered = true
        self.MMainUI:StopCountdown()
    end
    
    local settlementPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement.Settlement_C')
    -- ugcprint("[UGCPlayerController] Settlement UI path: " .. tostring(settlementPath))
    
    -- Capture PlayerController reference for async callback
    local PlayerController = self
    
    -- Create Settlement UI asynchronously
    UGCWidgetManagerSystem.CreateWidgetAsync(settlementPath, function(Widget)
        --ugcprint("[UGCPlayerController] CreateWidgetAsync callback triggered")
        if Widget then
            -- ugcprint("[UGCPlayerController] Settlement UI created successfully")
            
            -- Bind sure button click callback
            Widget.OnSureClicked = function()
                -- ugcprint("[UGCPlayerController] Settlement UI sure button clicked")
                --ugcprint("[UGCPlayerController] Preparing to call server RPC")
                
                -- Notify server that level reward is finished
                UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyLevelRewardFinish")
            end
            
            -- Add to viewport with high Z-order
            Widget:AddToViewport(6000)
            ugcprint("[UGCPlayerController] Settlement UI added to viewport")
        else
            -- ugcprint("[UGCPlayerController] Failed to create Settlement UI, Widget is nil")
        end
    end)
end

local function CleanupSettlementTipState(PlayerController, reason)
    if reason then
        -- ugcprint("[UGCPlayerController] SettlementTip flow ended: " .. tostring(reason))
    end

    if PlayerController and PlayerController.SettlementTipWidget and UGCObjectUtility.IsObjectValid(PlayerController.SettlementTipWidget) then
        PlayerController.SettlementTipWidget:RemoveFromParent()
    end

    if PlayerController then
        PlayerController.SettlementTipWidget = nil
        PlayerController.SettlementTipMatchingInProgress = false
        PlayerController.SettlementTipRequestSent = false
        PlayerController.SettlementTipRetryUsed = false
    end
end

--- Client: show SettlementTip UI and start matching
function UGCPlayerController:Client_ShowSettlementTipUI()
    -- ugcprint("[UGCPlayerController] Client_ShowSettlementTipUI called")
    
    if not self:IsLocalController() then
        return
    end

    if self.MMainUI and self.MMainUI.StopCountdown then
        self.MMainUI.CountdownTimeoutTriggered = true
        self.MMainUI:StopCountdown()
    end

    if self.SettlementTipMatchingInProgress then
        -- ugcprint("[UGCPlayerController] Matching already in progress, ignore duplicate trigger")
        return
    end
    self.SettlementTipMatchingInProgress = true
    self.SettlementTipRequestSent = false
    self.SettlementTipRetryUsed = false
    
    local settlementTipPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/SettlementTip.SettlementTip_C')
    -- ugcprint("[UGCPlayerController] SettlementTip UI path: " .. tostring(settlementTipPath))
    
    -- Capture PlayerController reference
    local PlayerController = self
    
    -- Create SettlementTip UI
    UGCWidgetManagerSystem.CreateWidgetAsync(settlementTipPath, function(Widget)
        if Widget then
            -- ugcprint("[UGCPlayerController] SettlementTip UI created successfully")
            
            -- Add to viewport, will stay visible
            Widget:AddToViewport(6000)
            self.SettlementTipWidget = Widget
            -- ugcprint("[UGCPlayerController] SettlementTip UI added to viewport, will stay visible")
        else
            -- ugcprint("[UGCPlayerController] Failed to create SettlementTip UI, continue with match request")
        end
    end)

    if not UGCMultiMode then
        -- ugcprint("[UGCPlayerController] Error: UGCMultiMode does not exist")
        CleanupSettlementTipState(self, "UGCMultiMode nil")
        return
    end

    if not self.SettlementTipMatchDelegateBound then
        UGCMultiMode.NotifyMatchSucceededDelegate:Add(function()
            -- ugcprint("[UGCPlayerController] Match succeeded! Hide SettlementTip UI")
            CleanupSettlementTipState(PlayerController, "MatchSucceeded")
        end, PlayerController)
        self.SettlementTipMatchDelegateBound = true
    end

    local function SendMatchRequest()
        if not self.SettlementTipMatchingInProgress or self.SettlementTipRequestSent then
            return
        end

        self.SettlementTipRequestSent = true

        local ok, requestResult = pcall(function()
            return UGCMultiMode.RequestMatch(1001, function(bSuccess)
                if bSuccess then
                    -- ugcprint("[UGCPlayerController] Mode 1001 match request success, waiting for match callback...")
                    return
                end

                -- ugcprint("[UGCPlayerController] Mode 1001 match request failed")
                self.SettlementTipRequestSent = false

                if self.SettlementTipRetryUsed then
                    CleanupSettlementTipState(self, "RequestMatch callback failed")
                else
                    self.SettlementTipRetryUsed = true
                    -- ugcprint("[UGCPlayerController] Retry mode 1001 match in 2 seconds")
                    UGCTimerUtility.CreateLuaTimer(2.0, function()
                        SendMatchRequest()
                    end, false, "SettlementTip_RequestRetry")
                end
            end, PlayerController)
        end)

        if not ok then
            -- ugcprint("[UGCPlayerController] RequestMatch exception: " .. tostring(requestResult))
            self.SettlementTipRequestSent = false
            CleanupSettlementTipState(self, "RequestMatch exception")
            return
        end

        if not requestResult then
            -- ugcprint("[UGCPlayerController] RequestMatch call failed")
            self.SettlementTipRequestSent = false
            if self.SettlementTipRetryUsed then
                CleanupSettlementTipState(self, "RequestMatch return false")
            else
                self.SettlementTipRetryUsed = true
                -- ugcprint("[UGCPlayerController] Retry mode 1001 match in 2 seconds")
                UGCTimerUtility.CreateLuaTimer(2.0, function()
                    SendMatchRequest()
                end, false, "SettlementTip_RequestRetry")
            end
            return
        end

        local watchdogToken = (self.SettlementTipWatchdogToken or 0) + 1
        self.SettlementTipWatchdogToken = watchdogToken

        UGCTimerUtility.CreateLuaTimer(8.0, function()
            if not self.SettlementTipMatchingInProgress then
                return
            end

            if self.SettlementTipWatchdogToken ~= watchdogToken then
                return
            end

            if not self.SettlementTipRequestSent then
                return
            end

            -- ugcprint("[UGCPlayerController] Match request timeout, preparing retry")
            self.SettlementTipRequestSent = false

            if self.SettlementTipRetryUsed then
                CleanupSettlementTipState(self, "Match watchdog timeout")
            else
                self.SettlementTipRetryUsed = true
                SendMatchRequest()
            end
        end, false, "SettlementTip_MatchWatchdog")
    end

    SendMatchRequest()
end

--- Client: show Settlement_2 UI (timeout settlement)
function UGCPlayerController:Client_ShowSettlement2UI()
    -- ugcprint("[UGCPlayerController] Client_ShowSettlement2UI called")
    
    if not self:IsLocalController() then
        return
    end

    if self.MMainUI and self.MMainUI.StopCountdown then
        self.MMainUI.CountdownTimeoutTriggered = true
        self.MMainUI:StopCountdown()
    end
    
    local settlement2Path = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement_2.Settlement_2_C')
    -- ugcprint("[UGCPlayerController] Settlement_2 UI path: " .. tostring(settlement2Path))
    
    -- Capture PlayerController reference
    local PlayerController = self
    
    -- Create Settlement_2 UI asynchronously
    UGCWidgetManagerSystem.CreateWidgetAsync(settlement2Path, function(Widget)
        if Widget then
            -- ugcprint("[UGCPlayerController] Settlement_2 UI created successfully")
            
            -- Bind sure button click callback
            Widget.OnSureClicked = function()
                -- ugcprint("[UGCPlayerController] Settlement_2 sure button triggered")
                
                -- Notify server that timeout is finished
                UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyTimeOutFinish")
            end
            
            -- Add to viewport
            Widget:AddToViewport(6000)
            -- ugcprint("[UGCPlayerController] Settlement_2 UI added to viewport")
        else
            -- ugcprint("[UGCPlayerController] Failed to create Settlement_2 UI, Widget is nil")
        end
    end)
end

-- Stop all TriggerBox_Single1 spawners before matching
local function StopSingle1SpawnersBeforeMatch()
    local okGet, allTriggers = pcall(function()
        return UGCGameSystem.GetAllActorsOfClass("Script.MODE.TriggerBox_Single1")
    end)

    if not okGet then
        -- ugcprint("[Server] Failed to get TriggerBox_Single1: " .. tostring(allTriggers))
        return
    end

    if not allTriggers or #allTriggers == 0 then
        -- ugcprint("[Server] TriggerBox_Single1 not found before matching")
        return
    end

    for _, trigger in pairs(allTriggers) do
        if trigger and trigger.StopAndCleanAll then
            local okStop, stopErr = pcall(function()
                trigger:StopAndCleanAll()
            end)

            if not okStop then
                -- ugcprint("[Server] TriggerBox_Single1 StopAndCleanAll failed: " .. tostring(stopErr))
            end
        end
    end

    -- ugcprint("[Server] Pre-match TriggerBox_Single1 stop/clean executed")
end

--- Server: notify level reward finished
function UGCPlayerController:Server_NotifyLevelRewardFinish()
    -- ugcprint("[Server] Server_NotifyLevelRewardFinish called")
    
    if not self:HasAuthority() then
        --ugcprint("[Server] Error: not server, exit")
        return
    end

    if self.LevelRewardFinishTriggered then
        -- ugcprint("[Server] Server_NotifyLevelRewardFinish already completed, ignore duplicate call")
        return
    end

    if self.LevelRewardFinishProcessing then
        -- ugcprint("[Server] Server_NotifyLevelRewardFinish is processing, ignore duplicate call")
        return
    end

    self.LevelRewardFinishProcessing = true

    local ok, err = pcall(function()
        -- Stop spawners before matching
        StopSingle1SpawnersBeforeMatch()
        
        -- Call OnFinish on current level reward actor
        if self.CurrentLevelRewardActor then
            -- ugcprint("[Server] Found CurrentLevelRewardActor, calling OnFinish()")
            self.CurrentLevelRewardActor:OnFinish()
            self.CurrentLevelRewardActor = nil
        else
            -- ugcprint("[Server] Warning: CurrentLevelRewardActor does not exist")
        end
    end)

    self.LevelRewardFinishProcessing = false

    if not ok then
        -- ugcprint("[Server] Server_NotifyLevelRewardFinish exception: " .. tostring(err))
        return
    end

    self.LevelRewardFinishTriggered = true
end

--- Server: notify timeout finished
function UGCPlayerController:Server_NotifyTimeOutFinish()
    -- ugcprint("[Server] Server_NotifyTimeOutFinish called")
    
    if not self:HasAuthority() then
        return
    end

    if self.TimeoutFinishTriggered then
        -- ugcprint("[Server] Server_NotifyTimeOutFinish already completed, ignore duplicate call")
        return
    end

    if self.TimeoutFinishProcessing then
        -- ugcprint("[Server] Server_NotifyTimeOutFinish is processing, ignore duplicate call")
        return
    end

    self.TimeoutFinishProcessing = true

    local ok, err = pcall(function()
        -- Stop spawners before matching
        StopSingle1SpawnersBeforeMatch()
        
        -- Call OnFinish on current timeout actor
        if self.CurrentTimeOutActor then
            if self.CurrentTimeOutActor.OnFinish then
                -- ugcprint("[Server] Found CurrentTimeOutActor, calling OnFinish()")
                self.CurrentTimeOutActor:OnFinish()
            end
            self.CurrentTimeOutActor = nil
            -- ugcprint("[Server] Cleared CurrentTimeOutActor reference")
        else
            -- ugcprint("[Server] Warning: CurrentTimeOutActor does not exist, continue matching flow")
        end
        
        -- Show SettlementTip UI on client for matching
        -- ugcprint("[Server] Call client RPC to show SettlementTip UI")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
    end)

    self.TimeoutFinishProcessing = false

    if not ok then
        -- ugcprint("[Server] Server_NotifyTimeOutFinish exception: " .. tostring(err))
        return
    end

    self.TimeoutFinishTriggered = true
end

--- Client: on player level up notification
function UGCPlayerController:Client_OnPlayerLevelUp(newLevel, newMagic)
    if not self:IsLocalController() then
        return
    end
    -- Sync magic value to local PlayerState
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState and playerState.GameData and newMagic then
        playerState.GameData.PlayerMagic = newMagic
    end
end

--- Client: exp blocked by rebirth cap
function UGCPlayerController:Client_OnExpBlockedByRebirth()
    if not self:IsLocalController() then
        return
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        self.MMainUI:ShowTip("Cannot gain exp, please go rebirth")
    end
end

--- Client: sync mob kill count (mode 1002)
function UGCPlayerController:Client_SyncMobKillCount(currentKills, requiredKills)
    -- ugcprint("[UGCPlayerController] Client_SyncMobKillCount: " .. tostring(currentKills) .. "/" .. tostring(requiredKills))
    if not self:IsLocalController() then return end
    if self.MMainUI and self.MMainUI.UpdateMobKillCount then
        self.MMainUI:UpdateMobKillCount(currentKills, requiredKills)
    end
end

-- ============ Rewards ============

-- Server: give dungeon completion rewards
function UGCPlayerController:Server_GiveRewards()
    -- ugcprint("[Server] Server_GiveRewards called")
    local matchRewardVirtualID = 5666
    
    if not self:HasAuthority() then
        return
    end
    
    -- Read all dungeon rewards from config
    local allRewards = UGCGameData.GetAllFubenreword()
    if not allRewards then
        -- ugcprint("[Server] Server_GiveRewards error: unable to read dungeon reward table")
        return
    end

    local totalRewardCount = 0
    for rowName, rewardData in pairs(allRewards) do
        local itemCount = rewardData["数量"]

        if itemCount then
            itemCount = math.floor(tonumber(itemCount) or 0)

            if itemCount > 0 then
                totalRewardCount = totalRewardCount + itemCount
            end
        end
    end

    if totalRewardCount <= 0 then
        -- ugcprint("[Server] Server_GiveRewards warning: reward count is 0, skip")
        return
    end

    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VIM then
        -- ugcprint("[Server] Server_GiveRewards error: unable to get VirtualItemManager")
        return
    end

    VIM:AddVirtualItem(self, matchRewardVirtualID, totalRewardCount)
    -- ugcprint("[Server] Server_GiveRewards completed, virtual item ID=" .. tostring(matchRewardVirtualID) .. ", count=" .. tostring(totalRewardCount))
end

-- ============ Team System ============

-- Server: send team invite to target player
function UGCPlayerController:Server_SendTeamInvite(TargetPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_SendTeamInvite: TargetPlayerKey=" .. tostring(TargetPlayerKey))
    
    local InviterPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    
    -- If team has only 1 member, set inviter as captain
    local InviterPawn = self.Pawn
    if InviterPawn then
        local InviterTeamID = UGCPawnAttrSystem.GetTeamID(InviterPawn)
        local TeamPlayerKeys = UGCTeamSystem.GetPlayerKeysByTeamID(InviterTeamID)
        local teamCount = TeamPlayerKeys and #TeamPlayerKeys or 0
        
        if teamCount <= 1 then
            if not TeamCaptainData then
                TeamCaptainData = {}
            end
            TeamCaptainData[InviterTeamID] = InviterPlayerKey
            -- ugcprint("[UGCPlayerController] Team " .. tostring(InviterTeamID) .. " captain set to: " .. tostring(InviterPlayerKey))
        end
    end
    
    -- Send invite to target player's client
    local TargetPC = UGCGameSystem.GetPlayerControllerByPlayerKey(TargetPlayerKey)
    if TargetPC then
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_ReceiveTeamInvite", InviterPlayerKey)
    end
end

-- Server: respond to team invite
function UGCPlayerController:Server_RespondTeamInvite(InviterPlayerKey, bAccepted)
    -- ugcprint("[UGCPlayerController] Server_RespondTeamInvite: InviterPlayerKey=" .. tostring(InviterPlayerKey) .. ", bAccepted=" .. tostring(bAccepted))
    
    local ResponderPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local InviterTeamID = nil
    
    if bAccepted then
        local InviterPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(InviterPlayerKey)
        if InviterPawn then
            InviterTeamID = UGCPawnAttrSystem.GetTeamID(InviterPawn)
            UGCTeamSystem.ChangePlayerTeamID(ResponderPlayerKey, InviterTeamID)
            -- ugcprint("[UGCPlayerController] Team change: ResponderPlayerKey=" .. tostring(ResponderPlayerKey) .. " -> TeamID=" .. tostring(InviterTeamID))
        end
    end
    
    -- Notify inviter of the result
    local InviterPC = UGCGameSystem.GetPlayerControllerByPlayerKey(InviterPlayerKey)
    if InviterPC then
        UnrealNetwork.CallUnrealRPC(InviterPC, InviterPC, "Client_TeamInviteResult", ResponderPlayerKey, bAccepted, true)
    end
    
    -- Notify responder of the result
    if bAccepted then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_TeamInviteResult", InviterPlayerKey, bAccepted, false)

        -- Refresh all team member UIs
        if InviterTeamID then
            self:RefreshAllTeamUI(InviterTeamID)
        end
    end
end

-- Client: receive team invite
function UGCPlayerController:Client_ReceiveTeamInvite(InviterPlayerKey)
    -- ugcprint("[UGCPlayerController] Client_ReceiveTeamInvite: InviterPlayerKey=" .. tostring(InviterPlayerKey))
    
    local InviteClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Teamiinvite.WB_Teamiinvite_C'))
    if not InviteClass then
        -- ugcprint("[UGCPlayerController] Error: unable to load WB_Teamiinvite class")
        return
    end
    
    local inviteUI = UserWidget.NewWidgetObjectBP(self, InviteClass)
    if inviteUI then
        if inviteUI.SetInviteData then
            inviteUI:SetInviteData(InviterPlayerKey, false)
        else
            inviteUI.InviterPlayerKey = InviterPlayerKey
            inviteUI.IsJoinRequest = false
        end
        inviteUI:AddToViewport(7000)
    end
end

-- Client: team invite result notification
function UGCPlayerController:Client_TeamInviteResult(TargetPlayerKey, bAccepted, bIsCaptain)
    -- ugcprint("[UGCPlayerController] Client_TeamInviteResult: TargetPlayerKey=" .. tostring(TargetPlayerKey) .. ", bAccepted=" .. tostring(bAccepted) .. ", bIsCaptain=" .. tostring(bIsCaptain))
    
    if self.MMainUI and self.MMainUI.WB_Team then
        if bAccepted then
            if bIsCaptain and self.MMainUI.ShowTip then
                local TargetPlayerName = GetPlayerNameByPlayerKey(TargetPlayerKey)
                self.MMainUI:ShowTip(tostring(TargetPlayerName) .. " has joined the team")
            end

            if bIsCaptain then
                self.bIsTeamCaptain = true
                local LocalPawn = self.Pawn
                if LocalPawn then
                    self.TeamCaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerPawn(LocalPawn)
                end
            else
                self.bIsTeamCaptain = false
                self.TeamCaptainPlayerKey = TargetPlayerKey
            end
            -- Delayed refresh team UI
            UGCTimerUtility.CreateLuaTimer(
                0.5,
                function()
                    if self.MMainUI and self.MMainUI.WB_Team then
                        self.MMainUI.WB_Team:CreatePlayerSlots()
                    end
                end,
                false,
                "TeamInviteResult_Refresh"
            )
        else
            self.MMainUI.WB_Team:UpdateSlotState(TargetPlayerKey, "invite")
        end
    end
end

-- Server: kick player from team
function UGCPlayerController:Server_KickFromTeam(TargetPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_KickFromTeam: TargetPlayerKey=" .. tostring(TargetPlayerKey))
    
    local CaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local CaptainPawn = self.Pawn
    if not CaptainPawn then return end
    
    local CaptainTeamID = UGCPawnAttrSystem.GetTeamID(CaptainPawn)
    
    -- Check if is captain
    if not TeamCaptainData[CaptainTeamID] or TeamCaptainData[CaptainTeamID] ~= CaptainPlayerKey then
        -- ugcprint("[UGCPlayerController] Error: not captain, no permission to kick")
        return
    end
    
    -- Find an empty team ID
    local newTeamID = 100
    while true do
        local members = UGCTeamSystem.GetPlayerKeysByTeamID(newTeamID)
        if not members or #members == 0 then
            break
        end
        newTeamID = newTeamID + 1
    end
    
    UGCTeamSystem.ChangePlayerTeamID(TargetPlayerKey, newTeamID)
    
    -- Refresh old team UI
    self:RefreshAllTeamUI(CaptainTeamID)
    
    -- Notify kicked player
    local TargetPC = UGCGameSystem.GetPlayerControllerByPlayerKey(TargetPlayerKey)
    if TargetPC then
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_RefreshTeamUI", -1)
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_OnKickedFromTeam")
    end
end

-- Server: leave team
function UGCPlayerController:Server_LeaveTeam()
    local LeaverPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    -- ugcprint("[UGCPlayerController] Server_LeaveTeam: PlayerKey=" .. tostring(LeaverPlayerKey))
    
    local LeaverPawn = self.Pawn
    if not LeaverPawn then return end
    
    local OldTeamID = UGCPawnAttrSystem.GetTeamID(LeaverPawn)
    
    -- Find an empty team ID
    local newTeamID = 100
    while true do
        local members = UGCTeamSystem.GetPlayerKeysByTeamID(newTeamID)
        if not members or #members == 0 then
            break
        end
        newTeamID = newTeamID + 1
    end
    
    UGCTeamSystem.ChangePlayerTeamID(LeaverPlayerKey, newTeamID)
    
    -- Refresh old team UI
    self:RefreshAllTeamUI(OldTeamID)
    
    -- Refresh leaver's UI
    UnrealNetwork.CallUnrealRPC(self, self, "Client_RefreshTeamUI", -1)
end

-- Server: request to join team
function UGCPlayerController:Server_RequestJoinTeam(CaptainPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_RequestJoinTeam: CaptainPlayerKey=" .. tostring(CaptainPlayerKey))
    
    local RequesterPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    
    local CaptainPC = UGCGameSystem.GetPlayerControllerByPlayerKey(CaptainPlayerKey)
    if CaptainPC then
        UnrealNetwork.CallUnrealRPC(CaptainPC, CaptainPC, "Client_ReceiveJoinRequest", RequesterPlayerKey)
    end
end

-- Server: accept join request
function UGCPlayerController:Server_AcceptJoinRequest(RequesterPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_AcceptJoinRequest: RequesterPlayerKey=" .. tostring(RequesterPlayerKey))
    
    local CaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local CaptainPawn = self.Pawn
    if not CaptainPawn then return end
    
    local CaptainTeamID = UGCPawnAttrSystem.GetTeamID(CaptainPawn)
    
    -- Check if is captain
    if not TeamCaptainData[CaptainTeamID] or TeamCaptainData[CaptainTeamID] ~= CaptainPlayerKey then
        -- ugcprint("[UGCPlayerController] Error: not captain, no permission to accept join request")
        return
    end
    
    -- Change requester to captain's team
    UGCTeamSystem.ChangePlayerTeamID(RequesterPlayerKey, CaptainTeamID)
    
    -- Notify captain
    UnrealNetwork.CallUnrealRPC(self, self, "Client_TeamInviteResult", RequesterPlayerKey, true, true)
    
    -- Notify requester
    local RequesterPC = UGCGameSystem.GetPlayerControllerByPlayerKey(RequesterPlayerKey)
    if RequesterPC then
        UnrealNetwork.CallUnrealRPC(RequesterPC, RequesterPC, "Client_TeamInviteResult", CaptainPlayerKey, true, false)
    end
    
    -- Notify other team members
    local TeamPCs = UGCTeamSystem.GetPlayerControllersByTeamID(CaptainTeamID)
    if TeamPCs then
        for _, PC in ipairs(TeamPCs) do
            local PCPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PC)
            if PCPlayerKey ~= CaptainPlayerKey and PCPlayerKey ~= RequesterPlayerKey then
                UnrealNetwork.CallUnrealRPC(PC, PC, "Client_RefreshTeamUI", CaptainPlayerKey)
            end
        end
    end
end

-- Client: receive join request
function UGCPlayerController:Client_ReceiveJoinRequest(RequesterPlayerKey)
    -- ugcprint("[UGCPlayerController] Client_ReceiveJoinRequest: RequesterPlayerKey=" .. tostring(RequesterPlayerKey))
    
    local InviteClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Teamiinvite.WB_Teamiinvite_C'))
    if not InviteClass then return end
    
    local inviteUI = UserWidget.NewWidgetObjectBP(self, InviteClass)
    if inviteUI then
        if inviteUI.SetInviteData then
            inviteUI:SetInviteData(RequesterPlayerKey, true)
        else
            inviteUI.InviterPlayerKey = RequesterPlayerKey
            inviteUI.IsJoinRequest = true
        end
        inviteUI:AddToViewport(7000)
    end
end

--- Client: refresh team UI
function UGCPlayerController:Client_RefreshTeamUI(CaptainPK)
    -- ugcprint("[UGCPlayerController] Client_RefreshTeamUI called, CaptainPK=" .. tostring(CaptainPK))
    
    if CaptainPK and CaptainPK ~= -1 then
        self.TeamCaptainPlayerKey = CaptainPK
    end
    
    UGCTimerUtility.CreateLuaTimer(
        0.5,
        function()
            local LocalPawn = self.Pawn
            if LocalPawn then
                local LocalTeamID = UGCPawnAttrSystem.GetTeamID(LocalPawn)
                local TeamPawns = UGCTeamSystem.GetPlayerPawnsByTeamID(LocalTeamID)
                local teamCount = TeamPawns and #TeamPawns or 0
                if teamCount <= 1 then
                    self.bIsTeamCaptain = nil
                    self.TeamCaptainPlayerKey = nil
                end
            end
            
            if self.MMainUI and self.MMainUI.WB_Team then
                self.MMainUI.WB_Team:CreatePlayerSlots()
            end
        end,
        false,
        "RefreshTeamUI_Timer"
    )
end

--- Client: kicked from team notification
function UGCPlayerController:Client_OnKickedFromTeam()
    if self.MMainUI and self.MMainUI.ShowTip then
        self.MMainUI:ShowTip("You have been kicked from the team")
    end
end

--- Server: request team panel player data
function UGCPlayerController:Server_RequestTeamPanelPlayers()
    if not self:HasAuthority() then
        return
    end

    local localPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    -- ugcprint("[UGCPlayerController] Server_RequestTeamPanelPlayers: Requester=" .. tostring(localPlayerKey))
    local localTeamID = -1

    local localPawn = self.Pawn
    if (not localPawn or not UGCObjectUtility.IsObjectValid(localPawn)) and self.K2_GetPawn then
        localPawn = self:K2_GetPawn()
    end
    if localPawn and UGCObjectUtility.IsObjectValid(localPawn) then
        localTeamID = UGCPawnAttrSystem.GetTeamID(localPawn)
    end

    local captainPK = -1
    if TeamCaptainData and localTeamID and TeamCaptainData[localTeamID] then
        captainPK = TeamCaptainData[localTeamID]
    end
    local bIsCaptain = (captainPK ~= -1 and localPlayerKey == captainPK)

    UnrealNetwork.CallUnrealRPC(self, self, "Client_BeginTeamPanelPlayers", captainPK, bIsCaptain)

    local allPCs = UGCGameSystem.GetAllPlayerController()
    local pushedCount = 0
    if allPCs then
        for _, pc in pairs(allPCs) do
            if pc then
                local playerKey = UGCGameSystem.GetPlayerKeyByPlayerController(pc)
                if playerKey and playerKey > 0 then
                    local pawn = pc.Pawn
                    if (not pawn or not UGCObjectUtility.IsObjectValid(pawn)) and pc.K2_GetPawn then
                        pawn = pc:K2_GetPawn()
                    end

                    local playerState = pc.PlayerState or (pawn and pawn.PlayerState) or UGCGameSystem.GetPlayerStateByPlayerController(pc)

                    local playerName = ""
                    if pawn and UGCObjectUtility.IsObjectValid(pawn) then
                        playerName = UGCPawnAttrSystem.GetPlayerName(pawn) or ""
                    end
                    if (not playerName or playerName == "") and playerState and playerState.PlayerName then
                        playerName = playerState.PlayerName
                    end
                    if not playerName or playerName == "" then
                        playerName = "Unknown Player"
                    end

                    local teamID = -1
                    if pawn and UGCObjectUtility.IsObjectValid(pawn) then
                        teamID = UGCPawnAttrSystem.GetTeamID(pawn)
                    elseif playerState and playerState.TeamID then
                        teamID = playerState.TeamID
                    end

                    local iconUrl = ""
                    if playerState then
                        local pkInt64 = UGCPlayerStateSystem.GetPlayerKeyInt64(playerState)
                        local accountInfo = UGCPlayerStateSystem.GetPlayerAccountInfo(pkInt64)
                        if accountInfo then
                            iconUrl = accountInfo.IconUrl or ""
                        end
                    end

                    local combatPower = 0
                    if playerState then
                        combatPower = tonumber(playerState.UGCPlayerCombatPower) or 0
                        if combatPower <= 0 and playerState.GetCombatPower then
                            combatPower = tonumber(playerState:GetCombatPower()) or 0
                        end
                    end

                    UnrealNetwork.CallUnrealRPC(self, self, "Client_AddTeamPanelPlayer", playerKey, playerName, teamID, iconUrl, combatPower)
                    pushedCount = pushedCount + 1
                end
            end
        end
    end

    -- ugcprint("[UGCPlayerController] Server_RequestTeamPanelPlayers: PushedCount=" .. tostring(pushedCount))

    UnrealNetwork.CallUnrealRPC(self, self, "Client_EndTeamPanelPlayers")
end

-- Client: begin receiving team panel player data
function UGCPlayerController:Client_BeginTeamPanelPlayers(CaptainPK, bIsCaptain)
    self.TeamPanelPlayerData = {}

    if CaptainPK and CaptainPK ~= -1 then
        self.TeamCaptainPlayerKey = CaptainPK
    else
        self.TeamCaptainPlayerKey = nil
    end

    self.bIsTeamCaptain = (bIsCaptain == true)
end

--- Client: add team panel player entry
function UGCPlayerController:Client_AddTeamPanelPlayer(PlayerKey, PlayerName, TeamID, IconUrl, CombatPower)
    if not self.TeamPanelPlayerData then
        self.TeamPanelPlayerData = {}
    end

    table.insert(self.TeamPanelPlayerData, {
        PlayerKey = PlayerKey,
        PlayerName = PlayerName,
        TeamID = TeamID,
        IconUrl = IconUrl,
        CombatPower = CombatPower,
    })
end

--- Client: end receiving team panel player data
function UGCPlayerController:Client_EndTeamPanelPlayers()
    local count = 0
    if self.TeamPanelPlayerData then
        for _, _ in pairs(self.TeamPanelPlayerData) do
            count = count + 1
        end
    end
    -- ugcprint("[UGCPlayerController] Client_EndTeamPanelPlayers: ReceivedCount=" .. tostring(count))

    if self.MMainUI and self.MMainUI.WB_Team and self.MMainUI.WB_Team.CreatePlayerSlots then
        self.MMainUI.WB_Team:CreatePlayerSlots(true)
    end
end

--- Refresh all team member UIs
function UGCPlayerController:RefreshAllTeamUI(TeamID)
    local CaptainPK = TeamCaptainData and TeamCaptainData[TeamID] or -1
    local TeamPCs = UGCTeamSystem.GetPlayerControllersByTeamID(TeamID)
    if TeamPCs then
        for _, PC in ipairs(TeamPCs) do
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_RefreshTeamUI", CaptainPK)
        end
    end
end

-- ============ Jiange (Sword Pavilion) UI ============

--- Client: show Jiange settlement UI (ta_settlement)
function UGCPlayerController:Client_ShowTaSettlementUI(LevelNum)
    -- ugcprint("[UGCPlayerController] Client_ShowTaSettlementUI called, LevelNum=" .. tostring(LevelNum))

    if not self:IsLocalController() then return end

    -- Show ta_settlement panel in JiangeUI
    if self.JiangeUI and self.JiangeUI.ta_settlement then
        local taUI = self.JiangeUI.ta_settlement
        taUI.DisplayLevelNum = LevelNum
        if taUI.settlementtip then
            taUI.settlementtip:SetText("Congratulations on passing floor " .. tostring(LevelNum) .. ", rewards below")
        end
        if taUI.CreateRewardSlots then
            taUI:CreateRewardSlots()
        end
        taUI:SetVisibility(0) -- Visible
        -- Update floor display text
        if self.JiangeUI.UpdateFloorText then
            self.JiangeUI:UpdateFloorText()
        end
        -- ugcprint("[UGCPlayerController] ta_settlement UI shown, floor=" .. tostring(LevelNum))
    else
        -- ugcprint("[UGCPlayerController] Error: JiangeUI or ta_settlement does not exist")
    end
end

--- Server: resume TriggerBox spawning
function UGCPlayerController:Server_ResumeTriggerBoxSpawning()
    -- ugcprint("[UGCPlayerController] Server_ResumeTriggerBoxSpawning called")

    if self.CurrentTriggerBox and self.CurrentTriggerBox.ResumeSpawning then
        -- ugcprint("[UGCPlayerController] Found TriggerBox, resuming spawning")
        self.CurrentTriggerBox:ResumeSpawning()
    else
        -- ugcprint("[UGCPlayerController] Error: CurrentTriggerBox is nil or has no ResumeSpawning method")
    end
end

-- Client: update Jiange floor display
function UGCPlayerController:Client_UpdateJiangeFloor(floor)
    -- ugcprint("[UGCPlayerController] Client_UpdateJiangeFloor: " .. tostring(floor))
    if not self:IsLocalController() then return end

    -- Save floor value
    self.JiangeFloor = floor

    -- Update floor text in UI
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.cengshu then
        self.MMainUI.wujingjiange.cengshu:SetText(tostring(floor + 1))
    end

    -- Refresh reward states
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.RefreshRewardStates then
        self.MMainUI.wujingjiange:RefreshRewardStates()
    end
end

-- Client: sync Jiange reward data
function UGCPlayerController:Client_SyncJiangeRewardData(claimedFloorsStr, dailyClaimDate, dailyAmount)
    -- ugcprint("[UGCPlayerController] Client_SyncJiangeRewardData: claimed=" .. tostring(claimedFloorsStr) .. ", date=" .. tostring(dailyClaimDate) .. ", daily=" .. tostring(dailyAmount))
    if not self:IsLocalController() then return end

    self.JiangeClaimedFloors = claimedFloorsStr or ""
    self.JiangeDailyClaimDate = dailyClaimDate or ""
    self.JiangeDailyAmount = dailyAmount or 1

    -- Refresh Jiange reward UI
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.RefreshRewardStates then
        self.MMainUI.wujingjiange:RefreshRewardStates()
    end
end

-- Client: Jiange daily claim result
function UGCPlayerController:Client_OnJiangeDailyClaimResult(success, amount, tipText)
    -- ugcprint("[UGCPlayerController] Client_OnJiangeDailyClaimResult: success=" .. tostring(success) .. ", amount=" .. tostring(amount) .. ", tip=" .. tostring(tipText))
    if not self:IsLocalController() then return end

    -- Clear pending state
    if self.MMainUI and self.MMainUI.wujingjiange then
        self.MMainUI.wujingjiange.DailyClaimPending = false
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip("Claim successful!")
        else
            self.MMainUI:ShowTip("Claim failed, please try again later")
        end
    end
end

-- Client: Jiange forge consume result
function UGCPlayerController:Client_OnJiangeForgeConsumeResult(success, remainCount, tipText)
    -- ugcprint("[UGCPlayerController] Client_OnJiangeForgeConsumeResult: success=" .. tostring(success) .. ", remainCount=" .. tostring(remainCount) .. ", tip=" .. tostring(tipText))
    if not self:IsLocalController() then return end

    if self.MMainUI and self.MMainUI.jiange and self.MMainUI.jiange.OnForgeConsumeResult then
        self.MMainUI.jiange:OnForgeConsumeResult(success, remainCount, tipText)
        return
    end

    if self.MMainUI and self.MMainUI.ShowTip and tipText and tipText ~= "" then
        self.MMainUI:ShowTip(tostring(tipText))
    end
end

-- Client: start countdown timer
function UGCPlayerController:Client_StartCountdown(totalSeconds)
    -- ugcprint("[UGCPlayerController] Client_StartCountdown called, totalSeconds=" .. tostring(totalSeconds))
    if not self:IsLocalController() then return end

    if self.MMainUI and self.MMainUI.StartCountdown then
        self.MMainUI:StartCountdown(totalSeconds)
    else
        -- ugcprint("[UGCPlayerController] Error: MMainUI or StartCountdown does not exist")
    end
end

-- Client: sync Jiange data (level and progress)
function UGCPlayerController:Client_SyncJiangeData(jiangeLevel, jiangeProgress)
    -- ugcprint("[UGCPlayerController] Client_SyncJiangeData: level=" .. tostring(jiangeLevel) .. ", progress=" .. tostring(jiangeProgress))
    if not self:IsLocalController() then return end
    -- Save locally for UI to read
    self.SavedJiangeLevel = jiangeLevel
    self.SavedJiangeProgress = jiangeProgress
    -- If Jiange UI is open, load data directly
    if self.MMainUI and self.MMainUI.jiange and self.MMainUI.jiange.LoadSavedData then
        self.MMainUI.jiange:LoadSavedData(jiangeLevel, jiangeProgress)
    end
end

-- Client: sync Shenyin (Shadow) data
function UGCPlayerController:Client_SyncShenyinData(dataStr)
    -- ugcprint("[UGCPlayerController] Client_SyncShenyinData: " .. tostring(dataStr))
    if not self:IsLocalController() then return end
    self.SavedShenyinData = dataStr
    -- If Shenyin UI is open, load data directly
    if self.MMainUI and self.MMainUI.shenyin and self.MMainUI.shenyin.LoadSavedData then
        self.MMainUI.shenyin:LoadSavedData(dataStr)
    end
end

-- Client: p1 companion died notification
function UGCPlayerController:Client_OnP1Died()
    -- ugcprint("[UGCPlayerController] Client_OnP1Died called")
    if not self:IsLocalController() then return end

    -- Show defense failed tip
    if self.MMainUI and self.MMainUI.ShowTip then
        self.MMainUI:ShowTip("Defense failed")
    end

    -- Delay 2 seconds then enter exit flow
    local PlayerController = self
    UGCTimerUtility.CreateLuaTimer(2.0, function()
        -- ugcprint("[UGCPlayerController] Defense failed, entering exit flow")
        PlayerController:Client_ShowSettlementTipUI()
    end, false, "P1Died_DelayExit")
end

local function IsWidgetShown(Widget)
    if not Widget then
        return false
    end

    local visibility = Widget:GetVisibility()
    return visibility == ESlateVisibility.Visible
        or visibility == ESlateVisibility.SelfHitTestInvisible
        or visibility == ESlateVisibility.HitTestInvisible
end

local function RestoreWidgetAfterRespawn(Widget, widgetTag)
    if not Widget then
        return
    end

    -- Try to unhide widget layers
    local subTimes = 0
    while (not IsWidgetShown(Widget)) and subTimes < 6 do
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(Widget)
        subTimes = subTimes + 1
    end

    Widget:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    -- ugcprint("[UGCPlayerController] Restored widget: " .. tostring(widgetTag) .. ", subTimes=" .. tostring(subTimes))
end

-- Client: restore main UI after respawn
function UGCPlayerController:Client_RestoreMainUIAfterRespawn()
    -- ugcprint("[UGCPlayerController] Client_RestoreMainUIAfterRespawn called")
    if not self:IsLocalController() then return end

    if self.JiangeUI then
        if self.JiangeUI.ta_settlement then
            self.JiangeUI.ta_settlement:SetVisibility(ESlateVisibility.Collapsed)
        end
        self.JiangeUI:RemoveFromParent()
        self.JiangeUI = nil
        -- ugcprint("[UGCPlayerController] JiangeUI removed")
    end

    if not self.MMainUI then
        return
    end

    local function RestoreMainPanelsOnce()
        if not self.MMainUI then
            return
        end

        self.MMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)

        local MainControlBaseUI = self.MMainUI.MainControlBaseUI
        local ShootingUIPanel = self.MMainUI.ShootingUIPanel

        if (not MainControlBaseUI) or (not ShootingUIPanel) then
            local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
            if MainControlPanel then
                MainControlBaseUI = MainControlBaseUI or MainControlPanel.MainControlBaseUI
                ShootingUIPanel = ShootingUIPanel or MainControlPanel.ShootingUIPanel
            end
        end

        RestoreWidgetAfterRespawn(MainControlBaseUI, "MainControlBaseUI")
        RestoreWidgetAfterRespawn(ShootingUIPanel, "ShootingUIPanel")

        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        RestoreWidgetAfterRespawn(SkillPanel, "SkillRootPanel")
    end

    RestoreMainPanelsOnce()

    -- Retry restore after short delays to handle async UI loading
    UGCTimerUtility.CreateLuaTimer(0.12, function()
        if self and self.IsLocalController and self:IsLocalController() then
            RestoreMainPanelsOnce()
        end
    end, false, "RespawnRestoreUIRetry1_" .. tostring(self))

    UGCTimerUtility.CreateLuaTimer(0.35, function()
        if self and self.IsLocalController and self:IsLocalController() then
            RestoreMainPanelsOnce()
        end
    end, false, "RespawnRestoreUIRetry2_" .. tostring(self))

    if self.MMainUI.wujingjiange then
        self.MMainUI.wujingjiange:SetVisibility(ESlateVisibility.Collapsed)
    end
    -- ugcprint("[UGCPlayerController] MMainUI restored to visible")
end

-- ============ Treasure Box (Baoxiang) System ============

local GiftPackManagerModule = UGCGameSystem.UGCRequire("ExtendResource.GiftPack.OfficialPackage." .. "Script.GiftPack.GiftPackManager")

local function GetGiftPackManager()
    if _G and _G.GiftPackManager and type(_G.GiftPackManager) == "table" then
        return _G.GiftPackManager
    end
    -- ugcprint("[GetGiftPackManager] Error: global GiftPackManager not available, _G.GiftPackManager=" .. tostring(_G and _G.GiftPackManager))
    return nil
end

local function GrantBaoxiangDrops(PlayerController, BagOwner, DropItemList)
    if type(DropItemList) ~= "table" then
        return 0
    end

    local totalGranted = 0
    local PlayerPawn = PlayerController and (PlayerController.Pawn or PlayerController:K2_GetPawn())
    if (not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn)) and BagOwner and UGCObjectUtility.IsObjectValid(BagOwner) then
        PlayerPawn = BagOwner
    end

    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")

    for dropItemID, dropNum in pairs(DropItemList) do
        local awardNum = math.floor(tonumber(dropNum) or 0)
        if awardNum > 0 then
            local targetItemID = tonumber(dropItemID) or dropItemID
            local mapping = UGCGameData.GetItemMapping(targetItemID)
            if mapping and mapping["ClassicItemID"] and mapping["ClassicItemID"] > 0 then
                targetItemID = mapping["ClassicItemID"]
            end

            local grantedNum = 0
            if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
                local addedNum = UGCBackpackSystemV2.AddItemV2(PlayerPawn, targetItemID, awardNum)
                if addedNum == true then
                    grantedNum = awardNum
                elseif type(addedNum) == "number" and addedNum > 0 then
                    grantedNum = addedNum
                end
            end

            if grantedNum <= 0 and VirtualItemManager and PlayerController then
                local virtualAddOk = VirtualItemManager:AddVirtualItem(PlayerController, tonumber(dropItemID) or dropItemID, awardNum)
                if virtualAddOk then
                    grantedNum = awardNum
                end
            end

            if grantedNum > 0 then
                totalGranted = totalGranted + grantedNum
                -- ugcprint("[Server] Box reward granted: ItemID=" .. tostring(dropItemID) .. " -> TargetID=" .. tostring(targetItemID) .. " x" .. tostring(grantedNum))
            else
                -- ugcprint("[Server] Box reward failed: ItemID=" .. tostring(dropItemID) .. " x" .. tostring(awardNum))
            end
        end
    end

    return totalGranted
end

--- Client: show treasure box quantity chooser UI
---@param ItemID number Treasure box backpack item ID
---@param OwnedCount number Current owned count
---@param GiftPackID number Gift pack ID
function UGCPlayerController:Client_ShowBaoxiangNumchoose(ItemID, OwnedCount, GiftPackID)
    -- ugcprint("[Client] Client_ShowBaoxiangNumchoose ItemID=" .. tostring(ItemID) .. " OwnedCount=" .. tostring(OwnedCount) .. " GiftPackID=" .. tostring(GiftPackID))

    if not self:IsLocalController() then
        return
    end

    -- Try to get global NumChose instance
    local numChoseWidget = _G.G_NumChoseInstance
    -- ugcprint("[Client] G_NumChoseInstance = " .. tostring(numChoseWidget))

    -- If not found, create dynamically
    if not numChoseWidget then
        if not self.NumChoseUI then
            local NumChoseClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/NumChose.NumChose_C'))
            if NumChoseClass then
                local widget = UserWidget.NewWidgetObjectBP(self, NumChoseClass)
                if widget then
                    widget:AddToViewport(9999)
                    self.NumChoseUI = widget
                    -- ugcprint("[Client] NumChose_C created dynamically")
                end
            end
        end
        numChoseWidget = self.NumChoseUI
    end

    if not numChoseWidget then
        -- ugcprint("[Client] Error: NumChose not available")
        return
    end

    local capturedGiftPackID = GiftPackID
    local capturedItemID = ItemID
    numChoseWidget:Show(OwnedCount, function(selectCount)
        -- ugcprint("[Client] Player selected box count: " .. tostring(selectCount) .. " ItemID=" .. tostring(capturedItemID) .. " GiftPackID=" .. tostring(capturedGiftPackID))
        local pc = UGCGameSystem.GetLocalPlayerController()
        if not pc then
            -- ugcprint("[Client] Error: unable to get PlayerController")
            return
        end
        -- Call server RPC to batch open
        local rpcOk, rpcErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(pc, pc, "Server_BatchOpenBaoxiang", capturedItemID, selectCount, capturedGiftPackID)
        end)
        if rpcOk then
            -- ugcprint("[Client] Server_BatchOpenBaoxiang RPC sent successfully")
        else
            -- ugcprint("[Client] Server_BatchOpenBaoxiang RPC failed: " .. tostring(rpcErr))
        end
    end, capturedItemID)
end

--- Server: batch open treasure boxes
---@param UseCount number Number to open
---@param InGiftPackID number|nil Gift pack ID (optional, looks up BAOXIANG_MAP if nil)
function UGCPlayerController:Server_BatchOpenBaoxiang(ItemID, UseCount, InGiftPackID)
    -- ugcprint("[Server] ====== Server_BatchOpenBaoxiang enter ======")
    -- ugcprint("[Server] ItemID=" .. tostring(ItemID) .. " type=" .. type(ItemID))
    -- ugcprint("[Server] UseCount=" .. tostring(UseCount) .. " type=" .. type(UseCount))
    -- ugcprint("[Server] InGiftPackID=" .. tostring(InGiftPackID) .. " type=" .. type(InGiftPackID))

    if not self:HasAuthority() then
        -- ugcprint("[Server] Error: no authority, exit")
        return
    end
    -- ugcprint("[Server] Authority check passed")

    local GiftPackManager = GetGiftPackManager()
    -- ugcprint("[Server] GiftPackManager=" .. tostring(GiftPackManager))
    if not GiftPackManager then
        -- ugcprint("[Server] Error: GiftPackManager not loaded, exit")
        return
    end

    UseCount = math.floor(tonumber(UseCount) or 0)
    -- ugcprint("[Server] Converted UseCount=" .. tostring(UseCount))
    if UseCount <= 0 then
        -- ugcprint("[Server] Error: UseCount<=0, exit")
        return
    end

    -- Map backpack ItemID to GiftPackID
    local BAOXIANG_MAP = {
        [8310167] = 321,  -- bx_1 / YS series
        [8310173] = 322,  -- bx_2
        [8310174] = 323,  -- bx_3
        [8310175] = 324,  -- bx_4
        [8310176] = 325,  -- bx_5
        [8310177] = 326,  -- bx_6
        [8310178] = 327,  -- bx_7
        [8310179] = 301,  -- day_1
        [8310180] = 302,  -- day_2
        [8310181] = 303,  -- day_3
        [8310182] = 310,  -- month_1
        [8310183] = 311,  -- month_2
        [8310184] = 312,  -- month_3
        [8310185] = 313,  -- month_4
        [8310186] = 314,  -- month_5
        [8310187] = 315,  -- month_6
        [8310188] = 316,  -- month_7
        [8310189] = 304,  -- week_1
        [8310190] = 305,  -- week_2
        [8310191] = 306,  -- week_3
        [8310192] = 307,  -- week_4
        [8310193] = 308,  -- week_5
        [8310194] = 309,  -- week_6
    }

    local GiftPackID = nil
    if InGiftPackID and type(InGiftPackID) == "number" and InGiftPackID > 0 then
        GiftPackID = InGiftPackID
        -- ugcprint("[Server] Using passed-in GiftPackID: " .. tostring(GiftPackID))
    else
        GiftPackID = BAOXIANG_MAP[ItemID]
        -- ugcprint("[Server] Looked up GiftPackID from BAOXIANG_MAP: " .. tostring(GiftPackID) .. " (ItemID=" .. tostring(ItemID) .. ")")
    end
    if not GiftPackID then
        -- ugcprint("[Server] Error: GiftPackID is nil, ItemID=" .. tostring(ItemID) .. " InGiftPackID=" .. tostring(InGiftPackID) .. ", exit")
        return
    end
    -- ugcprint("[Server] Final GiftPackID=" .. tostring(GiftPackID))

    -- ugcprint("[Server] GetGiftPackDataByID=" .. tostring(GiftPackManager.GetGiftPackDataByID))
    -- ugcprint("[Server] GetAllGiftPackDropList=" .. tostring(GiftPackManager.GetAllGiftPackDropList))
    if not GiftPackManager.GetGiftPackDataByID or not GiftPackManager.GetAllGiftPackDropList then
        -- ugcprint("[Server] Error: GiftPackManager interface incomplete, exit")
        return
    end

    local okGiftPackData, giftPackData = pcall(function()
        return GiftPackManager:GetGiftPackDataByID(GiftPackID)
    end)
    -- ugcprint("[Server] GetGiftPackDataByID pcall result: ok=" .. tostring(okGiftPackData) .. " data=" .. tostring(giftPackData))
    if (not okGiftPackData) or (not giftPackData) then
        -- ugcprint("[Server] Error: gift pack config missing or read failed, GiftPackID=" .. tostring(GiftPackID) .. " err=" .. tostring(giftPackData) .. ", exit")
        return
    end

    -- Get player Pawn
    local PlayerPawn = self.Pawn
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        PlayerPawn = self:K2_GetPawn()
    end

    -- Get VirtualItemManager
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    -- ugcprint("[Server] VirtualItemManager=" .. tostring(VirtualItemManager))

    -- Get virtual item ID from gift pack config
    local virtualItemID = giftPackData.ItemID
    -- ugcprint("[Server] Gift pack config virtual ItemID=" .. tostring(virtualItemID) .. " classic ItemID=" .. tostring(ItemID))

    -- Check both backpack and virtual item counts
    local bagCount = 0
    local virtualCount = 0
    
    -- Check backpack count
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        bagCount = UGCBackpackSystemV2.GetItemCountV2(PlayerPawn, ItemID) or 0
    end
    if bagCount <= 0 then
        bagCount = UGCBackpackSystemV2.GetItemCountV2(self, ItemID) or 0
    end
    
    -- Check virtual item count
    if VirtualItemManager and virtualItemID then
        local okVCount, vCount = pcall(function()
            return VirtualItemManager:GetItemNum(virtualItemID, self) or 0
        end)
        if okVCount and type(vCount) == "number" then
            virtualCount = vCount
        end
    end
    
    -- ugcprint("[Server] Backpack count=" .. tostring(bagCount) .. " Virtual item count=" .. tostring(virtualCount))

    -- Determine which source to use
    local useVirtual = false
    local ownedCount = math.max(bagCount, virtualCount)
    if ownedCount <= 0 then
        -- ugcprint("[Server] Neither backpack nor virtual has this item, exit")
        return
    end

    if ownedCount < UseCount then
        -- ugcprint("[Server] Count insufficient, adjust UseCount: " .. tostring(UseCount) .. " -> " .. tostring(ownedCount))
        UseCount = ownedCount
    end
    if UseCount <= 0 then
        -- ugcprint("[Server] Adjusted UseCount<=0, exit")
        return
    end

    -- Try to remove items
    local removedOk = false
    local bagOwner = PlayerPawn  -- Default Pawn for reward delivery

    -- Try backpack removal first
    if bagCount > 0 then
        -- ugcprint("[Server] Starting backpack deduction: ItemID=" .. tostring(ItemID) .. " UseCount=" .. tostring(UseCount))
        
        -- Try removing from Pawn
        local removedCount = 0
        if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
            removedCount = UGCBackpackSystemV2.RemoveItemV2(PlayerPawn, ItemID, UseCount)
            -- ugcprint("[Server] Pawn RemoveItemV2 result: " .. tostring(removedCount))
        end
        
        -- Try removing from self (controller)
        if not removedCount or removedCount == 0 or removedCount == false then
            removedCount = UGCBackpackSystemV2.RemoveItemV2(self, ItemID, UseCount)
            -- ugcprint("[Server] Self RemoveItemV2 result: " .. tostring(removedCount))
            if removedCount and removedCount ~= 0 and removedCount ~= false then
                bagOwner = self
            end
        end
        
        if removedCount == true then removedCount = UseCount end
        if type(removedCount) == "number" and removedCount > 0 then
            removedOk = true
        end
        -- ugcprint("[Server] Backpack deduction result: " .. tostring(removedOk) .. " removedCount=" .. tostring(removedCount))
    end

    -- If backpack removal failed, try official GiftPackComponent flow
    if not removedOk and virtualCount > 0 and virtualItemID then
        -- ugcprint("[Server] Backpack deduction failed, switching to official GiftPackComponent flow: GiftPackID=" .. tostring(GiftPackID) .. " UseCount=" .. tostring(UseCount))
        
        -- Adjust count for virtual items
        if virtualCount < UseCount then
            -- ugcprint("[Server] Virtual count insufficient, adjust UseCount: " .. tostring(UseCount) .. " -> " .. tostring(virtualCount))
            UseCount = virtualCount
        end
        
        -- Get GiftPackComponent
        local GPC = nil
        local okGPC, gpcErr = pcall(function()
            GPC = GiftPackManager:GetGiftPackComponent(self)
        end)
        -- ugcprint("[Server] GetGiftPackComponent: ok=" .. tostring(okGPC) .. " GPC=" .. tostring(GPC) .. " err=" .. tostring(gpcErr))
        
        if GPC then
            -- Debug: print current item count
            local okNum, gpcNum = pcall(function()
                return GPC:GetItemNum(virtualItemID)
            end)
            -- ugcprint("[Server] GPC:GetItemNum(" .. tostring(virtualItemID) .. ") = " .. tostring(gpcNum) .. " ok=" .. tostring(okNum))
            
            -- Debug: get VirtualItemManager from GPC
            local okVIM, vim = pcall(function()
                return GPC:GetVirtualItemManager()
            end)
            -- ugcprint("[Server] GPC:GetVirtualItemManager() = " .. tostring(vim) .. " ok=" .. tostring(okVIM) .. " IsValid=" .. tostring(okVIM and vim and UE.IsValid(vim)))
            
            -- Debug: get item data
            if okVIM and vim and UE.IsValid(vim) then
                local okData, itemData = pcall(function()
                    return vim:GetItemData(virtualItemID)
                end)
                -- ugcprint("[Server] GetItemData(" .. tostring(virtualItemID) .. ") ok=" .. tostring(okData) .. " data=" .. tostring(itemData))
                if okData and itemData then
                    for k, v in pairs(itemData) do
                        -- ugcprint("[Server] ItemData[" .. tostring(k) .. "] = " .. tostring(v))
                    end
                end
            end
        end
        
        -- Use official gift pack open flow
        local okUse, useErr = pcall(function()
            GiftPackManager:OpenNormalGiftPackage(GiftPackID, UseCount, self)
        end)
        -- ugcprint("[Server] OpenNormalGiftPackage pcall result: ok=" .. tostring(okUse) .. " err=" .. tostring(useErr))
        
        -- Debug: check item count after open
        if GPC then
            local okNum2, gpcNum2 = pcall(function()
                return GPC:GetItemNum(virtualItemID)
            end)
            -- ugcprint("[Server] After call GPC:GetItemNum(" .. tostring(virtualItemID) .. ") = " .. tostring(gpcNum2) .. " ok=" .. tostring(okNum2))
        end
        
        -- ugcprint("[Server] ====== Server_BatchOpenBaoxiang end (official flow) ======")
        return
    end

    -- Backpack removal succeeded, generate drops manually
    if removedOk then
        -- ugcprint("[Server] Deduction success, generating drops: GiftPackID=" .. tostring(GiftPackID) .. " UseCount=" .. tostring(UseCount))
        local okDropList, dropItemList = pcall(function()
            return GiftPackManager:GetAllGiftPackDropList(GiftPackID, UseCount)
        end)
        -- ugcprint("[Server] GetAllGiftPackDropList pcall result: ok=" .. tostring(okDropList) .. " type=" .. type(dropItemList))

        if not okDropList or type(dropItemList) ~= "table" then
            -- ugcprint("[Server] Error: drop generation failed, err=" .. tostring(dropItemList) .. ", rollback")
            if useVirtual then
                pcall(function() VirtualItemManager:AddVirtualItem(self, virtualItemID, UseCount) end)
            else
                UGCBackpackSystemV2.AddItemV2(bagOwner, ItemID, UseCount)
            end
            return
        end

        -- Debug: print drop items
        local dropCount = 0
        for k, v in pairs(dropItemList) do
            dropCount = dropCount + 1
            -- ugcprint("[Server] Drop item: ID=" .. tostring(k) .. " count=" .. tostring(v))
        end
        -- ugcprint("[Server] Drop item types: " .. tostring(dropCount))

        local grantedTotal = GrantBaoxiangDrops(self, bagOwner, dropItemList)
        -- ugcprint("[Server] GrantBaoxiangDrops result: " .. tostring(grantedTotal))
        if grantedTotal <= 0 then
            -- ugcprint("[Server] Error: no rewards granted, rollback")
            if useVirtual then
                pcall(function() VirtualItemManager:AddVirtualItem(self, virtualItemID, UseCount) end)
            else
                UGCBackpackSystemV2.AddItemV2(bagOwner, ItemID, UseCount)
            end
            return
        end

        -- ugcprint("[Server] ====== Batch open success: GiftPackID=" .. tostring(GiftPackID) .. " x" .. tostring(UseCount) .. " items=" .. tostring(grantedTotal) .. " ======")
        
        -- Notify client to show reward UI
        local awardList = {}
        for itemId, itemNum in pairs(dropItemList) do
            table.insert(awardList, {ItemID = itemId, ItemNum = itemNum})
        end
        UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowBaoxiangReward", awardList)
    else
        -- ugcprint("[Server] Error: all deduction methods failed")
    end
    -- ugcprint("[Server] ====== Server_BatchOpenBaoxiang end ======")
end

--- Client: show treasure box reward display
function UGCPlayerController:Client_ShowBaoxiangReward(awardList)
    -- ugcprint("[Client] Client_ShowBaoxiangReward called")
    if not self:IsLocalController() then
        return
    end
    
    if not awardList or #awardList == 0 then
        -- ugcprint("[Client] No rewards to display")
        return
    end
    
    -- Try to show reward in existing UI
    if self.MMainUI and self.MMainUI.ShowBaoxiangReward then
        self.MMainUI:ShowBaoxiangReward(awardList)
    else
        -- ugcprint("[Client] MMainUI.ShowBaoxiangReward not available")
    end
end

return UGCPlayerController