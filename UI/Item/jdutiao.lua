---@class jdutiao_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field ProgressBar_0 UProgressBar
--Edit Below--
local jdutiao = { bInitDoOnce = false }

function jdutiao:Construct()
    -- jdutiao 由 wujingjiange 动态创建并控制
    -- 动画播放和关闭逻辑在 wujingjiange:OnStartClicked 中处理
end

function jdutiao:Destruct()
end

return jdutiao
