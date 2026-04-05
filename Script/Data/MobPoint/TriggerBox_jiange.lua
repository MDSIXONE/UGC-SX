---@class TriggerBox_jiange_C:TriggerBox
---@field SpawnerManagers ULuaArrayHelper<AActor>
--Edit Below--
-- Endless Sword Pavilion trigger box: start spawning after a 4 second delay when a player enters, and pause/clear/reset when everyone leaves.
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
    -- Log that collision events have been bound.
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
    -- Log the player count after entry.

    if count == 1 and not self.bSpawnerStarted then
        -- Start spawning 4 seconds after the first player enters.
        self.bSpawnerStarted = true
        local this = self
        UGCGameSystem.SetTimer(this, function()
            if this:GetPlayerCount() > 0 then
                -- Start spawning after the delay if players are still inside.
                this:StartAllSpawners()
            else
                -- Cancel spawning if everyone has already left.
                this.bSpawnerStarted = false
            end
        end, 4.0, false)
    end
end

function TriggerBox_jiange:StartAllSpawners()
    if not self.SpawnerManagers then
        -- Error: SpawnerManagers is nil.
        return
    end

    local count = self.SpawnerManagers:Num()
    -- Log the number of spawner managers to start.
    for i = 1, count do
        local spawner = self.SpawnerManagers:Get(i)
        -- Log the current spawner reference.
        if spawner then
            -- Set OwnerTriggerBox first so the spawner can call back correctly.
            spawner.OwnerTriggerBox = self

            -- Start the spawner before the debug probes to avoid masking startup issues.
            local startOk, startErr = pcall(function()
                spawner:ResetSpawnerManager(true)
                spawner:StartSpawnerManager()
                spawner:ResumeSpawnerManager()
            end)
            if startOk then
                -- Log that the spawner started successfully.
            else
                -- Log that the spawner failed to start.
            end

            -- Debug output is wrapped in pcall so it does not affect the main flow.
            pcall(function()
                local className = spawner:GetClass() and spawner:GetClass():GetName() or "unknown"
                -- Log the spawner class name.
            end)

            pcall(function()
                if spawner.SpawnPoints then
                    local spCount = spawner.SpawnPoints:Num()
                    -- Log the number of spawn points.
                else
                    -- Log that SpawnPoints is nil.
                end
            end)

            pcall(function()
                if spawner.WaveConfigs then
                    -- Log the number of wave configs.
                else
                    -- Log that WaveConfigs is nil.
                end
            end)

            pcall(function()
                -- Log the spawner properties for debugging.
                for k, v in pairs(spawner) do
                    -- Log key-value pairs for the spawner.
                end
            end)
        end
    end
end

function TriggerBox_jiange:OnEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor or not OtherActor.PlayerState then return end

    self.PlayersInZone[tostring(OtherActor)] = nil
    local count = self:GetPlayerCount()
    -- Log the player count after exit.

    if count == 0 and self.bSpawnerStarted then
        -- Stop spawning and reset the floor when everyone leaves.
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
        -- Reset the floor to the saved highest floor plus one.
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
            -- Log the reset floor value.
        end
        -- Clear spawner initialization flags so they re-read saved data next time.
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

-- Callback from GLQjiange: notify players in the zone to show the settlement UI.
function TriggerBox_jiange:NotifyLevelComplete(levelNum)
    -- Log that the current floor is complete.

    local playerCount = 0
    for actorKey, pawn in pairs(self.PlayersInZone or {}) do
        playerCount = playerCount + 1
        if pawn then
            local PC = UGCGameSystem.GetPlayerControllerByPlayerPawn(pawn)
            if PC then
                PC.CurrentTriggerBox = self
                -- Send the settlement UI RPC to this player.
                UnrealNetwork.CallUnrealRPC(PC, PC, "Client_ShowTaSettlementUI", levelNum)
            end
        end
    end

    -- If the zone is empty, notify all players.
    if playerCount == 0 then
        local allPCs = UGCGameSystem.GetAllPlayerController()
        if allPCs then
            for _, pc in pairs(allPCs) do
                pc.CurrentTriggerBox = self
                UnrealNetwork.CallUnrealRPC(pc, pc, "Client_ShowTaSettlementUI", levelNum)
            end
        end
    end
end

-- Resume spawning after the player confirms the settlement.
function TriggerBox_jiange:ResumeSpawning()
    -- Resume all spawner managers.
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
