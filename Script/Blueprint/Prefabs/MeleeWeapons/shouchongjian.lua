---@class shouchongjian_C:BP_UGC_MeleeWeap_TangDao_C
--Edit Below--
local shouchongjian = {}
 
--[[
function shouchongjian:ReceiveBeginPlay()
    shouchongjian.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function shouchongjian:ReceiveTick(DeltaTime)
    shouchongjian.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function shouchongjian:ReceiveEndPlay()
    shouchongjian.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function shouchongjian:GetReplicatedProperties()
    return
end
--]]

--[[
function shouchongjian:GetAvailableServerRPCs()
    return
end
--]]

return shouchongjian