---@class UIFeatureToggle
---Auto pickup and auto absorb toggle logic.

local UIFeatureToggle = {}

function UIFeatureToggle.GetFeatureToggleState(self, stateField)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return false
    end
    return playerState[stateField] == true
end

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
