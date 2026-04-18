---@class UGCPlayerController_C:BP_UGCPlayerController_C
---@field LotteryComponent LotteryComponent_C
---@field TaskTemplateComponent TaskTemplateComponent_C
---@field SignInEventComponent SignInEventComponent_C
---@field GiftPackComponent GiftPackComponent_C
---@field RankingListComponent RankingListComponent_C
---@field ShopV2Component ShopV2Component_C
--Edit Below--
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local UGCPlayerController = {}
local TEAM_ABSORB_EXP_SHARE_RATE = 0.1

local function IsObjectValidSafe(obj)
    if not obj then
        return false
    end

    if UGCObjectUtility and UGCObjectUtility.IsObjectValid then
        local okValid, validOrErr = pcall(function()
            return UGCObjectUtility.IsObjectValid(obj)
        end)

        if okValid then
            return validOrErr == true
        end

        ugcprint("[UGCPlayerController] IsObjectValid 调用异常: " .. tostring(validOrErr))
        return false
    end

    return true
end

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

local function ResolveSingleModeTimeOutActor(worldContextObject)
    local timeoutClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/SingleModeTimeOut.SingleModeTimeOut_C")
    if not timeoutClassPath or timeoutClassPath == "" then
        ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 失败：SingleModeTimeOut 类路径为空")
        return nil, nil
    end

    local classPathCandidates = { timeoutClassPath }

    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 失败：WorldContextObject 为空")
        return nil, nil
    end

    if not UGCActorComponentUtility or not UGCActorComponentUtility.GetAllActorsOfClass then
        ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 失败：UGCActorComponentUtility.GetAllActorsOfClass 不可用")
        return nil, nil
    end

    for _, classPath in ipairs(classPathCandidates) do
        local okLoadClass, actorClassOrErr = pcall(function()
            return UGCObjectUtility.LoadClass(classPath)
        end)

        if not okLoadClass then
            ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 加载类失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorClassOrErr))
            goto continue_classpath
        end

        local actorClass = actorClassOrErr
        if not actorClass then
            ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 加载类为空, classPath=" .. tostring(classPath))
            goto continue_classpath
        end

        local okGetActor, actorListOrErr = pcall(function()
            return UGCActorComponentUtility.GetAllActorsOfClass(worldContext, actorClass)
        end)

        if not okGetActor then
            ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 获取Actor失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
            goto continue_classpath
        end

        local actorList = actorListOrErr
        if actorList and #actorList > 0 then
            for _, actor in pairs(actorList) do
                if IsObjectValidSafe(actor) then
                    return actor, classPath
                end
            end
        end

        ::continue_classpath::
    end

    return nil, nil
end

