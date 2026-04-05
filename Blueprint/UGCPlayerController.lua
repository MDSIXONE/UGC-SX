---@class UGCPlayerController_C:BP_UGCPlayerController_C
---@field LotteryComponent LotteryComponent_C
---@field GiftPackComponent GiftPackComponent_C
---@field RankingListComponent RankingListComponent_C
---@field ShopV2Component ShopV2Component_C
--Edit Below--
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local UGCPlayerController = {}

-- 全局队长数据表，key=TeamID, value=队长PlayerKey（服务器端）
TeamCaptainData = TeamCaptainData or {}

function UGCPlayerController:ReceiveBeginPlay()
    --ugcprint("========== UGCPlayerController:ReceiveBeginPlay 开始 ==========")
    UGCPlayerController.SuperClass.ReceiveBeginPlay(self)
    
    -- 创建延时执行，给玩家初始物品（仅首次进入）
    local OBTimerDelegate = ObjectExtend.CreateDelegate(self, 
        function()
            if self:HasAuthority() == true then
                local Uid = UGCGameSystem.GetUIDByPlayerController(self)
                local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)
                
                -- 检查是否已经发放过初始装备
                if not Data.HasReceivedInitialEquipment then
                    --ugcprint("[UGCPlayerController] 首次进入游戏，发放初始装备")
                    
                    local PlayerPawn = self:GetPlayerCharacterSafety()
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310033, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310006, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310007, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310008, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310009, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310010, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310011, 1)
                    UGCBackPackSystem.AddItem(PlayerPawn, 8310046, 99999)
                    
                    -- 标记已发放初始装备
                    Data.HasReceivedInitialEquipment = true
                    UGCPlayerStateSystem.SavePlayerArchiveData(Uid, Data)
                    --ugcprint("[UGCPlayerController] 初始装备发放完成，已保存标记")
                else
                    --ugcprint("[UGCPlayerController] 玩家已领取过初始装备，跳过发放")
                end
            end
        end
    )
    KismetSystemLibrary.K2_SetTimerDelegateForLua(OBTimerDelegate, self, 2, false)
    
    -- 只在本地客户端创建UI
    if self:IsLocalController() then
        --ugcprint("UGCPlayerController: 这是本地控制器，创建UI")
        
        -- 先创建 MainWidget，层级较低 (1000)
        local mainWidget = UGCGameData.GetUI(self, "MainWidget")
        if mainWidget then
            self.MainWidget = mainWidget
            mainWidget:AddToViewport(1000)
            --ugcprint("UGCPlayerController: MainWidget 已添加到视口，层级 1000")
        else
            --ugcprint("UGCPlayerController: 错误 - 无法创建 MainWidget")
        end
        
        -- 再创建 MMainUI，层级较高 (1100)
        local mainUI = UGCGameData.GetUI(self, "MMainUI")
        if mainUI then
            self.MMainUI = mainUI
            mainUI:AddToViewport(1100)
            --ugcprint("UGCPlayerController: MMainUI 已添加到视口并保存引用，层级 1100")
            
            if mainUI.TASK then
                --ugcprint("UGCPlayerController: MMainUI.TASK 组件存在")
            else
                --ugcprint("UGCPlayerController: 警告 - MMainUI.TASK 组件不存在")
            end
        else
            --ugcprint("UGCPlayerController: 错误 - 无法创建 MMainUI")
        end
        
        -- 监听购买结果委托
        self:RegisterBuyProductDelegate()
    else
        --ugcprint("UGCPlayerController: 不是本地控制器，跳过UI创建")
    end
    
    --ugcprint("========== UGCPlayerController:ReceiveBeginPlay 完成 ==========")
    
    -- 3秒后检查模式ID和关卡阶段
    if self:IsLocalController() then
        UGCTimerUtility.CreateLuaTimer(
            3.0,  -- 延时3秒
            function()
                local currentModeID = UGCMultiMode.GetModeID()
                local currentStage = UGCLevelFlowSystem.GetCurrentLevelStage(self)
                
                ugcprint("[UGCPlayerController] ========== 3秒后检查 ==========")
                ugcprint("[UGCPlayerController] 当前模式ID: " .. tostring(currentModeID))
                ugcprint("[UGCPlayerController] 当前关卡阶段: " .. tostring(currentStage))
                
                -- 测试读取副本数据表
                if currentModeID == 1002 then
                    ugcprint("[UGCPlayerController] 副本配置表路径: " .. tostring(UGCGameData.FubenTablePath))
                    local MgrPath = UGCGameData.GetGameModeActorMgrConfig(currentModeID)
                    if MgrPath and MgrPath ~= "" then
                        ugcprint("[UGCPlayerController] 副本数据表读取成功: " .. tostring(MgrPath))
                    else
                        ugcprint("[UGCPlayerController] 副本数据表读取失败或未配置")
                        ugcprint("[UGCPlayerController] MgrPath = " .. tostring(MgrPath))
                    end
                end
                
                if currentModeID == -99999 or currentModeID == 0 then
                    ugcprint("[UGCPlayerController] 提示：当前在大厅模式")
                else
                    ugcprint("[UGCPlayerController] 当前处于模式: " .. tostring(currentModeID) .. "，关卡: " .. tostring(currentStage))
                end
                ugcprint("[UGCPlayerController] ================================")
            end,
            false,  -- 不循环，只执行一次
            "CheckModeID_Timer"  -- 定时器名称
        )
    end
