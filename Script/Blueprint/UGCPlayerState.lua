---@class UGCPlayerState_C:BP_UGCPlayerState_C
--Edit Below--
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local UGCPlayerState = 
{
    -- Rebirth level requirements array
    RebirthLevels = {25, 90, 180, 300, 450, 600, 750, 1000},
    -- Rebirth combat power requirements array (both level and combat power must be met)
    RebirthCombatPowers = {500, 5000, 25000, 80000, 300000, 600000, 2000000, 5000000},
}

-- ============ Task System Config ============
local TASK_RESET_HOUR = 0
local TASK_RESET_MINUTE = 0
local TASK_RESET_CHECK_INTERVAL = 60
local TASK1_KILL_COUNT_REQUIRED = 1
local TASK2_ONLINE_TIME_REQUIRED = 300
local TASK3_KILL_COUNT_REQUIRED = 3
local TASK4_ONLINE_TIME_REQUIRED = 900
local TASK5_SPEND_REQUIRED = 1
local TASK6_SHOPBUY_REQUIRED = 2

-- Default game data template
local DefaultGameData = 
{
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
    -- New talent system (9 talents)
    PlayerTalent1 = 0,
    PlayerTalent2 = 0,
    PlayerTalent3 = 0,
    PlayerTalent4 = 0,
    PlayerTalent5 = 0,
    PlayerTalent6 = 0,
    PlayerTalent7 = 0,
    PlayerTalent8 = 0,
    PlayerTalent9 = 0,
    -- Legacy talent fields (kept for compatibility)
    PlayerSpeedTalent = 0,
    PlayerAttackTalent = 0,
    PlayerHpTalent = 0,
    -- Direct exp toggle (default enabled)
    DirectExpEnabled = true,
    -- Auto absorb toggle (requires unlock 9001)
    AutoTunshiEnabled = false,
    -- Auto pickup toggle (requires unlock 9002)
    AutoPickupEnabled = false,
    -- Extra absorb exp bonus (percentage, initial 1%)
    PlayerEcexp = 1,
    -- VIP level (calculated by cumulative spend)
    PlayerVIP = 0,
    -- Endless Sword Pavilion highest floor
    PlayerJiangeFloor = 0,
    -- Sword system
    PlayerJiangeLevel = 1,
    PlayerJiangeProgress = 0,
    -- Shadow system (JSON string storage)
    PlayerShenyinData = "",
    -- Manual stat point system
    PlayerManualAttack = 0,
    PlayerManualMagic = 0,
    PlayerManualHp = 0,
    PlayerManualBland = 0,
    -- Bloodline attribute value
    PlayerBland = 0,
    -- Bloodline toggle state
    BloodlineEnabled = false,
    -- Jiange floor reward claim records (comma-separated claimed floors, e.g. "100,200,300")
    PlayerJiangeFloorClaimed = "",
    -- Jiange daily claim date (format "YYYY-MM-DD")
    PlayerJiangeDailyClaimDate = "",
}

-- Talent config table
local TALENT_CONFIG = {
    [1] = { cost = 1, maxLevel = 5 },
    [2] = { cost = 1, maxLevel = 5 },
    [4] = { cost = 3, maxLevel = 5 },
    [7] = { cost = 5, maxLevel = 5 },
    [8] = { cost = 5, maxLevel = 5 },
}
local ENABLED_TALENT_TYPES = {1, 2, 4, 7, 8}
local TALENT_UPGRADE_VIRTUAL_ITEM_ID = 5555
local TALENT_BUFF_PATH_BY_TYPE = {
    -- jing
    [2] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff1_C'),
    -- mu
    [1] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff4_C'),
    -- shui
    [4] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff3_C'),
    -- tu
    [8] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff5_C'),
    -- huo
    [7] = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff1.buff2_C'),
}
local MANUAL_POINT_COST = 1

-- Task config table
local TASK_CONFIG = {
    [1] = { requiredCount = TASK1_KILL_COUNT_REQUIRED, counterField = "KillCount" },
    [2] = { requiredCount = TASK2_ONLINE_TIME_REQUIRED, counterField = "OnlineTime" },
    [3] = { requiredCount = TASK3_KILL_COUNT_REQUIRED, counterField = "KillCount" },
    [4] = { requiredCount = TASK4_ONLINE_TIME_REQUIRED, counterField = "OnlineTime" },
    [5] = { requiredCount = TASK5_SPEND_REQUIRED, counterField = "SpendCount" },
    [6] = { requiredCount = TASK6_SHOPBUY_REQUIRED, counterField = "ShopBuyCount" },
}

-- Calculate VIP level by cumulative spend
local function CalcVIPLevelBySpend(spendCount)
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

function UGCPlayerState:GetTotalSpendCount()
    return tonumber(self.TotalSpendCount) or 0
end

function UGCPlayerState:SerializeClaimedChongzhi(claimedMap)
    if not claimedMap then
        return ""
    end

    local ids = {}
    for rewardID, claimed in pairs(claimedMap) do
        if claimed then
            table.insert(ids, tonumber(rewardID) or rewardID)
        end
    end

    table.sort(ids, function(a, b)
        return (tonumber(a) or 0) < (tonumber(b) or 0)
    end)

    local serialized = {}
    for _, rewardID in ipairs(ids) do
        table.insert(serialized, tostring(rewardID))
    end
    return table.concat(serialized, ",")
end

function UGCPlayerState:DeserializeClaimedChongzhi(claimedStr)
    local claimedMap = {}
    if not claimedStr or claimedStr == "" then
        return claimedMap
    end

    for token in string.gmatch(claimedStr, "([^,]+)") do
        local rewardID = tonumber(token)
        if rewardID then
            claimedMap[rewardID] = true
        end
    end
    return claimedMap
end

local function NormalizeClaimedChongzhiMap(claimedRaw)
    local claimedMap = {}
    if type(claimedRaw) ~= "table" then
        return claimedMap
    end

    for key, value in pairs(claimedRaw) do
        local keyID = tonumber(key)
        if keyID and (value == true or value == 1 or value == "1" or value == "true") then
            claimedMap[keyID] = true
        end

        local valueID = tonumber(value)
        if valueID and valueID > 0 then
            claimedMap[valueID] = true
        end
    end

    return claimedMap
end

function UGCPlayerState:ReceiveBeginPlay()
    UGCPlayerState.SuperClass.ReceiveBeginPlay(self)
    
    -- Create independent GameData and delegates for each instance
    self.GameData = {}
    self.PlayerLevelChangedDelegate = Delegate.New()
    
    -- Initialize task system data
    self.CompletedTasks = {}
    self.ClaimedTasks = {}
    self.UGCTask1Status = 0
    self.UGCTask2Status = 0
    self.UGCTask3Status = 0
    self.UGCTask4Status = 0
    self.UGCTask5Status = 0
    self.UGCTask6Status = 0
    self.OnlineTime = 0
    self.KillCount = 0
    self.SpendCount = 0
    self.TotalSpendCount = 0
    self.ShopBuyCount = 0
    self.LastResetDate = nil
    self.LastWeeklyResetWeek = nil
    self.ClaimedChongzhi = {}
    
    self:DataInit()
    
    -- Start timers on server
    if self:HasAuthority() then
        self:StartTaskResetTimer()
        self:StartOnlineTimer()
    end
end

