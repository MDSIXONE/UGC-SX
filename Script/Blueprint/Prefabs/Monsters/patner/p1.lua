---@class p1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local p1 = {}

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
            local timeoutClassPaths = {
                "Script.MODE.SingleModeTimeOut",
                "Script.MODE.SingleModeTimeOut.SingleModeTimeOut_C",
            }

            for _, classPath in ipairs(timeoutClassPaths) do
                local actorList = UGCGameSystem.GetAllActorsOfClass(classPath)
                if actorList and #actorList > 0 then
                    for _, actor in pairs(actorList) do
                        if actor and UGCObjectUtility.IsObjectValid(actor) then
                            timeoutActor = actor
                            break
                        end
                    end
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