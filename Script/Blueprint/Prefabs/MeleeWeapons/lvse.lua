---@class lvse_C:BP_UGC_MeleeWeap_Pan_C
---@field lvse_FZ UStaticMeshComponent
--Edit Below--
local lvse = {}
 
--[[
function lvse:ReceiveBeginPlay()
    lvse.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function lvse:ReceiveTick(DeltaTime)
    lvse.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function lvse:ReceiveEndPlay()
    lvse.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function lvse:GetReplicatedProperties()
    return
end
--]]

--[[
function lvse:GetAvailableServerRPCs()
    return
end
--]]

return lvse