---@class SingleModeMgr_C:UGCLevelActorMgr
--Edit Below--
local SingleModeMgr = {}

function SingleModeMgr:ReceiveBeginPlay()
    SingleModeMgr.SuperClass.ReceiveBeginPlay(self)

    -- Total dungeon duration (seconds), editor TimeOut is set to 9999, controlled by code
    local FUBEN_TOTAL_TIME = 100

    -- Set all player teams' camp ID to 1
    local AllPCs = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    if AllPCs then
        for _, PC in pairs(AllPCs) do
            local Pawn = PC:K2_GetPawn()
            if Pawn then
                local TeamID = UGCPawnAttrSystem.GetTeamID(Pawn)
                if TeamID and TeamID >= 0 then
                    local success = UGCCampSystem.SetCampForTeam(TeamID, 1)
                    -- ugcprint("[SingleModeMgr] Team " .. tostring(TeamID) .. " camp set to 1, result=" .. tostring(success))
                end
            end
        end
    end

    -- Timeout is triggered by client countdown reaching 0, no longer controlled by server timer

    -- Delay 3 seconds to print player and p1 camp info (wait for p1 to spawn)
    UGCTimerUtility.CreateLuaTimer(3.0, function()
        -- ugcprint("[SingleModeMgr] ========== Camp Debug Info ==========")
        local PCs = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
        if PCs then
            for _, PC in pairs(PCs) do
                local Pawn = PC:K2_GetPawn()
                if Pawn then
                    local TeamID = UGCPawnAttrSystem.GetTeamID(Pawn)
                    local CampID = UGCCampSystem.GetCampIDByTeamID(TeamID)
                    -- ugcprint("[SingleModeMgr] Player TeamID=" .. tostring(TeamID) .. ", CampID=" .. tostring(CampID))

                    -- Find p1 and print camp relationship
                    local allActors = UGCGameSystem.GetAllActorsOfClass("Script.Blueprint.Prefabs.Monsters.patner.p1")
                    if allActors and #allActors > 0 then
                        for _, p1Actor in pairs(allActors) do
                            local p1CampID = UGCCampSystem.GetCampIDByActor(p1Actor)
                            local relation = UGCCampSystem.GetCampRelationWithActor(Pawn, p1Actor)
                            -- ugcprint("[SingleModeMgr] p1 CampID=" .. tostring(p1CampID) .. ", relation with player=" .. tostring(relation) .. " (0=Friendly/1=Neutral/2=Enemy)")
                        end
                    else
                        -- ugcprint("[SingleModeMgr] p1 Actor not found")
                    end
                end
            end
        end
        -- ugcprint("[SingleModeMgr] =====================================")
    end, false, "CampDebug_Timer")
end

--[[
function SingleModeMgr:ReceiveTick(DeltaTime)
    SingleModeMgr.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SingleModeMgr:ReceiveEndPlay()
    SingleModeMgr.SuperClass.ReceiveEndPlay(self) 
end
--]]

return SingleModeMgr
