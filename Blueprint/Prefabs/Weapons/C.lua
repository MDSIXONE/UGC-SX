---@class C_C:BP_UGC_Rifle_VAL_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local C = {}
 
--[[
function C:ReceiveBeginPlay()
    C.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function C:ReceiveTick(DeltaTime)
    C.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function C:ReceiveEndPlay()
    C.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function C:GetReplicatedProperties()
    return
end
--]]

--[[
function C:GetAvailableServerRPCs()
    return
end
--]]

return C