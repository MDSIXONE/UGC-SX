---@class UGCGameMode_C:BP_UGCGameBase_C
--Edit Below--
local UGCGameMode = {}

-- Import required modules
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

-- Mode 1002 global kill count
local Mode1002_TotalKillCount = 0
local MODE1002_REQUIRED_KILLS = 10

function UGCGameMode:ReceiveBeginPlay()
    UGCGameMode.SuperClass.ReceiveBeginPlay(self)
    
    -- Initialize mode
    if self:HasAuthority() then
        -- ugcprint("[UGCGameMode] ========== GameMode initialization started ==========")
        
        -- Get current mode ID
        local ModeID = UGCMultiMode.GetModeID()
        -- ugcprint("[UGCGameMode] Current ModeID: " .. tostring(ModeID))
        
        -- Initialize level flow for dungeon mode (1002)
        if ModeID == 1002 then
            -- ugcprint("[UGCGameMode] Detected dungeon mode 1002, initializing level flow")
            Mode1002_TotalKillCount = 0
            self:InitLevelFlow(ModeID)
        else
            -- ugcprint("[UGCGameMode] Mode " .. tostring(ModeID) .. ", skip level flow init")
        end
        
        self:InitMode()
        -- ugcprint("[UGCGameMode] ========== GameMode initialization completed ==========")
    end
end

--- Initialize level flow
---@param ModeID number Mode ID
function UGCGameMode:InitLevelFlow(ModeID)
    -- ugcprint("[UGCGameMode] Start initializing level flow, ModeID: " .. tostring(ModeID))
    
    -- Get level flow manager path from data table
    local MgrPath = UGCGameData.GetGameModeActorMgrConfig(ModeID)
    
    if MgrPath and MgrPath ~= "" then
        local fullPath = UGCGameSystem.GetUGCResourcesFullPath(MgrPath)
        -- ugcprint("[UGCGameMode] Level flow manager path: " .. tostring(fullPath))
        UGCLevelFlowSystem.EnableLevelFlow(fullPath)
        -- ugcprint("[UGCGameMode] Level flow initialization completed")
    else
        -- ugcprint("[UGCGameMode] Warning: Mode " .. tostring(ModeID) .. " has no level flow manager configured")
    end
end

function UGCGameMode:InitMode()
    -- Register monster death event listener
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.MobPawn.PostBeKilled, self, self.OnPostBeKilledDS)
    
    -- Register player leave event listener
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerLeave, self, self.OnPlayerLeave)
    
    -- Register player defeated event listener
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerPawn.PawnDefeat, self, self.OnPlayerDefeat)
    
    -- Register player respawn event listener
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerPawn.PawnRespawn, self, self.OnPlayerRespawn)
    
    -- ugcprint("[UGCGameMode] Event listeners registered")
end

-- Auto-respawn player when defeated
function UGCGameMode:OnPlayerDefeat(VictimPlayerKey, InstigatorPlayerKey, DamageType)
    --ugcprint("[UGCGameMode] ========== Player defeated event triggered ==========")
    --ugcprint("[UGCGameMode] Defeated PlayerKey: " .. tostring(VictimPlayerKey))
    
    if not VictimPlayerKey then
        --ugcprint("[UGCGameMode] Error: VictimPlayerKey is invalid")
        return
    end
    
    --ugcprint("[UGCGameMode] Respawning player in 3 seconds...")
    UGCPlayerPawnSystem.RespawnPlayer(VictimPlayerKey, 2.0, true, 0.01)
    --ugcprint("[UGCGameMode] RespawnPlayer called")
end

-- Restore player attributes after respawn
function UGCGameMode:OnPlayerRespawn(PlayerKey)
    --ugcprint("[UGCGameMode] ========== Player respawn event triggered ==========")
    --ugcprint("[UGCGameMode] Respawned PlayerKey: " .. tostring(PlayerKey))
    
    if not PlayerKey then
        --ugcprint("[UGCGameMode] Error: PlayerKey is invalid")
        return
    end
    
    -- Get PlayerState
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerKey(PlayerKey)
    if PlayerState and PlayerState.UpdateClientAttributes then
        --ugcprint("[UGCGameMode] Restoring player attributes...")
        PlayerState:UpdateClientAttributes()
    end
    
    -- Restore full health on respawn
    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(PlayerKey)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local maxHealth = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'HealthMax') or 100
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, 'Health', maxHealth)
        --ugcprint("[UGCGameMode] Respawn full heal: " .. tostring(maxHealth))
    end

    -- Reapply wearing Shenyin/Jiange skills on respawn
    if PlayerState and PlayerState.ReapplyWearingSkills then
        PlayerState:ReapplyWearingSkills()
    end

    -- Restore main UI after respawn (if player is still in Jiange UI)
    local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerKey(PlayerKey)
    if PlayerController then
        UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_RestoreMainUIAfterRespawn")
    end
