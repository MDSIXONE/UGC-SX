---@class wujingjiange_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_5 UButton
---@field Button_6 UButton
---@field Button_8 UButton
---@field Button_9 UButton
---@field Button_10 UButton
---@field Button_11 UButton
---@field cancel UButton
---@field cengshu UTextBlock
---@field day UTextBlock
---@field get1 UButton
---@field get2 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_8 UImage
---@field Image_9 UImage
---@field Image_10 UImage
---@field Image_11 UImage
---@field Image_12 UImage
---@field START UButton
---@field state100 UTextBlock
---@field state1000 UTextBlock
---@field state200 UTextBlock
---@field state300 UTextBlock
---@field state400 UTextBlock
---@field state500 UTextBlock
---@field state600 UTextBlock
---@field state700 UTextBlock
---@field state800 UTextBlock
---@field state900 UTextBlock
---@field TextBlock_5 UTextBlock
--Edit Below--
local wujingjiange = { bInitDoOnce = false, bFullScreenLayerApplied = false }

-- Configuration table used by this widget.
local FLOOR_REWARD_CONFIG = {
    [100] = 100, [200] = 200, [300] = 300, [400] = 400, [500] = 500,
    [600] = 600, [700] = 700, [800] = 800, [900] = 900, [1000] = 1000,
}

-- Configuration table used by this widget.
local FLOOR_STATE_MAP = {
    [100] = "state100", [200] = "state200", [300] = "state300", [400] = "state400", [500] = "state500",
    [600] = "state600", [700] = "state700", [800] = "state800", [900] = "state900", [1000] = "state1000",
}

function wujingjiange:Construct()
    self:LuaInit()
    self:SetVisibility(ESlateVisibility.Visible)
end

function wujingjiange:ApplyFullScreenLayer()
    if self.bFullScreenLayerApplied then
        return
    end

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

    self.bFullScreenLayerApplied = true
end

function wujingjiange:ReleaseFullScreenLayer()
    if not self.bFullScreenLayerApplied then
        return
    end

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

    self.bFullScreenLayerApplied = false
end

function wujingjiange:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.START then
        self.START.OnClicked:Add(self.OnStartClicked, self)
    end
    if self.cancel then
        self.cancel.OnClicked:Add(self.OnCancelClicked, self)
    end
    -- Guard condition before running this branch.
    if self.get1 then
        self.get1.OnClicked:Add(self.OnGet1Clicked, self)
    end
    -- Guard condition before running this branch.
    if self.get2 then
        self.get2.OnClicked:Add(self.OnGet2Clicked, self)
    end

    -- Keep this section consistent with the original UI flow.
    self.SelectedFloor = 100
    local buttonFloorMap = {
        {btn = "Button_0", floor = 100},
        {btn = "Button_1", floor = 200},
        {btn = "Button_2", floor = 300},
        {btn = "Button_3", floor = 400},
        {btn = "Button_5", floor = 500},
        {btn = "Button_6", floor = 600},
        {btn = "Button_8", floor = 700},
        {btn = "Button_9", floor = 800},
        {btn = "Button_10", floor = 900},
        {btn = "Button_11", floor = 1000},
    }
    for _, mapping in ipairs(buttonFloorMap) do
        local btn = self[mapping.btn]
        local floor = mapping.floor
        if btn then
            btn.OnClicked:Add(function()
                self.SelectedFloor = floor
                -- Refresh UI to match current data state.
                self:RefreshRewardStates()
            end, self)
        end
    end
end

function wujingjiange:Show()
    self:SetVisibility(ESlateVisibility.Visible)
    self:UpdateFloorText()
    self:RefreshRewardStates()
    self:ApplyFullScreenLayer()
end

-- Update floor text.
function wujingjiange:UpdateFloorText()
    if not self.cengshu then
        -- Exit early when requirements are not met.
        return
    end

    local floor = 0
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        floor = (PC.JiangeFloor or 0) + 1
    end
    self.cengshu:SetText(tostring(floor))
    -- Keep this section consistent with the original UI flow.
end

