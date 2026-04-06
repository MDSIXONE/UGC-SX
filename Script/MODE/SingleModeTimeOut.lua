---@class SingleModeTimeOut_C:UGCTimeOut
--Edit Below--
local SingleModeTimeOut = {}

function SingleModeTimeOut:LuaExecute()
    -- ugcprint("[SingleModeTimeOut] ========== Timeout triggered ==========")

    -- Get all players in current level
    local AllPlayer = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    
    if AllPlayer and #AllPlayer > 0 then
        -- ugcprint("[SingleModeTimeOut] Player count: " .. tostring(#AllPlayer))
        
        for k, Player in pairs(AllPlayer) do
            -- ugcprint("[SingleModeTimeOut] Player " .. tostring(k) .. " timeout triggered")
            
            -- Save TimeOutActor reference
            Player.TimeoutFinishTriggered = false
            Player.TimeoutFinishProcessing = false
            Player.CurrentTimeOutActor = self
            -- ugcprint("[SingleModeTimeOut] Saved TimeOutActor reference in PlayerController")
            
            -- Show Settlement_2 UI via client RPC
            -- ugcprint("[SingleModeTimeOut] Call client RPC to show Settlement_2 UI")
            UnrealNetwork.CallUnrealRPC(Player, Player, "Client_ShowSettlement2UI")
        end
    else
        -- ugcprint("[SingleModeTimeOut] Warning: no players in current level")
        -- No players, finish directly
        self:OnFinish()
    end
    
    -- ugcprint("[SingleModeTimeOut] Timeout trigger completed")
end

return SingleModeTimeOut
