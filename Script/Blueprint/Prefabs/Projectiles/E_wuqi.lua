---@class E_wuqi_C:BP_PEProjectile_ChargeRifle_super_C
--Edit Below--
local E_wuqi = {}
 
--[[
function E_wuqi:ReceiveBeginPlay()
    E_wuqi.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function E_wuqi:ReceiveTick(DeltaTime)
    E_wuqi.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function E_wuqi:ReceiveEndPlay()
    E_wuqi.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function E_wuqi:GetReplicatedProperties()
    return
end
--]]

--[[
function E_wuqi:GetAvailableServerRPCs()
    return
end
--]]

return E_wuqi