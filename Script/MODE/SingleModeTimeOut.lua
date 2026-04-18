---@class SingleModeTimeOut_C:UGCTimeOut
--Edit Below--
local SingleModeTimeOut = {}

local function StopAndCleanSingle1TriggerBoxes(worldContextObject, reasonTag)
    local triggerClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/TriggerBox_Single1.TriggerBox_Single1_C")
    if not triggerClassPath or triggerClassPath == "" then
        ugcprint("[SingleModeTimeOut] StopAndCleanSingle1 失败：TriggerBox_Single1 类路径为空")
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
            ugcprint("[SingleModeTimeOut] Global StopAndCleanSingle1 调用失败: " .. tostring(globalStopOrErr))
        end
    end

    if cleanedByGlobal > 0 then
        return cleanedByGlobal
    end

    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[SingleModeTimeOut] StopAndCleanSingle1 失败：WorldContextObject 为空")
        return 0
    end

    if (not UGCActorComponentUtility) or (not UGCActorComponentUtility.GetAllActorsOfClass) then
        ugcprint("[SingleModeTimeOut] StopAndCleanSingle1 失败：GetAllActorsOfClass 不可用")
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
                                ugcprint("[SingleModeTimeOut] StopAndCleanAll 调用失败: " .. tostring(stopErr))
                            end
                        end
                    end
                end
            else
                ugcprint("[SingleModeTimeOut] 查询 TriggerBox_Single1 失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
            end
        end
    end

    if cleanedCount > 0 then
        ugcprint("[SingleModeTimeOut] 已停止并清怪 TriggerBox_Single1 数量=" .. tostring(cleanedCount) .. ", reason=" .. tostring(reasonTag))
    else
        ugcprint("[SingleModeTimeOut] 未找到可处理的 TriggerBox_Single1, reason=" .. tostring(reasonTag))
    end

    return cleanedCount
end

function SingleModeTimeOut:LuaExecute()
    ugcprint("[SingleModeTimeOut] ========== 超时触发 ==========")
    self.bTimeOutFinished = false

    -- 超时触发后立即停刷清怪，避免匹配前继续刷出怪物。
    StopAndCleanSingle1TriggerBoxes(self, "TimeOut")

    -- 获取当前关卡内的所有玩家
    local AllPlayer = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    
    if AllPlayer and #AllPlayer > 0 then
        ugcprint("[SingleModeTimeOut] 当前关卡玩家数量: " .. tostring(#AllPlayer))
        
        for k, Player in pairs(AllPlayer) do
            ugcprint("[SingleModeTimeOut] 玩家 " .. tostring(k) .. " 触发超时")
            
            -- 保存 TimeOutActor 引用
            Player.CurrentTimeOutActor = self
            ugcprint("[SingleModeTimeOut] 在 PlayerController 中保存了 TimeOutActor 引用")
            
            -- 通过客户端RPC显示 Settlement_2 UI
            ugcprint("[SingleModeTimeOut] 调用客户端RPC显示 Settlement_2 UI")
            UnrealNetwork.CallUnrealRPC(Player, Player, "Client_ShowSettlement2UI")
        end
    else
        ugcprint("[SingleModeTimeOut] 警告：当前关卡没有玩家")
        -- 如果没有玩家，直接完成
        self.bTimeOutFinished = true
        self:OnFinish()
    end

    -- Watchdog: avoid dead-end if client timeout callbacks are lost.
    UGCTimerUtility.CreateLuaTimer(10.0, function()
        if self.bTimeOutFinished then
            return
        end

        self.bTimeOutFinished = true
        ugcprint("[SingleModeTimeOut] 10秒看门狗触发，自动调用 OnFinish()")
        self:OnFinish()
    end, false, "SingleMode_TimeOutWatchdog")
    
    ugcprint("[SingleModeTimeOut] 超时触发完成")
end

return SingleModeTimeOut
