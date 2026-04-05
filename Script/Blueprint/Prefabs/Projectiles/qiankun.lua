---@class qiankun_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local qiankun = {}
 
--[[
function qiankun:ReceiveBeginPlay()
    qiankun.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function qiankun:ReceiveTick(DeltaTime)
    qiankun.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function qiankun:ReceiveEndPlay()
    qiankun.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function qiankun:GetReplicatedProperties()
    return
end
--]]

--[[
function qiankun:GetAvailableServerRPCs()
    return
end
--]]

return qiankun