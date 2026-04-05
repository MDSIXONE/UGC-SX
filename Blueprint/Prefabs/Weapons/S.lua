---@class S_C:BP_UGC_Rifle_AKM_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local S = {}
 
--[[
function S:ReceiveBeginPlay()
    S.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function S:ReceiveTick(DeltaTime)
    S.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function S:ReceiveEndPlay()
    S.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function S:GetReplicatedProperties()
    return
end
--]]

--[[
function S:GetAvailableServerRPCs()
    return
end
--]]

return S