local function StopAndCleanSingle1TriggerBoxesForServer(worldContextObject, reasonTag)
    local cleanedByGlobal = 0
    if _G and _G.StopAndCleanAllSingle1TriggerBoxes then
        local okGlobalStop, globalStopOrErr = pcall(function()
            return _G.StopAndCleanAllSingle1TriggerBoxes(reasonTag)
        end)

        if okGlobalStop then
            cleanedByGlobal = tonumber(globalStopOrErr) or 0
        else
            ugcprint("[UGCPlayerController] Global StopAndCleanSingle1 调用失败: " .. tostring(globalStopOrErr))
        end
    end

    if cleanedByGlobal > 0 then
        return cleanedByGlobal
    end

    local triggerClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/TriggerBox_Single1.TriggerBox_Single1_C")
    if not triggerClassPath or triggerClassPath == "" then
        ugcprint("[UGCPlayerController] StopAndCleanSingle1 失败：TriggerBox_Single1 类路径为空")
        return 0
    end

    local classPathCandidates = { triggerClassPath }

    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[UGCPlayerController] StopAndCleanSingle1 失败：WorldContextObject 为空")
        return 0
    end

    if (not UGCActorComponentUtility) or (not UGCActorComponentUtility.GetAllActorsOfClass) then
        ugcprint("[UGCPlayerController] StopAndCleanSingle1 失败：GetAllActorsOfClass 不可用")
        return 0
    end

    local cleanedCount = 0
    for _, classPath in ipairs(classPathCandidates) do
        local triggerClass = UGCObjectUtility.LoadClass(classPath)
        if triggerClass then
            local okGetActors, actorListOrErr = pcall(function()
                return UGCActorComponentUtility.GetAllActorsOfClass(worldContext, triggerClass)
            end)

            if okGetActors then
                local actorList = actorListOrErr
                if actorList and #actorList > 0 then
                    for _, triggerActor in pairs(actorList) do
                        if triggerActor and UGCObjectUtility.IsObjectValid(triggerActor) and triggerActor.StopAndCleanAll then
                            local okStop, stopErr = pcall(function()
                                triggerActor:StopAndCleanAll()
                            end)

                            if okStop then
                                cleanedCount = cleanedCount + 1
                            else
                                ugcprint("[UGCPlayerController] StopAndCleanAll 调用失败: " .. tostring(stopErr))
                            end
                        end
                    end
                end
            else
                ugcprint("[UGCPlayerController] 查询 TriggerBox_Single1 失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
            end
        end
    end

    if cleanedCount > 0 then
        ugcprint("[UGCPlayerController] 已停止并清怪 TriggerBox_Single1 数量=" .. tostring(cleanedCount) .. ", reason=" .. tostring(reasonTag))
    else
        ugcprint("[UGCPlayerController] 未找到可处理的 TriggerBox_Single1, reason=" .. tostring(reasonTag))
    end

    return cleanedCount
end

local JiangeInstancePlayerMap = JiangeInstancePlayerMap or {}
local JiangeInstanceNextIndex = JiangeInstanceNextIndex or 1
local JIANGE_ENTRY_Z_OFFSET = 120
local JIANGE_FALLBACK_ENTRY = {
    X = 268737.21875,
    Y = 238584.484375,
    Z = 1118.539795,
}

local function ResolveJiangeTriggerBoxes(worldContextObject)
    local classPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/Data/MobPoint/TriggerBox_jiange.TriggerBox_jiange_C")
    if not classPath or classPath == "" then
        return {}
    end

    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        return {}
    end

    if not UGCActorComponentUtility or not UGCActorComponentUtility.GetAllActorsOfClass then
        return {}
    end

    local triggerClass = UGCObjectUtility.LoadClass(classPath)
    if not triggerClass then
        return {}
    end

    local okGetActors, actorListOrErr = pcall(function()
        return UGCActorComponentUtility.GetAllActorsOfClass(worldContext, triggerClass)
    end)
    if not okGetActors then
        ugcprint("[UGCPlayerController] ResolveJiangeTriggerBoxes failed: " .. tostring(actorListOrErr))
        return {}
    end

    local actorList = actorListOrErr
    local validBoxes = {}
    if actorList and #actorList > 0 then
        for _, actor in pairs(actorList) do
            if IsObjectValidSafe(actor) then
                table.insert(validBoxes, actor)
            end
        end
    end

    table.sort(validBoxes, function(a, b)
        local aName = ""
        local bName = ""
        pcall(function()
            aName = tostring(a:GetName())
        end)
        pcall(function()
            bName = tostring(b:GetName())
        end)
        return aName < bName
    end)

    return validBoxes
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
    return "Server_TeleportPlayer", "Server_EnterJiangeInstance", "Server_RestoreFullHealth", "Server_DestroyNearbyCorpses", "Server_SetDirectExpEnabled", "Server_SetAutoTunshiEnabled", "Server_SetAutoPickupEnabled", "Server_SetBloodlineEnabled", "Server_NotifyLevelRewardFinish", "Server_NotifyTimeOutFinish", "Server_GiveRewards", "Server_SendTeamInvite", "Server_RespondTeamInvite", "Server_RequestJoinTeam", "Server_AcceptJoinRequest", "Server_KickFromTeam", "Server_LeaveTeam", "Server_ResumeTriggerBoxSpawning", "Server_BatchOpenBaoxiang", "Server_RequestTeamPanelPlayers"
end

-- Available client RPCs
function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_ShowTunshiSuccess", "Client_SetPlayerRotation", "Client_ShowSettlementUI", "Client_ShowSettlementTipUI", "Client_ShowSettlement2UI", "Client_OnPlayerLevelUp", "Client_ReceiveTeamInvite", "Client_TeamInviteResult", "Client_ReceiveJoinRequest", "Client_RefreshTeamUI", "Client_OnKickedFromTeam", "Client_ShowTaSettlementUI", "Client_UpdateJiangeFloor", "Client_OnP1Died", "Client_StartCountdown", "Client_SyncJiangeData", "Client_SyncShenyinData", "Client_ShowBaoxiangNumchoose", "Client_BeginTeamPanelPlayers", "Client_AddTeamPanelPlayer", "Client_EndTeamPanelPlayers", "Client_ShowBaoxiangReward", "Client_SyncJiangeRewardData", "Client_OnJiangeDailyClaimResult", "Client_OnJiangeFloorClaimResult", "Client_OnJiangeForgeConsumeResult", "Client_OnChongzhiClaimResult", "Client_OnTalentUpgradeResult", "Client_OnManualPointResult", "Client_RestoreMainUIAfterRespawn", "Client_OnExpBlockedByRebirth", "Client_SyncMobKillCount", "Client_SyncPlayerKillCount"
end

-- Client: show absorb success notification
function UGCPlayerController:Client_ShowTunshiSuccess(totalExp)
    --ugcprint("[Client] Client_ShowTunshiSuccess received, exp value: " .. tostring(totalExp))
    
    if not self:IsLocalController() then
        return
    end
    
    if self.MMainUI and self.MMainUI.tunshitip then
        if self.MMainUI.tunshitip.ShowTips then
            self.MMainUI.tunshitip:ShowTips("吞噬成功 +" .. tostring(totalExp))
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

-- Server: enter Jiange with multi-instance distribution
function UGCPlayerController:Server_EnterJiangeInstance()
    local ok, err = pcall(function()
        local playerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
        local playerInstanceKey = nil
        if playerKey and tonumber(playerKey) and tonumber(playerKey) > 0 then
            playerInstanceKey = "P_" .. tostring(playerKey)
        else
            playerInstanceKey = "PC_" .. tostring(self)
        end

        local triggerBoxes = ResolveJiangeTriggerBoxes(self)
        if not triggerBoxes or #triggerBoxes == 0 then
            ugcprint("[UGCPlayerController] Server_EnterJiangeInstance fallback: no TriggerBox_jiange found")
            self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
            return
        end

        local instanceIndex = JiangeInstancePlayerMap[playerInstanceKey]
        if not instanceIndex or instanceIndex < 1 or instanceIndex > #triggerBoxes then
            instanceIndex = JiangeInstanceNextIndex
            JiangeInstancePlayerMap[playerInstanceKey] = instanceIndex
            JiangeInstanceNextIndex = JiangeInstanceNextIndex + 1
            if JiangeInstanceNextIndex > #triggerBoxes then
                JiangeInstanceNextIndex = 1
            end
            ugcprint("[UGCPlayerController] Jiange instance assigned: player=" .. tostring(playerInstanceKey) .. ", index=" .. tostring(instanceIndex))
        end

        local targetTrigger = triggerBoxes[instanceIndex]
        if not targetTrigger or not IsObjectValidSafe(targetTrigger) then
            ugcprint("[UGCPlayerController] Server_EnterJiangeInstance fallback: target trigger invalid")
            self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
            return
        end

        local targetLocation = targetTrigger:K2_GetActorLocation()
        if not targetLocation then
            ugcprint("[UGCPlayerController] Server_EnterJiangeInstance fallback: target location invalid")
            self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
            return
        end

        self:Server_TeleportPlayer(targetLocation.X, targetLocation.Y, targetLocation.Z + JIANGE_ENTRY_Z_OFFSET)
    end)

    if not ok then
        ugcprint("[UGCPlayerController] Server_EnterJiangeInstance error: " .. tostring(err))
        self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
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
    ugcprint("[UGCPlayerController] Client_ShowSettlementUI 被调用")

    local bIsLocalController = false
    local okIsLocal, isLocalResult = pcall(function()
        return self:IsLocalController()
    end)
    if okIsLocal then
        bIsLocalController = (isLocalResult == true)
    end
    ugcprint("[UGCPlayerController] Client_ShowSettlementUI IsLocalController=" .. tostring(bIsLocalController) .. ", ok=" .. tostring(okIsLocal))
    if not bIsLocalController then
        ugcprint("[UGCPlayerController] 警告：IsLocalController=false，仍继续执行结算兜底流程")
    end

    local okStopCountdown, stopCountdownErr = pcall(function()
        if self.MMainUI and self.MMainUI.StopCountdown then
            self.MMainUI.CountdownTimeoutTriggered = true
            self.MMainUI:StopCountdown()
        end
    end)
    if not okStopCountdown then
        ugcprint("[UGCPlayerController] StopCountdown 执行失败: " .. tostring(stopCountdownErr))
    end

    local settlementPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement.Settlement_C')
    ugcprint("[UGCPlayerController] Settlement UI 路径: " .. tostring(settlementPath))

    local PlayerController = self
    local bHandled = false

    local function HandleSettlementFinish(reason, needGiveRewards)
        if bHandled then
            ugcprint("[UGCPlayerController] Settlement 已处理，忽略重复触发, reason=" .. tostring(reason))
            return
        end

        bHandled = true
        ugcprint("[UGCPlayerController] Settlement 触发完成流程, reason=" .. tostring(reason) .. ", needGiveRewards=" .. tostring(needGiveRewards))

        if needGiveRewards then
            local okGiveReward, giveRewardErr = pcall(function()
                UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_GiveRewards")
            end)

            if okGiveReward then
                ugcprint("[UGCPlayerController] 已调用 Server_GiveRewards")
            else
                ugcprint("[UGCPlayerController] 调用 Server_GiveRewards 失败: " .. tostring(giveRewardErr))
            end
        end

        local okNotifyFinish, notifyFinishErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyLevelRewardFinish")
        end)

        if okNotifyFinish then
            ugcprint("[UGCPlayerController] 已调用 Server_NotifyLevelRewardFinish")
        else
            ugcprint("[UGCPlayerController] 调用 Server_NotifyLevelRewardFinish 失败: " .. tostring(notifyFinishErr))
        end
    end

    -- Global watchdog: continue level flow even if async callback never returns.
    UGCTimerUtility.CreateLuaTimer(
        10.0,
        function()
            if bHandled then
                return
            end

            ugcprint("[UGCPlayerController] Settlement 全局看门狗触发，执行自动兜底")
            HandleSettlementFinish("GlobalWatchdog", true)
        end,
        false,
        "SettlementGlobalWatchdog"
    )

    local okCreateWidgetAsync, createWidgetAsyncErr = pcall(function()
        UGCWidgetManagerSystem.CreateWidgetAsync(settlementPath, function(Widget)
            ugcprint("[UGCPlayerController] Settlement CreateWidgetAsync 回调触发")

            if Widget then
                ugcprint("[UGCPlayerController] Settlement UI 创建成功")

                Widget.OnSureClicked = function()
                    -- Settlement widget sure click already calls Server_GiveRewards.
                    HandleSettlementFinish("SureClicked", false)
                end

                Widget:AddToViewport(6000)
                ugcprint("[UGCPlayerController] Settlement UI 已添加到视口")

                UGCTimerUtility.CreateLuaTimer(
                    8.0,
                    function()
                        if bHandled then
                            return
                        end

                        ugcprint("[UGCPlayerController] Settlement 8秒未完成，执行自动兜底")
                        if Widget and UGCObjectUtility.IsObjectValid(Widget) then
                            Widget:RemoveFromParent()
                        end

                        HandleSettlementFinish("AutoFallback", true)
                    end,
                    false,
                    "SettlementAutoFallbackTimer"
                )
            else
                ugcprint("[UGCPlayerController] 创建 Settlement UI 失败，直接执行兜底流程")
                HandleSettlementFinish("CreateWidgetFailed", true)
            end
        end)
    end)
    if not okCreateWidgetAsync then
        ugcprint("[UGCPlayerController] 调用 CreateWidgetAsync 失败: " .. tostring(createWidgetAsyncErr))
        HandleSettlementFinish("CreateWidgetAsyncError", true)
    end
