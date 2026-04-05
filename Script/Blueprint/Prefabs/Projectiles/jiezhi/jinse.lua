---@class hongse_2_C:PESkillProjectileBase
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
---@field Box UBoxComponent
--Edit Below--
local jinse = {}
 
--[[
function jinse:ReceiveBeginPlay()
    jinse.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function jinse:ReceiveTick(DeltaTime)
    jinse.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function jinse:ReceiveEndPlay()
    jinse.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function jinse:GetReplicatedProperties()
    return
end
--]]

--[[
function jinse:GetAvailableServerRPCs()
    return
end
--]]

return jinse