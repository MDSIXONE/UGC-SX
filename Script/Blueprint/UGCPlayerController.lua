--- ================================================================================
--- UGCPlayerController.lua - 玩家控制器核心模块
---
--- 模块说明：
--- 本模块是 UGC 游戏的核心玩家控制器（PlayerController），负责处理以下主要功能：
---   1. UI 创建与初始化：MainWidget、MMainUI 等界面组件
---   2. RPC 通信：Server/Client 双端 RPC 调用
---   3. 传送系统：玩家位置 teleport 功能
---   4. 剑阁副本：多实例分配、楼层数据同步
---   5. 吞噬系统：尸体吞噬、经验分配
---   6. 副本结算：关卡奖励结算、超时结算、匹配流程
---   7. 队伍系统：邀请、加入、踢人、离开、队长管理
---   8. 宝箱系统：批量开启、奖励发放
---   9. 购买系统：商品购买回调
---
--- 重要组件：
---   - LotteryComponent：抽奖组件
---   - TaskTemplateComponent：任务模板组件
---   - SignInEventComponent：签到事件组件
---   - GiftPackComponent：礼包组件
---   - RankingListComponent：排行榜组件
---   - ShopV2Component：商店组件 V2
---
--- 依赖模块：
---   - Delegate：事件委托
---   - UGCGameData：游戏数据
---
--- 作者：UGC Team
--- ================================================================================

---@class UGCPlayerController_C:BP_UGCPlayerController_C
---@field LotteryComponent LotteryComponent_C
---@field TaskTemplateComponent TaskTemplateComponent_C
---@field SignInEventComponent SignInEventComponent_C
---@field GiftPackComponent GiftPackComponent_C
---@field RankingListComponent RankingListComponent_C
---@field ShopV2Component ShopV2Component_C

-- Edit Below--

-- 引入依赖模块
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

-- 模块定义
local UGCPlayerController = {}

-- ================================================================================
-- 常量定义
-- ================================================================================

-- 队伍经验分享比例：当玩家吞噬尸体获得经验时，队伍成员可获得的分享经验比例（10%）
local TEAM_ABSORB_EXP_SHARE_RATE = 0.1

-- ================================================================================
-- 工具函数
-- ================================================================================

-- 安全检查对象是否有效（带异常保护）
-- 使用 pcall 包装 IsObjectValid 调用，防止因对象已销毁导致的异常
-- @param obj 待检查的对象
-- @return boolean 有效返回 true，否则返回 false
local function IsObjectValidSafe(obj)
    -- 防御性检查：nil 对象直接返回 false
    if not obj then
        return false
    end

    -- 如果工具类可用，使用安全调用方式
    if UGCObjectUtility and UGCObjectUtility.IsObjectValid then
        local okValid, validOrErr = pcall(function()
            return UGCObjectUtility.IsObjectValid(obj)
        end)

        -- 调用成功，检查返回值
        if okValid then
            return validOrErr == true
        end

        -- 调用异常，记录错误日志
        ugcprint("[UGCPlayerController] IsObjectValid 调用异常: " .. tostring(validOrErr))
        return false
    end

    -- 工具类不可用时，默认认为有效
    return true
end

-- 根据 PlayerKey 获取玩家名称
-- 优先级：Pawn 上的玩家名 > PlayerState 上的玩家名 > PlayerKey 字符串
-- @param PlayerKey 玩家唯一标识键
-- @return string 玩家名称，查找失败时返回 PlayerKey 字符串
local function GetPlayerNameByPlayerKey(PlayerKey)
    -- 参数校验：PlayerKey 必须为正数
    if not PlayerKey or PlayerKey <= 0 then
        return tostring(PlayerKey)
    end

    -- 尝试从 Pawn 获取玩家名（优先级最高）
    local Pawn = UGCGameSystem.GetPlayerPawnByPlayerKey(PlayerKey)
    if Pawn and UGCObjectUtility.IsObjectValid(Pawn) then
        local PlayerName = UGCPawnAttrSystem.GetPlayerName(Pawn)
        if PlayerName and PlayerName ~= "" then
            return PlayerName
        end
    end

    -- 降级：从 PlayerState 获取玩家名
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerKey(PlayerKey)
    if PlayerState and PlayerState.PlayerName and PlayerState.PlayerName ~= "" then
        return PlayerState.PlayerName
    end

    -- 所有方式都失败，返回 PlayerKey 字符串作为兜底
    return tostring(PlayerKey)
end

-- ================================================================================
-- 副本系统辅助函数
-- ================================================================================

