---@class B__C:BP_UGC_Rifle_AKM_C
---@field lanse_ UStaticMeshComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local B_ = {}
 
--[[
function B_:ReceiveBeginPlay()
    B_.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function B_:ReceiveTick(DeltaTime)
    B_.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function B_:ReceiveEndPlay()
    B_.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function B_:GetReplicatedProperties()
    return
end
--]]

--[[
function B_:GetAvailableServerRPCs()
    return
end
--]]

return B_