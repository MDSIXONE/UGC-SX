---@class UGCPlayerState_C:BP_UGCPlayerState_C
---@module UGCPlayerState
---
--- 玩家状态管理模块
---
--- 功能概述：
--- - 玩家数据初始化（从 Archive 加载到 GameData）
--- - 属性计算（HP、攻击、魔力、战斗力）
--- - 转生系统（等级封顶、经验封顶、转生奖励累加）
--- - 经验与升级系统（升级增加属性和天赋点）
--- - 天赋系统（9种天赋，虚拟物品消耗，技能加成）
--- - 手动加点系统（Attack/Magic/Hp/Bland 四维加点）
--- - 持久化（GameData <-> Archive 双向同步）
--- - 各类 RPC 请求处理（服务器执行，客户端通知）
---
--- 模块依赖：
--- - Config_PlayerData：玩家相关配置（默认数据、转生等级/战斗力要求、天赋配置、手动加点映射等）
--- - SkillSystem：天赋技能应用、血脉系统、声翼/剑隔技能管理
--- - RewardSystem：充值奖励序列化/反序列化、奖励领取
--- - VirtualItemSystem：虚拟物品管理（消费计数、自动吞噬/拾取开关）
--- - PlayerAttributeCalculator：战斗力计算、最终属性计算
---
--- 数据流向概述：
--- - 存档层：ArchiveData.GameRecordData（服务器存储的原始数据）
--- - 运行时层：PlayerState.GameData（运行时内存数据）
--- - 同步层：PlayerState.UGC*（Replicated 属性，网络同步到客户端）
--- - Pawn 层：Player Pawn 的 Attribute（实际战斗使用的属性值）
---
local Delegate = require("common.Delegate")
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')
local SkillSystem = UGCGameSystem.UGCRequire('Script.Common.SkillSystem')
local RewardSystem = UGCGameSystem.UGCRequire('Script.Common.RewardSystem')
local VirtualItemSystem = UGCGameSystem.UGCRequire('Script.Common.VirtualItemSystem')
local PlayerAttributeCalculator = UGCGameSystem.UGCRequire('Script.Common.PlayerAttributeCalculator')

local UGCPlayerState = {
    --- 转生等级要求配置数组，每转一次检查对应索引的等级要求
    --- 例如 RebirthLevels[1] = 50 表示第1次转生需要达到50级
    RebirthLevels = Config_PlayerData.RebirthLevels,
    --- 转生战斗力要求配置数组，每转一次检查对应索引的战斗力要求
    --- 例如 RebirthCombatPowers[1] = 100000 表示第1次转生需要10万战斗力
    RebirthCombatPowers = Config_PlayerData.RebirthCombatPowers,
}

--- 获取玩家累计消费金额（以虚拟物品单位计）
--- 从 TotalSpendCount 字段读取，用于VIP等级计算、排行榜等
---
---@return number 累计消费金额
function UGCPlayerState:GetTotalSpendCount()
    return tonumber(self.TotalSpendCount) or 0
end

--- 序列化充值奖励领取状态 Map 为字符串
--- 用于将内存中的领取记录（key=奖励ID，value=领取时间戳）转换为字符串存档
---
---@param claimedMap table<string, number> 奖励ID到领取时间的映射
---@return string 序列化后的字符串
function UGCPlayerState:SerializeClaimedChongzhi(claimedMap)
    return RewardSystem.SerializeClaimedChongzhi(self, claimedMap)
end

--- 反序列化充值奖励领取状态字符串为 Map
--- 用于从存档字符串恢复领取记录
---
---@param claimedStr string 序列化字符串
---@return table<string, number> 奖励ID到领取时间的映射
function UGCPlayerState:DeserializeClaimedChongzhi(claimedStr)
    return RewardSystem.DeserializeClaimedChongzhi(self, claimedStr)
end

--- 标准化充值奖励领取记录（兼容旧版数据结构）
--- 处理存档中可能是 table 或其他格式的 ClaimedChongzhi 字段
---
---@param claimedRaw any 原始领取数据
---@return table<string, number> 标准化的领取记录
local function NormalizeClaimedChongzhiMap(claimedRaw)
    return RewardSystem.NormalizeClaimedChongzhiMap(self, claimedRaw)
end

--- 生命周期回调：玩家状态 BeginPlay
--- 初始化玩家状态的基础数据结构，调用 DataInit 加载存档数据
function UGCPlayerState:ReceiveBeginPlay()
    UGCPlayerState.SuperClass.ReceiveBeginPlay(self)

    -- 初始化 GameData 表（运行时数据容器）
    self.GameData = {}
    -- 等级变化事件委托（通知 UI 等系统刷新）
    self.PlayerLevelChangedDelegate = Delegate.New()

    -- 累计消费计数
    self.TotalSpendCount = 0
    -- 上次周重置的周数（用于周重置逻辑）
    self.LastWeeklyResetWeek = nil
    -- 充值奖励领取记录
    self.ClaimedChongzhi = {}

    -- 加载存档数据到内存
    self:DataInit()
end

