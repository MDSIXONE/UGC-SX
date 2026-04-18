---@class X_fuwuqi_C:PESkillProjectileBase
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem UParticleSystemComponent
---@field Sphere USphereComponent
--Edit Below--
local X_fuwuqi = {}
 
--[[
function X_fuwuqi:ReceiveBeginPlay()
    X_fuwuqi.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function X_fuwuqi:ReceiveTick(DeltaTime)
    X_fuwuqi.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function X_fuwuqi:ReceiveEndPlay()
    X_fuwuqi.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function X_fuwuqi:GetReplicatedProperties()
    return
end
--]]

--[[
function X_fuwuqi:GetAvailableServerRPCs()
    return
end
--]]

return X_fuwuqi