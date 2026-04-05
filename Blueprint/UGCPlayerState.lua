---@class UGCPlayerState_C:BP_UGCPlayerState_C
--Edit Below--
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local UGCPlayerState = 
{
    -- 转生等级数组，定义每次转生所需的等级
    RebirthLevels = {25, 90, 180, 300, 450, 600, 750},
    -- 转生战斗力数组，定义每次转生所需的战斗力（与等级同时满足才能转生）
    RebirthCombatPowers = {2000, 75000, 540000, 3000000, 12000000, 45000000, 120000000},
}

-- ============ 任务系统配置 ============
local TASK_RESET_HOUR = 0
local TASK_RESET_MINUTE = 0
local TASK_RESET_CHECK_INTERVAL = 60
local TASK1_KILL_COUNT_REQUIRED = 1
local TASK2_ONLINE_TIME_REQUIRED = 300
local TASK3_KILL_COUNT_REQUIRED = 3
local TASK4_ONLINE_TIME_REQUIRED = 900
local TASK5_SPEND_REQUIRED = 1

-- 默认游戏数据模板
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
    -- 新天赋系统 (9个天赋)
    PlayerTalent1 = 0,
    PlayerTalent2 = 0,
    PlayerTalent3 = 0,
    PlayerTalent4 = 0,
    PlayerTalent5 = 0,
    PlayerTalent6 = 0,
    PlayerTalent7 = 0,
    PlayerTalent8 = 0,
    PlayerTalent9 = 0,
    -- 旧天赋字段保留兼容
    PlayerSpeedTalent = 0,
    PlayerAttackTalent = 0,
    PlayerHpTalent = 0,
    -- 直接获取经验开关（默认开启）
    DirectExpEnabled = true,
    -- 额外吞噬经验加成（百分比，初始值为1%）
    PlayerEcexp = 1,
    -- 无尽剑阁最高层数
    PlayerJiangeFloor = 0,
}

-- 天赋配置表
local TALENT_CONFIG = {
    [1] = { cost = 1, maxLevel = 1000 },
    [2] = { cost = 1, maxLevel = 1000 },
    [3] = { cost = 1, maxLevel = 1000 },
    [4] = { cost = 3, maxLevel = 50 },
    [5] = { cost = 3, maxLevel = 100 },
    [6] = { cost = 3, maxLevel = 100 },
    [7] = { cost = 5, maxLevel = 100 },
    [8] = { cost = 5, maxLevel = 100 },
    [9] = { cost = 5, maxLevel = 50 },
}

-- 任务配置表
local TASK_CONFIG = {
    [1] = { requiredCount = TASK1_KILL_COUNT_REQUIRED, counterField = "KillCount" },
    [2] = { requiredCount = TASK2_ONLINE_TIME_REQUIRED, counterField = "OnlineTime" },
    [3] = { requiredCount = TASK3_KILL_COUNT_REQUIRED, counterField = "KillCount" },
    [4] = { requiredCount = TASK4_ONLINE_TIME_REQUIRED, counterField = "OnlineTime" },
    [5] = { requiredCount = TASK5_SPEND_REQUIRED, counterField = "SpendCount" },
}

function UGCPlayerState:ReceiveBeginPlay()
    UGCPlayerState.SuperClass.ReceiveBeginPlay(self)
    
    -- 为每个实例创建独立的 GameData 和委托
    self.GameData = {}
    self.PlayerLevelChangedDelegate = Delegate.New()
    
    -- 初始化任务系统数据
    self.CompletedTasks = {}
    self.ClaimedTasks = {}
    self.UGCTask1Status = 0
    self.UGCTask2Status = 0
    self.UGCTask3Status = 0
    self.UGCTask4Status = 0
    self.UGCTask5Status = 0
    self.OnlineTime = 0
    self.KillCount = 0
    self.SpendCount = 0
    self.LastResetDate = nil
    
    self:DataInit()
    
    -- 服务端启动定时器
    if self:HasAuthority() then
        self:StartTaskResetTimer()
        self:StartOnlineTimer()
    end