function UGCPlayerState:DataInit()
    local isServer = UGCGameSystem.IsServer(self)
    
    local Uid = UGCGameSystem.GetUIDByPlayerState(self)
    local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)
    
    -- Initialize game record data
    if not Data.GameRecordData then
        local level1Cfg = UGCGameData.GetLevelConfig(1)
        local level1HP = level1Cfg and level1Cfg.AddHP or 21000
        local level1Attack = level1Cfg and level1Cfg.AddHIT or 2300
        local level1Magic = level1Cfg and level1Cfg.AddMG or 6900
        
        Data.GameRecordData = {
            UGCPlayerExp = 0,
            UGCPlayerLevel = 1,
            UGCPlayerHp = 100 + level1HP,
            UGCPlayerMaxHp = 100 + level1HP,
            UGCPlayerAttack = 20 + level1Attack,
            UGCPlayerMagic = 10 + level1Magic,
            UGCPlayerRebirthCount = 0,
            UGCPlayerTalentPoints = 0,
            UGCPlayerSpeedTalent = 0,
        }
    end

    if not Data.live then
        Data.live = 1
    end
    self.live = Data.live
    
    -- Read charge reward claim records (compatible with both table and serialized string formats)
    local claimedRaw = Data.GameRecordData.ClaimedChongzhi or {}
    if type(claimedRaw) == "string" then
        self.ClaimedChongzhi = self:DeserializeClaimedChongzhi(claimedRaw)
    else
        self.ClaimedChongzhi = NormalizeClaimedChongzhiMap(claimedRaw)
    end
    -- Total spend is used for cumulative recharge and VIP, daily task spend resets separately.
    self.TotalSpendCount = tonumber(Data.GameRecordData.TotalSpendCount) or 0
    self.SpendCount = 0
    
    -- Map archive fields to runtime fields
    for runtimeField, defaultValue in pairs(DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        self.GameData[runtimeField] = Data.GameRecordData[archiveField] or defaultValue
    end

    -- Recalculate VIP level from cumulative spend (compatible with old saves)
    self.GameData.PlayerVIP = CalcVIPLevelBySpend(self.TotalSpendCount)
    
    -- Fix old save attribute values
    if isServer and self.GameData.PlayerLevel then
        local correctMaxHp = 100
        local correctAttack = 20
        local correctMagic = 10
        
        for i = 1, self.GameData.PlayerLevel do
            local cfg = UGCGameData.GetLevelConfig(i)
            if cfg then
                correctMaxHp = correctMaxHp + (cfg.AddHP or 0)
                correctAttack = correctAttack + (cfg.AddHIT or 0)
                correctMagic = correctMagic + (cfg.AddMG or 0)
            end
        end
        
        correctMaxHp = correctMaxHp + (self.GameData.PlayerRebirthBonusHp or 0)
        correctAttack = correctAttack + (self.GameData.PlayerRebirthBonusAttack or 0)
        correctMagic = correctMagic + (self.GameData.PlayerRebirthBonusMagic or 0)
        
        -- Add manual stat points (HP 5 per point, Attack 2 per point, Magic 1 per point)
        correctMaxHp = correctMaxHp + (self.GameData.PlayerManualHp or 0) * 5
        correctAttack = correctAttack + (self.GameData.PlayerManualAttack or 0) * 2
        correctMagic = correctMagic + (self.GameData.PlayerManualMagic or 0) * 1
        
        if self.GameData.PlayerMaxHp ~= correctMaxHp then
            local hpRatio = self.GameData.PlayerHp / self.GameData.PlayerMaxHp
            self.GameData.PlayerMaxHp = correctMaxHp
            self.GameData.PlayerHp = math.floor(correctMaxHp * hpRatio)
        end
        
        if self.GameData.PlayerAttack ~= correctAttack then
            self.GameData.PlayerAttack = correctAttack
        end
        
        if self.GameData.PlayerMagic ~= correctMagic then
            self.GameData.PlayerMagic = correctMagic
        end
    end
    
    -- Initialize replicated properties on server
    if isServer then
        self:SyncReplicatedProperties()
        self:ApplyAllTalentBuffs()
        self:UpdateClientAttributes()
    else
        self:RequestServerInit()
    end
end

function UGCPlayerState:DataSave()
    if not UGCGameSystem.IsServer(self) then
        return
    end
    
    local Uid = UGCGameSystem.GetUIDByPlayerState(self)
    local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)
    
    if not Data.GameRecordData then
        Data.GameRecordData = {}
    end
    
    -- Read current HP from character before saving
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local currentHp = UGCAttributeSystem.GetGameAttributeValue(Player, 'Health')
        if currentHp and currentHp > 0 then
            self.GameData.PlayerHp = currentHp
        end
    end
    
    for runtimeField, defaultValue in pairs(DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        Data.GameRecordData[archiveField] = self.GameData[runtimeField] or defaultValue
    end
    
    -- Save charge reward claim records
    Data.GameRecordData.ClaimedChongzhi = self.ClaimedChongzhi or {}
    -- Save cumulative spend amount
    Data.GameRecordData.TotalSpendCount = self:GetTotalSpendCount()
    
    UGCPlayerStateSystem.SavePlayerArchiveData(Uid, Data)
end

function UGCPlayerState:GetRebirthRequiredLevel()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    if rebirthCount >= #UGCPlayerState.RebirthLevels then
        return UGCPlayerState.RebirthLevels[#UGCPlayerState.RebirthLevels]
    end
    return UGCPlayerState.RebirthLevels[rebirthCount + 1]
end

function UGCPlayerState:GetRebirthRequiredCombatPower()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    if rebirthCount >= #UGCPlayerState.RebirthCombatPowers then
        return UGCPlayerState.RebirthCombatPowers[#UGCPlayerState.RebirthCombatPowers]
    end
    return UGCPlayerState.RebirthCombatPowers[rebirthCount + 1]
end

function UGCPlayerState:CanRebirth()
    local requiredLevel = self:GetRebirthRequiredLevel()
    local requiredCombatPower = self:GetRebirthRequiredCombatPower()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    
    local currentLevel = self.GameData.PlayerLevel or 1
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        currentLevel = math.floor(UGCAttributeSystem.GetGameAttributeValue(Player, 'Level') or currentLevel)
    end
    
    local currentCombatPower = self:GetCombatPower()
    
    if rebirthCount >= #UGCPlayerState.RebirthLevels then
        return false, "已达到最大转生次数"
    end
    
    if currentLevel < requiredLevel then
        return false, "等级不足，需要" .. requiredLevel .. "级"
    end
    
    if currentCombatPower < requiredCombatPower then
        return false, "战斗力不足，需要" .. UGCGameData.FormatNumber(requiredCombatPower)
    end
    
    return true, "可以转生"
end

function UGCPlayerState:GetRebirthInfo()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    local requiredLevel = self:GetRebirthRequiredLevel()
    local requiredCombatPower = self:GetRebirthRequiredCombatPower()
    
    local currentLevel = self.GameData.PlayerLevel or 1
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        currentLevel = math.floor(UGCAttributeSystem.GetGameAttributeValue(Player, 'Level') or currentLevel)
    end
    
    local currentCombatPower = self:GetCombatPower()
    local canRebirth, reason = self:CanRebirth()
    
    return {
        rebirthCount = rebirthCount,
        requiredLevel = requiredLevel,
        currentLevel = currentLevel,
        requiredCombatPower = requiredCombatPower,
        currentCombatPower = currentCombatPower,
        canRebirth = canRebirth,
        reason = reason,
        maxRebirthCount = #UGCPlayerState.RebirthLevels
    }
end

function UGCPlayerState:DoRebirth()
    local canRebirth, reason = self:CanRebirth()
    if not canRebirth then
        return false, reason
    end
    
    -- Calculate current level attribute bonuses
    local currentLevelBonusHp = 0
    local currentLevelBonusAttack = 0
    local currentLevelBonusMagic = 0
    for i = 1, (self.GameData.PlayerLevel or 1) do
        local cfg = UGCGameData.GetLevelConfig(i)
        if cfg then
            currentLevelBonusHp = currentLevelBonusHp + (cfg.AddHP or 0)
            currentLevelBonusAttack = currentLevelBonusAttack + (cfg.AddHIT or 0)
            currentLevelBonusMagic = currentLevelBonusMagic + (cfg.AddMG or 0)
        end
    end
    
    -- Accumulate into rebirth bonuses
    self.GameData.PlayerRebirthBonusHp = (self.GameData.PlayerRebirthBonusHp or 0) + currentLevelBonusHp
    self.GameData.PlayerRebirthBonusAttack = (self.GameData.PlayerRebirthBonusAttack or 0) + currentLevelBonusAttack
    self.GameData.PlayerRebirthBonusMagic = (self.GameData.PlayerRebirthBonusMagic or 0) + currentLevelBonusMagic
    
    -- Increment rebirth count
    self.GameData.PlayerRebirthCount = (self.GameData.PlayerRebirthCount or 0) + 1
    
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerRebirthCount")
    end
    
    -- Reset level and exp
    self.GameData.PlayerLevel = 1
    self.GameData.PlayerExp = 0
    
    -- Calculate final attributes after rebirth (including manual points)
    local finalMaxHp = self:CalculateFinalMaxHp() + (self.GameData.PlayerManualHp or 0) * 5
    local finalAttack = self:CalculateFinalAttack() + (self.GameData.PlayerManualAttack or 0) * 2
    local finalMagic = self:CalculateFinalMagic() + (self.GameData.PlayerManualMagic or 0) * 1
    
    -- Reset base attribute values
    self.GameData.PlayerMaxHp = finalMaxHp
    self.GameData.PlayerAttack = finalAttack
    self.GameData.PlayerMagic = finalMagic
    
    -- Full heal
    self.GameData.PlayerHp = finalMaxHp
    
    self:UpdateClientAttributes()
    self:DataSave()
    
    return true, "转生成功"
end

function UGCPlayerState:NotifyExpBlockedByRebirth()
    if not UGCGameSystem.IsServer(self) then
        return
    end

    -- Rate limit to avoid spamming tips during frequent kills
    local nowSec = os.time()
    if self.LastExpBlockedTipTime and (nowSec - self.LastExpBlockedTipTime) < 2 then
        return
    end
    self.LastExpBlockedTipTime = nowSec

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnExpBlockedByRebirth")
    end
end

function UGCPlayerState:AddExp(Delta)
    if not Delta or Delta <= 0 then
        return
    end
    
    self:EnsureDataInitialized()
    
    local requiredLevel = self:GetRebirthRequiredLevel()
    if self.GameData.PlayerLevel >= requiredLevel then
        self:NotifyExpBlockedByRebirth()
        return
    end
    
    local InitialLevel = self.GameData.PlayerLevel
    local NewEXP = self.GameData.PlayerExp + Delta
    local hasLeveledUp = false

    while true do  
        if self.GameData.PlayerLevel >= requiredLevel then
            break
        end
        
        local Cfg = UGCGameData.GetLevelConfig(self.GameData.PlayerLevel)
        if not Cfg then
            break
        end
        
        if Cfg and Cfg.Exp and (NewEXP >= Cfg.Exp) then
            NewEXP = NewEXP - Cfg.Exp
            local NewLevel = self.GameData.PlayerLevel + 1
            
            if NewLevel > requiredLevel then
                NewEXP = NewEXP + Cfg.Exp
                break
            end
            
            self.GameData.PlayerLevel = NewLevel
            hasLeveledUp = true
            
            self:OnLevelUp(NewLevel)
            self:Client_OnPlayerLevelUp(self.GameData.PlayerLevel)
        else
            break
        end
    end
    
    self.GameData.PlayerExp = NewEXP
    
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerLevel = self.GameData.PlayerLevel
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerLevel")
    end
    
    self:UpdateClientAttributes(hasLeveledUp)
    self:DataSave()
end

function UGCPlayerState:GetCombatPower()
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

function UGCPlayerState:SyncCombatPower()
    if not UGCGameSystem.IsServer(self) then
        return
    end
    
    local combatPower = self:GetCombatPower()
    self.UGCPlayerCombatPower = combatPower
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerCombatPower")
end

function UGCPlayerState:UpdateCombatPowerRank(RankID)
    if not UGCGameSystem.IsServer(self) then
        return
    end
    
    RankID = RankID or 1
    
    local combatPower = self:GetCombatPower()
    local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local UID = UGCGameSystem.GetUIDByPlayerState(self)
    
    if PlayerController and UID and RankingListManager then
        RankingListManager:UpdatePlayerRankingScore(PlayerController, UID, RankID, combatPower)
    end
end

-- Update Jiange floor ranking (RankID=2)
function UGCPlayerState:UpdateJiangeFloorRank()
    if not UGCGameSystem.IsServer(self) then
        return
    end

    local floor = self.GameData.PlayerJiangeFloor or 0
    local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local UID = UGCGameSystem.GetUIDByPlayerState(self)

    if PlayerController and UID and RankingListManager then
        RankingListManager:UpdatePlayerRankingScore(PlayerController, UID, 2, floor)
    end
end

-- Update wealth ranking (RankID=3)
function UGCPlayerState:UpdateSpendRank()
    if not UGCGameSystem.IsServer(self) then
        return
    end

    local spend = self:GetTotalSpendCount()
    local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local UID = UGCGameSystem.GetUIDByPlayerState(self)

    if PlayerController and UID and RankingListManager then
        RankingListManager:UpdatePlayerRankingScore(PlayerController, UID, 3, spend)
    end
end

function UGCPlayerState:OnLevelUp(newLevel)
    local Cfg = UGCGameData.GetLevelConfig(newLevel)
    if not Cfg then
        return
    end
    
    local addHP = Cfg.AddHP or 0
    local addHIT = Cfg.AddHIT or 0
    local addMG = Cfg.AddMG or 0
    
    -- ugcprint("[OnLevelUp] Lv=" .. tostring(newLevel) .. " addHP=" .. tostring(addHP) .. " addHIT=" .. tostring(addHIT) .. " addMG=" .. tostring(addMG))
    
    self.GameData.PlayerMaxHp = self.GameData.PlayerMaxHp + addHP
    self.GameData.PlayerHp = self.GameData.PlayerMaxHp
    self.GameData.PlayerAttack = self.GameData.PlayerAttack + addHIT
    self.GameData.PlayerMagic = self.GameData.PlayerMagic + addMG
    
    -- ugcprint("[OnLevelUp] After levelup Magic=" .. tostring(self.GameData.PlayerMagic))
    
    -- Gain 1 talent point per level
    self.GameData.PlayerTalentPoints = (self.GameData.PlayerTalentPoints or 0) + 1
    
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerTalentPoints")
    end
end

function UGCPlayerState:EnsureDataInitialized()
    if not self.GameData or not self.GameData.PlayerLevel then
        self.GameData = self.GameData or {}
        self.PlayerLevelChangedDelegate = self.PlayerLevelChangedDelegate or Delegate.New()
        self:DataInit()
        return true
    end
    return false
end

-- Calculate applied bloodline value:
-- 1) Base is manual point PlayerBland
-- 2) If bloodline enabled and base < 1, use minimum 1 for effect
local function GetAppliedBlandValue(GameData)
    local bland = (GameData and GameData.PlayerBland) or 0
    if GameData and GameData.BloodlineEnabled == true and bland < 1 then
        bland = 1
    end
    return bland
end

function UGCPlayerState:UpdateClientAttributes(isLevelUp)
    if not UGCGameSystem.IsServer(self) then
        return
    end
    
    self:EnsureDataInitialized()

    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local finalMaxHp = self.GameData.PlayerMaxHp
        local finalAttack = self.GameData.PlayerAttack
        local finalMagic = self.GameData.PlayerMagic
        
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Level', self.GameData.PlayerLevel)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Health', self.GameData.PlayerHp)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'HealthMax', finalMaxHp)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Attack', finalAttack)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Magic', finalMagic)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'EXP', self.GameData.PlayerExp or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', (self.GameData.PlayerEcexp or 0) + (self.ShenyinEcexpBonus or 0))
        UGCAttributeSystem.SetGameAttributeValue(Player, 'bland', GetAppliedBlandValue(self.GameData))
        
        self:ApplyAllTalentBuffsInternal(Player)
        self:SyncCombatPower()
        self:UpdateCombatPowerRank()
    end
