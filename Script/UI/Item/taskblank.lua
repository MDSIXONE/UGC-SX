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
    -- Related UI logic.
    self:SetVisibility(ESlateVisibility.Collapsed)
    -- Related UI logic.
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.TASK then
        pc.MMainUI.TASK:SetVisibility(ESlateVisibility.Visible)
        -- Related UI logic.
        if pc.MMainUI.TASK.RefreshTaskUI then
            pc.MMainUI.TASK:RefreshTaskUI()
        end
        -- Related UI logic.
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
