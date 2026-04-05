---@class SSS1_1_C:PESkillProjectileBase
---@field SS UParticleSystemComponent
---@field ParticleSystem UParticleSystemComponent
---@field Ak UAkComponent
---@field ST_Prop_BPKR_MotherBomb_A UStaticMeshComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local SSS1_1 = {}
 
--[[
function SSS1_1:ReceiveBeginPlay()
    SSS1_1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS1_1:ReceiveTick(DeltaTime)
    SSS1_1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS1_1:ReceiveEndPlay()
    SSS1_1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS1_1:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS1_1:GetAvailableServerRPCs()
    return
end
--]]

return SSS1_1