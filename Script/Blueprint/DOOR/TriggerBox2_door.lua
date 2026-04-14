---@class TriggerBox2_door_C:TriggerBox
---@field team int32
--Edit Below--
local TriggerBox2_door = {}

local DOOR_REGISTRY_KEY = "__TriggerBox2DoorRegistry"
local TELEPORT_LOCK_KEY = "__TriggerBox2DoorTeleportLock"
local TELEPORT_LOCK_DURATION = 1.0
local TELEPORT_Z_OFFSET = 100

local function GetDoorRegistry()
    if not _G[DOOR_REGISTRY_KEY] then
        _G[DOOR_REGISTRY_KEY] = {}
    end
    return _G[DOOR_REGISTRY_KEY]
end

local function GetTeleportLockMap()
    if not _G[TELEPORT_LOCK_KEY] then
        _G[TELEPORT_LOCK_KEY] = {}
    end
    return _G[TELEPORT_LOCK_KEY]
end

local function GetNowTime()
    if os and os.clock then
        return os.clock()
    end
    return os.time()
end

local function IsObjectValidSafe(obj)
    return obj and UGCObjectUtility and UGCObjectUtility.IsObjectValid and UGCObjectUtility.IsObjectValid(obj)
end

local function IsPlayerActor(actor)
    return actor and actor.PlayerState ~= nil
end

local function IsActorTeleportLocked(actor)
    local lockMap = GetTeleportLockMap()
    local actorKey = tostring(actor)
    local now = GetNowTime()
    local unlockTime = lockMap[actorKey]
    if unlockTime and unlockTime > now then
        return true
    end
    if unlockTime and unlockTime <= now then
        lockMap[actorKey] = nil
    end
    return false
end

local function LockActorTeleport(actor)
    local lockMap = GetTeleportLockMap()
    lockMap[tostring(actor)] = GetNowTime() + TELEPORT_LOCK_DURATION
end

function TriggerBox2_door:ReceiveBeginPlay()
    TriggerBox2_door.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit()
    self:RegisterDoor()
end

function TriggerBox2_door:ReceiveEndPlay()
    self:UnregisterDoor()
    TriggerBox2_door.SuperClass.ReceiveEndPlay(self)
end

function TriggerBox2_door:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true

    if self.CollisionComponent then
        self.CollisionComponent.OnComponentBeginOverlap:Add(self.CollisionComponent_OnComponentBeginOverlap, self)
    end
end

function TriggerBox2_door:RegisterDoor()
    local teamID = math.floor(tonumber(self.team) or 0)
    if teamID <= 0 then
        return
    end

    local registry = GetDoorRegistry()
    registry[teamID] = registry[teamID] or {}
    registry[teamID][tostring(self)] = self
end

function TriggerBox2_door:UnregisterDoor()
    local teamID = math.floor(tonumber(self.team) or 0)
    if teamID <= 0 then
        return
    end

    local registry = _G[DOOR_REGISTRY_KEY]
    if not registry or not registry[teamID] then
        return
    end

    registry[teamID][tostring(self)] = nil
end

function TriggerBox2_door:FindTargetDoor()
    local teamID = math.floor(tonumber(self.team) or 0)
    if teamID <= 0 then
        return nil
    end

    local registry = GetDoorRegistry()
    local doorMap = registry[teamID]
    if not doorMap then
        return nil
    end

    local selfLocation = self:K2_GetActorLocation()
    local targetDoor = nil
    local bestDistSq = nil

    for key, door in pairs(doorMap) do
        if door == self then
            goto continue_door
        end

        if not IsObjectValidSafe(door) then
            doorMap[key] = nil
            goto continue_door
        end

        local targetLocation = door:K2_GetActorLocation()
        if not targetLocation then
            goto continue_door
        end

        local dx = selfLocation.X - targetLocation.X
        local dy = selfLocation.Y - targetLocation.Y
        local dz = selfLocation.Z - targetLocation.Z
        local distSq = dx * dx + dy * dy + dz * dz

        if not bestDistSq or distSq < bestDistSq then
            bestDistSq = distSq
            targetDoor = door
        end

        ::continue_door::
    end

    return targetDoor
end

function TriggerBox2_door:CollisionComponent_OnComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not self:HasAuthority() then
        return
    end

    if not IsPlayerActor(OtherActor) then
        return
    end

    if IsActorTeleportLocked(OtherActor) then
        return
    end

    local targetDoor = self:FindTargetDoor()
    if not targetDoor then
        return
    end

    local targetLocation = targetDoor:K2_GetActorLocation()
    if not targetLocation then
        return
    end

    targetLocation.Z = targetLocation.Z + TELEPORT_Z_OFFSET

    LockActorTeleport(OtherActor)

    local okTeleport, teleportErr = pcall(function()
        OtherActor:K2_SetActorLocation(targetLocation, false, nil, true)
    end)

    if not okTeleport then
        ugcprint("[TriggerBox2_door] 传送失败: " .. tostring(teleportErr))
        return
    end

    ugcprint("[TriggerBox2_door] 传送成功, team=" .. tostring(self.team))
end

return TriggerBox2_door