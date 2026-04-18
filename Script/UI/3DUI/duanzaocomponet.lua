---@class duanzaocompent_C:WidgetComponent
--Edit Below--
local jiangecomponet = {}
 
--[[
function jiangecomponet:ReceiveBeginPlay()
    jiangecomponet.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function jiangecomponet:ReceiveTick(DeltaTime)
    jiangecomponet.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function jiangecomponet:ReceiveEndPlay()
    jiangecomponet.SuperClass.ReceiveEndPlay(self) 
end
--]]

return jiangecomponet