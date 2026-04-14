---@class SSS_fuwuqi2_C:BP_UGC_DragonBoySpear_C
--Edit Below--
local SSS_fuwuqi2 = {}
 
--[[
function SSS_fuwuqi2:ReceiveBeginPlay()
    SSS_fuwuqi2.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS_fuwuqi2:ReceiveTick(DeltaTime)
    SSS_fuwuqi2.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS_fuwuqi2:ReceiveEndPlay()
    SSS_fuwuqi2.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS_fuwuqi2:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS_fuwuqi2:GetAvailableServerRPCs()
    return
end
--]]

return SSS_fuwuqi2