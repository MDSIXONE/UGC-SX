---@class TalentTip_C:UUserWidget
---@field Image_43 UImage
---@field Talent_Cancel General_SecondLevelButton_3_C
---@field Talent_explain UTextBlock
---@field Talent_sure General_SecondLevelButton_1_C
---@field Talent_Tip UTextBlock
---@field VerticalBox_0 UVerticalBox
--Edit Below--
local TalentTip = { bInitDoOnce = false }

-- 当前选择的天赋等级
TalentTip.CurrentTalentLevel = 0

function TalentTip:Construct()
    self:LuaInit()
end

function TalentTip:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    
    -- 绑定确认按钮 (General_SecondLevelButton_1_C)
    if self.Talent_sure then
        -- 尝试多种可能的按钮名称
        if self.Talent_sure.Button_0 then
            self.Talent_sure.Button_0.OnClicked:Add(self.OnSureClicked, self)
            --ugcprint("[TalentTip] 确认按钮绑定成功 (Button_0)")
        elseif self.Talent_sure.Button_Levels2_1 then
            self.Talent_sure.Button_Levels2_1.OnClicked:Add(self.OnSureClicked, self)
            --ugcprint("[TalentTip] 确认按钮绑定成功 (Button_Levels2_1)")
        else
            --ugcprint("[TalentTip] 警告：确认按钮内部按钮不存在")
        end
    end
    
    -- 绑定取消按钮 (General_SecondLevelButton_3_C)
    if self.Talent_Cancel then
        if self.Talent_Cancel.Button_Levels2_3 then
            self.Talent_Cancel.Button_Levels2_3.OnClicked:Add(self.OnCancelClicked, self)
            --ugcprint("[TalentTip] 取消按钮绑定成功 (Button_Levels2_3)")
        elseif self.Talent_Cancel.fuben_cancel then
            self.Talent_Cancel.fuben_cancel.OnClicked:Add(self.OnCancelClicked, self)
            --ugcprint("[TalentTip] 取消按钮绑定成功 (fuben_cancel)")
        else
            --ugcprint("[TalentTip] 警告：取消按钮内部按钮不存在")
        end
    end
end

-- 设置显示内容
function TalentTip:SetTalentInfo(level)
    self.CurrentTalentLevel = level
    
    if self.Talent_Tip then
        self.Talent_Tip:SetText("是否为（Speed" .. level .. "）加点")
    end
    
    if self.Talent_explain then
        self.Talent_explain:SetText("每点增加1%移动速度")
    end
end

-- 确认按钮点击
function TalentTip:OnSureClicked()
    --ugcprint("[TalentTip] 确认解锁 Speed" .. self.CurrentTalentLevel)
    
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TalentTip] 错误：无法获取玩家数据")
        return
    end
    
    -- 通过 RPC 调用服务器解锁天赋
    --ugcprint("[TalentTip] 发送天赋解锁请求到服务器")
    UnrealNetwork.CallUnrealRPC(
        playerState,
        playerState,
        "Server_UnlockTalent",
        "Speed",
        self.CurrentTalentLevel
    )
    
    -- 隐藏提示框
    self:SetVisibility(ESlateVisibility.Collapsed)
end

-- 取消按钮点击
function TalentTip:OnCancelClicked()
    --ugcprint("[TalentTip] 取消")
    self:SetVisibility(ESlateVisibility.Collapsed)
end

return TalentTip