end

-- Save player data when leaving
function UGCGameMode:OnPlayerLeave(PlayerController)
    --ugcprint("[UGCGameMode] ========== Player leave event triggered ==========")
    
    if not PlayerController or not UGCObjectUtility.IsObjectValid(PlayerController) then
        --ugcprint("[UGCGameMode] Error: PlayerController is invalid")
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
    if PlayerState and PlayerState.DataSave then
        --ugcprint("[UGCGameMode] Saving player data...")
        PlayerState:DataSave()
    end
end

-- Core experience gain logic on monster kill
function UGCGameMode:OnPostBeKilledDS(Victim, CauserController)
    --ugcprint("[UGCGameMode] ========== Monster death event triggered ==========")
    
    if not Victim or not UGCObjectUtility.IsObjectValid(Victim) then
        --ugcprint("[UGCGameMode] Error: Victim is invalid")
        return
    end
    
    if not CauserController or not UGCObjectUtility.IsObjectValid(CauserController) then
        --ugcprint("[UGCGameMode] Error: CauserController is invalid")
        return
    end
    
    if not CauserController:IsPlayerController() then
        --ugcprint("[UGCGameMode] Killer is not a player, skip")
        return
    end
    
    -- Get monster info from config table
    local MonsterDetailCfg = UGCGameData.GetMonsterConfig(Victim.MonsterID)
    if not MonsterDetailCfg then
        --ugcprint("[UGCGameMode] Warning: Monster config not found, MonsterID=" .. tostring(Victim.MonsterID))
        return
    end
    
    -- Check player's direct exp toggle state
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(CauserController)
    if PlayerState then
        local directExpEnabled = PlayerState.GameData and PlayerState.GameData.DirectExpEnabled
        if directExpEnabled == nil then
            directExpEnabled = true  -- Default enabled
        end
        
        if directExpEnabled then
            --ugcprint("[UGCGameMode] Direct exp mode enabled, auto grant exp on monster kill")
        else
            --ugcprint("[UGCGameMode] Direct exp mode disabled, need absorb to get exp")
        end
        
        -- Increment kill count (for task system)
        if PlayerState.AddKillCount then
            PlayerState:AddKillCount()
            --ugcprint("[UGCGameMode] Kill count incremented")

            local killerPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(CauserController)
            local currentKillCount = 0
            if PlayerState.GetKillCount then
                currentKillCount = tonumber(PlayerState:GetKillCount()) or 0
            else
                currentKillCount = tonumber(PlayerState.KillCount) or 0
            end

            if killerPlayerKey and killerPlayerKey > 0 then
                local allPCs = UGCGameSystem.GetAllPlayerController()
                if allPCs then
                    for _, pc in ipairs(allPCs) do
                        if pc and UGCObjectUtility.IsObjectValid(pc) then
                            UnrealNetwork.CallUnrealRPC(pc, pc, "Client_SyncPlayerKillCount", killerPlayerKey, currentKillCount)
                        end
                    end
                end
            end
        end

        -- Mode 1002: only count GW2_2 kills (MonsterID 322) for progress display
        local modeID = UGCMultiMode.GetModeID()
        if modeID and modeID == 1002 and tonumber(Victim.MonsterID) == 322 then
            Mode1002_TotalKillCount = Mode1002_TotalKillCount + 1
            -- ugcprint("[UGCGameMode] 1002 global kills: " .. tostring(Mode1002_TotalKillCount) .. "/" .. tostring(MODE1002_REQUIRED_KILLS))
            -- Sync to all clients
            local allPCs = UGCGameSystem.GetAllPlayerController()
            if allPCs then
                for _, pc in ipairs(allPCs) do
                    if pc and UGCObjectUtility.IsObjectValid(pc) then
                        UnrealNetwork.CallUnrealRPC(pc, pc, "Client_SyncMobKillCount", Mode1002_TotalKillCount, MODE1002_REQUIRED_KILLS)
                    end
                end
            end
        end
    end
end

return UGCGameMode