end

-- Generic attribute calculation function
function UGCPlayerState:CalculateFinalAttribute(baseValue, rebirthBonusField, configField)
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

function UGCPlayerState:CalculateFinalMaxHp()
    return self:CalculateFinalAttribute(100, "PlayerRebirthBonusHp", "AddHP")
end

function UGCPlayerState:CalculateFinalAttack()
    return self:CalculateFinalAttribute(20, "PlayerRebirthBonusAttack", "AddHIT")
end

function UGCPlayerState:CalculateFinalMagic()
    return self:CalculateFinalAttribute(10, "PlayerRebirthBonusMagic", "AddMG")
end

function UGCPlayerState:GetAvailableServerRPCs()
    return "Server_Rebirth", "Server_RequestInit", "Server_UnlockTalent", "Server_AddTalentPoint", "Server_AddTalentPointNew", "Server_ClaimTaskReward", "Server_AddSpendCount", "Server_AddShopBuyCount", "Server_SetDirectExpEnabled", "Server_SetAutoTunshiEnabled", "Server_SetAutoPickupEnabled", "Server_AddEcexp", "Server_SetBloodlineEnabled", "Server_CraftItem", "Server_SetShenyingSkill", "Server_SetShenyinEcexp", "Server_SetJiangeSkill", "Server_SetJiangeAtkBonus", "Server_RemoveVirtualItem", "Server_RemoveBackpackItem", "Server_ClaimChongzhiReward", "Server_GiveTaReward", "Server_SaveJiangeData", "Server_SaveShenyinData", "Server_AddManualPoint", "Server_ClaimJiangeFloorReward", "Server_ClaimJiangeDailyReward"
end

function UGCPlayerState:RequestServerInit()
    local pc = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if pc then
        UnrealNetwork.CallUnrealRPC(self, self, "Server_RequestInit")
    end
end

function UGCPlayerState:Server_RequestInit()
    self:EnsureDataInitialized()
    self:StartTaskResetTimer()
    self:StartOnlineTimer()
    self:UpdateClientAttributes()

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeData", self.GameData.PlayerJiangeLevel or 1, self.GameData.PlayerJiangeProgress or 0)
    end
end

function UGCPlayerState:Server_Rebirth()
    local success, message = self:DoRebirth()
end

