---@class shouchongjian_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local shouchongjian = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function shouchongjian:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return shouchongjian.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function shouchongjian:HandleDrop(InCount, Reason)
--    return shouchongjian.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function shouchongjian:HandleTake(TakeCount, TotalCount)
--    return shouchongjian.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function shouchongjian:HandleUse(Target, Reason)
--    return shouchongjian.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function shouchongjian:HandleDisuse(Reason)
--    return shouchongjian.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function shouchongjian:HandleTryDisuse(Reason)
--    return shouchongjian.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function shouchongjian:HandleEnable(bEnable)
--    shouchongjian.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function shouchongjian:HanldeCleared()
--    return shouchongjian.SuperClass.HanldeCleared(self)
-- end
]]--


return shouchongjian