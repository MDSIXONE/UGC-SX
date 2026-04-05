---@class SS1_C:BP_MagicFieldActorBase_C
---@field Play_UGC_PasssiveSkill_SoulBurn UAkComponent
---@field Box UBoxComponent
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local SS1 = {}
 
--[[
function SS1:ReceiveBeginPlay()
    SS1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SS1:ReceiveTick(DeltaTime)
    SS1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SS1:ReceiveEndPlay()
    SS1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SS1:GetReplicatedProperties()
    return
end
--]]

--[[
function SS1:GetAvailableServerRPCs()
    return
end
--]]

return SS1