end

--- Client: show SettlementTip UI and start matching
function UGCPlayerController:Client_ShowSettlementTipUI()
    ugcprint("[UGCPlayerController] Client_ShowSettlementTipUI 被调用")

    local bIsLocalController = false
    local okIsLocal, isLocalResult = pcall(function()
        return self:IsLocalController()
    end)
    if okIsLocal then
        bIsLocalController = (isLocalResult == true)
    end
    ugcprint("[UGCPlayerController] Client_ShowSettlementTipUI IsLocalController=" .. tostring(bIsLocalController) .. ", ok=" .. tostring(okIsLocal))
    if not bIsLocalController then
        ugcprint("[UGCPlayerController] 警告：SettlementTip IsLocalController=false，仍继续执行匹配")
    end

    local okStopCountdown, stopCountdownErr = pcall(function()
        if self.MMainUI and self.MMainUI.StopCountdown then
            self.MMainUI.CountdownTimeoutTriggered = true
            self.MMainUI:StopCountdown()
        end
    end)
    if not okStopCountdown then
        ugcprint("[UGCPlayerController] SettlementTip StopCountdown 执行失败: " .. tostring(stopCountdownErr))
    end

    local settlementTipPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/SettlementTip.SettlementTip_C')
    ugcprint("[UGCPlayerController] SettlementTip UI 路径: " .. tostring(settlementTipPath))
    
    -- 保存 PlayerController 引用，供回调函数使用
    local PlayerController = self
    
    -- 异步创建 SettlementTip UI（仅负责展示，不阻塞匹配）
    UGCWidgetManagerSystem.CreateWidgetAsync(settlementTipPath, function(Widget)
        ugcprint("[UGCPlayerController] SettlementTip CreateWidgetAsync 回调被调用")

        if Widget then
            ugcprint("[UGCPlayerController] 成功创建 SettlementTip UI")
            Widget:AddToViewport(6000)
            ugcprint("[UGCPlayerController] SettlementTip UI 已添加到视口，将一直显示")
        else
            ugcprint("[UGCPlayerController] 创建 SettlementTip UI 失败，Widget为nil")
        end

        if UGCMultiMode then
            UGCMultiMode.NotifyMatchSucceededDelegate:Add(function()
                ugcprint("[UGCPlayerController] 匹配成功！隐藏 SettlementTip UI")
                if Widget and UGCObjectUtility.IsObjectValid(Widget) then
                    Widget:RemoveFromParent()
                end
            end, PlayerController)

            local hasRetried = false
            local function DoRequestMatch(tag)
                ugcprint("[UGCPlayerController] RequestMatch(1001) 开始调用, tag=" .. tostring(tag))
                local bRequestSuccess = UGCMultiMode.RequestMatch(1001, function(arg1, arg2)
                    local bSuccess = false
                    if type(arg1) == "boolean" then
                        bSuccess = arg1
                    elseif type(arg2) == "boolean" then
                        bSuccess = arg2
                    end

                    ugcprint("[UGCPlayerController] RequestMatch(1001) 回调, tag=" .. tostring(tag) .. ", arg1=" .. tostring(arg1) .. ", arg2=" .. tostring(arg2) .. ", parsedSuccess=" .. tostring(bSuccess))
                    if (not bSuccess) and (not hasRetried) then
                        hasRetried = true
                        ugcprint("[UGCPlayerController] RequestMatch 回调失败，1.5秒后重试一次")
                        UGCTimerUtility.CreateLuaTimer(1.5, function()
                            DoRequestMatch("RetryByCallback")
                        end, false, "SettlementTipMatchRetry")
                    end
                end, PlayerController)

                ugcprint("[UGCPlayerController] RequestMatch(1001) 返回值, tag=" .. tostring(tag) .. ": " .. tostring(bRequestSuccess))

                if (not bRequestSuccess) and (not hasRetried) then
                    hasRetried = true
                    ugcprint("[UGCPlayerController] RequestMatch 返回 false，1.5秒后重试一次")
                    UGCTimerUtility.CreateLuaTimer(1.5, function()
                        DoRequestMatch("RetryByReturn")
                    end, false, "SettlementTipMatchRetry")
                end
            end

            DoRequestMatch("First")
        else
            ugcprint("[UGCPlayerController] 错误：UGCMultiMode 不存在")
        end
    end)
