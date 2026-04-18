---@class TalentTree_C:UUserWidget
---@field canPointcount UTextBlock
---@field currentlevel UTextBlock
---@field huo UNewButton
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
---@field introduce_Text UTextBlock
---@field jing UNewButton
---@field mu UNewButton
---@field nextlevel UTextBlock
---@field shui UNewButton
---@field Talent_cancel UButton
---@field Talent_name UTextBlock
---@field Talent_Sure UButton
---@field TalentPoint_Text UTextBlock
---@field tu UNewButton
--Edit Below--
local TalentTree = { bInitDoOnce = false }
-- 天赋类型枚举
local TALENT_TYPE = {
    NONE = 0,
    WOOD_SOURCE = 1,   -- 木之本源：最终生命属性增长
    METAL_SOURCE = 2,  -- 金之本源：最终速度属性增长
    WATER_SOURCE = 4,  -- 水之本源：最终魔法属性增长
    FIRE_SOURCE = 7,   -- 火之本源：最终攻击属性增长
    EARTH_SOURCE = 8,  -- 土之本源：周期恢复生命
}
local TALENT_UPGRADE_VIRTUAL_ITEM_ID = 5555
-- 天赋配置表
-- cost: 升级所需天赋点
-- maxLevel: 最大等级
-- desc: 描述
-- buffPath: 对应的buff路径 (用于buff类型天赋)
local TALENT_CONFIG = {
    [TALENT_TYPE.WOOD_SOURCE] = {
        name = "木之本源",
        cost = 1,
        maxLevel = 5,
        desc = "每次觉醒本源可以获取50%的最终生命属性增长",
        dataField = "PlayerTalent1",
    },
    [TALENT_TYPE.METAL_SOURCE] = {
        name = "金之本源",
        cost = 1,
        maxLevel = 5,
        desc = "每次觉醒本源可以获取20%的最终速度属性增长",
        dataField = "PlayerTalent2",
    },
    [TALENT_TYPE.WATER_SOURCE] = {
        name = "水之本源",
        cost = 3,
        maxLevel = 5,
        desc = "每次觉醒本源可以获取50%的最终魔法属性增长",
        dataField = "PlayerTalent4",
    },
    [TALENT_TYPE.FIRE_SOURCE] = {
        name = "火之本源",
        cost = 5,
        maxLevel = 5,
        desc = "每次觉醒本源可以获取50%的最终攻击属性增长",
        dataField = "PlayerTalent7",
    },
    [TALENT_TYPE.EARTH_SOURCE] = {
        name = "土之本源",
        cost = 5,
        maxLevel = 5,
        desc = "每次觉醒本源可以每3秒恢复最大生命5%的血量",
        dataField = "PlayerTalent8",
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
    -- 木之本源 - mu按钮
    if self.mu then
        self.mu.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.WOOD_SOURCE) end, self)
        --ugcprint("[TalentTree] mu(木之本源) 按钮绑定成功")
    end
    
    -- 金之本源 - jing按钮
    if self.jing then
        self.jing.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.METAL_SOURCE) end, self)
        --ugcprint("[TalentTree] jing(金之本源) 按钮绑定成功")
    end
    -- 水之本源 - shui按钮
    if self.shui then
        self.shui.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.WATER_SOURCE) end, self)
        --ugcprint("[TalentTree] shui(水之本源) 按钮绑定成功")
    end
    -- 火之本源 - huo按钮
    if self.huo then
        self.huo.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.FIRE_SOURCE) end, self)
        --ugcprint("[TalentTree] huo(火之本源) 按钮绑定成功")
    end
    -- 土之本源 - tu按钮
    if self.tu then
        self.tu.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.EARTH_SOURCE) end, self)
        --ugcprint("[TalentTree] tu(土之本源) 按钮绑定成功")
    end
    if self.SS then
        self.SS:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.Hp2 then
        self.Hp2:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.ZD then
        self.ZD:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.YaoShe then
        self.YaoShe:SetVisibility(ESlateVisibility.Collapsed)
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
    if self.currentlevel then
        self.currentlevel:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.nextlevel then
        self.nextlevel:SetVisibility(ESlateVisibility.Collapsed)
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
        local costText = "需要" .. config.cost .. "个五行本源升级\n" .. config.desc
        self.introduce_Text:SetText(costText)
        self.introduce_Text:SetVisibility(ESlateVisibility.Visible)
    end
    if self.introduce then
        self.introduce:SetVisibility(ESlateVisibility.Visible)
    end
    if self.Talent_Sure then
        self.Talent_Sure:SetVisibility(ESlateVisibility.Visible)
    end
    local currentLevel = self:GetTalentLevel(talentType)
    -- 显示升级消耗
    if self.canPointcount then
        self.canPointcount:SetText("升级消耗: " .. config.cost .. "个五行本源")
        self.canPointcount:SetVisibility(ESlateVisibility.Visible)
    end
    if self.currentlevel then
        self.currentlevel:SetText("" .. tostring(currentLevel) .. "/" .. tostring(config.maxLevel))
        self.currentlevel:SetVisibility(ESlateVisibility.Visible)
    end
    if self.nextlevel then
        if currentLevel >= config.maxLevel then
            self.nextlevel:SetText("已满级")
        else
            self.nextlevel:SetText("" .. tostring(currentLevel + 1))
        end
        self.nextlevel:SetVisibility(ESlateVisibility.Visible)
    end
