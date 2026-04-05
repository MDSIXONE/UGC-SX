---@class zise_C:BP_UGC_MeleeWeap_Machete_C
---@field ParticleSystem UParticleSystemComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local zise = {}
 
--[[
function zise:ReceiveBeginPlay()
    zise.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function zise:ReceiveTick(DeltaTime)
    zise.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function zise:ReceiveEndPlay()
    zise.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function zise:GetReplicatedProperties()
    return
end
--]]

--[[
function zise:GetAvailableServerRPCs()
    return
end
--]]

return zise