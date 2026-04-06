---@class shoucong_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_42 UButton
--Edit Below--
local shoucong =
{
    bInitDoOnce = false;
    ProductID = 9000601; -- 商品ID
}

function shoucong:Construct()
    self:LuaInit();
end

function shoucong:OnClick()
    --ugcprint("[shoucong] 按钮被点击")
    
    -- 获取 CommodityOperationManager
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        --ugcprint("[shoucong] 错误：无法获取 CommodityOperationManager")
        return
    end
    
    -- 获取商品配置
    local ProductData = CommodityOperationManager:GetProductData(self.ProductID)
    if not ProductData then
        --[[        --ugcprint(string.format("[shoucong] 错误：无法获取商品配置，ProductID: %d", self.ProductID))]]
        return
    end
    
    --[[    --ugcprint(string.format("[shoucong] 商品配置 - ID:%d, 物品ID:%d, 价格:%d", self.ProductID, ProductData.ItemID, ProductData.SellingPrice or 0))]]
    
    -- 检查是否能够购买
    if not CommodityOperationManager:CanAfford(self.ProductID, 1) then
        --ugcprint("[shoucong] 绿洲币不足")
        return
    end
    
    -- 获取 VirtualItemManager
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        --ugcprint("[shoucong] 错误：无法获取 VirtualItemManager")
        return
    end
    
    -- 获取物品配置
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        --ugcprint("[shoucong] 错误：无法获取物品配置")
        return
    end
    
    -- 获取限购信息
    local LimitType = ProductData.LimitType or 0  -- 0:不限购
    local PurchaseLimit = ProductData.PurchaseLimit or 0  -- 限购总次数
    local PurchasedTimes = CommodityOperationManager:GetPurchasedTimes(self.ProductID) or 0  -- 已购买次数
    local RemainingTimes = PurchaseLimit - PurchasedTimes  -- 剩余次数
    
    if RemainingTimes < 0 then
        RemainingTimes = 0
    end
    
    --[[    --ugcprint(string.format("[shoucong] 限购信息 - 类型:%d, 限购:%d, 已购:%d, 剩余:%d", LimitType, PurchaseLimit, PurchasedTimes, RemainingTimes))]]
    
    -- 检查是否还能购买
    if LimitType ~= 0 and RemainingTimes <= 0 then
        --ugcprint("[shoucong] 已达到购买上限")
        return
    end
    
    -- 显示自定义确认界面
    --ugcprint("[shoucong] 显示自定义确认界面")
    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then
        --ugcprint("[shoucong] 错误：无法获取 PlayerController")
        return
    end
    
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    local confirmUI = UGCGameData.GetUI(PlayerController, "ConfirmPurchase")
    if confirmUI then
        confirmUI:AddToViewport(15000)
        -- 传递完整的购买信息
        confirmUI:SetPurchaseInfo({
            ProductID = self.ProductID,
            ItemID = ProductData.ItemID,
            Price = ProductData.SellingPrice or 1,
            ItemName = ObjectData.ItemName or "物品",
            ItemDesc = ObjectData.ItemDesc or "",
            ItemIcon = ObjectData.ItemIcon,
            LimitType = LimitType,
            PurchaseLimit = PurchaseLimit,
            PurchasedTimes = PurchasedTimes,
            RemainingTimes = RemainingTimes,
            Caller = self
        })
        --ugcprint("[shoucong] 自定义确认界面已显示")
    else
        --ugcprint("[shoucong] 错误：无法创建确认界面")
    end
end

---确认购买（从自定义确认界面调用）
function shoucong:OnConfirmPurchase()
    --ugcprint("[shoucong] 确认购买")
    
    -- 获取 CommodityOperationManager
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        --ugcprint("[shoucong] 错误：无法获取 CommodityOperationManager")
        return
    end
    
    -- 获取商品配置
    local ProductData = CommodityOperationManager:GetProductData(self.ProductID)
    if not ProductData then
        --ugcprint("[shoucong] 错误：无法获取商品配置")
        return
    end
    
    -- 获取 VirtualItemManager
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        --ugcprint("[shoucong] 错误：无法获取 VirtualItemManager")
        return
    end
    
    -- 获取物品配置
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        --ugcprint("[shoucong] 错误：无法获取物品配置")
        return
    end
    
    -- 调用系统购买接口（会自动扣币和发货）
    --[[    --ugcprint(string.format("[shoucong] 调用购买接口 - ProductID:%d", self.ProductID))]]
    local PromiseFuture = UGCCommoditySystem.BuyUGCCommodity2(self.ProductID, ObjectData.ItemIcon, ObjectData.ItemDesc, 1)
    
    if PromiseFuture ~= nil then
        PromiseFuture:Then(
            function (Result)
                --ugcprint("[shoucong] 系统购买确认界面已打开")
                local UI = Result:Get()
                if UI and UI.ConfirmationOperationDelegate then
                    UI.ConfirmationOperationDelegate:Add(self.OnPurchaseComplete, self)
                end
            end
        )
    else
        --ugcprint("[shoucong] 错误：无法打开购买确认界面")
    end
end

function shoucong:OnPurchaseComplete(bConfirmed)
    --[[    --ugcprint(string.format("[shoucong] 购买完成回调 - 确认:%s", tostring(bConfirmed)))]]
    
    if bConfirmed then
        --ugcprint("[shoucong] 购买成功！系统已自动扣除绿洲币并发放物品")
    else
        --ugcprint("[shoucong] 购买已取消")
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