--- Server RPC: add manual stat point
--- pointType: "attack", "magic", "hp", "bland"
function UGCPlayerState:Server_AddManualPoint(pointType)
    if not UGCGameSystem.IsServer(self) then return end

    local MANUAL_POINT_MAP = {
        attack = { dataField = "PlayerManualAttack", repField = "UGCPlayerManualAttack", addPerPoint = 2, targetField = "PlayerAttack", successTip = "攻击+2" },
        magic  = { dataField = "PlayerManualMagic",  repField = "UGCPlayerManualMagic",  addPerPoint = 1, targetField = "PlayerMagic", successTip = "魔法+1" },
        hp     = { dataField = "PlayerManualHp",     repField = "UGCPlayerManualHp",     addPerPoint = 5, targetField = "PlayerMaxHp", successTip = "生命+5" },
        bland  = { dataField = "PlayerManualBland",  repField = "UGCPlayerManualBland",  addPerPoint = 10, targetField = "PlayerBland", successTip = "血脉+10" },
    }

    local function NotifyManualPointResult(success, tipText)
        local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if not PC then
            return
        end

        local remainPoints = 0
        if self.GameData then
            remainPoints = self.GameData.PlayerTalentPoints or 0
        end

        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnManualPointResult", success == true, tostring(pointType or ""), remainPoints, tipText or "")
    end

    local info = MANUAL_POINT_MAP[pointType]
    if not info then
        NotifyManualPointResult(false, "加点类型无效")
        return
    end

    self:EnsureDataInitialized()

    local currentTalentPoints = self.GameData.PlayerTalentPoints or 0
    if currentTalentPoints < MANUAL_POINT_COST then
        NotifyManualPointResult(false, "天赋点不足")
        return
    end

    self.GameData.PlayerTalentPoints = currentTalentPoints - MANUAL_POINT_COST

    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerTalentPoints")

    -- Update point count
    local current = self.GameData[info.dataField] or 0
    self.GameData[info.dataField] = current + 1

    -- Sync replicated property to client
    self[info.repField] = self.GameData[info.dataField]
    UnrealNetwork.RepLazyProperty(self, info.repField)

    -- Add bonus to base value
    local oldValue = self.GameData[info.targetField] or 0
    self.GameData[info.targetField] = oldValue + info.addPerPoint
    
    -- ugcprint("[Server_AddManualPoint] " .. pointType .. " points=" .. tostring(self.GameData[info.dataField]) .. " " .. info.targetField .. ": " .. tostring(oldValue) .. "->" .. tostring(self.GameData[info.targetField]))

    -- Adjust HP proportionally
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local currentHp = UGCAttributeSystem.GetGameAttributeValue(Player, 'Health') or self.GameData.PlayerHp
        if currentHp > self.GameData.PlayerMaxHp then
            self.GameData.PlayerHp = self.GameData.PlayerMaxHp
        else
            self.GameData.PlayerHp = currentHp
        end
    end

    self:UpdateClientAttributes()
    self:DataSave()
    NotifyManualPointResult(true, info.successTip)
end

-- ============ Talent System ============

-- Server RPC: upgrade talent (new version with buff system)
function UGCPlayerState:Server_AddTalentPointNew(talentType)
    if not UGCGameSystem.IsServer(self) then return end

    talentType = math.floor(tonumber(talentType) or 0)
    self:EnsureDataInitialized()

    local function NotifyTalentUpgradeResult(success, level, remainCount, tipText)
        local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if not PC then
            return
        end

        local currentLevel = level
        if currentLevel == nil and self.GameData then
            currentLevel = self.GameData["PlayerTalent" .. tostring(talentType)] or 0
        end

        UnrealNetwork.CallUnrealRPC(
            PC,
            PC,
            "Client_OnTalentUpgradeResult",
            success == true,
            talentType,
            math.floor(tonumber(currentLevel) or 0),
            math.max(0, math.floor(tonumber(remainCount) or 0)),
            tipText or ""
        )
    end

    local config = TALENT_CONFIG[talentType]
    if not config then
        NotifyTalentUpgradeResult(false, nil, 0, "该天赋暂未开放")
        return
    end

    local dataField = "PlayerTalent" .. talentType
    local currentLevel = self.GameData[dataField] or 0

    if currentLevel >= config.maxLevel then
        NotifyTalentUpgradeResult(false, currentLevel, 0, "该天赋已满级")
        return
    end

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    if (not PC) or (not VirtualItemManager) then
        NotifyTalentUpgradeResult(false, currentLevel, 0, "材料系统未就绪")
        return
    end

    local function GetTalentItemCount()
        local queryOk, queryRet = pcall(function()
            return VirtualItemManager:GetItemNum(TALENT_UPGRADE_VIRTUAL_ITEM_ID, PC)
        end)
        if queryOk then
            return math.max(0, math.floor(tonumber(queryRet) or 0))
        end

        local fallbackOk, fallbackRet = pcall(function()
            return VirtualItemManager:GetItemNum(TALENT_UPGRADE_VIRTUAL_ITEM_ID)
        end)
        if fallbackOk then
            return math.max(0, math.floor(tonumber(fallbackRet) or 0))
        end

        return 0
    end

    local function ParseRemoveResult(result)
        if result == nil then
            return true
        end

        local resultType = type(result)
        if resultType == "boolean" then
            return result
        end
        if resultType == "number" then
            return result > 0
        end
        if resultType == "table" then
            if result.bSucceeded ~= nil then
                return result.bSucceeded == true
            end
            if result.bSuccess ~= nil then
                return result.bSuccess == true
            end
            if result.Success ~= nil then
                return result.Success == true
            end
            if result.Result ~= nil then
                return result.Result == true
            end
        end

        return false
    end

    local currentItemCount = GetTalentItemCount()
    if currentItemCount < config.cost then
        NotifyTalentUpgradeResult(false, currentLevel, currentItemCount, "虚拟物品5555不足")
        return
    end

    local removeResult = nil
    local removeOk = pcall(function()
        removeResult = VirtualItemManager:RemoveVirtualItem(PC, TALENT_UPGRADE_VIRTUAL_ITEM_ID, config.cost)
    end)
    if (not removeOk) or (not ParseRemoveResult(removeResult)) then
        NotifyTalentUpgradeResult(false, currentLevel, GetTalentItemCount(), "虚拟物品5555不足")
        return
    end

    local newLevel = currentLevel + 1
    self.GameData[dataField] = newLevel

    local repField = "UGCPlayerTalent" .. talentType
    self[repField] = self.GameData[dataField]
    UnrealNetwork.RepLazyProperty(self, repField)

    self:ApplyTalentBuff(talentType)
    self:UpdateCombatPowerRank()
    self:DataSave()

    NotifyTalentUpgradeResult(true, newLevel, GetTalentItemCount(), "")
end

-- Legacy talent upgrade (redirects to new version)
function UGCPlayerState:Server_UnlockTalent(talentIndex)
    self:Server_AddTalentPointNew(talentIndex)
end

function UGCPlayerState:Server_AddTalentPoint(talentType)
    self:Server_AddTalentPointNew(talentType)
end

-- Apply single talent buff
function UGCPlayerState:ApplyTalentBuff(talentType)
    local config = TALENT_CONFIG[talentType]
    if not config then 
        return 
    end
    
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then
        return
    end
    
    self:UpdateClientAttributes()
end

-- Apply all talent buffs using buff asset system
function UGCPlayerState:ApplyAllTalentBuffsInternal(Player)
    if not Player then return end

    for _, talentType in ipairs(ENABLED_TALENT_TYPES) do
        local dataField = "PlayerTalent" .. talentType
        local level = self.GameData[dataField] or 0
        local buffPath = TALENT_BUFF_PATH_BY_TYPE[talentType]

        if level > 0 and buffPath and buffPath ~= "" then
            UGCPersistEffectSystem.RemoveBuffByClass(Player, buffPath, -1, nil)
            local buffObj = UGCPersistEffectSystem.AddBuffByClass(Player, buffPath, nil, -1, level)
        end
    end
end

function UGCPlayerState:ApplyAllTalentBuffs()
    for _, talentType in ipairs(ENABLED_TALENT_TYPES) do
        local dataField = "PlayerTalent" .. talentType
        local level = self.GameData[dataField] or 0
        if level > 0 then
            self:ApplyTalentBuff(talentType)
        end
    end
end

-- Notify client of level up
function UGCPlayerState:Client_OnPlayerLevelUp(Level)
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnPlayerLevelUp", self.GameData.PlayerLevel)
    end
end

-- ============ Replicated Properties ============

function UGCPlayerState:GetReplicatedProperties()
    return 
        {"UGCPlayerLevel", "Lazy"},
        {"UGCPlayerRebirthCount", "Lazy"},
        {"UGCPlayerTalentPoints", "Lazy"},
        {"UGCPlayerSpeedTalent", "Lazy"},
        {"UGCPlayerAttackTalent", "Lazy"},
        {"UGCPlayerHpTalent", "Lazy"},
        {"UGCPlayerCombatPower", "Lazy"},
        {"UGCPlayerTalent1", "Lazy"},
        {"UGCPlayerTalent2", "Lazy"},
        {"UGCPlayerTalent3", "Lazy"},
        {"UGCPlayerTalent4", "Lazy"},
        {"UGCPlayerTalent5", "Lazy"},
        {"UGCPlayerTalent6", "Lazy"},
        {"UGCPlayerTalent7", "Lazy"},
        {"UGCPlayerTalent8", "Lazy"},
        {"UGCPlayerTalent9", "Lazy"},
        {"UGCTask1Status", "Lazy"},
        {"UGCTask2Status", "Lazy"},
        {"UGCTask3Status", "Lazy"},
        {"UGCTask4Status", "Lazy"},
        {"UGCTask5Status", "Lazy"},
        {"UGCTask6Status", "Lazy"},
        {"UGCDirectExpEnabled", "Lazy"},
        {"UGCPlayerEcexp", "Lazy"},
        {"UGCSpendCount", "Lazy"},
        {"UGCPlayerVIP", "Lazy"},
        {"UGCClaimedChongzhiStr", "Lazy"},
        {"UGCPlayerManualAttack", "Lazy"},
        {"UGCPlayerManualMagic", "Lazy"},
        {"UGCPlayerManualHp", "Lazy"},
        {"UGCPlayerManualBland", "Lazy"},
        {"UGCBloodlineEnabled", "Lazy"}
