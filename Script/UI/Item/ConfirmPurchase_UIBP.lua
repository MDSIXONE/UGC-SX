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
    
    -- 绑定按钮事件
    self.sure.OnPressed:Add(self.OnConfirmClick, self)
    self.cancel.OnPressed:Add(self.OnCancelClick, self)
    self.switchto1.OnPressed:Add(self.OnSwitchTo1Click, self)
    self.Switchto2.OnPressed:Add(self.OnSwitchTo2Click, self)
    
    -- 初始化 WidgetSwitcher 显示第一个页面
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
    
    --ugcprint("[ConfirmPurchase_UIBP] 初始化完成")
end

---设置购买信息
---@param info table 购买信息表
function ConfirmPurchase_UIBP:SetPurchaseInfo(info)
    self.PurchaseInfo = info
    
    --[[ugcprint(string.format("[ConfirmPurchase_UIBP] 设置购买信息 - 商品ID:%d, 物品ID:%d, 价格:%d", 
        info.ProductID, info.ItemID, info.Price))]]
    --[[ugcprint(string.format("[ConfirmPurchase_UIBP] 限购信息 - 类型:%d, 限购:%d, 已购:%d, 剩余:%d", 
        info.LimitType, info.PurchaseLimit, info.PurchasedTimes, info.RemainingTimes))]]
    
    -- 更新UI显示
    if self.detail then
        local detailText = string.format("确认花费 %d 绿洲币购买 %s？", info.Price, info.ItemName or "物品")
        
        -- 如果有限购，显示限购信息
        if info.LimitType ~= 0 then
            detailText = detailText .. string.format("\n\n限购次数：%d/%d (剩余 %d 次)", 
                info.PurchasedTimes, info.PurchaseLimit, info.RemainingTimes)
        end
        
        self.detail:SetText(detailText)
        --[[        --ugcprint(string.format("[ConfirmPurchase_UIBP] 显示文本: %s", detailText))]]
    end
end

---确认按钮点击
function ConfirmPurchase_UIBP:OnConfirmClick()
    --ugcprint("[ConfirmPurchase_UIBP] 点击确认按钮")
    
    -- 获取当前页面索引
    local currentIndex = 0
    if self.WidgetSwitcher_0 then
        currentIndex = self.WidgetSwitcher_0:GetActiveWidgetIndex()
    end
    
    --[[    --ugcprint(string.format("[ConfirmPurchase_UIBP] 当前页面索引: %d", currentIndex))]]
    
    -- 根据页面索引决定购买哪个商品
    local productID = currentIndex == 0 and self.ProductID_Page1 or self.ProductID_Page2
    
    --[[    --ugcprint(string.format("[ConfirmPurchase_UIBP] 购买商品ID: %d", productID))]]
    
    -- 执行购买逻辑
    self:PurchaseProduct(productID)
    
    -- 关闭界面
    self:RemoveFromParent()
end

---取消按钮点击
function ConfirmPurchase_UIBP:OnCancelClick()
    --ugcprint("[ConfirmPurchase_UIBP] 点击取消按钮")
    
    -- 关闭界面
    self:RemoveFromParent()
end

---切换到第一个页面
function ConfirmPurchase_UIBP:OnSwitchTo1Click()
    --ugcprint("[ConfirmPurchase_UIBP] 切换到页面1")
    
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
end

---切换到第二个页面
function ConfirmPurchase_UIBP:OnSwitchTo2Click()
    --ugcprint("[ConfirmPurchase_UIBP] 切换到页面2")
    
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    end
end

---购买商品
---@param productID number 商品ID
function ConfirmPurchase_UIBP:PurchaseProduct(productID)
    --[[    --ugcprint(string.format("[ConfirmPurchase_UIBP] 开始购买商品 - ProductID: %d", productID))]]
    
    -- 获取 CommodityOperationManager
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        --ugcprint("[ConfirmPurchase_UIBP] 错误：无法获取 CommodityOperationManager")
        return
    end
    
    -- 获取商品配置
    local ProductData = CommodityOperationManager:GetProductData(productID)
    if not ProductData then
        --[[        --ugcprint(string.format("[ConfirmPurchase_UIBP] 错误：无法获取商品配置，ProductID: %d", productID))]]
        return
    end
    
    -- 获取 VirtualItemManager
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        --ugcprint("[ConfirmPurchase_UIBP] 错误：无法获取 VirtualItemManager")
        return
    end
    
    -- 获取物品配置
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        --ugcprint("[ConfirmPurchase_UIBP] 错误：无法获取物品配置")
        return
    end
    
    -- 调用系统购买接口（会自动扣币和发货）
    --[[    --ugcprint(string.format("[ConfirmPurchase_UIBP] 调用购买接口 - ProductID:%d", productID))]]
    local PromiseFuture = UGCCommoditySystem.BuyUGCCommodity2(productID, ObjectData.ItemIcon, ObjectData.ItemDesc, 1)
    
    if PromiseFuture ~= nil then
        PromiseFuture:Then(
            function (Result)
                --ugcprint("[ConfirmPurchase_UIBP] 系统购买确认界面已打开")
                local UI = Result:Get()
                if UI and UI.ConfirmationOperationDelegate then
                    UI.ConfirmationOperationDelegate:Add(self.OnPurchaseComplete, self)
                end
            end
        )
    else
        --ugcprint("[ConfirmPurchase_UIBP] 错误：无法打开购买确认界面")
    end
end

---购买完成回调
function ConfirmPurchase_UIBP:OnPurchaseComplete(bConfirmed)
    --[[    --ugcprint(string.format("[ConfirmPurchase_UIBP] 购买完成回调 - 确认:%s", tostring(bConfirmed)))]]
    
    if bConfirmed then
        --ugcprint("[ConfirmPurchase_UIBP] 购买成功！系统已自动扣除绿洲币并发放物品")
    else
        --ugcprint("[ConfirmPurchase_UIBP] 购买已取消")
    end
end

return ConfirmPurchase_UIBP