function wujingjiange:OnCancelClicked()
    self:ReleaseFullScreenLayer()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function wujingjiange:OnStartClicked()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then
        -- Exit early when requirements are not met.
        return
    end

    -- Local helper value for this logic block.
    local needTip = false
    if PC.MMainUI then
        -- Local helper value for this logic block.
        local jiangeUI = PC.MMainUI.jiange
        if jiangeUI and jiangeUI.IsWearing then
            jiangeUI:ApplySkill(false)
            jiangeUI:ApplyAtkBonus(false)
            jiangeUI.IsWearing = false
			if jiangeUI.weartip then jiangeUI.weartip:SetText("穿戴") end
            -- Keep this section consistent with the original UI flow.
            needTip = true
        end
        -- Local helper value for this logic block.
        local shenyinUI = PC.MMainUI.shenyin
        if shenyinUI and shenyinUI.CurrentWearing then
            local wearingBtn = shenyinUI.CurrentWearing
            local pair = shenyinUI:GetPairByButton(wearingBtn)
            if pair then
                shenyinUI.SlotStates[wearingBtn] = "unwear"
                shenyinUI.CurrentWearing = nil
                if pair.border and shenyinUI[pair.border] then
                    shenyinUI[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
                end
                shenyinUI:ApplySkill(pair.skill, false, shenyinUI.SlotQualities[wearingBtn])
                shenyinUI.CurrentEcexpBonus = 0
                shenyinUI:ApplyEcexp(0)
            end
            -- Keep this section consistent with the original UI flow.
            needTip = true
        end

        -- Local helper value for this logic block.
        local playerState = UGCGameSystem.GetLocalPlayerState()
        local bloodlineEnabled = false
        if playerState then
            if playerState.UGCBloodlineEnabled ~= nil then
                bloodlineEnabled = (playerState.UGCBloodlineEnabled == true)
            elseif playerState.GameData then
                bloodlineEnabled = (playerState.GameData.BloodlineEnabled == true)
            end
        end

        if bloodlineEnabled then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SetBloodlineEnabled", false)

            if PC.MMainUI.xuemai then
                PC.MMainUI.xuemai.bBloodlineEnabled = false
                if PC.MMainUI.xuemai.UpdateImages then
                    PC.MMainUI.xuemai:UpdateImages()
                end
            end

            -- Keep this section consistent with the original UI flow.
            needTip = true
        end
    end

    if needTip then
        -- Guard condition before running this branch.
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("进入剑阁前已自动卸下当前装备并关闭血脉")
        end
        UGCTimerUtility.CreateLuaTimer(2.0, function()
            self:DoEnterJiange(PC)
        end, false, "WujingJiange_DelayEnter")
    else
        -- Execute the next UI update step.
        self:DoEnterJiange(PC)
    end
end

-- Do enter jiange.
function wujingjiange:DoEnterJiange(PC)
    if not PC then return end
    -- Keep this section consistent with the original UI flow.
    -- Keep this section consistent with the original UI flow.
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_EnterJiangeInstance")
    -- Configure initial widget visibility.
    self:SetVisibility(ESlateVisibility.Collapsed)

    -- Execute the next UI update step.
    self:ReleaseFullScreenLayer()

    -- Execute the next UI update step.
    self:SwitchToJiangeUI(PC)
end

-- Switch to jiange ui.
function wujingjiange:SwitchToJiangeUI(PC)
    if not PC then return end

    -- Guard condition before running this branch.
    if PC.MMainUI then
        PC.MMainUI:SetVisibility(ESlateVisibility.Collapsed)
        -- Continue applying initial visibility settings.
    end

    -- Guard condition before running this branch.
    if not PC.JiangeUI then
        local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
        local jiangeUI = UGCGameData.GetUI(PC, "JiangeUI")
        if jiangeUI then
            PC.JiangeUI = jiangeUI
            jiangeUI:AddToViewport(1100)
            -- Keep this section consistent with the original UI flow.
        else
            -- Keep this section consistent with the original UI flow.
        end
    else
        PC.JiangeUI:SetVisibility(ESlateVisibility.Visible)
        if PC.JiangeUI.UpdateFloorText then
            PC.JiangeUI:UpdateFloorText()
        end
        -- Keep this section consistent with the original UI flow.
    end
end

-- Parse claimed floors.
function wujingjiange:ParseClaimedFloors()
    local PC = UGCGameSystem.GetLocalPlayerController()
    local str = PC and PC.JiangeClaimedFloors or ""
    local claimed = {}
    if str ~= "" then
        for s in string.gmatch(str, "([^,]+)") do
            local n = tonumber(s)
            if n then claimed[n] = true end
        end
    end
    return claimed
end

-- Refresh reward states.
function wujingjiange:RefreshRewardStates()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    local playerFloor = PC.JiangeFloor or 0
    local claimed = self:ParseClaimedFloors()

    -- Iterate through related data or widgets.
    for floor, stateName in pairs(FLOOR_STATE_MAP) do
        local stateWidget = self[stateName]
        if stateWidget then
            if claimed[floor] then
                stateWidget:SetText("已领取")
            elseif playerFloor >= floor then
                stateWidget:SetText("可领取")
            else
                stateWidget:SetText(tostring(floor) .. "层")
            end
        end
    end

    -- Local helper value for this logic block.
    local dailyAmount = PC.JiangeDailyAmount or 1
    if self.day then
        self.day:SetText(tostring(dailyAmount) .. "*")
    end

    -- Keep this section consistent with the original UI flow.
end

-- Handle get1 button click.
function wujingjiange:OnGet1Clicked()
    -- Acquire local player references.
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    -- Guard condition before running this branch.
    if self.DailyClaimPending then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("每日奖励领取中，请稍候...")
        end
        return
    end

    -- Local helper value for this logic block.
    local today = os.date("%Y-%m-%d")
    local lastDate = PC.JiangeDailyClaimDate or ""
    if lastDate == today then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("今日已领取过每日奖励")
        end
        -- Exit early when requirements are not met.
        return
    end

    -- Local helper value for this logic block.
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        self.DailyClaimPending = true
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimJiangeDailyReward")
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("已发送每日奖励领取请求")
        end
        -- Keep this section consistent with the original UI flow.
    else
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("领取失败，请稍后再试")
        end
    end
end

-- Handle get2 button click.
function wujingjiange:OnGet2Clicked()
    local targetFloor = self.SelectedFloor or 100
    -- Acquire local player references.

    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    if self.FloorClaimPending then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("层奖励领取中，请稍候...")
        end
        return
    end

    local playerFloor = PC.JiangeFloor or 0

    -- Guard condition before running this branch.
    if playerFloor < targetFloor then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("当前层数不足，无法领取该层奖励")
        end
        -- Exit early when requirements are not met.
        return
    end

    -- Local helper value for this logic block.
    local claimed = self:ParseClaimedFloors()
    if claimed[targetFloor] then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("该层奖励已领取")
        end
        -- Exit early when requirements are not met.
        return
    end

    -- Local helper value for this logic block.
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        self.FloorClaimPending = true
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimJiangeFloorReward", targetFloor)
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("已发送层奖励领取请求")
        end
        -- Keep this section consistent with the original UI flow.
    end
end

function wujingjiange:Destruct()
    self:ReleaseFullScreenLayer()
end

return wujingjiange
