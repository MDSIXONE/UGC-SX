---@class NumChose_C:UGC_BackpackMain_Full_UIBP_C
---@field Btn_Increase UButton
---@field Btn_Increase10 UButton
---@field Btn_Increase100 UButton
---@field Btn_Reduce UButton
---@field BtnClose UButton
---@field Button_Buy UButton
---@field Common_UIPopupBG Common_UIPopupBG_C
---@field GiftPack_PopupsBG_UIBP GiftPack_PopupsBG_UIBP_C
---@field Image_BgQuality UImage
---@field Image_EffectExpression UImage
---@field Image_Icon UImage
---@field Image_Quality UImage
---@field IsOwned UTextBlock
---@field Money_Type_Img1 UImage
---@field Name1 UTextBlock
---@field NumberInput UHorizontalBox
---@field Price2 UTextBlock
---@field Text UTextBlock
---@field TextBlock_Count UTextBlock
---@field TextBlock_Describe UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_Increase UWidgetSwitcher
---@field WidgetSwitcher_Reduce UWidgetSwitcher
--Edit Below--
local NumChose = { bInitDoOnce = false }

function NumChose:Construct()
    -- ugcprint("[NumChose] ========== Construct 寮€濮?==========")
    self.BtnClose.OnClicked:Add(self.Close, self)
    self.Btn_Reduce.OnClicked:Add(self.Reduce, self)
    self.Btn_Increase.OnClicked:Add(self.Increase, self)
    self.Btn_Increase10.OnClicked:Add(self.IncreaseTen, self)
    self.Btn_Increase100.OnClicked:Add(self.IncreaseHundred, self)
    self.Button_Buy.OnClicked:Add(self.OnConfirm, self)

    self.CurNum = 1
    self.MaxNum = 1
    self.ConfirmCallback = nil

    -- 娉ㄥ唽鍏ㄥ眬寮曠敤锛屼緵Client RPC鏌ユ壘
    _G.G_NumChoseInstance = self
    -- ugcprint("[NumChose] 鍏ㄥ眬寮曠敤宸叉敞鍐?_G.G_NumChoseInstance")

    -- 鍒濆闅愯棌锛堢瓑Show璋冪敤鏃舵墠鏄剧ず锛?    self:SetVisibility(ESlateVisibility.Collapsed)
    -- ugcprint("[NumChose] Construct 瀹屾垚")
end

function NumChose:Close()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function NumChose:Reduce()
    if self.CurNum > 1 then
        self:ChangeNum(self.CurNum - 1)
    end
end

function NumChose:Increase()
    if self.CurNum < self.MaxNum then
        self:ChangeNum(self.CurNum + 1)
    end
end

function NumChose:IncreaseTen()
    local Num = math.min(self.CurNum + 10, self.MaxNum)
    self:ChangeNum(Num)
end

function NumChose:IncreaseHundred()
    local Num = math.min(self.CurNum + 100, self.MaxNum)
    self:ChangeNum(Num)
end

function NumChose:ChangeNum(Num)
    self.CurNum = Num
    self.TextBlock_Count:SetText(string.format("%d/%d", self.CurNum, self.MaxNum))

    if self.CurNum <= 1 then
        self.WidgetSwitcher_Reduce:SetActiveWidgetIndex(1)
    else
        self.WidgetSwitcher_Reduce:SetActiveWidgetIndex(0)
    end

    if self.CurNum >= self.MaxNum then
        self.WidgetSwitcher_Increase:SetActiveWidgetIndex(1)
    else
        self.WidgetSwitcher_Increase:SetActiveWidgetIndex(0)
    end
end

--- 纭鎸夐挳鍥炶皟
function NumChose:OnConfirm()
    -- ugcprint("[NumChose] 纭浣跨敤鏁伴噺: " .. tostring(self.CurNum))
    -- ugcprint("[NumChose] ConfirmCallback=" .. tostring(self.ConfirmCallback) .. " type=" .. type(self.ConfirmCallback))
    if self.ConfirmCallback then
        local ok, err = pcall(self.ConfirmCallback, self.CurNum)
        if not ok then
            -- ugcprint("[NumChose] ConfirmCallback鎵ц鍑洪敊: " .. tostring(err))
        else
            -- ugcprint("[NumChose] ConfirmCallback鎵ц鎴愬姛")
        end
    else
        -- ugcprint("[NumChose] 璀﹀憡锛欳onfirmCallback涓簄il锛屾湭鎵ц浠讳綍鎿嶄綔")
    end
    self:Close()
