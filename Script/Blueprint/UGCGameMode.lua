---@class UGCGameMode_C:BP_UGCGameBase_C
local UGCGameMode = {}

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

local Mode1002_TotalKillCount = 0
local MODE1002_REQUIRED_KILLS = 10

function UGCGameMode:ReceiveBeginPlay()
    UGCGameMode.SuperClass.ReceiveBeginPlay(self)

    if self:HasAuthority() then
        local ModeID = UGCMultiMode.GetModeID()

        if ModeID == 1002 then
            Mode1002_TotalKillCount = 0
            self:InitLevelFlow(ModeID)
        end

        self:InitMode()
    end
end

function UGCGameMode:InitLevelFlow(ModeID)
    local MgrPath = UGCGameData.GetGameModeActorMgrConfig(ModeID)

    if MgrPath and MgrPath ~= "" then
        local fullPath = UGCGameSystem.GetUGCResourcesFullPath(MgrPath)
        UGCLevelFlowSystem.EnableLevelFlow(fullPath)
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
end

-- Auto-respawn player when defeated
function UGCGameMode:OnPlayerDefeat(VictimPlayerKey, InstigatorPlayerKey, DamageType)
    
    if not VictimPlayerKey then
        return
    end
    
    UGCPlayerPawnSystem.RespawnPlayer(VictimPlayerKey, 2.0, true, 0.01)
end

-- Restore player attributes after respawn
function UGCGameMode:OnPlayerRespawn(PlayerKey)
    if not PlayerKey then
        return
    end
    
    -- Get PlayerState
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerKey(PlayerKey)
    if PlayerState and PlayerState.UpdateClientAttributes then
        PlayerState:UpdateClientAttributes()
    end
    
    -- Restore full health on respawn
    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(PlayerKey)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local maxHealth = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'HealthMax') or 100
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, 'Health', maxHealth)
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
    if not PlayerController or not UGCObjectUtility.IsObjectValid(PlayerController) then
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
    if PlayerState and PlayerState.DataSave then
        PlayerState:DataSave()
    end
end

-- Core experience gain logic on monster kill
function UGCGameMode:OnPostBeKilledDS(Victim, CauserController)
    if not Victim or not UGCObjectUtility.IsObjectValid(Victim) then
        return
    end
    
    if not CauserController or not UGCObjectUtility.IsObjectValid(CauserController) then
        return
    end
    
    if not CauserController:IsPlayerController() then
        return
    end
    
    -- Get monster info from config table
    local MonsterDetailCfg = UGCGameData.GetMonsterConfig(Victim.MonsterID)
    if not MonsterDetailCfg then
        return
    end
    
    -- Check player's direct exp toggle state
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(CauserController)
    if PlayerState then
        local directExpEnabled = PlayerState.GameData and PlayerState.GameData.DirectExpEnabled
        if directExpEnabled == nil then
            directExpEnabled = true  -- Default enabled
        end
        
        -- Increment kill count (for task system)
        if PlayerState.AddKillCount then
            PlayerState:AddKillCount()

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
