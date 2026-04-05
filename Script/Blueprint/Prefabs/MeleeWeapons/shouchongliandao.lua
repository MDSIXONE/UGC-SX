---@class shouchongliandao_C:BP_UGC_MeleeWeap_TangDao_C
---@field ParticleSystem UParticleSystemComponent
--Edit Below--
local shouchongliandao = {}
 
--[[
function shouchongliandao:ReceiveBeginPlay()
    shouchongliandao.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function shouchongliandao:ReceiveTick(DeltaTime)
    shouchongliandao.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function shouchongliandao:ReceiveEndPlay()
    shouchongliandao.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function shouchongliandao:GetReplicatedProperties()
    return
end
--]]

--[[
function shouchongliandao:GetAvailableServerRPCs()
    return
end
--]]

return shouchongliandao