end

-- 注册购买结果委托
function UGCPlayerController:RegisterBuyProductDelegate()
    UGCTimerUtility.CreateLuaTimer(
        1,
        function()
            local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
            if CommodityOperationManager then
                CommodityOperationManager.BuyProductResultDelegate:Add(self.OnBuyProductResult, self)
                --ugcprint("[UGCPlayerController] 购买结果委托已注册")
            else
                --ugcprint("[UGCPlayerController] 无法获取 CommodityOperationManager")
            end
        end,
        false,
        "RegisterBuyProductDelegate"
    )
end

-- 购买结果回调
function UGCPlayerController:OnBuyProductResult(Result)
    --ugcprint("[UGCPlayerController] 收到购买结果回调")
    
    if Result and Result.bSucceeded then
        local spendAmount = Result.TotalPrice
        if not spendAmount or spendAmount == 0 then
            spendAmount = Result.Num or 1
        end
        --[[        --ugcprint(string.format("[UGCPlayerController] 购买成功，消费金额: %d", spendAmount))]]
        
        local playerState = UGCGameSystem.GetPlayerStateByPlayerController(self)
        if playerState then
            UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddSpendCount", spendAmount)
        end
    else
        --ugcprint("[UGCPlayerController] 购买失败或结果无效")
    end
end

-- 声明可用的服务器 RPC
function UGCPlayerController:GetAvailableServerRPCs()
    return "Server_TeleportPlayer", "Server_RestoreFullHealth", "Server_DestroyNearbyCorpses", "Server_SetDirectExpEnabled", "Server_SetBloodlineEnabled", "Server_NotifyLevelRewardFinish", "Server_NotifyTimeOutFinish", "Server_GiveRewards", "Server_SendTeamInvite", "Server_RespondTeamInvite", "Server_RequestJoinTeam", "Server_AcceptJoinRequest", "Server_KickFromTeam", "Server_LeaveTeam", "Server_ResumeTriggerBoxSpawning"
end

-- 声明可用的客户端 RPC
function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_ShowTunshiSuccess", "Client_SetPlayerRotation", "Client_ShowSettlementUI", "Client_ShowSettlementTipUI", "Client_ShowSettlement2UI", "Client_OnPlayerLevelUp", "Client_ReceiveTeamInvite", "Client_TeamInviteResult", "Client_ReceiveJoinRequest", "Client_RefreshTeamUI", "Client_ShowTaSettlementUI", "Client_UpdateJiangeFloor"
end

-- 客户端RPC：显示吞噬成功提示
function UGCPlayerController:Client_ShowTunshiSuccess(totalExp)
    --ugcprint("[Client] Client_ShowTunshiSuccess 收到吞噬成功通知，经验值: " .. tostring(totalExp))
    
    if not self:IsLocalController() then
        return
    end
    
    if self.MMainUI and self.MMainUI.tunshitip then
        if self.MMainUI.tunshitip.ShowTips then
            self.MMainUI.tunshitip:ShowTips("吞噬成功+" .. tostring(totalExp))
            --ugcprint("[Client] 显示吞噬提示: 吞噬成功+" .. tostring(totalExp))
        end
    end
end

-- 服务器端处理回满血请求
function UGCPlayerController:Server_RestoreFullHealth()
    --ugcprint("[Server] Server_RestoreFullHealth 收到回满血请求")
    
    local ok, err = pcall(function()
        local PlayerPawn = self.Pawn or self:K2_GetPawn()
        if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
            --ugcprint("[Server] 错误：无法获取玩家 Pawn")
            return
        end
        
        local maxHealth = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'HealthMax') or 100
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, 'Health', maxHealth)
        --ugcprint("[Server] 已将生命值设置为: " .. tostring(maxHealth))
    end)
    
    if not ok then
        --ugcprint("[Server] Server_RestoreFullHealth 发生错误: " .. tostring(err))
    end
end

