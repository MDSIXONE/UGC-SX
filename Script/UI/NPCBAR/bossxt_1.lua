---@class bossxt_1_C:UGCGenericCharacterPositionWidget
---@field ProgressBar_0 UProgressBar
---@field TextBlock_name UTextBlock
---@field TextBlock_percent UTextBlock
--Edit Below--
local bossxt_1 = { bInitDoOnce = false }

-- 角色名字变化回调
---@param Name FName
function bossxt_1:BP_CharacterNameChange(Name)
    self.TextBlock_name:SetText(tostring(Name))
end

-- 角色血量变化回调
---@param InHPCurrent float 当前血量
---@param InHPMax float 最大血量
function bossxt_1:BP_CharacterHPChange(InHPCurrent, InHPMax)
    if InHPMax > 0 then
        local percent = InHPCurrent / InHPMax
        self.ProgressBar_0:SetPercent(percent)
        self.TextBlock_percent:SetText(string.format("%d%%", math.floor(percent * 100)))
    end
end

-- 初始化参数完成回调
function bossxt_1:Event_InitParamEnd()
end

return bossxt_1
