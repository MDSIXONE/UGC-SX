---@class ST_2_C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Sphere USphereComponent
--Edit Below--
local ST_1 = {}
 
--[[
function ST_1:ReceiveBeginPlay()
    ST_1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function ST_1:ReceiveTick(DeltaTime)
    ST_1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function ST_1:ReceiveEndPlay()
    ST_1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function ST_1:GetReplicatedProperties()
    return
end
--]]

--[[
function ST_1:GetAvailableServerRPCs()
    return
end
--]]

return ST_1