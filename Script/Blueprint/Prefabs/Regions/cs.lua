local cs = {}
 
--[[
function cs:ReceiveBeginPlay()
    cs.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function cs:ReceiveTick(DeltaTime)
    cs.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function cs:ReceiveEndPlay()
    cs.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function cs:GetReplicatedProperties()
    return
end
--]]

--[[
function cs:GetAvailableServerRPCs()
    return
end
--]]

return cs