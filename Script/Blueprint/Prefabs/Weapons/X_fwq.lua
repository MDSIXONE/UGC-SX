---@class X_fwq_C:BP_UGC_SkillRifle_LaserGun_C
---@field ParticleSystem3 UParticleSystemComponent
---@field ParticleSystem2 UParticleSystemComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local X_fwq = {}
 
--[[
function X_fwq:ReceiveBeginPlay()
    X_fwq.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function X_fwq:ReceiveTick(DeltaTime)
    X_fwq.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function X_fwq:ReceiveEndPlay()
    X_fwq.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function X_fwq:GetReplicatedProperties()
    return
end
--]]

--[[
function X_fwq:GetAvailableServerRPCs()
    return
end
--]]

return X_fwq