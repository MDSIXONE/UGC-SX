---@class lanse_C:PersistEffectBuff
--Edit Below--
local jinse = {}
 
-- buff启动条件
--[[
function jinse:CanApply_BP(OwnerActor)
-- return true
end
--]]

-- buff开始
--[[
function jinse:OnApply_BP(OwnerActor)

end
--]]

-- buff结束
--[[
function jinse:OnUnApply_BP(OwnerActor, Reason)

end
--]]

-- buff合并条件，A为当前身上已有buff，B为外来buff，当要挂载外来buff时会判断A.CanMerge(B)
--[[
function jinse:CanMerge_BP(PersistEffect)
-- return true
end
--]]

-- buff合并，A为当前身上已有buff，B为外来buff，调用A.OnMerge(B)
--[[
function jinse:OnMerge_BP(PersistEffect)

end
--]]

-- 开启Tick需要SetTickEnable(true)，或buff为间隔触发类型会自动开启
--[[
function jinse:Tick_BP(OwnerActor, DeltaTime)

end
--]]

--[[
function jinse:OnInterrupted_BP(OwnerActor)

end
--]]

-- buff总持续时长变化，如修改ApplyTime、修改StackNum
--[[
function jinse:OnTotalDurationChange_BP(PreTime, CurTime)

end
--]]

-- buff堆叠层数变化
--[[
function jinse:OnStackChange_BP(PreNum, CurNum)

end
--]]

-- buff触发前条件判断
--[[
function jinse:CanTrigger_BP()
	return true
end
--]]

-- buff触发效果
--[[
function jinse:OnTrigger_BP(Delta)

end
--]]

return jinse