end

--- Client: show Settlement_2 UI (timeout settlement)
function UGCPlayerController:Client_ShowSettlement2UI()
    ugcprint("[UGCPlayerController] Client_ShowSettlement2UI 被调用")

    local bIsLocalController = false
    local okIsLocal, isLocalResult = pcall(function()
        return self:IsLocalController()
    end)
    if okIsLocal then
        bIsLocalController = (isLocalResult == true)
    end
    ugcprint("[UGCPlayerController] Client_ShowSettlement2UI IsLocalController=" .. tostring(bIsLocalController) .. ", ok=" .. tostring(okIsLocal))
    if not bIsLocalController then
        ugcprint("[UGCPlayerController] 警告：Settlement_2 IsLocalController=false，继续执行超时关卡流程兜底")
    end

    local okStopCountdown, stopCountdownErr = pcall(function()
        if self.MMainUI and self.MMainUI.StopCountdown then
            self.MMainUI.CountdownTimeoutTriggered = true
            self.MMainUI:StopCountdown()
        end
    end)
    if not okStopCountdown then
        ugcprint("[UGCPlayerController] Settlement_2 StopCountdown 执行失败: " .. tostring(stopCountdownErr))
    end
    
    local settlement2Path = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement_2.Settlement_2_C')
    ugcprint("[UGCPlayerController] Settlement_2 UI 路径: " .. tostring(settlement2Path))
    
    -- 保存 PlayerController 引用，供回调函数使用
    local PlayerController = self
    local bNotified = false

    local function NotifyTimeOutFinish(reason)
        if bNotified then
            ugcprint("[UGCPlayerController] Settlement_2 已通知，忽略重复触发, reason=" .. tostring(reason))
            return
        end

        bNotified = true
        ugcprint("[UGCPlayerController] Settlement_2 执行超时完成通知, reason=" .. tostring(reason))

        local okRPC, rpcErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyTimeOutFinish")
        end)
        if okRPC then
            ugcprint("[UGCPlayerController] 已调用 Server_NotifyTimeOutFinish")
        else
            ugcprint("[UGCPlayerController] 调用 Server_NotifyTimeOutFinish 失败: " .. tostring(rpcErr))
        end
    end

    -- Global watchdog: if timeout UI callback is lost, still continue level flow.
    UGCTimerUtility.CreateLuaTimer(8.0, function()
        if bNotified then
            return
        end
        ugcprint("[UGCPlayerController] Settlement_2 全局看门狗触发")
        NotifyTimeOutFinish("GlobalWatchdog")
    end, false, "Settlement2GlobalWatchdog")
    
    local okCreateWidgetAsync, createWidgetAsyncErr = pcall(function()
        -- 异步创建 Settlement_2 UI
        UGCWidgetManagerSystem.CreateWidgetAsync(settlement2Path, function(Widget)
            if Widget then
                ugcprint("[UGCPlayerController] 成功创建 Settlement_2 UI, widget=" .. tostring(Widget))

                -- 设置回调函数，UI显示后立即执行
                Widget.OnSureClicked = function()
                    ugcprint("[UGCPlayerController] Settlement_2 触发后续流程, widget=" .. tostring(Widget))
                    NotifyTimeOutFinish("SureClicked")
                end

                -- 添加到视口
                Widget:AddToViewport(6000)
                ugcprint("[UGCPlayerController] Settlement_2 UI 已添加到视口")
            else
                ugcprint("[UGCPlayerController] 创建 Settlement_2 UI 失败，Widget为nil")
                NotifyTimeOutFinish("CreateWidgetFailed")
            end
        end)
    end)
    if not okCreateWidgetAsync then
        ugcprint("[UGCPlayerController] Settlement_2 CreateWidgetAsync 调用失败: " .. tostring(createWidgetAsyncErr))
        NotifyTimeOutFinish("CreateWidgetAsyncError")
    end
