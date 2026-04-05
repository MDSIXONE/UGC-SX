---@class bailangjian_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local bifangjian = {}
 
--[[
function bifangjian:ReceiveBeginPlay()
    bifangjian.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function bifangjian:ReceiveTick(DeltaTime)
    bifangjian.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function bifangjian:ReceiveEndPlay()
    bifangjian.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function bifangjian:GetReplicatedProperties()
    return
end
--]]

--[[
function bifangjian:GetAvailableServerRPCs()
    return
end
--]]

return bifangjian