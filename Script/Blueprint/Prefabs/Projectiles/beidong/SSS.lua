---@class SSS_C:PESkillProjectileBase
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local SSS = {}
 
--[[
function SSS:ReceiveBeginPlay()
    SSS.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS:ReceiveTick(DeltaTime)
    SSS.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS:ReceiveEndPlay()
    SSS.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS:GetAvailableServerRPCs()
    return
end
--]]

return SSS