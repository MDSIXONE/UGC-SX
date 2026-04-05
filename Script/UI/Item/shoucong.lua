---@class shoucong_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_42 UButton
--Edit Below--
local shoucong =
{
    bInitDoOnce = false;
    ProductID = 9000601; -- 
}

function shoucong:Construct()
    self:LuaInit();
end

function shoucong:OnClick()
    -- Local helper value for this logic block.
    
    -- Local helper value for this logic block.
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local ProductData = CommodityOperationManager:GetProductData(self.ProductID)
    if not ProductData then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Guard condition before running this branch.
    
    -- Guard condition before running this branch.
    if not CommodityOperationManager:CanAfford(self.ProductID, 1) then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local LimitType = ProductData.LimitType or 0 -- 
    
    if RemainingTimes < 0 then
        RemainingTimes = 0
    end
    
    -- Guard condition before running this branch.
    
    -- Guard condition before running this branch.
    if LimitType ~= 0 and RemainingTimes <= 0 then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Acquire local player references.
    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then
        -- Exit early when requirements are not met.
        return
    end
    
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    local confirmUI = UGCGameData.GetUI(PlayerController, "ConfirmPurchase")
    if confirmUI then
        confirmUI:AddToViewport(15000)
        -- Keep this section consistent with the original UI flow.
        confirmUI:SetPurchaseInfo({
            ProductID = self.ProductID,
            ItemID = ProductData.ItemID,
            Price = ProductData.SellingPrice or 1,
            ItemName = ObjectData.ItemName or "閻椻晛鎼?,
            ItemDesc = ObjectData.ItemDesc or "",
            ItemIcon = ObjectData.ItemIcon,
            LimitType = LimitType,
            PurchaseLimit = PurchaseLimit,
            PurchasedTimes = PurchasedTimes,
            RemainingTimes = RemainingTimes,
            Caller = self
        })
        -- Keep this section consistent with the original UI flow.
    else
        -- Keep this section consistent with the original UI flow.
    end
end

--- Handle confirm purchase event.
function shoucong:OnConfirmPurchase()
    -- Local helper value for this logic block.
    
    -- Local helper value for this logic block.
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local ProductData = CommodityOperationManager:GetProductData(self.ProductID)
    if not ProductData then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        -- Exit early when requirements are not met.
        return
    end
    
    -- Local helper value for this logic block.
    -- Local helper value for this logic block.
    local PromiseFuture = UGCCommoditySystem.BuyUGCCommodity2(self.ProductID, ObjectData.ItemIcon, ObjectData.ItemDesc, 1)
    
    if PromiseFuture ~= nil then
        PromiseFuture:Then(
            function (Result)
                -- Local helper value for this logic block.
                local UI = Result:Get()
                if UI and UI.ConfirmationOperationDelegate then
                    UI.ConfirmationOperationDelegate:Add(self.OnPurchaseComplete, self)
                end
            end
        )
    else
        -- Keep this section consistent with the original UI flow.
    end
end

function shoucong:OnPurchaseComplete(bConfirmed)
    -- Guard condition before running this branch.
    
    if bConfirmed then
        -- Keep this section consistent with the original UI flow.
    else
        -- Keep this section consistent with the original UI flow.
    end
end

-- [Editor Generated Lua] function define Begin:
function shoucong:LuaInit()
    if self.bInitDoOnce then
        return;
    end
    self.bInitDoOnce = true;
    -- [Editor Generated Lua] BindingProperty Begin:
    -- [Editor Generated Lua] BindingProperty End;

    -- [Editor Generated Lua] BindingEvent Begin:
    self.Button_42.OnPressed:Add(self.OnClick, self);
    -- [Editor Generated Lua] BindingEvent End;
end

-- [Editor Generated Lua] function define End;

return shoucong
