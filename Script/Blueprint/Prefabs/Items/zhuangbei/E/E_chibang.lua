---@class E_chibang_C:Template_AvatarEquipment_CustomBag_C
--Edit Below--
local E_chibang = {} 

-- [[ 特殊事件 ]]
--- func 当耐久度变化时生效(服务端生效)
---@param OriginDurability number 原始耐久值
---@param ChangedDurability number 变化后的耐久值
-- function E_chibang:OnDurabilityChanged(OriginDurability, ChangedDurability)
--     E_chibang.SuperClass.OnDurabilityChanged(self, OriginDurability, ChangedDurability);
-- end

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function E_chibang:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return E_chibang.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function E_chibang:HandleDrop(InCount, Reason)
--    return E_chibang.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function E_chibang:HandleTake(TakeCount, TotalCount)
--    return E_chibang.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function E_chibang:HandleUse(Target, Reason)
--    return E_chibang.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function E_chibang:HandleDisuse(Reason)
--    return E_chibang.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function E_chibang:HandleTryDisuse(Reason)
--    return E_chibang.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function E_chibang:HandleEnable(bEnable)
--    E_chibang.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function E_chibang:HanldeCleared()
--    return E_chibang.SuperClass.HanldeCleared(self)
-- end
]]--

--[[V2背包事件]]--
--[[
--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function E_chibang:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return E_chibang.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function E_chibang:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     E_chibang.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function E_chibang:CanUseV2()
--     return E_chibang.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function E_chibang:OnUseV2()
--     E_chibang.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function E_chibang:OnDisuseV2()
--     E_chibang.SuperClass.OnDisuseV2(self);
-- end

--- func 其他物品能否附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function E_chibang:CanAttachToSlot(SlotName, ItemDefineID)
--     return E_chibang.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当其他物品附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function E_chibang:OnAttachToSlot(SlotName, ItemDefineID)
--     E_chibang.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当物品从此槽位移除(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function E_chibang:OnDetachBySlot(SlotName, ItemDefineID)
--     E_chibang.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID);
-- end

--- func 能否Attach到Parent物品上, 如果Parent为空物品, 说明将被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
---@return bool 能否Attach
-- function E_chibang:CanAttach(ParentDefineID, SlotName)
--     return E_chibang.SuperClass.CanAttach(self, ParentDefineID, SlotName);
-- end

--- func 当Attach到Parent物品上, 如果Parent为空物品, 说明是被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function E_chibang:OnAttach(ParentDefineID, SlotName)
--     E_chibang.SuperClass.OnAttach(self, ParentDefineID, SlotName);
-- end

--- func 当从Parent物品上解除Attach, 如果Parent为空物品, 说明是从背包装备槽位解除装备(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function E_chibang:OnDetach(ParentDefineID, SlotName)
--     E_chibang.SuperClass.OnDetach(self, ParentDefineID, SlotName);
-- end

--- func 当物品被装备前，检查能否装备(服务端生效)
---@return bool 能否装备
-- function E_chibang:CanEquip()
--     return E_chibang.SuperClass.CanEquip(self);
-- end

--- func 当物品被装备回调(服务端生效)
-- function E_chibang:OnEquip()
--     E_chibang.SuperClass.OnEquip(self);
-- end

--- func 当物品被卸下回调(服务端生效)
-- function E_chibang:OnUnEquip()
--     E_chibang.SuperClass.OnUnEquip(self);
-- end

--- func 当物品在背包中被交换槽位前，检查能否交换(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
---@return 能否交换到新槽位
-- function E_chibang:CanSwapEquipSlot(OldSlotName, NewSlotName)
--     return E_chibang.SuperClass.CanSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end

--- func 当物品被交换到新装备槽位后回调(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
-- function E_chibang:OnSwapEquipSlot(OldSlotName, NewSlotName)
        E_chibang.SuperClass.OnSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end
]]--

return E_chibang