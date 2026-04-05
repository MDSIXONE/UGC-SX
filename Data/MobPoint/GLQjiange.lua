---@class GLQjiange_C:BP_UGCMobSpawnerManager_C
--Edit Below--
-- 无尽剑阁刷怪管理器（参考 MOBGLQ 模式）
local GLQjiange = {}

-- 全局层数（所有玩家共享）
GLQjiange.CurrentFloor = 1

-- mob数据表路径
local MobTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/mob.mob')

function GLQjiange:ReceiveBeginPlay()
    GLQjiange.SuperClass.ReceiveBeginPlay(self)
    self:InitData()
    ugcprint("[GLQjiange] ReceiveBeginPlay 初始化成功")

    -- 调试信息（全部pcall包裹）
    pcall(function()
        local className = self:GetClass() and self:GetClass():GetName() or "unknown"
        ugcprint("[GLQjiange] 自身类名: " .. className)
    end)

    pcall(function()
        if self.SpawnPoints then
            ugcprint("[GLQjiange] SpawnPoints数量: " .. self.SpawnPoints:Num())
        else
            ugcprint("[GLQjiange] SpawnPoints为nil（未配置刷怪点）")
        end
    end)

    pcall(function()
        ugcprint("[GLQjiange] 自身属性列表:")
        for k, v in pairs(self) do
            ugcprint("[GLQjiange]   " .. tostring(k) .. " = " .. tostring(v))
        end
    end)
end

function GLQjiange:InitData()
    if self.bDataInited then return end
    self.bDataInited = true

    -- 从存档读取最高层数，从下一层开始
    local savedFloor = 0
    local allPCs = UGCGameSystem.GetAllPlayerController()
    if allPCs then
        for _, pc in pairs(allPCs) do
            local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
            if ps and ps.GameData then
                local f = ps.GameData.PlayerJiangeFloor or 0
                if f > savedFloor then savedFloor = f end
            end
        end
    end
    GLQjiange.CurrentFloor = savedFloor + 1

    self.MobSpawnTimerIndex = 0
    self.MobSpawnedThisWave = false
    ugcprint("[GLQjiange] InitData 完成，起始层=" .. GLQjiange.CurrentFloor)
end

-- 根据层数获取怪物配置
function GLQjiange:GetMobConfig(floor)
    local config = UGCGameSystem.GetTableDataByRowName(MobTablePath, tostring(floor))
    if config then
        ugcprint("[GLQjiange] 读取到第" .. floor .. "层配置: HP=" .. tostring(config.mobhp) .. ", AT=" .. tostring(config.mobat))
    else
        ugcprint("[GLQjiange] 未找到第" .. floor .. "层配置，使用默认缩放")
    end
    return config
end

-- 怪物刷出事件
function GLQjiange:OnMobSpawn(Mob)
    self:InitData()
    self.MobSpawnedThisWave = true
    ugcprint("[GLQjiange] 怪物刷出: " .. tostring(Mob))

    local floor = GLQjiange.CurrentFloor or 1
    local config = self:GetMobConfig(floor)

    local hp = 100 * floor
    local at = 10 * floor
    if config then
        hp = config.mobhp or hp
        at = config.mobat or at
    end

    if Mob then
        Mob.MobAttack = at
        ugcprint("[GLQjiange] 设置怪物攻击力: " .. tostring(at))

        self.MobSpawnTimerIndex = (self.MobSpawnTimerIndex or 0) + 1
        local timerName = "GLQjiange_SetHP_" .. tostring(self.MobSpawnTimerIndex)
        local mobRef = Mob
        UGCTimerUtility.CreateLuaTimer(0.2, function()
            ugcprint("[GLQjiange] 延迟回调，设置怪物属性, timer=" .. timerName)
            local ok, err = pcall(function()
                UGCAttributeSystem.SetGameAttributeValue(mobRef, 'HealthMax', hp)
                UGCAttributeSystem.SetGameAttributeValue(mobRef, 'Health', hp)
            end)
            if ok then
                ugcprint("[GLQjiange] 设置成功: HP=" .. tostring(hp))
            else
                ugcprint("[GLQjiange] 设置失败: " .. tostring(err))
            end
        end, false, timerName)
    end