end

--- Server: notify level reward finished
function UGCPlayerController:Server_NotifyLevelRewardFinish()
    ugcprint("[Server] Server_NotifyLevelRewardFinish 被调用")
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end

    -- 结算收口时统一停刷清怪，避免匹配前继续刷怪。
    StopAndCleanSingle1TriggerBoxesForServer(self, "LevelRewardFinish")

    -- 获取保存的 LevelRewardActor 引用
    if self.CurrentLevelRewardActor then
        local rewardActor = self.CurrentLevelRewardActor
        if rewardActor.bLevelRewardFinished then
            ugcprint("[Server] CurrentLevelRewardActor 已完成，忽略重复 OnFinish")
        else
            rewardActor.bLevelRewardFinished = true
            ugcprint("[Server] 找到 CurrentLevelRewardActor，调用 OnFinish()")
            rewardActor:OnFinish()
        end
        self.CurrentLevelRewardActor = nil
    else
        ugcprint("[Server] 警告：CurrentLevelRewardActor 不存在，直接显示 SettlementTip 防止卡死")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
    end
end

--- Server: notify timeout finished
function UGCPlayerController:Server_NotifyTimeOutFinish()
    local playerKey = "Unknown"
    local okPlayerKey, playerKeyOrErr = pcall(function()
        return UGCGameSystem.GetPlayerKeyByPlayerController(self)
    end)
    if okPlayerKey then
        playerKey = tostring(playerKeyOrErr)
    end

    ugcprint("[Server] Server_NotifyTimeOutFinish 被调用, playerKey=" .. tostring(playerKey))
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end

    -- 超时收口时统一停刷清怪，避免回退路径遗漏。
    StopAndCleanSingle1TriggerBoxesForServer(self, "TimeOutFinish")

    if self.bHandlingTimeOutFinishRPC then
        ugcprint("[Server] Server_NotifyTimeOutFinish 正在处理中，忽略重复调用, playerKey=" .. tostring(playerKey))
        return
    end

    self.bHandlingTimeOutFinishRPC = true

    local okHandle, handleErr = pcall(function()
        local timeOutActor = self.CurrentTimeOutActor

        if (not timeOutActor) or (not IsObjectValidSafe(timeOutActor)) then
            local resolvedActor, classPath = ResolveSingleModeTimeOutActor(self)
            if resolvedActor then
                timeOutActor = resolvedActor
                ugcprint("[Server] CurrentTimeOutActor 为空，已通过类路径定位到 TimeOutActor: " .. tostring(classPath) .. ", playerKey=" .. tostring(playerKey))
            else
                ugcprint("[Server] 通过类路径定位 TimeOutActor 失败, playerKey=" .. tostring(playerKey))
            end
        end

        if timeOutActor and IsObjectValidSafe(timeOutActor) then
            if timeOutActor.bTimeOutFinished then
                ugcprint("[Server] TimeOutActor 已完成，忽略重复 OnFinish, playerKey=" .. tostring(playerKey))
            else
                timeOutActor.bTimeOutFinished = true
                ugcprint("[Server] 调用 TimeOutActor:OnFinish()，按关卡流程进入结算阶段, playerKey=" .. tostring(playerKey))
                timeOutActor:OnFinish()
            end

            self.CurrentTimeOutActor = nil
        else
            ugcprint("[Server] 警告：未找到 TimeOutActor，回退为直接显示 SettlementTip, playerKey=" .. tostring(playerKey))
            UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
        end
    end)

    self.bHandlingTimeOutFinishRPC = false

    if not okHandle then
        ugcprint("[Server] Server_NotifyTimeOutFinish 执行异常: " .. tostring(handleErr) .. ", playerKey=" .. tostring(playerKey))
        local okFallback, fallbackErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
        end)
        if not okFallback then
            ugcprint("[Server] Server_NotifyTimeOutFinish 异常后兜底调用失败: " .. tostring(fallbackErr) .. ", playerKey=" .. tostring(playerKey))
        end
    end
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
        self.MMainUI:ShowTip("当前无法获得经验，请先转生")
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

