---@class Config_PlayerData
---Player data configuration constants, default templates, and helpers.

local Config_PlayerData = {}

---Rebirth level requirements array
Config_PlayerData.RebirthLevels = {25, 90, 180, 300, 450, 600, 750, 1000}

---Rebirth combat power requirements array (both level and combat power must be met)
Config_PlayerData.RebirthCombatPowers = {500, 5000, 25000, 80000, 300000, 600000, 2000000, 5000000}

---Default game data template
Config_PlayerData.DefaultGameData = {
    PlayerExp = 0,
    PlayerLevel = 1,
    PlayerHp = 100,
    PlayerMaxHp = 100,
    PlayerAttack = 20,
    PlayerMagic = 10,
    PlayerRebirthCount = 0,
    PlayerTalentPoints = 0,
    PlayerRebirthBonusHp = 0,
    PlayerRebirthBonusAttack = 0,
    PlayerRebirthBonusMagic = 0,
    PlayerTalent1 = 0,
    PlayerTalent2 = 0,
    PlayerTalent3 = 0,
    PlayerTalent4 = 0,
    PlayerTalent5 = 0,
    PlayerTalent6 = 0,
    PlayerTalent7 = 0,
    PlayerTalent8 = 0,
    PlayerTalent9 = 0,
    PlayerSpeedTalent = 0,
    PlayerAttackTalent = 0,
    PlayerHpTalent = 0,
    DirectExpEnabled = true,
    AutoTunshiEnabled = false,
    AutoPickupEnabled = false,
    PlayerEcexp = 1,
    PlayerVIP = 0,
    PlayerJiangeFloor = 0,
    PlayerJiangeLevel = 1,
    PlayerJiangeProgress = 0,
    PlayerShenyinData = "",
    PlayerManualAttack = 0,
    PlayerManualMagic = 0,
    PlayerManualHp = 0,
    PlayerManualBland = 0,
    PlayerBland = 0,
    BloodlineEnabled = false,
    PlayerJiangeFloorClaimed = "",
    PlayerJiangeDailyClaimDate = "",
}

---Talent config table
Config_PlayerData.TALENT_CONFIG = {
    [1] = { cost = 1, maxLevel = 5 },
    [2] = { cost = 1, maxLevel = 5 },
    [4] = { cost = 3, maxLevel = 5 },
    [7] = { cost = 5, maxLevel = 5 },
    [8] = { cost = 5, maxLevel = 5 },
}

Config_PlayerData.ENABLED_TALENT_TYPES = {1, 2, 4, 7, 8}
Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID = 5555
Config_PlayerData.MANUAL_POINT_COST = 1

---Talent buff asset paths by type
Config_PlayerData.TALENT_BUFF_PATH_BY_TYPE = {
    [2] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff1_C'),
    [1] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff4_C'),
    [4] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff3_C'),
    [8] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff5_C'),
    [7] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff2_C'),
}

---Manual stat point config
Config_PlayerData.MANUAL_POINT_MAP = {
    attack = { dataField = "PlayerManualAttack", repField = "UGCPlayerManualAttack", addPerPoint = 2, targetField = "PlayerAttack", successTip = "攻击+2" },
    magic  = { dataField = "PlayerManualMagic",  repField = "UGCPlayerManualMagic",  addPerPoint = 1, targetField = "PlayerMagic", successTip = "魔法+1" },
    hp     = { dataField = "PlayerManualHp",     repField = "UGCPlayerManualHp",     addPerPoint = 5, targetField = "PlayerMaxHp", successTip = "生命+5" },
    bland  = { dataField = "PlayerManualBland",  repField = "UGCPlayerManualBland",  addPerPoint = 10, targetField = "PlayerBland", successTip = "血脉+10" },
}

---All Shenyin skill path prefixes (for server-side cleanup)
Config_PlayerData.ALL_SHENYIN_SKILLS = {"baise", "lvse", "lanse", "zise", "chengse", "hongse", "jinse"}

---All Jiange skill names (for server-side cleanup)
Config_PlayerData.ALL_JIANGE_SKILLS = {"bailangjian", "kuishejian", "baihujian", "bifangjian", "qilingjian", "zhuquejian", "shenlongjian"}

---Bloodline skill path
Config_PlayerData.BLOODLINE_SKILL_PATH = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/chaofeng.chaofeng_C')

---Auto feature unlock item IDs
Config_PlayerData.AUTO_TUNSHI_UNLOCK_ITEM_ID = 9001
Config_PlayerData.AUTO_PICKUP_UNLOCK_ITEM_ID = 9002
Config_PlayerData.AUTO_TUNSHI_PRODUCT_ID = 9000112
Config_PlayerData.AUTO_PICKUP_PRODUCT_ID = 9000113

---Jiange reward config
Config_PlayerData.JiangeRewardVirtualItemID = 5666
Config_PlayerData.JiangeDailyRewardCount = 1
Config_PlayerData.JiangeSettlementRewardCount = 1
Config_PlayerData.JiangeFloorRewardConfig = {
    [100] = 100, [200] = 200, [300] = 300, [400] = 400,
    [500] = 500, [600] = 600, [700] = 700, [800] = 800,
    [900] = 900, [1000] = 1000,
}

---Calculate VIP level by cumulative spend
function Config_PlayerData.CalcVIPLevelBySpend(spendCount)
    spendCount = tonumber(spendCount) or 0
    if spendCount >= 3000 then
        return 7
    elseif spendCount >= 1000 then
        return 6
    elseif spendCount >= 648 then
        return 5
    elseif spendCount >= 168 then
        return 4
    elseif spendCount >= 98 then
        return 3
    elseif spendCount >= 30 then
        return 2
    elseif spendCount >= 6 then
        return 1
    end
    return 0
end

return Config_PlayerData
