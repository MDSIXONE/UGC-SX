---@class TASK_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_cancel UButton
---@field Image_95 UImage
---@field WrapBox_0 UWrapBox
--Edit Below--
local TASK = { bInitDoOnce = false, bFullScreenLayerApplied = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

-- Configuration table used by this widget.
local TASK_STATUS_TEXT = {
    [0] = "未完成",
    [1] = "可领取",
    [2] = "已领取"
}

function TASK:Construct()
    self:LuaInit()
    self.CurrentPage = 0

    if self.Button_cancel then
        self.Button_cancel.OnClicked:Add(self.OnCancelClicked, self)
    end
    -- Guard condition before running this branch.
    if self.Button_0 then
        self.Button_0.OnClicked:Add(function() self:SwitchPage(0) end, self)
    end
    if self.Button_1 then
        self.Button_1.OnClicked:Add(function() self:SwitchPage(1) end, self)
    end
    if self.Button_2 then
        self.Button_2.OnClicked:Add(function() self:SwitchPage(2) end, self)
    end

    self:RefreshTaskUI()
end

function TASK:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
end

function TASK:ApplyFullScreenLayer()
    if self.bFullScreenLayerApplied then
        return
    end

    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end

    self.bFullScreenLayerApplied = true
end

function TASK:ReleaseFullScreenLayer()
    if not self.bFullScreenLayerApplied then
        return
    end

    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end

    self.bFullScreenLayerApplied = false
end

function TASK:ShowPanel()
    self:SetVisibility(ESlateVisibility.Visible)
    self:RefreshTaskUI()
    self:ApplyFullScreenLayer()
end

function TASK:HidePanel()
    self:ReleaseFullScreenLayer()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

-- Switch page.
function TASK:SwitchPage(pageIndex)
    if self.CurrentPage == pageIndex then return end
    self.CurrentPage = pageIndex
    -- Refresh UI to match current data state.
    self:RefreshTaskUI()
end

--- Refresh task ui.
function TASK:RefreshTaskUI()
    if not self.WrapBox_0 then
        -- Exit early when requirements are not met.
        return
    end
    self.WrapBox_0:ClearChildren()

    local playerState = self:GetLocalPlayerState()
    if not playerState or not playerState.GetTaskStatus then
        -- Exit early when requirements are not met.
        return
    end

    local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Taskslot.Taskslot_C'))
    if not SlotClass then
        -- Exit early when requirements are not met.
        return
    end

    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then return end

    -- Local helper value for this logic block.
    local allTasks = UGCGameData.GetAllTaskConfig()
    if not allTasks then
        -- Exit early when requirements are not met.
        return
    end

    -- Configuration table used by this widget.
    local pageTasks = {}
    for rowName, taskConfig in pairs(allTasks) do
        local taskPage = taskConfig.page or 0
        if taskPage == self.CurrentPage then
            table.insert(pageTasks, { rowIndex = tonumber(rowName), config = taskConfig })
        end
    end
    table.sort(pageTasks, function(a, b) return a.rowIndex < b.rowIndex end)

    local count = 0
    for _, taskData in ipairs(pageTasks) do
        local i = taskData.rowIndex
        local taskConfig = taskData.config
        local taskStatus = playerState:GetTaskStatus(i)

        local slot = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
        if slot then
            self.WrapBox_0:AddChild(slot)

            if slot.TextBlock_taskdetail then
                local desc = taskConfig.taskdetail or taskConfig.taskname or ("任务" .. tostring(i))
                slot.TextBlock_taskdetail:SetText(tostring(desc))
            end

            if slot.TextBlock_buttun then
                slot.TextBlock_buttun:SetText(TASK_STATUS_TEXT[taskStatus] or "未知")
            end

            if slot.Button_0 then
                slot.Button_0:SetIsEnabled(taskStatus == 1)
                local rowIndex = i
                slot.Button_0.OnClicked:Add(function()
                    self:OnTaskSlotClicked(rowIndex)
                end, self)
            end

            count = count + 1
            -- Keep this section consistent with the original UI flow.
        end
    end
    -- Keep this section consistent with the original UI flow.
end

-- Handle task slot button click.
function TASK:OnTaskSlotClicked(taskRowIndex)
    -- Local helper value for this logic block.
    local playerState = self:GetLocalPlayerState()
    if not playerState then return end

    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    if taskStatus ~= 1 then return end

    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end

function TASK:OnCancelClicked()
    self:HidePanel()
end

function TASK:GetLocalPlayerState()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        return UGCGameSystem.GetPlayerStateByPlayerController(pc)
    end
    return nil
end

function TASK:GetLocalPlayerPawn()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        return pc:K2_GetPawn()
    end
    return nil
end

-- Compatibility wrappers kept for parity with ExampleScript/UI/Item/TASK.lua.
function TASK:OnButton1Clicked()
    self:OnTaskSlotClicked(1)
end

function TASK:OnButton2Clicked()
    self:OnTaskSlotClicked(2)
end

function TASK:OnButton3Clicked()
    self:OnTaskSlotClicked(3)
end

function TASK:OnButton4Clicked()
    self:OnTaskSlotClicked(4)
end

function TASK:OnButton5Clicked()
    self:OnTaskSlotClicked(5)
end

function TASK:RefreshTask1(playerState)
    self:RefreshTaskUI()
end

function TASK:RefreshTask2(playerState)
    self:RefreshTaskUI()
end

function TASK:RefreshTask3(playerState)
    self:RefreshTaskUI()
end

function TASK:RefreshTask4(playerState)
    self:RefreshTaskUI()
end

function TASK:RefreshTask5(playerState)
    self:RefreshTaskUI()
end

function TASK:Destruct()
    self:ReleaseFullScreenLayer()
end

return TASK
