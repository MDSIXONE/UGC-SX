---@class Numchoose_C:UUserWidget
---@field Btn_Increase UButton
---@field Btn_Increase10 UButton
---@field Btn_Increase100 UButton
---@field Btn_Reduce UButton
---@field BtnClose UButton
---@field Button_Buy UButton
---@field Image_Icon UImage
---@field Name1 UTextBlock
---@field TextBlock_Count UTextBlock
---@field TextBlock_Describe UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_Increase UWidgetSwitcher
---@field WidgetSwitcher_Reduce UWidgetSwitcher
--Edit Below--
local Numchoose = { bInitDoOnce = false }

function Numchoose:Construct()
    self.BtnClose.OnClicked:Add(self.Close, self)
    self.Btn_Reduce.OnClicked:Add(self.Reduce, self)
    self.Btn_Increase.OnClicked:Add(self.Increase, self)
    self.Btn_Increase10.OnClicked:Add(self.IncreaseTen, self)
    self.Btn_Increase100.OnClicked:Add(self.IncreaseHundred, self)
    self.Button_Buy.OnClicked:Add(self.OnConfirm, self)

    self.CurNum = 1
    self.MaxNum = 1
    self.ConfirmCallback = nil
end

function Numchoose:Close()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function Numchoose:Reduce()
    if self.CurNum > 1 then
        self:ChangeNum(self.CurNum - 1)
    end
end

function Numchoose:Increase()
    if self.CurNum < self.MaxNum then
        self:ChangeNum(self.CurNum + 1)
    end
end

function Numchoose:IncreaseTen()
    local Num = math.min(self.CurNum + 10, self.MaxNum)
    self:ChangeNum(Num)
end

function Numchoose:IncreaseHundred()
    local Num = math.min(self.CurNum + 100, self.MaxNum)
    self:ChangeNum(Num)
end

function Numchoose:ChangeNum(Num)
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
function Numchoose:OnConfirm()
    -- ugcprint("[Numchoose] 纭浣跨敤鏁伴噺: " .. tostring(self.CurNum))
    if self.ConfirmCallback then
        self.ConfirmCallback(self.CurNum)
    end
    self:Close()
end

--- 鍒濆鍖栧苟鏄剧ず鏁伴噺閫夋嫨鍣?---@param MaxNum number 鏈€澶у彲閫夋暟閲?---@param Callback function 纭鍥炶皟锛屽弬鏁颁负閫夋嫨鐨勬暟閲?---@param ItemID number|nil 鐗╁搧铏氭嫙ID锛堝彲閫夛級锛岀敤浜庢樉绀虹墿鍝佸浘鏍囥€佸悕绉板拰鎻忚堪
function Numchoose:Show(MaxNum, Callback, ItemID)
    self.MaxNum = math.max(MaxNum, 1)
    self.CurNum = 1
    self.ConfirmCallback = Callback
    self:ChangeNum(1)

    -- 鍚屾鐗╁搧淇℃伅锛堝浘鏍囥€佸悕绉般€佹弿杩帮級
    if ItemID then
        self:SetItemInfo(ItemID)
    end

    self:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    -- ugcprint("[Numchoose] 鏄剧ず鏁伴噺閫夋嫨鍣? 鏈€澶ф暟閲? " .. tostring(self.MaxNum) .. ", ItemID: " .. tostring(ItemID))
end

--- 璁剧疆鐗╁搧淇℃伅锛堝浘鏍囥€佸悕绉般€佹弿杩帮級
---@param itemID number 鐗╁搧ID锛堟敮鎸佽櫄鎷熺墿鍝両D鎴栫粡鍏哥墿鍝両D锛?function Numchoose:SetItemInfo(itemID)
    -- ugcprint("[Numchoose] SetItemInfo, 鐗╁搧ID: " .. tostring(itemID))

    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    
    -- 鍏堝皾璇曠洿鎺ョ敤铏氭嫙鐗╁搧ID鏌?    local itemConfig = UGCGameData.GetItemConfig(itemID)
    
    -- 濡傛灉鎵句笉鍒帮紝鍙兘鏄粡鍏哥墿鍝両D锛屽弽鏌ユ槧灏勮〃
    if not itemConfig then
        -- ugcprint("[Numchoose] 铏氭嫙ID鏈壘鍒帮紝灏濊瘯鍙嶆煡鏄犲皠琛?)
        local allMapping = UGCGameData.GetAllItemMapping()
        if allMapping then
            for virtualID, mappingData in pairs(allMapping) do
                if mappingData["ClassicItemID"] == itemID then
                    -- ugcprint("[Numchoose] 鎵惧埌鏄犲皠: 缁忓吀ID " .. tostring(itemID) .. " -> 铏氭嫙ID " .. tostring(virtualID))
                    itemConfig = UGCGameData.GetItemConfig(virtualID)
                    break
                end
            end
        end
    end

    if not itemConfig then
        -- ugcprint("[Numchoose] 鏈壘鍒扮墿鍝侀厤缃? ID: " .. tostring(itemID))
        return
    end

    -- 璁剧疆鐗╁搧鍚嶇О
    if self.Name1 and itemConfig.ItemName then
        self.Name1:SetText(tostring(itemConfig.ItemName))
    end

    -- 璁剧疆鐗╁搧鎻忚堪
    if self.TextBlock_Describe and itemConfig.ItemDesc then
        self.TextBlock_Describe:SetText(tostring(itemConfig.ItemDesc))
    end

    -- 璁剧疆鐗╁搧鍥炬爣
    if self.Image_Icon and itemConfig.ItemSmallIcon then
        local pathString = UGCObjectUtility.GetPathBySoftObjectPath(itemConfig.ItemSmallIcon)
        if pathString and pathString ~= "" then
            local IconTexture = UGCObjectUtility.LoadObject(pathString)
            if IconTexture then
                self.Image_Icon:SetBrushFromTexture(IconTexture)
            end
        end
    end
end

return Numchoose
