---@class shoucong_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_42 UButton
--Edit Below--
UGCGameSystem.UGCRequire("ExtendResource.SignInEvent.OfficialPackage." .. "Script.SignInEvent.SignInEventManager")

local shoucong =
{
    bInitDoOnce = false;
    ProductID = 9000601; -- 商品ID
}

function shoucong:Construct()
    self:LuaInit();
end

function shoucong:OnClick()
    --ugcprint("[shoucong] 按钮被点击，打开签到主界面")

    if SignInEventManager and SignInEventManager.OpenMainUI then
        SignInEventManager:OpenMainUI()
    else
        --ugcprint("[shoucong] 错误 - SignInEventManager 不存在")
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