end

--- 鍒濆鍖栧苟鏄剧ず鏁伴噺閫夋嫨鍣?---@param MaxNum number 鏈€澶у彲閫夋暟閲?---@param Callback function 纭鍥炶皟锛屽弬鏁颁负閫夋嫨鐨勬暟閲?---@param ItemID number|nil 鐗╁搧铏氭嫙ID锛堝彲閫夛級锛岀敤浜庢樉绀虹墿鍝佸浘鏍囥€佸悕绉板拰鎻忚堪
function NumChose:Show(MaxNum, Callback, ItemID)
    self.MaxNum = math.max(MaxNum, 1)
    self.CurNum = 1
    self.ConfirmCallback = Callback
    self:ChangeNum(1)

    -- 鍚屾鐗╁搧淇℃伅锛堝浘鏍囥€佸悕绉般€佹弿杩帮級
    if ItemID then
        self:SetItemInfo(ItemID)
    end

    self:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    -- ugcprint("[NumChose] 鏄剧ず鏁伴噺閫夋嫨鍣? 鏈€澶ф暟閲? " .. tostring(self.MaxNum) .. ", ItemID: " .. tostring(ItemID))
end

--- 璁剧疆鐗╁搧淇℃伅锛堝浘鏍囥€佸悕绉般€佹弿杩帮級
---@param itemID number 鐗╁搧ID锛堟敮鎸佽櫄鎷熺墿鍝両D鎴栫粡鍏哥墿鍝両D锛?function NumChose:SetItemInfo(itemID)
    -- ugcprint("[NumChose] SetItemInfo, 鐗╁搧ID: " .. tostring(itemID))

    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    
    -- 鍏堝皾璇曠洿鎺ョ敤铏氭嫙鐗╁搧ID鏌?    local itemConfig = UGCGameData.GetItemConfig(itemID)
    
    -- 濡傛灉鎵句笉鍒帮紝鍙兘鏄粡鍏哥墿鍝両D锛屽弽鏌ユ槧灏勮〃
    if not itemConfig then
        -- ugcprint("[NumChose] 铏氭嫙ID鏈壘鍒帮紝灏濊瘯鍙嶆煡鏄犲皠琛?)
        local allMapping = UGCGameData.GetAllItemMapping()
        if allMapping then
            for virtualID, mappingData in pairs(allMapping) do
                if mappingData["ClassicItemID"] == itemID then
                    -- ugcprint("[NumChose] 鎵惧埌鏄犲皠: 缁忓吀ID " .. tostring(itemID) .. " -> 铏氭嫙ID " .. tostring(virtualID))
                    itemConfig = UGCGameData.GetItemConfig(virtualID)
                    break
                end
            end
        end
    end

    if not itemConfig then
        -- ugcprint("[NumChose] 鏈壘鍒扮墿鍝侀厤缃? ID: " .. tostring(itemID))
        return
    end

    -- 璁剧疆鐗╁搧鍚嶇О
    if self.Name1 and itemConfig.ItemName then
        self.Name1:SetText(tostring(itemConfig.ItemName))
        -- ugcprint("[NumChose] 鐗╁搧鍚嶇О: " .. tostring(itemConfig.ItemName))
    end

    -- 璁剧疆鐗╁搧鎻忚堪
    if self.TextBlock_Describe and itemConfig.ItemDesc then
        self.TextBlock_Describe:SetText(tostring(itemConfig.ItemDesc))
        -- ugcprint("[NumChose] 鐗╁搧鎻忚堪: " .. tostring(itemConfig.ItemDesc))
    end

    -- 璁剧疆鐗╁搧鍥炬爣
    if self.Image_Icon and itemConfig.ItemSmallIcon then
        local pathString = UGCObjectUtility.GetPathBySoftObjectPath(itemConfig.ItemSmallIcon)
        if pathString and pathString ~= "" then
            local IconTexture = UGCObjectUtility.LoadObject(pathString)
            if IconTexture then
                self.Image_Icon:SetBrushFromTexture(IconTexture)
                -- ugcprint("[NumChose] 鐗╁搧鍥炬爣璁剧疆鎴愬姛")
            else
                -- ugcprint("[NumChose] 鐗╁搧鍥炬爣鍔犺浇澶辫触, 璺緞: " .. tostring(pathString))
            end
        end
    end
end

return NumChose
