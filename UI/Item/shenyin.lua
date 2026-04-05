---@class shenyin_C:UUserWidget
---@field AddLevel UButton
---@field Addquality UButton
---@field Addqualityitem UHorizontalBox
---@field Border_2 UBorder
---@field Border_3 UBorder
---@field Border_4 UBorder
---@field Border_5 UBorder
---@field Border_6 UBorder
---@field Border_7 UBorder
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_4 UButton
---@field Button_5 UButton
---@field Button_6 UButton
---@field Button_7 UButton
---@field cancel UButton
---@field detail UTextBlock
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_122 UImage
---@field Image_Addqualityitem UImage
---@field Image_baihu UImage
---@field Image_baize UImage
---@field image_detail UImage
---@field Image_fenghuang UImage
---@field Image_levelupitem UImage
---@field Image_qiling UImage
---@field Image_qingshe UImage
---@field Image_shenlong UImage
---@field level UTextBlock
---@field levelupitem UHorizontalBox
---@field remove UButton
---@field unlock UButton
---@field wear UButton
--Edit Below--
local shenyin = { bInitDoOnce = false }
local ButtonBorderMap = {
    { button = "Button_2", border = "Border_2", image = "Image_2", skill = "lvse",    icon = "Image_qingshe" },
    { button = "Button_3", border = "Border_3", image = "Image_3", skill = "lanse",   icon = "Image_baihu" },
    { button = "Button_4", border = "Border_4", image = "Image_4", skill = "zise",    icon = "Image_baize" },
    { button = "Button_5", border = "Border_5", image = "Image_5", skill = "chengse", icon = "Image_qiling" },
    { button = "Button_6", border = "Border_6", image = "Image_6", skill = "hongse",  icon = "Image_fenghuang" },
    { button = "Button_7", border = "Border_7", image = "Image_7", skill = "jinse",   icon = "Image_shenlong" },
}
-- 每个Button按品质的介绍文本（品质1~5）
local DetailTexts = {
    bailang  = { "白狼", "霜牙白狼", "寒锋啸狼", "极夜霜魂·白狼", "天穹凛影·噬月战狼" },
    Button_2 = { "青蛇", "幽影青蛇", "毒影幽蛇", "苍渊幽影·青蛇", "万毒冥影·噬魂龙蛇" },
    Button_3 = { "蓝虎", "雷风蓝虎", "沧雷战虎", "沧溟雷啸·战虎", "九霄镇岳·裂空天虎" },
    Button_4 = { "白泽", "紫曜白泽", "星寰白泽", "紫宸天启·白泽", "鸿蒙虚境·万灵神泽" },
    Button_5 = { "麒麟", "炎角麒麟", "焚天瑞麟", "炎狱镇世·麒麟", "太古洪荒·万兽祖麟" },
    Button_6 = { "凤凰", "赤焰凤凰", "烬火凰鸟", "焚天涅槃·火凰", "九天永烬·不死神凰" },
    Button_7 = { "神龙", "傲世金龙", "穹天苍龙", "寰宇镇世·金龙", "混沌元始·万龙之祖" },
}
-- 每个神影按品质对应的图片名（品质1~5）
-- 图片路径格式: PNG/shenyin/XXX.XXX
local DetailImages = {
    bailang  = { "bailang1", "bailang2", "bailang3", "bailang4", "bailang5" },
    Button_2 = { "qingshe1", "qingshe2", "qingshe3", "qingshe4", "qingshe5" },
    Button_3 = { "baihu1", "baihu2", "baihu3", "baihu4", "baihu5" },
    Button_4 = { "baize1", "baize2", "baize3", "baize4", "baize5" },
    Button_5 = { "qiling1", "qiling2", "qiling3", "qiling4", "qiling5" },
    Button_6 = { "fenghuang1", "fenghuang2", "fenghuang3", "fenghuang4", "fenghuang5" },
    Button_7 = { "shenlong1", "shenlong2", "shenlong3", "shenlong4", "shenlong5" },
}
-- 每个Button的吞噬倍率配置: {基础倍率, 100级倍率}
local EcexpConfig = {
    bailang  = { base = 100,  max = 200 },
    Button_2 = { base = 200,  max = 400 },
    Button_3 = { base = 300,  max = 600 },
    Button_4 = { base = 400,  max = 800 },
    Button_5 = { base = 500,  max = 1000 },
    Button_6 = { base = 750,  max = 1500 },
    Button_7 = { base = 1000, max = 2000 },
}
-- 每个神影对应的升级/升品材料图片名（路径: PNG/shenjian/XXX.XXX）
local ItemImages = {
    bailang  = "sp1",
    Button_2 = "sp2",
    Button_3 = "sp3",
    Button_4 = "sp4",
    Button_5 = "sp5",
    Button_6 = "sp6",
    Button_7 = "sp7",
}
local STATE_UNLOCK = "unlock"
local STATE_UNWEAR = "unwear"
local STATE_WEAR   = "wear"
local MAX_QUALITY = 5
local MAX_LEVEL = 100
function shenyin:Construct()
    self:LuaInit()
    self.SlotStates = {}
    self.SlotLevels = {}    -- 等级 1~100
    self.SlotQualities = {} -- 品质 1~5
    -- 初始化白狼（默认已解锁未穿戴）
    self.SlotStates["bailang"] = STATE_UNWEAR
    self.SlotLevels["bailang"] = 1
    self.SlotQualities["bailang"] = 1
    for _, pair in ipairs(ButtonBorderMap) do
        self.SlotStates[pair.button] = STATE_UNLOCK
        self.SlotLevels[pair.button] = 1
        self.SlotQualities[pair.button] = 1
    end
    self.SelectedButton = nil
    self.CurrentWearing = nil
    self.CurrentEcexpBonus = 0  -- 当前穿戴增加的Ecexp值
    for _, pair in ipairs(ButtonBorderMap) do
        if self[pair.border] then
            self[pair.border]:SetVisibility(1)
        end
    end
    if self.unlock then self.unlock:SetVisibility(1) end
    if self.wear   then self.wear:SetVisibility(1) end
    if self.remove then self.remove:SetVisibility(1) end
    if self.AddLevel then self.AddLevel:SetVisibility(1) end
    if self.Addquality then self.Addquality:SetVisibility(1) end
    if self.detail then self.detail:SetText("") end
    if self.level then self.level:SetText("") end
    self:SetVisibility(1)
