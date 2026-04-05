---@class E_C:BP_UGC_MachineGun_Uzi_C
---@field StaticMesh UStaticMeshComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local E = {}
 
--[[
function E:ReceiveBeginPlay()
    E.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function E:ReceiveTick(DeltaTime)
    E.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function E:ReceiveEndPlay()
    E.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function E:GetReplicatedProperties()
    return
end
--]]

--[[
function E:GetAvailableServerRPCs()
    return
end
--]]

return E