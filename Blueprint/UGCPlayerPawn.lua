---@class UGCPlayerPawn_C:BP_UGCPlayerPawn_C
---@field chenghao chenghao_C
--Edit Below--
local UGCPlayerPawn = {}

function UGCPlayerPawn:ReceiveBeginPlay()
    self.bVaultIsOpen = true
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)
end

function UGCPlayerPawn:GetReplicatedProperties()
    return {"__SubObjectRepList", "Lazy"}
end

-- 当HealthMax属性变化时调用（服务器端）
function UGCPlayerPawn:OnHealthMaxChanged(OldValue, NewValue)
    --ugcprint("[UGCPlayerPawn] HealthMax 变化: " .. tostring(OldValue) .. " -> " .. tostring(NewValue))
    
    -- 只在服务器端处理
    if not UGCGameSystem.IsServer(self) then
        return
    end
    
    -- 获取PlayerState并更新战斗力
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerPawn(self)
    if PlayerState then
        -- 同步GameData中的PlayerMaxHp
        if PlayerState.GameData then
            PlayerState.GameData.PlayerMaxHp = NewValue
            --ugcprint("[UGCPlayerPawn] 同步 PlayerState.GameData.PlayerMaxHp: " .. tostring(NewValue))
        end
        
        -- 同步战斗力到客户端
        if PlayerState.SyncCombatPower then
            PlayerState:SyncCombatPower()
        end
        
        -- 更新战斗力排行榜
        if PlayerState.UpdateCombatPowerRank then
            PlayerState:UpdateCombatPowerRank()
        end
    end
end

return UGCPlayerPawn
