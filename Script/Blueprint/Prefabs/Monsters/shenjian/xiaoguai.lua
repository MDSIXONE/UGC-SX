---@class xiaoguai_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local xiaoguai = {}
local UGCGameData = require("Script.Blueprint.UGCGameData")

function xiaoguai:ReceiveBeginPlay()
    xiaoguai.SuperClass.ReceiveBeginPlay(self)
    -- 属性由 GLQ_2:OnMobSpawn 根据层数设置，这里不需要额外处理
end

function xiaoguai:BPDie(KillingDamage, EventInstigator, DamageCauser, DamageEvent, DamageTypeID)
    if not self:HasAuthority() then return end

    -- 掉落物品
    self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})

    -- 给击杀者经验
    local killerPawn = nil
    if EventInstigator then
        killerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(EventInstigator)
    end
    if not killerPawn and DamageCauser then
        local ctrl = DamageCauser:GetController()
        if ctrl then killerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(ctrl) end
    end
    if killerPawn then
        local ps = UGCGameSystem.GetPlayerStateByPlayerPawn(killerPawn)
        if ps then
            -- 小怪给较少经验（基于当前层数）
            local GLQjiange = require("Script.Data.MobPoint.GLQjiange")
            local floor = GLQjiange and GLQjiange.CurrentFloor or 1
            local exp = 100 * floor
            if ps.AddExp then ps:AddExp(exp) end
            if ps.AddKillCount then ps:AddKillCount() end
        end
    end
end

return xiaoguai