end

-- ============ OnRep Callbacks ============

function UGCPlayerState:OnRep_UGCPlayerLevel()
    if self.GameData then
        self.GameData.PlayerLevel = self.UGCPlayerLevel
    end
    self.PlayerLevelChangedDelegate:Broadcast(self.UGCPlayerLevel)
end

function UGCPlayerState:OnRep_UGCPlayerRebirthCount()
    if self.GameData then
        self.GameData.PlayerRebirthCount = self.UGCPlayerRebirthCount
    end
end

function UGCPlayerState:OnRep_UGCPlayerTalentPoints()
    if self.GameData then
        self.GameData.PlayerTalentPoints = self.UGCPlayerTalentPoints
    end
    self:NotifyTalentTreeRefresh()
end

function UGCPlayerState:OnRep_UGCPlayerCombatPower()
end

function UGCPlayerState:OnRep_UGCSpendCount()
    self.TotalSpendCount = tonumber(self.UGCSpendCount) or 0
    if self.GameData then
        local vip = self.UGCPlayerVIP
        if vip == nil then
            vip = CalcVIPLevelBySpend(self.TotalSpendCount)
        end
        self.GameData.PlayerVIP = tonumber(vip) or 0
    end
    self:NotifySpendUIRefresh()
end

function UGCPlayerState:OnRep_UGCPlayerVIP()
    if self.GameData then
        self.GameData.PlayerVIP = tonumber(self.UGCPlayerVIP) or 0
    end
end

function UGCPlayerState:OnRep_UGCClaimedChongzhiStr()
    self.ClaimedChongzhi = self:DeserializeClaimedChongzhi(self.UGCClaimedChongzhiStr)
    self:NotifySpendUIRefresh()
end

function UGCPlayerState:NotifyTalentTreeRefresh()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.TalentTree then
        local talentTree = pc.MMainUI.TalentTree
        if talentTree:GetVisibility() == ESlateVisibility.Visible then
            talentTree:RefreshUI()
        end
    end
end

function UGCPlayerState:NotifySpendUIRefresh()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if not pc or not pc.MMainUI then
        return
    end

    local activeUI = pc.MMainUI.active
    if activeUI and UGCObjectUtility.IsObjectValid(activeUI) and activeUI:GetVisibility() == ESlateVisibility.Visible then
        if activeUI.RefreshBuySlots then
            activeUI:RefreshBuySlots()
        end
    end
end

function UGCPlayerState:SyncSpendReplicatedProperties()
    self.UGCSpendCount = self:GetTotalSpendCount()
    self.UGCPlayerVIP = self.GameData and (self.GameData.PlayerVIP or 0) or 0
    self.UGCClaimedChongzhiStr = self:SerializeClaimedChongzhi(self.ClaimedChongzhi)
end

function UGCPlayerState:ReplicateSpendProperties()
    self:SyncSpendReplicatedProperties()
    UnrealNetwork.RepLazyProperty(self, "UGCSpendCount")
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerVIP")
    UnrealNetwork.RepLazyProperty(self, "UGCClaimedChongzhiStr")
end

-- Dynamic talent OnRep callbacks
for i = 1, 9 do
    UGCPlayerState["OnRep_UGCPlayerTalent" .. i] = function(self)
        if self.GameData then
            self.GameData["PlayerTalent" .. i] = self["UGCPlayerTalent" .. i]
        end
        self:NotifyTalentTreeRefresh()
    end
end

-- ============ SyncReplicatedProperties ============

function UGCPlayerState:SyncReplicatedProperties()
    self.UGCPlayerLevel = self.GameData.PlayerLevel
    self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    self.UGCPlayerCombatPower = self:GetCombatPower()
    self.UGCDirectExpEnabled = self.GameData.DirectExpEnabled
    self.UGCPlayerEcexp = self.GameData.PlayerEcexp
    self:SyncSpendReplicatedProperties()
    self.UGCPlayerManualAttack = self.GameData.PlayerManualAttack or 0
    self.UGCPlayerManualMagic = self.GameData.PlayerManualMagic or 0
    self.UGCPlayerManualHp = self.GameData.PlayerManualHp or 0
    self.UGCPlayerManualBland = self.GameData.PlayerManualBland or 0
    self.UGCBloodlineEnabled = self.GameData.BloodlineEnabled or false
    
    -- Sync talents
    for i = 1, 9 do
        self["UGCPlayerTalent" .. i] = self.GameData["PlayerTalent" .. i]
    end
    
    -- Sync legacy talents
    self.UGCPlayerSpeedTalent = self.GameData.PlayerSpeedTalent
    self.UGCPlayerAttackTalent = self.GameData.PlayerAttackTalent
    self.UGCPlayerHpTalent = self.GameData.PlayerHpTalent
    
    -- Batch replicate properties
    local repProps = {"UGCPlayerLevel", "UGCPlayerRebirthCount", "UGCPlayerTalentPoints", "UGCPlayerCombatPower",
                      "UGCPlayerSpeedTalent", "UGCPlayerAttackTalent", "UGCPlayerHpTalent", "UGCDirectExpEnabled", "UGCPlayerEcexp",
                      "UGCSpendCount", "UGCPlayerVIP", "UGCClaimedChongzhiStr",
                      "UGCPlayerManualAttack", "UGCPlayerManualMagic", "UGCPlayerManualHp", "UGCPlayerManualBland", "UGCBloodlineEnabled"}
    
    for i = 1, 9 do
        table.insert(repProps, "UGCPlayerTalent" .. i)
    end
    
    for _, prop in ipairs(repProps) do
        UnrealNetwork.RepLazyProperty(self, prop)
    end

    -- Sync Jiange floor to client
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        local floor = self.GameData.PlayerJiangeFloor or 0
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_UpdateJiangeFloor", floor)
    end

    -- Init Jiange floor ranking
    self:UpdateJiangeFloorRank()
end

-- ============ ReceiveEndPlay ============

function UGCPlayerState:ReceiveEndPlay(EndPlayReason)
    if UGCGameSystem.IsServer(self) then
        self:DataSave()
        self:StopTaskResetTimer()
        self:StopOnlineTimer()
    end
    
    UGCPlayerState.SuperClass.ReceiveEndPlay(self, EndPlayReason)
end

-- ============ Task System Functions ============

function UGCPlayerState:StartTaskResetTimer()
    if self.TaskResetTimer then
        return
    end
    
    self.TaskResetTimer = UGCTimerUtility.CreateLuaTimer(
        TASK_RESET_CHECK_INTERVAL,
        function()
            self:CheckDailyReset()
        end,
        true,
        "TaskResetTimer_" .. tostring(self)
    )
    
    self:CheckDailyReset()
end

function UGCPlayerState:CheckDailyReset()
    local currentTime = os.date("*t")
    local currentHour = currentTime.hour
    local currentMinute = currentTime.min
    local currentDate = string.format("%d-%02d-%02d", currentTime.year, currentTime.month, currentTime.day)
    
    if currentHour == TASK_RESET_HOUR and currentMinute >= TASK_RESET_MINUTE then
        if self.LastResetDate ~= currentDate then
            self.LastResetDate = currentDate
            self:ResetAllTasks()
        end
    end
end

function UGCPlayerState:StartOnlineTimer()
    if self.OnlineTimer then
        return
    end
    
    self.OnlineTime = 0
    
    self.OnlineTimer = UGCTimerUtility.CreateLuaTimer(
        1,
        function()
            self:OnOnlineTimerTick()
        end,
        true,
        "OnlineTimer_" .. tostring(self)
    )
end

function UGCPlayerState:StopOnlineTimer()
    if self.OnlineTimer then
        UGCTimerUtility.RemoveLuaTimer(self.OnlineTimer)
        self.OnlineTimer = nil
    end
end

function UGCPlayerState:OnOnlineTimerTick()
    self.OnlineTime = (self.OnlineTime or 0) + 1
    self:CheckTaskCompletion("OnlineTime")
end

