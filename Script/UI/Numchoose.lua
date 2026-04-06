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

--- Confirm button callback.
function Numchoose:OnConfirm()
    -- ugcprint("[Numchoose] Confirm use count: " .. tostring(self.CurNum))
    if self.ConfirmCallback then
        self.ConfirmCallback(self.CurNum)
    end
    self:Close()
end

--- Initialize and show the quantity selector.
---@param MaxNum number Maximum selectable count.
---@param Callback function Confirm callback; receives selected count.
---@param ItemID number|nil Optional virtual item ID for icon/name/description display.
function Numchoose:Show(MaxNum, Callback, ItemID)
    self.MaxNum = math.max(MaxNum, 1)
    self.CurNum = 1
    self.ConfirmCallback = Callback
    self:ChangeNum(1)

    -- Sync item information (icon, name, description).
    if ItemID then
        self:SetItemInfo(ItemID)
    end

    self:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    -- ugcprint("[Numchoose] Show quantity selector, MaxNum: " .. tostring(self.MaxNum) .. ", ItemID: " .. tostring(ItemID))
end

--- Set item information (icon, name, description).
---@param itemID number Item ID (supports virtual ID or classic item ID).
function Numchoose:SetItemInfo(itemID)
    -- ugcprint("[Numchoose] SetItemInfo, ItemID: " .. tostring(itemID))

    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    
    -- Try direct lookup by virtual item ID first.
    local itemConfig = UGCGameData.GetItemConfig(itemID)
    
    -- If not found, it may be a classic item ID; reverse lookup from mapping table.
    if not itemConfig then
        -- ugcprint("[Numchoose] Virtual ID not found, trying reverse mapping")
        local allMapping = UGCGameData.GetAllItemMapping()
        if allMapping then
            for virtualID, mappingData in pairs(allMapping) do
                if mappingData["ClassicItemID"] == itemID then
                    -- ugcprint("[Numchoose] Mapping found: ClassicID " .. tostring(itemID) .. " -> VirtualID " .. tostring(virtualID))
                    itemConfig = UGCGameData.GetItemConfig(virtualID)
                    break
                end
            end
        end
    end

    if not itemConfig then
        -- ugcprint("[Numchoose] Item config not found, ID: " .. tostring(itemID))
        return
    end

    -- Set item name.
    if self.Name1 and itemConfig.ItemName then
        self.Name1:SetText(tostring(itemConfig.ItemName))
    end

    -- Set item description.
    if self.TextBlock_Describe and itemConfig.ItemDesc then
        self.TextBlock_Describe:SetText(tostring(itemConfig.ItemDesc))
    end

    -- Set item icon.
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
