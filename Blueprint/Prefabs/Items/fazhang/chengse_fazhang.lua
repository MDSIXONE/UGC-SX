---@class chengse_fazhang_C:Template_Melee_Pan_Handle_C
--Edit Below--
local lvse_fazhang = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function lvse_fazhang:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return lvse_fazhang.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function lvse_fazhang:HandleDrop(InCount, Reason)
--    return lvse_fazhang.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function lvse_fazhang:HandleTake(TakeCount, TotalCount)
--    return lvse_fazhang.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function lvse_fazhang:HandleUse(Target, Reason)
--    return lvse_fazhang.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function lvse_fazhang:HandleDisuse(Reason)
--    return lvse_fazhang.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function lvse_fazhang:HandleTryDisuse(Reason)
--    return lvse_fazhang.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function lvse_fazhang:HandleEnable(bEnable)
--    lvse_fazhang.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function lvse_fazhang:HanldeCleared()
--    return lvse_fazhang.SuperClass.HanldeCleared(self)
-- end
]]--


return lvse_fazhang