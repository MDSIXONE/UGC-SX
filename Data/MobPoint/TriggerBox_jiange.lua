---@class TriggerBox_jiange_C:TriggerBox
---@field SpawnerManagers ULuaArrayHelper<AActor>
--Edit Below--
-- 无尽剑阁触发盒：玩家进入后延迟4秒启动刷怪，离开暂停清除+重置层数
local TriggerBox_jiange = {}

function TriggerBox_jiange:ReceiveBeginPlay()
    TriggerBox_jiange.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit()
end

function TriggerBox_jiange:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true

    self.PlayersInZone = {}
    self.bSpawnerStarted = false

    self.CollisionComponent.OnComponentBeginOverlap:Add(self.OnBeginOverlap, self)
    self.CollisionComponent.OnComponentEndOverlap:Add(self.OnEndOverlap, self)
    ugcprint("[TriggerBox_jiange] 初始化完成，碰撞事件已绑定")
end

function TriggerBox_jiange:GetPlayerCount()
    local count = 0
    for _ in pairs(self.PlayersInZone or {}) do count = count + 1 end
    return count
end

function TriggerBox_jiange:OnBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not OtherActor or not OtherActor.PlayerState then return end

    self.PlayersInZone[tostring(OtherActor)] = OtherActor
    local count = self:GetPlayerCount()
    ugcprint("[TriggerBox_jiange] 玩家进入，当前玩家数: " .. count)

    if count == 1 and not self.bSpawnerStarted then
        ugcprint("[TriggerBox_jiange] 第一个玩家进入，4秒后启动刷怪")
        self.bSpawnerStarted = true
        local this = self
        UGCGameSystem.SetTimer(this, function()
            if this:GetPlayerCount() > 0 then
                ugcprint("[TriggerBox_jiange] 延迟4秒到，启动刷怪")
                this:StartAllSpawners()
            else
                ugcprint("[TriggerBox_jiange] 延迟4秒到，但玩家已离开，取消刷怪")
                this.bSpawnerStarted = false
            end
        end, 4.0, false)
    end
end

function TriggerBox_jiange:StartAllSpawners()
    if not self.SpawnerManagers then
        ugcprint("[TriggerBox_jiange] 错误：SpawnerManagers 为nil")
        return
    end

    local count = self.SpawnerManagers:Num()
    ugcprint("[TriggerBox_jiange] 开始启动 SpawnerManagers，数量: " .. count)
    for i = 1, count do
        local spawner = self.SpawnerManagers:Get(i)
        ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " = " .. tostring(spawner))
        if spawner then
            -- 先注册OwnerTriggerBox（最重要，放最前面）
            spawner.OwnerTriggerBox = self

            -- 先启动刷怪（关键逻辑放在调试之前，防止调试崩溃导致刷怪不启动）
            local startOk, startErr = pcall(function()
                spawner:ResetSpawnerManager(true)
                spawner:StartSpawnerManager()
                spawner:ResumeSpawnerManager()
            end)
            if startOk then
                ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 启动完成")
            else
                ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 启动失败: " .. tostring(startErr))
            end

            -- 调试信息（全部pcall包裹，不影响主逻辑）
            pcall(function()
                local className = spawner:GetClass() and spawner:GetClass():GetName() or "unknown"
                ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 类名: " .. className)
            end)

            pcall(function()
                if spawner.SpawnPoints then
                    local spCount = spawner.SpawnPoints:Num()
                    ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " SpawnPoints数量: " .. spCount)
                else
                    ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " SpawnPoints为nil")
                end
            end)

            pcall(function()
                if spawner.WaveConfigs then
                    ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " WaveConfigs数量: " .. spawner.WaveConfigs:Num())
                else
                    ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " WaveConfigs为nil")
                end
            end)

            pcall(function()
                ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 属性列表:")
                for k, v in pairs(spawner) do
                    ugcprint("[TriggerBox_jiange]   " .. tostring(k) .. " = " .. tostring(v))
                end
            end)
        end
    end