-- 定位 SingleModeTimeOut Actor
-- 用于超时结算场景，通过类路径查找场景中唯一存在的超时触发器
-- @param worldContextObject 世界上下文对象（可选，默认使用 GameState 或 GameMode）
-- @return actor, classPath 找到的 Actor 及其类路径，未找到返回 nil
local function ResolveSingleModeTimeOutActor(worldContextObject)
    -- 获取超时 Actor 的类路径
    local timeoutClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/SingleModeTimeOut.SingleModeTimeOut_C")
    if not timeoutClassPath or timeoutClassPath == "" then
        ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 失败：SingleModeTimeOut 类路径为空")
        return nil, nil
    end

    local classPathCandidates = { timeoutClassPath }

    -- 确定世界上下文对象
    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 失败：WorldContextObject 为空")
        return nil, nil
    end

    -- 检查工具类是否可用
    if not UGCActorComponentUtility or not UGCActorComponentUtility.GetAllActorsOfClass then
        ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 失败：UGCActorComponentUtility.GetAllActorsOfClass 不可用")
        return nil, nil
    end

    -- 遍历候选类路径，查找有效 Actor
    for _, classPath in ipairs(classPathCandidates) do
        -- 加载类
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

        -- 查找该类的所有 Actor
        local okGetActor, actorListOrErr = pcall(function()
            return UGCActorComponentUtility.GetAllActorsOfClass(worldContext, actorClass)
        end)

        if not okGetActor then
            ugcprint("[UGCPlayerController] ResolveSingleModeTimeOutActor 获取Actor失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
            goto continue_classpath
        end

        -- 遍历 Actor 列表，返回第一个有效对象
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

-- 停止并清理所有 Single1 TriggerBox（停刷清怪）
-- 在副本结算或超时时调用，通知所有刷怪触发器停止生成怪物并清理已存在的怪物
-- @param worldContextObject 世界上下文对象（可选）
-- @param reasonTag 清理原因标签，用于日志记录
-- @return cleanedCount 实际清理的触发器数量
local function StopAndCleanSingle1TriggerBoxesForServer(worldContextObject, reasonTag)
    local cleanedByGlobal = 0

    -- 首先尝试调用全局清理函数（优先）
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

    -- 全局清理成功，直接返回
    if cleanedByGlobal > 0 then
        return cleanedByGlobal
    end

    -- 获取 TriggerBox_Single1 的类路径
    local triggerClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/TriggerBox_Single1.TriggerBox_Single1_C")
    if not triggerClassPath or triggerClassPath == "" then
        ugcprint("[UGCPlayerController] StopAndCleanSingle1 失败：TriggerBox_Single1 类路径为空")
        return 0
    end

    local classPathCandidates = { triggerClassPath }

    -- 确定世界上下文
    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[UGCPlayerController] StopAndCleanSingle1 失败：WorldContextObject 为空")
        return 0
    end

    -- 检查工具类
    if (not UGCActorComponentUtility) or (not UGCActorComponentUtility.GetAllActorsOfClass) then
        ugcprint("[UGCPlayerController] StopAndCleanSingle1 失败：GetAllActorsOfClass 不可用")
        return 0
    end

    local cleanedCount = 0

    -- 遍历并清理所有触发器
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
                        -- 检查触发器有效性及 StopAndCleanAll 方法
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

    -- 记录清理结果
    if cleanedCount > 0 then
        ugcprint("[UGCPlayerController] 已停止并清怪 TriggerBox_Single1 数量=" .. tostring(cleanedCount) .. ", reason=" .. tostring(reasonTag))
    else
        ugcprint("[UGCPlayerController] 未找到可处理的 TriggerBox_Single1, reason=" .. tostring(reasonTag))
    end

    return cleanedCount
end

-- ================================================================================
-- 剑阁系统常量与辅助函数
-- ================================================================================

-- 剑阁多实例映射表：key=玩家实例键(P_PlayerKey 或 PC_Controller), value=分配的实例索引
local JiangeInstancePlayerMap = JiangeInstancePlayerMap or {}

-- 下一个分配的实例索引（轮询分配）
local JiangeInstanceNextIndex = JiangeInstanceNextIndex or 1

-- 剑阁传送时 Z 轴偏移量（防止卡在地形中）
local JIANGE_ENTRY_Z_OFFSET = 120

-- 剑阁传送失败时的备用传送点坐标（fallback）
local JIANGE_FALLBACK_ENTRY = {
    X = 268737.21875,
    Y = 238584.484375,
    Z = 1118.539795,
}

-- 定位剑阁场景中的所有触发器
-- 剑阁可能有多个楼层，每个楼层有独立的 TriggerBox_jiange
-- @param worldContextObject 世界上下文对象（可选）
-- @return table 有效的触发器数组，按名称排序
local function ResolveJiangeTriggerBoxes(worldContextObject)
    -- 获取剑阁触发器类路径
    local classPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/Data/MobPoint/TriggerBox_jiange.TriggerBox_jiange_C")
    if not classPath or classPath == "" then
        return {}
    end

    -- 确定世界上下文
    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        return {}
    end

    -- 检查工具类
    if not UGCActorComponentUtility or not UGCActorComponentUtility.GetAllActorsOfClass then
        return {}
    end

    -- 加载触发器类
    local triggerClass = UGCObjectUtility.LoadClass(classPath)
    if not triggerClass then
        return {}
    end

    -- 查找所有触发器
    local okGetActors, actorListOrErr = pcall(function()
        return UGCActorComponentUtility.GetAllActorsOfClass(worldContext, triggerClass)
    end)
    if not okGetActors then
        ugcprint("[UGCPlayerController] ResolveJiangeTriggerBoxes failed: " .. tostring(actorListOrErr))
        return {}
    end

    -- 过滤有效触发器
    local actorList = actorListOrErr
    local validBoxes = {}
    if actorList and #actorList > 0 then
        for _, actor in pairs(actorList) do
            if IsObjectValidSafe(actor) then
                table.insert(validBoxes, actor)
            end
        end
    end

    -- 按名称排序（确保楼层顺序一致）
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

-- ================================================================================
-- 队伍系统全局数据
-- ================================================================================

-- 全局队长数据表：key=TeamID, value=队长 PlayerKey
-- 用于记录每个队伍的队长是谁，以便进行队伍管理操作
TeamCaptainData = TeamCaptainData or {}

-- ================================================================================
-- 生命周期函数
-- ================================================================================

-- 玩家控制器开始游戏时被调用
-- 职责：
--   1. 延迟 2 秒后检查是否首次登录，若是则发放初始装备
--   2. 本地控制器创建 UI：MainWidget 和 MMainUI
--   3. 注册商品购买回调
--   4. 延迟 3 秒检测当前模式 ID 和关卡阶段
function UGCPlayerController:ReceiveBeginPlay()
    --ugcprint("========== UGCPlayerController:ReceiveBeginPlay started ==========")

    -- 调用父类实现
    UGCPlayerController.SuperClass.ReceiveBeginPlay(self)

    -- ========================================================================
    -- 初始装备检查与发放（仅服务器执行）
    -- ========================================================================
    -- 延迟 2 秒执行，等待游戏系统完全初始化
    local OBTimerDelegate = ObjectExtend.CreateDelegate(self,
        function()
            if self:HasAuthority() == true then
                -- 获取玩家 UID 和存档数据
                local Uid = UGCGameSystem.GetUIDByPlayerController(self)
                local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)

                -- 检查是否首次进入游戏（未领取过初始装备）
                if not Data.HasReceivedInitialEquipment then
                    --ugcprint("[UGCPlayerController] First login, granting initial equipment")

                    -- 获取玩家 Pawn 并添加初始装备（物品 ID: 8310105）
                    local PlayerPawn = self:GetPlayerCharacterSafety()
                    UGCBackpackSystemV2.AddItemV2(PlayerPawn, 8310105, 1)

                    -- 标记已领取并保存存档
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

    -- ========================================================================
    -- UI 创建（仅本地控制器执行）
    -- ========================================================================
    if self:IsLocalController() then
        --ugcprint("UGCPlayerController: This is local controller, creating UI")

        -- 创建 MainWidget（层 1000）
        local mainWidget = UGCGameData.GetUI(self, "MainWidget")
        if mainWidget then
            self.MainWidget = mainWidget
            mainWidget:AddToViewport(1000)
            --ugcprint("UGCPlayerController: MainWidget added to viewport, layer 1000")
        else
            --ugcprint("UGCPlayerController: Error - unable to create MainWidget")
        end

        -- 创建 MMainUI（层 1100）- 主界面 UI
        local mainUI = UGCGameData.GetUI(self, "MMainUI")
        if mainUI then
            self.MMainUI = mainUI
            mainUI:AddToViewport(1100)
            --ugcprint("UGCPlayerController: MMainUI added to viewport, layer 1100")

            -- 检查 MMainUI 的 TASK 组件
            if mainUI.TASK then
                --ugcprint("UGCPlayerController: MMainUI.TASK component exists")
            else
                --ugcprint("UGCPlayerController: Warning - MMainUI.TASK component missing")
            end
        else
            --ugcprint("UGCPlayerController: Error - unable to create MMainUI")
        end

        -- 注册商品购买结果回调
        self:RegisterBuyProductDelegate()
    else
        --ugcprint("UGCPlayerController: Not local controller, skip UI creation")
    end

    --ugcprint("========== UGCPlayerController:ReceiveBeginPlay completed ==========")

    -- ========================================================================
    -- 延迟模式 ID 检测
    -- ========================================================================
    -- 延迟 3 秒后检测当前游戏模式 ID 和关卡阶段，用于调试和配置加载
    if self:IsLocalController() then
        UGCTimerUtility.CreateLuaTimer(
            3.0, -- 3 秒延迟
            function()
                local currentModeID = UGCMultiMode.GetModeID()
                local currentStage = UGCLevelFlowSystem.GetCurrentLevelStage(self)

                -- ugcprint("[UGCPlayerController] ========== 3s check ==========")
                -- ugcprint("[UGCPlayerController] Current ModeID: " .. tostring(currentModeID))
                -- ugcprint("[UGCPlayerController] Current level stage: " .. tostring(currentStage))

                -- 副本模式 1002：打印副本配置信息
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

                -- 打印当前模式提示
                if currentModeID == -99999 or currentModeID == 0 then
                    -- ugcprint("[UGCPlayerController] Hint: Currently in lobby mode")
                else
                    -- ugcprint("[UGCPlayerController] Currently in mode: " .. tostring(currentModeID) .. ", stage: " .. tostring(currentStage))
                end
                -- ugcprint("[UGCPlayerController] ================================")
            end,
            false, -- 不循环
            "CheckModeID_Timer"  -- 定时器名称
        )
    end
end

-- ================================================================================
-- 购买系统
-- ================================================================================

-- 注册商品购买结果委托
-- 延迟 1 秒执行，等待商品操作管理器初始化
function UGCPlayerController:RegisterBuyProductDelegate()
    UGCTimerUtility.CreateLuaTimer(
        1,
        function()
            -- 获取全局商品操作管理器
            local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
            if CommodityOperationManager then
                -- 添加购买结果监听回调
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

-- 商品购买结果回调处理
-- 职责：
--   1. 解析购买结果
--   2. 计算消费金额
--   3. 成功时更新消费统计（消费次数、消费金额）
-- @param Result 购买结果数据表
function UGCPlayerController:OnBuyProductResult(Result)
    -- ugcprint("[UGCPlayerController] Buy result callback received")

    -- 打印结果详情（调试用）
    if Result then
        for k, v in pairs(Result) do
            -- ugcprint("[UGCPlayerController] Result." .. tostring(k) .. " = " .. tostring(v))
        end
    end

    -- 检查购买是否成功
    if Result and Result.bSucceeded then
        -- 计算消费金额
        local spendAmount = 0
        if Result.TotalPrice and Result.TotalPrice > 0 then
            -- 优先使用总价字段
            spendAmount = Result.TotalPrice
        elseif Result.ProductID then
            -- 根据产品 ID 查找单价并计算
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

        -- 获取 PlayerState 并上报消费统计
        local playerState = UGCGameSystem.GetPlayerStateByPlayerController(self)
        if playerState then
            -- 上报消费金额
            UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddSpendCount", spendAmount)
            -- 上报消费次数
            UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddShopBuyCount")
        end
    else
        -- ugcprint("[UGCPlayerController] Purchase failed or result invalid")
    end
end

-- ================================================================================
-- RPC 函数声明
-- ================================================================================

-- 获取可用的 Server RPC 列表
-- 用于编辑器显示和网络调试
function UGCPlayerController:GetAvailableServerRPCs()
    return "Server_TeleportPlayer", "Server_EnterJiangeInstance", "Server_RestoreFullHealth", "Server_DestroyNearbyCorpses", "Server_SetDirectExpEnabled", "Server_SetAutoTunshiEnabled", "Server_SetAutoPickupEnabled", "Server_SetBloodlineEnabled", "Server_NotifyLevelRewardFinish", "Server_NotifyTimeOutFinish", "Server_GiveRewards", "Server_SendTeamInvite", "Server_RespondTeamInvite", "Server_RequestJoinTeam", "Server_AcceptJoinRequest", "Server_KickFromTeam", "Server_LeaveTeam", "Server_ResumeTriggerBoxSpawning", "Server_BatchOpenBaoxiang", "Server_RequestTeamPanelPlayers"
end

-- 获取可用的 Client RPC 列表
-- 用于编辑器显示和网络调试
function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_ShowTunshiSuccess", "Client_SetPlayerRotation", "Client_ShowSettlementUI", "Client_ShowSettlementTipUI", "Client_ShowSettlement2UI", "Client_OnPlayerLevelUp", "Client_ReceiveTeamInvite", "Client_TeamInviteResult", "Client_ReceiveJoinRequest", "Client_RefreshTeamUI", "Client_OnKickedFromTeam", "Client_ShowTaSettlementUI", "Client_UpdateJiangeFloor", "Client_OnP1Died", "Client_StartCountdown", "Client_SyncJiangeData", "Client_SyncShenyinData", "Client_ShowBaoxiangNumchoose", "Client_BeginTeamPanelPlayers", "Client_AddTeamPanelPlayer", "Client_EndTeamPanelPlayers", "Client_ShowBaoxiangReward", "Client_SyncJiangeRewardData", "Client_OnJiangeDailyClaimResult", "Client_OnJiangeFloorClaimResult", "Client_OnJiangeForgeConsumeResult", "Client_OnChongzhiClaimResult", "Client_OnTalentUpgradeResult", "Client_OnManualPointResult", "Client_RestoreMainUIAfterRespawn", "Client_OnExpBlockedByRebirth", "Client_SyncMobKillCount", "Client_SyncPlayerKillCount"
end

-- ================================================================================
-- 吞噬系统 Client RPC
-- ================================================================================

-- Client RPC：显示吞噬成功提示
-- 服务器在玩家成功吞噬尸体后调用，在客户端显示经验获取提示
-- @param totalExp 吞噬获得的总经验值
function UGCPlayerController:Client_ShowTunshiSuccess(totalExp)
    --ugcprint("[Client] Client_ShowTunshiSuccess received, exp value: " .. tostring(totalExp))

    -- 仅本地控制器处理
    if not self:IsLocalController() then
        return
    end

    -- 调用 MMainUI 的 tunshitip 显示提示
    if self.MMainUI and self.MMainUI.tunshitip then
        if self.MMainUI.tunshitip.ShowTips then
            self.MMainUI.tunshitip:ShowTips("吞噬成功 +" .. tostring(totalExp))
            --ugcprint("[Client] Showing absorb tip: Absorb success +" .. tostring(totalExp))
        end
    end
end

-- ================================================================================
-- 玩家生命值与传送系统
-- ================================================================================

-- Server RPC：恢复玩家满血
-- 服务器收到请求后，将玩家生命值恢复至最大值
function UGCPlayerController:Server_RestoreFullHealth()
    --ugcprint("[Server] Server_RestoreFullHealth request received")

    local ok, err = pcall(function()
        local PlayerPawn = self.Pawn or self:K2_GetPawn()
        if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
            --ugcprint("[Server] Error: unable to get player Pawn")
            return
        end

        -- 获取最大生命值属性并设置为满血
        local maxHealth = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'HealthMax') or 100
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, 'Health', maxHealth)
        --ugcprint("[Server] Health set to: " .. tostring(maxHealth))
    end)

    if not ok then
        --ugcprint("[Server] Server_RestoreFullHealth error: " .. tostring(err))
    end
end

-- Server RPC：进入剑阁副本（多实例分配）
-- 职责：
--   1. 为玩家分配剑阁实例索引（轮询分配到不同 TriggerBox）
--   2. 获取目标传送点坐标
--   3. 执行传送
-- 剑阁可能有多层，每层有独立的触发器，实现负载均衡
function UGCPlayerController:Server_EnterJiangeInstance()
    local ok, err = pcall(function()
        -- 计算玩家实例键（使用 PlayerKey 或 Controller 地址）
        local playerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
        local playerInstanceKey = nil
        if playerKey and tonumber(playerKey) and tonumber(playerKey) > 0 then
            playerInstanceKey = "P_" .. tostring(playerKey)
        else
            playerInstanceKey = "PC_" .. tostring(self)
        end

        -- 获取剑阁触发器列表
        local triggerBoxes = ResolveJiangeTriggerBoxes(self)
        if not triggerBoxes or #triggerBoxes == 0 then
            ugcprint("[UGCPlayerController] Server_EnterJiangeInstance fallback: no TriggerBox_jiange found")
            -- 找不到触发器，使用备用传送点
            self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
            return
        end

        -- 检查玩家是否已有分配的实例
        local instanceIndex = JiangeInstancePlayerMap[playerInstanceKey]
        if not instanceIndex or instanceIndex < 1 or instanceIndex > #triggerBoxes then
            -- 无分配或分配无效，分配新实例（轮询）
            instanceIndex = JiangeInstanceNextIndex
            JiangeInstancePlayerMap[playerInstanceKey] = instanceIndex
            JiangeInstanceNextIndex = JiangeInstanceNextIndex + 1
            -- 超过触发器数量时重置
            if JiangeInstanceNextIndex > #triggerBoxes then
                JiangeInstanceNextIndex = 1
            end
            ugcprint("[UGCPlayerController] Jiange instance assigned: player=" .. tostring(playerInstanceKey) .. ", index=" .. tostring(instanceIndex))
        end

        -- 获取目标触发器
        local targetTrigger = triggerBoxes[instanceIndex]
        if not targetTrigger or not IsObjectValidSafe(targetTrigger) then
            ugcprint("[UGCPlayerController] Server_EnterJiangeInstance fallback: target trigger invalid")
            self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
            return
        end

        -- 获取目标位置
        local targetLocation = targetTrigger:K2_GetActorLocation()
        if not targetLocation then
            ugcprint("[UGCPlayerController] Server_EnterJiangeInstance fallback: target location invalid")
            self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
            return
        end

        -- 执行传送，Z 轴加上偏移量防止卡地形
        self:Server_TeleportPlayer(targetLocation.X, targetLocation.Y, targetLocation.Z + JIANGE_ENTRY_Z_OFFSET)
    end)

    if not ok then
        ugcprint("[UGCPlayerController] Server_EnterJiangeInstance error: " .. tostring(err))
        -- 异常时使用备用传送点
        self:Server_TeleportPlayer(JIANGE_FALLBACK_ENTRY.X, JIANGE_FALLBACK_ENTRY.Y, JIANGE_FALLBACK_ENTRY.Z)
    end
end

