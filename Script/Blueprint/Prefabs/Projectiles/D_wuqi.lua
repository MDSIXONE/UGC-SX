---@class D_wuqi_C:PESkillProjectileBase
---@field StaticMesh UStaticMeshComponent
---@field Sphere USphereComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local D_wuqi = {}
 
--[[
function D_wuqi:ReceiveBeginPlay()
    D_wuqi.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function D_wuqi:ReceiveTick(DeltaTime)
    D_wuqi.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function D_wuqi:ReceiveEndPlay()
    D_wuqi.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function D_wuqi:GetReplicatedProperties()
    return
end
--]]

--[[
function D_wuqi:GetAvailableServerRPCs()
    return
end
--]]

return D_wuqi