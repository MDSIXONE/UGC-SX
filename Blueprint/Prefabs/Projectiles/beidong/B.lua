---@class B_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local B = {}
 
--[[
function B:ReceiveBeginPlay()
    B.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function B:ReceiveTick(DeltaTime)
    B.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function B:ReceiveEndPlay()
    B.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function B:GetReplicatedProperties()
    return
end
--]]

--[[
function B:GetAvailableServerRPCs()
    return
end
--]]

return B