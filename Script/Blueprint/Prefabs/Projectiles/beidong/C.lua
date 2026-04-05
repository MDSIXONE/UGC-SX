---@class C_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local C = {}
 
--[[
function C:ReceiveBeginPlay()
    C.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function C:ReceiveTick(DeltaTime)
    C.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function C:ReceiveEndPlay()
    C.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function C:GetReplicatedProperties()
    return
end
--]]

--[[
function C:GetAvailableServerRPCs()
    return
end
--]]

return C