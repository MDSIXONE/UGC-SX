---@class TalentTree_C:UUserWidget
---@field Attack UNewButton
---@field canPointcount UTextBlock
---@field HF UNewButton
---@field Hp UNewButton
---@field Hp2 UNewButton
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_8 UImage
---@field introduce_Text UTextBlock
---@field Sikll UNewButton
---@field Speed UNewButton
---@field SS UNewButton
---@field Talent_cancel UButton
---@field Talent_name UTextBlock
---@field Talent_Sure UButton
---@field TalentPoint_Text UTextBlock
---@field YaoShe UNewButton
---@field ZD UNewButton
--Edit Below--
local TalentTree = { bInitDoOnce = false }
-- 天赋类型枚举
local TALENT_TYPE = {
    NONE = 0,
    HP = 1,           -- 生命加成 (Hp按钮)
    ATTACK = 2,       -- 攻击加成 (Attack按钮)
    MAGIC = 3,        -- 魔法加成 (Hp2按钮)
    SPEED = 4,        -- 移速加成 (Speed按钮)
    ACCURACY = 5,     -- 准度加成 (ZD按钮)
    HIP_FIRE = 6,     -- 腰射加成 (YaoShe按钮)
    SKILL_HASTE = 7,  -- 技能急速 (Sikll按钮)
    HP_REGEN = 8,     -- 生命恢复 (HF按钮)
    FIRE_RATE = 9,    -- 射速加成 (SS按钮)
}
-- 天赋配置表
-- cost: 升级所需天赋点
-- maxLevel: 最大等级
-- desc: 描述
-- buffPath: 对应的buff路径 (用于buff类型天赋)
local TALENT_CONFIG = {
    [TALENT_TYPE.HP] = {
        name = "生命加成",
        cost = 1,
        maxLevel = 1000,
        desc = "每次升级增加最大生命3%",
        dataField = "PlayerTalent1",
    },
    [TALENT_TYPE.ATTACK] = {
        name = "攻击加成",
        cost = 1,
        maxLevel = 1000,
        desc = "每次升级增加最大攻击1%",
        dataField = "PlayerTalent2",
    },
    [TALENT_TYPE.MAGIC] = {
        name = "魔法加成",
        cost = 1,
        maxLevel = 1000,
        desc = "每次升级增加最大魔法2%",
        dataField = "PlayerTalent3",
    },
    [TALENT_TYPE.SPEED] = {
        name = "移速加成",
        cost = 3,
        maxLevel = 50,
        desc = "每次升级增加1%移动速度",
        dataField = "PlayerTalent4",
    },
    [TALENT_TYPE.ACCURACY] = {
        name = "准度加成",
        cost = 3,
        maxLevel = 100,
        desc = "每次升级水平、垂直后坐力-0.01",
        dataField = "PlayerTalent5",
    },
    [TALENT_TYPE.HIP_FIRE] = {
        name = "腰射加成",
        cost = 3,
        maxLevel = 100,
        desc = "每次升级连发散射-0.01",
        dataField = "PlayerTalent6",
    },
    [TALENT_TYPE.SKILL_HASTE] = {
        name = "技能急速",
        cost = 5,
        maxLevel = 100,
        desc = "每次升级技能急速+0.01",
        dataField = "PlayerTalent7",
    },
    [TALENT_TYPE.HP_REGEN] = {
        name = "生命恢复",
        cost = 5,
        maxLevel = 100,
        desc = "每次升级每秒恢复最大生命0.001",
        dataField = "PlayerTalent8",
    },
    [TALENT_TYPE.FIRE_RATE] = {
        name = "射速加成",
        cost = 5,
        maxLevel = 50,
        desc = "每次升级射击间隔-0.01",
        dataField = "PlayerTalent9",
    },
}
function TalentTree:Construct()
    self:LuaInit()