--- Client: sync per-player kill count for FriendList
function UGCPlayerController:Client_SyncPlayerKillCount(playerKey, killCount)
    if not self:IsLocalController() then
        return
    end

    ugcprint("[UGCPlayerController] Client_SyncPlayerKillCount key=" .. tostring(playerKey) .. ", kill=" .. tostring(killCount))

    if self.MMainUI and self.MMainUI.SyncFriendListPlayerKillCount then
        self.MMainUI:SyncFriendListPlayerKillCount(playerKey, killCount)
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
                self.MMainUI:ShowTip(tostring(TargetPlayerName) .. " 已加入队伍")
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
        self.MMainUI:ShowTip("你已被踢出队伍")
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
        taUI.SettlementActionPending = false
        taUI.DisplayLevelNum = LevelNum
        if taUI.settlementtip then
            taUI.settlementtip:SetText("恭喜通过第" .. tostring(LevelNum) .. "层，奖励如下")
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
            self.MMainUI:ShowTip("领取成功！")
        else
            self.MMainUI:ShowTip("领取失败，请稍后再试")
        end
    end
end

-- Client: Jiange floor claim result
function UGCPlayerController:Client_OnJiangeFloorClaimResult(success, floorNum, tipText)
    if not self:IsLocalController() then return end

    if self.MMainUI and self.MMainUI.wujingjiange then
        self.MMainUI.wujingjiange.FloorClaimPending = false
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip(tostring(floorNum or 0) .. "层奖励领取成功")
        else
            self.MMainUI:ShowTip("领取失败，请稍后再试")
        end
    end

    if success and self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.RefreshRewardStates then
        self.MMainUI.wujingjiange:RefreshRewardStates()
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