end

-- 所有怪物死亡
function GLQjiange:OnAllMobDie()
    self:InitData()

    -- 关键保护：如果本波没有怪物生成过，忽略（防止空波无限循环）
    if not self.MobSpawnedThisWave then
        ugcprint("[GLQjiange] 本波未生成过怪物，忽略OnAllMobDie（检查蓝图SpawnPoints配置）")
        return
    end

    ugcprint("[GLQjiange] 第 " .. GLQjiange.CurrentFloor .. " 层怪物全灭")
    self.MobSpawnedThisWave = false
    self.IsPausedForSettlement = true

    -- 保存最高层数到玩家存档
    self:SaveFloorRecord(GLQjiange.CurrentFloor)

    -- 通知 TriggerBox 弹结算UI（参考 example MOBGLQ 模式）
    if self.OwnerTriggerBox and self.OwnerTriggerBox.NotifyLevelComplete then
        self.OwnerTriggerBox:NotifyLevelComplete(GLQjiange.CurrentFloor)
    else
        ugcprint("[GLQjiange] 警告：OwnerTriggerBox 不存在，自动继续下一层")
        self:ResumeAfterSettlement()
    end
end

-- 玩家点击继续后，升层并重新刷怪
function GLQjiange:ResumeAfterSettlement()
    GLQjiange.CurrentFloor = GLQjiange.CurrentFloor + 1
    ugcprint("[GLQjiange] 结算完成，开始第 " .. GLQjiange.CurrentFloor .. " 层")
    self.IsPausedForSettlement = false

    -- 通知客户端更新层数显示
    self:NotifyFloorUpdate()

    self:ResetSpawnerManager(true)
    local this = self
    UGCGameSystem.SetTimer(this, function()
        this:StartSpawnerManager()
        this:ResumeSpawnerManager()
        ugcprint("[GLQjiange] 第 " .. GLQjiange.CurrentFloor .. " 层刷怪已启动")
    end, 0.5, false)
end

-- 保存最高层数到所有区域内玩家的存档
function GLQjiange:SaveFloorRecord(floor)
    local allPCs = UGCGameSystem.GetAllPlayerController()
    if not allPCs then return end
    for _, pc in pairs(allPCs) do
        local playerState = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if playerState and playerState.GameData then
            local oldFloor = playerState.GameData.PlayerJiangeFloor or 0
            if floor > oldFloor then
                playerState.GameData.PlayerJiangeFloor = floor
                ugcprint("[GLQjiange] 玩家最高层数更新: " .. oldFloor .. " -> " .. floor)
                if playerState.DataSave then
                    playerState:DataSave()
                end
                -- 更新闯关层数排行榜
                if playerState.UpdateJiangeFloorRank then
                    playerState:UpdateJiangeFloorRank()
                end
            end
        end
        -- 通知客户端更新层数显示
        UnrealNetwork.CallUnrealRPC(pc, pc, "Client_UpdateJiangeFloor", floor)
    end
end

-- 通知客户端更新层数显示（通过RPC）
-- JiangeFloor 存的是"已完成的最高层数"，客户端显示时 +1 表示"下一层要打的"
function GLQjiange:NotifyFloorUpdate()
    local allPlayers = UGCGameSystem.GetAllPlayerController()
    if not allPlayers then return end
    for _, pc in pairs(allPlayers) do
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        local savedFloor = 0
        if ps and ps.GameData then
            savedFloor = ps.GameData.PlayerJiangeFloor or 0
        end
        UnrealNetwork.CallUnrealRPC(pc, pc, "Client_UpdateJiangeFloor", savedFloor)
    end
end

return GLQjiange
