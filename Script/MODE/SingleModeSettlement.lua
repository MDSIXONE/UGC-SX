---@class SingleModeSettlement_C:UGCSettlement
--Edit Below--
local SingleModeSettlement = {}

function SingleModeSettlement:LuaExecuteWithFinish(_, IsFinish)
    -- ugcprint("[SingleModeSettlement] ========== Settlement phase started ==========")

    -- Get all players in current level
    local AllPlayer = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    
    if AllPlayer and #AllPlayer > 0 then
        -- ugcprint("[SingleModeSettlement] Player count: " .. #AllPlayer)
        for k, v in pairs(AllPlayer) do
            -- ugcprint("[SingleModeSettlement] Player " .. k .. " settling")
            
            -- Call client RPC to show SettlementTip UI and start matching
            if v then
                -- ugcprint("[SingleModeSettlement] Call client RPC to show SettlementTip UI")
                UnrealNetwork.CallUnrealRPC(v, v, "Client_ShowSettlementTipUI")
            end
        end
    else
        -- ugcprint("[SingleModeSettlement] Warning: AllPlayer is empty")
        -- ugcprint("[SingleModeSettlement] No players, skip settlement phase")
        self:OnFinish()
        return
    end
    
    -- ugcprint("[SingleModeSettlement] IsFinish: " .. tostring(IsFinish))
    -- ugcprint("[SingleModeSettlement] Settlement phase done, call OnFinish to continue level flow")
    self:OnFinish()
end

return SingleModeSettlement
