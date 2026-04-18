---@class UGCPlayerState_C:BP_UGCPlayerState_C
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')
local SkillSystem = UGCGameSystem.UGCRequire('Script.Common.SkillSystem')
local RewardSystem = UGCGameSystem.UGCRequire('Script.Common.RewardSystem')
local VirtualItemSystem = UGCGameSystem.UGCRequire('Script.Common.VirtualItemSystem')
local PlayerAttributeCalculator = UGCGameSystem.UGCRequire('Script.Common.PlayerAttributeCalculator')

local UGCPlayerState = {
    RebirthLevels = Config_PlayerData.RebirthLevels,
    RebirthCombatPowers = Config_PlayerData.RebirthCombatPowers,
}

function UGCPlayerState:GetTotalSpendCount()
    return tonumber(self.TotalSpendCount) or 0
end

function UGCPlayerState:SerializeClaimedChongzhi(claimedMap)
    return RewardSystem.SerializeClaimedChongzhi(self, claimedMap)
end

function UGCPlayerState:DeserializeClaimedChongzhi(claimedStr)
    return RewardSystem.DeserializeClaimedChongzhi(self, claimedStr)
end

local function NormalizeClaimedChongzhiMap(claimedRaw)
    return RewardSystem.NormalizeClaimedChongzhiMap(self, claimedRaw)
end

function UGCPlayerState:ReceiveBeginPlay()
    UGCPlayerState.SuperClass.ReceiveBeginPlay(self)

    self.GameData = {}
    self.PlayerLevelChangedDelegate = Delegate.New()

    self.TotalSpendCount = 0
    self.LastWeeklyResetWeek = nil
    self.ClaimedChongzhi = {}

    self:DataInit()
end

