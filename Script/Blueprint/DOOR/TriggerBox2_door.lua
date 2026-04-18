---@class TriggerBox2_door_C:TriggerBox
---@field team int32
--Edit Below--
local TriggerBox2_door = {}

local DOOR_REGISTRY_KEY = "__TriggerBox2DoorRegistry"
local TELEPORT_LOCK_KEY = "__TriggerBox2DoorTeleportLock"
local TELEPORT_LOCK_DURATION = 1.0
local TELEPORT_Z_OFFSET = 100
local DEBUG_LOG_ENABLED = true

local function DebugLog(msg)
    if not DEBUG_LOG_ENABLED then
        return
    end
    ugcprint("[TriggerBox2_door] " .. tostring(msg))
end

local function GetTableCount(map)
    local count = 0
    for _ in pairs(map or {}) do
        count = count + 1
    end
    return count
end

local function FormatVector(vec)
    if not vec then
        return "nil"
    end
    return "(" .. tostring(vec.X) .. ", " .. tostring(vec.Y) .. ", " .. tostring(vec.Z) .. ")"
end

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
        return true, unlockTime - now
    end
    if unlockTime and unlockTime <= now then
        lockMap[actorKey] = nil
    end
    return false, 0
end

local function LockActorTeleport(actor)
    local lockMap = GetTeleportLockMap()
    local unlockTime = GetNowTime() + TELEPORT_LOCK_DURATION
    lockMap[tostring(actor)] = unlockTime
    return unlockTime
end

function TriggerBox2_door:ReceiveBeginPlay()
    TriggerBox2_door.SuperClass.ReceiveBeginPlay(self)
    DebugLog("BeginPlay, door=" .. tostring(self) .. ", team=" .. tostring(self.team) .. ", authority=" .. tostring(self:HasAuthority()))
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
        DebugLog("LuaInit bind overlap, door=" .. tostring(self))
    else
        DebugLog("LuaInit missing CollisionComponent, door=" .. tostring(self))
    end
end

function TriggerBox2_door:RegisterDoor()
    local teamID = math.floor(tonumber(self.team) or 0)
    if teamID <= 0 then
        DebugLog("RegisterDoor skip invalid team, team=" .. tostring(self.team) .. ", door=" .. tostring(self))
        return
    end

    local registry = GetDoorRegistry()
    registry[teamID] = registry[teamID] or {}
    registry[teamID][tostring(self)] = self
    DebugLog("RegisterDoor ok, team=" .. tostring(teamID) .. ", count=" .. tostring(GetTableCount(registry[teamID])) .. ", door=" .. tostring(self))
end

function TriggerBox2_door:UnregisterDoor()
    local teamID = math.floor(tonumber(self.team) or 0)
    if teamID <= 0 then
        DebugLog("UnregisterDoor skip invalid team, team=" .. tostring(self.team) .. ", door=" .. tostring(self))
        return
    end

    local registry = _G[DOOR_REGISTRY_KEY]
    if not registry or not registry[teamID] then
        DebugLog("UnregisterDoor skip no registry team=" .. tostring(teamID) .. ", door=" .. tostring(self))
        return
    end

    registry[teamID][tostring(self)] = nil
    DebugLog("UnregisterDoor ok, team=" .. tostring(teamID) .. ", count=" .. tostring(GetTableCount(registry[teamID])) .. ", door=" .. tostring(self))
end

function TriggerBox2_door:FindTargetDoor()
    local teamID = math.floor(tonumber(self.team) or 0)
    if teamID <= 0 then
        DebugLog("FindTargetDoor fail invalid team, team=" .. tostring(self.team) .. ", door=" .. tostring(self))
        return nil
    end

    local registry = GetDoorRegistry()
    local doorMap = registry[teamID]
    if not doorMap then
        DebugLog("FindTargetDoor fail no doorMap, team=" .. tostring(teamID) .. ", door=" .. tostring(self))
        return nil
    end

    local selfLocation = self:K2_GetActorLocation()
    if not selfLocation then
        DebugLog("FindTargetDoor fail selfLocation=nil, team=" .. tostring(teamID) .. ", door=" .. tostring(self))
        return nil
    end

    local targetDoor = nil
    local bestDistSq = nil

    for key, door in pairs(doorMap) do
        if door == self then
            goto continue_door
        end

        if not IsObjectValidSafe(door) then
            doorMap[key] = nil
            DebugLog("FindTargetDoor remove invalid door, team=" .. tostring(teamID) .. ", key=" .. tostring(key))
            goto continue_door
        end

        local targetLocation = door:K2_GetActorLocation()
        if not targetLocation then
            DebugLog("FindTargetDoor skip door with nil location, team=" .. tostring(teamID) .. ", door=" .. tostring(door))
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

    if targetDoor then
        DebugLog("FindTargetDoor success, team=" .. tostring(teamID) .. ", target=" .. tostring(targetDoor) .. ", distSq=" .. tostring(bestDistSq))
    else
        DebugLog("FindTargetDoor fail no target, team=" .. tostring(teamID) .. ", registered=" .. tostring(GetTableCount(doorMap)))
    end

    return targetDoor
end

function TriggerBox2_door:CollisionComponent_OnComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not self:HasAuthority() then
        if IsPlayerActor(OtherActor) then
            DebugLog("Overlap skip no authority, door=" .. tostring(self) .. ", actor=" .. tostring(OtherActor))
        end
        return
    end

    if not IsPlayerActor(OtherActor) then
        return
    end

    local isLocked, remainSec = IsActorTeleportLocked(OtherActor)
    if isLocked then
        DebugLog("Overlap skip teleport locked, actor=" .. tostring(OtherActor) .. ", remain=" .. tostring(remainSec) .. ", door=" .. tostring(self))
        return
    end

    local targetDoor = self:FindTargetDoor()
    if not targetDoor then
        DebugLog("Overlap skip no target door, team=" .. tostring(self.team) .. ", actor=" .. tostring(OtherActor) .. ", door=" .. tostring(self))
        return
    end

    local sourceLocation = OtherActor:K2_GetActorLocation()
    local targetLocation = targetDoor:K2_GetActorLocation()
    if not targetLocation then
        DebugLog("Overlap skip target location nil, targetDoor=" .. tostring(targetDoor) .. ", actor=" .. tostring(OtherActor))
        return
    end

    targetLocation.Z = targetLocation.Z + TELEPORT_Z_OFFSET

    local unlockTime = LockActorTeleport(OtherActor)
    DebugLog("Teleport start, actor=" .. tostring(OtherActor) .. ", from=" .. FormatVector(sourceLocation) .. ", to=" .. FormatVector(targetLocation) .. ", unlockTime=" .. tostring(unlockTime))

    local didTeleport = nil
    local okTeleport, teleportErr = pcall(function()
        didTeleport = OtherActor:K2_SetActorLocation(targetLocation, false, nil, true)
    end)

    if not okTeleport then
        DebugLog("传送失败异常: " .. tostring(teleportErr))
        return
    end

    if didTeleport == false then
        DebugLog("传送失败返回false, actor=" .. tostring(OtherActor) .. ", target=" .. FormatVector(targetLocation))
        return
    end

    DebugLog("传送成功, team=" .. tostring(self.team) .. ", actor=" .. tostring(OtherActor) .. ", target=" .. FormatVector(targetLocation) .. ", result=" .. tostring(didTeleport))
end

return TriggerBox2_door