-- Server RPC：传送玩家到指定坐标
-- 支持带旋转角度的传送（Yaw）
-- @param X Y Z 目标坐标
-- @param Yaw 目标朝向角度（可选）
function UGCPlayerController:Server_TeleportPlayer(X, Y, Z, Yaw)
    --ugcprint("[Server] Server_TeleportPlayer request received")
    --ugcprint("[Server] Target location: X=" .. tostring(X) .. " Y=" .. tostring(Y) .. " Z=" .. tostring(Z) .. " Yaw=" .. tostring(Yaw))

    local ok, err = pcall(function()
        local PlayerPawn = nil

        -- 多种方式获取 Pawn（防御性处理）
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

        -- 构建目标位置向量
        local TargetLocation = Vector.New(X, Y, Z)

        -- 如果指定了 Yaw，同时设置旋转
        if Yaw and Yaw ~= 0 then
            -- 创建旋转体：Pitch=0, Roll=0, 只设置 Yaw
            local newRotation = Rotator.New(0, Yaw, 0)

            -- 同时设置位置和旋转
            PlayerPawn:K2_SetActorLocationAndRotation(TargetLocation, newRotation, false, nil, true)

            --ugcprint("[Server] Teleport location and rotation success! Yaw=" .. Yaw)

            -- 同步客户端旋转
        else
            -- 只设置位置
            PlayerPawn:K2_SetActorLocation(TargetLocation, false, nil, true)
            --ugcprint("[Server] Teleport location success")
        end
    end)

    if not ok then
        --ugcprint("[Server] Server_TeleportPlayer error: " .. tostring(err))
    end
end

-- Client RPC：设置玩家朝向
-- 服务器传送玩家后，同步客户端的朝向
-- @param Yaw 目标朝向角度
function UGCPlayerController:Client_SetPlayerRotation(Yaw)
    --ugcprint("[Client] Client_SetPlayerRotation received: Yaw=" .. tostring(Yaw))

    local PlayerPawn = self.Pawn or self:K2_GetPawn()
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local newRotation = Rotator.New(0, Yaw, 0)
        PlayerPawn:K2_SetActorRotation(newRotation, false)

        -- 同步控制器旋转
        if self.SetControlRotation then
            self:SetControlRotation(newRotation)
        end

        --ugcprint("[Client] Client rotation set: Yaw=" .. Yaw)
    end
end

-- ================================================================================
-- 吞噬系统
-- ================================================================================

