---@class SSS2_C:BP_UGC_Rifle_AKM_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem2 UParticleSystemComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local SSS2 = {}
 
--[[
function SSS2:ReceiveBeginPlay()
    SSS2.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS2:ReceiveTick(DeltaTime)
    SSS2.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS2:ReceiveEndPlay()
    SSS2.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS2:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS2:GetAvailableServerRPCs()
    return
end
--]]

return SSS2