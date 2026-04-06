---@class p1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local p1 = {}

local function StopAndCleanSingle1TriggerBoxes(worldContextObject, reasonTag)
    local triggerClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/TriggerBox_Single1.TriggerBox_Single1_C")
    if not triggerClassPath or triggerClassPath == "" then
        ugcprint("[p1] StopAndCleanSingle1 失败：TriggerBox_Single1 类路径为空")
        return 0
    end

    local classPathCandidates = { triggerClassPath }

    local cleanedByGlobal = 0
    if _G and _G.StopAndCleanAllSingle1TriggerBoxes then
        local okGlobalStop, globalStopOrErr = pcall(function()
            return _G.StopAndCleanAllSingle1TriggerBoxes(reasonTag)
        end)

        if okGlobalStop then
            cleanedByGlobal = tonumber(globalStopOrErr) or 0
        else
            ugcprint("[p1] Global StopAndCleanSingle1 调用失败: " .. tostring(globalStopOrErr))
        end
    end

    if cleanedByGlobal > 0 then
        return cleanedByGlobal
    end

    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[p1] StopAndCleanSingle1 失败：WorldContextObject 为空")
        return 0
    end

    if (not UGCActorComponentUtility) or (not UGCActorComponentUtility.GetAllActorsOfClass) then
        ugcprint("[p1] StopAndCleanSingle1 失败：GetAllActorsOfClass 不可用")
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
                                ugcprint("[p1] StopAndCleanAll 调用失败: " .. tostring(stopErr))
                            end
                        end
                    end
                end
            else
                ugcprint("[p1] 查询 TriggerBox_Single1 失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
            end
        end
    end

    if cleanedCount > 0 then
        ugcprint("[p1] 已停止并清怪 TriggerBox_Single1 数量=" .. tostring(cleanedCount) .. ", reason=" .. tostring(reasonTag))
    else
        ugcprint("[p1] 未找到可处理的 TriggerBox_Single1, reason=" .. tostring(reasonTag))
    end

    return cleanedCount
end

function p1:ReceiveBeginPlay()
    p1.SuperClass.ReceiveBeginPlay(self)
    -- 将p1设为阵营1（与玩家同阵营）
    if self:HasAuthority() then
        UGCCampSystem.SetCampForActor(self, 1)
        ugcprint("[p1] 阵营设为1")
    end
end

-- function p1:ReceiveTick(DeltaTime)
--     p1.SuperClass.ReceiveTick(self, DeltaTime)
-- end

-- function p1:ReceiveEndPlay()
--     p1.SuperClass.ReceiveEndPlay(self) 
-- end

-- function p1:GetReplicatedProperties()
--     return
-- end

-- ---受击前置事件
-- ---生效范围：服务器
-- ---@param Damage float 伤害值
-- ---@param EventInstigator AController 伤害来源的Controller
-- ---@param DamageCauser AActor 伤害来源
-- ---@param DamageContext FGameMagnitudeContext  伤害上下文
-- function p1:PreTakeDamageEvent(Damage, EventInstigator, DamageCauser, DamageContext)
     
-- end

-- ---受击后置事件
-- ---生效范围：服务器
-- ---@param Damage float 伤害值
-- ---@param EventInstigator AController 伤害来源的Controller
-- ---@param DamageCauser AActor 伤害来源
-- ---@param DamageContext FGameMagnitudeContext  伤害上下文
-- function p1:PostTakeDamageEvent(Damage, EventInstigator, DamageCauser, DamageContext)
    
-- end

-- ---受击前置伤害修改
-- ---生效范围：服务器
-- ---@param Damage float 伤害值
-- ---@param EventInstigator AController 伤害来源的Controller
-- ---@param DamageCauser AActor 伤害来源
-- ---@param DamageContext FGameMagnitudeContext  伤害上下文
-- ---@return float 修改后的伤害值
-- function p1:PreOverrideDamage(Damage, EventInstigator, DamageCauser, DamageContext)
--     return Damage
-- end

-- ---受击后置伤害修改
-- ---生效范围：服务器
-- ---@param Damage float 伤害值
-- ---@param EventInstigator AController 伤害来源的Controller
-- ---@param DamageCauser AActor 伤害来源
-- ---@param DamageContext FGameMagnitudeContext  伤害上下文
-- ---@return float 修改后的伤害值
-- function p1:PostOverrideDamage(Damage, EventInstigator, DamageCauser, DamageContext)
--     return Damage
-- end

---角色死亡事件
---生效范围：服务器&客户端
---@param Damage float 伤害值
---@param EventInstigator AController 伤害来源的Controller
---@param DamageCauser AActor 伤害来源
---@param FDamageEvent DamageEvent 伤害事件
---@param DamageTypeID int32 伤害类型
function p1:BPDie(KillingDamage, EventInstigator, DamageCauser, DamageEvent, DamageTypeID)
    if self:HasAuthority() then
        -- 只有服务端才可以掉落
        self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})

        -- P1死亡后立即停刷并清怪，防止失败流程期间继续刷怪。
        StopAndCleanSingle1TriggerBoxes(self, "P1Died")

        -- p1死亡，通知所有玩家保卫失败并进入退出流程
        ugcprint("[p1] p1死亡，通知所有玩家保卫失败")
        local AllPCs = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
        if AllPCs and #AllPCs > 0 then
            for _, PC in pairs(AllPCs) do
                if PC then
                    UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnP1Died")
                end
            end
        end

        -- 服务端兜底：确保P1失败后也按超时关卡流程收口，不依赖客户端RPC是否丢失
        UGCTimerUtility.CreateLuaTimer(2.5, function()
            local timeoutActor = nil
            local timeoutClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/SingleModeTimeOut.SingleModeTimeOut_C")
            if not timeoutClassPath or timeoutClassPath == "" then
                ugcprint("[p1] SingleModeTimeOut 类路径为空，无法执行P1兜底")
                return
            end

            local timeoutClassPaths = { timeoutClassPath }

            local worldContext = self
            if (not worldContext) or (UGCObjectUtility and UGCObjectUtility.IsObjectValid and (not UGCObjectUtility.IsObjectValid(worldContext))) then
                worldContext = UGCGameSystem.GameState or UGCGameSystem.GameMode
            end

            for _, classPath in ipairs(timeoutClassPaths) do
                local actorClass = UGCObjectUtility.LoadClass(classPath)
                if actorClass and worldContext and UGCActorComponentUtility and UGCActorComponentUtility.GetAllActorsOfClass then
                    local okGetActors, actorListOrErr = pcall(function()
                        return UGCActorComponentUtility.GetAllActorsOfClass(worldContext, actorClass)
                    end)

                    if okGetActors then
                        local actorList = actorListOrErr
                        if actorList and #actorList > 0 then
                            for _, actor in pairs(actorList) do
                                if actor and UGCObjectUtility.IsObjectValid(actor) then
                                    timeoutActor = actor
                                    break
                                end
                            end
                        end
                    else
                        ugcprint("[p1] 获取 SingleModeTimeOut actor 失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
                    end
                else
                    ugcprint("[p1] 跳过 classPath=" .. tostring(classPath) .. "，原因：类加载失败或查询接口不可用")
                end

                if timeoutActor then
                    break
                end
            end

            if timeoutActor and UGCObjectUtility.IsObjectValid(timeoutActor) then
                if timeoutActor.bTimeOutFinished then
                    ugcprint("[p1] TimeOutActor 已完成，跳过P1兜底")
                else
                    timeoutActor.bTimeOutFinished = true
                    ugcprint("[p1] P1死亡，服务端兜底调用 TimeOutActor:OnFinish()，走关卡流程")
                    timeoutActor:OnFinish()
                end
            else
                ugcprint("[p1] 警告：未找到 SingleModeTimeOut actor，P1兜底无法执行")
            end
        end, false, "P1Die_LevelFlowFallback")
    end
end

-- ---状态进入事件
-- ---生效范围：服务器&客户端
-- ---@param DynamicState FGameplayTag 进入的状态
-- function p1:OnEnterTagState_BP(DynamicState)
--     local Tag = BlueprintGameplayTagLibrary.GetTagName(DynamicState)
--     ugcprint('OnEnterTagState_BP: ' .. Tag)
-- end

-- ---状态退出事件
-- ---生效范围：服务器&客户端
-- ---@param DynamicState FGameplayTag 退出的状态
-- function p1:OnLeaveTagState_BP(DynamicState)
--     local Tag = BlueprintGameplayTagLibrary.GetTagName(DynamicState)
--     ugcprint('OnLeaveTagState_BP: ' .. Tag)
-- end

-- ---状态打断事件
-- ---生效范围：服务器&客户端
-- ---@param DynamicState FGameplayTag 打断的状态
-- function p1:OnInterruptTagState_BP(DynamicState)
--     local Tag = BlueprintGameplayTagLibrary.GetTagName(DynamicState)
--     ugcprint('OnInterruptTagState_BP' .. Tag)
-- end

-- ---行为树消息
-- ---生效范围：服务器
-- ---@param NotifyMsg string 消息
-- function p1:OnBehaviorNotify_BP(NotifyMsg)
--     ugcprint('OnBehaviorNotify_BP: ' .. NotifyMsg)
-- end

-- ---怪物的目标发生变化事件
-- ---生效范围：服务器&客户端
-- ---@param OldTarget AActor 旧目标
-- ---@param NewTarget AActor 新目标
-- function p1:OnTargetChange_BP(OldTarget, NewTarget)
    
-- end

return p1