-- 服务器端处理传送请求
function UGCPlayerController:Server_TeleportPlayer(X, Y, Z, Yaw)
    --ugcprint("[Server] Server_TeleportPlayer 收到传送请求")
    --ugcprint("[Server] 目标位置: X=" .. tostring(X) .. " Y=" .. tostring(Y) .. " Z=" .. tostring(Z) .. " Yaw=" .. tostring(Yaw))
    
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
            --ugcprint("[Server] 错误：无法获取玩家 Pawn")
            return
        end
        
        local TargetLocation = Vector.New(X, Y, Z)
        
        -- 如果提供了朝向参数，使用 K2_SetActorLocationAndRotation 同时设置位置和朝向
        if Yaw and Yaw ~= 0 then
            -- 使用固定的 Pitch=0, Roll=0，只设置 Yaw
            local newRotation = Rotator.New(0, Yaw, 0)
            
            -- K2_SetActorLocationAndRotation 参数：位置、旋转、是否碰撞检测、扫描结果、是否强制设置
            PlayerPawn:K2_SetActorLocationAndRotation(TargetLocation, newRotation, false, nil, true)
            
            --ugcprint("[Server] 传送位置和朝向成功! Yaw=" .. Yaw)
            
            -- 通过客户端 RPC 通知客户端设置朝向（这是关键）
            UnrealNetwork.CallUnrealRPC(self, self, "Client_SetPlayerRotation", Yaw)
        else
            -- 没有朝向参数，只传送位置
            PlayerPawn:K2_SetActorLocation(TargetLocation, false, nil, true)
            --ugcprint("[Server] 传送位置成功!")
        end
    end)
    
    if not ok then
        --ugcprint("[Server] Server_TeleportPlayer 发生错误: " .. tostring(err))
    end
end

-- 客户端 RPC：设置玩家朝向
function UGCPlayerController:Client_SetPlayerRotation(Yaw)
    --ugcprint("[Client] Client_SetPlayerRotation 收到朝向设置请求: Yaw=" .. tostring(Yaw))
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local newRotation = Rotator.New(0, Yaw, 0)
        PlayerPawn:K2_SetActorRotation(newRotation, false)
        
        if self.SetControlRotation then
            self:SetControlRotation(newRotation)
        end
        
        --ugcprint("[Client] 客户端朝向已设置: Yaw=" .. Yaw)
    end
end

