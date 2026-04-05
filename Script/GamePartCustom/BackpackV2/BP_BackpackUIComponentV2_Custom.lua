---@class BP_BackpackUIComponentV2_Custom_C:BP_BackpackUIComponentV2_C
--Edit Below--
local BP_BackpackUIComponentV2_Custom = {} 

---开始运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveBeginPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveBeginPlay(self)
end

---结束运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveEndPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveEndPlay(self)
end

return BP_BackpackUIComponentV2_Custom