function UGCPlayerState:DataInit()
    local isServer = UGCGameSystem.IsServer(self)

    local Uid = UGCGameSystem.GetUIDByPlayerState(self)
    local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)

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

    local claimedRaw = Data.GameRecordData.ClaimedChongzhi or {}
    if type(claimedRaw) == "string" then
        self.ClaimedChongzhi = self:DeserializeClaimedChongzhi(claimedRaw)
    else
        self.ClaimedChongzhi = NormalizeClaimedChongzhiMap(claimedRaw)
    end

    self.TotalSpendCount = tonumber(Data.GameRecordData.TotalSpendCount) or 0
    self.SpendCount = 0

    for runtimeField, defaultValue in pairs(Config_PlayerData.DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        self.GameData[runtimeField] = Data.GameRecordData[archiveField] or defaultValue
    end

    self.GameData.PlayerVIP = Config_PlayerData.CalcVIPLevelBySpend(self.TotalSpendCount)

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

    if isServer then
        self:SyncReplicatedProperties()
        SkillSystem.ApplyAllTalentBuffs(self)
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

    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local currentHp = UGCAttributeSystem.GetGameAttributeValue(Player, 'Health')
        if currentHp and currentHp > 0 then
            self.GameData.PlayerHp = currentHp
        end
    end

    for runtimeField, defaultValue in pairs(Config_PlayerData.DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        Data.GameRecordData[archiveField] = self.GameData[runtimeField] or defaultValue
    end

    Data.GameRecordData.ClaimedChongzhi = self.ClaimedChongzhi or {}
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

    local currentCombatPower = PlayerAttributeCalculator.GetCombatPower(self)

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

    local currentCombatPower = PlayerAttributeCalculator.GetCombatPower(self)
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

    self.GameData.PlayerRebirthBonusHp = (self.GameData.PlayerRebirthBonusHp or 0) + currentLevelBonusHp
    self.GameData.PlayerRebirthBonusAttack = (self.GameData.PlayerRebirthBonusAttack or 0) + currentLevelBonusAttack
    self.GameData.PlayerRebirthBonusMagic = (self.GameData.PlayerRebirthBonusMagic or 0) + currentLevelBonusMagic
    self.GameData.PlayerRebirthCount = (self.GameData.PlayerRebirthCount or 0) + 1

    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerRebirthCount")
    end

    self.GameData.PlayerLevel = 1
    self.GameData.PlayerExp = 0

    local finalMaxHp = PlayerAttributeCalculator.CalculateFinalMaxHp(self) + (self.GameData.PlayerManualHp or 0) * 5
    local finalAttack = PlayerAttributeCalculator.CalculateFinalAttack(self) + (self.GameData.PlayerManualAttack or 0) * 2
    local finalMagic = PlayerAttributeCalculator.CalculateFinalMagic(self) + (self.GameData.PlayerManualMagic or 0) * 1

    self.GameData.PlayerMaxHp = finalMaxHp
    self.GameData.PlayerAttack = finalAttack
    self.GameData.PlayerMagic = finalMagic
    self.GameData.PlayerHp = finalMaxHp

    self:UpdateClientAttributes()
    self:DataSave()

    return true, "转生成功"
end

function UGCPlayerState:NotifyExpBlockedByRebirth()
    if not UGCGameSystem.IsServer(self) then
        return
    end

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
    return PlayerAttributeCalculator.GetCombatPower(self)
end

function UGCPlayerState:SyncCombatPower()
    if not UGCGameSystem.IsServer(self) then
        return
    end

    local combatPower = PlayerAttributeCalculator.GetCombatPower(self)
    self.UGCPlayerCombatPower = combatPower
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerCombatPower")
end

function UGCPlayerState:UpdateCombatPowerRank(RankID)
    if not UGCGameSystem.IsServer(self) then
        return
    end

    RankID = RankID or 1

    local combatPower = PlayerAttributeCalculator.GetCombatPower(self)
    local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local UID = UGCGameSystem.GetUIDByPlayerState(self)

    if PlayerController and UID and RankingListManager then
        RankingListManager:UpdatePlayerRankingScore(PlayerController, UID, RankID, combatPower)
    end
end

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

    self.GameData.PlayerMaxHp = self.GameData.PlayerMaxHp + addHP
    self.GameData.PlayerHp = self.GameData.PlayerMaxHp
    self.GameData.PlayerAttack = self.GameData.PlayerAttack + addHIT
    self.GameData.PlayerMagic = self.GameData.PlayerMagic + addMG

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

function UGCPlayerState:CalculateFinalAttribute(baseValue, rebirthBonusField, configField)
    return PlayerAttributeCalculator.CalculateFinalAttribute(self, baseValue, rebirthBonusField, configField)
end

function UGCPlayerState:CalculateFinalMaxHp()
    return PlayerAttributeCalculator.CalculateFinalMaxHp(self)
end

function UGCPlayerState:CalculateFinalAttack()
    return PlayerAttributeCalculator.CalculateFinalAttack(self)
end

function UGCPlayerState:CalculateFinalMagic()
    return PlayerAttributeCalculator.CalculateFinalMagic(self)
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
        UGCAttributeSystem.SetGameAttributeValue(Player, 'bland', PlayerAttributeCalculator.GetAppliedBlandValue(self.GameData))

        SkillSystem.ApplyAllTalentBuffsInternal(self, Player)
        self:SyncCombatPower()
        self:UpdateCombatPowerRank()
    end
end

function UGCPlayerState:GetAvailableServerRPCs()
    return "Server_Rebirth", "Server_RequestInit", "Server_UnlockTalent", "Server_AddTalentPoint", "Server_AddTalentPointNew", "Server_AddSpendCount", "Server_AddShopBuyCount", "Server_SetDirectExpEnabled", "Server_SetAutoTunshiEnabled", "Server_SetAutoPickupEnabled", "Server_AddEcexp", "Server_SetBloodlineEnabled", "Server_CraftItem", "Server_SetShenyingSkill", "Server_SetShenyinEcexp", "Server_SetJiangeSkill", "Server_SetJiangeAtkBonus", "Server_RemoveVirtualItem", "Server_RemoveBackpackItem", "Server_ClaimChongzhiReward", "Server_GiveTaReward", "Server_SaveJiangeData", "Server_SaveShenyinData", "Server_AddManualPoint", "Server_ClaimJiangeFloorReward", "Server_ClaimJiangeDailyReward"
end

function UGCPlayerState:RequestServerInit()
    local pc = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if pc then
        UnrealNetwork.CallUnrealRPC(self, self, "Server_RequestInit")
    end
end

function UGCPlayerState:Server_RequestInit()
    self:EnsureDataInitialized()
    self:UpdateClientAttributes()

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeData", self.GameData.PlayerJiangeLevel or 1, self.GameData.PlayerJiangeProgress or 0)
    end
end

function UGCPlayerState:Server_Rebirth()
    local success, message = self:DoRebirth()
end

function UGCPlayerState:Server_AddManualPoint(pointType)
    if not UGCGameSystem.IsServer(self) then return end

    local MANUAL_POINT_MAP = Config_PlayerData.MANUAL_POINT_MAP

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
    if currentTalentPoints < Config_PlayerData.MANUAL_POINT_COST then
        NotifyManualPointResult(false, "天赋点不足")
        return
    end

    self.GameData.PlayerTalentPoints = currentTalentPoints - Config_PlayerData.MANUAL_POINT_COST

    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerTalentPoints")

    local current = self.GameData[info.dataField] or 0
    self.GameData[info.dataField] = current + 1

    self[info.repField] = self.GameData[info.dataField]
    UnrealNetwork.RepLazyProperty(self, info.repField)

    local oldValue = self.GameData[info.targetField] or 0
    self.GameData[info.targetField] = oldValue + info.addPerPoint

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

    local config = Config_PlayerData.TALENT_CONFIG[talentType]
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
            return VirtualItemManager:GetItemNum(Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID, PC)
        end)
        if queryOk then
            return math.max(0, math.floor(tonumber(queryRet) or 0))
        end

        local fallbackOk, fallbackRet = pcall(function()
            return VirtualItemManager:GetItemNum(Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID)
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
        removeResult = VirtualItemManager:RemoveVirtualItem(PC, Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID, config.cost)
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

    SkillSystem.ApplyTalentBuff(self, talentType)
    self:UpdateCombatPowerRank()
    self:DataSave()

    NotifyTalentUpgradeResult(true, newLevel, GetTalentItemCount(), "")
end

function UGCPlayerState:Server_UnlockTalent(talentIndex)
    self:Server_AddTalentPointNew(talentIndex)
end

function UGCPlayerState:Server_AddTalentPoint(talentType)
    self:Server_AddTalentPointNew(talentType)
end

function UGCPlayerState:ApplyTalentBuff(talentType)
    return SkillSystem.ApplyTalentBuff(self, talentType)
end

function UGCPlayerState:ApplyAllTalentBuffsInternal(Player)
    return SkillSystem.ApplyAllTalentBuffsInternal(self, Player)
end

function UGCPlayerState:ApplyAllTalentBuffs()
    return SkillSystem.ApplyAllTalentBuffs(self)
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
            vip = Config_PlayerData.CalcVIPLevelBySpend(self.TotalSpendCount)
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

for i = 1, 9 do
    UGCPlayerState["OnRep_UGCPlayerTalent" .. i] = function(self)
        if self.GameData then
            self.GameData["PlayerTalent" .. i] = self["UGCPlayerTalent" .. i]
        end
        self:NotifyTalentTreeRefresh()
    end
end

function UGCPlayerState:SyncReplicatedProperties()
    self.UGCPlayerLevel = self.GameData.PlayerLevel
    self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    self.UGCPlayerCombatPower = PlayerAttributeCalculator.GetCombatPower(self)
    self.UGCDirectExpEnabled = self.GameData.DirectExpEnabled
    self.UGCPlayerEcexp = self.GameData.PlayerEcexp
    self:SyncSpendReplicatedProperties()
    self.UGCPlayerManualAttack = self.GameData.PlayerManualAttack or 0
    self.UGCPlayerManualMagic = self.GameData.PlayerManualMagic or 0
    self.UGCPlayerManualHp = self.GameData.PlayerManualHp or 0
    self.UGCPlayerManualBland = self.GameData.PlayerManualBland or 0
    self.UGCBloodlineEnabled = self.GameData.BloodlineEnabled or false

    for i = 1, 9 do
        self["UGCPlayerTalent" .. i] = self.GameData["PlayerTalent" .. i]
    end

    self.UGCPlayerSpeedTalent = self.GameData.PlayerSpeedTalent
    self.UGCPlayerAttackTalent = self.GameData.PlayerAttackTalent
    self.UGCPlayerHpTalent = self.GameData.PlayerHpTalent

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

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        local floor = self.GameData.PlayerJiangeFloor or 0
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_UpdateJiangeFloor", floor)
    end

    self:UpdateJiangeFloorRank()
end

function UGCPlayerState:ReceiveEndPlay(EndPlayReason)
    if UGCGameSystem.IsServer(self) then
        self:DataSave()
    end

    UGCPlayerState.SuperClass.ReceiveEndPlay(self, EndPlayReason)
end

function UGCPlayerState:Server_AddSpendCount(amount)
    VirtualItemSystem.Server_AddSpendCount(self, amount)
end

function UGCPlayerState:Server_AddShopBuyCount()
    VirtualItemSystem.Server_AddShopBuyCount(self)
end

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

function UGCPlayerState:Server_SetAutoTunshiEnabled(isEnabled)
    VirtualItemSystem.Server_SetAutoTunshiEnabled(self, isEnabled)
end

function UGCPlayerState:Server_SetAutoPickupEnabled(isEnabled)
    VirtualItemSystem.Server_SetAutoPickupEnabled(self, isEnabled)
end

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

function UGCPlayerState:Server_SetShenyinEcexp(amount)
    if not UGCGameSystem.IsServer(self) then return end
    if not amount then return end
    self.ShenyinEcexpBonus = amount

    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local totalEcexp = (self.GameData.PlayerEcexp or 0) + (self.ShenyinEcexpBonus or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', totalEcexp)
    end
end

function UGCPlayerState:Server_SetBloodlineEnabled(isEnabled)
    SkillSystem.Server_SetBloodlineEnabled(self, isEnabled)
end

function UGCPlayerState:OnRep_UGCBloodlineEnabled()
    if self.GameData then
        self.GameData.BloodlineEnabled = self.UGCBloodlineEnabled
    end
end

function UGCPlayerState:Server_CraftItem(InputItemIDs, InputCounts, OutputItemID, OutputCount)
    local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not playerPawn then
        return
    end

    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        local currentCount = UGCBackpackSystemV2.GetItemCountV2(playerPawn, itemID)

        if currentCount < needCount then
            return
        end
    end

    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        local removedCount = UGCBackpackSystemV2.RemoveItemV2(playerPawn, itemID, needCount)

        if removedCount == 0 or removedCount ~= needCount then
            return
        end
    end

    local addedCount, defineIDs = UGCBackpackSystemV2.AddItemV2(playerPawn, OutputItemID, OutputCount)
end

function UGCPlayerState:Server_SetShenyingSkill(skillPath, isWear)
    SkillSystem.Server_SetShenyingSkill(self, skillPath, isWear)
end

function UGCPlayerState:Server_SetJiangeSkill(skillPath, isWear)
    SkillSystem.Server_SetJiangeSkill(self, skillPath, isWear)
end

function UGCPlayerState:Server_RemoveVirtualItem(virtualItemID, count)
    VirtualItemSystem.Server_RemoveVirtualItem(self, virtualItemID, count)
end

function UGCPlayerState:Server_RemoveBackpackItem(itemID, count)
    VirtualItemSystem.Server_RemoveBackpackItem(self, itemID, count)
end

function UGCPlayerState:Server_ClaimChongzhiReward(rewardID)
    RewardSystem.Server_ClaimChongzhiReward(self, rewardID)
end

function UGCPlayerState:Server_GiveTaReward(floorNum)
    RewardSystem.Server_GiveTaReward(self, floorNum)
end

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

function UGCPlayerState:Server_ClaimJiangeFloorReward(floorNum)
    RewardSystem.Server_ClaimJiangeFloorReward(self, floorNum)
end

function UGCPlayerState:Server_ClaimJiangeDailyReward()
    RewardSystem.Server_ClaimJiangeDailyReward(self)
end

function UGCPlayerState:Server_SetJiangeAtkBonus(bonusPercent)
    if not UGCGameSystem.IsServer(self) then return end
    bonusPercent = tonumber(bonusPercent) or 0
    self.JiangeAtkBonusPercent = bonusPercent
    self:UpdateClientAttributes()
    self:DataSave()
end

function UGCPlayerState:ReapplyWearingSkills()
    SkillSystem.ReapplyWearingSkills(self)
end

return UGCPlayerState
