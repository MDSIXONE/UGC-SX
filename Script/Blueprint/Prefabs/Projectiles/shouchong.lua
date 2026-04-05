---@class shouchong_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Sphere USphereComponent
--Edit Below--
local shouchong = {}
 
--[[
function shouchong:ReceiveBeginPlay()
    shouchong.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function shouchong:ReceiveTick(DeltaTime)
    shouchong.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function shouchong:ReceiveEndPlay()
    shouchong.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function shouchong:GetReplicatedProperties()
    return
end
--]]

--[[
function shouchong:GetAvailableServerRPCs()
    return
end
--]]

return shouchong