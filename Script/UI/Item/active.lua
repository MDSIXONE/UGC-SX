---@class active_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_cancel UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field WidgetSwitcher_0 UWidgetSwitcher
---@field WrapBox_0 UWrapBox
--Edit Below--
local active = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function active:Construct()
    self:LuaInit()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function active:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true

    if self.Button_cancel then
        self.Button_cancel.OnClicked:Add(self.OnCancelClicked, self)
    end
    if self.Button_0 then
        self.Button_0.OnClicked:Add(function() self:SwitchTab(0) end, self)
    end
    if self.Button_1 then
        self.Button_1.OnClicked:Add(function() self:SwitchTab(1) end, self)
    end
    if self.Button_2 then
        self.Button_2.OnClicked:Add(function() self:SwitchTab(2) end, self)
    end
end

function active:Show()
    self:SetVisibility(ESlateVisibility.Visible)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end
    -- Execute the next UI update step.
    self:SwitchTab(0)
end

function active:OnCancelClicked()
    self:SetVisibility(ESlateVisibility.Collapsed)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end
end

function active:SwitchTab(index)
    if self.WidgetSwitcher_0 then
        self.WidgetSwitcher_0:SetActiveWidgetIndex(index)
    end
    -- Guard condition before running this branch.
    if index == 0 then
        self:RefreshBuySlots()
    end
end

-- Get current spend.
function active:GetCurrentSpend()
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        if playerState.UGCSpendCount ~= nil then
            return tonumber(playerState.UGCSpendCount) or 0
        end
        if playerState.GetTotalSpendCount then
            return tonumber(playerState:GetTotalSpendCount()) or 0
        end
        if playerState.TotalSpendCount ~= nil then
            return tonumber(playerState.TotalSpendCount) or 0
        end
        return tonumber(playerState.SpendCount) or 0
    end
    return 0
end

-- Refresh buy slots.
function active:RefreshBuySlots()
    if not self.WrapBox_0 then
        -- Exit early when requirements are not met.
        return
    end
    self.WrapBox_0:ClearChildren()

    local allConfig = UGCGameData.GetAllChongzhiConfig()
    if not allConfig then
        -- Exit early when requirements are not met.
        return
    end

    -- Configuration table used by this widget.
    local sortedRows = {}
    for rowName, config in pairs(allConfig) do
        table.insert(sortedRows, { rowIndex = tonumber(rowName), config = config })
    end
    table.sort(sortedRows, function(a, b) return a.rowIndex < b.rowIndex end)

    local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/buyslot.buyslot_C'))
    if not SlotClass then
        -- Exit early when requirements are not met.
        return
    end

    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then return end

    local currentSpend = self:GetCurrentSpend()
    local claimedMap = self:GetClaimedChongzhi()

    for _, rowData in ipairs(sortedRows) do
        local slot = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
        if slot then
            self.WrapBox_0:AddChild(slot)
            local claimed = claimedMap[rowData.rowIndex] or false
            if slot.SetData then
                slot:SetData(rowData.rowIndex, rowData.config, currentSpend, claimed)
            end
            -- Keep this section consistent with the original UI flow.
        end
    end
end

-- Get claimed chongzhi.
function active:GetClaimedChongzhi()
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState and playerState.UGCClaimedChongzhiStr and playerState.DeserializeClaimedChongzhi then
        return playerState:DeserializeClaimedChongzhi(playerState.UGCClaimedChongzhiStr)
    end
    if playerState and playerState.ClaimedChongzhi then
        return playerState.ClaimedChongzhi
    end
    return {}
end

function active:Destruct()
end

return active