--- 数据初始化：从 Archive 存档加载数据到 GameData 运行时数据
---
--- 数据流向详解（Archive -> GameData）：
---
--- 1. 获取玩家 UID
---    Uid = UGCPlayerStateSystem.GetPlayerArchiveData(Uid) -> ArchiveData
---
--- 2. 首次登录时创建默认 GameRecordData
---    字段映射（Archive字段 -> 含义 -> 默认值）：
---    - UGCPlayerExp：当前经验值 -> 0
---    - UGCPlayerLevel：玩家等级 -> 1
---    - UGCPlayerHp：当前生命值 -> 100 + 1级HP加成
---    - UGCPlayerMaxHp：最大生命值 -> 100 + 1级HP加成
---    - UGCPlayerAttack：攻击力 -> 20 + 1级攻击加成
---    - UGCPlayerMagic：魔力 -> 10 + 1级魔力加成
---    - UGCPlayerRebirthCount：转生次数 -> 0
---    - UGCPlayerTalentPoints：天赋点数 -> 0
---    - UGCPlayerSpeedTalent：速度天赋等级 -> 0
---
--- 3. 充值奖励领取记录处理
---    - 如果是字符串格式 -> 调用 DeserializeClaimedChongzhi 反序列化
---    - 如果是 Table 格式 -> 调用 NormalizeClaimedChongzhiMap 标准化
---    - 存储到 self.ClaimedChongzhi（内存中）
---
--- 4. DefaultGameData 字段映射（Config_PlayerData.DefaultGameData）
---    遍历配置中的每个字段，执行：
---    - runtimeField：运行时字段名（如 "PlayerLevel"）
---    - archiveField：存档字段名（UGC + runtimeField，如 "UGCPlayerLevel"）
---    - self.GameData[runtimeField] = Data.GameRecordData[archiveField] or defaultValue
---    例如：
---    - PlayerLevel <- UGCPlayerLevel
---    - PlayerExp <- UGCPlayerExp
---    - PlayerTalent1-9 <- UGCPlayerTalent1-9
---    - PlayerRebirthBonusHp <- UGCPlayerRebirthBonusHp（转生奖励HP）
---    - DirectExpEnabled <- UGCDirectExpEnabled（直服经验开关）
---    等等...
---
--- 5. VIP 等级计算
---    根据 TotalSpendCount 计算 VIP 等级
---    self.GameData.PlayerVIP = Config_PlayerData.CalcVIPLevelBySpend(self.TotalSpendCount)
---
--- 6. 服务器端属性修正（校验并修正存档数据）
---    根据当前 PlayerLevel 重新计算：
---    - 基础属性（HP/Attack/Magic）：逐级累加 AddHP/AddHIT/AddMG
---    - 转生奖励加成：PlayerRebirthBonusHp/Attack/Magic
---    - 手动加点加成：PlayerManualHp*5 / PlayerManualAttack*2 / PlayerManualMagic*1
---    如果存档中的属性值与计算值不符，更新为正确值
---    HP 修正时会保持当前HP的比例（血量不会超过最大生命值）
---
--- 7. 同步与初始化完成
---    - 服务器端：SyncReplicatedProperties -> UpdateClientAttributes
---    - 客户端：RequestServerInit（请求服务器同步数据）
function UGCPlayerState:DataInit()
    local isServer = UGCGameSystem.IsServer(self)

    -- 获取玩家 UID
    local Uid = UGCGameSystem.GetUIDByPlayerState(self)
    -- 从存档系统获取玩家存档数据
    local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)

    -- 首次登录：创建默认 GameRecordData
    if not Data.GameRecordData then
        -- 获取1级配置以计算基础属性
        local level1Cfg = UGCGameData.GetLevelConfig(1)
        -- 1级HP加成（配置或默认值21000）
        local level1HP = level1Cfg and level1Cfg.AddHP or 21000
        -- 1级攻击加成（配置或默认值2300）
        local level1Attack = level1Cfg and level1Cfg.AddHIT or 2300
        -- 1级魔力加成（配置或默认值6900）
        local level1Magic = level1Cfg and level1Cfg.AddMG or 6900

        -- 初始化玩家数据
        Data.GameRecordData = {
            -- 经验值从0开始
            UGCPlayerExp = 0,
            -- 等级从1开始
            UGCPlayerLevel = 1,
            -- 当前HP = 基础100 + 1级HP加成
            UGCPlayerHp = 100 + level1HP,
            -- 最大HP = 基础100 + 1级HP加成
            UGCPlayerMaxHp = 100 + level1HP,
            -- 攻击力 = 基础20 + 1级攻击加成
            UGCPlayerAttack = 20 + level1Attack,
            -- 魔力 = 基础10 + 1级魔力加成
            UGCPlayerMagic = 10 + level1Magic,
            -- 转生次数初始为0
            UGCPlayerRebirthCount = 0,
            -- 天赋点数初始为0
            UGCPlayerTalentPoints = 0,
            -- 速度天赋初始为0
            UGCPlayerSpeedTalent = 0,
        }
    end

    -- 确保 live 标记存在（表示角色存活）
    if not Data.live then
        Data.live = 1
    end
    self.live = Data.live

    -- 处理充值奖励领取记录
    local claimedRaw = Data.GameRecordData.ClaimedChongzhi or {}
    if type(claimedRaw) == "string" then
        -- 字符串格式：反序列化为 Map
        self.ClaimedChongzhi = self:DeserializeClaimedChongzhi(claimedRaw)
    else
        -- 其他格式：标准化处理
        self.ClaimedChongzhi = NormalizeClaimedChongzhiMap(claimedRaw)
    end

    -- 加载累计消费金额
    self.TotalSpendCount = tonumber(Data.GameRecordData.TotalSpendCount) or 0
    -- 当前会话消费计数（内存中）
    self.SpendCount = 0

    -- DefaultGameData 字段映射：将 Archive 数据加载到运行时 GameData
    -- Config_PlayerData.DefaultGameData 定义了所有需要持久化的字段及其默认值
    -- 例如：{ PlayerLevel = 1 } 意味着：
    --   - 运行时字段：self.GameData.PlayerLevel
    --   - 存档字段：Data.GameRecordData.UGCPlayerLevel
    --   - 加载逻辑：self.GameData.PlayerLevel = Data.GameRecordData.UGCPlayerLevel or 1
    for runtimeField, defaultValue in pairs(Config_PlayerData.DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        self.GameData[runtimeField] = Data.GameRecordData[archiveField] or defaultValue
    end

    -- 根据累计消费计算 VIP 等级
    self.GameData.PlayerVIP = Config_PlayerData.CalcVIPLevelBySpend(self.TotalSpendCount)

    -- 服务器端：校验并修正玩家属性
    if isServer and self.GameData.PlayerLevel then
        -- 从1级开始逐级累加属性
        local correctMaxHp = 100      -- 基础最大HP
        local correctAttack = 20      -- 基础攻击力
        local correctMagic = 10       -- 基础魔力

        -- 累加每级的属性加成
        for i = 1, self.GameData.PlayerLevel do
            local cfg = UGCGameData.GetLevelConfig(i)
            if cfg then
                correctMaxHp = correctMaxHp + (cfg.AddHP or 0)
                correctAttack = correctAttack + (cfg.AddHIT or 0)
                correctMagic = correctMagic + (cfg.AddMG or 0)
            end
        end

        -- 加上转生奖励加成
        correctMaxHp = correctMaxHp + (self.GameData.PlayerRebirthBonusHp or 0)
        correctAttack = correctAttack + (self.GameData.PlayerRebirthBonusAttack or 0)
        correctMagic = correctMagic + (self.GameData.PlayerRebirthBonusMagic or 0)

        -- 加上手动加点加成（Attack*2, Magic*1, Hp*5）
        correctMaxHp = correctMaxHp + (self.GameData.PlayerManualHp or 0) * 5
        correctAttack = correctAttack + (self.GameData.PlayerManualAttack or 0) * 2
        correctMagic = correctMagic + (self.GameData.PlayerManualMagic or 0) * 1

        -- 修正最大HP（保持当前HP比例）
        if self.GameData.PlayerMaxHp ~= correctMaxHp then
            local hpRatio = self.GameData.PlayerHp / self.GameData.PlayerMaxHp
            self.GameData.PlayerMaxHp = correctMaxHp
            self.GameData.PlayerHp = math.floor(correctMaxHp * hpRatio)
        end

        -- 修正攻击力
        if self.GameData.PlayerAttack ~= correctAttack then
            self.GameData.PlayerAttack = correctAttack
        end

        -- 修正魔力
        if self.GameData.PlayerMagic ~= correctMagic then
            self.GameData.PlayerMagic = correctMagic
        end
    end

    -- 服务器端：完成初始化，同步属性到 Pawn
    if isServer then
        -- 同步所有 Replicated 属性到客户端
        self:SyncReplicatedProperties()
        -- 应用所有天赋技能加成
        SkillSystem.ApplyAllTalentBuffs(self)
        -- 更新 Pawn 的 Attribute 属性
        self:UpdateClientAttributes()
    else
        -- 客户端：请求服务器同步初始化数据
        self:RequestServerInit()
    end
end

--- 数据保存：将 GameData 运行时数据写回 Archive 存档
---
--- 数据流向详解（GameData -> Archive）：
---
--- 1. 权限检查：仅服务器可执行保存
---
--- 2. 获取当前 HP（从 Pawn 同步最新值）
---    - 获取玩家 Pawn
---    - 读取 Health 属性
---    - 如果 HP > 0，更新到 GameData.PlayerHp
---
--- 3. GameData -> Archive 字段映射（反向于 DataInit）
---    遍历 Config_PlayerData.DefaultGameData 中的每个字段：
---    - runtimeField：运行时字段名（如 "PlayerLevel"）
---    - archiveField：存档字段名（UGC + runtimeField，如 "UGCPlayerLevel"）
---    - Data.GameRecordData[archiveField] = self.GameData[runtimeField] or defaultValue
---
---    例如：
---    - GameData.PlayerLevel -> Archive.UGCPlayerLevel
---    - GameData.PlayerExp -> Archive.UGCPlayerExp
---    - GameData.PlayerTalent1 -> Archive.UGCPlayerTalent1
---    - GameData.PlayerRebirthBonusHp -> Archive.UGCPlayerRebirthBonusHp
---    - GameData.DirectExpEnabled -> Archive.UGCDirectExpEnabled
---    等等...
---
--- 4. 特殊字段保存
---    - ClaimedChongzhi：充值奖励领取记录（直接存储 Map 或序列化字符串）
---    - TotalSpendCount：累计消费金额
---
--- 5. 调用存档系统保存
---    UGCPlayerStateSystem.SavePlayerArchiveData(Uid, Data)
function UGCPlayerState:DataSave()
    -- 仅服务器执行
    if not UGCGameSystem.IsServer(self) then
        return
    end

    -- 获取玩家 UID 和存档数据
    local Uid = UGCGameSystem.GetUIDByPlayerState(self)
    local Data = UGCPlayerStateSystem.GetPlayerArchiveData(Uid)

    -- 确保 GameRecordData 存在
    if not Data.GameRecordData then
        Data.GameRecordData = {}
    end

    -- 从 Pawn 同步当前 HP 到 GameData（确保存档最新血量）
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local currentHp = UGCAttributeSystem.GetGameAttributeValue(Player, 'Health')
        if currentHp and currentHp > 0 then
            self.GameData.PlayerHp = currentHp
        end
    end

    -- GameData -> Archive 字段映射保存
    -- 将运行时数据写入存档，字段名前缀 UGC
    for runtimeField, defaultValue in pairs(Config_PlayerData.DefaultGameData) do
        local archiveField = "UGC" .. runtimeField
        Data.GameRecordData[archiveField] = self.GameData[runtimeField] or defaultValue
    end

    -- 保存充值奖励领取记录
    Data.GameRecordData.ClaimedChongzhi = self.ClaimedChongzhi or {}
    -- 保存累计消费金额
    Data.GameRecordData.TotalSpendCount = self:GetTotalSpendCount()

    -- 调用存档系统保存
    UGCPlayerStateSystem.SavePlayerArchiveData(Uid, Data)
end

--- 获取当前转生等级要求
--- 根据当前转生次数，返回下一次转生需要的等级
---
---@return number 需要的等级
function UGCPlayerState:GetRebirthRequiredLevel()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    -- 如果已超过配置数组长度，返回最后一个配置值（封顶值）
    if rebirthCount >= #UGCPlayerState.RebirthLevels then
        return UGCPlayerState.RebirthLevels[#UGCPlayerState.RebirthLevels]
    end
    -- 否则返回下一次转生需要的等级
    return UGCPlayerState.RebirthLevels[rebirthCount + 1]
end

--- 获取当前转生战斗力要求
--- 根据当前转生次数，返回下一次转生需要的战斗力
---
---@return number 需要的战斗力
function UGCPlayerState:GetRebirthRequiredCombatPower()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    -- 如果已超过配置数组长度，返回最后一个配置值（封顶值）
    if rebirthCount >= #UGCPlayerState.RebirthCombatPowers then
        return UGCPlayerState.RebirthCombatPowers[#UGCPlayerState.RebirthCombatPowers]
    end
    -- 否则返回下一次转生需要的战斗力
    return UGCPlayerState.RebirthCombatPowers[rebirthCount + 1]
end

--- 检查玩家是否可以转生
--- 同时检查等级和战斗力是否满足要求
---
--- 转生条件：
--- 1. 当前转生次数未达上限
--- 2. 玩家等级 >= 转生要求等级
--- 3. 当前战斗力 >= 转生要求战斗力
---
---@return boolean, string 是否可以转生, 原因描述
function UGCPlayerState:CanRebirth()
    -- 获取转生要求
    local requiredLevel = self:GetRebirthRequiredLevel()
    local requiredCombatPower = self:GetRebirthRequiredCombatPower()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0

    -- 获取当前等级（优先从 Pawn 获取实时等级）
    local currentLevel = self.GameData.PlayerLevel or 1
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        currentLevel = math.floor(UGCAttributeSystem.GetGameAttributeValue(Player, 'Level') or currentLevel)
    end

    -- 计算当前战斗力
    local currentCombatPower = PlayerAttributeCalculator.GetCombatPower(self)

    -- 检查1：转生次数已达上限
    if rebirthCount >= #UGCPlayerState.RebirthLevels then
        return false, "已达到最大转生次数"
    end

    -- 检查2：等级不足
    if currentLevel < requiredLevel then
        return false, "等级不足，需要" .. requiredLevel .. "级"
    end

    -- 检查3：战斗力不足
    if currentCombatPower < requiredCombatPower then
        return false, "战斗力不足，需要" .. UGCGameData.FormatNumber(requiredCombatPower)
    end

    -- 所有条件满足
    return true, "可以转生"
end

--- 获取转生详细信息
--- 返回当前转生状态和要求的完整信息，用于 UI 显示
---
---@return table 转生信息表，包含：
--- - rebirthCount：当前转生次数
--- - requiredLevel：要求的等级
--- - currentLevel：当前等级
--- - requiredCombatPower：要求的战斗力
--- - currentCombatPower：当前战斗力
--- - canRebirth：是否可以转生
--- - reason：原因描述
--- - maxRebirthCount：最大转生次数
function UGCPlayerState:GetRebirthInfo()
    local rebirthCount = self.UGCPlayerRebirthCount or self.GameData.PlayerRebirthCount or 0
    local requiredLevel = self:GetRebirthRequiredLevel()
    local requiredCombatPower = self:GetRebirthRequiredCombatPower()

    -- 获取当前等级
    local currentLevel = self.GameData.PlayerLevel or 1
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        currentLevel = math.floor(UGCAttributeSystem.GetGameAttributeValue(Player, 'Level') or currentLevel)
    end

    -- 计算当前战斗力
    local currentCombatPower = PlayerAttributeCalculator.GetCombatPower(self)
    local canRebirth, reason = self:CanRebirth()

    -- 返回完整转生信息
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

--- 执行转生
---
--- 转生流程：
--- 1. 验证可转生条件（CanRebirth）
--- 2. 计算当前等级累计的属性加成（HP/Attack/Magic）
--- 3. 将累计加成累加到转生奖励（RebirthBonus）字段
--- 4. 转生次数 +1
--- 5. 重置等级为1，经验为0
--- 6. 重新计算最终属性并同步
---
--- 转生后效果：
--- - 玩家等级重置为1
--- - 经验清零
--- - 转生奖励属性累加（永久保留）
--- - 每次转生后需要重新升级以达到下一转生要求
function UGCPlayerState:DoRebirth()
    -- 验证可转生条件
    local canRebirth, reason = self:CanRebirth()
    if not canRebirth then
        return false, reason
    end

    -- 计算当前等级累计的属性加成
    local currentLevelBonusHp = 0
    local currentLevelBonusAttack = 0
    local currentLevelBonusMagic = 0
    -- 从1级到当前等级逐级累加
    for i = 1, (self.GameData.PlayerLevel or 1) do
        local cfg = UGCGameData.GetLevelConfig(i)
        if cfg then
            currentLevelBonusHp = currentLevelBonusHp + (cfg.AddHP or 0)
            currentLevelBonusAttack = currentLevelBonusAttack + (cfg.AddHIT or 0)
            currentLevelBonusMagic = currentLevelBonusMagic + (cfg.AddMG or 0)
        end
    end

    -- 累加转生奖励加成（永久加成，每次转生后累加）
    self.GameData.PlayerRebirthBonusHp = (self.GameData.PlayerRebirthBonusHp or 0) + currentLevelBonusHp
    self.GameData.PlayerRebirthBonusAttack = (self.GameData.PlayerRebirthBonusAttack or 0) + currentLevelBonusAttack
    self.GameData.PlayerRebirthBonusMagic = (self.GameData.PlayerRebirthBonusMagic or 0) + currentLevelBonusMagic
    -- 转生次数 +1
    self.GameData.PlayerRebirthCount = (self.GameData.PlayerRebirthCount or 0) + 1

    -- 服务器端：同步转生次数到客户端
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerRebirthCount")
    end

    -- 重置等级为1，经验为0
    self.GameData.PlayerLevel = 1
    self.GameData.PlayerExp = 0

    -- 重新计算最终属性（基础 + 转生奖励 + 手动加点）
    local finalMaxHp = PlayerAttributeCalculator.CalculateFinalMaxHp(self) + (self.GameData.PlayerManualHp or 0) * 5
    local finalAttack = PlayerAttributeCalculator.CalculateFinalAttack(self) + (self.GameData.PlayerManualAttack or 0) * 2
    local finalMagic = PlayerAttributeCalculator.CalculateFinalMagic(self) + (self.GameData.PlayerManualMagic or 0) * 1

    -- 更新属性值，满血恢复
    self.GameData.PlayerMaxHp = finalMaxHp
    self.GameData.PlayerAttack = finalAttack
    self.GameData.PlayerMagic = finalMagic
    self.GameData.PlayerHp = finalMaxHp

    -- 同步属性到客户端并保存存档
    self:UpdateClientAttributes()
    self:DataSave()

    return true, "转生成功"
end

--- 通知客户端经验因转生前封顶而被阻止
--- 当玩家达到转生要求等级后继续获取经验时调用
---
--- 封顶逻辑说明：
--- - AddExp 时检查 PlayerLevel >= GetRebirthRequiredLevel()
--- - 如果达到转生等级要求，经验获取会被封顶
--- - 此函数通知客户端显示提示UI，告知玩家需要转生后才能继续获取经验
---
--- 防刷屏：两次通知间隔至少2秒
function UGCPlayerState:NotifyExpBlockedByRebirth()
    if not UGCGameSystem.IsServer(self) then
        return
    end

    -- 获取当前时间戳（秒）
    local nowSec = os.time()
    -- 防刷屏：距离上次通知不足2秒则跳过
    if self.LastExpBlockedTipTime and (nowSec - self.LastExpBlockedTipTime) < 2 then
        return
    end
    self.LastExpBlockedTipTime = nowSec

    -- 获取玩家控制器并发送 RPC 通知
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnExpBlockedByRebirth")
    end
end

--- 添加经验值
---
--- 经验封顶机制（转生前）：
--- - 当玩家等级 >= 转生要求等级时，经验获取被封顶
--- - 封顶后调用 NotifyExpBlockedByRebirth() 通知客户端
--- - 这是为了防止玩家在达到转生要求后继续刷经验而不转生
---
--- 升级流程：
--- 1. 检查是否达到转生等级要求（封顶检查）
--- 2. 循环处理升级：当前经验 >= 升级所需经验时触发升级
--- 3. 每升一级：等级+1，天赋点+1，属性增加，经验扣除
--- 4. 升级后同步等级和属性到客户端
---
---@param Delta number 要添加的经验值
function UGCPlayerState:AddExp(Delta)
    if not Delta or Delta <= 0 then
        return
    end

    -- 确保数据已初始化
    self:EnsureDataInitialized()

    -- 转生前经验封顶检查
    -- 当等级达到转生要求时，停止获取经验，通知玩家需要转生
    local requiredLevel = self:GetRebirthRequiredLevel()
    if self.GameData.PlayerLevel >= requiredLevel then
        -- 经验被封顶，通知客户端显示提示
        self:NotifyExpBlockedByRebirth()
        return
    end

    local InitialLevel = self.GameData.PlayerLevel
    local NewEXP = self.GameData.PlayerExp + Delta
    local hasLeveledUp = false

    -- 循环处理升级（可能一次获得大量经验导致连升多级）
    while true do
        -- 再次检查转生等级要求（升级后可能达到要求）
        if self.GameData.PlayerLevel >= requiredLevel then
            break
        end

        -- 获取当前等级配置
        local Cfg = UGCGameData.GetLevelConfig(self.GameData.PlayerLevel)
        if not Cfg then
            break
        end

        -- 检查经验是否足够升级
        if Cfg and Cfg.Exp and (NewEXP >= Cfg.Exp) then
            -- 扣除升级所需经验
            NewEXP = NewEXP - Cfg.Exp
            local NewLevel = self.GameData.PlayerLevel + 1

            -- 检查升级后是否会超过转生要求等级（不允许超过）
            if NewLevel > requiredLevel then
                -- 归还经验并停止
                NewEXP = NewEXP + Cfg.Exp
                break
            end

            -- 执行升级
            self.GameData.PlayerLevel = NewLevel
            hasLeveledUp = true

            -- 触发升级事件（属性增加、天赋点增加等）
            self:OnLevelUp(NewLevel)
            -- 通知客户端等级变化
            self:Client_OnPlayerLevelUp(self.GameData.PlayerLevel)
        else
            break
        end
    end

    -- 更新经验值
    self.GameData.PlayerExp = NewEXP

    -- 服务器端：同步等级到客户端
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerLevel = self.GameData.PlayerLevel
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerLevel")
    end

    -- 更新客户端属性并保存存档
    self:UpdateClientAttributes(hasLeveledUp)
    self:DataSave()
end

--- 获取玩家战斗力
---
---@return number 当前战斗力值
function UGCPlayerState:GetCombatPower()
    return PlayerAttributeCalculator.GetCombatPower(self)
end

--- 同步战斗力值（服务器执行）
--- 计算当前战斗力并同步到网络属性，供客户端和排行榜使用
function UGCPlayerState:SyncCombatPower()
    if not UGCGameSystem.IsServer(self) then
        return
    end

    local combatPower = PlayerAttributeCalculator.GetCombatPower(self)
    self.UGCPlayerCombatPower = combatPower
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerCombatPower")
end

--- 更新战斗力排行榜（服务器执行）
--- 将玩家战斗力同步到指定排行榜
---
---@param RankID number 排行榜ID（默认1为战斗力排行榜）
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

--- 更新剑隔（Jiange）层数排行榜（服务器执行）
--- 将玩家剑隔副本进度同步到排行榜
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

--- 更新消费排行榜（服务器执行）
--- 将玩家累计消费金额同步到排行榜
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

--- 升级事件处理
--- 升级时增加属性值和天赋点数
---
--- 升级效果：
--- - HP：增加当前等级的 AddHP
--- - Attack：增加当前等级的 AddHIT
--- - Magic：增加当前等级的 AddMG
--- - 天赋点：+1
---
---@param newLevel number 升级后的新等级
function UGCPlayerState:OnLevelUp(newLevel)
    -- 获取新等级的等级配置
    local Cfg = UGCGameData.GetLevelConfig(newLevel)
    if not Cfg then
        return
    end

    -- 获取属性加成值
    local addHP = Cfg.AddHP or 0
    local addHIT = Cfg.AddHIT or 0
    local addMG = Cfg.AddMG or 0

    -- 增加属性（最大HP、当前HP、攻击力、魔力）
    self.GameData.PlayerMaxHp = self.GameData.PlayerMaxHp + addHP
    self.GameData.PlayerHp = self.GameData.PlayerMaxHp  -- 满血恢复
    self.GameData.PlayerAttack = self.GameData.PlayerAttack + addHIT
    self.GameData.PlayerMagic = self.GameData.PlayerMagic + addMG

    -- 天赋点数 +1
    self.GameData.PlayerTalentPoints = (self.GameData.PlayerTalentPoints or 0) + 1

    -- 服务器端：同步天赋点数到客户端
    if UGCGameSystem.IsServer(self) then
        self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
        UnrealNetwork.RepLazyProperty(self, "UGCPlayerTalentPoints")
    end
end

--- 确保数据已初始化
--- 如果 GameData 未初始化，执行 DataInit
---
---@return boolean 是否执行了初始化
function UGCPlayerState:EnsureDataInitialized()
    if not self.GameData or not self.GameData.PlayerLevel then
        self.GameData = self.GameData or {}
        self.PlayerLevelChangedDelegate = self.PlayerLevelChangedDelegate or Delegate.New()
        self:DataInit()
        return true
    end
    return false
end

--- 计算最终属性值（通用接口）
--- 委托给 PlayerAttributeCalculator 处理
function UGCPlayerState:CalculateFinalAttribute(baseValue, rebirthBonusField, configField)
    return PlayerAttributeCalculator.CalculateFinalAttribute(self, baseValue, rebirthBonusField, configField)
end

--- 计算最终最大HP
--- 基础HP + 转生奖励HP + 手动加点HP
function UGCPlayerState:CalculateFinalMaxHp()
    return PlayerAttributeCalculator.CalculateFinalMaxHp(self)
end

--- 计算最终攻击力
--- 基础Attack + 转生奖励Attack + 手动加点Attack*2
function UGCPlayerState:CalculateFinalAttack()
    return PlayerAttributeCalculator.CalculateFinalAttack(self)
end

--- 计算最终魔力
--- 基础Magic + 转生奖励Magic + 手动加点Magic*1
function UGCPlayerState:CalculateFinalMagic()
    return PlayerAttributeCalculator.CalculateFinalMagic(self)
end

--- 更新客户端属性（服务器执行）
--- 将 PlayerState 的属性同步到 Player Pawn 的 Attribute 系统
---
--- 同步的属性列表：
--- - Level：玩家等级
--- - Health：当前生命值
--- - HealthMax：最大生命值
--- - Attack：攻击力
--- - Magic：魔力
--- - EXP：当前经验值
--- - Ecexp：额外经验值（PlayerEcexp + ShenyinEcexpBonus）
--- - bland：特殊属性值（根据手动加点计算）
---
--- 同步后操作：
--- - 应用所有天赋技能加成（SkillSystem）
--- - 同步战斗力并更新排行榜
---
---@param isLevelUp boolean 是否为升级触发的更新
function UGCPlayerState:UpdateClientAttributes(isLevelUp)
    if not UGCGameSystem.IsServer(self) then
        return
    end

    -- 确保数据已初始化
    self:EnsureDataInitialized()

    -- 获取玩家 Pawn
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        -- 从 GameData 获取最终属性值
        local finalMaxHp = self.GameData.PlayerMaxHp
        local finalAttack = self.GameData.PlayerAttack
        local finalMagic = self.GameData.PlayerMagic

        -- 同步等级
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Level', self.GameData.PlayerLevel)
        -- 同步当前HP
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Health', self.GameData.PlayerHp)
        -- 同步最大HP
        UGCAttributeSystem.SetGameAttributeValue(Player, 'HealthMax', finalMaxHp)
        -- 同步攻击力
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Attack', finalAttack)
        -- 同步魔力
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Magic', finalMagic)
        -- 同步当前经验
        UGCAttributeSystem.SetGameAttributeValue(Player, 'EXP', self.GameData.PlayerExp or 0)
        -- 同步额外经验（基础 + 身印加成）
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', (self.GameData.PlayerEcexp or 0) + (self.ShenyinEcexpBonus or 0))
        -- 同步特殊属性（bland）
        UGCAttributeSystem.SetGameAttributeValue(Player, 'bland', PlayerAttributeCalculator.GetAppliedBlandValue(self.GameData))

        -- 应用所有天赋技能加成
        SkillSystem.ApplyAllTalentBuffsInternal(self, Player)
        -- 同步战斗力并更新排行榜
        self:SyncCombatPower()
        self:UpdateCombatPowerRank()
    end
end

--- 获取可用的服务器 RPC 列表
--- 客户端调用此函数了解可以请求哪些服务器 RPC
---
--- RPC 列表：
--- - Server_Rebirth：转生请求
--- - Server_RequestInit：请求服务器初始化数据
--- - Server_UnlockTalent / Server_AddTalentPoint / Server_AddTalentPointNew：天赋相关
--- - Server_AddSpendCount：增加消费计数
--- - Server_AddShopBuyCount：增加商店购买计数
--- - Server_SetDirectExpEnabled：设置直服经验开关
--- - Server_SetAutoTunshiEnabled：设置自动吞噬开关
--- - Server_SetAutoPickupEnabled：设置自动拾取开关
--- - Server_AddEcexp：增加额外经验
--- - Server_SetBloodlineEnabled：设置血脉启用状态
--- - Server_CraftItem：制作物品
--- - Server_SetShenyingSkill：设置声翼技能
--- - Server_SetShenyinEcexp：设置身印经验加成
--- - Server_SetJiangeSkill：设置剑隔技能
--- - Server_SetJiangeAtkBonus：设置剑隔攻击加成
--- - Server_RemoveVirtualItem：移除虚拟物品
--- - Server_RemoveBackpackItem：移除背包物品
--- - Server_ClaimChongzhiReward：领取充值奖励
--- - Server_GiveTaReward：给予TA奖励
--- - Server_SaveJiangeData：保存剑隔数据
--- - Server_SaveShenyinData：保存身印数据
--- - Server_AddManualPoint：手动加点
--- - Server_ClaimJiangeFloorReward：领取剑隔层数奖励
--- - Server_ClaimJiangeDailyReward：领取剑隔每日奖励
---
---@return string, string, ... 所有可用的 RPC 函数名
function UGCPlayerState:GetAvailableServerRPCs()
    return "Server_Rebirth", "Server_RequestInit", "Server_UnlockTalent", "Server_AddTalentPoint", "Server_AddTalentPointNew", "Server_AddSpendCount", "Server_AddShopBuyCount", "Server_SetDirectExpEnabled", "Server_SetAutoTunshiEnabled", "Server_SetAutoPickupEnabled", "Server_AddEcexp", "Server_SetBloodlineEnabled", "Server_CraftItem", "Server_SetShenyingSkill", "Server_SetShenyinEcexp", "Server_SetJiangeSkill", "Server_SetJiangeAtkBonus", "Server_RemoveVirtualItem", "Server_RemoveBackpackItem", "Server_ClaimChongzhiReward", "Server_GiveTaReward", "Server_SaveJiangeData", "Server_SaveShenyinData", "Server_AddManualPoint", "Server_ClaimJiangeFloorReward", "Server_ClaimJiangeDailyReward"
end

--- 请求服务器初始化（客户端调用）
--- 客户端 BeginPlay 时调用，请求服务器同步初始化数据
function UGCPlayerState:RequestServerInit()
    local pc = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if pc then
        UnrealNetwork.CallUnrealRPC(self, self, "Server_RequestInit")
    end
end

--- 服务器初始化请求处理（Server RPC）
--- 服务器收到客户端初始化请求后，同步数据到客户端
---
--- 处理流程：
--- 1. EnsureDataInitialized：确保数据已加载
--- 2. UpdateClientAttributes：更新 Pawn 属性
--- 3. 同步剑隔副本数据到客户端
function UGCPlayerState:Server_RequestInit()
    -- 确保数据已初始化
    self:EnsureDataInitialized()
    -- 更新客户端属性
    self:UpdateClientAttributes()

    -- 同步剑隔副本数据到客户端
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeData", self.GameData.PlayerJiangeLevel or 1, self.GameData.PlayerJiangeProgress or 0)
    end
end

--- 转生请求处理（Server RPC）
--- 客户端请求转生，服务器执行转生逻辑
function UGCPlayerState:Server_Rebirth()
    local success, message = self:DoRebirth()
end

--- 手动加点系统（Server RPC）
---
--- 手动加点说明：
--- 玩家可以使用天赋点在四维属性上进行手动加点
--- - Attack：攻击力，每点 +2
--- - Magic：魔力，每点 +1
--- - Hp：生命值，每点 +5
--- - Bland：特殊属性，根据配置计算
---
--- 加点流程：
--- 1. 验证加点类型是否有效
--- 2. 检查天赋点数是否足够（MANUAL_POINT_COST = 1点天赋）
--- 3. 扣除天赋点数
--- 4. 增加对应属性字段
--- 5. 同步属性到客户端
--- 6. 保存存档并通知客户端结果
---
--- 字段映射（MANUAL_POINT_MAP 配置）：
--- - "Attack"：dataField=PlayerManualAttack, repField=UGCPlayerManualAttack, targetField=PlayerAttack, addPerPoint=2
--- - "Magic"：dataField=PlayerManualMagic, repField=UGCPlayerManualMagic, targetField=PlayerMagic, addPerPoint=1
--- - "Hp"：dataField=PlayerManualHp, repField=UGCPlayerManualHp, targetField=PlayerMaxHp, addPerPoint=5
--- - "Bland"：dataField=PlayerManualBland, repField=UGCPlayerManualBland, targetField=bland, addPerPoint=配置值
---
---@param pointType string 加点类型（Attack/Magic/Hp/Bland）
function UGCPlayerState:Server_AddManualPoint(pointType)
    if not UGCGameSystem.IsServer(self) then return end

    -- 从配置获取加点类型映射
    local MANUAL_POINT_MAP = Config_PlayerData.MANUAL_POINT_MAP

    -- 通知客户端加点结果的辅助函数
    local function NotifyManualPointResult(success, tipText)
        local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if not PC then
            return
        end

        -- 获取剩余天赋点数
        local remainPoints = 0
        if self.GameData then
            remainPoints = self.GameData.PlayerTalentPoints or 0
        end

        -- 发送 RPC 通知客户端
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnManualPointResult", success == true, tostring(pointType or ""), remainPoints, tipText or "")
    end

    -- 验证加点类型
    local info = MANUAL_POINT_MAP[pointType]
    if not info then
        NotifyManualPointResult(false, "加点类型无效")
        return
    end

    -- 确保数据已初始化
    self:EnsureDataInitialized()

    -- 检查天赋点数是否足够
    local currentTalentPoints = self.GameData.PlayerTalentPoints or 0
    if currentTalentPoints < Config_PlayerData.MANUAL_POINT_COST then
        NotifyManualPointResult(false, "天赋点不足")
        return
    end

    -- 扣除天赋点数
    self.GameData.PlayerTalentPoints = currentTalentPoints - Config_PlayerData.MANUAL_POINT_COST

    -- 同步天赋点数到客户端
    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerTalentPoints")

    -- 增加对应属性字段（记录手动加点的总点数）
    local current = self.GameData[info.dataField] or 0
    self.GameData[info.dataField] = current + 1

    -- 同步到网络属性
    self[info.repField] = self.GameData[info.dataField]
    UnrealNetwork.RepLazyProperty(self, info.repField)

    -- 增加实际属性值（每点加 addPerPoint）
    local oldValue = self.GameData[info.targetField] or 0
    self.GameData[info.targetField] = oldValue + info.addPerPoint

    -- 同步 HP（确保不超过最大生命值）
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local currentHp = UGCAttributeSystem.GetGameAttributeValue(Player, 'Health') or self.GameData.PlayerHp
        if currentHp > self.GameData.PlayerMaxHp then
            self.GameData.PlayerHp = self.GameData.PlayerMaxHp
        else
            self.GameData.PlayerHp = currentHp
        end
    end

    -- 更新属性并保存存档
    self:UpdateClientAttributes()
    self:DataSave()
    -- 通知客户端加点成功
    NotifyManualPointResult(true, info.successTip)
end

--- 天赋升级系统（Server RPC）
---
--- 天赋系统说明：
--- 共有9种天赋，每种天赋有独立等级和最大等级
--- 升级需要消耗虚拟物品（TALENT_UPGRADE_VIRTUAL_ITEM_ID）
--- 每级消耗的物品数量由 TALENT_CONFIG[talentType].cost 定义
---
--- 天赋列表（TALENT_CONFIG 配置）：
--- - 天赋1~9：每种天赋独立配置 maxLevel 和 cost
---
--- 升级流程：
--- 1. 验证天赋类型是否有效（配置中存在）
--- 2. 检查当前天赋等级是否已满
--- 3. 获取虚拟物品管理器并查询物品数量
--- 4. 检查物品数量是否足够
--- 5. 消耗虚拟物品
--- 6. 天赋等级 +1
--- 7. 应用天赋技能加成
--- 8. 更新战斗力排行榜
--- 9. 保存存档并通知客户端结果
---
--- 材料消耗校验：
--- - 使用 pcall 安全调用，防止虚拟物品系统异常
--- - 支持两种查询方式：带PC参数和不带PC参数
--- - 消耗后再次查询验证
---
---@param talentType number 天赋类型（1-9）
function UGCPlayerState:Server_AddTalentPointNew(talentType)
    if not UGCGameSystem.IsServer(self) then return end

    -- 将天赋类型转为整数
    talentType = math.floor(tonumber(talentType) or 0)
    -- 确保数据已初始化
    self:EnsureDataInitialized()

    -- 通知客户端天赋升级结果的辅助函数
    local function NotifyTalentUpgradeResult(success, level, remainCount, tipText)
        local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if not PC then
            return
        end

        -- 获取当前天赋等级
        local currentLevel = level
        if currentLevel == nil and self.GameData then
            currentLevel = self.GameData["PlayerTalent" .. tostring(talentType)] or 0
        end

        -- 发送 RPC 通知客户端
        UnrealNetwork.CallUnrealRPC(
            PC,
            PC,
            "Client_OnTalentUpgradeResult",
            success == true,       -- 是否成功
            talentType,            -- 天赋类型
            math.floor(tonumber(currentLevel) or 0),  -- 当前等级
            math.max(0, math.floor(tonumber(remainCount) or 0)),  -- 剩余物品数量
            tipText or ""          -- 提示文本
        )
    end

    -- 验证天赋类型配置
    local config = Config_PlayerData.TALENT_CONFIG[talentType]
    if not config then
        NotifyTalentUpgradeResult(false, nil, 0, "该天赋暂未开放")
        return
    end

    -- 获取数据字段名（如 PlayerTalent1）
    local dataField = "PlayerTalent" .. talentType
    local currentLevel = self.GameData[dataField] or 0

    -- 检查天赋是否已满级
    if currentLevel >= config.maxLevel then
        NotifyTalentUpgradeResult(false, currentLevel, 0, "该天赋已满级")
        return
    end

    -- 获取虚拟物品管理器
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    if (not PC) or (not VirtualItemManager) then
        NotifyTalentUpgradeResult(false, currentLevel, 0, "材料系统未就绪")
        return
    end

    -- 获取天赋物品数量的辅助函数（支持带PC和不带PC两种调用方式）
    local function GetTalentItemCount()
        -- 尝试带PC参数的调用
        local queryOk, queryRet = pcall(function()
            return VirtualItemManager:GetItemNum(Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID, PC)
        end)
        if queryOk then
            return math.max(0, math.floor(tonumber(queryRet) or 0))
        end

        -- 回退：不带PC参数的调用
        local fallbackOk, fallbackRet = pcall(function()
            return VirtualItemManager:GetItemNum(Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID)
        end)
        if fallbackOk then
            return math.max(0, math.floor(tonumber(fallbackRet) or 0))
        end

        return 0
    end

    -- 解析虚拟物品操作结果的辅助函数
    local function ParseRemoveResult(result)
        if result == nil then
            return true  -- nil 视为成功
        end

        local resultType = type(result)
        if resultType == "boolean" then
            return result
        end
        if resultType == "number" then
            return result > 0
        end
        if resultType == "table" then
            -- 支持多种成功标识字段名
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

    -- 检查虚拟物品数量是否足够
    local currentItemCount = GetTalentItemCount()
    if currentItemCount < config.cost then
        NotifyTalentUpgradeResult(false, currentLevel, currentItemCount, "虚拟物品5555不足")
        return
    end

    -- 消耗虚拟物品
    local removeResult = nil
    local removeOk = pcall(function()
        removeResult = VirtualItemManager:RemoveVirtualItem(PC, Config_PlayerData.TALENT_UPGRADE_VIRTUAL_ITEM_ID, config.cost)
    end)
    -- 验证消耗结果
    if (not removeOk) or (not ParseRemoveResult(removeResult)) then
        NotifyTalentUpgradeResult(false, currentLevel, GetTalentItemCount(), "虚拟物品5555不足")
        return
    end

    -- 天赋等级 +1
    local newLevel = currentLevel + 1
    self.GameData[dataField] = newLevel

    -- 同步到网络属性
    local repField = "UGCPlayerTalent" .. talentType
    self[repField] = self.GameData[dataField]
    UnrealNetwork.RepLazyProperty(self, repField)

    -- 应用天赋技能加成
    SkillSystem.ApplyTalentBuff(self, talentType)
    -- 更新战斗力排行榜
    self:UpdateCombatPowerRank()
    -- 保存存档
    self:DataSave()

    -- 通知客户端升级成功
    NotifyTalentUpgradeResult(true, newLevel, GetTalentItemCount(), "")
end

--- 解锁天赋（Server RPC）
--- 兼容旧接口，直接调用 Server_AddTalentPointNew
---
---@param talentIndex number 天赋索引
function UGCPlayerState:Server_UnlockTalent(talentIndex)
    self:Server_AddTalentPointNew(talentIndex)
end

--- 添加天赋点（Server RPC）
--- 兼容旧接口，直接调用 Server_AddTalentPointNew
---
---@param talentType number 天赋类型
function UGCPlayerState:Server_AddTalentPoint(talentType)
    self:Server_AddTalentPointNew(talentType)
end

--- 应用天赋技能加成（通用接口）
function UGCPlayerState:ApplyTalentBuff(talentType)
    return SkillSystem.ApplyTalentBuff(self, talentType)
end

--- 应用所有天赋技能加成（内部，带Player参数）
function UGCPlayerState:ApplyAllTalentBuffsInternal(Player)
    return SkillSystem.ApplyAllTalentBuffsInternal(self, Player)
end

--- 应用所有天赋技能加成（通用接口）
function UGCPlayerState:ApplyAllTalentBuffs()
    return SkillSystem.ApplyAllTalentBuffs(self)
end

--- 通知客户端玩家升级（Client RPC）
--- 升级时调用，通知 UI 等系统刷新
---
---@param Level number 升级后的等级
function UGCPlayerState:Client_OnPlayerLevelUp(Level)
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnPlayerLevelUp", self.GameData.PlayerLevel)
    end
end

--- 获取所有网络同步属性列表
---
--- 属性列表及说明：
--- - UGCPlayerLevel：玩家等级（Lazy同步）
--- - UGCPlayerRebirthCount：转生次数（Lazy同步）
--- - UGCPlayerTalentPoints：天赋点数（Lazy同步）
--- - UGCPlayerSpeedTalent：速度天赋等级（Lazy同步）
--- - UGCPlayerAttackTalent：攻击天赋等级（Lazy同步）
--- - UGCPlayerHpTalent：生命天赋等级（Lazy同步）
--- - UGCPlayerCombatPower：战斗力（Lazy同步）
--- - UGCPlayerTalent1~9：天赋1~9等级（Lazy同步）
--- - UGCDirectExpEnabled：直服经验开关（Lazy同步）
--- - UGCPlayerEcexp：额外经验（Lazy同步）
--- - UGCSpendCount：累计消费金额（Lazy同步）
--- - UGCPlayerVIP：VIP等级（Lazy同步）
--- - UGCClaimedChongzhiStr：充值奖励领取记录序列化字符串（Lazy同步）
--- - UGCPlayerManualAttack：手动加点-攻击（Lazy同步）
--- - UGCPlayerManualMagic：手动加点-魔力（Lazy同步）
--- - UGCPlayerManualHp：手动加点-生命（Lazy同步）
--- - UGCPlayerManualBland：手动加点-特殊属性（Lazy同步）
--- - UGCBloodlineEnabled：血脉启用状态（Lazy同步）
---
--- Lazy 同步说明：
--- Lazy 同步模式下，属性变化后不会立即同步，而是等待下次同步机会
--- 需要手动调用 RepLazyProperty 触发同步
---
---@return table 属性列表
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

--- 玩家等级同步回调（OnRep）
--- 当客户端收到服务器同步的等级变化时调用
function UGCPlayerState:OnRep_UGCPlayerLevel()
    if self.GameData then
        self.GameData.PlayerLevel = self.UGCPlayerLevel
    end
    -- 广播等级变化事件（通知 UI 等系统刷新）
    self.PlayerLevelChangedDelegate:Broadcast(self.UGCPlayerLevel)
end

--- 转生次数同步回调（OnRep）
--- 当客户端收到服务器同步的转生次数变化时调用
function UGCPlayerState:OnRep_UGCPlayerRebirthCount()
    if self.GameData then
        self.GameData.PlayerRebirthCount = self.UGCPlayerRebirthCount
    end
end

--- 天赋点数同步回调（OnRep）
--- 当客户端收到服务器同步的天赋点数变化时调用
--- 同时通知天赋树 UI 刷新
function UGCPlayerState:OnRep_UGCPlayerTalentPoints()
    if self.GameData then
        self.GameData.PlayerTalentPoints = self.UGCPlayerTalentPoints
    end
    self:NotifyTalentTreeRefresh()
end

--- 战斗力同步回调（OnRep）
--- 当客户端收到服务器同步的战斗力变化时调用（暂无额外处理）
function UGCPlayerState:OnRep_UGCPlayerCombatPower()
end

--- 累计消费金额同步回调（OnRep）
--- 当客户端收到服务器同步的消费金额变化时调用
--- 同步后重新计算 VIP 等级并通知消费 UI 刷新
function UGCPlayerState:OnRep_UGCSpendCount()
    self.TotalSpendCount = tonumber(self.UGCSpendCount) or 0
    if self.GameData then
        local vip = self.UGCPlayerVIP
        if vip == nil then
            -- 如果VIP未同步，根据消费重新计算
            vip = Config_PlayerData.CalcVIPLevelBySpend(self.TotalSpendCount)
        end
        self.GameData.PlayerVIP = tonumber(vip) or 0
    end
    -- 通知消费 UI 刷新
    self:NotifySpendUIRefresh()
end

--- VIP等级同步回调（OnRep）
--- 当客户端收到服务器同步的VIP等级变化时调用
function UGCPlayerState:OnRep_UGCPlayerVIP()
    if self.GameData then
        self.GameData.PlayerVIP = tonumber(self.UGCPlayerVIP) or 0
    end
end

--- 充值奖励领取记录同步回调（OnRep）
--- 当客户端收到服务器同步的充值奖励领取记录变化时调用
--- 反序列化字符串并刷新消费 UI
function UGCPlayerState:OnRep_UGCClaimedChongzhiStr()
    self.ClaimedChongzhi = self:DeserializeClaimedChongzhi(self.UGCClaimedChongzhiStr)
    self:NotifySpendUIRefresh()
end

--- 通知天赋树 UI 刷新
--- 检查本地玩家天赋树界面是否打开，如果打开则刷新
function UGCPlayerState:NotifyTalentTreeRefresh()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.TalentTree then
        local talentTree = pc.MMainUI.TalentTree
        -- 只有天赋树界面可见时才刷新
        if talentTree:GetVisibility() == ESlateVisibility.Visible then
            talentTree:RefreshUI()
        end
    end
end

--- 通知消费相关 UI 刷新
--- 检查当前打开的界面，如果是消费相关界面则刷新购买槽位
function UGCPlayerState:NotifySpendUIRefresh()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if not pc or not pc.MMainUI then
        return
    end

    local activeUI = pc.MMainUI.active
    -- 检查当前界面是否可见且有刷新方法
    if activeUI and UGCObjectUtility.IsObjectValid(activeUI) and activeUI:GetVisibility() == ESlateVisibility.Visible then
        if activeUI.RefreshBuySlots then
            activeUI:RefreshBuySlots()
        end
    end
end

--- 同步消费相关属性
--- 将累计消费、VIP等级、充值奖励领取记录同步到网络属性
function UGCPlayerState:SyncSpendReplicatedProperties()
    self.UGCSpendCount = self:GetTotalSpendCount()
    self.UGCPlayerVIP = self.GameData and (self.GameData.PlayerVIP or 0) or 0
    self.UGCClaimedChongzhiStr = self:SerializeClaimedChongzhi(self.ClaimedChongzhi)
end

--- 复制消费属性到网络
--- 同步并标记需要网络复制的消费相关属性
function UGCPlayerState:ReplicateSpendProperties()
    self:SyncSpendReplicatedProperties()
    UnrealNetwork.RepLazyProperty(self, "UGCSpendCount")
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerVIP")
    UnrealNetwork.RepLazyProperty(self, "UGCClaimedChongzhiStr")
end

-- 为天赋1~9生成同步回调（OnRep_UGCPlayerTalent1 ~ OnRep_UGCPlayerTalent9）
-- 每个天赋的回调逻辑相同：更新 GameData 并刷新天赋树 UI
for i = 1, 9 do
    UGCPlayerState["OnRep_UGCPlayerTalent" .. i] = function(self)
        if self.GameData then
            self.GameData["PlayerTalent" .. i] = self["UGCPlayerTalent" .. i]
        end
        self:NotifyTalentTreeRefresh()
    end
end

--- 同步所有网络属性到客户端
---
--- 同步的属性列表：
--- - 核心属性：Level, RebirthCount, TalentPoints, CombatPower
--- - 天赋相关：SpeedTalent, AttackTalent, HpTalent, Talent1~9
--- - 功能开关：DirectExpEnabled, BloodlineEnabled
--- - 经验相关：PlayerEcexp
--- - 消费相关：SpendCount, VIP, ClaimedChongzhiStr
--- - 手动加点：ManualAttack, ManualMagic, ManualHp, ManualBland
---
--- 同步后操作：
--- - 发送剑隔副本层数到客户端
--- - 更新剑隔层数排行榜
function UGCPlayerState:SyncReplicatedProperties()
    -- 同步核心属性
    self.UGCPlayerLevel = self.GameData.PlayerLevel
    self.UGCPlayerRebirthCount = self.GameData.PlayerRebirthCount
    self.UGCPlayerTalentPoints = self.GameData.PlayerTalentPoints
    self.UGCPlayerCombatPower = PlayerAttributeCalculator.GetCombatPower(self)
    self.UGCDirectExpEnabled = self.GameData.DirectExpEnabled
    self.UGCPlayerEcexp = self.GameData.PlayerEcexp

    -- 同步消费相关属性
    self:SyncSpendReplicatedProperties()

    -- 同步手动加点属性
    self.UGCPlayerManualAttack = self.GameData.PlayerManualAttack or 0
    self.UGCPlayerManualMagic = self.GameData.PlayerManualMagic or 0
    self.UGCPlayerManualHp = self.GameData.PlayerManualHp or 0
    self.UGCPlayerManualBland = self.GameData.PlayerManualBland or 0
    self.UGCBloodlineEnabled = self.GameData.BloodlineEnabled or false

    -- 同步天赋1~9等级
    for i = 1, 9 do
        self["UGCPlayerTalent" .. i] = self.GameData["PlayerTalent" .. i]
    end

    -- 同步其他天赋属性
    self.UGCPlayerSpeedTalent = self.GameData.PlayerSpeedTalent
    self.UGCPlayerAttackTalent = self.GameData.PlayerAttackTalent
    self.UGCPlayerHpTalent = self.GameData.PlayerHpTalent

    -- 标记所有属性为需要同步
    local repProps = {"UGCPlayerLevel", "UGCPlayerRebirthCount", "UGCPlayerTalentPoints", "UGCPlayerCombatPower",
                      "UGCPlayerSpeedTalent", "UGCPlayerAttackTalent", "UGCPlayerHpTalent", "UGCDirectExpEnabled", "UGCPlayerEcexp",
                      "UGCSpendCount", "UGCPlayerVIP", "UGCClaimedChongzhiStr",
                      "UGCPlayerManualAttack", "UGCPlayerManualMagic", "UGCPlayerManualHp", "UGCPlayerManualBland", "UGCBloodlineEnabled"}

    -- 添加天赋1~9到同步列表
    for i = 1, 9 do
        table.insert(repProps, "UGCPlayerTalent" .. i)
    end

    -- 触发所有属性的网络同步
    for _, prop in ipairs(repProps) do
        UnrealNetwork.RepLazyProperty(self, prop)
    end

    -- 同步剑隔副本层数到客户端
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        local floor = self.GameData.PlayerJiangeFloor or 0
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_UpdateJiangeFloor", floor)
    end

    -- 更新剑隔层数排行榜
    self:UpdateJiangeFloorRank()
end

--- 生命周期回调：玩家状态 EndPlay
--- 玩家退出时保存数据到存档
---
---@param EndPlayReason number 退出原因
function UGCPlayerState:ReceiveEndPlay(EndPlayReason)
    if UGCGameSystem.IsServer(self) then
        -- 保存玩家数据到存档
        self:DataSave()
    end

    -- 调用父类的 EndPlay
    UGCPlayerState.SuperClass.ReceiveEndPlay(self, EndPlayReason)
end

--- 增加消费计数（Server RPC）
--- 玩家消费虚拟物品时调用，累计到 TotalSpendCount
--- 并更新 VIP 等级
---
---@param amount number 消费金额
function UGCPlayerState:Server_AddSpendCount(amount)
    VirtualItemSystem.Server_AddSpendCount(self, amount)
end

--- 增加商店购买计数（Server RPC）
--- 玩家在商店购买物品时调用
function UGCPlayerState:Server_AddShopBuyCount()
    VirtualItemSystem.Server_AddShopBuyCount(self)
end

--- 设置直服经验开关（Server RPC）
--- 玩家可以开关直服经验获取功能
---
---@param isEnabled boolean 是否启用直服经验
function UGCPlayerState:Server_SetDirectExpEnabled(isEnabled)
    self.GameData.DirectExpEnabled = isEnabled
    self.UGCDirectExpEnabled = isEnabled
    UnrealNetwork.RepLazyProperty(self, "UGCDirectExpEnabled")
    self:DataSave()
end

--- 直服经验开关同步回调（OnRep）
function UGCPlayerState:OnRep_UGCDirectExpEnabled()
    if self.GameData then
        self.GameData.DirectExpEnabled = self.UGCDirectExpEnabled
    end
end

--- 设置自动吞噬开关（Server RPC）
--- 玩家可以开关自动吞噬功能
---
---@param isEnabled boolean 是否启用自动吞噬
function UGCPlayerState:Server_SetAutoTunshiEnabled(isEnabled)
    VirtualItemSystem.Server_SetAutoTunshiEnabled(self, isEnabled)
end

--- 设置自动拾取开关（Server RPC）
--- 玩家可以开关自动拾取功能
---
---@param isEnabled boolean 是否启用自动拾取
function UGCPlayerState:Server_SetAutoPickupEnabled(isEnabled)
    VirtualItemSystem.Server_SetAutoPickupEnabled(self, isEnabled)
end

--- 增加额外经验（Server RPC）
--- 额外经验（Ecexp）是一种独立于普通经验的加成经验
--- 可以通过身印等系统获得
---
---@param amount number 要增加的额外经验值
function UGCPlayerState:Server_AddEcexp(amount)
    if not UGCGameSystem.IsServer(self) then return end
    if not amount or amount <= 0 then
        return
    end

    -- 增加额外经验
    self.GameData.PlayerEcexp = (self.GameData.PlayerEcexp or 0) + amount
    self.UGCPlayerEcexp = self.GameData.PlayerEcexp
    UnrealNetwork.RepLazyProperty(self, "UGCPlayerEcexp")

    -- 同步到 Pawn 属性（基础 + 身印加成）
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local totalEcexp = self.GameData.PlayerEcexp + (self.ShenyinEcexpBonus or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', totalEcexp)
    end

    -- 保存存档
    self:DataSave()
end

--- 额外经验同步回调（OnRep）
function UGCPlayerState:OnRep_UGCPlayerEcexp()
    if self.GameData then
        self.GameData.PlayerEcexp = self.UGCPlayerEcexp
    end
end

--- 设置身印经验加成（Server RPC）
--- 身印系统提供的额外经验加成（临时加成，不持久化）
---
---@param amount number 身印提供的额外经验加成
function UGCPlayerState:Server_SetShenyinEcexp(amount)
    if not UGCGameSystem.IsServer(self) then return end
    if not amount then return end
    -- 身印加成存储在运行时变量，不保存到存档
    self.ShenyinEcexpBonus = amount

    -- 同步到 Pawn 属性
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if Player then
        local totalEcexp = (self.GameData.PlayerEcexp or 0) + (self.ShenyinEcexpBonus or 0)
        UGCAttributeSystem.SetGameAttributeValue(Player, 'Ecexp', totalEcexp)
    end
end

--- 设置血脉启用状态（Server RPC）
--- 血脉系统开关，影响技能系统
---
---@param isEnabled boolean 是否启用血脉
function UGCPlayerState:Server_SetBloodlineEnabled(isEnabled)
    SkillSystem.Server_SetBloodlineEnabled(self, isEnabled)
end

--- 血脉启用状态同步回调（OnRep）
function UGCPlayerState:OnRep_UGCBloodlineEnabled()
    if self.GameData then
        self.GameData.BloodlineEnabled = self.UGCBloodlineEnabled
    end
end

--- 制作物品（Server RPC）
--- 玩家使用材料制作物品
---
--- 制作流程：
--- 1. 检查玩家 Pawn 是否存在
--- 2. 检查所有材料是否足够
--- 3. 消耗所有材料
--- 4. 添加制作产物到背包
---
---@param InputItemIDs table<number> 输入物品ID列表
---@param InputCounts table<number> 对应物品消耗数量列表
---@param OutputItemID number 输出物品ID
---@param OutputCount number 输出物品数量
function UGCPlayerState:Server_CraftItem(InputItemIDs, InputCounts, OutputItemID, OutputCount)
    local playerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not playerPawn then
        return
    end

    -- 第一步：检查所有材料是否足够
    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        local currentCount = UGCBackpackSystemV2.GetItemCountV2(playerPawn, itemID)

        if currentCount < needCount then
            return  -- 材料不足，制作失败
        end
    end

    -- 第二步：消耗所有材料
    for i = 1, #InputItemIDs do
        local itemID = InputItemIDs[i]
        local needCount = InputCounts[i]
        local removedCount = UGCBackpackSystemV2.RemoveItemV2(playerPawn, itemID, needCount)

        if removedCount == 0 or removedCount ~= needCount then
            return  -- 消耗失败，制作失败
        end
    end

    -- 第三步：添加产物到背包
    local addedCount, defineIDs = UGCBackpackSystemV2.AddItemV2(playerPawn, OutputItemID, OutputCount)
end

--- 设置声翼技能（Server RPC）
--- 玩家装备/卸下声翼技能
---
---@param skillPath string 技能路径
---@param isWear boolean 是否装备
function UGCPlayerState:Server_SetShenyingSkill(skillPath, isWear)
    SkillSystem.Server_SetShenyingSkill(self, skillPath, isWear)
end

--- 设置剑隔技能（Server RPC）
--- 玩家装备/卸下剑隔技能
---
---@param skillPath string 技能路径
---@param isWear boolean 是否装备
function UGCPlayerState:Server_SetJiangeSkill(skillPath, isWear)
    SkillSystem.Server_SetJiangeSkill(self, skillPath, isWear)
end

--- 移除虚拟物品（Server RPC）
--- 扣除玩家持有的虚拟物品
---
---@param virtualItemID number 虚拟物品ID
---@param count number 移除数量
function UGCPlayerState:Server_RemoveVirtualItem(virtualItemID, count)
    VirtualItemSystem.Server_RemoveVirtualItem(self, virtualItemID, count)
end

--- 移除背包物品（Server RPC）
--- 扣除玩家背包中的实物物品
---
---@param itemID number 物品ID
---@param count number 移除数量
function UGCPlayerState:Server_RemoveBackpackItem(itemID, count)
    VirtualItemSystem.Server_RemoveBackpackItem(self, itemID, count)
end

--- 领取充值奖励（Server RPC）
--- 玩家领取已达成条件的充值奖励
---
---@param rewardID number 奖励ID
function UGCPlayerState:Server_ClaimChongzhiReward(rewardID)
    RewardSystem.Server_ClaimChongzhiReward(self, rewardID)
end

--- 给予TA奖励（Server RPC）
--- 根据层数发放TA副本奖励
---
---@param floorNum number 楼层编号
function UGCPlayerState:Server_GiveTaReward(floorNum)
    RewardSystem.Server_GiveTaReward(self, floorNum)
end

--- 保存剑隔副本数据（Server RPC）
--- 玩家在剑隔副本中的进度变化时保存
---
--- 保存的数据：
--- - PlayerJiangeLevel：剑隔副本当前等级
--- - PlayerJiangeProgress：剑隔副本当前进度（0-100）
---
---@param jiangeLevel number 剑隔等级
---@param jiangeProgress number 进度百分比
function UGCPlayerState:Server_SaveJiangeData(jiangeLevel, jiangeProgress)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    -- 转换并验证参数
    local targetLevel = math.floor(tonumber(jiangeLevel) or 1)
    local targetProgress = tonumber(jiangeProgress) or 0
    -- 进度限制在 0-100 之间
    targetProgress = math.max(0, math.min(100, targetProgress))
    -- 精度处理：保留1位小数
    targetProgress = math.floor(targetProgress * 10 + 0.5) / 10

    -- 保存到 GameData
    self.GameData.PlayerJiangeLevel = targetLevel
    self.GameData.PlayerJiangeProgress = targetProgress

    -- 同步到客户端
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeData", self.GameData.PlayerJiangeLevel, self.GameData.PlayerJiangeProgress)
    end

    -- 保存存档
    self:DataSave()
end

--- 保存身印数据（Server RPC）
--- 身印系统的自定义数据字符串
---
---@param dataStr string 身印数据字符串
function UGCPlayerState:Server_SaveShenyinData(dataStr)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    self.GameData.PlayerShenyinData = dataStr or ""

    -- 同步到客户端
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncShenyinData", self.GameData.PlayerShenyinData)
    end

    -- 保存存档
    self:DataSave()
end

--- 领取剑隔层数奖励（Server RPC）
--- 玩家达到指定剑隔层数后领取奖励
---
---@param floorNum number 楼层编号
function UGCPlayerState:Server_ClaimJiangeFloorReward(floorNum)
    RewardSystem.Server_ClaimJiangeFloorReward(self, floorNum)
end

--- 领取剑隔每日奖励（Server RPC）
--- 玩家每日重置后领取剑隔每日奖励
function UGCPlayerState:Server_ClaimJiangeDailyReward()
    RewardSystem.Server_ClaimJiangeDailyReward(self)
end

--- 设置剑隔攻击加成（Server RPC）
--- 剑隔系统提供的攻击力加成百分比
---
---@param bonusPercent number 加成百分比
function UGCPlayerState:Server_SetJiangeAtkBonus(bonusPercent)
    if not UGCGameSystem.IsServer(self) then return end
    bonusPercent = tonumber(bonusPercent) or 0
    -- 存储加成百分比（运行时变量）
    self.JiangeAtkBonusPercent = bonusPercent
    -- 更新客户端属性
    self:UpdateClientAttributes()
    -- 保存存档
    self:DataSave()
end

--- 重新应用已装备技能
--- 用于技能系统重新加载时恢复装备状态
function UGCPlayerState:ReapplyWearingSkills()
    SkillSystem.ReapplyWearingSkills(self)
end

return UGCPlayerState
