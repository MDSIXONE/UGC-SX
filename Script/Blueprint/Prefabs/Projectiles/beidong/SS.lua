---@class SS_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local SS = {}
 
--[[
function SS:ReceiveBeginPlay()
    SS.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SS:ReceiveTick(DeltaTime)
    SS.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SS:ReceiveEndPlay()
    SS.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SS:GetReplicatedProperties()
    return
end
--]]

--[[
function SS:GetAvailableServerRPCs()
    return
end
--]]

return SS