---@class chengse1__C:PESkillProjectileBase
---@field ParticleSystem UParticleSystemComponent
---@field Box UBoxComponent
--Edit Below--
local chengse1_ = {}
 
--[[
function chengse1_:ReceiveBeginPlay()
    chengse1_.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function chengse1_:ReceiveTick(DeltaTime)
    chengse1_.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function chengse1_:ReceiveEndPlay()
    chengse1_.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function chengse1_:GetReplicatedProperties()
    return
end
--]]

--[[
function chengse1_:GetAvailableServerRPCs()
    return
end
--]]

return chengse1_