---@class shenyin_C:UUserWidget
---@field AddLevel UButton
---@field Addquality UButton
---@field Addqualityitem UHorizontalBox
---@field Border_2p UImage
---@field Border_3p UImage
---@field Border_4p UImage
---@field Border_5p UImage
---@field Border_6p UImage
---@field Border_7p UImage
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_4 UButton
---@field Button_5 UButton
---@field Button_6 UButton
---@field Button_7 UButton
---@field cancel UButton
---@field detail UTextBlock
---@field Image_0 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_8 UImage
---@field Image_9 UImage
---@field Image_10 UImage
---@field Image_11 UImage
---@field Image_12 UImage
---@field Image_13 UImage
---@field Image_14 UImage
---@field Image_98 UImage
---@field Image_99 UImage
---@field Image_101 UImage
---@field Image_104 UImage
---@field Image_108 UImage
---@field Image_111 UImage
---@field Image_122 UImage
---@field Image_Addqualityitem UImage
---@field Image_baihu UImage
---@field Image_baize UImage
---@field image_detail UImage
---@field Image_fenghuang UImage
---@field Image_itemnumb UImage
---@field Image_levelupitem UImage
---@field Image_qiling UImage
---@field Image_qingshe UImage
---@field Image_shenlong UImage
---@field itemnumb UTextBlock
---@field level UTextBlock
---@field levelupitem UHorizontalBox
---@field remove UButton
---@field TextBlock_currentlevel UTextBlock
---@field TextBlock_currentshhuxing UTextBlock
---@field TextBlock_jieshao UTextBlock
---@field TextBlock_nextlevel UTextBlock
---@field TextBlock_nextlevelshuxing UTextBlock
---@field tip tip_C
---@field unlock UButton
---@field wear UButton
--Edit Below--
local shenyin = { bInitDoOnce = false }
local ButtonBorderMap = {
    { button = "Button_2", border = "Border_2p", image = "Image_2", skill = "lvse",    icon = "Image_qingshe" },
    { button = "Button_3", border = "Border_3p", image = "Image_3", skill = "lanse",   icon = "Image_baihu" },
    { button = "Button_4", border = "Border_4p", image = "Image_4", skill = "zise",    icon = "Image_baize" },
    { button = "Button_5", border = "Border_5p", image = "Image_5", skill = "chengse", icon = "Image_qiling" },
    { button = "Button_6", border = "Border_6p", image = "Image_6", skill = "hongse",  icon = "Image_fenghuang" },
    { button = "Button_7", border = "Border_7p", image = "Image_7", skill = "jinse",   icon = "Image_shenlong" },
}
-- Configuration table used by this widget.
local DetailTexts = {
    bailang  = { "白狼", "霜牙白狼", "寒锋啸狼", "极夜霜魂·白狼", "天穹凛影·噬月战狼" },
    Button_2 = { "青蛇", "幽影青蛇", "毒影幽蛇", "苍渊幽影·青蛇", "万毒冥影·噬魂龙蛇" },
    Button_3 = { "蓝虎", "雷风蓝虎", "沧雷战虎", "沧溟雷啸·战虎", "九霄镇岳·裂空天虎" },
    Button_4 = { "白泽", "紫曜白泽", "星寰白泽", "紫宸天启·白泽", "鸿蒙虚境·万灵神泽" },
    Button_5 = { "麒麟", "炎角麒麟", "焚天瑞麟", "炎狱镇世·麒麟", "太古洪荒·万兽祖麟" },
    Button_6 = { "凤凰", "赤焰凤凰", "烬火凰鸟", "焚天涅槃·火凰", "九天永烬·不死神凰" },
    Button_7 = { "神龙", "傲世金龙", "穹天苍龙", "寰宇镇世·金龙", "混沌元始·万龙之祖" },
}
-- Configuration table used by this widget.
local DetailImages = {
    bailang  = { "bailang1", "bailang2", "bailang3", "bailang4", "bailang5" },
    Button_2 = { "qingshe1", "qingshe2", "qingshe3", "qingshe4", "qingshe5" },
    Button_3 = { "baihu1", "baihu2", "baihu3", "baihu4", "baihu5" },
    Button_4 = { "baize1", "baize2", "baize3", "baize4", "baize5" },
    Button_5 = { "qiling1", "qiling2", "qiling3", "qiling4", "qiling5" },
    Button_6 = { "fenghuang1", "fenghuang2", "fenghuang3", "fenghuang4", "fenghuang5" },
    Button_7 = { "shenlong1", "shenlong2", "shenlong3", "shenlong4", "shenlong5" },
}
-- Configuration table used by this widget.
local EcexpConfig = {
    bailang  = { base = 100,  max = 200 },
    Button_2 = { base = 200,  max = 400 },
    Button_3 = { base = 300,  max = 600 },
    Button_4 = { base = 400,  max = 800 },
    Button_5 = { base = 500,  max = 1000 },
    Button_6 = { base = 750,  max = 1500 },
    Button_7 = { base = 1000, max = 2000 },
}
-- Configuration table used by this widget.
local ItemImages = {
    bailang  = "sp1",
    Button_2 = "sp2",
    Button_3 = "sp3",
    Button_4 = "sp4",
    Button_5 = "sp5",
    Button_6 = "sp6",
    Button_7 = "sp7",
}
-- Configuration table used by this widget.
local ItemVirtualIDs = {
    bailang  = 5001,
    Button_2 = 5002,
    Button_3 = 5003,
    Button_4 = 5004,
    Button_5 = 5005,
    Button_6 = 5006,
    Button_7 = 5007,
}
-- Configuration table used by this widget.
local SkillDescriptions = {
    bailang  = "白狼神影：提升吞噬经验加成40%。",
    Button_2 = "青蛇神影：提升吞噬经验加成80%。",
    Button_3 = "蓝虎神影：提升吞噬经验加成120%。",
    Button_4 = "白泽神影：提升吞噬经验加成160%。",
    Button_5 = "麒麟神影：提升吞噬经验加成200%。",
    Button_6 = "凤凰神影：提升吞噬经验加成300%。",
    Button_7 = "神龙神影：提升吞噬经验加成500%。",
}
local STATE_UNLOCK = "unlock"
local STATE_UNWEAR = "unwear"
local STATE_WEAR   = "wear"
local MAX_QUALITY = 5
local MAX_LEVEL = 100
function shenyin:Construct()
    self:LuaInit()
    self.SlotStates = {}
    self.SlotLevels = {}
    self.SlotQualities = {}
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
    self.CurrentEcexpBonus = 0

    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.SavedShenyinData and PC.SavedShenyinData ~= "" then
        self:LoadSavedData(PC.SavedShenyinData)
    end

    for _, pair in ipairs(ButtonBorderMap) do
        if self[pair.border] then
            self[pair.border]:SetVisibility(ESlateVisibility.Visible)
        end
    end
    if self.unlock then self.unlock:SetVisibility(ESlateVisibility.Visible) end
    if self.wear   then self.wear:SetVisibility(ESlateVisibility.Visible) end
    if self.remove then self.remove:SetVisibility(ESlateVisibility.Visible) end
    if self.AddLevel then self.AddLevel:SetVisibility(ESlateVisibility.Visible) end
    if self.Addquality then self.Addquality:SetVisibility(ESlateVisibility.Visible) end
    if self.detail then self.detail:SetText("") end
    if self.level then self.level:SetText("") end
    self:SetVisibility(ESlateVisibility.Visible)
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if VIM then
        VIM.OnItemNumUpdatedDelegate:Add(self.OnItemNumUpdated, self)
    end
