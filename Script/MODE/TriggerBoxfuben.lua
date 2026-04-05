---@class TriggerBoxfuben_C:TriggerBox
--Edit Below--
local TriggerBoxfuben = {}

function TriggerBoxfuben:ReceiveBeginPlay()
    TriggerBoxfuben.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit()
end

function TriggerBoxfuben:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true

    -- ugcprint("[TriggerBoxfuben] LuaInit called")

    -- Bind begin/end overlap collision events
    self.CollisionComponent.OnComponentBeginOverlap:Add(self.CollisionComponent_OnComponentBeginOverlap, self)
    self.CollisionComponent.OnComponentEndOverlap:Add(self.CollisionComponent_OnComponentEndOverlap, self)

    -- ugcprint("[TriggerBoxfuben] Collision events bound")
end

--- Player enters trigger box
function TriggerBoxfuben:CollisionComponent_OnComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not OtherActor then
        return
    end
    
    -- Check if it's a player
    local isPlayer = OtherActor.PlayerState ~= nil
    if not isPlayer then
        return
    end

    -- ugcprint("[TriggerBoxfuben] Player entered trigger box")
    
    -- Get player controller
    local playerController = OtherActor:GetPlayerControllerSafety()
    if playerController then
        -- ugcprint("[TriggerBoxfuben] Got player controller, preparing to show mode select UI")
        
        -- Check if on client
        if not UGCGameSystem.IsServer() then
            -- ugcprint("[TriggerBoxfuben] On client, open mode select UI")
            UGCMultiMode.SetModeChooseUIVisible(true)
        else
            -- ugcprint("[TriggerBoxfuben] On server, skip UI display")
        end
    else
        -- ugcprint("[TriggerBoxfuben] Unable to get player controller")
    end
end

--- Player leaves trigger box
function TriggerBoxfuben:CollisionComponent_OnComponentEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor then
        return
    end

    -- Check if it's a player
    local isPlayer = OtherActor.PlayerState ~= nil
    if not isPlayer then
        return
    end

    -- ugcprint("[TriggerBoxfuben] Player left trigger box")
    
    -- Get player controller
    local playerController = OtherActor:GetPlayerControllerSafety()
    if playerController then
        -- ugcprint("[TriggerBoxfuben] Got player controller, preparing to close mode select UI")
        
        -- Check if on client
        if not UGCGameSystem.IsServer() then
            -- ugcprint("[TriggerBoxfuben] On client, close mode select UI")
            UGCMultiMode.SetModeChooseUIVisible(false)
        else
            -- ugcprint("[TriggerBoxfuben] On server, skip UI close")
            end
    else
        -- ugcprint("[TriggerBoxfuben] Unable to get player controller")
    end
end

return TriggerBoxfuben
