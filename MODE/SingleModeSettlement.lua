---@class SingleModeSettlement_C:UGCSettlement
--Edit Below--
local SingleModeSettlement = {}

function SingleModeSettlement:LuaExecuteWithFinish(_, IsFinish)
    ugcprint("[SingleModeSettlement] ========== 结算阶段开始 ==========")
    
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
    end
    
    ugcprint("[SingleModeSettlement] IsFinish: " .. tostring(IsFinish))
    ugcprint("[SingleModeSettlement] 结算阶段触发完成，等待匹配成功")
end

return SingleModeSettlement