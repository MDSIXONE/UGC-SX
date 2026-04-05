---@class TriggerBox_Single1_C:TriggerBox_C
---@field SpawnerManagers ULuaArrayHelper<AActor>
--Edit Below--
local TriggerBox_Single1 = {}

function TriggerBox_Single1:ReceiveBeginPlay()
    TriggerBox_Single1.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit()
end

function TriggerBox_Single1:LuaInit()
    if self.bInitDoOnce then
        return
    end

    self.bInitDoOnce = true
    self.PlayersInZone = {}
    self.bSpawnerStarted = false
    -- 结算/超时后锁定，避免匹配前再次触发刷怪
    self.bBlockAutoResume = false

    if self.CollisionComponent then
        self.CollisionComponent.OnComponentBeginOverlap:Add(self.CollisionComponent_OnComponentBeginOverlap, self)
        self.CollisionComponent.OnComponentEndOverlap:Add(self.CollisionComponent_OnComponentEndOverlap, self)
    end
end

function TriggerBox_Single1:GetPlayerCount()
    local count = 0
    for _ in pairs(self.PlayersInZone or {}) do
        count = count + 1
    end
    return count
end

function TriggerBox_Single1:StartOrResumeAllSpawners()
    if self.bBlockAutoResume then
        return
    end

    if not self.SpawnerManagers then
        return
    end

    local count = self.SpawnerManagers:Num()
    for i = 1, count do
        local spawner = self.SpawnerManagers:Get(i)
        if spawner then
            spawner.OwnerTriggerBox = self

            if not self.bSpawnerStarted then
                if spawner.ResetSpawnerManager then
                    spawner:ResetSpawnerManager(true)
                end
                if spawner.StartSpawnerManager then
                    spawner:StartSpawnerManager()
                end
            end

            if spawner.ResumeSpawnerManager then
                spawner:ResumeSpawnerManager()
            end
        end
    end

    self.bSpawnerStarted = true
end

function TriggerBox_Single1:CollisionComponent_OnComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not OtherActor or not OtherActor.PlayerState then
        return
    end

    local actorKey = tostring(OtherActor)
    self.PlayersInZone[actorKey] = OtherActor

    if self:GetPlayerCount() == 1 then
        self:StartOrResumeAllSpawners()
    end
end

function TriggerBox_Single1:CollisionComponent_OnComponentEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor or not OtherActor.PlayerState then
        return
    end

    local actorKey = tostring(OtherActor)
    self.PlayersInZone[actorKey] = nil

    -- Single1 特殊逻辑：玩家全部离开后仍保持刷怪，不在此处暂停/清怪
end

-- 在匹配前由超时/结算流程调用，统一暂停并清怪
function TriggerBox_Single1:StopAndCleanAll()
    self.bBlockAutoResume = true

    if not self.SpawnerManagers then
        return
    end

    local count = self.SpawnerManagers:Num()
    for i = 1, count do
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

return TriggerBox_Single1