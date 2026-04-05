---@class A_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local A = {}
 
--[[
function A:ReceiveBeginPlay()
    A.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function A:ReceiveTick(DeltaTime)
    A.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function A:ReceiveEndPlay()
    A.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function A:GetReplicatedProperties()
    return
end
--]]

--[[
function A:GetAvailableServerRPCs()
    return
end
--]]

return A