-- Generic task completion check
function UGCPlayerState:CheckTaskCompletion(counterField)
    for taskId, config in pairs(TASK_CONFIG) do
        if config.counterField == counterField then
            local currentCount = self[counterField] or 0
            if currentCount >= config.requiredCount and not self:IsTaskCompleted(taskId) then
                self:SetTaskCompleted(taskId, true)
            end
        end
    end
end

function UGCPlayerState:StopTaskResetTimer()
    if self.TaskResetTimer then
        UGCTimerUtility.RemoveLuaTimer(self.TaskResetTimer)
        self.TaskResetTimer = nil
    end
end

function UGCPlayerState:ResetAllTasks()
    self.CompletedTasks = {}
    self.ClaimedTasks = {}
    self.OnlineTime = 0
    self.KillCount = 0
    self.SpendCount = 0
    self.ShopBuyCount = 0
    
    for i = 1, 6 do
        local statusField = "UGCTask" .. i .. "Status"
        self[statusField] = 0
        UnrealNetwork.RepLazyProperty(self, statusField)
    end
end

-- Dynamic task status OnRep callbacks
for i = 1, 6 do
    UGCPlayerState["OnRep_UGCTask" .. i .. "Status"] = function(self)
        self:NotifyTaskUIRefresh()
    end
end

function UGCPlayerState:IsTaskCompleted(taskRowIndex)
    if not self.CompletedTasks then
        self.CompletedTasks = {}
    end
    return self.CompletedTasks[taskRowIndex] == true
end

function UGCPlayerState:SetTaskCompleted(taskRowIndex, isComplete)
    if not self.CompletedTasks then
        self.CompletedTasks = {}
    end
    self.CompletedTasks[taskRowIndex] = isComplete
    self:SyncTaskStatus(taskRowIndex)
end

function UGCPlayerState:SyncTaskStatus(taskRowIndex)
    local statusField = "UGCTask" .. taskRowIndex .. "Status"
    self[statusField] = self:GetTaskStatus(taskRowIndex)
    UnrealNetwork.RepLazyProperty(self, statusField)
end

function UGCPlayerState:GetKillCount()
    return self.KillCount or 0
end

function UGCPlayerState:AddKillCount()
    self.KillCount = (self.KillCount or 0) + 1
    self:CheckTaskCompletion("KillCount")
end

function UGCPlayerState:GetSpendCount()
    return self.SpendCount or 0
end

function UGCPlayerState:AddSpendCount(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then
        return
    end

    self.SpendCount = (self.SpendCount or 0) + amount
    self.TotalSpendCount = self:GetTotalSpendCount() + amount
    self:CheckTaskCompletion("SpendCount")
end

function UGCPlayerState:IsTaskClaimed(taskRowIndex)
    if not self.ClaimedTasks then
        self.ClaimedTasks = {}
    end
    return self.ClaimedTasks[taskRowIndex] == true
end

function UGCPlayerState:SetTaskClaimed(taskRowIndex, isClaimed)
    if not self.ClaimedTasks then
        self.ClaimedTasks = {}
    end
    self.ClaimedTasks[taskRowIndex] = isClaimed
    self:SyncTaskStatus(taskRowIndex)
end

function UGCPlayerState:GetTaskStatus(taskRowIndex)
    if not self:HasAuthority() then
        local statusField = "UGCTask" .. taskRowIndex .. "Status"
        if self[statusField] then
            return self[statusField]
        end
    end
    
    local isCompleted = self:IsTaskCompleted(taskRowIndex)
    local isClaimed = self:IsTaskClaimed(taskRowIndex)
    
    if isClaimed then
        return 2
    elseif isCompleted then
        return 1
    else
        return 0
    end
end

function UGCPlayerState:Server_AddSpendCount(amount)
    if not UGCGameSystem.IsServer(self) then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then
        return
    end

    self:EnsureDataInitialized()
    self:AddSpendCount(amount)

    self.GameData.PlayerVIP = CalcVIPLevelBySpend(self:GetTotalSpendCount())
    self:ReplicateSpendProperties()
    self:UpdateSpendRank()
    self:DataSave()
end

function UGCPlayerState:Server_AddShopBuyCount()
    if not UGCGameSystem.IsServer(self) then return end
    self.ShopBuyCount = (self.ShopBuyCount or 0) + 1
    self:CheckTaskCompletion("ShopBuyCount")
end

function UGCPlayerState:Server_ClaimTaskReward(taskRowIndex)
    local taskStatus = self:GetTaskStatus(taskRowIndex)
    if taskStatus ~= 1 then
        return
    end
    
    local taskConfig = UGCGameData.GetTaskConfig(taskRowIndex)
    if not taskConfig or not taskConfig.taskawardid then
        return
    end
    
    local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if playerPawn then
        local awardNum = taskConfig.awardnum or 1
        UGCBackpackSystemV2.AddItemV2(playerPawn, taskConfig.taskawardid, awardNum)
    end
    
    self:SetTaskClaimed(taskRowIndex, true)
end

function UGCPlayerState:NotifyTaskUIRefresh()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if not pc then
        return
    end
    
    if pc.MMainUI and pc.MMainUI.TASK then
        local taskUI = pc.MMainUI.TASK
        if taskUI:GetVisibility() == ESlateVisibility.Visible then
            if taskUI.RefreshTaskUI then
                taskUI:RefreshTaskUI()
            end
        end
        return
    end
    
    if pc.TaskButtonUI then
        local taskButtonUI = pc.TaskButtonUI
        if taskButtonUI and taskButtonUI.TaskUI and UGCObjectUtility.IsObjectValid(taskButtonUI.TaskUI) then
            if taskButtonUI.TaskUI.RefreshTaskUI then
                taskButtonUI.TaskUI:RefreshTaskUI()
            end
        end
    end
end

-- ============ Feature Toggles ============

-- Server: set direct exp enabled
function UGCPlayerState:Server_SetDirectExpEnabled(isEnabled)
    self.GameData.DirectExpEnabled = isEnabled
    self.UGCDirectExpEnabled = isEnabled
    UnrealNetwork.RepLazyProperty(self, "UGCDirectExpEnabled")
    self:DataSave()
end

function UGCPlayerState:OnRep_UGCDirectExpEnabled()
    if self.GameData then
        self.GameData.DirectExpEnabled = self.UGCDirectExpEnabled
    end
end

-- Server: set auto absorb enabled
function UGCPlayerState:Server_SetAutoTunshiEnabled(isEnabled)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    self.GameData.AutoTunshiEnabled = (isEnabled == true)
    self:DataSave()
end

-- Server: set auto pickup enabled
function UGCPlayerState:Server_SetAutoPickupEnabled(isEnabled)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    self.GameData.AutoPickupEnabled = (isEnabled == true)
    self:DataSave()
end

-- Server: add extra exp bonus (Ecexp)
function UGCPlayerState:Server_AddEcexp(amount)
    if not UGCGameSystem.IsServer(self) then return end
    if not amount or amount <= 0 then
        return
    end
    
    self.GameData.PlayerEcexp = (self.GameData.PlayerEcexp or 0) + amount
    self.UGCPlayerEcexp = self.GameData.PlayerEcexp
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerEcexp")
    
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local totalEcexp = self.GameData.PlayerEcexp + (self.ShenyinEcexpBonus or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', totalEcexp)
    end
    
    self:DataSave()
end

function UGCPlayerState:OnRep_UGCPlayerEcexp()
    if self.GameData then
        self.GameData.PlayerEcexp = self.UGCPlayerEcexp
    end
end

-- Server: set Shenyin temp Ecexp bonus (not saved, clears on disconnect)
function UGCPlayerState:Server_SetShenyinEcexp(amount)
    if not UGCGameSystem.IsServer(self) then return end
    if not amount then return end
    self.ShenyinEcexpBonus = amount
    ugcprint("[Server_SetShenyinEcexp] Shenyin temp Ecexp=" .. tostring(amount))
    
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local totalEcexp = (self.GameData.PlayerEcexp or 0) + (self.ShenyinEcexpBonus or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', totalEcexp)
    end
end

-- Server: set bloodline enabled
function UGCPlayerState:Server_SetBloodlineEnabled(isEnabled)
    if not UGCGameSystem.IsServer(self) then return end
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then
        return
    end
    
    local skillPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/chaofeng.chaofeng_C')
    
    if isEnabled then
        local skill = UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
        if skill then
            self.GameData.BloodlineEnabled = true
            self.UGCBloodlineEnabled = true
        else
            return
        end
    else
        local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, skillPath)
        if skills and #skills > 0 then
            for _, skill in ipairs(skills) do
                UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
            end
        end
        self.GameData.BloodlineEnabled = false
        self.UGCBloodlineEnabled = false
    end
    
    UnrealNetwork.RepLazyProperty(self, "UGCBloodlineEnabled")
    UGCAttributeSystem.SetGameAttributeValue(Player, 'bland', isEnabled and 1 or 0)
    self:DataSave()
end

function UGCPlayerState:OnRep_UGCBloodlineEnabled()
    if self.GameData then
        self.GameData.BloodlineEnabled = self.UGCBloodlineEnabled
    end
end

-- ============ Crafting System ============

--- Server RPC: craft item
--- @param InputItemIDs table Input material ID array
--- @param InputCounts table Input material count array
--- @param OutputItemID number Output item ID
--- @param OutputCount number Output item count
function UGCPlayerState:Server_CraftItem(InputItemIDs, InputCounts, OutputItemID, OutputCount)
    ugcprint("[Server_CraftItem] ========== Server received craft request ==========")
    ugcprint("[Server_CraftItem] Output item: " .. tostring(OutputItemID) .. " x " .. tostring(OutputCount))
    
    local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not playerPawn then
        ugcprint("[Server_CraftItem] Error: cannot get player pawn")
        return
    end
    
    -- Check all material counts
    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        local currentCount = UGCBackpackSystemV2.GetItemCountV2(playerPawn, itemID)
        
        if currentCount < needCount then
            ugcprint("[Server_CraftItem] Material " .. i .. " insufficient: need=" .. needCount .. " have=" .. currentCount)
            return
        end
    end
    
    -- Remove all materials
    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        
        local removedCount = UGCBackpackSystemV2.RemoveItemV2(playerPawn, itemID, needCount)
        
        if removedCount == 0 then
            ugcprint("[Server_CraftItem] Error: material " .. i .. " cannot be removed (returned 0)")
            return
        end
        
        if removedCount ~= needCount then
            ugcprint("[Server_CraftItem] Warning: material " .. i .. " removed count mismatch (need:" .. needCount .. ", actual:" .. removedCount .. ")")
            return
        end
    end
    
    -- Add output item
    local addedCount, defineIDs = UGCBackpackSystemV2.AddItemV2(playerPawn, OutputItemID, OutputCount)
    ugcprint("[Server_CraftItem] Added " .. tostring(addedCount) .. " output items")
    
    if addedCount > 0 then
        ugcprint("[Server_CraftItem] Craft success!")
    else
        ugcprint("[Server_CraftItem] Craft failed: cannot add output item")
    end
end

-- ============ Shenyin (Shadow) Skill System ============

-- All Shenyin skill path prefixes (for server-side cleanup)
local ALL_SHENYIN_SKILLS = {"baise", "lvse", "lanse", "zise", "chengse", "hongse", "jinse"}

-- Server: set Shenyin passive skill (clear all first, then add new)
function UGCPlayerState:Server_SetShenyingSkill(skillPath, isWear)
    ugcprint("[Server_SetShenyingSkill] RPC received: skillPath=" .. tostring(skillPath) .. ", isWear=" .. tostring(isWear))
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    -- Remove all Shenyin skills (iterate all possible paths)
    for _, skillName in ipairs(ALL_SHENYIN_SKILLS) do
        for lv = 1, 5 do
            local path
            if lv == 1 then
                path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/' .. skillName .. '.' .. skillName .. '_C')
            else
                path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/SY' .. lv .. '/' .. skillName .. '.' .. skillName .. '_C')
            end
            local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, path)
            if skills and #skills > 0 then
                for _, skill in ipairs(skills) do
                    UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
                    ugcprint("[Server_SetShenyingSkill] Removed: " .. tostring(path))
                end
            end
        end
    end

    -- If wearing, add new skill
    if isWear then
        ugcprint("[Server_SetShenyingSkill] Adding: " .. tostring(skillPath))
        UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
    end
    ugcprint("[Server_SetShenyingSkill] Done")
end

-- ============ Jiange (Sword) Skill System ============

-- All Jiange skill names (for server-side cleanup)
local ALL_JIANGE_SKILLS = {"bailangjian", "kuishejian", "baihujian", "bifangjian", "qilingjian", "zhuquejian", "shenlongjian"}

-- Server: set Jiange passive skill (clear all first, then add new)
function UGCPlayerState:Server_SetJiangeSkill(skillPath, isWear)
    ugcprint("[Server_SetJiangeSkill] RPC received: skillPath=" .. tostring(skillPath) .. ", isWear=" .. tostring(isWear))
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    -- Remove all Jiange skills
    for _, skillName in ipairs(ALL_JIANGE_SKILLS) do
        local path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. skillName .. '.' .. skillName .. '_C')
        local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, path)
        if skills and #skills > 0 then
            for _, skill in ipairs(skills) do
                UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
                ugcprint("[Server_SetJiangeSkill] Removed: " .. tostring(path))
            end
        end
    end

    -- If wearing, add new skill
    if isWear then
        ugcprint("[Server_SetJiangeSkill] Adding: " .. tostring(skillPath))
        UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
    end
    ugcprint("[Server_SetJiangeSkill] Done")
