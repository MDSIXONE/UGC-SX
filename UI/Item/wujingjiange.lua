---@class wujingjiange_C:UUserWidget
---@field Button_4 UButton
---@field cancel UButton
---@field cengshu UTextBlock
---@field get1 UButton
---@field Image_0 UImage
---@field START UButton
--Edit Below--
local wujingjiange = { bInitDoOnce = false }

function wujingjiange:Construct()
    self:LuaInit()
    self:SetVisibility(1)
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
end

function wujingjiange:Show()
    self:SetVisibility(0)
    self:UpdateFloorText()
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

-- 更新层数显示
function wujingjiange:UpdateFloorText()
    if not self.cengshu then
        ugcprint("[wujingjiange] cengshu 控件不存在")
        return
    end

    local floor = 0
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        floor = (PC.JiangeFloor or 0) + 1
    end
    self.cengshu:SetText(tostring(floor))
    ugcprint("[wujingjiange] 层数显示: " .. tostring(floor))
end

function wujingjiange:OnCancelClicked()
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end
    self:SetVisibility(2)
end

function wujingjiange:OnStartClicked()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then
        ugcprint("[wujingjiange] PC为nil")
        return
    end
    ugcprint("[wujingjiange] 开始传送")
    -- 通过RPC调用服务端传送（客户端直接TeleportTo在真机不生效）
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportPlayer", 268737.21875, 238584.484375, 1118.539795)
    self:SetVisibility(2)

    -- 使用MMainUI上的jdutiao子控件（不再动态创建）
    local MMainUI = PC.MMainUI
    if MMainUI and MMainUI.jdutiao then
        local jd = MMainUI.jdutiao
        jd:SetVisibility(0) -- Visible
        ugcprint("[wujingjiange] jdutiao已显示")

        -- 播放动画
        if jd.NewAnimation_1 then
            jd:PlayAnimation(jd.NewAnimation_1, 0, 1, 0, 1.0, false)
            ugcprint("[wujingjiange] jdutiao动画开始播放")
        else
            ugcprint("[wujingjiange] 警告：NewAnimation_1为nil")
        end

        -- 4秒后隐藏jdutiao并恢复界面
        UGCGameSystem.SetTimer(self, function()
            ugcprint("[wujingjiange] 4秒到，隐藏jdutiao")
            jd:SetVisibility(2) -- Collapsed
            local MCP = UGCWidgetManagerSystem.GetMainUI()
            if MCP then
                UGCWidgetManagerSystem.SubWidgetHiddenLayer(MCP.MainControlBaseUI)
                UGCWidgetManagerSystem.SubWidgetHiddenLayer(MCP.ShootingUIPanel)
            end
            local SP = UGCWidgetManagerSystem.GetSkillRootPanel()
            if SP then
                UGCWidgetManagerSystem.SubWidgetHiddenLayer(SP)
            end
        end, 4.0, false)
    else
        ugcprint("[wujingjiange] MMainUI或jdutiao不存在，直接恢复界面")
        local MCP = UGCWidgetManagerSystem.GetMainUI()
        if MCP then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MCP.MainControlBaseUI)
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MCP.ShootingUIPanel)
        end
        local SP = UGCWidgetManagerSystem.GetSkillRootPanel()
        if SP then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(SP)
        end
    end
end

function wujingjiange:Destruct()
end

return wujingjiange
