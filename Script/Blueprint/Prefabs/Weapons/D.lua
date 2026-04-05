---@class D_C:BP_UGC_Rifle_HoneyBadger_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local D = {}
 
--[[
function D:ReceiveBeginPlay()
    D.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function D:ReceiveTick(DeltaTime)
    D.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function D:ReceiveEndPlay()
    D.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function D:GetReplicatedProperties()
    return
end
--]]

--[[
function D:GetAvailableServerRPCs()
    return
end
--]]

return D