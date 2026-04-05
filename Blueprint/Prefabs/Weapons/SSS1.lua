---@class SSS1_C:BP_UGC_Rifle_AKM_C
--Edit Below--
local SSS1 = {}
 
--[[
function SSS1:ReceiveBeginPlay()
    SSS1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS1:ReceiveTick(DeltaTime)
    SSS1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS1:ReceiveEndPlay()
    SSS1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS1:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS1:GetAvailableServerRPCs()
    return
end
--]]

return SSS1