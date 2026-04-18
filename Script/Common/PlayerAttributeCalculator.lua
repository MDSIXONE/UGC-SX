---@class PlayerAttributeCalculator
---Player attribute calculation helpers (HP, Attack, Magic, Combat Power).

local PlayerAttributeCalculator = {}

---Calculate applied bloodline value:
---1) Base is manual point PlayerBland
---2) If bloodline enabled and base < 1, use minimum 1 for effect
function PlayerAttributeCalculator.GetAppliedBlandValue(GameData)
    local bland = (GameData and GameData.PlayerBland) or 0
    if GameData and GameData.BloodlineEnabled == true and bland < 1 then
        bland = 1
    end
    return bland
end

---Generic attribute calculation function
function PlayerAttributeCalculator.CalculateFinalAttribute(self, baseValue, rebirthBonusField, configField)
    local rebirthBonus = self.GameData[rebirthBonusField] or 0
    local levelBonus = 0

    for i = 1, (self.GameData.PlayerLevel or 1) do
        local cfg = UGCGameData.GetLevelConfig(i)
        if cfg and cfg[configField] then
            levelBonus = levelBonus + cfg[configField]
        end
    end

    return baseValue + rebirthBonus + levelBonus
end

function PlayerAttributeCalculator.CalculateFinalMaxHp(self)
    return self:CalculateFinalAttribute(100, "PlayerRebirthBonusHp", "AddHP")
end

function PlayerAttributeCalculator.CalculateFinalAttack(self)
    return self:CalculateFinalAttribute(20, "PlayerRebirthBonusAttack", "AddHIT")
end

function PlayerAttributeCalculator.CalculateFinalMagic(self)
    return self:CalculateFinalAttribute(10, "PlayerRebirthBonusMagic", "AddMG")
end

function PlayerAttributeCalculator.GetCombatPower(self)
    local maxHp = 100
    local attack = 20
    local magic = 10

    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        maxHp = UGCAttributeSystem.GetGameAttributeValue(Player, 'HealthMax') or self.GameData.PlayerMaxHp or 100
        attack = UGCAttributeSystem.GetGameAttributeValue(Player, 'Attack') or self.GameData.PlayerAttack or 20
        magic = UGCAttributeSystem.GetGameAttributeValue(Player, 'Magic') or self.GameData.PlayerMagic or 10
    else
        maxHp = self.GameData.PlayerMaxHp or 100
        attack = self.GameData.PlayerAttack or 20
        magic = self.GameData.PlayerMagic or 10
    end

    local combatPower = math.floor(maxHp * 0.05 + attack * 0.7 + magic * 0.25)
    return combatPower
end

return PlayerAttributeCalculator