-- Client: charge reward claim result
function UGCPlayerController:Client_OnChongzhiClaimResult(success, rewardID, tipText)
    if not self:IsLocalController() then return end

    if success then
        local playerState = UGCGameSystem.GetLocalPlayerState()
        local claimID = math.floor(tonumber(rewardID) or 0)
        if playerState and claimID > 0 then
            playerState.ClaimedChongzhi = playerState.ClaimedChongzhi or {}
            playerState.ClaimedChongzhi[claimID] = true
            if playerState.SerializeClaimedChongzhi then
                playerState.UGCClaimedChongzhiStr = playerState:SerializeClaimedChongzhi(playerState.ClaimedChongzhi)
            end
        end
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip("充值奖励领取成功")
        else
            self.MMainUI:ShowTip("充值奖励领取失败")
        end
    end

    if self.MMainUI and self.MMainUI.active and self.MMainUI.active.RefreshBuySlots then
        if self.MMainUI.active:GetVisibility() == ESlateVisibility.Visible then
            self.MMainUI.active:RefreshBuySlots()
        end
    end
end

function UGCPlayerController:Client_OnTalentUpgradeResult(success, talentType, currentLevel, remainCount, tipText)
    if not self:IsLocalController() then return end

    local handled = false
    if self.MMainUI and self.MMainUI.TalentTree and self.MMainUI.TalentTree.OnTalentUpgradeResult then
        handled = self.MMainUI.TalentTree:OnTalentUpgradeResult(success, talentType, currentLevel, remainCount, tipText) == true
    end

    if handled then
        return
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip("天赋升级成功")
        else
            self.MMainUI:ShowTip("天赋升级失败")
        end
    end
