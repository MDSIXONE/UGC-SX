---@class ST_6_C:BP_UGC_Pistol_MedicalGun_C
---@field ParticleSystem4 UParticleSystemComponent
---@field ParticleSystem3 UParticleSystemComponent
---@field ParticleSystem2 UParticleSystemComponent
---@field ParticleSystem1 UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
---@field ST_5 UStaticMeshComponent
--Edit Below--
local ST_1 = {}
 
--[[
function ST_1:ReceiveBeginPlay()
    ST_1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function ST_1:ReceiveTick(DeltaTime)
    ST_1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function ST_1:ReceiveEndPlay()
    ST_1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function ST_1:GetReplicatedProperties()
    return
end
--]]

--[[
function ST_1:GetAvailableServerRPCs()
    return
end
--]]

return ST_1