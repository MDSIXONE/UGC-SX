---@class UIPanelToggles
---Shared UI panel visibility and widget layer management.
---
--- UI 面板可见性和 Widget 层级管理工具模块
--- 本模块提供统一的接口来管理游戏 UI 面板的显示/隐藏操作
--- 主要功能：
---   1. 管理主 UI（MainControlBaseUI、ShootingUIPanel）的可见性层级
---   2. 管理技能面板（SkillRootPanel）的可见性层级
---   3. 提供统一的 Show/Hide/Toggle 接口
---
--- 使用场景：当打开某个 UI 面板时，需要遮挡游戏画面（添加隐藏层），
---          关闭面板时移除隐藏层恢复游戏画面

local UIPanelToggles = {}

--------------------------------------------------------------------------------
--- ApplyWidgetLayer：应用或移除游戏画面隐藏层
---
--- 功能说明：
---   当打开某些特殊 UI 面板（如设置面板、背包等）时，需要遮挡游戏画面，
---   防止玩家在面板打开期间进行游戏操作。本函数通过添加/移除隐藏层来实现。
---
--- 参数说明：
---   @param visible boolean - true 表示添加隐藏层（遮挡游戏画面），false 表示移除隐藏层（恢复游戏画面）
---
--- 影响的面板：
---   - MainControlBaseUI：主控制面板（基础 UI 控件容器）
---   - ShootingUIPanel：射击 UI 面板（射击相关 UI 元素）
---   - SkillRootPanel：技能根面板（所有技能 UI 的父级容器）
---
--- 实现逻辑：
---   visible = true  → 调用 AddWidgetHiddenLayer 添加隐藏层
---   visible = false → 调用 SubWidgetHiddenLayer 移除隐藏层
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
--- ShowPanel：显示指定面板并遮挡游戏画面
---
--- 功能说明：
---   统一显示 UI 面板的接口，同时应用隐藏层来遮挡游戏画面。
---   适用于打开设置、背包、任务等需要玩家专注查看的面板。
---
--- 参数说明：
---   @param panel userdata - 要显示的面板对象（UMG Widget 实例）
---
--- 处理逻辑：
---   1. 空值检查：如果 panel 为 nil，直接返回不做任何操作
---   2. 设置可见性：将面板 visibility 设置为 Visible
---   3. 应用隐藏层：调用 ApplyWidgetLayer(true) 遮挡游戏画面
--------------------------------------------------------------------------------
function UIPanelToggles.ShowPanel(panel)
    if not panel then return end
    panel:SetVisibility(ESlateVisibility.Visible)
    UIPanelToggles.ApplyWidgetLayer(true)
end

--------------------------------------------------------------------------------
--- HidePanel：隐藏指定面板并恢复游戏画面
---
--- 功能说明：
---   统一隐藏 UI 面板的接口，同时移除隐藏层来恢复游戏画面。
---   适用于关闭设置、背包、任务等面板后需要恢复游戏操作。
---
--- 参数说明：
---   @param panel userdata - 要隐藏的面板对象（UMG Widget 实例）
---
--- 处理逻辑：
---   1. 空值检查：如果 panel 为 nil，直接返回不做任何操作
---   2. 设置可见性：将面板 visibility 设置为 Collapsed（隐藏）
---   3. 移除隐藏层：调用 ApplyWidgetLayer(false) 恢复游戏画面
--------------------------------------------------------------------------------
function UIPanelToggles.HidePanel(panel)
    if not panel then return end
    panel:SetVisibility(ESlateVisibility.Collapsed)
    UIPanelToggles.ApplyWidgetLayer(false)
end

--------------------------------------------------------------------------------
--- TogglePanel：根据当前可见性切换面板状态
---
--- 功能说明：
---   切换 UI 面板的显示/隐藏状态。如果面板当前是隐藏的则显示它，
---   如果当前是显示的则隐藏它。同时自动管理隐藏层的应用/移除。
---
--- 参数说明：
---   @param panel userdata - 要切换的面板对象（UMG Widget 实例）
---
--- 处理逻辑：
---   1. 空值检查：如果 panel 为 nil，直接返回不做任何操作
---   2. 判断当前状态：检查面板 visibility 是否为 Collapsed
---   3. 切换可见性：
---      - 当前为隐藏 → 设置为 Visible，并应用隐藏层
---      - 当前为显示 → 设置为 Collapsed，并移除隐藏层
--------------------------------------------------------------------------------
function UIPanelToggles.TogglePanel(panel)
    if not panel then return end
    local isCollapsed = panel:GetVisibility() == ESlateVisibility.Collapsed
    panel:SetVisibility(isCollapsed and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    UIPanelToggles.ApplyWidgetLayer(isCollapsed)
end

return UIPanelToggles
