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
---@field Image_1 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_8 UImage
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
    { button = "Button_2", border = "Border_2", image = "Image_2", skill = "lvse",    icon = "Image_qingshe" },
    { button = "Button_3", border = "Border_3", image = "Image_3", skill = "lanse",   icon = "Image_baihu" },
    { button = "Button_4", border = "Border_4", image = "Image_4", skill = "zise",    icon = "Image_baize" },
    { button = "Button_5", border = "Border_5", image = "Image_5", skill = "chengse", icon = "Image_qiling" },
    { button = "Button_6", border = "Border_6", image = "Image_6", skill = "hongse",  icon = "Image_fenghuang" },
    { button = "Button_7", border = "Border_7", image = "Image_7", skill = "jinse",   icon = "Image_shenlong" },
}
-- Configuration table used by this widget.
local DetailTexts = {
    bailang  = { "閻х晫瀚?, "闂囨粎澧惂鐣屽", "鐎垫帡鏀遍崯鍝ュ", "閺嬩礁顧侀棁婊堢搳璺惂鐣屽", "婢垛晝鈹曢崙娑樺璺崳顒佹箑閹存瀚? },
    Button_2 = { "闂堟帟娉?, "楠炶棄濂栭棃鎺曟厂", "濮ｆ帒濂栭獮鍊熸厂", "閼诲秵绗傞獮钘夊璺棃鎺曟厂", "娑撳洦鐦ㄩ崘銉ュ璺崳顒勭搳姒瑨娉? },
    Button_3 = { "閽冩繆妾?, "闂嗙兘顥撻拑婵婃", "濞屟囨祫閹存妾?, "濞屟勭熬闂嗗嘲鏆╄矾閹存妾?, "娑旀繈娓奸梹鍥ф袱璺憗鍌溾敄婢垛晞妾? },
    Button_4 = { "閻ц姤杈?, "缁鳖偅娲旈惂鑺ヨ景", "閺勭喎顕ラ惂鑺ヨ景", "缁鳖偄顔忔径鈺佹儙璺惂鑺ヨ景", "妤﹁儻鎸嬮搹姘暔璺稉鍥╀紥缁佺偞杈? },
    Button_5 = { "妤规帡绨?, "閻愬氦顫楁ス鎺楃熬", "閻掓艾銇夐悷鐐虹熬", "閻愬海瀚抽梹鍥︾瑯璺ス鎺楃熬", "婢额亜褰滃ú顏囧礆璺稉鍥у悢缁佹牠绨? },
    Button_6 = { "閸戙倕鍤?, "鐠с倗鍔欓崙銈呭殺", "閻戭剛浼€閸戜即绗?, "閻掓艾銇夊☉鍛潏璺悘顐㈠殺", "娑旀繂銇夊鍝ュ劯璺稉宥嗩劥缁佺偛鍤? },
    Button_7 = { "缁佺偤绶?, "閸岃弓绗橀柌鎴︾烦", "缁岀懓銇夐懟宥夌烦", "鐎垫澘鐣ら梹鍥︾瑯璺柌鎴︾烦", "濞ｉ攱鐭婇崗鍐潗璺稉鍥烦娑斿顨? },
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
    bailang  = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊40%閻ㄥ嫪婵€鐎?,
    Button_2 = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊80%閻ㄥ嫪婵€鐎?,
    Button_3 = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊120%閻ㄥ嫪婵€鐎?,
    Button_4 = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊160%閻ㄥ嫪婵€鐎?,
    Button_5 = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊200%閻ㄥ嫪婵€鐎?,
    Button_6 = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊300%閻ㄥ嫪婵€鐎?,
    Button_7 = "濮?缁夋帒鎮滈崨銊ユ纯閻ㄥ嫪琚辨稉顏呮櫕娴滄椽妾锋稉瀣殻閸忚棄鈻夐崢瀣剁礉闁姵鍨氶張鈧径褏鏁撻崨钘夊500%閻ㄥ嫪婵€鐎?,
}
local STATE_UNLOCK = "unlock"
local STATE_UNWEAR = "unwear"
local STATE_WEAR   = "wear"
local MAX_QUALITY = 5
local MAX_LEVEL = 100
function shenyin:Construct()
    self:LuaInit()
    self.SlotStates = {}
    self.SlotLevels = {} -- 
    self.SlotQualities = {} -- 
    -- Keep this section consistent with the original UI flow.
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

    -- Acquire local player references.
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.SavedShenyinData and PC.SavedShenyinData ~= "" then
        self:LoadSavedData(PC.SavedShenyinData)
    end

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
    -- Local helper value for this logic block.
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if VIM then
        VIM.OnItemNumUpdatedDelegate:Add(self.OnItemNumUpdated, self)
    end
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
    -- Refresh UI to match current data state.
    self:RefreshAllIconColors()
    -- Execute the next UI update step.
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
        self.unlock:SetVisibility(state == STATE_UNLOCK and 0 or 1)
    end
    if self.wear then
        self.wear:SetVisibility(state == STATE_UNWEAR and 0 or 1)
    end
    if self.remove then
        self.remove:SetVisibility(state == STATE_WEAR and 0 or 1)
    end
    -- Guard condition before running this branch.
    if self.AddLevel then
        local canLevel = (state ~= STATE_UNLOCK) and (lv < MAX_LEVEL)
        self.AddLevel:SetVisibility(canLevel and 0 or 1)
    end
    -- Guard condition before running this branch.
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
                self:ShowTip("绾板海澧栨稉宥堝喕閿涘矁袙闁夸線娓剁憰?00娑擃亞顣抽悧?)
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
        self[pair.border]:SetVisibility(0)
        self[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
    end
    -- Guard condition before running this branch.
    if pair.icon and self[pair.icon] then
        -- Execute the next UI update step.
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
        self[pair.border]:SetVisibility(0)
        self[pair.border]:SetBrushColor({R = 1, G = 1, B = 0, A = 1})
    end
    -- Execute the next UI update step.
    self:ApplySkill(pair.skill, true, self.SlotQualities[self.SelectedButton])
    -- Keep this section consistent with the original UI flow.
    self.CurrentEcexpBonus = self:GetEcexpBonus(self.SelectedButton)
    self:ApplyEcexp(self.CurrentEcexpBonus)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("瀹歌尙鈹涢幋?)
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
    self:ShowTip("瀹告彃宓忔稉?)
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
                self:ShowTip("绾板海澧栨稉宥堝喕")
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
    self:ShowTip("閸楀洨楠囬幋鎰")
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
                self:ShowTip("绾板海澧栨稉宥堝喕")
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
    self:ShowTip("鏉╂盯妯侀幋鎰")
end
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
