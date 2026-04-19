---@class UIFeatureToggle
---
--- 模块说明：自动吞噬和自动拾取功能开关的 UI 逻辑封装
--- 提供功能解锁状态检查、开关状态读取/设置、按钮点击事件处理等功能
--- 自动吞噬通过 Config_PlayerData.AUTO_TUNSHI_UNLOCK_ITEM_ID 判断解锁
--- 自动拾取通过 Config_PlayerData.AUTO_PICKUP_UNLOCK_ITEM_ID 判断解锁
--- 功能状态通过 Server_SetAutoTunshiEnabled / Server_SetAutoPickupEnabled RPC 同步到服务端

local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')

local UIFeatureToggle = {}

--- 从 playerState 读取功能开关状态
--- @param self 表自身
--- @param stateField string 状态字段名（如 "UGCAutoTunshiEnabled"）
--- @return boolean 返回该开关的启用状态，未找到或 playerState 为空时返回 false
function UIFeatureToggle.GetFeatureToggleState(self, stateField)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return false
    end
    return playerState[stateField] == true
end

--- 设置功能开关状态，同时写入 playerState 和 GameData
--- @param self 表自身
--- @param stateField string 状态字段名（如 "UGCAutoTunshiEnabled"）
--- @param gameDataField string GameData 中的字段名（如 "AutoTunshiEnabled"）
--- @param enabled boolean 是否启用该功能
function UIFeatureToggle.SetFeatureToggleState(self, stateField, gameDataField, enabled)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return
    end
    playerState[stateField] = (enabled == true)
    if playerState.GameData then
        playerState.GameData[gameDataField] = (enabled == true)
    end
end

--- 检查功能是否已解锁（通过虚拟物品数量判断）
--- 自动吞噬使用 Config_PlayerData.AUTO_TUNSHI_UNLOCK_ITEM_ID
--- 自动拾取使用 Config_PlayerData.AUTO_PICKUP_UNLOCK_ITEM_ID
--- @param self 表自身
--- @param itemID number 解锁所需的虚拟物品ID
--- @return boolean 物品数量大于 0 返回 true，否则返回 false
function UIFeatureToggle.IsFeatureUnlocked(self, itemID)
    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return false
    end
    local virtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not virtualItemManager then
        return false
    end
    local itemNum = virtualItemManager:GetItemNum(itemID, playerController) or 0
    return itemNum > 0
end

--- 跳转到购买界面购买功能解锁道具
--- 通过 shoucong 组件触发购买确认流程，设置 ProductID 后调用 OnConfirmPurchase 或 OnClick
--- @param self 表自身
--- @param productID number 商品ID，对应 Config_PlayerData 中的功能商品ID
function UIFeatureToggle.JumpToFeaturePurchase(self, productID)
    if self.shoucong then
        if productID and productID > 0 then
            self.shoucong.ProductID = productID
        end
        if self.shoucong.OnConfirmPurchase then
            self.shoucong:OnConfirmPurchase()
        elseif self.shoucong.OnClick then
            self.shoucong:OnClick()
        end
    end
end

--- 自动吞噬按钮点击事件处理
--- 流程：先检查解锁状态（通过 AUTO_TUNSHI_UNLOCK_ITEM_ID 虚拟物品数量判断）
---  - 若未解锁：弹出提示并跳转到购买界面购买解锁道具
---  - 若已解锁：切换开关状态，同时写入 playerState 和 GameData，
---    并通过 Server_SetAutoTunshiEnabled RPC 通知服务端同步状态
--- @param self 表自身
function UIFeatureToggle.OnAutoTunshiClicked(self)
    if not UIFeatureToggle.IsFeatureUnlocked(self, Config_PlayerData.AUTO_TUNSHI_UNLOCK_ITEM_ID) then
        self:ShowTip("自动吞噬功能未解锁，前往购买。")
        UIFeatureToggle.JumpToFeaturePurchase(self, Config_PlayerData.AUTO_TUNSHI_PRODUCT_ID)
        return
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return
    end

    local newState = not UIFeatureToggle.GetFeatureToggleState(self, "UGCAutoTunshiEnabled")
    UIFeatureToggle.SetFeatureToggleState(self, "UGCAutoTunshiEnabled", "AutoTunshiEnabled", newState)
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_SetAutoTunshiEnabled", newState)

    if self.zdtunshi and self.zdtunshi.SetToggleState then
        self.zdtunshi:SetToggleState(newState)
    elseif self.zdtunshi and self.zdtunshi.RefreshFromPlayerState then
        self.zdtunshi:RefreshFromPlayerState()
    end

    if newState then
        self:ShowTip("自动吞噬已开启。")
    else
        self:ShowTip("自动吞噬已关闭。")
    end
end

--- 自动拾取按钮点击事件处理
--- 逻辑与自动吞噬相同，通过 AUTO_PICKUP_UNLOCK_ITEM_ID 判断解锁
--- 已解锁时切换状态并通过 Server_SetAutoPickupEnabled RPC 通知服务端
--- @param self 表自身
function UIFeatureToggle.OnAutoPickupClicked(self)
    if not UIFeatureToggle.IsFeatureUnlocked(self, Config_PlayerData.AUTO_PICKUP_UNLOCK_ITEM_ID) then
        self:ShowTip("自动拾取功能未解锁，前往购买。")
        UIFeatureToggle.JumpToFeaturePurchase(self, Config_PlayerData.AUTO_PICKUP_PRODUCT_ID)
        return
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return
    end

    local newState = not UIFeatureToggle.GetFeatureToggleState(self, "UGCAutoPickupEnabled")
    UIFeatureToggle.SetFeatureToggleState(self, "UGCAutoPickupEnabled", "AutoPickupEnabled", newState)
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_SetAutoPickupEnabled", newState)

    if self.zdshiqu and self.zdshiqu.SetToggleState then
        self.zdshiqu:SetToggleState(newState)
    elseif self.zdshiqu and self.zdshiqu.RefreshFromPlayerState then
        self.zdshiqu:RefreshFromPlayerState()
    end

    if newState then
        self:ShowTip("自动拾取已开启。")
    else
        self:ShowTip("自动拾取已关闭。")
    end
end

return UIFeatureToggle