-- Server RPC：吞噬附近尸体并获取经验
-- 职责：
--   1. 遍历范围内的死亡怪物
--   2. 计算经验值（考虑 Ecexp 加成）
--   3. 通知客户端显示吞噬成功
--   4. 分配经验给队友（10% 比例）
--   5. 播放吞噬特效
function UGCPlayerController:Server_DestroyNearbyCorpses()
    --ugcprint("[Server] Server_DestroyNearbyCorpses request received")

    -- 权限检查：仅服务器可执行
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

        -- 获取玩家当前位置
        local playerLocation = PlayerPawn:K2_GetActorLocation()

        -- 获取死亡怪物列表
        local deadMonsters = UGCGameData.DeadMonsters
        --ugcprint("[Server] Dead monsters count: " .. #deadMonsters)

        local destroyedCount = 0
        local totalExp = 0
        local remainingMonsters = {}

        -- 遍历死亡怪物列表
        for i, monster in ipairs(deadMonsters) do
            if monster and UGCObjectUtility.IsObjectValid(monster) then
                local monsterLocation = monster:K2_GetActorLocation()

                -- 计算距离（欧几里得距离）
                local diffX = playerLocation.X - monsterLocation.X
                local diffY = playerLocation.Y - monsterLocation.Y
                local diffZ = playerLocation.Z - monsterLocation.Z
                local distance = math.sqrt(diffX*diffX + diffY*diffY + diffZ*diffZ)

                -- 检查是否在吞噬范围内（1000 单位）
                if distance < 1000 then
                    if monster.MonsterID then
                        local monsterConfig = UGCGameData.GetMonsterConfig(monster.MonsterID)
                        if monsterConfig and monsterConfig.KillExp and monsterConfig.KillExp > 0 then
                            -- 获取经验加成属性（Ecexp：经验加成百分比 / 100）
                            local ecexp = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'Ecexp') or 0

                            -- 计算最终经验值：
                            -- 基础经验 * (1 + 0.5固定加成 + Ecexp加成)
                            local baseExp = monsterConfig.KillExp
                            local bonusRate = 1 + 0.5 + (ecexp / 100)
                            local monsterExp = math.floor(baseExp * bonusRate)
                            totalExp = totalExp + monsterExp

                            --ugcprint("[Server] Absorb monster ID=" .. monster.MonsterID .. ", baseExp: " .. baseExp .. ", Ecexp: " .. ecexp .. "%, bonusRate: " .. bonusRate .. ", finalExp: " .. monsterExp)

                            -- 通知客户端显示吞噬成功提示
                            UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowTunshiSuccess", monsterExp)
                        end
                    end

                    -- 隐藏并销毁怪物尸体
                    monster:SetActorHiddenInGame(true)
                    monster:K2_DestroyActor()
                    destroyedCount = destroyedCount + 1
                else
                    -- 超出范围，保留到下次检测
                    table.insert(remainingMonsters, monster)
                end
            end
        end

        -- 更新死亡怪物列表（移除已处理的）
        UGCGameData.DeadMonsters = remainingMonsters
        --ugcprint("[Server] Destroyed " .. destroyedCount .. " corpses, remaining " .. #remainingMonsters)

        -- 发放总经验
        if totalExp > 0 then
            --ugcprint("[Server] Absorb total exp: " .. totalExp)

            -- 添加经验到玩家
            if PlayerState.AddExp then
                PlayerState:AddExp(totalExp)
                --ugcprint("[Server] Exp granted")
            end

            -- 队伍经验分享：将 10% 经验分配给队友
            local teamShareExp = math.floor(totalExp * TEAM_ABSORB_EXP_SHARE_RATE)
            if teamShareExp > 0 then
                local teamID = UGCPawnAttrSystem.GetTeamID(PlayerPawn)
                local teamPlayerStates = teamID and UGCTeamSystem.GetPlayerStatesByTeamID(teamID) or nil
                if teamPlayerStates then
                    for _, teammateState in ipairs(teamPlayerStates) do
                        -- 跳过自己
                        if teammateState and teammateState ~= PlayerState and teammateState.AddExp then
                            teammateState:AddExp(teamShareExp)
                        end
                    end
                end
            end

            -- 添加吞噬特效 buff
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

-- ================================================================================
-- 玩家属性开关设置
-- ================================================================================

-- Server RPC：设置直接经验获取模式
-- 委托给 PlayerState 处理
-- @param isEnabled 是否启用
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

    -- 委托给 PlayerState 处理
    if PlayerState.Server_SetDirectExpEnabled then
        PlayerState:Server_SetDirectExpEnabled(isEnabled)
    end
end

-- Server RPC：设置血脉模式
-- 委托给 PlayerState 处理
-- @param isEnabled 是否启用
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

    -- 委托给 PlayerState 处理
    if PlayerState.Server_SetBloodlineEnabled then
        PlayerState:Server_SetBloodlineEnabled(isEnabled)
    end
end

-- Server RPC：设置自动吞噬模式
-- 委托给 PlayerState 处理
-- @param isEnabled 是否启用
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

-- Server RPC：设置自动拾取模式
-- 委托给 PlayerState 处理
-- @param isEnabled 是否启用
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

-- ================================================================================
-- 结算系统
-- ================================================================================

-- ============ Settlement UI Functions ============

--- Client RPC：显示关卡结算界面
--- 流程：
---   1. 停止倒计时
---   2. 异步创建 Settlement UI
---   3. 设置确定按钮回调（调用 Server_GiveRewards）
---   4. 启动全局看门狗（10 秒超时）
---   5. 启动 UI 局部看门狗（8 秒超时自动关闭）
function UGCPlayerController:Client_ShowSettlementUI()
    ugcprint("[UGCPlayerController] Client_ShowSettlementUI 被调用")

    -- 检查是否为本地控制器
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

    -- 停止主界面倒计时
    local okStopCountdown, stopCountdownErr = pcall(function()
        if self.MMainUI and self.MMainUI.StopCountdown then
            self.MMainUI.CountdownTimeoutTriggered = true
            self.MMainUI:StopCountdown()
        end
    end)
    if not okStopCountdown then
        ugcprint("[UGCPlayerController] StopCountdown 执行失败: " .. tostring(stopCountdownErr))
    end

    -- 获取结算 UI 路径
    local settlementPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement.Settlement_C')
    ugcprint("[UGCPlayerController] Settlement UI 路径: " .. tostring(settlementPath))

    -- 保存 PlayerController 引用，供回调函数使用（避免闭包问题）
    local PlayerController = self
    local bHandled = false

    -- 结算完成处理函数
    -- @param reason 处理原因（调试用）
    -- @param needGiveRewards 是否需要发放奖励
    local function HandleSettlementFinish(reason, needGiveRewards)
        -- 防止重复触发
        if bHandled then
            ugcprint("[UGCPlayerController] Settlement 已处理，忽略重复触发, reason=" .. tostring(reason))
            return
        end

        bHandled = true
        ugcprint("[UGCPlayerController] Settlement 触发完成流程, reason=" .. tostring(reason) .. ", needGiveRewards=" .. tostring(needGiveRewards))

        -- 需要发放奖励时调用服务器
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

        -- 通知服务器结算完成
        local okNotifyFinish, notifyFinishErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyLevelRewardFinish")
        end)

        if okNotifyFinish then
            ugcprint("[UGCPlayerController] 已调用 Server_NotifyLevelRewardFinish")
        else
            ugcprint("[UGCPlayerController] 调用 Server_NotifyLevelRewardFinish 失败: " .. tostring(notifyFinishErr))
        end
    end

    -- ========================================================================
    -- 全局看门狗：10 秒超时兜底
    -- 防止异步回调丢失导致结算流程卡死
    -- ========================================================================
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

    -- 异步创建结算 UI
    local okCreateWidgetAsync, createWidgetAsyncErr = pcall(function()
        UGCWidgetManagerSystem.CreateWidgetAsync(settlementPath, function(Widget)
            ugcprint("[UGCPlayerController] Settlement CreateWidgetAsync 回调触发")

            if Widget then
                ugcprint("[UGCPlayerController] Settlement UI 创建成功")

                -- 设置确定按钮回调
                -- 注意：UI 按钮本身也会调用 Server_GiveRewards，这里只处理完成通知
                Widget.OnSureClicked = function()
                    -- Settlement widget sure click already calls Server_GiveRewards.
                    HandleSettlementFinish("SureClicked", false)
                end

                -- 添加到视口显示
                Widget:AddToViewport(6000)
                ugcprint("[UGCPlayerController] Settlement UI 已添加到视口")

                -- =================================================================
                -- UI 局部看门狗：8 秒后自动关闭并发放奖励
                -- 处理玩家点击无响应的情况
                -- =================================================================
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

--- Client RPC：显示结算提示界面并开始匹配
--- 用于关卡完成后的多人匹配流程
--- 流程：
---   1. 停止倒计时
---   2. 异步创建 SettlementTip UI（一直显示）
---   3. 监听匹配成功事件，匹配成功后隐藏 UI
---   4. 调用 RequestMatch 请求进入模式 1001
function UGCPlayerController:Client_ShowSettlementTipUI()
    ugcprint("[UGCPlayerController] Client_ShowSettlementTipUI 被调用")

    -- 检查是否为本地控制器
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

    -- 停止主界面倒计时
    local okStopCountdown, stopCountdownErr = pcall(function()
        if self.MMainUI and self.MMainUI.StopCountdown then
            self.MMainUI.CountdownTimeoutTriggered = true
            self.MMainUI:StopCountdown()
        end
    end)
    if not okStopCountdown then
        ugcprint("[UGCPlayerController] SettlementTip StopCountdown 执行失败: " .. tostring(stopCountdownErr))
    end

    -- 获取结算提示 UI 路径
    local settlementTipPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/SettlementTip.SettlementTip_C')
    ugcprint("[UGCPlayerController] SettlementTip UI 路径: " .. tostring(settlementTipPath))

    -- 保存 PlayerController 引用
    local PlayerController = self

    -- 异步创建 SettlementTip UI（仅负责展示，不阻塞匹配流程）
    UGCWidgetManagerSystem.CreateWidgetAsync(settlementTipPath, function(Widget)
        ugcprint("[UGCPlayerController] SettlementTip CreateWidgetAsync 回调被调用")

        if Widget then
            ugcprint("[UGCPlayerController] 成功创建 SettlementTip UI")
            Widget:AddToViewport(6000)
            ugcprint("[UGCPlayerController] SettlementTip UI 已添加到视口，将一直显示")
        else
            ugcprint("[UGCPlayerController] 创建 SettlementTip UI 失败，Widget为nil")
        end

        -- 检查匹配模块是否可用
        if UGCMultiMode then
            -- =================================================================
            -- 监听匹配成功事件
            -- 匹配成功后自动隐藏提示 UI
            -- =================================================================
            UGCMultiMode.NotifyMatchSucceededDelegate:Add(function()
                ugcprint("[UGCPlayerController] 匹配成功！隐藏 SettlementTip UI")
                if Widget and UGCObjectUtility.IsObjectValid(Widget) then
                    Widget:RemoveFromParent()
                end
            end, PlayerController)

            -- 重试标记（防止无限重试）
            local hasRetried = false

            -- 执行匹配请求
            -- @param tag 请求标签（First/RetryByCallback/RetryByReturn）
            local function DoRequestMatch(tag)
                ugcprint("[UGCPlayerController] RequestMatch(1001) 开始调用, tag=" .. tostring(tag))

                -- 调用匹配接口
                local bRequestSuccess = UGCMultiMode.RequestMatch(1001, function(arg1, arg2)
                    -- 解析回调结果
                    local bSuccess = false
                    if type(arg1) == "boolean" then
                        bSuccess = arg1
                    elseif type(arg2) == "boolean" then
                        bSuccess = arg2
                    end

                    ugcprint("[UGCPlayerController] RequestMatch(1001) 回调, tag=" .. tostring(tag) .. ", arg1=" .. tostring(arg1) .. ", arg2=" .. tostring(arg2) .. ", parsedSuccess=" .. tostring(bSuccess))

                    -- 匹配失败时，延迟 1.5 秒重试一次
                    if (not bSuccess) and (not hasRetried) then
                        hasRetried = true
                        ugcprint("[UGCPlayerController] RequestMatch 回调失败，1.5秒后重试一次")
                        UGCTimerUtility.CreateLuaTimer(1.5, function()
                            DoRequestMatch("RetryByCallback")
                        end, false, "SettlementTipMatchRetry")
                    end
                end, PlayerController)

                ugcprint("[UGCPlayerController] RequestMatch(1001) 返回值, tag=" .. tostring(tag) .. ": " .. tostring(bRequestSuccess))

                -- 返回 false 时，延迟 1.5 秒重试一次
                if (not bRequestSuccess) and (not hasRetried) then
                    hasRetried = true
                    ugcprint("[UGCPlayerController] RequestMatch 返回 false，1.5秒后重试一次")
                    UGCTimerUtility.CreateLuaTimer(1.5, function()
                        DoRequestMatch("RetryByReturn")
                    end, false, "SettlementTipMatchRetry")
                end
            end

            -- 首次匹配请求
            DoRequestMatch("First")
        else
            ugcprint("[UGCPlayerController] 错误：UGCMultiMode 不存在")
        end
    end)
end

--- Client RPC：显示超时结算界面（Settlement_2）
--- 用于关卡超时后的结算流程
--- 流程：
---   1. 停止倒计时
---   2. 异步创建 Settlement_2 UI
---   3. 设置确定按钮回调
---   4. 启动全局看门狗（8 秒超时）
function UGCPlayerController:Client_ShowSettlement2UI()
    ugcprint("[UGCPlayerController] Client_ShowSettlement2UI 被调用")

    -- 检查是否为本地控制器
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

    -- 停止主界面倒计时
    local okStopCountdown, stopCountdownErr = pcall(function()
        if self.MMainUI and self.MMainUI.StopCountdown then
            self.MMainUI.CountdownTimeoutTriggered = true
            self.MMainUI:StopCountdown()
        end
    end)
    if not okStopCountdown then
        ugcprint("[UGCPlayerController] Settlement_2 StopCountdown 执行失败: " .. tostring(stopCountdownErr))
    end

    -- 获取结算_2 UI 路径
    local settlement2Path = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Settlement_2.Settlement_2_C')
    ugcprint("[UGCPlayerController] Settlement_2 UI 路径: " .. tostring(settlement2Path))

    -- 保存 PlayerController 引用
    local PlayerController = self
    local bNotified = false

    -- 超时完成通知处理函数
    local function NotifyTimeOutFinish(reason)
        -- 防止重复触发
        if bNotified then
            ugcprint("[UGCPlayerController] Settlement_2 已通知，忽略重复触发, reason=" .. tostring(reason))
            return
        end

        bNotified = true
        ugcprint("[UGCPlayerController] Settlement_2 执行超时完成通知, reason=" .. tostring(reason))

        -- 调用服务器通知超时完成
        local okRPC, rpcErr = pcall(function()
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_NotifyTimeOutFinish")
        end)
        if okRPC then
            ugcprint("[UGCPlayerController] 已调用 Server_NotifyTimeOutFinish")
        else
            ugcprint("[UGCPlayerController] 调用 Server_NotifyTimeOutFinish 失败: " .. tostring(rpcErr))
        end
    end

    -- =================================================================
    -- 全局看门狗：8 秒超时兜底
    -- 防止 UI 回调丢失导致流程卡死
    -- =================================================================
    UGCTimerUtility.CreateLuaTimer(8.0, function()
        if bNotified then
            return
        end
        ugcprint("[UGCPlayerController] Settlement_2 全局看门狗触发")
        NotifyTimeOutFinish("GlobalWatchdog")
    end, false, "Settlement2GlobalWatchdog")

    -- 异步创建 Settlement_2 UI
    local okCreateWidgetAsync, createWidgetAsyncErr = pcall(function()
        UGCWidgetManagerSystem.CreateWidgetAsync(settlement2Path, function(Widget)
            if Widget then
                ugcprint("[UGCPlayerController] 成功创建 Settlement_2 UI, widget=" .. tostring(Widget))

                -- 设置确定按钮回调
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

--- Server RPC：通知关卡奖励完成
--- 职责：
---   1. 停刷清怪（避免匹配前继续刷怪）
---   2. 获取并调用 LevelRewardActor 的 OnFinish
---   3. 若 LevelRewardActor 不存在，直接显示 SettlementTip 兜底
function UGCPlayerController:Server_NotifyLevelRewardFinish()
    ugcprint("[Server] Server_NotifyLevelRewardFinish 被调用")

    -- 权限检查
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end

    -- 结算收口时统一停刷清怪
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
        -- 找不到 LevelRewardActor，直接显示 SettlementTip 防止卡死
        ugcprint("[Server] 警告：CurrentLevelRewardActor 不存在，直接显示 SettlementTip 防止卡死")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
    end
end

--- Server RPC：通知超时完成
--- 职责：
---   1. 停刷清怪
---   2. 定位并调用 TimeOutActor 的 OnFinish
---   3. 处理重复调用（防抖）
---   4. 若 TimeOutActor 不存在，直接显示 SettlementTip 兜底
function UGCPlayerController:Server_NotifyTimeOutFinish()
    -- 获取玩家标识（用于日志）
    local playerKey = "Unknown"
    local okPlayerKey, playerKeyOrErr = pcall(function()
        return UGCGameSystem.GetPlayerKeyByPlayerController(self)
    end)
    if okPlayerKey then
        playerKey = tostring(playerKeyOrErr)
    end

    ugcprint("[Server] Server_NotifyTimeOutFinish 被调用, playerKey=" .. tostring(playerKey))

    -- 权限检查
    if not self:HasAuthority() then
        --ugcprint("[Server] 错误：不是服务端，退出")
        return
    end

    -- 超时收口时统一停刷清怪
    StopAndCleanSingle1TriggerBoxesForServer(self, "TimeOutFinish")

    -- 防抖：检查是否正在处理中
    if self.bHandlingTimeOutFinishRPC then
        ugcprint("[Server] Server_NotifyTimeOutFinish 正在处理中，忽略重复调用, playerKey=" .. tostring(playerKey))
        return
    end

    self.bHandlingTimeOutFinishRPC = true

    -- 执行超时完成处理
    local okHandle, handleErr = pcall(function()
        local timeOutActor = self.CurrentTimeOutActor

        -- 尝试定位 TimeOutActor
        if (not timeOutActor) or (not IsObjectValidSafe(timeOutActor)) then
            local resolvedActor, classPath = ResolveSingleModeTimeOutActor(self)
            if resolvedActor then
                timeOutActor = resolvedActor
                ugcprint("[Server] CurrentTimeOutActor 为空，已通过类路径定位到 TimeOutActor: " .. tostring(classPath) .. ", playerKey=" .. tostring(playerKey))
            else
                ugcprint("[Server] 通过类路径定位 TimeOutActor 失败, playerKey=" .. tostring(playerKey))
            end
        end

        -- 调用 TimeOutActor 的 OnFinish
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
            -- 找不到 TimeOutActor，回退为显示 SettlementTip
            ugcprint("[Server] 警告：未找到 TimeOutActor，回退为直接显示 SettlementTip, playerKey=" .. tostring(playerKey))
            UnrealNetwork.CallUnrealRPC(self, self, "Client_ShowSettlementTipUI")
        end
    end)

    self.bHandlingTimeOutFinishRPC = false

    -- 处理异常
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

-- ================================================================================
-- 玩家属性同步 Client RPC
-- ================================================================================

--- Client RPC：玩家升级通知
--- @param newLevel 新等级
--- @param newMagic 新灵力值（同步到本地 PlayerState）
function UGCPlayerController:Client_OnPlayerLevelUp(newLevel, newMagic)
    if not self:IsLocalController() then
        return
    end
    -- 同步灵力值到本地 PlayerState
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState and playerState.GameData and newMagic then
        playerState.GameData.PlayerMagic = newMagic
    end
end

--- Client RPC：经验获取被重生上限阻挡
--- 当玩家经验达到重生上限时收到此通知，显示提示
function UGCPlayerController:Client_OnExpBlockedByRebirth()
    if not self:IsLocalController() then
        return
    end

    if self.MMainUI and self.MMainUI.ShowTip then
        self.MMainUI:ShowTip("当前无法获得经验，请先转生")
    end
end

--- Client RPC：同步怪物击杀数量（副本模式 1002）
--- 用于更新主界面上的击杀计数显示
-- @param currentKills 当前击杀数
-- @param requiredKills 需求击杀数
function UGCPlayerController:Client_SyncMobKillCount(currentKills, requiredKills)
    -- ugcprint("[UGCPlayerController] Client_SyncMobKillCount: " .. tostring(currentKills) .. "/" .. tostring(requiredKills))
    if not self:IsLocalController() then return end
    if self.MMainUI and self.MMainUI.UpdateMobKillCount then
        self.MMainUI:UpdateMobKillCount(currentKills, requiredKills)
    end
end

--- Client RPC：同步个人击杀数量（好友列表显示）
--- @param playerKey 玩家标识
--- @param killCount 击杀数
function UGCPlayerController:Client_SyncPlayerKillCount(playerKey, killCount)
    if not self:IsLocalController() then
        return
    end

    ugcprint("[UGCPlayerController] Client_SyncPlayerKillCount key=" .. tostring(playerKey) .. ", kill=" .. tostring(killCount))

    if self.MMainUI and self.MMainUI.SyncFriendListPlayerKillCount then
        self.MMainUI:SyncFriendListPlayerKillCount(playerKey, killCount)
    end
end

-- ================================================================================
-- 奖励系统
-- ================================================================================

-- ============ Rewards ============

-- Server RPC：发放副本完成奖励
-- 职责：
--   1. 读取副本奖励配置表
--   2. 统计总奖励数量
--   3. 发放虚拟物品给玩家
function UGCPlayerController:Server_GiveRewards()
    -- ugcprint("[Server] Server_GiveRewards called")

    -- 虚拟物品 ID（匹配奖励）
    local matchRewardVirtualID = 5666

    -- 权限检查
    if not self:HasAuthority() then
        return
    end

    -- 读取所有副本奖励配置
    local allRewards = UGCGameData.GetAllFubenreword()
    if not allRewards then
        -- ugcprint("[Server] Server_GiveRewards error: unable to read dungeon reward table")
        return
    end

    -- 统计总奖励数量
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

    -- 获取虚拟物品管理器
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VIM then
        -- ugcprint("[Server] Server_GiveRewards error: unable to get VirtualItemManager")
        return
    end

    -- 发放虚拟物品
    VIM:AddVirtualItem(self, matchRewardVirtualID, totalRewardCount)
    -- ugcprint("[Server] Server_GiveRewards completed, virtual item ID=" .. tostring(matchRewardVirtualID) .. ", count=" .. tostring(totalRewardCount))
end

-- ================================================================================
-- 队伍系统
-- ================================================================================

-- ============ Team System ============

-- Server RPC：发送队伍邀请
-- 队长向目标玩家发送入队邀请
-- @param TargetPlayerKey 目标玩家标识
function UGCPlayerController:Server_SendTeamInvite(TargetPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_SendTeamInvite: TargetPlayerKey=" .. tostring(TargetPlayerKey))

    -- 获取邀请者标识
    local InviterPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)

    -- 如果队伍只有 1 人，将邀请者设为队长
    local InviterPawn = self.Pawn
    if InviterPawn then
        local InviterTeamID = UGCPawnAttrSystem.GetTeamID(InviterPawn)
        local TeamPlayerKeys = UGCTeamSystem.GetPlayerKeysByTeamID(InviterTeamID)
        local teamCount = TeamPlayerKeys and #TeamPlayerKeys or 0

        -- 单人队伍设置队长
        if teamCount <= 1 then
            if not TeamCaptainData then
                TeamCaptainData = {}
            end
            TeamCaptainData[InviterTeamID] = InviterPlayerKey
            -- ugcprint("[UGCPlayerController] Team " .. tostring(InviterTeamID) .. " captain set to: " .. tostring(InviterPlayerKey))
        end
    end

    -- 向目标玩家发送邀请通知
    local TargetPC = UGCGameSystem.GetPlayerControllerByPlayerKey(TargetPlayerKey)
    if TargetPC then
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_ReceiveTeamInvite", InviterPlayerKey)
    end
end

-- Server RPC：响应队伍邀请
-- 被邀请者接受或拒绝邀请
-- @param InviterPlayerKey 邀请者标识
-- @param bAccepted 是否接受
function UGCPlayerController:Server_RespondTeamInvite(InviterPlayerKey, bAccepted)
    -- ugcprint("[UGCPlayerController] Server_RespondTeamInvite: InviterPlayerKey=" .. tostring(InviterPlayerKey) .. ", bAccepted=" .. tostring(bAccepted))

    local ResponderPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local InviterTeamID = nil

    -- 接受邀请：变更队伍
    if bAccepted then
        local InviterPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(InviterPlayerKey)
        if InviterPawn then
            InviterTeamID = UGCPawnAttrSystem.GetTeamID(InviterPawn)
            UGCTeamSystem.ChangePlayerTeamID(ResponderPlayerKey, InviterTeamID)
            -- ugcprint("[UGCPlayerController] Team change: ResponderPlayerKey=" .. tostring(ResponderPlayerKey) .. " -> TeamID=" .. tostring(InviterTeamID))
        end
    end

    -- 通知邀请者结果
    local InviterPC = UGCGameSystem.GetPlayerControllerByPlayerKey(InviterPlayerKey)
    if InviterPC then
        UnrealNetwork.CallUnrealRPC(InviterPC, InviterPC, "Client_TeamInviteResult", ResponderPlayerKey, bAccepted, true)
    end

    -- 通知响应者结果（接受时刷新队伍 UI）
    if bAccepted then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_TeamInviteResult", InviterPlayerKey, bAccepted, false)

        -- 刷新所有队伍成员 UI
        if InviterTeamID then
            self:RefreshAllTeamUI(InviterTeamID)
        end
    end
end

-- Client RPC：收到队伍邀请
-- 显示邀请弹窗供玩家选择
-- @param InviterPlayerKey 邀请者标识
function UGCPlayerController:Client_ReceiveTeamInvite(InviterPlayerKey)
    -- ugcprint("[UGCPlayerController] Client_ReceiveTeamInvite: InviterPlayerKey=" .. tostring(InviterPlayerKey))

    -- 加载邀请 UI 类
    local InviteClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Teamiinvite.WB_Teamiinvite_C'))
    if not InviteClass then
        -- ugcprint("[UGCPlayerController] Error: unable to load WB_Teamiinvite class")
        return
    end

    -- 创建并显示邀请 UI
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

-- Client RPC：队伍邀请结果通知
-- @param TargetPlayerKey 相关玩家标识
-- @param bAccepted 是否接受
-- @param bIsCaptain 是否是队长视角
function UGCPlayerController:Client_TeamInviteResult(TargetPlayerKey, bAccepted, bIsCaptain)
    -- ugcprint("[UGCPlayerController] Client_TeamInviteResult: TargetPlayerKey=" .. tostring(TargetPlayerKey) .. ", bAccepted=" .. tostring(bAccepted) .. ", bIsCaptain=" .. tostring(bIsCaptain))

    if self.MMainUI and self.MMainUI.WB_Team then
        if bAccepted then
            -- 显示加入成功提示
            if bIsCaptain and self.MMainUI.ShowTip then
                local TargetPlayerName = GetPlayerNameByPlayerKey(TargetPlayerKey)
                self.MMainUI:ShowTip(tostring(TargetPlayerName) .. " 已加入队伍")
            end

            -- 更新队长状态
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

            -- 延迟刷新队伍 UI
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
            -- 拒绝：更新槽位状态
            self.MMainUI.WB_Team:UpdateSlotState(TargetPlayerKey, "invite")
        end
    end
end

-- Server RPC：踢出队伍成员
-- 只有队长有权限执行
-- @param TargetPlayerKey 被踢玩家标识
function UGCPlayerController:Server_KickFromTeam(TargetPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_KickFromTeam: TargetPlayerKey=" .. tostring(TargetPlayerKey))

    -- 获取队长信息
    local CaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local CaptainPawn = self.Pawn
    if not CaptainPawn then return end

    local CaptainTeamID = UGCPawnAttrSystem.GetTeamID(CaptainPawn)

    -- 权限检查：必须是队长
    if not TeamCaptainData[CaptainTeamID] or TeamCaptainData[CaptainTeamID] ~= CaptainPlayerKey then
        -- ugcprint("[UGCPlayerController] Error: not captain, no permission to kick")
        return
    end

    -- 分配一个新的空闲队伍 ID（踢出的玩家独处）
    local newTeamID = 100
    while true do
        local members = UGCTeamSystem.GetPlayerKeysByTeamID(newTeamID)
        if not members or #members == 0 then
            break
        end
        newTeamID = newTeamID + 1
    end

    -- 执行踢出操作
    UGCTeamSystem.ChangePlayerTeamID(TargetPlayerKey, newTeamID)

    -- 刷新旧队伍 UI
    self:RefreshAllTeamUI(CaptainTeamID)

    -- 通知被踢玩家
    local TargetPC = UGCGameSystem.GetPlayerControllerByPlayerKey(TargetPlayerKey)
    if TargetPC then
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_RefreshTeamUI", -1)
        UnrealNetwork.CallUnrealRPC(TargetPC, TargetPC, "Client_OnKickedFromTeam")
    end
end

-- Server RPC：离开队伍
-- 玩家主动离开当前队伍
function UGCPlayerController:Server_LeaveTeam()
    local LeaverPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    -- ugcprint("[UGCPlayerController] Server_LeaveTeam: PlayerKey=" .. tostring(LeaverPlayerKey))

    local LeaverPawn = self.Pawn
    if not LeaverPawn then return end

    local OldTeamID = UGCPawnAttrSystem.GetTeamID(LeaverPawn)

    -- 分配新的空闲队伍 ID
    local newTeamID = 100
    while true do
        local members = UGCTeamSystem.GetPlayerKeysByTeamID(newTeamID)
        if not members or #members == 0 then
            break
        end
        newTeamID = newTeamID + 1
    end

    -- 执行离队操作
    UGCTeamSystem.ChangePlayerTeamID(LeaverPlayerKey, newTeamID)

    -- 刷新旧队伍 UI
    self:RefreshAllTeamUI(OldTeamID)

    -- 刷新离队者 UI
    UnrealNetwork.CallUnrealRPC(self, self, "Client_RefreshTeamUI", -1)
end

-- Server RPC：请求加入队伍
-- 玩家向队长发送入队请求
-- @param CaptainPlayerKey 队长标识
function UGCPlayerController:Server_RequestJoinTeam(CaptainPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_RequestJoinTeam: CaptainPlayerKey=" .. tostring(CaptainPlayerKey))

    local RequesterPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)

    local CaptainPC = UGCGameSystem.GetPlayerControllerByPlayerKey(CaptainPlayerKey)
    if CaptainPC then
        UnrealNetwork.CallUnrealRPC(CaptainPC, CaptainPC, "Client_ReceiveJoinRequest", RequesterPlayerKey)
    end
end

-- Server RPC：接受入队请求
-- 队长同意玩家的入队请求
-- @param RequesterPlayerKey 请求者标识
function UGCPlayerController:Server_AcceptJoinRequest(RequesterPlayerKey)
    -- ugcprint("[UGCPlayerController] Server_AcceptJoinRequest: RequesterPlayerKey=" .. tostring(RequesterPlayerKey))

    local CaptainPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(self)
    local CaptainPawn = self.Pawn
    if not CaptainPawn then return end

    local CaptainTeamID = UGCPawnAttrSystem.GetTeamID(CaptainPawn)

    -- 权限检查：必须是队长
    if not TeamCaptainData[CaptainTeamID] or TeamCaptainData[CaptainTeamID] ~= CaptainPlayerKey then
        -- ugcprint("[UGCPlayerController] Error: not captain, no permission to accept join request")
        return
    end

    -- 变更请求者到队长队伍
    UGCTeamSystem.ChangePlayerTeamID(RequesterPlayerKey, CaptainTeamID)

    -- 通知队长
    UnrealNetwork.CallUnrealRPC(self, self, "Client_TeamInviteResult", RequesterPlayerKey, true, true)

    -- 通知请求者
    local RequesterPC = UGCGameSystem.GetPlayerControllerByPlayerKey(RequesterPlayerKey)
    if RequesterPC then
        UnrealNetwork.CallUnrealRPC(RequesterPC, RequesterPC, "Client_TeamInviteResult", CaptainPlayerKey, true, false)
    end

    -- 通知其他队伍成员
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

-- Client RPC：收到入队请求
-- 显示入队请求弹窗供队长选择
-- @param RequesterPlayerKey 请求者标识
function UGCPlayerController:Client_ReceiveJoinRequest(RequesterPlayerKey)
    -- ugcprint("[UGCPlayerController] Client_ReceiveJoinRequest: RequesterPlayerKey=" .. tostring(RequesterPlayerKey))

    -- 加载邀请 UI 类
    local InviteClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Teamiinvite.WB_Teamiinvite_C'))
    if not InviteClass then return end

    -- 创建并显示请求 UI
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

--- Client RPC：刷新队伍 UI
--- @param CaptainPK 队长标识（-1 表示无队伍）
function UGCPlayerController:Client_RefreshTeamUI(CaptainPK)
    -- ugcprint("[UGCPlayerController] Client_RefreshTeamUI called, CaptainPK=" .. tostring(CaptainPK))

    -- 更新队长标识
    if CaptainPK and CaptainPK ~= -1 then
        self.TeamCaptainPlayerKey = CaptainPK
    end

    -- 延迟刷新，等待队伍数据更新
    UGCTimerUtility.CreateLuaTimer(
        0.5,
        function()
            local LocalPawn = self.Pawn
            if LocalPawn then
                local LocalTeamID = UGCPawnAttrSystem.GetTeamID(LocalPawn)
                local TeamPawns = UGCTeamSystem.GetPlayerPawnsByTeamID(LocalTeamID)
                local teamCount = TeamPawns and #TeamPawns or 0

                -- 单人队伍清除队长状态
                if teamCount <= 1 then
                    self.bIsTeamCaptain = nil
                    self.TeamCaptainPlayerKey = nil
                end
            end

            -- 刷新队伍 UI
            if self.MMainUI and self.MMainUI.WB_Team then
                self.MMainUI.WB_Team:CreatePlayerSlots()
            end
        end,
        false,
        "RefreshTeamUI_Timer"
    )
end

--- Client RPC：被踢出队伍通知
--- 显示被踢出提示
function UGCPlayerController:Client_OnKickedFromTeam()
    if self.MMainUI and self.MMainUI.ShowTip then
        self.MMainUI:ShowTip("你已被踢出队伍")
    end
end

--- Server RPC：请求队伍面板玩家数据
--- 用于显示所有玩家的队伍面板（包含战力等信息）
function UGCPlayerController:Server_RequestTeamPanelPlayers()
    if not self:HasAuthority() then
        return
    end

    -- 获取本地玩家信息
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

    -- 判断是否是队长
    local captainPK = -1
    if TeamCaptainData and localTeamID and TeamCaptainData[localTeamID] then
        captainPK = TeamCaptainData[localTeamID]
    end
    local bIsCaptain = (captainPK ~= -1 and localPlayerKey == captainPK)

    -- 发送开始信号
    UnrealNetwork.CallUnrealRPC(self, self, "Client_BeginTeamPanelPlayers", captainPK, bIsCaptain)

    -- 遍历所有玩家控制器，收集数据
    local allPCs = UGCGameSystem.GetAllPlayerController()
    local pushedCount = 0
    if allPCs then
        for _, pc in pairs(allPCs) do
            if pc then
                local playerKey = UGCGameSystem.GetPlayerKeyByPlayerController(pc)
                if playerKey and playerKey > 0 then
                    -- 获取 Pawn
                    local pawn = pc.Pawn
                    if (not pawn or not UGCObjectUtility.IsObjectValid(pawn)) and pc.K2_GetPawn then
                        pawn = pc:K2_GetPawn()
                    end

                    -- 获取 PlayerState
                    local playerState = pc.PlayerState or (pawn and pawn.PlayerState) or UGCGameSystem.GetPlayerStateByPlayerController(pc)

                    -- 获取玩家名称
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

                    -- 获取队伍 ID
                    local teamID = -1
                    if pawn and UGCObjectUtility.IsObjectValid(pawn) then
                        teamID = UGCPawnAttrSystem.GetTeamID(pawn)
                    elseif playerState and playerState.TeamID then
                        teamID = playerState.TeamID
                    end

                    -- 获取头像 URL
                    local iconUrl = ""
                    if playerState then
                        local pkInt64 = UGCPlayerStateSystem.GetPlayerKeyInt64(playerState)
                        local accountInfo = UGCPlayerStateSystem.GetPlayerAccountInfo(pkInt64)
                        if accountInfo then
                            iconUrl = accountInfo.IconUrl or ""
                        end
                    end

                    -- 获取战力
                    local combatPower = 0
                    if playerState then
                        combatPower = tonumber(playerState.UGCPlayerCombatPower) or 0
                        if combatPower <= 0 and playerState.GetCombatPower then
                            combatPower = tonumber(playerState:GetCombatPower()) or 0
                        end
                    end

                    -- 发送玩家数据
                    UnrealNetwork.CallUnrealRPC(self, self, "Client_AddTeamPanelPlayer", playerKey, playerName, teamID, iconUrl, combatPower)
                    pushedCount = pushedCount + 1
                end
            end
        end
    end

    -- ugcprint("[UGCPlayerController] Server_RequestTeamPanelPlayers: PushedCount=" .. tostring(pushedCount))

    -- 发送结束信号
    UnrealNetwork.CallUnrealRPC(self, self, "Client_EndTeamPanelPlayers")
end

-- Client RPC：开始接收队伍面板玩家数据
-- @param CaptainPK 队长标识
-- @param bIsCaptain 是否是队长
function UGCPlayerController:Client_BeginTeamPanelPlayers(CaptainPK, bIsCaptain)
    -- 初始化数据表
    self.TeamPanelPlayerData = {}

    -- 设置队长标识
    if CaptainPK and CaptainPK ~= -1 then
        self.TeamCaptainPlayerKey = CaptainPK
    else
        self.TeamCaptainPlayerKey = nil
    end

    self.bIsTeamCaptain = (bIsCaptain == true)
end

--- Client RPC：添加队伍面板玩家条目
--- @param PlayerKey 玩家标识
--- @param PlayerName 玩家名称
--- @param TeamID 队伍 ID
--- @param IconUrl 头像 URL
--- @param CombatPower 战力
function UGCPlayerController:Client_AddTeamPanelPlayer(PlayerKey, PlayerName, TeamID, IconUrl, CombatPower)
    if not self.TeamPanelPlayerData then
        self.TeamPanelPlayerData = {}
    end

    -- 插入玩家数据到列表
    table.insert(self.TeamPanelPlayerData, {
        PlayerKey = PlayerKey,
        PlayerName = PlayerName,
        TeamID = TeamID,
        IconUrl = IconUrl,
        CombatPower = CombatPower,
    })
end

--- Client RPC：结束接收队伍面板玩家数据
--- 触发 UI 刷新显示
function UGCPlayerController:Client_EndTeamPanelPlayers()
    local count = 0
    if self.TeamPanelPlayerData then
        for _, _ in pairs(self.TeamPanelPlayerData) do
            count = count + 1
        end
    end
    -- ugcprint("[UGCPlayerController] Client_EndTeamPanelPlayers: ReceivedCount=" .. tostring(count))

    -- 刷新队伍 UI
    if self.MMainUI and self.MMainUI.WB_Team and self.MMainUI.WB_Team.CreatePlayerSlots then
        self.MMainUI.WB_Team:CreatePlayerSlots(true)
    end
end

--- 刷新所有队伍成员 UI
--- 遍历队伍成员并发送刷新通知
--- @param TeamID 队伍 ID
function UGCPlayerController:RefreshAllTeamUI(TeamID)
    local CaptainPK = TeamCaptainData and TeamCaptainData[TeamID] or -1
    local TeamPCs = UGCTeamSystem.GetPlayerControllersByTeamID(TeamID)
    if TeamPCs then
        for _, PC in ipairs(TeamPCs) do
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_RefreshTeamUI", CaptainPK)
        end
    end
end

-- ================================================================================
-- 剑阁（剑阁副本）系统
-- ================================================================================

-- ============ Jiange (Sword Pavilion) UI ============

--- Client RPC：显示剑阁结算界面
--- @param LevelNum 当前层数
function UGCPlayerController:Client_ShowTaSettlementUI(LevelNum)
    -- ugcprint("[UGCPlayerController] Client_ShowTaSettlementUI called, LevelNum=" .. tostring(LevelNum))

    if not self:IsLocalController() then return end

    -- 显示剑阁结算面板
    if self.JiangeUI and self.JiangeUI.ta_settlement then
        local taUI = self.JiangeUI.ta_settlement
        taUI.SettlementActionPending = false
        taUI.DisplayLevelNum = LevelNum

        -- 设置结算提示文本
        if taUI.settlementtip then
            taUI.settlementtip:SetText("恭喜通过第" .. tostring(LevelNum) .. "层，奖励如下")
        end

        -- 创建奖励槽位
        if taUI.CreateRewardSlots then
            taUI:CreateRewardSlots()
        end

        -- 显示结算 UI
        taUI:SetVisibility(0) -- Visible

        -- 更新楼层显示文本
        if self.JiangeUI.UpdateFloorText then
            self.JiangeUI:UpdateFloorText()
        end
        -- ugcprint("[UGCPlayerController] ta_settlement UI shown, floor=" .. tostring(LevelNum))
    else
        -- ugcprint("[UGCPlayerController] Error: JiangeUI or ta_settlement does not exist")
    end
end

--- Server RPC：恢复 TriggerBox 刷怪
--- 在某些条件下恢复暂停的怪物生成
function UGCPlayerController:Server_ResumeTriggerBoxSpawning()
    -- ugcprint("[UGCPlayerController] Server_ResumeTriggerBoxSpawning called")

    if self.CurrentTriggerBox and self.CurrentTriggerBox.ResumeSpawning then
        -- ugcprint("[UGCPlayerController] Found TriggerBox, resuming spawning")
        self.CurrentTriggerBox:ResumeSpawning()
    else
        -- ugcprint("[UGCPlayerController] Error: CurrentTriggerBox is nil or has no ResumeSpawning method")
    end
end

-- Client RPC：更新剑阁楼层显示
-- @param floor 当前楼层索引
function UGCPlayerController:Client_UpdateJiangeFloor(floor)
    -- ugcprint("[UGCPlayerController] Client_UpdateJiangeFloor: " .. tostring(floor))
    if not self:IsLocalController() then return end

    -- 保存楼层值
    self.JiangeFloor = floor

    -- 更新 UI 上的楼层文本
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.cengshu then
        self.MMainUI.wujingjiange.cengshu:SetText(tostring(floor + 1))
    end

    -- 刷新奖励状态显示
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.RefreshRewardStates then
        self.MMainUI.wujingjiange:RefreshRewardStates()
    end
end

-- Client RPC：同步剑阁奖励数据
-- @param claimedFloorsStr 已领取楼层字符串（逗号分隔）
-- @param dailyClaimDate 每日领取日期
-- @param dailyAmount 每日领取次数
function UGCPlayerController:Client_SyncJiangeRewardData(claimedFloorsStr, dailyClaimDate, dailyAmount)
    -- ugcprint("[UGCPlayerController] Client_SyncJiangeRewardData: claimed=" .. tostring(claimedFloorsStr) .. ", date=" .. tostring(dailyClaimDate) .. ", daily=" .. tostring(dailyAmount))
    if not self:IsLocalController() then return end

    -- 保存数据
    self.JiangeClaimedFloors = claimedFloorsStr or ""
    self.JiangeDailyClaimDate = dailyClaimDate or ""
    self.JiangeDailyAmount = dailyAmount or 1

    -- 刷新剑阁奖励 UI
    if self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.RefreshRewardStates then
        self.MMainUI.wujingjiange:RefreshRewardStates()
    end
end

-- Client RPC：剑阁每日领取结果
-- @param success 是否成功
-- @param amount 领取数量
-- @param tipText 提示文本
function UGCPlayerController:Client_OnJiangeDailyClaimResult(success, amount, tipText)
    -- ugcprint("[UGCPlayerController] Client_OnJiangeDailyClaimResult: success=" .. tostring(success) .. ", amount=" .. tostring(amount) .. ", tip=" .. tostring(tipText))
    if not self:IsLocalController() then return end

    -- 清除待处理状态
    if self.MMainUI and self.MMainUI.wujingjiange then
        self.MMainUI.wujingjiange.DailyClaimPending = false
    end

    -- 显示提示
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

-- Client RPC：剑阁楼层奖励领取结果
-- @param success 是否成功
-- @param floorNum 楼层号
-- @param tipText 提示文本
function UGCPlayerController:Client_OnJiangeFloorClaimResult(success, floorNum, tipText)
    if not self:IsLocalController() then return end

    -- 清除待处理状态
    if self.MMainUI and self.MMainUI.wujingjiange then
        self.MMainUI.wujingjiange.FloorClaimPending = false
    end

    -- 显示提示
    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip(tostring(floorNum or 0) .. "层奖励领取成功")
        else
            self.MMainUI:ShowTip("领取失败，请稍后再试")
        end
    end

    -- 刷新奖励状态
    if success and self.MMainUI and self.MMainUI.wujingjiange and self.MMainUI.wujingjiange.RefreshRewardStates then
        self.MMainUI.wujingjiange:RefreshRewardStates()
    end
end

-- Client RPC：剑阁锻造消耗结果
-- @param success 是否成功
-- @param remainCount 剩余次数
-- @param tipText 提示文本
function UGCPlayerController:Client_OnJiangeForgeConsumeResult(success, remainCount, tipText)
    -- ugcprint("[UGCPlayerController] Client_OnJiangeForgeConsumeResult: success=" .. tostring(success) .. ", remainCount=" .. tostring(remainCount) .. ", tip=" .. tostring(tipText))
    if not self:IsLocalController() then return end

    -- 优先调用 UI 专用处理
    if self.MMainUI and self.MMainUI.jiange and self.MMainUI.jiange.OnForgeConsumeResult then
        self.MMainUI.jiange:OnForgeConsumeResult(success, remainCount, tipText)
        return
    end

    -- 通用提示处理
    if self.MMainUI and self.MMainUI.ShowTip and tipText and tipText ~= "" then
        self.MMainUI:ShowTip(tostring(tipText))
    end
end

-- Client RPC：充值奖励领取结果
-- @param success 是否成功
-- @param rewardID 奖励 ID
-- @param tipText 提示文本
function UGCPlayerController:Client_OnChongzhiClaimResult(success, rewardID, tipText)
    if not self:IsLocalController() then return end

    -- 成功时记录已领取状态
    if success then
        local playerState = UGCGameSystem.GetLocalPlayerState()
        local claimID = math.floor(tonumber(rewardID) or 0)
        if playerState and claimID > 0 then
            playerState.ClaimedChongzhi = playerState.ClaimedChongzhi or {}
            playerState.ClaimedChongzhi[claimID] = true
            -- 序列化保存
            if playerState.SerializeClaimedChongzhi then
                playerState.UGCClaimedChongzhiStr = playerState:SerializeClaimedChongzhi(playerState.ClaimedChongzhi)
            end
        end
    end

    -- 显示提示
    if self.MMainUI and self.MMainUI.ShowTip then
        if tipText and tipText ~= "" then
            self.MMainUI:ShowTip(tostring(tipText))
        elseif success then
            self.MMainUI:ShowTip("充值奖励领取成功")
        else
            self.MMainUI:ShowTip("充值奖励领取失败")
        end
    end

    -- 刷新充值奖励 UI
    if self.MMainUI and self.MMainUI.active and self.MMainUI.active.RefreshBuySlots then
        if self.MMainUI.active:GetVisibility() == ESlateVisibility.Visible then
            self.MMainUI.active:RefreshBuySlots()
        end
    end
end

-- Client RPC：天赋升级结果
-- @param success 是否成功
-- @param talentType 天赋类型
-- @param currentLevel 当前等级
-- @param remainCount 剩余点数
-- @param tipText 提示文本
function UGCPlayerController:Client_OnTalentUpgradeResult(success, talentType, currentLevel, remainCount, tipText)
    if not self:IsLocalController() then return end

    -- 优先调用 UI 专用处理
    local handled = false
    if self.MMainUI and self.MMainUI.TalentTree and self.MMainUI.TalentTree.OnTalentUpgradeResult then
        handled = self.MMainUI.TalentTree:OnTalentUpgradeResult(success, talentType, currentLevel, remainCount, tipText) == true
    end

    if handled then
        return
    end

    -- 通用提示处理
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

-- Client RPC：手动加点结果
-- @param success 是否成功
-- @param pointType 加点类型
-- @param remainTalentPoints 剩余天赋点数
-- @param tipText 提示文本
function UGCPlayerController:Client_OnManualPointResult(success, pointType, remainTalentPoints, tipText)
    if not self:IsLocalController() then return end

    -- 优先调用 UI 专用处理
    local handled = false
    if self.MMainUI and self.MMainUI.touxiangdetail and self.MMainUI.touxiangdetail.OnManualPointResult then
        handled = self.MMainUI.touxiangdetail:OnManualPointResult(success, pointType, remainTalentPoints, tipText) == true
    end

    if handled then
        return
    end

    -- 通用提示处理
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

-- Client RPC：开始倒计时
-- @param totalSeconds 总秒数
function UGCPlayerController:Client_StartCountdown(totalSeconds)
    -- ugcprint("[UGCPlayerController] Client_StartCountdown called, totalSeconds=" .. tostring(totalSeconds))
    if not self:IsLocalController() then return end

    if self.MMainUI and self.MMainUI.StartCountdown then
        self.MMainUI:StartCountdown(totalSeconds)
    else
        -- ugcprint("[UGCPlayerController] Error: MMainUI or StartCountdown does not exist")
    end
end

-- Client RPC：同步剑阁数据（关卡和进度）
-- @param jiangeLevel 剑阁等级
-- @param jiangeProgress 剑阁进度
function UGCPlayerController:Client_SyncJiangeData(jiangeLevel, jiangeProgress)
    -- ugcprint("[UGCPlayerController] Client_SyncJiangeData: level=" .. tostring(jiangeLevel) .. ", progress=" .. tostring(jiangeProgress))
    if not self:IsLocalController() then return end

    -- 本地保存
    self.SavedJiangeLevel = jiangeLevel
    self.SavedJiangeProgress = jiangeProgress

    -- 如果剑阁 UI 已打开，直接加载数据
    if self.MMainUI and self.MMainUI.jiange and self.MMainUI.jiange.LoadSavedData then
        self.MMainUI.jiange:LoadSavedData(jiangeLevel, jiangeProgress)
    end
end

-- Client RPC：同步神隐数据
-- @param dataStr 序列化的神隐数据字符串
function UGCPlayerController:Client_SyncShenyinData(dataStr)
    -- ugcprint("[UGCPlayerController] Client_SyncShenyinData: " .. tostring(dataStr))
    if not self:IsLocalController() then return end

    self.SavedShenyinData = dataStr

    -- 如果神隐 UI 已打开，直接加载数据
    if self.MMainUI and self.MMainUI.shenyin and self.MMainUI.shenyin.LoadSavedData then
        self.MMainUI.shenyin:LoadSavedData(dataStr)
    end
end

-- Client RPC：P1 守护失败通知
-- 当 P1 守护怪死亡时触发
function UGCPlayerController:Client_OnP1Died()
    -- ugcprint("[UGCPlayerController] Client_OnP1Died called")
    if not self:IsLocalController() then return end

    -- 显示防守失败提示
    if self.MMainUI and self.MMainUI.ShowTip then
        self.MMainUI:ShowTip("防守失败")
    end

    -- 延迟 2 秒后进入退出流程
    local PlayerController = self

    -- 清理之前的定时器
    if self.P1DiedDelayHandle then
        local okClearTimer, clearTimerErr = pcall(function()
            UGCGameSystem.ClearTimer(self, self.P1DiedDelayHandle)
        end)
        if not okClearTimer then
            ugcprint("[UGCPlayerController] 清理 P1DiedDelayHandle 失败: " .. tostring(clearTimerErr))
        end
        self.P1DiedDelayHandle = nil
    end

    -- 设置延迟回调
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

-- ================================================================================
-- UI 恢复系统
-- ================================================================================

-- 判断 Widget 是否显示
-- @param Widget UI 组件
-- @return boolean 是否可见
local function IsWidgetShown(Widget)
    if not Widget then
        return false
    end

    local visibility = Widget:GetVisibility()
    return visibility == ESlateVisibility.Visible
        or visibility == ESlateVisibility.SelfHitTestInvisible
        or visibility == ESlateVisibility.HitTestInvisible
end

-- 复活后恢复 Widget 显示
-- 尝试通过减少隐藏层级来恢复 UI 显示
-- @param Widget UI 组件
-- @param widgetTag 标签（调试用）
local function RestoreWidgetAfterRespawn(Widget, widgetTag)
    if not Widget then
        return
    end

    -- 尝试减少隐藏层级
    local subTimes = 0
    while (not IsWidgetShown(Widget)) and subTimes < 6 do
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(Widget)
        subTimes = subTimes + 1
    end

    -- 强制设置为可见
    Widget:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    -- ugcprint("[UGCPlayerController] Restored widget: " .. tostring(widgetTag) .. ", subTimes=" .. tostring(subTimes))
end

-- Client RPC：复活后恢复主 UI
-- 玩家复活后恢复所有被隐藏的 UI 组件
function UGCPlayerController:Client_RestoreMainUIAfterRespawn()
    -- ugcprint("[UGCPlayerController] Client_RestoreMainUIAfterRespawn called")
    if not self:IsLocalController() then return end

    -- 清理剑阁 UI
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

    -- 恢复主面板函数
    local function RestoreMainPanelsOnce()
        if not self.MMainUI then
            return
        end

        -- 恢复主 UI 可见性
        self.MMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)

        -- 获取基础 UI 组件
        local MainControlBaseUI = self.MMainUI.MainControlBaseUI
        local ShootingUIPanel = self.MMainUI.ShootingUIPanel

        -- 尝试从全局获取缺失的组件
        if (not MainControlBaseUI) or (not ShootingUIPanel) then
            local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
            if MainControlPanel then
                MainControlBaseUI = MainControlBaseUI or MainControlPanel.MainControlBaseUI
                ShootingUIPanel = ShootingUIPanel or MainControlPanel.ShootingUIPanel
            end
        end

        -- 恢复各个 UI 组件
        RestoreWidgetAfterRespawn(MainControlBaseUI, "MainControlBaseUI")
        RestoreWidgetAfterRespawn(ShootingUIPanel, "ShootingUIPanel")

        -- 恢复技能面板
        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        RestoreWidgetAfterRespawn(SkillPanel, "SkillRootPanel")
    end

    -- 立即恢复一次
    RestoreMainPanelsOnce()

    -- =================================================================
    -- 延迟重试恢复
    -- 处理异步加载导致的组件缺失
    -- =================================================================
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

    -- 隐藏武竞剑阁组件
    if self.MMainUI.wujingjiange then
        self.MMainUI.wujingjiange:SetVisibility(ESlateVisibility.Collapsed)
    end
    -- ugcprint("[UGCPlayerController] MMainUI restored to visible")
end

-- ================================================================================
-- 宝箱系统
-- ================================================================================

-- ============ Treasure Box (Baoxiang) System ============

-- 引入礼包管理器模块
local GiftPackManagerModule = UGCGameSystem.UGCRequire("ExtendResource.GiftPack.OfficialPackage." .. "Script.GiftPack.GiftPackManager")

-- 获取全局礼包管理器实例
-- @return GiftPackManager 礼包管理器实例或 nil
local function GetGiftPackManager()
    if _G and _G.GiftPackManager and type(_G.GiftPackManager) == "table" then
        return _G.GiftPackManager
    end
    -- ugcprint("[GetGiftPackManager] Error: global GiftPackManager not available, _G.GiftPackManager=" .. tostring(_G and _G.GiftPackManager))
    return nil
end

-- 发放宝箱掉落物品
-- 处理物品映射和虚拟物品/背包发放
-- @param PlayerController 玩家控制器
-- @param BagOwner 背包所有者（Pawn 或 Controller）
-- @param DropItemList 掉落物品列表 {ItemID = Count}
-- @return totalGranted 实际发放的物品总数
local function GrantBaoxiangDrops(PlayerController, BagOwner, DropItemList)
    -- 参数检查
    if type(DropItemList) ~= "table" then
        return 0
    end

    local totalGranted = 0

    -- 获取玩家 Pawn
    local PlayerPawn = PlayerController and (PlayerController.Pawn or PlayerController:K2_GetPawn())
    if (not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn)) and BagOwner and UGCObjectUtility.IsObjectValid(BagOwner) then
        PlayerPawn = BagOwner
    end

    -- 获取虚拟物品管理器
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")

    -- 遍历发放每个掉落物品
    for dropItemID, dropNum in pairs(DropItemList) do
        local awardNum = math.floor(tonumber(dropNum) or 0)
        if awardNum > 0 then
            local targetItemID = tonumber(dropItemID) or dropItemID

            -- 检查物品映射（UGC 物品 ID -> 经典物品 ID）
            local mapping = UGCGameData.GetItemMapping(targetItemID)
            if mapping and mapping["ClassicItemID"] and mapping["ClassicItemID"] > 0 then
                targetItemID = mapping["ClassicItemID"]
            end

            -- 尝试发放物品
            local grantedNum = 0
            if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
                local addedNum = UGCBackpackSystemV2.AddItemV2(PlayerPawn, targetItemID, awardNum)
                if addedNum == true then
                    grantedNum = awardNum
                elseif type(addedNum) == "number" and addedNum > 0 then
                    grantedNum = addedNum
                end
            end

            -- 背包发放失败时尝试虚拟物品
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

--- Client RPC：显示宝箱数量选择 UI
--- @param ItemID 宝箱物品 ID
--- @param OwnedCount 拥有数量
--- @param GiftPackID 礼包 ID
function UGCPlayerController:Client_ShowBaoxiangNumchoose(ItemID, OwnedCount, GiftPackID)
    -- ugcprint("[Client] Client_ShowBaoxiangNumchoose ItemID=" .. tostring(ItemID) .. " OwnedCount=" .. tostring(OwnedCount) .. " GiftPackID=" .. tostring(GiftPackID))

    if not self:IsLocalController() then
        return
    end

    -- 尝试获取全局数量选择 UI 实例
    local numChoseWidget = _G.G_NumChoseInstance
    -- ugcprint("[Client] G_NumChoseInstance = " .. tostring(numChoseWidget))

    -- 如果未找到，动态创建
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

    -- 捕获变量到闭包
    local capturedGiftPackID = GiftPackID
    local capturedItemID = ItemID

    -- 显示数量选择 UI
    numChoseWidget:Show(OwnedCount, function(selectCount)
        -- ugcprint("[Client] Player selected box count: " .. tostring(selectCount) .. " ItemID=" .. tostring(capturedItemID) .. " GiftPackID=" .. tostring(capturedGiftPackID))
        local pc = UGCGameSystem.GetLocalPlayerController()
        if not pc then
            -- ugcprint("[Client] Error: unable to get PlayerController")
            return
        end

        -- 调用服务器批量开启
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

--- Server RPC：批量开启宝箱
--- @param ItemID 宝箱物品 ID
--- @param UseCount 开启数量
--- @param InGiftPackID 礼包 ID（可选）
function UGCPlayerController:Server_BatchOpenBaoxiang(ItemID, UseCount, InGiftPackID)
    -- ugcprint("[Server] ====== Server_BatchOpenBaoxiang enter ======")
    -- ugcprint("[Server] ItemID=" .. tostring(ItemID) .. " type=" .. type(ItemID))
    -- ugcprint("[Server] UseCount=" .. tostring(UseCount) .. " type=" .. type(UseCount))
    -- ugcprint("[Server] InGiftPackID=" .. tostring(InGiftPackID) .. " type=" .. type(InGiftPackID))

    -- 权限检查
    if not self:HasAuthority() then
        -- ugcprint("[Server] Error: no authority, exit")
        return
    end
    -- ugcprint("[Server] Authority check passed")

    -- 获取礼包管理器
    local GiftPackManager = GetGiftPackManager()
    -- ugcprint("[Server] GiftPackManager=" .. tostring(GiftPackManager))
    if not GiftPackManager then
        -- ugcprint("[Server] Error: GiftPackManager not loaded, exit")
        return
    end

    -- 转换并验证开启数量
    UseCount = math.floor(tonumber(UseCount) or 0)
    -- ugcprint("[Server] Converted UseCount=" .. tostring(UseCount))
    if UseCount <= 0 then
        -- ugcprint("[Server] Error: UseCount<=0, exit")
        return
    end

    -- =================================================================
    -- 宝箱 ID 映射表
    -- 背包物品 ID -> 礼包配置 ID
    -- 包含多种宝箱类型：ys 系列、日宝箱、月宝箱、周宝箱
    -- =================================================================
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

    -- 确定礼包 ID
    local GiftPackID = nil
    if InGiftPackID and type(InGiftPackID) == "number" and InGiftPackID > 0 then
        -- 优先使用传入的礼包 ID
        GiftPackID = InGiftPackID
        -- ugcprint("[Server] Using passed-in GiftPackID: " .. tostring(GiftPackID))
    else
        -- 根据物品 ID 查找礼包 ID
        GiftPackID = BAOXIANG_MAP[ItemID]
        -- ugcprint("[Server] Looked up GiftPackID from BAOXIANG_MAP: " .. tostring(GiftPackID) .. " (ItemID=" .. tostring(ItemID) .. ")")
    end
    if not GiftPackID then
        -- ugcprint("[Server] Error: GiftPackID is nil, ItemID=" .. tostring(ItemID) .. " InGiftPackID=" .. tostring(InGiftPackID) .. ", exit")
        return
    end
    -- ugcprint("[Server] Final GiftPackID=" .. tostring(GiftPackID))

    -- 检查礼包管理器接口
    -- ugcprint("[Server] GetGiftPackDataByID=" .. tostring(GiftPackManager.GetGiftPackDataByID))
    -- ugcprint("[Server] GetAllGiftPackDropList=" .. tostring(GiftPackManager.GetAllGiftPackDropList))
    if not GiftPackManager.GetGiftPackDataByID or not GiftPackManager.GetAllGiftPackDropList then
        -- ugcprint("[Server] Error: GiftPackManager interface incomplete, exit")
        return
    end

    -- 读取礼包配置数据
    local okGiftPackData, giftPackData = pcall(function()
        return GiftPackManager:GetGiftPackDataByID(GiftPackID)
    end)
    -- ugcprint("[Server] GetGiftPackDataByID pcall result: ok=" .. tostring(okGiftPackData) .. " data=" .. tostring(giftPackData))
    if (not okGiftPackData) or (not giftPackData) then
        -- ugcprint("[Server] Error: gift pack config missing or read failed, GiftPackID=" .. tostring(GiftPackID) .. " err=" .. tostring(giftPackData) .. ", exit")
        return
    end

    -- 获取玩家 Pawn
    local PlayerPawn = self.Pawn
    if not PlayerPawn or not UGCObjectUtility.IsObjectValid(PlayerPawn) then
        PlayerPawn = self:K2_GetPawn()
    end

    -- 获取虚拟物品管理器
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    -- ugcprint("[Server] VirtualItemManager=" .. tostring(VirtualItemManager))

    -- 从礼包配置获取虚拟物品 ID
    local virtualItemID = giftPackData.ItemID
    -- ugcprint("[Server] Gift pack config virtual ItemID=" .. tostring(virtualItemID) .. " classic ItemID=" .. tostring(ItemID))

    -- =================================================================
    -- 检查背包和虚拟物品数量
    -- =================================================================
    local bagCount = 0
    local virtualCount = 0

    -- 检查背包数量
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        bagCount = UGCBackpackSystemV2.GetItemCountV2(PlayerPawn, ItemID) or 0
    end
    if bagCount <= 0 then
        bagCount = UGCBackpackSystemV2.GetItemCountV2(self, ItemID) or 0
    end

    -- 检查虚拟物品数量
    if VirtualItemManager and virtualItemID then
        local okVCount, vCount = pcall(function()
            return VirtualItemManager:GetItemNum(virtualItemID, self) or 0
        end)
        if okVCount and type(vCount) == "number" then
            virtualCount = vCount
        end
    end

    -- ugcprint("[Server] Backpack count=" .. tostring(bagCount) .. " Virtual item count=" .. tostring(virtualCount))

    -- 确定使用哪个来源
    local useVirtual = false
    local ownedCount = math.max(bagCount, virtualCount)
    if ownedCount <= 0 then
        -- ugcprint("[Server] Neither backpack nor virtual has this item, exit")
        return
    end

    -- 调整开启数量
    if ownedCount < UseCount then
        -- ugcprint("[Server] Count insufficient, adjust UseCount: " .. tostring(UseCount) .. " -> " .. tostring(ownedCount))
        UseCount = ownedCount
    end
    if UseCount <= 0 then
        -- ugcprint("[Server] Adjusted UseCount<=0, exit")
        return
    end

    -- =================================================================
    -- 尝试扣除物品
    -- 优先从背包扣除，失败则使用官方礼包流程
    -- =================================================================
    local removedOk = false
    local bagOwner = PlayerPawn  -- 默认奖励发放目标

    -- 尝试背包扣除
    if bagCount > 0 then
        -- ugcprint("[Server] Starting backpack deduction: ItemID=" .. tostring(ItemID) .. " UseCount=" .. tostring(UseCount))

        -- 尝试从 Pawn 扣除
        local removedCount = 0
        if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
            removedCount = UGCBackpackSystemV2.RemoveItemV2(PlayerPawn, ItemID, UseCount)
            -- ugcprint("[Server] Pawn RemoveItemV2 result: " .. tostring(removedCount))
        end

        -- 尝试从 Controller 扣除
        if not removedCount or removedCount == 0 or removedCount == false then
            removedCount = UGCBackpackSystemV2.RemoveItemV2(self, ItemID, UseCount)
            -- ugcprint("[Server] Self RemoveItemV2 result: " .. tostring(removedCount))
            if removedCount and removedCount ~= 0 and removedCount ~= false then
                bagOwner = self
            end
        end

        -- 处理返回值
        if removedCount == true then removedCount = UseCount end
        if type(removedCount) == "number" and removedCount > 0 then
            removedOk = true
        end
        -- ugcprint("[Server] Backpack deduction result: " .. tostring(removedOk) .. " removedCount=" .. tostring(removedCount))
    end

    -- 背包扣除失败，使用官方礼包流程
    if not removedOk and virtualCount > 0 and virtualItemID then
        -- ugcprint("[Server] Backpack deduction failed, switching to official GiftPackComponent flow: GiftPackID=" .. tostring(GiftPackID) .. " UseCount=" .. tostring(UseCount))

        -- 调整虚拟物品数量
        if virtualCount < UseCount then
            -- ugcprint("[Server] Virtual count insufficient, adjust UseCount: " .. tostring(UseCount) .. " -> " .. tostring(virtualCount))
            UseCount = virtualCount
        end

        -- 获取 GiftPackComponent
        local GPC = nil
        local okGPC, gpcErr = pcall(function()
            GPC = GiftPackManager:GetGiftPackComponent(self)
        end)
        -- ugcprint("[Server] GetGiftPackComponent: ok=" .. tostring(okGPC) .. " GPC=" .. tostring(GPC) .. " err=" .. tostring(gpcErr))

        if GPC then
            -- 调试：打印当前物品数量
            local okNum, gpcNum = pcall(function()
                return GPC:GetItemNum(virtualItemID)
            end)
            -- ugcprint("[Server] GPC:GetItemNum(" .. tostring(virtualItemID) .. ") = " .. tostring(gpcNum) .. " ok=" .. tostring(okNum))

            -- 调试：获取 VirtualItemManager
            local okVIM, vim = pcall(function()
                return GPC:GetVirtualItemManager()
            end)
            -- ugcprint("[Server] GPC:GetVirtualItemManager() = " .. tostring(vim) .. " ok=" .. tostring(okVIM) .. " IsValid=" .. tostring(okVIM and vim and UE.IsValid(vim)))

            -- 调试：获取物品数据
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

        -- 使用官方礼包开启流程
        local okUse, useErr = pcall(function()
            GiftPackManager:OpenNormalGiftPackage(GiftPackID, UseCount, self)
        end)
        -- ugcprint("[Server] OpenNormalGiftPackage pcall result: ok=" .. tostring(okUse) .. " err=" .. tostring(useErr))

        -- 调试：检查开启后物品数量
        if GPC then
            local okNum2, gpcNum2 = pcall(function()
                return GPC:GetItemNum(virtualItemID)
            end)
            -- ugcprint("[Server] After call GPC:GetItemNum(" .. tostring(virtualItemID) .. ") = " .. tostring(gpcNum2) .. " ok=" .. tostring(okNum2))
        end

        -- ugcprint("[Server] ====== Server_BatchOpenBaoxiang end (official flow) ======")
        return
    end

    -- =================================================================
    -- 背包扣除成功，手动生成掉落
    -- =================================================================
    if removedOk then
        -- ugcprint("[Server] Deduction success, generating drops: GiftPackID=" .. tostring(GiftPackID) .. " UseCount=" .. tostring(UseCount))

        -- 获取掉落物品列表
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

        -- 调试：打印掉落物品
        local dropCount = 0
        for k, v in pairs(dropItemList) do
            dropCount = dropCount + 1
            -- ugcprint("[Server] Drop item: ID=" .. tostring(k) .. " count=" .. tostring(v))
        end
        -- ugcprint("[Server] Drop item types: " .. tostring(dropCount))

        -- 发放掉落物品
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

        -- 通知客户端显示奖励 UI
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

--- Client RPC：显示宝箱奖励展示
--- @param awardList 奖励列表 {{ItemID, ItemNum}, ...}
function UGCPlayerController:Client_ShowBaoxiangReward(awardList)
    -- ugcprint("[Client] Client_ShowBaoxiangReward called")
    if not self:IsLocalController() then
        return
    end

    if not awardList or #awardList == 0 then
        -- ugcprint("[Client] No rewards to display")
        return
    end

    -- 尝试在现有 UI 中显示奖励
    if self.MMainUI and self.MMainUI.ShowBaoxiangReward then
        self.MMainUI:ShowBaoxiangReward(awardList)
    else
        -- ugcprint("[Client] MMainUI.ShowBaoxiangReward not available")
    end
end

-- ================================================================================
-- 模块返回
-- ================================================================================

return UGCPlayerController