end
function TalentTree:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    --ugcprint("[TalentTree] LuaInit 开始")
    
    -- 当前选中的天赋类型
    self.CurrentTalentType = TALENT_TYPE.NONE
    
    -- 隐藏详情控件
    self:HideDetailControls()
    
    -- 绑定按钮事件
    -- 天赋1: 生命加成 - Hp按钮
    if self.Hp then
        self.Hp.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.HP) end, self)
        --ugcprint("[TalentTree] Hp(生命加成) 按钮绑定成功")
    end
    
    -- 天赋2: 攻击加成 - Attack按钮
    if self.Attack then
        self.Attack.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.ATTACK) end, self)
        --ugcprint("[TalentTree] Attack(攻击加成) 按钮绑定成功")
    end
    
    -- 天赋3: 魔法加成 - Hp2按钮
    if self.Hp2 then
        self.Hp2.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.MAGIC) end, self)
        --ugcprint("[TalentTree] Hp2(魔法加成) 按钮绑定成功")
    end
    
    -- 天赋4: 移速加成 - Speed按钮
    if self.Speed then
        self.Speed.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.SPEED) end, self)
        --ugcprint("[TalentTree] Speed(移速加成) 按钮绑定成功")
    end
    
    -- 天赋5: 准度加成 - ZD按钮
    if self.ZD then
        self.ZD.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.ACCURACY) end, self)
        --ugcprint("[TalentTree] ZD(准度加成) 按钮绑定成功")
    end
    
    -- 天赋6: 腰射加成 - YaoShe按钮
    if self.YaoShe then
        self.YaoShe.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.HIP_FIRE) end, self)
        --ugcprint("[TalentTree] YaoShe(腰射加成) 按钮绑定成功")
    end
    
    -- 天赋7: 技能急速 - Sikll按钮
    if self.Sikll then
        self.Sikll.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.SKILL_HASTE) end, self)
        --ugcprint("[TalentTree] Sikll(技能急速) 按钮绑定成功")
    end
    
    -- 天赋8: 生命恢复 - HF按钮
    if self.HF then
        self.HF.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.HP_REGEN) end, self)
        --ugcprint("[TalentTree] HF(生命恢复) 按钮绑定成功")
    end
    
    -- 天赋9: 射速加成 - SS按钮
    if self.SS then
        self.SS.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.FIRE_RATE) end, self)
        --ugcprint("[TalentTree] SS(射速加成) 按钮绑定成功")
    end
    
    -- 确认和取消按钮
    if self.Talent_Sure then
        self.Talent_Sure.OnClicked:Add(self.OnSureClicked, self)
        --ugcprint("[TalentTree] Talent_Sure 按钮绑定成功")
    end
    if self.Talent_cancel then
        self.Talent_cancel.OnClicked:Add(self.OnCancelClicked, self)
        --ugcprint("[TalentTree] Talent_cancel 按钮绑定成功")
    end
    
    -- 初始化显示
    self:UpdateTalentPointText()
    
    --ugcprint("[TalentTree] LuaInit 完成")
end
-- 隐藏详情控件
function TalentTree:HideDetailControls()
    if self.Talent_name then
        self.Talent_name:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.introduce_Text then
        self.introduce_Text:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.introduce then
        self.introduce:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.Talent_Sure then
        self.Talent_Sure:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.canPointcount then
        self.canPointcount:SetVisibility(ESlateVisibility.Collapsed)
    end
end
-- 显示详情控件
function TalentTree:ShowDetailControls(talentType)
    local config = TALENT_CONFIG[talentType]
    if not config then return end
    
    -- 显示天赋名称
    if self.Talent_name then
        self.Talent_name:SetText(config.name)
        self.Talent_name:SetVisibility(ESlateVisibility.Visible)
    end
    
    if self.introduce_Text then
        local costText = "需要" .. config.cost .. "点天赋点升级\n" .. config.desc
        self.introduce_Text:SetText(costText)
        self.introduce_Text:SetVisibility(ESlateVisibility.Visible)
    end
    if self.introduce then
        self.introduce:SetVisibility(ESlateVisibility.Visible)
    end
    if self.Talent_Sure then
        self.Talent_Sure:SetVisibility(ESlateVisibility.Visible)
    end
    -- 显示当前等级/最大等级
    if self.canPointcount then
        local currentLevel = self:GetTalentLevel(talentType)
        self.canPointcount:SetText("当前等级: " .. currentLevel .. "/" .. config.maxLevel)
        self.canPointcount:SetVisibility(ESlateVisibility.Visible)
    end
end
-- 获取剩余天赋点
function TalentTree:GetRemainingTalentPoints()
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        if playerState.GameData and playerState.GameData.PlayerTalentPoints ~= nil then
            return playerState.GameData.PlayerTalentPoints
        elseif playerState.UGCPlayerTalentPoints ~= nil then
            return playerState.UGCPlayerTalentPoints
        end
    end
    return 0
