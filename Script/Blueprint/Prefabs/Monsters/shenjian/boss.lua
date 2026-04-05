---@class boss_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local boss = {}
local UGCGameData = require("Script.Blueprint.UGCGameData")

function boss:ReceiveBeginPlay()
    boss.SuperClass.ReceiveBeginPlay(self)
    -- 灞炴€х敱 GLQ_2:OnMobSpawn 鏍规嵁灞傛暟璁剧疆锛岃繖閲屼笉闇€瑕侀澶栧鐞?
end

function boss:BPDie(KillingDamage, EventInstigator, DamageCauser, DamageEvent, DamageTypeID)
    if not self:HasAuthority() then return end

    -- 鎺夎惤鐗╁搧
    self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})

    -- 缁欏嚮鏉€鑰呯粡楠?
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
            -- Boss缁欒緝澶氱粡楠岋紙鍩轰簬褰撳墠灞傛暟锛?
            local GLQjiange = require("Script.Data.MobPoint.GLQjiange")
            local floor = GLQjiange and GLQjiange.CurrentFloor or 1
            local exp = 500 * floor
            if ps.AddExp then ps:AddExp(exp) end
            if ps.AddKillCount then ps:AddKillCount() end
            -- ugcprint("[boss] 姝讳骸锛屽眰鏁?" .. floor .. "锛岀粰浜堢粡楠?" .. exp)
        end
    end
end

return boss
