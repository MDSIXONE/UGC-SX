---@class shuihanjian_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Capsule UCapsuleComponent
---@field SkeletalMesh USkeletalMeshComponent
--Edit Below--
local shuihanjian = {}
 
--[[
function shuihanjian:ReceiveBeginPlay()
    shuihanjian.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function shuihanjian:ReceiveTick(DeltaTime)
    shuihanjian.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function shuihanjian:ReceiveEndPlay()
    shuihanjian.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function shuihanjian:GetReplicatedProperties()
    return
end
--]]

--[[
function shuihanjian:GetAvailableServerRPCs()
    return
end
--]]

return shuihanjian