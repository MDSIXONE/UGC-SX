---@class S1_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local S1 = {}
 
--[[
function S1:ReceiveBeginPlay()
    S1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function S1:ReceiveTick(DeltaTime)
    S1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function S1:ReceiveEndPlay()
    S1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function S1:GetReplicatedProperties()
    return
end
--]]

--[[
function S1:GetAvailableServerRPCs()
    return
end
--]]

return S1