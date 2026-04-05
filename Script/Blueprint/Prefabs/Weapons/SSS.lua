---@class SSS_C:BP_UGC_Rifle_AUG_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem2 UParticleSystemComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local SSS = {}
 
--[[
function SSS:ReceiveBeginPlay()
    SSS.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS:ReceiveTick(DeltaTime)
    SSS.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS:ReceiveEndPlay()
    SSS.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS:GetAvailableServerRPCs()
    return
end
--]]

return SSS