end

-- ============ Additional Server RPCs (extended from base) ============

local function GrantRewardToPlayerState(playerState, itemID, itemCount)
    itemID = tonumber(itemID) or 0
    itemCount = math.floor(tonumber(itemCount) or 0)
    if itemID <= 0 or itemCount <= 0 then
        return false
    end

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(playerState)
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    if VirtualItemManager and PC then
        local addResult = nil
        local addOk = pcall(function()
            addResult = VirtualItemManager:AddVirtualItem(PC, itemID, itemCount)
        end)
        if addOk and (addResult == nil or addResult == true or (type(addResult) == "number" and addResult > 0)) then
            return true
        end
    end

    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local addedCount = UGCBackpackSystemV2.AddItemV2(PlayerPawn, itemID, itemCount)
        if addedCount == true then
            return true
        end
        if type(addedCount) == "number" and addedCount > 0 then
            return true
        end
    end

    return false
end

-- Server: remove virtual item
function UGCPlayerState:Server_RemoveVirtualItem(virtualItemID, count)
    if not UGCGameSystem.IsServer(self) then return end
    
    virtualItemID = tonumber(virtualItemID) or 0
    count = math.floor(tonumber(count) or 0)
    if virtualItemID <= 0 or count <= 0 then return end

    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if (not VirtualItemManager) or (not PC) then
        return
    end

    -- Jiange forge stone (5666) needs an explicit server confirmation callback.
    if virtualItemID == 5666 then
        local function GetRemainCount()
            local queryOk, queryRet = pcall(function()
                return VirtualItemManager:GetItemNum(virtualItemID, PC)
            end)
            if queryOk then
                return tonumber(queryRet) or 0
            end

            local fallbackOk, fallbackRet = pcall(function()
                return VirtualItemManager:GetItemNum(virtualItemID)
            end)
            if fallbackOk then
                return tonumber(fallbackRet) or 0
            end
            return 0
        end

        local function NotifyForgeConsumeResult(success, tipText)
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeForgeConsumeResult", success == true, GetRemainCount(), tipText or "")
        end

        local function ParseRemoveResult(result)
            if result == nil then
                return true
            end

            local resultType = type(result)
            if resultType == "boolean" then
                return result
            end
            if resultType == "number" then
                return result > 0
            end
            if resultType == "table" then
                if result.bSucceeded ~= nil then
                    return result.bSucceeded == true
                end
                if result.bSuccess ~= nil then
                    return result.bSuccess == true
                end
                if result.Success ~= nil then
                    return result.Success == true
                end
                if result.Result ~= nil then
                    return result.Result == true
                end
            end

            return false
        end

        local callbackDone = false
        local beforeCount = GetRemainCount()

        local callOk = pcall(function()
            VirtualItemManager:RemoveVirtualItem(PC, virtualItemID, count, function(result)
                callbackDone = true
                local success = ParseRemoveResult(result)
                if success then
                    NotifyForgeConsumeResult(true, "")
                else
                    NotifyForgeConsumeResult(false, "锻造石不足，无法升级")
                end
            end)
        end)

        if not callOk then
            local fallbackResult = nil
            local fallbackOk = pcall(function()
                fallbackResult = VirtualItemManager:RemoveVirtualItem(PC, virtualItemID, count)
            end)

            if (not fallbackOk) or (not ParseRemoveResult(fallbackResult)) then
                NotifyForgeConsumeResult(false, "锻造石不足，无法升级")
                return
            end

            NotifyForgeConsumeResult(true, "")
            return
        end

        -- Fallback path: if callback is not triggered, infer by item count delta.
        UGCGameSystem.SetTimer(self, function()
            if callbackDone then
                return
            end

            local afterCount = GetRemainCount()
            if afterCount <= (beforeCount - count) then
                NotifyForgeConsumeResult(true, "")
            else
                NotifyForgeConsumeResult(false, "锻造石不足，无法升级")
            end
        end, 0.35, false)

        return
    end

    VirtualItemManager:RemoveVirtualItem(PC, virtualItemID, count)
end

