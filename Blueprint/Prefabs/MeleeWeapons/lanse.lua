---@class lanse_C:BP_UGC_MeleeWeap_Pan_C
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local lanse = {}
 
--[[
function lanse:ReceiveBeginPlay()
    lanse.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function lanse:ReceiveTick(DeltaTime)
    lanse.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function lanse:ReceiveEndPlay()
    lanse.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function lanse:GetReplicatedProperties()
    return
end
--]]

--[[
function lanse:GetAvailableServerRPCs()
    return
end
--]]

return lanse