end
function shenyin:Show()
    self:SetVisibility(0)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end
    -- 刷新所有图标颜色状态
    self:RefreshAllIconColors()
    -- 每次打开默认选中白狼
    self:OnSlotButtonClicked("bailang")
end
-- 设置UImage的Brush着色（TintColor）为白色
function shenyin:SetIconBrushWhite(imageWidget)
    if not imageWidget then return end
    local brush = imageWidget:GetBrush()
    if brush then
        brush.TintColor = UGCObjectUtility.NewStruct("SlateColor")
        brush.TintColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
        imageWidget:SetBrush(brush)
    end
end
-- 刷新所有神影图标的颜色（已解锁=白色，未解锁=保持默认灰色）
function shenyin:RefreshAllIconColors()
    for _, pair in ipairs(ButtonBorderMap) do
        if pair.icon and self[pair.icon] then
            local state = self.SlotStates[pair.button]
            if state ~= STATE_UNLOCK then
                self:SetIconBrushWhite(self[pair.icon])
            end
        end
    end
end
function shenyin:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    for _, pair in ipairs(ButtonBorderMap) do
        local btn = self[pair.button]
        if btn then
            local buttonName = pair.button
            btn.OnClicked:Add(function()
                self:OnSlotButtonClicked(buttonName)
            end, self)
        end
    end
    if self.unlock then self.unlock.OnClicked:Add(self.OnUnlockClicked, self) end
    if self.wear then self.wear.OnClicked:Add(self.OnWearClicked, self) end
    if self.remove then self.remove.OnClicked:Add(self.OnRemoveClicked, self) end
    if self.cancel then self.cancel.OnClicked:Add(self.OnCancelClicked, self) end
    if self.AddLevel then self.AddLevel.OnClicked:Add(self.OnAddLevelClicked, self) end
    if self.Addquality then self.Addquality.OnClicked:Add(self.OnAddQualityClicked, self) end
end
-- 获取当前选中按钮的吞噬倍率（按等级线性插值：1级=base，100级=max）
function shenyin:GetEcexpBonus(buttonName)
    local cfg = EcexpConfig[buttonName]
    if not cfg then return 0 end
    local lv = self.SlotLevels[buttonName] or 1
    if lv >= MAX_LEVEL then
        return cfg.max
    end
    -- 1级=base, 100级=max, 线性插值
    local bonus = cfg.base + (cfg.max - cfg.base) * (lv - 1) / (MAX_LEVEL - 1)
    return math.floor(bonus)
