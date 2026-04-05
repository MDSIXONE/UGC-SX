---@class X_fuwuqi_C:Template_Other_RPG_C
--Edit Below--
local X_fuwuqi = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function X_fuwuqi:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return X_fuwuqi.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function X_fuwuqi:HandleDrop(InCount, Reason)
--    return X_fuwuqi.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function X_fuwuqi:HandleTake(TakeCount, TotalCount)
--    return X_fuwuqi.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function X_fuwuqi:HandleUse(Target, Reason)
--    return X_fuwuqi.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function X_fuwuqi:HandleDisuse(Reason)
--    return X_fuwuqi.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function X_fuwuqi:HandleTryDisuse(Reason)
--    return X_fuwuqi.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function X_fuwuqi:HandleEnable(bEnable)
--    X_fuwuqi.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function X_fuwuqi:HanldeCleared()
--    return X_fuwuqi.SuperClass.HanldeCleared(self)
-- end
]]--

--[[V2背包事件]]--
--[[
--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function X_fuwuqi:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return X_fuwuqi.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function X_fuwuqi:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     X_fuwuqi.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function X_fuwuqi:CanUseV2()
--     return X_fuwuqi.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function X_fuwuqi:OnUseV2()
--     X_fuwuqi.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function X_fuwuqi:OnDisuseV2()
--     X_fuwuqi.SuperClass.OnDisuseV2(self);
-- end

--- func 其他物品能否附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function X_fuwuqi:CanAttachToSlot(SlotName, ItemDefineID)
--     return X_fuwuqi.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当其他物品附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function X_fuwuqi:OnAttachToSlot(SlotName, ItemDefineID)
--     X_fuwuqi.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当物品从此槽位移除(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function X_fuwuqi:OnDetachBySlot(SlotName, ItemDefineID)
--     X_fuwuqi.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID);
-- end

--- func 能否Attach到Parent物品上, 如果Parent为空物品, 说明将被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
---@return bool 能否Attach
-- function X_fuwuqi:CanAttach(ParentDefineID, SlotName)
--     return X_fuwuqi.SuperClass.CanAttach(self, ParentDefineID, SlotName);
-- end

--- func 当Attach到Parent物品上, 如果Parent为空物品, 说明是被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function X_fuwuqi:OnAttach(ParentDefineID, SlotName)
--     X_fuwuqi.SuperClass.OnAttach(self, ParentDefineID, SlotName);
-- end

--- func 当从Parent物品上解除Attach, 如果Parent为空物品, 说明是从背包装备槽位解除装备(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function X_fuwuqi:OnDetach(ParentDefineID, SlotName)
--     X_fuwuqi.SuperClass.OnDetach(self, ParentDefineID, SlotName);
-- end

--- func 当物品被装备前，检查能否装备(服务端生效)
---@return bool 能否装备
-- function X_fuwuqi:CanEquip()
--     return X_fuwuqi.SuperClass.CanEquip(self);
-- end

--- func 当物品被装备回调(服务端生效)
-- function X_fuwuqi:OnEquip()
--     X_fuwuqi.SuperClass.OnEquip(self);
-- end

--- func 当物品被卸下回调(服务端生效)
-- function X_fuwuqi:OnUnEquip()
--     X_fuwuqi.SuperClass.OnUnEquip(self);
-- end

--- func 当物品在背包中被交换槽位前，检查能否交换(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
---@return 能否交换到新槽位
-- function X_fuwuqi:CanSwapEquipSlot(OldSlotName, NewSlotName)
--     return X_fuwuqi.SuperClass.CanSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end

--- func 当物品被交换到新装备槽位后回调(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
-- function X_fuwuqi:OnSwapEquipSlot(OldSlotName, NewSlotName)
        X_fuwuqi.SuperClass.OnSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end
]]--


return X_fuwuqi