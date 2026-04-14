---@class E_chibang_max_C:PESkillProjectileBase
---@field Play_UGC_Skill_ChargedPunch_Throw UAkComponent
---@field ParticleSystem UParticleSystemComponent
---@field Sphere USphereComponent
--Edit Below--
local E_chibang_max = {}
 
--[[
function E_chibang_max:ReceiveBeginPlay()
    E_chibang_max.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function E_chibang_max:ReceiveTick(DeltaTime)
    E_chibang_max.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function E_chibang_max:ReceiveEndPlay()
    E_chibang_max.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function E_chibang_max:GetReplicatedProperties()
    return
end
--]]

--[[
function E_chibang_max:GetAvailableServerRPCs()
    return
end
--]]

return E_chibang_max