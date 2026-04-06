---@class boss_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local boss = {}
local UGCGameData = require("Script.Blueprint.UGCGameData")

function boss:ReceiveBeginPlay()
    boss.SuperClass.ReceiveBeginPlay(self)
    -- Attributes are configured by GLQ_2:OnMobSpawn based on current floor.
end

function boss:BPDie(KillingDamage, EventInstigator, DamageCauser, DamageEvent, DamageTypeID)
    if not self:HasAuthority() then return end

    -- Drop items.
    self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})

    -- Grant exp to killer.
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
            -- Boss grants more exp (scaled by current floor).
            local GLQjiange = require("Script.Data.MobPoint.GLQjiange")
            local floor = GLQjiange and GLQjiange.CurrentFloor or 1
            local exp = 500 * floor
            if ps.AddExp then ps:AddExp(exp) end
            -- ugcprint("[boss] died, floor=" .. floor .. ", exp=" .. exp)
        end
    end
end

return boss
