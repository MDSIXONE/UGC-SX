---@class SingleModeSettlement_C:UGCSettlement
--Edit Below--
local SingleModeSettlement = {}

local function StopAndCleanSingle1TriggerBoxes(worldContextObject, reasonTag)
    local triggerClassPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/MODE/TriggerBox_Single1.TriggerBox_Single1_C")
    if not triggerClassPath or triggerClassPath == "" then
        ugcprint("[SingleModeSettlement] StopAndCleanSingle1 失败：TriggerBox_Single1 类路径为空")
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
            ugcprint("[SingleModeSettlement] Global StopAndCleanSingle1 调用失败: " .. tostring(globalStopOrErr))
        end
    end

    if cleanedByGlobal > 0 then
        return cleanedByGlobal
    end

    local worldContext = worldContextObject or UGCGameSystem.GameState or UGCGameSystem.GameMode
    if not worldContext then
        ugcprint("[SingleModeSettlement] StopAndCleanSingle1 失败：WorldContextObject 为空")
        return 0
    end

    if (not UGCActorComponentUtility) or (not UGCActorComponentUtility.GetAllActorsOfClass) then
        ugcprint("[SingleModeSettlement] StopAndCleanSingle1 失败：GetAllActorsOfClass 不可用")
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
                                ugcprint("[SingleModeSettlement] StopAndCleanAll 调用失败: " .. tostring(stopErr))
                            end
                        end
                    end
                end
            else
                ugcprint("[SingleModeSettlement] 查询 TriggerBox_Single1 失败, classPath=" .. tostring(classPath) .. ", err=" .. tostring(actorListOrErr))
            end
        end
    end

    if cleanedCount > 0 then
        ugcprint("[SingleModeSettlement] 已停止并清怪 TriggerBox_Single1 数量=" .. tostring(cleanedCount) .. ", reason=" .. tostring(reasonTag))
    else
        ugcprint("[SingleModeSettlement] 未找到可处理的 TriggerBox_Single1, reason=" .. tostring(reasonTag))
    end

    return cleanedCount
end

function SingleModeSettlement:LuaExecuteWithFinish(_, IsFinish)
    ugcprint("[SingleModeSettlement] ========== 结算阶段开始 ==========")

    -- 进入结算阶段立即停刷清怪，避免结算期间继续刷出怪物。
    StopAndCleanSingle1TriggerBoxes(self, "Settlement")

    -- 获取当前关卡内的所有玩家
    local AllPlayer = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    
    if AllPlayer and #AllPlayer > 0 then
        ugcprint("[SingleModeSettlement] 玩家数量: " .. #AllPlayer)
        for k, v in pairs(AllPlayer) do
            ugcprint("[SingleModeSettlement] 玩家 " .. k .. " 进行结算")
            
            -- 直接通过客户端RPC显示 SettlementTip UI 并发起匹配
            if v then
                ugcprint("[SingleModeSettlement] 调用客户端RPC显示 SettlementTip UI")
                UnrealNetwork.CallUnrealRPC(v, v, "Client_ShowSettlementTipUI")
            end
        end
    else
        ugcprint("[SingleModeSettlement] 警告：AllPlayer 为空")
        -- 如果没有玩家，直接完成
        self:OnFinish()
        return
    end
    
    ugcprint("[SingleModeSettlement] IsFinish: " .. tostring(IsFinish))
    ugcprint("[SingleModeSettlement] 结算阶段触发完成，等待匹配成功")
end

return SingleModeSettlement
