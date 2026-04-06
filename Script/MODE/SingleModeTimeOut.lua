---@class SingleModeTimeOut_C:UGCTimeOut
--Edit Below--
local SingleModeTimeOut = {}

function SingleModeTimeOut:LuaExecute()
    ugcprint("[SingleModeTimeOut] ========== 超时触发 ==========")
    self.bTimeOutFinished = false

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