-- 服务器端处理销毁附近尸体请求（吞噬系统核心）
function UGCPlayerController:Server_DestroyNearbyCorpses()
    --ugcprint("[Server] Server_DestroyNearbyCorpses 收到销毁尸体请求")
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end
    
    local ok, err = pcall(function()
        local PlayerPawn = self.Pawn or self:K2_GetPawn()
        if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
            --ugcprint("[Server] 错误：无法获取玩家 Pawn")
            return
        end
        
        local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
        if not PlayerState then
            --ugcprint("[Server] 错误：无法获取 PlayerState")
            return
        end
        
        local playerLocation = PlayerPawn:K2_GetActorLocation()
        
        -- 从全局列表获取死亡怪物
        local deadMonsters = UGCGameData.DeadMonsters
        --ugcprint("[Server] 死亡怪物列表数量: " .. #deadMonsters)
        
        local destroyedCount = 0
        local totalExp = 0
        local remainingMonsters = {}
        
        -- 遍历所有死亡怪物
        for i, monster in ipairs(deadMonsters) do
            if monster and UGCObjectUtility.IsObjectValid(monster) then
                local monsterLocation = monster:K2_GetActorLocation()
                local diffX = playerLocation.X - monsterLocation.X
                local diffY = playerLocation.Y - monsterLocation.Y
                local diffZ = playerLocation.Z - monsterLocation.Z
                local distance = math.sqrt(diffX*diffX + diffY*diffY + diffZ*diffZ)
                
                -- 距离小于1000时销毁并获取经验
                if distance < 1000 then
                    if monster.MonsterID then
                        local monsterConfig = UGCGameData.GetMonsterConfig(monster.MonsterID)
                        if monsterConfig and monsterConfig.KillExp and monsterConfig.KillExp > 0 then
                            -- 获取玩家的额外吞噬经验属性
                            local ecexp = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'Ecexp') or 0
                            
                            -- 吞噬获得的经验 = 基础经验 × (1 + 50% + Ecexp%)
                            local baseExp = monsterConfig.KillExp
                            local bonusRate = 1 + 0.5 + (ecexp / 100)
                            local monsterExp = math.floor(baseExp * bonusRate)
                            totalExp = totalExp + monsterExp
                            
                            --ugcprint("[Server] 吞噬怪物 ID=" .. monster.MonsterID .. ", 基础经验: " .. baseExp .. ", Ecexp: " .. ecexp .. "%, 加成倍率: " .. bonusRate .. ", 最终经验: " .. monsterExp)
                            
                            -- 为每个怪物单独显示提示
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
        
        -- 更新全局列表
        UGCGameData.DeadMonsters = remainingMonsters
        --ugcprint("[Server] 已销毁 " .. destroyedCount .. " 具尸体，剩余 " .. #remainingMonsters .. " 具")
        
        -- 给玩家增加经验
        if totalExp > 0 then
            --ugcprint("[Server] 吞噬获得总经验: " .. totalExp)
            
            if PlayerState.AddExp then
                PlayerState:AddExp(totalExp)
                --ugcprint("[Server] 经验已发放")
            end
            
            -- 添加吞噬特效BUFF
            local buffPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tunshi.tunshi_C')
            local buffObj = UGCPersistEffectSystem.AddBuffByClass(PlayerPawn, buffPath, nil, 2, 1)
            
            if buffObj then
                --ugcprint("[Server] ✓ 吞噬特效BUFF添加成功！")
            else
                --ugcprint("[Server] ✗ 吞噬特效BUFF添加失败！")
            end
        end
    end)
    
    if not ok then
        --ugcprint("[Server] Server_DestroyNearbyCorpses 发生错误: " .. tostring(err))
    end
end

--- 服务器端设置直接获取经验开关
function UGCPlayerController:Server_SetDirectExpEnabled(isEnabled)
    --ugcprint("[Server] Server_SetDirectExpEnabled 收到设置请求: " .. tostring(isEnabled))
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        --ugcprint("[Server] 错误：无法获取玩家 Pawn")
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
    if not PlayerState then
        --ugcprint("[Server] 错误：无法获取 PlayerState")
        return
    end
    
    -- 调用 PlayerState 的设置函数
    if PlayerState.Server_SetDirectExpEnabled then
        PlayerState:Server_SetDirectExpEnabled(isEnabled)
    end
end

--- 服务器端设置血脉开关
function UGCPlayerController:Server_SetBloodlineEnabled(isEnabled)
    --ugcprint("[Server] Server_SetBloodlineEnabled 收到设置请求: " .. tostring(isEnabled))
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        --ugcprint("[Server] 错误：无法获取玩家 Pawn")
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(PlayerPawn)
    if not PlayerState then
        --ugcprint("[Server] 错误：无法获取 PlayerState")
        return
    end
    
    -- 调用 PlayerState 的设置函数
    if PlayerState.Server_SetBloodlineEnabled then
        PlayerState:Server_SetBloodlineEnabled(isEnabled)
    end
end

-- ============ 副本系统RPC ============

---客户端RPC：显示 Settlement UI（副本成功奖励）
function UGCPlayerController:Client_ShowSettlementUI()
    ugcprint("[UGCPlayerController] Client_ShowSettlementUI 被调用")
    
    if not self:IsLocalController() then
        return
    end
    
    local settlementPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement.Settlement_C')
    ugcprint("[UGCPlayerController] Settlement UI 路径: " .. tostring(settlementPath))
    
    -- 保存 PlayerController 引用，供回调函数使用
    local PlayerController = self
    
    -- 异步创建 Settlement UI
    UGCWidgetManagerSystem.CreateWidgetAsync(settlementPath, function(Widget)
        --ugcprint("[UGCPlayerController] CreateWidgetAsync 回调被调用")
        if Widget then
            ugcprint("[UGCPlayerController] 成功创建 Settlement UI")
            
            -- 设置回调函数，使用闭包捕获 PlayerController
            Widget.OnSureClicked = function()
                ugcprint("[UGCPlayerController] Settlement UI 的 sure 按钮被点击")
                --ugcprint("[UGCPlayerController] 准备调用服务器RPC")
                
                -- 调用服务器RPC通知关底奖励完成
                UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyLevelRewardFinish")
            end
            
            -- 添加到视口
            Widget:AddToViewport(6000)  -- 使用更高的层级
            ugcprint("[UGCPlayerController] Settlement UI 已添加到视口")
        else
            ugcprint("[UGCPlayerController] 创建 Settlement UI 失败，Widget为nil")
        end
    end)
end

---客户端RPC：显示 SettlementTip UI（匹配提示）
function UGCPlayerController:Client_ShowSettlementTipUI()
    ugcprint("[UGCPlayerController] Client_ShowSettlementTipUI 被调用")
    
    if not self:IsLocalController() then
        return
    end
    
    local settlementTipPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/SettlementTip.SettlementTip_C')
    ugcprint("[UGCPlayerController] SettlementTip UI 路径: " .. tostring(settlementTipPath))
    
    -- 保存 PlayerController 引用，供回调函数使用
    local PlayerController = self
    
    -- 异步创建 SettlementTip UI
    UGCWidgetManagerSystem.CreateWidgetAsync(settlementTipPath, function(Widget)
        --ugcprint("[UGCPlayerController] CreateWidgetAsync 回调被调用")
        if Widget then
            ugcprint("[UGCPlayerController] 成功创建 SettlementTip UI")
            
            -- 添加到视口，一直显示
            Widget:AddToViewport(6000)
            ugcprint("[UGCPlayerController] SettlementTip UI 已添加到视口，将一直显示")
            
            -- 直接发起模式1001匹配
            --ugcprint("[UGCPlayerController] 立即发起模式1001匹配")
            
            -- 监听匹配成功事件
            if UGCMultiMode then
                UGCMultiMode.NotifyMatchSucceededDelegate:Add(function()
                    ugcprint("[UGCPlayerController] 匹配成功！隐藏 SettlementTip UI")
                    if Widget and UGCObjectUtility.IsObjectValid(Widget) then
                        Widget:RemoveFromParent()
                    end
                end, PlayerController)
                
                -- 发起匹配
                local bRequestSuccess = UGCMultiMode.RequestMatch(1001, function(bSuccess)
                    if bSuccess then
                        --ugcprint("[UGCPlayerController] 模式1001匹配请求成功，等待匹配成功回调...")
                    else
                        --ugcprint("[UGCPlayerController] 模式1001匹配请求失败")
                    end
                end, PlayerController)
                
                --ugcprint("[UGCPlayerController] RequestMatch 返回值: " .. tostring(bRequestSuccess))
            else
                --ugcprint("[UGCPlayerController] 错误：UGCMultiMode 不存在")
            end
        else
            ugcprint("[UGCPlayerController] 创建 SettlementTip UI 失败，Widget为nil")
        end
    end)
end

---客户端RPC：显示 Settlement_2 UI（超时失败）
function UGCPlayerController:Client_ShowSettlement2UI()
    ugcprint("[UGCPlayerController] Client_ShowSettlement2UI 被调用")
    
    if not self:IsLocalController() then
        return
    end
    
    local settlement2Path = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement_2.Settlement_2_C')
    ugcprint("[UGCPlayerController] Settlement_2 UI 路径: " .. tostring(settlement2Path))
    
    -- 保存 PlayerController 引用，供回调函数使用
    local PlayerController = self
    
    -- 异步创建 Settlement_2 UI
    UGCWidgetManagerSystem.CreateWidgetAsync(settlement2Path, function(Widget)
        if Widget then
            ugcprint("[UGCPlayerController] 成功创建 Settlement_2 UI")
            
            -- 设置回调函数，UI显示后立即执行
            Widget.OnSureClicked = function()
                ugcprint("[UGCPlayerController] Settlement_2 触发后续流程")
                
                -- 调用服务器RPC通知超时完成
                UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyTimeOutFinish")
            end
            
            -- 添加到视口
            Widget:AddToViewport(6000)
            ugcprint("[UGCPlayerController] Settlement_2 UI 已添加到视口")
        else
            ugcprint("[UGCPlayerController] 创建 Settlement_2 UI 失败，Widget为nil")
        end
    end)
end

---服务器RPC：通知关底奖励完成
function UGCPlayerController:Server_NotifyLevelRewardFinish()
    ugcprint("[Server] Server_NotifyLevelRewardFinish 被调用")
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end
    
    -- 获取保存的 LevelRewardActor 引用
    if self.CurrentLevelRewardActor then
        ugcprint("[Server] 找到 CurrentLevelRewardActor，调用 OnFinish()")
        self.CurrentLevelRewardActor:OnFinish()
        self.CurrentLevelRewardActor = nil
    else
        ugcprint("[Server] 警告：CurrentLevelRewardActor 不存在")
    end
end

---服务器RPC：通知超时完成
function UGCPlayerController:Server_NotifyTimeOutFinish()
    ugcprint("[Server] Server_NotifyTimeOutFinish 被调用")
    
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end
    
    -- 获取保存的 TimeOutActor 引用
    if self.CurrentTimeOutActor then
        ugcprint("[Server] 找到 CurrentTimeOutActor")
        
        -- 超时不需要调用 OnFinish()，系统会自动处理
        -- 直接清理引用
        self.CurrentTimeOutActor = nil
        ugcprint("[Server] 已清理 CurrentTimeOutActor 引用")
        
        -- 超时完成后，显示 SettlementTip UI 并发起模式1001匹配
        ugcprint("[Server] 调用客户端RPC显示 SettlementTip UI")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
    else
        ugcprint("[Server] 警告：CurrentTimeOutActor 不存在")
    end
end

---客户端RPC：玩家升级通知
function UGCPlayerController:Client_OnPlayerLevelUp(newLevel)
    --ugcprint("[Client] Client_OnPlayerLevelUp 收到升级通知，新等级: " .. tostring(newLevel))
    
    if not self:IsLocalController() then
        return
    end
end

-- ============ 奖励发放RPC ============

---服务器RPC：发放副本奖励
function UGCPlayerController:Server_GiveRewards()
    ugcprint("[Server] Server_GiveRewards 被调用")
    
    if not self:HasAuthority() then
        return
    end
    
    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        ugcprint("[Server] Server_GiveRewards 错误：无法获取玩家 Pawn")
        return
    end
    
    -- 读取奖励数据表
    local allRewards = UGCGameData.GetAllFubenreword()
    if not allRewards then
        ugcprint("[Server] Server_GiveRewards 错误：无法读取副本奖励表")
        return
    end
    
    local rewardCount = 0
    for rowName, rewardData in pairs(allRewards) do
        local virtualItemID = rewardData["虚拟物品ID"]
        local itemCount = rewardData["数量"]
        
        if virtualItemID and itemCount then
            itemCount = math.floor(tonumber(itemCount) or 0)
            
            if itemCount > 0 then
                -- 通过虚拟ID查找实际物品ID
                local mapping = UGCGameData.GetItemMapping(virtualItemID)
                if mapping and mapping["ClassicItemID"] then
                    local realItemID = mapping["ClassicItemID"]
                    
                    ugcprint("[Server] 发放奖励: 虚拟ID=" .. tostring(virtualItemID) .. ", 实际ID=" .. tostring(realItemID) .. ", 数量=" .. tostring(itemCount))
                    
                    local success = UGCBackPackSystem.AddItem(PlayerPawn, realItemID, itemCount)
                    if success then
                        rewardCount = rewardCount + 1
                        local currentCount = UGCBackPackSystem.GetItemCount(PlayerPawn, realItemID)
                        ugcprint("[Server] ✓ 发放成功，背包数量: " .. tostring(currentCount))
                    else
                        ugcprint("[Server] ✗ 发放失败")
                    end
                else
                    ugcprint("[Server] 警告：无法找到虚拟ID的映射: " .. tostring(virtualItemID))
                end
            end
        end
    end
    
    ugcprint("[Server] Server_GiveRewards 完成，共发放 " .. rewardCount .. " 个奖励")
end

-- ============ 队伍系统RPC ============

---服务器RPC：发送组队邀请
function UGCPlayerController:Server_SendTeamInvite(TargetPlayerKey)
    ugcprint("[UGCPlayerController] Server_SendTeamInvite: 目标PlayerKey=" .. tostring(TargetPlayerKey))
    
    local InviterPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    
    -- 检查队伍人数，如果只有自己一个人，设为队长
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
            ugcprint("[UGCPlayerController] 队伍" .. tostring(InviterTeamID) .. "队长设为: " .. tostring(InviterPlayerKey))
        end
    end
    
    -- 找到目标玩家的 PlayerController
    local TargetPC = UGCGameSystem.GetPlayerControllerByPlayerKey(TargetPlayerKey)
    if TargetPC then
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_ReceiveTeamInvite", InviterPlayerKey)
    end
end

---服务器RPC：回复组队邀请
function UGCPlayerController:Server_RespondTeamInvite(InviterPlayerKey, bAccepted)
    ugcprint("[UGCPlayerController] Server_RespondTeamInvite: InviterPlayerKey=" .. tostring(InviterPlayerKey) .. ", bAccepted=" .. tostring(bAccepted))
    
    local ResponderPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    
    if bAccepted then
        local InviterPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(InviterPlayerKey)
        if InviterPawn then
            local InviterTeamID = UGCPawnAttrSystem.GetTeamID(InviterPawn)
            UGCTeamSystem.ChangePlayerTeamID(ResponderPlayerKey, InviterTeamID)
            ugcprint("[UGCPlayerController] 换队：ResponderPlayerKey=" .. tostring(ResponderPlayerKey) .. " -> TeamID=" .. tostring(InviterTeamID))
        end
    end
    
    -- 通知邀请者
    local InviterPC = UGCGameSystem.GetPlayerControllerByPlayerKey(InviterPlayerKey)
    if InviterPC then
        UnrealNetwork.CallUnrealRPC(InviterPC, InviterPC, "Client_TeamInviteResult", ResponderPlayerKey, bAccepted, true)
    end
    
    -- 通知被邀请者自己
    if bAccepted then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_TeamInviteResult", InviterPlayerKey, bAccepted, false)
    end
end

---客户端RPC：收到组队邀请
function UGCPlayerController:Client_ReceiveTeamInvite(InviterPlayerKey)
    ugcprint("[UGCPlayerController] Client_ReceiveTeamInvite: InviterPlayerKey=" .. tostring(InviterPlayerKey))
    
    local InviteClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Teamiinvite.WB_Teamiinvite_C'))
    if not InviteClass then
        ugcprint("[UGCPlayerController] 错误：无法加载 WB_Teamiinvite 类")
        return
    end
    
    local inviteUI = UserWidget.NewWidgetObjectBP(self, InviteClass)
    if inviteUI then
        inviteUI.InviterPlayerKey = InviterPlayerKey
        inviteUI:AddToViewport(7000)
    end
end

---客户端RPC：收到邀请结果
function UGCPlayerController:Client_TeamInviteResult(TargetPlayerKey, bAccepted, bIsCaptain)
    ugcprint("[UGCPlayerController] Client_TeamInviteResult: TargetPlayerKey=" .. tostring(TargetPlayerKey) .. ", bAccepted=" .. tostring(bAccepted) .. ", bIsCaptain=" .. tostring(bIsCaptain))
    
    if self.MMainUI and self.MMainUI.WB_Team then
        if bAccepted then
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
            -- 延迟0.5秒重建所有槽位
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

---服务器RPC：踢出队伍（队长操作）
function UGCPlayerController:Server_KickFromTeam(TargetPlayerKey)
    ugcprint("[UGCPlayerController] Server_KickFromTeam: TargetPlayerKey=" .. tostring(TargetPlayerKey))
    
    local CaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local CaptainPawn = self.Pawn
    if not CaptainPawn then return end
    
    local CaptainTeamID = UGCPawnAttrSystem.GetTeamID(CaptainPawn)
    
    -- 验证是否是队长
    if not TeamCaptainData[CaptainTeamID] or TeamCaptainData[CaptainTeamID] ~= CaptainPlayerKey then
        ugcprint("[UGCPlayerController] 错误：不是队长，无权踢人")
        return
    end
    
    -- 找一个没人用的TeamID
    local newTeamID = 100
    while true do
        local members = UGCTeamSystem.GetPlayerKeysByTeamID(newTeamID)
        if not members or #members == 0 then
            break
        end
        newTeamID = newTeamID + 1
    end
    
    UGCTeamSystem.ChangePlayerTeamID(TargetPlayerKey, newTeamID)
    
    -- 通知原队伍成员刷新UI
    self:RefreshAllTeamUI(CaptainTeamID)
    
    -- 通知被踢玩家刷新UI
    local TargetPC = UGCGameSystem.GetPlayerControllerByPlayerKey(TargetPlayerKey)
    if TargetPC then
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_RefreshTeamUI", -1)
    end
end

---服务器RPC：自己退出队伍
function UGCPlayerController:Server_LeaveTeam()
    local LeaverPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    ugcprint("[UGCPlayerController] Server_LeaveTeam: PlayerKey=" .. tostring(LeaverPlayerKey))
    
    local LeaverPawn = self.Pawn
    if not LeaverPawn then return end
    
    local OldTeamID = UGCPawnAttrSystem.GetTeamID(LeaverPawn)
    
    -- 找一个没人用的TeamID
    local newTeamID = 100
    while true do
        local members = UGCTeamSystem.GetPlayerKeysByTeamID(newTeamID)
        if not members or #members == 0 then
            break
        end
        newTeamID = newTeamID + 1
    end
    
    UGCTeamSystem.ChangePlayerTeamID(LeaverPlayerKey, newTeamID)
    
    -- 通知原队伍成员刷新UI
    self:RefreshAllTeamUI(OldTeamID)
    
    -- 通知自己刷新UI
    UnrealNetwork.CallUnrealRPC(self, self, "Client_RefreshTeamUI", -1)
end

---服务器RPC：申请入队
function UGCPlayerController:Server_RequestJoinTeam(CaptainPlayerKey)
    ugcprint("[UGCPlayerController] Server_RequestJoinTeam: CaptainPlayerKey=" .. tostring(CaptainPlayerKey))
    
    local RequesterPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    
    local CaptainPC = UGCGameSystem.GetPlayerControllerByPlayerKey(CaptainPlayerKey)
    if CaptainPC then
        UnrealNetwork.CallUnrealRPC(CaptainPC, CaptainPC, "Client_ReceiveJoinRequest", RequesterPlayerKey)
    end
end

---服务器RPC：队长同意入队申请
function UGCPlayerController:Server_AcceptJoinRequest(RequesterPlayerKey)
    ugcprint("[UGCPlayerController] Server_AcceptJoinRequest: RequesterPlayerKey=" .. tostring(RequesterPlayerKey))
    
    local CaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local CaptainPawn = self.Pawn
    if not CaptainPawn then return end
    
    local CaptainTeamID = UGCPawnAttrSystem.GetTeamID(CaptainPawn)
    
    -- 验证是否是队长
    if not TeamCaptainData[CaptainTeamID] or TeamCaptainData[CaptainTeamID] ~= CaptainPlayerKey then
        ugcprint("[UGCPlayerController] 错误：不是队长，无权接受入队申请")
        return
    end
    
    -- 把申请者换到队长的队伍
    UGCTeamSystem.ChangePlayerTeamID(RequesterPlayerKey, CaptainTeamID)
    
    -- 通知队长自己刷新UI
    UnrealNetwork.CallUnrealRPC(self, self, "Client_TeamInviteResult", RequesterPlayerKey, true, true)
    
    -- 通知申请者刷新UI
    local RequesterPC = UGCGameSystem.GetPlayerControllerByPlayerKey(RequesterPlayerKey)
    if RequesterPC then
        UnrealNetwork.CallUnrealRPC(RequesterPC, RequesterPC, "Client_TeamInviteResult", CaptainPlayerKey, true, false)
    end
    
    -- 通知队伍其他成员刷新UI
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

---客户端RPC：收到入队申请（队长收到）
function UGCPlayerController:Client_ReceiveJoinRequest(RequesterPlayerKey)
    ugcprint("[UGCPlayerController] Client_ReceiveJoinRequest: RequesterPlayerKey=" .. tostring(RequesterPlayerKey))
    
    local InviteClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Teamiinvite.WB_Teamiinvite_C'))
    if not InviteClass then return end
    
    local inviteUI = UserWidget.NewWidgetObjectBP(self, InviteClass)
    if inviteUI then
        inviteUI.InviterPlayerKey = RequesterPlayerKey
        inviteUI.IsJoinRequest = true
        inviteUI:AddToViewport(7000)
    end
end

---客户端RPC：刷新队伍UI
function UGCPlayerController:Client_RefreshTeamUI(CaptainPK)
    ugcprint("[UGCPlayerController] Client_RefreshTeamUI 被调用, CaptainPK=" .. tostring(CaptainPK))
    
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

---服务器辅助方法：通知指定队伍所有成员刷新UI
function UGCPlayerController:RefreshAllTeamUI(TeamID)
    local CaptainPK = TeamCaptainData and TeamCaptainData[TeamID] or -1
    local TeamPCs = UGCTeamSystem.GetPlayerControllersByTeamID(TeamID)
    if TeamPCs then
        for _, PC in ipairs(TeamPCs) do
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_RefreshTeamUI", CaptainPK)
        end
    end
end

-- ============ 无尽剑阁结算RPC ============

---客户端RPC：显示 ta_settlement UI（层数结算）
function UGCPlayerController:Client_ShowTaSettlementUI(LevelNum)
    ugcprint("[UGCPlayerController] Client_ShowTaSettlementUI 被调用, LevelNum=" .. tostring(LevelNum))

    if not self:IsLocalController() then return end

    -- 使用MMainUI上的ta_settlement子控件
    if self.MMainUI and self.MMainUI.ta_settlement then
        local taUI = self.MMainUI.ta_settlement
        taUI.DisplayLevelNum = LevelNum
        if taUI.settlementtip then
            taUI.settlementtip:SetText("恭喜通过第" .. tostring(LevelNum) .. "层，获得奖励如下")
        end
        if taUI.CreateRewardSlots then
            taUI:CreateRewardSlots()
        end
        taUI:SetVisibility(0) -- Visible
        ugcprint("[UGCPlayerController] ta_settlement UI 已显示，层数=" .. tostring(LevelNum))
    else
        ugcprint("[UGCPlayerController] 错误：MMainUI或ta_settlement不存在")
    end
end

---服务器RPC：恢复TriggerBox刷怪（玩家点击继续后）
function UGCPlayerController:Server_ResumeTriggerBoxSpawning()
    ugcprint("[UGCPlayerController] Server_ResumeTriggerBoxSpawning 被调用")

    if self.CurrentTriggerBox and self.CurrentTriggerBox.ResumeSpawning then
        ugcprint("[UGCPlayerController] 找到TriggerBox，恢复刷怪")
        self.CurrentTriggerBox:ResumeSpawning()
    else
        ugcprint("[UGCPlayerController] 错误：CurrentTriggerBox 为nil或无ResumeSpawning方法")
    end
end

---客户端RPC：更新无尽剑阁层数显示
function UGCPlayerController:Client_UpdateJiangeFloor(floor)
    ugcprint("[UGCPlayerController] Client_UpdateJiangeFloor: " .. tostring(floor))
    if not self:IsLocalController() then return end

    -- 保存到本地，供UI读取
    self.JiangeFloor = floor

    -- 如果wujingjiange界面存在，实时更新（显示下一层，即 floor+1）
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.cengshu then
        self.MMainUI.wujingjiange.cengshu:SetText(tostring(floor + 1))
    end
end

return UGCPlayerController