end
-- 获取天赋升级材料(五行本源)数量
function TalentTree:GetTalentVirtualItemCount()
    local virtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not virtualItemManager then
        return 0
    end
    local playerController = UGCGameSystem.GetLocalPlayerController()
    local count = 0
    if playerController then
        count = virtualItemManager:GetItemNum(TALENT_UPGRADE_VIRTUAL_ITEM_ID, playerController) or 0
    else
        count = virtualItemManager:GetItemNum(TALENT_UPGRADE_VIRTUAL_ITEM_ID) or 0
    end
    return math.max(0, math.floor(tonumber(count) or 0))
end
-- 获取某天赋当前等级
function TalentTree:GetTalentLevel(talentType)
    local config = TALENT_CONFIG[talentType]
    if not config then return 0 end
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return 0
    end
    if playerState.GameData and playerState.GameData[config.dataField] ~= nil then
        return playerState.GameData[config.dataField] or 0
    end
    local repField = "UGC" .. config.dataField
    if playerState[repField] ~= nil then
        return playerState[repField] or 0
    end
    return 0
end
-- 更新天赋点显示
function TalentTree:UpdateTalentPointText()
    if self.TalentPoint_Text then
        local count = self:GetTalentVirtualItemCount()
        self.TalentPoint_Text:SetText("" .. tostring(count))
    end
end
function TalentTree:ShowTip(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
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
        self:ShowTip("请先选择天赋")
        return
    end
    
    local config = TALENT_CONFIG[self.CurrentTalentType]
    if not config then
        self:ShowTip("该天赋暂未开放")
        return
    end
    
    --ugcprint("[TalentTree] 选中天赋: " .. config.name .. " (类型: " .. self.CurrentTalentType .. ")")
    --ugcprint("[TalentTree] 天赋配置 - 消耗: " .. config.cost .. ", 最大等级: " .. config.maxLevel)
    
    -- 检查虚拟物品数量是否足够
    local materialCount = self:GetTalentVirtualItemCount()
    if materialCount < config.cost then
        self:ShowTip("五行本源不足")
        return
    end
    
    -- 检查是否已满级
    local currentLevel = self:GetTalentLevel(self.CurrentTalentType)
    if currentLevel >= config.maxLevel then
        self:ShowTip("该天赋已满级")
        return
    end
    
    -- 发送加点请求到服务器
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        UnrealNetwork.CallUnrealRPC(
            playerState,
            playerState,
            "Server_AddTalentPointNew",
            self.CurrentTalentType
        )
    else
        self:ShowTip("无法获取玩家状态")
    end
end
function TalentTree:OnTalentUpgradeResult(success, talentType, currentLevel, remainCount, tipText)
    if tipText and tipText ~= "" then
        self:ShowTip(tostring(tipText))
    elseif success then
        self:ShowTip("天赋升级成功")
    else
        self:ShowTip("天赋升级失败")
    end
    self:RefreshUI()
    return true
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