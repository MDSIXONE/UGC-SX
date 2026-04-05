---@class SS_C:BP_UGC_Rifle_M416_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem UParticleSystemComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field hongse UParticleSystemComponent
--Edit Below--
local SS = {}
 
--[[
function SS:ReceiveBeginPlay()
    SS.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SS:ReceiveTick(DeltaTime)
    SS.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SS:ReceiveEndPlay()
    SS.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SS:GetReplicatedProperties()
    return
end
--]]

--[[
function SS:GetAvailableServerRPCs()
    return
end
--]]

return SS