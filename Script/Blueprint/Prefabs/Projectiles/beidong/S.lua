---@class S_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local S = {}
 
--[[
function S:ReceiveBeginPlay()
    S.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function S:ReceiveTick(DeltaTime)
    S.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function S:ReceiveEndPlay()
    S.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function S:GetReplicatedProperties()
    return
end
--]]

--[[
function S:GetAvailableServerRPCs()
    return
end
--]]

return S