-- Server: remove backpack item
function UGCPlayerState:Server_RemoveBackpackItem(itemID, count)
    if not UGCGameSystem.IsServer(self) then return end
    
    itemID = tonumber(itemID) or 0
    count = math.floor(tonumber(count) or 0)
    if itemID <= 0 or count <= 0 then return end
    
    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        UGCBackpackSystemV2.RemoveItemV2(PlayerPawn, itemID, count)
    end
end

-- Server: claim charge reward
function UGCPlayerState:Server_ClaimChongzhiReward(rewardID)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    
    rewardID = math.floor(tonumber(rewardID) or 0)
    if rewardID <= 0 then return end

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local function NotifyChongzhiClaimResult(success, tipText)
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnChongzhiClaimResult", success == true, rewardID, tipText or "")
        end
    end

    self.ChongzhiClaimPending = self.ChongzhiClaimPending or {}
    if self.ChongzhiClaimPending[rewardID] then
        NotifyChongzhiClaimResult(false, "领取处理中，请稍后")
        return
    end
    self.ChongzhiClaimPending[rewardID] = true

    local function FinishClaim(success, tipText)
        self.ChongzhiClaimPending[rewardID] = nil
        NotifyChongzhiClaimResult(success, tipText)
    end
    
    if self.ClaimedChongzhi and (self.ClaimedChongzhi[rewardID] or self.ClaimedChongzhi[tostring(rewardID)]) then
        FinishClaim(false, "该奖励已领取")
        return
    end
    
    local rewardConfig = UGCGameData.GetChongzhiRewardConfig(rewardID)
    if not rewardConfig then
        FinishClaim(false, "奖励配置不存在")
        return
    end
    
    local requiredSpend = rewardConfig.RequiredSpend or 0
    local currentSpend = self:GetTotalSpendCount()
    if currentSpend < requiredSpend then
        FinishClaim(false, "累计充值不足，无法领取")
        return
    end
    
    local rewardItemID = tonumber(rewardConfig.RewardItemID or rewardConfig.ItemID or rewardConfig.itemid) or 0
    local rewardItemCount = math.floor(tonumber(rewardConfig.RewardItemCount or rewardConfig.ItemCount or rewardConfig.itemnum) or 0)
    if rewardItemID <= 0 or rewardItemCount <= 0 then
        FinishClaim(false, "奖励配置异常")
        return
    end

    if not GrantRewardToPlayerState(self, rewardItemID, rewardItemCount) then
        FinishClaim(false, "发放奖励失败，请稍后再试")
        return
    end
    
    if not self.ClaimedChongzhi then
        self.ClaimedChongzhi = {}
    end
    self.ClaimedChongzhi[rewardID] = true
    self:ReplicateSpendProperties()
    self:DataSave()
    FinishClaim(true, "充值奖励领取成功")
end

-- Server: give Jiange settlement reward
function UGCPlayerState:Server_GiveTaReward(floorNum)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    
    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        floorNum = math.floor(tonumber(self.GameData and self.GameData.PlayerJiangeFloor) or 0)
    end
    if floorNum <= 0 then return end

    if floorNum > (self.GameData.PlayerJiangeFloor or 0) then
        self.GameData.PlayerJiangeFloor = floorNum
        local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_UpdateJiangeFloor", floorNum)
        end
        self:UpdateJiangeFloorRank()
    end
    
    local rewardConfig = UGCGameData.GetTaSettlementReward(floorNum)
    if rewardConfig then
        local rewardItemID = tonumber(rewardConfig.ItemID or rewardConfig.itemid) or 0
        local rewardItemCount = math.floor(tonumber(rewardConfig.ItemCount or rewardConfig.itemcount or rewardConfig.itemnum) or 0)
        if rewardItemID > 0 and rewardItemCount > 0 then
            GrantRewardToPlayerState(self, rewardItemID, rewardItemCount)
        end

        local rewardExp = tonumber(rewardConfig.Exp or rewardConfig.exp) or 0
        if rewardExp > 0 then
            self:AddExp(rewardExp)
        end
    end
    
    self:DataSave()
end

-- Server: save Jiange data
function UGCPlayerState:Server_SaveJiangeData(jiangeLevel, jiangeProgress)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    
    local targetLevel = math.floor(tonumber(jiangeLevel) or 1)
    local targetProgress = tonumber(jiangeProgress) or 0
    targetProgress = math.max(0, math.min(100, targetProgress))
    targetProgress = math.floor(targetProgress * 10 + 0.5) / 10

    self.GameData.PlayerJiangeLevel = targetLevel
    self.GameData.PlayerJiangeProgress = targetProgress
    
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeData", self.GameData.PlayerJiangeLevel, self.GameData.PlayerJiangeProgress)
    end
    
    self:DataSave()
end

-- Server: save Shenyin data
function UGCPlayerState:Server_SaveShenyinData(dataStr)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    
    self.GameData.PlayerShenyinData = dataStr or ""
    
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncShenyinData", self.GameData.PlayerShenyinData)
    end
    
    self:DataSave()
end

-- Server: claim Jiange floor reward
function UGCPlayerState:Server_ClaimJiangeFloorReward(floorNum)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)

    local function NotifyFloorClaimResult(success, tipText)
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeFloorClaimResult", success, floorNum, tipText or "")
        end
    end
    
    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        NotifyFloorClaimResult(false, "参数错误")
        return
    end
    
    local currentFloor = self.GameData.PlayerJiangeFloor or 0
    if currentFloor < floorNum then
        NotifyFloorClaimResult(false, "当前层数不足，无法领取该层奖励")
        return
    end
    
    local claimed = self.GameData.PlayerJiangeFloorClaimed or ""
    if string.find("," .. claimed .. ",", "," .. tostring(floorNum) .. ",") then
        NotifyFloorClaimResult(false, "该层奖励已领取")
        return
    end
    
    local rewardConfig = UGCGameData.GetJiangeFloorReward(floorNum)
    local rewardItemID = tonumber(rewardConfig and (rewardConfig.ItemID or rewardConfig.itemid)) or 0
    local rewardItemCount = math.floor(tonumber(rewardConfig and (rewardConfig.ItemCount or rewardConfig.itemcount or rewardConfig.itemnum)) or 0)
    if rewardItemID <= 0 or rewardItemCount <= 0 then
        NotifyFloorClaimResult(false, "奖励配置异常")
        return
    end

    if not GrantRewardToPlayerState(self, rewardItemID, rewardItemCount) then
        NotifyFloorClaimResult(false, "领取失败，请稍后再试")
        return
    end
    
    if claimed == "" then
        self.GameData.PlayerJiangeFloorClaimed = tostring(floorNum)
    else
        self.GameData.PlayerJiangeFloorClaimed = claimed .. "," .. tostring(floorNum)
    end
    
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeRewardData",
            self.GameData.PlayerJiangeFloorClaimed,
            self.GameData.PlayerJiangeDailyClaimDate or "",
            1)
    end

    NotifyFloorClaimResult(true, tostring(floorNum) .. "层奖励领取成功")
    
    self:DataSave()
end

-- Server: claim Jiange daily reward
function UGCPlayerState:Server_ClaimJiangeDailyReward()
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()
    
    local todayStr = os.date("%Y-%m-%d")
    local lastClaimDate = self.GameData.PlayerJiangeDailyClaimDate or ""
    
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    
    if lastClaimDate == todayStr then
        if PC then
			UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", false, 0, "今日已领取过每日奖励")
        end
        return
    end
    
    local dailyRewardConfig = UGCGameData.GetJiangeDailyReward()
    local rewardItemID = tonumber(dailyRewardConfig and (dailyRewardConfig.ItemID or dailyRewardConfig.itemid)) or 0
    local rewardItemCount = math.floor(tonumber(dailyRewardConfig and (dailyRewardConfig.ItemCount or dailyRewardConfig.itemcount or dailyRewardConfig.itemnum)) or 0)
    if rewardItemID <= 0 or rewardItemCount <= 0 then
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", false, 0, "奖励配置异常")
        end
        return
    end

    if not GrantRewardToPlayerState(self, rewardItemID, rewardItemCount) then
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", false, 0, "领取失败，请稍后再试")
        end
        return
    end

    local amount = rewardItemCount
    
    self.GameData.PlayerJiangeDailyClaimDate = todayStr
    
    if PC then
		UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", true, amount, "领取成功！")
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeRewardData",
            self.GameData.PlayerJiangeFloorClaimed or "",
            self.GameData.PlayerJiangeDailyClaimDate,
            amount)
    end
    
    self:DataSave()
end

-- Server: set Jiange attack bonus percentage
function UGCPlayerState:Server_SetJiangeAtkBonus(bonusPercent)
    if not UGCGameSystem.IsServer(self) then return end
    bonusPercent = tonumber(bonusPercent) or 0
    self.JiangeAtkBonusPercent = bonusPercent
    self:UpdateClientAttributes()
    self:DataSave()
end

return UGCPlayerState
