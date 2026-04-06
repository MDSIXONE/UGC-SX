---@class SingleMode_1_LevelReward_C:UGCLevelReward
--Edit Below--
local SingleMode_1_LevelReward = {}

function SingleMode_1_LevelReward:LuaExecute()
    -- ugcprint("[LevelReward] ========== 关底奖励触发 ==========")
    
    -- 获取当前关卡内的所有玩家
    local AllPlayer = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    
    if AllPlayer and #AllPlayer > 0 then
        -- ugcprint("[LevelReward] 当前关卡玩家数量: " .. tostring(#AllPlayer))
        
        for k, v in pairs(AllPlayer) do
            -- ugcprint("[LevelReward] 玩家 " .. tostring(k) .. " 触发关底奖励")
            
            -- 在服务端的 PlayerController 中保存 LevelRewardActor 引用
            if v then
                v.LevelRewardFinishTriggered = false
                v.LevelRewardFinishProcessing = false
                v.CurrentLevelRewardActor = self
                -- ugcprint("[LevelReward] 在 PlayerController 中保存了 LevelRewardActor 引用")
                
                -- 通过客户端RPC显示 Settlement UI
                -- ugcprint("[LevelReward] 调用客户端RPC显示 Settlement UI")
                UnrealNetwork.CallUnrealRPC(v, v, "Client_ShowSettlementUI")
            end
        end
    else
        -- ugcprint("[LevelReward] 警告：当前关卡没有玩家")
        -- 如果没有玩家，直接完成
        self:OnFinish()
    end
    
    -- ugcprint("[LevelReward] 关底奖励触发完成，等待玩家点击 sure 按钮")
    -- 注意：不在这里调用 OnFinish()，等待玩家点击 sure 按钮后再调用
end

return SingleMode_1_LevelReward
