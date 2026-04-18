---@class UIPanelToggles
---Shared UI panel visibility and widget layer management.

local UIPanelToggles = {}

---Apply or remove hidden layer from main UI and skill panels
function UIPanelToggles.ApplyWidgetLayer(visible)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        if visible then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        else
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        if visible then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
        else
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
        end
    end
end

---Show a panel and apply hidden layer
function UIPanelToggles.ShowPanel(panel)
    if not panel then return end
    panel:SetVisibility(ESlateVisibility.Visible)
    UIPanelToggles.ApplyWidgetLayer(true)
end

---Hide a panel and remove hidden layer
function UIPanelToggles.HidePanel(panel)
    if not panel then return end
    panel:SetVisibility(ESlateVisibility.Collapsed)
    UIPanelToggles.ApplyWidgetLayer(false)
end

---Toggle panel visibility with layer management
function UIPanelToggles.TogglePanel(panel)
    if not panel then return end
    local isCollapsed = panel:GetVisibility() == ESlateVisibility.Collapsed
    panel:SetVisibility(isCollapsed and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    UIPanelToggles.ApplyWidgetLayer(isCollapsed)
end

return UIPanelToggles