end

function TriggerBox_jiange:OnEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor or not OtherActor.PlayerState then return end

    self.PlayersInZone[tostring(OtherActor)] = nil
    local count = self:GetPlayerCount()
    ugcprint("[TriggerBox_jiange] 玩家离开，剩余玩家数: " .. count)

    if count == 0 and self.bSpawnerStarted then
        ugcprint("[TriggerBox_jiange] 所有玩家离开，停止刷怪并重置层数")
        self.bSpawnerStarted = false
        if self.SpawnerManagers then
            local num = self.SpawnerManagers:Num()
            for i = 1, num do
                local spawner = self.SpawnerManagers:Get(i)
                if spawner then
                    if spawner.PauseSpawnerManager then
                        spawner:PauseSpawnerManager()
                    end
                    if spawner.CleanAllMobs then
                        spawner:CleanAllMobs(true)
                    end
                end
            end
        end
        -- 重置层数为存档最高层+1
        local GLQjiange = require("Script.Data.MobPoint.GLQjiange")
        if GLQjiange then
            local savedFloor = 0
            local allPCs = UGCGameSystem.GetAllPlayerController()
            if allPCs then
                for _, aPC in pairs(allPCs) do
                    local ps = UGCGameSystem.GetPlayerStateByPlayerController(aPC)
                    if ps and ps.GameData then
                        local f = ps.GameData.PlayerJiangeFloor or 0
                        if f > savedFloor then savedFloor = f end
                    end
                end
            end
            GLQjiange.CurrentFloor = savedFloor + 1
            ugcprint("[TriggerBox_jiange] 层数重置为存档最高层+1: " .. GLQjiange.CurrentFloor)
        end
        -- 重置spawner的初始化标记，下次进入重新读取存档
        if self.SpawnerManagers then
            local num = self.SpawnerManagers:Num()
            for i = 1, num do
                local spawner = self.SpawnerManagers:Get(i)
                if spawner then
                    spawner.bDataInited = false
                    spawner.MobSpawnedThisWave = false
                end
            end
        end
    end
end

-- GLQjiange回调：通知区域内玩家弹结算UI
function TriggerBox_jiange:NotifyLevelComplete(levelNum)
    ugcprint("[TriggerBox_jiange] 第 " .. tostring(levelNum) .. " 层完成，通知玩家弹结算UI")

    local playerCount = 0
    for actorKey, pawn in pairs(self.PlayersInZone or {}) do
        playerCount = playerCount + 1
        if pawn then
            local PC = UGCGameSystem.GetPlayerControllerByPlayerPawn(pawn)
            if PC then
                PC.CurrentTriggerBox = self
                ugcprint("[TriggerBox_jiange] 发送RPC Client_ShowTaSettlementUI, levelNum=" .. tostring(levelNum))
                UnrealNetwork.CallUnrealRPC(PC, PC, "Client_ShowTaSettlementUI", levelNum)
            end
        end
    end

    -- 如果PlayersInZone为空，通知所有玩家
    if playerCount == 0 then
        ugcprint("[TriggerBox_jiange] PlayersInZone为空，通知所有玩家")
        local allPCs = UGCGameSystem.GetAllPlayerController()
        if allPCs then
            for _, pc in pairs(allPCs) do
                pc.CurrentTriggerBox = self
                UnrealNetwork.CallUnrealRPC(pc, pc, "Client_ShowTaSettlementUI", levelNum)
            end
        end
    end
end

-- 玩家点击继续后，恢复刷怪
function TriggerBox_jiange:ResumeSpawning()
    ugcprint("[TriggerBox_jiange] 恢复刷怪")
    if self.SpawnerManagers then
        local count = self.SpawnerManagers:Num()
        for i = 1, count do
            local spawner = self.SpawnerManagers:Get(i)
            if spawner and spawner.ResumeAfterSettlement then
                spawner:ResumeAfterSettlement()
            end
        end
    end
end

return TriggerBox_jiange