end

function UGCPlayerState:DataInit()
    local isServer = UGCGameSystem.IsServer(self)
    
    local Uid = UGCGameSystem.GetUIDByPlayerState(self)
    local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)
    
    -- 初始化游戏记录数据
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
    
    -- 从存档字段映射到运行时字段
    for runtimeField, defaultValue in pairs(DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        self.GameData[runtimeField] = Data.GameRecordData[archiveField] or defaultValue
    end
    
    -- 修复旧存档的属性值
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
    
    -- 在服务器端初始化复制属性
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
    
    -- 保存前先从角色读取当前血量
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
        return false, "等级不足，需要达到" .. requiredLevel .. "级"
    end
    
    if currentCombatPower < requiredCombatPower then
        return false, "战斗力不足，需要达到" .. UGCGameData.FormatNumber(requiredCombatPower)
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
    
    -- 计算当前等级带来的属性加成
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
    
    -- 累加到转生加成中
    self.GameData.PlayerRebirthBonusHp = (self.GameData.PlayerRebirthBonusHp or 0) + currentLevelBonusHp
    self.GameData.PlayerRebirthBonusAttack = (self.GameData.PlayerRebirthBonusAttack or 0) + currentLevelBonusAttack
    self.GameData.PlayerRebirthBonusMagic = (self.GameData.PlayerRebirthBonusMagic or 0) + currentLevelBonusMagic
    
    -- 增加转生次数
    self.GameData.PlayerRebirthCount = (self.GameData.PlayerRebirthCount or 0) + 1
    
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerRebirthCount")
    end
    
    -- 重置等级和经验
    self.GameData.PlayerLevel = 1
    self.GameData.PlayerExp = 0
    
    -- 计算转生后的最终属性
    local finalMaxHp = self:CalculateFinalMaxHp()
    local finalMagic = self:CalculateFinalMagic()
    
    -- 回满血和魔法
    self.GameData.PlayerHp = finalMaxHp
    self.GameData.PlayerMagic = finalMagic
    
    self:UpdateClientAttributes()
    self:DataSave()
    
    return true, "转生成功"
end

function UGCPlayerState:AddExp(Delta)
    if not Delta or Delta <= 0 then
        return
    end
    
    self:EnsureDataInitialized()
    
    local requiredLevel = self:GetRebirthRequiredLevel()
    if self.GameData.PlayerLevel >= requiredLevel then
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

-- 更新闯关层数排行榜（RankID=2）
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

function UGCPlayerState:OnLevelUp(newLevel)
    local Cfg = UGCGameData.GetLevelConfig(newLevel)
    if not Cfg then
        return
    end
    
    local addHP = Cfg.AddHP or 0
    local addHIT = Cfg.AddHIT or 0
    local addMG = Cfg.AddMG or 0
    
    self.GameData.PlayerMaxHp = self.GameData.PlayerMaxHp + addHP
    self.GameData.PlayerHp = self.GameData.PlayerMaxHp
    self.GameData.PlayerAttack = self.GameData.PlayerAttack + addHIT
    self.GameData.PlayerMagic = self.GameData.PlayerMagic + addMG
    
    -- 每升一级获得1个天赋点
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
        
        self:ApplyAllTalentBuffsInternal(Player)
        self:SyncCombatPower()
        self:UpdateCombatPowerRank()
    end
end

-- 通用属性计算函数
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
	return "Server_Rebirth", "Server_RequestInit", "Server_UnlockTalent", "Server_AddTalentPoint", "Server_AddTalentPointNew", "Server_ClaimTaskReward", "Server_AddSpendCount", "Server_SetDirectExpEnabled", "Server_AddEcexp", "Server_SetBloodlineEnabled", "Server_CraftItem", "Server_SetShenyingSkill", "Server_SetShenyinEcexp", "Server_SetJiangeSkill"
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
end

function UGCPlayerState:Server_Rebirth()
    local success, message = self:DoRebirth()
end

function UGCPlayerState:Server_AddTalentPointNew(talentType)
    local config = TALENT_CONFIG[talentType]
    if not config then
        return
    end
    
    local currentPoints = self.GameData.PlayerTalentPoints or 0
    if currentPoints < config.cost then
        return
    end
    
    local dataField = "PlayerTalent" .. talentType
    local currentLevel = self.GameData[dataField] or 0
    
    if currentLevel >= config.maxLevel then
        return
    end
    
    self.GameData.PlayerTalentPoints = currentPoints - config.cost
    self.GameData[dataField] = currentLevel + 1
    
    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerTalentPoints")
    
    local repField = "UGCPlayerTalent" .. talentType
    self[repField] = self.GameData[dataField]
    UnrealNetwork.RepLazyProperty(self, repField)
    
    self:ApplyTalentBuff(talentType)
    self:UpdateCombatPowerRank()
    self:DataSave()
end

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

function UGCPlayerState:ApplyAllTalentBuffsInternal(Player)
    if not Player then return end
    
    for talentType = 1, 9 do
        local dataField = "PlayerTalent" .. talentType
        local level = self.GameData[dataField] or 0
        local buffPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/tianfu/buff' .. talentType .. '.buff' .. talentType .. '_C')
        
        if level > 0 then
            UGCPersistEffectSystem.RemoveBuffByClass(Player, buffPath, -1, nil)
            local buffObj = UGCPersistEffectSystem.AddBuffByClass(Player, buffPath, nil, -1, level)
        end
    end
end

function UGCPlayerState:ApplyAllTalentBuffs()
    for talentType = 1, 9 do
        local dataField = "PlayerTalent" .. talentType
        local level = self.GameData[dataField] or 0
        if level > 0 then
            self:ApplyTalentBuff(talentType)
        end
    end
end

function UGCPlayerState:Client_OnPlayerLevelUp(Level)
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnPlayerLevelUp", self.GameData.PlayerLevel)
    end
end

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
        {"UGCDirectExpEnabled", "Lazy"},
        {"UGCPlayerEcexp", "Lazy"}
end

-- OnRep回调函数
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

function UGCPlayerState:NotifyTalentTreeRefresh()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.TalentTree then
        local talentTree = pc.MMainUI.TalentTree
        if talentTree:GetVisibility() == ESlateVisibility.Visible then
            talentTree:RefreshUI()
        end
    end
end

-- 动态生成天赋OnRep回调
for i = 1, 9 do
    UGCPlayerState["OnRep_UGCPlayerTalent" .. i] = function(self)
        if self.GameData then
            self.GameData["PlayerTalent" .. i] = self["UGCPlayerTalent" .. i]
        end
        self:NotifyTalentTreeRefresh()
    end
end

-- 同步复制属性到服务器的通用函数
function UGCPlayerState:SyncReplicatedProperties()
    self.UGCPlayerLevel = self.GameData.PlayerLevel
    self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    self.UGCPlayerCombatPower = self:GetCombatPower()
    self.UGCDirectExpEnabled = self.GameData.DirectExpEnabled
    self.UGCPlayerEcexp = self.GameData.PlayerEcexp
    
    -- 同步天赋
    for i = 1, 9 do
        self["UGCPlayerTalent" .. i] = self.GameData["PlayerTalent" .. i]
    end
    
    -- 同步旧天赋
    self.UGCPlayerSpeedTalent = self.GameData.PlayerSpeedTalent
    self.UGCPlayerAttackTalent = self.GameData.PlayerAttackTalent
    self.UGCPlayerHpTalent = self.GameData.PlayerHpTalent
    
    -- 批量复制属性
    local repProps = {"UGCPlayerLevel", "UGCPlayerRebirthCount", "UGCPlayerTalentPoints", "UGCPlayerCombatPower",
                      "UGCPlayerSpeedTalent", "UGCPlayerAttackTalent", "UGCPlayerHpTalent", "UGCDirectExpEnabled", "UGCPlayerEcexp"}
    
    for i = 1, 9 do
        table.insert(repProps, "UGCPlayerTalent" .. i)
    end
    
    for _, prop in ipairs(repProps) do
        UnrealNetwork.RepLazyProperty(self, prop)
    end

    -- 同步无尽剑阁层数到客户端
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        local floor = self.GameData.PlayerJiangeFloor or 0
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_UpdateJiangeFloor", floor)
    end

    -- 初始化时同步闯关层数排行榜
    self:UpdateJiangeFloorRank()
end

function UGCPlayerState:ReceiveEndPlay(EndPlayReason)
    if UGCGameSystem.IsServer(self) then
        self:DataSave()
        self:StopTaskResetTimer()
        self:StopOnlineTimer()
    end
    
    UGCPlayerState.SuperClass.ReceiveEndPlay(self, EndPlayReason)
end

-- ============ 任务系统函数 ============

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

-- 通用任务完成检查函数
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
    
    for i = 1, 5 do
        local statusField = "UGCTask" .. i .. "Status"
        self[statusField] = 0
        UnrealNetwork.RepLazyProperty(self, statusField)
    end
end

-- 动态生成任务状态OnRep回调
for i = 1, 5 do
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
    self.SpendCount = (self.SpendCount or 0) + amount
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
    if amount and amount > 0 then
        self:AddSpendCount(amount)
    end
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

-- 服务端设置直接获取经验开关
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

-- 服务端增减额外吞噬经验加成（支持负数，用于神影卸下时减少）
function UGCPlayerState:Server_AddEcexp(amount)
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

-- 服务端设置神影临时Ecexp加成（不存档，断线自动清零）
function UGCPlayerState:Server_SetShenyinEcexp(amount)
    if not amount then return end
    self.ShenyinEcexpBonus = amount
    ugcprint("[Server_SetShenyinEcexp] 神影临时Ecexp=" .. tostring(amount))
    
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local totalEcexp = (self.GameData.PlayerEcexp or 0) + (self.ShenyinEcexpBonus or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', totalEcexp)
    end
end

-- 服务端设置血脉开关
function UGCPlayerState:Server_SetBloodlineEnabled(isEnabled)
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

function UGCPlayerState:OnRep_UGCPlayerEcexp()
    if self.GameData then
        self.GameData.PlayerEcexp = self.UGCPlayerEcexp
    end
end

-- ============ 合成系统 ============

---服务器RPC：合成物品
---@param InputItemIDs table 输入材料ID数组
---@param InputCounts table 输入材料数量数组
---@param OutputItemID number 输出物品ID
---@param OutputCount number 输出物品数量
function UGCPlayerState:Server_CraftItem(InputItemIDs, InputCounts, OutputItemID, OutputCount)
    ugcprint("[Server_CraftItem] ========== 服务器收到合成请求 ==========")
    ugcprint("[Server_CraftItem] 输出物品: " .. tostring(OutputItemID) .. " x " .. tostring(OutputCount))
    
    -- 获取玩家Pawn
    local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not playerPawn then
        ugcprint("[Server_CraftItem] 错误：无法获取玩家Pawn")
        return
    end
    ugcprint("[Server_CraftItem] ✓ 玩家Pawn获取成功")
    
    -- 检查所有材料数量
    ugcprint("[Server_CraftItem] 检查材料数量，材料总数: " .. tostring(#InputItemIDs))
    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        local currentCount = UGCBackpackSystemV2.GetItemCountV2(playerPawn, itemID)
        ugcprint("[Server_CraftItem] 材料 " .. i .. " - ID: " .. tostring(itemID) .. ", 需要: " .. needCount .. ", 当前: " .. currentCount)
        
        if currentCount < needCount then
            ugcprint("[Server_CraftItem] ✗ 材料 " .. i .. " 数量不足")
            return
        end
        ugcprint("[Server_CraftItem] ✓ 材料 " .. i .. " 数量充足")
    end
    
    -- 移除所有材料
    ugcprint("[Server_CraftItem] 开始移除材料")
    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        
        ugcprint("[Server_CraftItem] 尝试移除材料 " .. i .. " - ID: " .. tostring(itemID) .. ", 数量: " .. tostring(needCount))
        local removedCount = UGCBackpackSystemV2.RemoveItemV2(playerPawn, itemID, needCount)
        ugcprint("[Server_CraftItem] 移除材料 " .. i .. " - 实际移除了 " .. tostring(removedCount) .. " 个")
        
        if removedCount == 0 then
            ugcprint("[Server_CraftItem] ✗ 错误：材料 " .. i .. " 无法移除（返回0）")
            ugcprint("[Server_CraftItem] ✗ 可能原因：物品配置中'是否可移除'字段为false")
            ugcprint("[Server_CraftItem] ✗ 请在物品编辑器中检查物品ID " .. tostring(itemID) .. " 的配置")
            return
        end
        
        if removedCount ~= needCount then
            ugcprint("[Server_CraftItem] ✗ 警告：材料 " .. i .. " 移除数量不匹配（需要:" .. needCount .. ", 实际:" .. removedCount .. "）")
            return
        end
        
        ugcprint("[Server_CraftItem] ✓ 材料 " .. i .. " 移除成功")
    end
    
    -- 添加输出物品
    ugcprint("[Server_CraftItem] 添加输出物品: " .. tostring(OutputItemID) .. " x " .. tostring(OutputCount))
    local addedCount, defineIDs = UGCBackpackSystemV2.AddItemV2(playerPawn, OutputItemID, OutputCount)
    ugcprint("[Server_CraftItem] 实际添加了 " .. tostring(addedCount) .. " 个输出物品")
    
    if addedCount > 0 then
        ugcprint("[Server_CraftItem] ✓ 合成成功！")
    else
        ugcprint("[Server_CraftItem] ✗ 合成失败：无法添加输出物品")
    end
    ugcprint("[Server_CraftItem] ==========================================")
end

-- 所有神影技能路径前缀（用于服务端清除）
local ALL_SHENYIN_SKILLS = {"baise", "lvse", "lanse", "zise", "chengse", "hongse", "jinse"}

-- 服务端设置神影被动技能（先清除所有神影技能，再添加新的）
function UGCPlayerState:Server_SetShenyingSkill(skillPath, isWear)
    ugcprint("[Server_SetShenyingSkill] 收到RPC: skillPath=" .. tostring(skillPath) .. ", isWear=" .. tostring(isWear))
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    -- 先移除所有神影技能（遍历所有可能的路径）
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
                    ugcprint("[Server_SetShenyingSkill] 移除: " .. tostring(path))
                end
            end
        end
    end

    -- 如果是穿戴，添加新技能
    if isWear then
        ugcprint("[Server_SetShenyingSkill] 添加: " .. tostring(skillPath))
        UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
    end
    ugcprint("[Server_SetShenyingSkill] 完成")
end

-- 所有神剑技能名（用于服务端清除）
local ALL_JIANGE_SKILLS = {"bailangjian", "kuishejian", "baihujian", "bifangjian", "qilingjian", "zhuquejian", "shenlongjian"}

-- 服务端设置神剑被动技能（先清除所有神剑技能，再添加新的）
function UGCPlayerState:Server_SetJiangeSkill(skillPath, isWear)
    ugcprint("[Server_SetJiangeSkill] 收到RPC: skillPath=" .. tostring(skillPath) .. ", isWear=" .. tostring(isWear))
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    -- 先移除所有神剑技能
    for _, skillName in ipairs(ALL_JIANGE_SKILLS) do
        local path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. skillName .. '.' .. skillName .. '_C')
        local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, path)
        if skills and #skills > 0 then
            for _, skill in ipairs(skills) do
                UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
                ugcprint("[Server_SetJiangeSkill] 移除: " .. tostring(path))
            end
        end
    end

    -- 如果是穿戴，添加新技能
    if isWear then
        ugcprint("[Server_SetJiangeSkill] 添加: " .. tostring(skillPath))
        UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
    end
    ugcprint("[Server_SetJiangeSkill] 完成")
end

return UGCPlayerState