end
-- 获取某天赋当前等级
function TalentTree:GetTalentLevel(talentType)
    local config = TALENT_CONFIG[talentType]
    if not config then return 0 end
    
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState and playerState.GameData then
        return playerState.GameData[config.dataField] or 0
    end
    return 0
end
-- 更新天赋点显示
function TalentTree:UpdateTalentPointText()
    if self.TalentPoint_Text then
        local points = self:GetRemainingTalentPoints()
        self.TalentPoint_Text:SetText("剩余天赋点: " .. tostring(points))
    end
end
-- 点击天赋按钮
function TalentTree:OnTalentClicked(talentType)
    local config = TALENT_CONFIG[talentType]
    if config then
        --ugcprint("[TalentTree] " .. config.name .. " 被点击")
    end
    self:ToggleTalentDetail(talentType)
end
-- 切换天赋详情显示
function TalentTree:ToggleTalentDetail(talentType)
    if self.CurrentTalentType == talentType then
        -- 再次点击同一个，隐藏详情
        self:HideDetailControls()
        self.CurrentTalentType = TALENT_TYPE.NONE
        --ugcprint("[TalentTree] 隐藏详情")
    else
        -- 点击不同的，显示新的详情
        self:HideDetailControls()
        self.CurrentTalentType = talentType
        self:ShowDetailControls(talentType)
        local config = TALENT_CONFIG[talentType]
        if config then
            --ugcprint("[TalentTree] 显示 " .. config.name .. " 详情")
        end
    end
end
-- 确认加点
function TalentTree:OnSureClicked()
    --ugcprint("[TalentTree] ========== OnSureClicked 开始 ==========")
    
    if self.CurrentTalentType == TALENT_TYPE.NONE then
        --ugcprint("[TalentTree] 错误：未选择天赋")
        return
    end
    
    local config = TALENT_CONFIG[self.CurrentTalentType]
    if not config then
        --ugcprint("[TalentTree] 错误：天赋配置不存在，类型: " .. tostring(self.CurrentTalentType))
        return
    end
    
    --ugcprint("[TalentTree] 选中天赋: " .. config.name .. " (类型: " .. self.CurrentTalentType .. ")")
    --ugcprint("[TalentTree] 天赋配置 - 消耗: " .. config.cost .. ", 最大等级: " .. config.maxLevel)
    
    -- 检查天赋点是否足够
    local remainingPoints = self:GetRemainingTalentPoints()
    --ugcprint("[TalentTree] 当前天赋点: " .. remainingPoints .. ", 需要: " .. config.cost)
    if remainingPoints < config.cost then
        --ugcprint("[TalentTree] 错误：天赋点不足")
        return
    end
    
    -- 检查是否已满级
    local currentLevel = self:GetTalentLevel(self.CurrentTalentType)
    --ugcprint("[TalentTree] 当前等级: " .. currentLevel .. ", 最大等级: " .. config.maxLevel)
    if currentLevel >= config.maxLevel then
        --ugcprint("[TalentTree] 错误：该天赋已满级")
        return
    end
    
    -- 发送加点请求到服务器
    local playerState = UGCGameSystem.GetLocalPlayerState()
    --ugcprint("[TalentTree] 获取PlayerState: " .. tostring(playerState))
    if playerState then
        --ugcprint("[TalentTree] 发送RPC请求: Server_AddTalentPointNew, 参数: " .. self.CurrentTalentType)
        UnrealNetwork.CallUnrealRPC(
            playerState,
            playerState,
            "Server_AddTalentPointNew",
            self.CurrentTalentType
        )
        --ugcprint("[TalentTree] RPC请求已发送")
    else
        --ugcprint("[TalentTree] 错误：无法获取PlayerState")
    end
    
    --ugcprint("[TalentTree] ========== OnSureClicked 完成 ==========")
end
-- 关闭界面
function TalentTree:OnCancelClicked()
    --ugcprint("[TalentTree] 关闭天赋树")
    self:SetVisibility(ESlateVisibility.Collapsed)
    self:HideDetailControls()
    self.CurrentTalentType = TALENT_TYPE.NONE
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
-- 刷新界面（外部调用）
function TalentTree:RefreshUI()
    self:UpdateTalentPointText()
    -- 如果正在显示某个天赋详情，也刷新它
    if self.CurrentTalentType ~= TALENT_TYPE.NONE then
        self:ShowDetailControls(self.CurrentTalentType)
    end
end
return TalentTree