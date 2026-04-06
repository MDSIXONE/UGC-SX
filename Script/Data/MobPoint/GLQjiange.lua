---@class GLQjiange_C:BP_UGCMobSpawnerManager_C
--Edit Below--
-- Endless Sword Pavilion mob spawner manager for the MOBGLQ mode.
local GLQjiange = {}

-- Shared floor number across all players.
GLQjiange.CurrentFloor = 1

-- Mob table path.
local MobTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/mob.mob')

function GLQjiange:ReceiveBeginPlay()
    GLQjiange.SuperClass.ReceiveBeginPlay(self)
    self:InitData()
    -- Log successful initialization.

    -- Debug output is wrapped in pcall to avoid affecting gameplay.
    pcall(function()
        local className = self:GetClass() and self:GetClass():GetName() or "unknown"
        -- Log the class name.
    end)

    pcall(function()
        if self.SpawnPoints then
            -- Log the number of spawn points.
        else
            -- Log that SpawnPoints is nil and no spawn points are configured.
        end
    end)

    pcall(function()
        -- Log the object's own properties.
        for k, v in pairs(self) do
            -- Log key-value pairs for debugging.
        end
    end)
end

function GLQjiange:InitData()
    if self.bDataInited then return end
    self.bDataInited = true

    -- Read the saved highest floor and start from the next floor.
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
    -- Log the starting floor after initialization.
end

-- Get the mob configuration for the given floor.
function GLQjiange:GetMobConfig(floor)
    local config = UGCGameSystem.GetTableDataByRowName(MobTablePath, tostring(floor))
    if config then
        -- Log the loaded floor configuration.
    else
        -- Log that no configuration was found and defaults will be used.
    end
    return config
end

-- Handle the mob spawn event.
function GLQjiange:OnMobSpawn(Mob)
    self:InitData()
    self.MobSpawnedThisWave = true
    -- Log the spawned mob.

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
        -- Set the mob attack value.

        if UGCGameSystem.IsServer(self) then
            self.MobSpawnTimerIndex = (self.MobSpawnTimerIndex or 0) + 1
            local timerName = "GLQjiange_SetHP_" .. tostring(self.MobSpawnTimerIndex)
            local mobRef = Mob
            UGCTimerUtility.CreateLuaTimer(0.2, function()
                -- Delay the attribute update slightly to ensure the mob exists.
                local ok, err = pcall(function()
                    UGCAttributeSystem.SetGameAttributeValue(mobRef, 'HealthMax', hp)
                    UGCAttributeSystem.SetGameAttributeValue(mobRef, 'Health', hp)
                end)
                if ok then
                    -- Log that the HP update succeeded.
                else
                    -- Log that the HP update failed.
                end
            end, false, timerName)
        end
    end
end

-- Handle the all-mobs-dead event.
function GLQjiange:OnAllMobDie()
    self:InitData()

    -- Skip this callback if no mob was spawned in the current wave.
    if not self.MobSpawnedThisWave then
        return
    end

    -- Log that the current floor has been cleared.
    self.MobSpawnedThisWave = false
    self.IsPausedForSettlement = true

    -- Save the highest floor to player storage.
    self:SaveFloorRecord(GLQjiange.CurrentFloor)

    -- Notify the trigger box to open the settlement UI.
    if self.OwnerTriggerBox and self.OwnerTriggerBox.NotifyLevelComplete then
        self.OwnerTriggerBox:NotifyLevelComplete(GLQjiange.CurrentFloor)
    else
        -- If the trigger box is missing, continue to the next floor automatically.
        self:ResumeAfterSettlement()
    end
end

-- Resume spawning after the player confirms the settlement.
function GLQjiange:ResumeAfterSettlement()
    GLQjiange.CurrentFloor = GLQjiange.CurrentFloor + 1
    -- Log the next floor after settlement.
    self.IsPausedForSettlement = false

    -- Notify clients to refresh the displayed floor.
    self:NotifyFloorUpdate()

    self:ResetSpawnerManager(true)
    local this = self
    UGCGameSystem.SetTimer(this, function()
        this:StartSpawnerManager()
        this:ResumeSpawnerManager()
        -- Log that spawning has resumed on the next floor.
    end, 0.5, false)
end

-- Save the highest floor to every player's storage.
function GLQjiange:SaveFloorRecord(floor)
    local allPCs = UGCGameSystem.GetAllPlayerController()
    if not allPCs then return end
    for _, pc in pairs(allPCs) do
        local playerState = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if playerState and playerState.GameData then
            local oldFloor = playerState.GameData.PlayerJiangeFloor or 0
            if floor > oldFloor then
                playerState.GameData.PlayerJiangeFloor = floor
                if playerState.DataSave then
                    playerState:DataSave()
                end
                -- Update the dungeon floor ranking.
                if playerState.UpdateJiangeFloorRank then
                    playerState:UpdateJiangeFloorRank()
                end
            end
        end
        -- Notify the client to refresh the floor display.
        UnrealNetwork.CallUnrealRPC(pc, pc, "Client_UpdateJiangeFloor", floor)
    end
end

-- Notify clients to refresh the floor display through RPC.
-- JiangeFloor stores the highest cleared floor, and the client shows +1 as the next floor to challenge.
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
