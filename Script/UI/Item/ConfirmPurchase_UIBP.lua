---@class ConfirmPurchase_UIBP_C:UUserWidget
---@field Button_1 UButton
---@field cancel UButton
---@field detail UTextBlock
---@field Image_0 UImage
---@field Image_1 UImage
---@field ImageEx_0 UImageEx
---@field ImageEx_30 UImageEx
---@field sure UButton
---@field switchto1 UButton
---@field Switchto2 UButton
---@field TextBlock_5 UTextBlock
---@field WidgetSwitcher_0 UWidgetSwitcher
--Edit Below--
local ConfirmPurchase_UIBP = { 
    bInitDoOnce = false,
    ProductID_Page1 = 9000601,  -- 页面1的商品ID
    ProductID_Page2 = 9000602   -- 页面2的商品ID
}

function ConfirmPurchase_UIBP:Construct()
    self:LuaInit()
end

function ConfirmPurchase_UIBP:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    
    -- Bind the button event.
    self.sure.OnPressed:Add(self.OnConfirmClick, self)
    self.cancel.OnPressed:Add(self.OnCancelClick, self)
    self.switchto1.OnPressed:Add(self.OnSwitchTo1Click, self)
    self.Switchto2.OnPressed:Add(self.OnSwitchTo2Click, self)
    
    -- Initialize the UI UI.
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
    
    -- Log the initialization state.
end

-- Related UI logic.
-- Related UI logic.
function ConfirmPurchase_UIBP:SetPurchaseInfo(info)
    self.PurchaseInfo = info
    
    -- Log this action.
        info.ProductID, info.ItemID, info.Price))]]
    -- Log this action.
        info.LimitType, info.PurchaseLimit, info.PurchasedTimes, info.RemainingTimes))]]
    
    -- Update the UI UI state.
    if self.detail then
        local detailText = string.format("确认花费 %d 绿洲币购买 %s？", info.Price, info.ItemName or "物品")
        
        -- Related UI logic.
        if info.LimitType ~= 0 then
            detailText = detailText .. string.format("\n\n限购次数：%d/%d (剩余 %d 次)", 
                info.PurchasedTimes, info.PurchaseLimit, info.RemainingTimes)
        end
        
        self.detail:SetText(detailText)
        -- Log this action.
    end
end

-- Handle the confirm action.
function ConfirmPurchase_UIBP:OnConfirmClick()
    -- Log this action.
    
    -- Get the required UI reference.
    local currentIndex = 0
    if self.WidgetSwitcher_0 then
        currentIndex = self.WidgetSwitcher_0:GetActiveWidgetIndex()
    end
    
    -- Log this action.
    
    -- Related UI logic.
    local productID = currentIndex == 0 and self.ProductID_Page1 or self.ProductID_Page2
    
    -- Log this action.
    
    -- Related UI logic.
    self:PurchaseProduct(productID)
    
    -- Related UI logic.
    self:RemoveFromParent()
end

-- Handle the cancel action.
function ConfirmPurchase_UIBP:OnCancelClick()
    -- Log this action.
    
    -- Related UI logic.
    self:RemoveFromParent()
end

-- Related UI logic.
function ConfirmPurchase_UIBP:OnSwitchTo1Click()
    -- Log this action.
    
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
end

-- Related UI logic.
function ConfirmPurchase_UIBP:OnSwitchTo2Click()
    -- Log this action.
    
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    end
end

-- Related UI logic.
-- Related UI logic.
function ConfirmPurchase_UIBP:PurchaseProduct(productID)
    -- Log this action.
    
    -- Get the required UI reference.
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        -- Log the error state.
        return
    end
    
    -- Get the required UI reference.
    local ProductData = CommodityOperationManager:GetProductData(productID)
    if not ProductData then
        -- Log the error state.
        return
    end
    
    -- Get the required UI reference.
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        -- Log the error state.
        return
    end
    
    -- Get the required UI reference.
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        -- Log the error state.
        return
    end
    
    -- Related UI logic.
    -- Log this action.
    local PromiseFuture = UGCCommoditySystem.BuyUGCCommodity2(productID, ObjectData.ItemIcon, ObjectData.ItemDesc, 1)
    
    if PromiseFuture ~= nil then
        PromiseFuture:Then(
            function (Result)
                -- Log this action.
                local UI = Result:Get()
                if UI and UI.ConfirmationOperationDelegate then
                    UI.ConfirmationOperationDelegate:Add(self.OnPurchaseComplete, self)
                end
            end
        )
    else
        -- Log the error state.
    end
end

-- Related UI logic.
function ConfirmPurchase_UIBP:OnPurchaseComplete(bConfirmed)
    -- Log this action.
    
    if bConfirmed then
        -- Log the success state.
    else
        -- Log this action.
    end
end

return ConfirmPurchase_UIBP