end
-- 获取品质对应的名字
function shenyin:GetDetailText(buttonName)
    local texts = DetailTexts[buttonName]
    if not texts then return "" end
    local quality = self.SlotQualities[buttonName] or 1
    return texts[quality] or texts[#texts]
end
-- 更新详情图片（根据当前选中的神影和品质）
function shenyin:UpdateDetailImage(buttonName)
    if not self.image_detail then return end
    local images = DetailImages[buttonName]
    if not images then return end
    local quality = self.SlotQualities[buttonName] or 1
    local imgName = images[quality] or images[#images]
    local imgPath = UGCGameSystem.GetUGCResourcesFullPath('PNG/shenshou/' .. imgName .. '.' .. imgName)
    local texture = LoadObject(imgPath)
    if texture then
        self.image_detail:SetBrushFromTexture(texture)
    end
end
-- 获取技能路径（根据品质）
function shenyin:GetSkillPath(skillName, quality)
    quality = quality or 1
    if quality <= 1 then
        return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/' .. skillName .. '.' .. skillName .. '_C')
    else
        return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/SY' .. quality .. '/' .. skillName .. '.' .. skillName .. '_C')
    end
end
function shenyin:GetPairByButton(buttonName)
    -- 白狼特殊处理（没有按钮/边框控件）
    if buttonName == "bailang" then
        return { button = "bailang", border = nil, image = nil, skill = "baise" }
    end
    for _, pair in ipairs(ButtonBorderMap) do
        if pair.button == buttonName then return pair end
    end
    return nil
end
function shenyin:OnSlotButtonClicked(buttonName)
    self.SelectedButton = buttonName
    if self.detail then
        self.detail:SetText(self:GetDetailText(buttonName))
    end
    self:UpdateDetailImage(buttonName)
    self:UpdateItemImages(buttonName)
    self:UpdateLevelDisplay()
    self:UpdateActionButtons()
end

-- 更新升级/升品材料图片
function shenyin:UpdateItemImages(buttonName)
    local imgName = ItemImages[buttonName]
    if not imgName then return end
    local imgPath = UGCGameSystem.GetUGCResourcesFullPath('PNG/shenjian/' .. imgName .. '.' .. imgName)
    local texture = LoadObject(imgPath)
    if texture then
        if self.Image_levelupitem then
            self.Image_levelupitem:SetBrushFromTexture(texture)
        end
        if self.Image_Addqualityitem then
            self.Image_Addqualityitem:SetBrushFromTexture(texture)
        end
    end
end
function shenyin:UpdateActionButtons()
    local state = self.SlotStates[self.SelectedButton]
    local lv = self.SlotLevels[self.SelectedButton] or 1
    local quality = self.SlotQualities[self.SelectedButton] or 1
    if self.unlock then
        self.unlock:SetVisibility(state == STATE_UNLOCK and 0 or 1)
    end
    if self.wear then
        self.wear:SetVisibility(state == STATE_UNWEAR and 0 or 1)
    end
    if self.remove then
        self.remove:SetVisibility(state == STATE_WEAR and 0 or 1)
    end
    -- 已解锁且未满级时显示升级按钮
    if self.AddLevel then
        local canLevel = (state ~= STATE_UNLOCK) and (lv < MAX_LEVEL)
        self.AddLevel:SetVisibility(canLevel and 0 or 1)
    end
    -- 已解锁且未满品质时显示升品按钮
    if self.Addquality then
        local canQuality = (state ~= STATE_UNLOCK) and (quality < MAX_QUALITY)
        self.Addquality:SetVisibility(canQuality and 0 or 1)
    end
end
function shenyin:UpdateLevelDisplay()
    if not self.SelectedButton then return end
    local lv = self.SlotLevels[self.SelectedButton] or 1
    local state = self.SlotStates[self.SelectedButton]
    if self.level then
        if state == STATE_UNLOCK then
            self.level:SetText("")
        else
            self.level:SetText("Lv." .. tostring(lv))
        end
    end
end
-- 通过RPC在服务端添加/移除被动技能 + 增减Ecexp
function shenyin:ApplySkill(skillName, isWear, quality)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local skillPath = self:GetSkillPath(skillName, quality)
    ugcprint("[shenyin] ApplySkill: skill=" .. tostring(skillName) .. ", quality=" .. tostring(quality) .. ", isWear=" .. tostring(isWear) .. ", path=" .. tostring(skillPath))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetShenyingSkill", skillPath, isWear)
end
-- 通过RPC设置神影临时Ecexp（直接设置值，不是加减）
function shenyin:ApplyEcexp(amount)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    ugcprint("[shenyin] SetShenyinEcexp: " .. tostring(amount))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetShenyinEcexp", amount)
end
-- 解锁
function shenyin:OnUnlockClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    self.SlotStates[self.SelectedButton] = STATE_UNWEAR
    if self[pair.border] then
        self[pair.border]:SetVisibility(0)
        self[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
    end
    -- 解锁后把对应图片的Brush着色设为白色(FFFFFFFF)
    if pair.icon and self[pair.icon] then
        ugcprint("[shenyin] OnUnlockClicked: 设置Brush TintColor为白色, icon=" .. tostring(pair.icon))
        self:SetIconBrushWhite(self[pair.icon])
    end
    self:UpdateActionButtons()
end
-- 穿戴
function shenyin:OnWearClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    -- 卸下旧的（UI状态）
    if self.CurrentWearing and self.CurrentWearing ~= self.SelectedButton then
        local oldPair = self:GetPairByButton(self.CurrentWearing)
        if oldPair then
            self.SlotStates[self.CurrentWearing] = STATE_UNWEAR
            if self[oldPair.border] then
                self[oldPair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
            end
        end
    end
    self.SlotStates[self.SelectedButton] = STATE_WEAR
    self.CurrentWearing = self.SelectedButton
    if self[pair.border] then
        self[pair.border]:SetVisibility(0)
        self[pair.border]:SetBrushColor({R = 1, G = 1, B = 0, A = 1})
    end
    -- 应用技能（品质决定路径）
    self:ApplySkill(pair.skill, true, self.SlotQualities[self.SelectedButton])
    -- 设置神影临时Ecexp
    self.CurrentEcexpBonus = self:GetEcexpBonus(self.SelectedButton)
    self:ApplyEcexp(self.CurrentEcexpBonus)
    self:UpdateActionButtons()
end
-- 卸下
function shenyin:OnRemoveClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    self.SlotStates[self.SelectedButton] = STATE_UNWEAR
    if self.CurrentWearing == self.SelectedButton then
        self.CurrentWearing = nil
    end
    if self[pair.border] then
        self[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
    end
    -- 移除技能
    self:ApplySkill(pair.skill, false, self.SlotQualities[self.SelectedButton])
    -- 清除神影临时Ecexp
    self.CurrentEcexpBonus = 0
    self:ApplyEcexp(0)
    self:UpdateActionButtons()
end
-- AddLevel：只升等级，穿戴中则更新Ecexp加成
function shenyin:OnAddLevelClicked()
    if not self.SelectedButton then return end
    local state = self.SlotStates[self.SelectedButton]
    if state == STATE_UNLOCK then return end
    local lv = self.SlotLevels[self.SelectedButton] or 1
    if lv >= MAX_LEVEL then return end
    self.SlotLevels[self.SelectedButton] = lv + 1
    -- 如果正在穿戴，检查Ecexp是否因到100级而变化
    if state == STATE_WEAR then
        local newBonus = self:GetEcexpBonus(self.SelectedButton)
        if newBonus ~= self.CurrentEcexpBonus then
            self.CurrentEcexpBonus = newBonus
            self:ApplyEcexp(newBonus)
        end
    end
    self:UpdateLevelDisplay()
    self:UpdateActionButtons()
end
-- Addquality：升品质，改变技能路径和detail名字
function shenyin:OnAddQualityClicked()
    if not self.SelectedButton then return end
    local state = self.SlotStates[self.SelectedButton]
    if state == STATE_UNLOCK then return end
    local quality = self.SlotQualities[self.SelectedButton] or 1
    if quality >= MAX_QUALITY then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    self.SlotQualities[self.SelectedButton] = quality + 1
    -- 如果正在穿戴，重新应用新品质技能
    if state == STATE_WEAR then
        self:ApplySkill(pair.skill, true, quality + 1)
    end
    -- 刷新detail名字和图片
    if self.detail then
        self.detail:SetText(self:GetDetailText(self.SelectedButton))
    end
    self:UpdateDetailImage(self.SelectedButton)
    self:UpdateActionButtons()
end
-- 关闭界面
function shenyin:OnCancelClicked()
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
function shenyin:Destruct()
end
return shenyin