end

function UGCPlayerController:Client_OnManualPointResult(success, pointType, remainTalentPoints, tipText)
    if not self:IsLocalController() then return end

    local handled = false
    if self.MMainUI and self.MMainUI.touxiangdetail and self.MMainUI.touxiangdetail.OnManualPointResult then
        handled = self.MMainUI.touxiangdetail:OnManualPointResult(success, pointType, remainTalentPoints, tipText) == true
    end

    if handled then
        return
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip("加点成功")
        else
            self.MMainUI:ShowTip("加点失败")
        end
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
        self.MMainUI:ShowTip("防守失败")
    end

    -- Delay 2 seconds then enter exit flow
    local PlayerController = self
    if self.P1DiedDelayHandle then
        local okClearTimer, clearTimerErr = pcall(function()
            UGCGameSystem.ClearTimer(self, self.P1DiedDelayHandle)
        end)
        if not okClearTimer then
            ugcprint("[UGCPlayerController] 清理 P1DiedDelayHandle 失败: " .. tostring(clearTimerErr))
        end
        self.P1DiedDelayHandle = nil
    end

    self.P1DiedDelayHandle = UGCGameSystem.SetTimer(self, function()
        self.P1DiedDelayHandle = nil
        -- ugcprint("[UGCPlayerController] Defense failed, entering exit flow")
        local okRPC, rpcErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyTimeOutFinish")
        end)
        if not okRPC then
            ugcprint("[UGCPlayerController] Error: failed to call Server_NotifyTimeOutFinish: " .. tostring(rpcErr))
        end
    end, 2.0, false)
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