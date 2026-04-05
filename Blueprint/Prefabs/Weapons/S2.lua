---@class S2_C:BP_UGC_Rifle_M762_C
---@field ParticleSystem1 UParticleSystemComponent
---@field STCustomMesh USTCustomMeshComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local S2 = {}
 
--[[
function S2:ReceiveBeginPlay()
    S2.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function S2:ReceiveTick(DeltaTime)
    S2.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function S2:ReceiveEndPlay()
    S2.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function S2:GetReplicatedProperties()
    return
end
--]]

--[[
function S2:GetAvailableServerRPCs()
    return
end
--]]

return S2