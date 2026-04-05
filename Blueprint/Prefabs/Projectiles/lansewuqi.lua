---@class lansewuqi_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local lansewuqi = {}
 
--[[
function lansewuqi:ReceiveBeginPlay()
    lansewuqi.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function lansewuqi:ReceiveTick(DeltaTime)
    lansewuqi.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function lansewuqi:ReceiveEndPlay()
    lansewuqi.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function lansewuqi:GetReplicatedProperties()
    return
end
--]]

--[[
function lansewuqi:GetAvailableServerRPCs()
    return
end
--]]

return lansewuqi