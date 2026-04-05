---@class UGCPlayerPawn_C:BP_UGCPlayerPawn_C
---@field chenghao chenghao_C
--Edit Below--
local UGCPlayerPawn = {
    bEnableAutoPickup = false;
    AutoPickupRange = 1000;
    AutoPickupInterval = 0.2;
    AutoPickupUnlockItemID = 9002;
    AutoPickupCheckInterval = 1.0;
    MaxAutoPickupPerTick = 8;
}

function UGCPlayerPawn:ReceiveBeginPlay()
    self.bVaultIsOpen = true
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)

    if UGCGameSystem.IsServer(self) then
        self:RefreshAutoPickupUnlockState()
        self:StartAutoPickupConditionTimer()
        self:StartAutoPickupTimer()
    end
end

function UGCPlayerPawn:ReceiveEndPlay(EndPlayReason)
    if UGCGameSystem.IsServer(self) then
        self:StopAutoPickupConditionTimer()
        self:StopAutoPickupTimer()
    end

    UGCPlayerPawn.SuperClass.ReceiveEndPlay(self, EndPlayReason)
end

-- 自动拾取开关（程序内可调用）
function UGCPlayerPawn:SetAutoPickupEnabled(bEnabled)
    self.bEnableAutoPickup = (bEnabled == true)
end

function UGCPlayerPawn:StartAutoPickupTimer()
    if self.AutoPickupTimer then
        return
    end

    self.AutoPickupTimer = UGCTimerUtility.CreateLuaTimer(
        self.AutoPickupInterval,
        function()
            self:TryAutoPickupOnce()
        end,
        true,
        "AutoPickupTimer_" .. tostring(self)
    )
end

function UGCPlayerPawn:StartAutoPickupConditionTimer()
    if self.AutoPickupConditionTimer then
        return
    end

    self.AutoPickupConditionTimer = UGCTimerUtility.CreateLuaTimer(
        self.AutoPickupCheckInterval,
        function()
            self:RefreshAutoPickupUnlockState()
        end,
        true,
        "AutoPickupConditionTimer_" .. tostring(self)
    )
end

function UGCPlayerPawn:StopAutoPickupConditionTimer()
    if self.AutoPickupConditionTimer then
        UGCTimerUtility.RemoveLuaTimer(self.AutoPickupConditionTimer)
        self.AutoPickupConditionTimer = nil
    end
end

function UGCPlayerPawn:RefreshAutoPickupUnlockState()
    local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(self)
    local autoPickupEnabled = playerState and playerState.GameData and playerState.GameData.AutoPickupEnabled
    if autoPickupEnabled ~= true then
        self:SetAutoPickupEnabled(false)
        return
    end

    local playerController = UGCGameSystem.GetPlayerControllerByPlayerPawn(self)
    if playerController == nil then
        self:SetAutoPickupEnabled(false)
        return
    end

    local virtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if virtualItemManager == nil then
        self:SetAutoPickupEnabled(false)
        return
    end

    local itemNum = virtualItemManager:GetItemNum(self.AutoPickupUnlockItemID, playerController) or 0
    self:SetAutoPickupEnabled(itemNum > 0)
end

function UGCPlayerPawn:StopAutoPickupTimer()
    if self.AutoPickupTimer then
        UGCTimerUtility.RemoveLuaTimer(self.AutoPickupTimer)
        self.AutoPickupTimer = nil
    end
end

function UGCPlayerPawn:TryAutoPickupOnce()
    if not self.bEnableAutoPickup then
        return
    end

    local center = self:K2_GetActorLocation()
    if center == nil then
        return
    end

    local wrappers = UGCItemSystemV2.FindPickupWrapperActorByRange(center, self.AutoPickupRange)
    if wrappers == nil then
        return
    end

    for _, wrapperActor in pairs(wrappers) do
        if wrapperActor ~= nil then
            UGCItemSystemV2.TryPickupWrapperItem(self, wrapperActor)
        end
    end
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