end
function shenyin:Show()
    self:SetVisibility(ESlateVisibility.Visible)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        if MainControlPanel.MainControlBaseUI then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        end
        if MainControlPanel.ShootingUIPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end
    self:RefreshAllIconColors()
    self:OnSlotButtonClicked("bailang")
end
-- Set icon brush white.
function shenyin:SetIconBrushWhite(imageWidget)
    if not imageWidget then return end
    local brush = imageWidget:GetBrush()
    if brush then
        brush.TintColor = UGCObjectUtility.NewStruct("SlateColor")
        brush.TintColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
        imageWidget:SetBrush(brush)
    end
end
-- Refresh all icon colors.
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
-- Get ecexp bonus.
function shenyin:GetEcexpBonus(buttonName)
    local cfg = EcexpConfig[buttonName]
    if not cfg then return 0 end
    local lv = self.SlotLevels[buttonName] or 1
    if lv >= MAX_LEVEL then
        return cfg.max
    end
    -- Local helper value for this logic block.
    local bonus = cfg.base + (cfg.max - cfg.base) * (lv - 1) / (MAX_LEVEL - 1)
    return math.floor(bonus)
end
-- Get detail text.
function shenyin:GetDetailText(buttonName)
    local texts = DetailTexts[buttonName]
    if not texts then return "" end
    local quality = self.SlotQualities[buttonName] or 1
    return texts[quality] or texts[#texts]
end
-- Update detail image.
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
-- Get skill path.
function shenyin:GetSkillPath(skillName, quality)
    quality = quality or 1
    if quality <= 1 then
        return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/' .. skillName .. '.' .. skillName .. '_C')
    else
        return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/SY' .. quality .. '/' .. skillName .. '.' .. skillName .. '_C')
    end
end
function shenyin:GetPairByButton(buttonName)
    -- Guard condition before running this branch.
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
    self:UpdateInfoDisplay(buttonName)
    self:UpdateActionButtons()
end
-- Update item images.
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
        if self.Image_itemnumb then
            self.Image_itemnumb:SetBrushFromTexture(texture)
        end
    end
    -- Guard condition before running this branch.
    if self.itemnumb then
        local virtualID = ItemVirtualIDs[buttonName]
        if virtualID then
            local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
            if VIM then
                local count = VIM:GetItemNum(virtualID) or 0
                -- Local helper value for this logic block.
                local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
                local displayCount = math.max(count - pending, 0)
                -- ugcprint("[shenyin] GetItemNum: virtualID=" .. tostring(virtualID) .. ", count=" .. tostring(count) .. ", pending=" .. tostring(pending) .. ", display=" .. tostring(displayCount))
                self.itemnumb:SetText(tostring(displayCount))
            else
                -- Initialize displayed label text.
                self.itemnumb:SetText("0")
            end
        else
            self.itemnumb:SetText("0")
        end
    end
end
-- Update info display.
function shenyin:UpdateInfoDisplay(buttonName)
    local state = self.SlotStates[buttonName]
    local lv = self.SlotLevels[buttonName] or 1
    local cfg = EcexpConfig[buttonName]

    -- Guard condition before running this branch.
    if self.TextBlock_currentlevel then
        if state == STATE_UNLOCK then
            self.TextBlock_currentlevel:SetText("--")
        else
            self.TextBlock_currentlevel:SetText(tostring(lv))
        end
    end

    -- Guard condition before running this branch.
    if self.TextBlock_nextlevel then
        if state == STATE_UNLOCK or lv >= MAX_LEVEL then
            self.TextBlock_nextlevel:SetText("--")
        else
            self.TextBlock_nextlevel:SetText(tostring(lv + 1))
        end
    end

    -- Guard condition before running this branch.
    if self.TextBlock_currentshhuxing then
        if state == STATE_UNLOCK or not cfg then
            self.TextBlock_currentshhuxing:SetText("--")
        else
            local currentBonus = self:GetEcexpBonus(buttonName)
            self.TextBlock_currentshhuxing:SetText(tostring(currentBonus) .. "%")
        end
    end

    -- Guard condition before running this branch.
    if self.TextBlock_nextlevelshuxing then
        if state == STATE_UNLOCK or not cfg or lv >= MAX_LEVEL then
            self.TextBlock_nextlevelshuxing:SetText("--")
        else
            -- Local helper value for this logic block.
            local nextBonus = cfg.base + (cfg.max - cfg.base) * lv / (MAX_LEVEL - 1)
            nextBonus = math.floor(nextBonus)
            self.TextBlock_nextlevelshuxing:SetText(tostring(nextBonus) .. "%")
        end
    end

    -- Guard condition before running this branch.
    if self.TextBlock_jieshao then
        local desc = SkillDescriptions[buttonName]
        if desc then
            self.TextBlock_jieshao:SetText(desc)
        else
            self.TextBlock_jieshao:SetText("")
        end
    end
end

function shenyin:UpdateActionButtons()
    local state = self.SlotStates[self.SelectedButton]
    local lv = self.SlotLevels[self.SelectedButton] or 1
    local quality = self.SlotQualities[self.SelectedButton] or 1
    if self.unlock then
        self.unlock:SetVisibility(state == STATE_UNLOCK and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    end
    if self.wear then
        self.wear:SetVisibility(state == STATE_UNWEAR and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    end
    if self.remove then
        self.remove:SetVisibility(state == STATE_WEAR and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    end
    if self.AddLevel then
        local canLevel = (state ~= STATE_UNLOCK) and (lv < MAX_LEVEL)
        self.AddLevel:SetVisibility(canLevel and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    end
    if self.Addquality then
        local canQuality = (state ~= STATE_UNLOCK) and (quality < MAX_QUALITY)
        self.Addquality:SetVisibility(canQuality and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
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
-- Apply skill.
function shenyin:ApplySkill(skillName, isWear, quality)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local skillPath = self:GetSkillPath(skillName, quality)
    -- ugcprint("[shenyin] ApplySkill: skill=" .. tostring(skillName) .. ", quality=" .. tostring(quality) .. ", isWear=" .. tostring(isWear) .. ", path=" .. tostring(skillPath))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetShenyingSkill", skillPath, isWear)
end
-- Apply ecexp.
function shenyin:ApplyEcexp(amount)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    -- ugcprint("[shenyin] SetShenyinEcexp: " .. tostring(amount))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetShenyinEcexp", amount)
end
-- Handle unlock button click.
function shenyin:OnUnlockClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    -- Local helper value for this logic block.
    local virtualID = ItemVirtualIDs[self.SelectedButton]
    if virtualID then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM then
            local count = VIM:GetItemNum(virtualID) or 0
            local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
            if count - pending < 100 then
                self:ShowTip("解锁所需材料不足")
                return
            end
        end
        -- Keep this section consistent with the original UI flow.
        self.PendingCost = self.PendingCost or {}
        self.PendingCost[virtualID] = (self.PendingCost[virtualID] or 0) + 100
        -- Get player state.
        local PlayerState = UGCGameSystem.GetLocalPlayerState()
        if PlayerState then
            UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", virtualID, 100)
        end
    end
    self.SlotStates[self.SelectedButton] = STATE_UNWEAR
    if self[pair.border] then
        self[pair.border]:SetVisibility(ESlateVisibility.Visible)
        self[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
    end
    if pair.icon and self[pair.icon] then
        self:SetIconBrushWhite(self[pair.icon])
    end
    self:UpdateActionButtons()
    self:UpdateItemImages(self.SelectedButton)
    self:UpdateInfoDisplay(self.SelectedButton)
    self:UpdateLevelDisplay()
    self:SaveToServer()
end
-- Handle wear button click.
function shenyin:OnWearClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    -- Guard condition before running this branch.
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
        self[pair.border]:SetVisibility(ESlateVisibility.Visible)
        self[pair.border]:SetBrushColor({R = 1, G = 1, B = 0, A = 1})
    end
    self:ApplySkill(pair.skill, true, self.SlotQualities[self.SelectedButton])
    self.CurrentEcexpBonus = self:GetEcexpBonus(self.SelectedButton)
    self:ApplyEcexp(self.CurrentEcexpBonus)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("穿戴成功")
end
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
    -- Execute the next UI update step.
    self:ApplySkill(pair.skill, false, self.SlotQualities[self.SelectedButton])
    -- Keep this section consistent with the original UI flow.
    self.CurrentEcexpBonus = 0
    self:ApplyEcexp(0)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("卸下成功")
end
-- Handle add level button click.
function shenyin:OnAddLevelClicked()
    if not self.SelectedButton then return end
    local state = self.SlotStates[self.SelectedButton]
    if state == STATE_UNLOCK then return end
    local lv = self.SlotLevels[self.SelectedButton] or 1
    if lv >= MAX_LEVEL then return end
    -- Local helper value for this logic block.
    local virtualID = ItemVirtualIDs[self.SelectedButton]
    if virtualID then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM then
            local count = VIM:GetItemNum(virtualID) or 0
            -- Local helper value for this logic block.
            local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
            if count - pending < 1 then
                self:ShowTip("升级所需材料不足")
                return
            end
        end
        -- Keep this section consistent with the original UI flow.
        self.PendingCost = self.PendingCost or {}
        self.PendingCost[virtualID] = (self.PendingCost[virtualID] or 0) + 1
        -- Get player state.
        local PlayerState = UGCGameSystem.GetLocalPlayerState()
        if PlayerState then
            UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", virtualID, 1)
        end
    end
    self.SlotLevels[self.SelectedButton] = lv + 1
    -- Guard condition before running this branch.
    if state == STATE_WEAR then
        local newBonus = self:GetEcexpBonus(self.SelectedButton)
        if newBonus ~= self.CurrentEcexpBonus then
            self.CurrentEcexpBonus = newBonus
            self:ApplyEcexp(newBonus)
        end
    end
    self:UpdateLevelDisplay()
    self:UpdateInfoDisplay(self.SelectedButton)
    self:UpdateItemImages(self.SelectedButton)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("等级提升成功")
end
-- Handle add quality button click.
function shenyin:OnAddQualityClicked()
    if not self.SelectedButton then return end
    local state = self.SlotStates[self.SelectedButton]
    if state == STATE_UNLOCK then return end
    local quality = self.SlotQualities[self.SelectedButton] or 1
    if quality >= MAX_QUALITY then return end
    -- Local helper value for this logic block.
    local virtualID = ItemVirtualIDs[self.SelectedButton]
    if virtualID then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM then
            local count = VIM:GetItemNum(virtualID) or 0
            local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
            if count - pending < 100 then
                self:ShowTip("升级所需材料不足")
                return
            end
        end
        -- Keep this section consistent with the original UI flow.
        self.PendingCost = self.PendingCost or {}
        self.PendingCost[virtualID] = (self.PendingCost[virtualID] or 0) + 100
        -- Get player state.
        local PlayerState = UGCGameSystem.GetLocalPlayerState()
        if PlayerState then
            UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", virtualID, 100)
        end
    end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    self.SlotQualities[self.SelectedButton] = quality + 1
    -- Guard condition before running this branch.
    if state == STATE_WEAR then
        self:ApplySkill(pair.skill, true, quality + 1)
    end
    -- Guard condition before running this branch.
    if self.detail then
        self.detail:SetText(self:GetDetailText(self.SelectedButton))
    end
    self:UpdateDetailImage(self.SelectedButton)
    self:UpdateInfoDisplay(self.SelectedButton)
    self:UpdateItemImages(self.SelectedButton)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("品质提升成功")
end
function shenyin:OnCancelClicked()
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        if MainControlPanel.MainControlBaseUI then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        end
        if MainControlPanel.ShootingUIPanel then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end
    self:SetVisibility(ESlateVisibility.Collapsed)
end
-- Serialize data.
function shenyin:SerializeData()
    local parts = {}
    -- Local helper value for this logic block.
    local s = self.SlotStates["bailang"] or STATE_UNWEAR
    local l = self.SlotLevels["bailang"] or 1
    local q = self.SlotQualities["bailang"] or 1
    table.insert(parts, "bailang:" .. s .. ":" .. tostring(l) .. ":" .. tostring(q))
    -- Iterate through related data or widgets.
    for _, pair in ipairs(ButtonBorderMap) do
        local st = self.SlotStates[pair.button] or STATE_UNLOCK
        local lv = self.SlotLevels[pair.button] or 1
        local qu = self.SlotQualities[pair.button] or 1
        table.insert(parts, pair.button .. ":" .. st .. ":" .. tostring(lv) .. ":" .. tostring(qu))
    end
    return table.concat(parts, ";")
end

-- Deserialize data.
function shenyin:DeserializeData(dataStr)
    if not dataStr or dataStr == "" then return end
    for entry in string.gmatch(dataStr, "([^;]+)") do
        local btn, st, lv, qu = string.match(entry, "([^:]+):([^:]+):([^:]+):([^:]+)")
        if btn and st then
            self.SlotStates[btn] = st
            self.SlotLevels[btn] = tonumber(lv) or 1
            self.SlotQualities[btn] = tonumber(qu) or 1
        end
    end
    -- Keep this section consistent with the original UI flow.
end

-- Load saved data.
function shenyin:LoadSavedData(dataStr)
    -- ugcprint("[shenyin] LoadSavedData: " .. tostring(dataStr))
    self:DeserializeData(dataStr)
end

-- Save to server.
function shenyin:SaveToServer()
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        local dataStr = self:SerializeData()
        -- ugcprint("[shenyin] SaveToServer: " .. tostring(dataStr))
        UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SaveShenyinData", dataStr)
    end
end

function shenyin:Destruct()
    -- Local helper value for this logic block.
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if VIM then
        VIM.OnItemNumUpdatedDelegate:Remove(self.OnItemNumUpdated, self)
    end
end
-- Handle item num updated event.
function shenyin:OnItemNumUpdated()
    -- Keep this section consistent with the original UI flow.
    self.PendingCost = {}
    if self.SelectedButton then
        self:UpdateItemImages(self.SelectedButton)
    end
end
-- Show tip.
function shenyin:ShowTip(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end
return shenyin
