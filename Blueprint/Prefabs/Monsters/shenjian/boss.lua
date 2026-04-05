---@class boss_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local boss = {}
local UGCGameData = require("Script.Blueprint.UGCGameData")

function boss:ReceiveBeginPlay()
    boss.SuperClass.ReceiveBeginPlay(self)
    -- 属性由 GLQ_2:OnMobSpawn 根据层数设置，这里不需要额外处理
end

function boss:BPDie(KillingDamage, EventInstigator, DamageCauser, DamageEvent, DamageTypeID)
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
            -- Boss给较多经验（基于当前层数）
            local GLQjiange = require("Script.Data.MobPoint.GLQjiange")
            local floor = GLQjiange and GLQjiange.CurrentFloor or 1
            local exp = 500 * floor
            if ps.AddExp then ps:AddExp(exp) end
            if ps.AddKillCount then ps:AddKillCount() end
            ugcprint("[boss] 死亡，层数=" .. floor .. "，给予经验=" .. exp)
        end
    end
end

return boss
