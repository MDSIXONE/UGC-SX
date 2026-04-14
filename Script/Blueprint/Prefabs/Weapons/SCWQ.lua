---@class SCWQ_C:BP_UGC_Rifle_M762_C
---@field Plane UStaticMeshComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local SCWQ = {}
 
--[[
function SCWQ:ReceiveBeginPlay()
    SCWQ.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SCWQ:ReceiveTick(DeltaTime)
    SCWQ.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SCWQ:ReceiveEndPlay()
    SCWQ.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SCWQ:GetReplicatedProperties()
    return
end
--]]

--[[
function SCWQ:GetAvailableServerRPCs()
    return
end
--]]

return SCWQ