---@class shoucong_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_42 UButton
--Edit Below--
local shoucong =
{
    bInitDoOnce = false;
    ProductID = 9000601; -- 鍟嗗搧ID
}

function shoucong:Construct()
    self:LuaInit();
end

function shoucong:OnClick()
    --ugcprint("[shoucong] 鎸夐挳琚偣鍑?)
    
    -- 鑾峰彇 CommodityOperationManager
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙?CommodityOperationManager")
        return
    end
    
    -- 鑾峰彇鍟嗗搧閰嶇疆
    local ProductData = CommodityOperationManager:GetProductData(self.ProductID)
    if not ProductData then
        --[[        --ugcprint(string.format("[shoucong] 閿欒锛氭棤娉曡幏鍙栧晢鍝侀厤缃紝ProductID: %d", self.ProductID))]]
        return
    end
    
    --[[    --ugcprint(string.format("[shoucong] 鍟嗗搧閰嶇疆 - ID:%d, 鐗╁搧ID:%d, 浠锋牸:%d", self.ProductID, ProductData.ItemID, ProductData.SellingPrice or 0))]]
    
    -- 妫€鏌ユ槸鍚﹁兘澶熻喘涔?    if not CommodityOperationManager:CanAfford(self.ProductID, 1) then
        --ugcprint("[shoucong] 缁挎床甯佷笉瓒?)
        return
    end
    
    -- 鑾峰彇 VirtualItemManager
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙?VirtualItemManager")
        return
    end
    
    -- 鑾峰彇鐗╁搧閰嶇疆
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙栫墿鍝侀厤缃?)
        return
    end
    
    -- 鑾峰彇闄愯喘淇℃伅
    local LimitType = ProductData.LimitType or 0  -- 0:涓嶉檺璐?    local PurchaseLimit = ProductData.PurchaseLimit or 0  -- 闄愯喘鎬绘鏁?    local PurchasedTimes = CommodityOperationManager:GetPurchasedTimes(self.ProductID) or 0  -- 宸茶喘涔版鏁?    local RemainingTimes = PurchaseLimit - PurchasedTimes  -- 鍓╀綑娆℃暟
    
    if RemainingTimes < 0 then
        RemainingTimes = 0
    end
    
    --[[    --ugcprint(string.format("[shoucong] 闄愯喘淇℃伅 - 绫诲瀷:%d, 闄愯喘:%d, 宸茶喘:%d, 鍓╀綑:%d", LimitType, PurchaseLimit, PurchasedTimes, RemainingTimes))]]
    
    -- 妫€鏌ユ槸鍚﹁繕鑳借喘涔?    if LimitType ~= 0 and RemainingTimes <= 0 then
        --ugcprint("[shoucong] 宸茶揪鍒拌喘涔颁笂闄?)
        return
    end
    
    -- 鏄剧ず鑷畾涔夌‘璁ょ晫闈?    --ugcprint("[shoucong] 鏄剧ず鑷畾涔夌‘璁ょ晫闈?)
    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙?PlayerController")
        return
    end
    
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    local confirmUI = UGCGameData.GetUI(PlayerController, "ConfirmPurchase")
    if confirmUI then
        confirmUI:AddToViewport(15000)
        -- 浼犻€掑畬鏁寸殑璐拱淇℃伅
        confirmUI:SetPurchaseInfo({
            ProductID = self.ProductID,
            ItemID = ProductData.ItemID,
            Price = ProductData.SellingPrice or 1,
            ItemName = ObjectData.ItemName or "鐗╁搧",
            ItemDesc = ObjectData.ItemDesc or "",
            ItemIcon = ObjectData.ItemIcon,
            LimitType = LimitType,
            PurchaseLimit = PurchaseLimit,
            PurchasedTimes = PurchasedTimes,
            RemainingTimes = RemainingTimes,
            Caller = self
        })
        --ugcprint("[shoucong] 鑷畾涔夌‘璁ょ晫闈㈠凡鏄剧ず")
    else
        --ugcprint("[shoucong] 閿欒锛氭棤娉曞垱寤虹‘璁ょ晫闈?)
    end
end

---纭璐拱锛堜粠鑷畾涔夌‘璁ょ晫闈㈣皟鐢級
function shoucong:OnConfirmPurchase()
    --ugcprint("[shoucong] 纭璐拱")
    
    -- 鑾峰彇 CommodityOperationManager
    local CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor()
    if not CommodityOperationManager then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙?CommodityOperationManager")
        return
    end
    
    -- 鑾峰彇鍟嗗搧閰嶇疆
    local ProductData = CommodityOperationManager:GetProductData(self.ProductID)
    if not ProductData then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙栧晢鍝侀厤缃?)
        return
    end
    
    -- 鑾峰彇 VirtualItemManager
    local VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VirtualItemManager then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙?VirtualItemManager")
        return
    end
    
    -- 鑾峰彇鐗╁搧閰嶇疆
    local ObjectData = VirtualItemManager:GetItemData(ProductData.ItemID)
    if not ObjectData then
        --ugcprint("[shoucong] 閿欒锛氭棤娉曡幏鍙栫墿鍝侀厤缃?)
        return
    end
    
    -- 璋冪敤绯荤粺璐拱鎺ュ彛锛堜細鑷姩鎵ｅ竵鍜屽彂璐э級
    --[[    --ugcprint(string.format("[shoucong] 璋冪敤璐拱鎺ュ彛 - ProductID:%d", self.ProductID))]]
    local PromiseFuture = UGCCommoditySystem.BuyUGCCommodity2(self.ProductID, ObjectData.ItemIcon, ObjectData.ItemDesc, 1)
    
    if PromiseFuture ~= nil then
        PromiseFuture:Then(
            function (Result)
                --ugcprint("[shoucong] 绯荤粺璐拱纭鐣岄潰宸叉墦寮€")
                local UI = Result:Get()
                if UI and UI.ConfirmationOperationDelegate then
                    UI.ConfirmationOperationDelegate:Add(self.OnPurchaseComplete, self)
                end
            end
        )
    else
        --ugcprint("[shoucong] 閿欒锛氭棤娉曟墦寮€璐拱纭鐣岄潰")
    end
end

function shoucong:OnPurchaseComplete(bConfirmed)
    --[[    --ugcprint(string.format("[shoucong] 璐拱瀹屾垚鍥炶皟 - 纭:%s", tostring(bConfirmed)))]]
    
    if bConfirmed then
        -- ugcprint("[shoucong] 璐拱鎴愬姛锛佺郴缁熷凡鑷姩鎵ｉ櫎缁挎床甯佸苟鍙戞斁鐗╁搧")
    else
        --ugcprint("[shoucong] 璐拱宸插彇娑?)
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
