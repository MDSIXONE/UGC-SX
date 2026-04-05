---@class taskblank_C:UUserWidget
---@field Button_0 UButton
---@field Image_1 UImage
--Edit Below--
local taskblank = { bInitDoOnce = false }

function taskblank:Construct()
    self:LuaInit()
    self:SetVisibility(ESlateVisibility.Collapsed)
    UGCTimerUtility.CreateLuaTimer(2.0, function()
        local modeID = UGCMultiMode.GetModeID()
        if modeID and modeID == 1002 then
            self:SetVisibility(ESlateVisibility.Collapsed)
        end
    end, false, "taskblank_mode1002_hide")
end

function taskblank:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.Button_0 then
        self.Button_0.OnClicked:Add(self.OnButtonClicked, self)
    end
end

function taskblank:OnButtonClicked()
    -- 隐藏自己
    self:SetVisibility(ESlateVisibility.Collapsed)
    -- 打开TASK面板
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.TASK then
        pc.MMainUI.TASK:SetVisibility(ESlateVisibility.Visible)
        -- 刷新任务列表
        if pc.MMainUI.TASK.RefreshTaskUI then
            pc.MMainUI.TASK:RefreshTaskUI()
        end
        -- 隐藏主控制面板和技能面板
        local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
        if MainControlPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        if SkillPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
        end
    end
end

function taskblank:Destruct()
end

return taskblank
