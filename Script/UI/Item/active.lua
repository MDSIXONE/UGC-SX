---@class active_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_cancel UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field Image_3 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field WidgetSwitcher_0 UWidgetSwitcher
---@field WrapBox_0 UWrapBox
---@field WrapBox_1 UWrapBox
--Edit Below--
local active = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
UGCGameSystem.UGCRequire("ExtendResource.SignInEvent.OfficialPackage." .. "Script.SignInEvent.SignInEventManager")
local SignInEventMainUIPath = 'ExtendResource/SignInEvent/OfficialPackage/Asset/SignInEvent/Arts_UI/UIBP/SignInEvent_Main_UIBP.SignInEvent_Main_UIBP_C'

active.SignInEventMainUI = nil

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
        if MainControlPanel.MainControlBaseUI then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        end
        if MainControlPanel.ShootingUIPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end
    self:SwitchTab(0)
end

function active:OnCancelClicked()
    self:SetVisibility(ESlateVisibility.Collapsed)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        if MainControlPanel.MainControlBaseUI then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        end
        if MainControlPanel.ShootingUIPanel then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
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
    elseif index == 1 then
        self:InitSignInEventMainUI()
    end
end

function active:InitSignInEventMainUI()
    if not self.WrapBox_1 then
        return
    end

    if self.SignInEventMainUI and UGCObjectUtility.IsObjectValid(self.SignInEventMainUI) then
        if self.SignInEventMainUI.Refresh then
            pcall(function()
                self.SignInEventMainUI:Refresh()
            end)
        end
        self.SignInEventMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        return
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return
    end

    local signInEventMainUI = nil

    if playerController.SignInEventComponent and UGCObjectUtility.IsObjectValid(playerController.SignInEventComponent) then
        signInEventMainUI = playerController.SignInEventComponent.MainUI
    elseif SignInEventManager and SignInEventManager.GetSignInEventComponent then
        local signInEventComponent = SignInEventManager:GetSignInEventComponent(playerController)
        if signInEventComponent and UGCObjectUtility.IsObjectValid(signInEventComponent) then
            signInEventMainUI = signInEventComponent.MainUI
        end
    end

    if not (signInEventMainUI and UGCObjectUtility.IsObjectValid(signInEventMainUI)) then
        local SignInEventMainClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath(SignInEventMainUIPath))
        if SignInEventMainClass then
            signInEventMainUI = UserWidget.NewWidgetObjectBP(playerController, SignInEventMainClass)
        end
    end

    if not signInEventMainUI then
        UGCTimerUtility.CreateLuaTimer(0.3,
            function()
                if self and self.InitSignInEventMainUI then
                    self:InitSignInEventMainUI()
                end
            end,
            false,
            "active_signin_retry_" .. tostring(self)
        )
        return
    end

    self.WrapBox_1:ClearChildren()
    self.WrapBox_1:AddChild(signInEventMainUI)
    if signInEventMainUI.Refresh then
        pcall(function()
            signInEventMainUI:Refresh()
        end)
    end
    signInEventMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.SignInEventMainUI = signInEventMainUI
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

    -- Normalize each row to keep UI and server checks consistent.
    local sortedRows = {}
    for rowName, _ in pairs(allConfig) do
        local rowIndex = tonumber(rowName)
        if rowIndex and rowIndex > 0 then
            local normalizedConfig = UGCGameData.GetChongzhiRewardConfig(rowIndex)
            if normalizedConfig then
                table.insert(sortedRows, { rowIndex = rowIndex, config = normalizedConfig })
            end
        end
    end

    if #sortedRows <= 0 then
        return
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
            local claimed = claimedMap[rowData.rowIndex] or claimedMap[tostring(rowData.rowIndex)] or false
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
        local normalizedMap = {}
        for key, value in pairs(playerState.ClaimedChongzhi) do
            local keyID = tonumber(key)
            if keyID and (value == true or value == 1 or value == "1" or value == "true") then
                normalizedMap[keyID] = true
            end

            local valueID = tonumber(value)
            if valueID and valueID > 0 then
                normalizedMap[valueID] = true
            end
        end
        return normalizedMap
    end
    return {}
end

function active:Destruct()
    self.SignInEventMainUI = nil
end

return active
