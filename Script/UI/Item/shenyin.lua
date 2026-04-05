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
-- 姣忎釜Button鎸夊搧璐ㄧ殑浠嬬粛鏂囨湰锛堝搧璐?~5锛?local DetailTexts = {
    bailang  = { "鐧界嫾", "闇滅墮鐧界嫾", "瀵掗攱鍟哥嫾", "鏋佸闇滈瓊路鐧界嫾", "澶╃┕鍑涘奖路鍣湀鎴樼嫾" },
    Button_2 = { "闈掕泧", "骞藉奖闈掕泧", "姣掑奖骞借泧", "鑻嶆笂骞藉奖路闈掕泧", "涓囨瘨鍐ュ奖路鍣瓊榫欒泧" },
    Button_3 = { "钃濊檸", "闆烽钃濊檸", "娌ч浄鎴樿檸", "娌ф簾闆峰暩路鎴樿檸", "涔濋渼闀囧渤路瑁傜┖澶╄檸" },
    Button_4 = { "鐧芥辰", "绱洔鐧芥辰", "鏄熷鐧芥辰", "绱澶╁惎路鐧芥辰", "楦胯挋铏氬路涓囩伒绁炴辰" },
    Button_5 = { "楹掗簾", "鐐庤楹掗簾", "鐒氬ぉ鐟為簾", "鐐庣嫳闀囦笘路楹掗簾", "澶彜娲崚路涓囧吔绁栭簾" },
    Button_6 = { "鍑ゅ嚢", "璧ょ劙鍑ゅ嚢", "鐑伀鍑伴笩", "鐒氬ぉ娑呮路鐏嚢", "涔濆ぉ姘哥儸路涓嶆绁炲嚢" },
    Button_7 = { "绁為緳", "鍌蹭笘閲戦緳", "绌瑰ぉ鑻嶉緳", "瀵板畤闀囦笘路閲戦緳", "娣锋矊鍏冨路涓囬緳涔嬬" },
}
-- 姣忎釜绁炲奖鎸夊搧璐ㄥ搴旂殑鍥剧墖鍚嶏紙鍝佽川1~5锛?-- 鍥剧墖璺緞鏍煎紡: PNG/shenyin/XXX.XXX
local DetailImages = {
    bailang  = { "bailang1", "bailang2", "bailang3", "bailang4", "bailang5" },
    Button_2 = { "qingshe1", "qingshe2", "qingshe3", "qingshe4", "qingshe5" },
    Button_3 = { "baihu1", "baihu2", "baihu3", "baihu4", "baihu5" },
    Button_4 = { "baize1", "baize2", "baize3", "baize4", "baize5" },
    Button_5 = { "qiling1", "qiling2", "qiling3", "qiling4", "qiling5" },
    Button_6 = { "fenghuang1", "fenghuang2", "fenghuang3", "fenghuang4", "fenghuang5" },
    Button_7 = { "shenlong1", "shenlong2", "shenlong3", "shenlong4", "shenlong5" },
}
-- 姣忎釜Button鐨勫悶鍣€嶇巼閰嶇疆: {鍩虹鍊嶇巼, 100绾у€嶇巼}
local EcexpConfig = {
    bailang  = { base = 100,  max = 200 },
    Button_2 = { base = 200,  max = 400 },
    Button_3 = { base = 300,  max = 600 },
    Button_4 = { base = 400,  max = 800 },
    Button_5 = { base = 500,  max = 1000 },
    Button_6 = { base = 750,  max = 1500 },
    Button_7 = { base = 1000, max = 2000 },
}
-- 姣忎釜绁炲奖瀵瑰簲鐨勫崌绾?鍗囧搧鏉愭枡鍥剧墖鍚嶏紙璺緞: PNG/shenjian/XXX.XXX锛?local ItemImages = {
    bailang  = "sp1",
    Button_2 = "sp2",
    Button_3 = "sp3",
    Button_4 = "sp4",
    Button_5 = "sp5",
    Button_6 = "sp6",
    Button_7 = "sp7",
}
-- 姣忎釜绁炲奖瀵瑰簲鐨勮櫄鎷熺墿鍝両D锛堢鐗囷級
local ItemVirtualIDs = {
    bailang  = 5001,
    Button_2 = 5002,
    Button_3 = 5003,
    Button_4 = 5004,
    Button_5 = 5005,
    Button_6 = 5006,
    Button_7 = 5007,
}
-- 姣忎釜绁炲奖鐨勬妧鑳戒粙缁?local SkillDescriptions = {
    bailang  = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏40%鐨勪激瀹?,
    Button_2 = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏80%鐨勪激瀹?,
    Button_3 = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏120%鐨勪激瀹?,
    Button_4 = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏160%鐨勪激瀹?,
    Button_5 = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏200%鐨勪激瀹?,
    Button_6 = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏300%鐨勪激瀹?,
    Button_7 = "姣?绉掑悜鍛ㄥ洿鐨勪袱涓晫浜洪檷涓嬬鍏藉▉鍘嬶紝閫犳垚鏈€澶х敓鍛藉姏500%鐨勪激瀹?,
}
local STATE_UNLOCK = "unlock"
local STATE_UNWEAR = "unwear"
local STATE_WEAR   = "wear"
local MAX_QUALITY = 5
local MAX_LEVEL = 100
function shenyin:Construct()
    self:LuaInit()
    self.SlotStates = {}
    self.SlotLevels = {}    -- 绛夌骇 1~100
    self.SlotQualities = {} -- 鍝佽川 1~5
    -- 鍒濆鍖栫櫧鐙硷紙榛樿宸茶В閿佹湭绌挎埓锛?    self.SlotStates["bailang"] = STATE_UNWEAR
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

    -- 浠嶱C璇诲彇瀛樻。鏁版嵁
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
    -- 鐩戝惉铏氭嫙鐗╁搧鏁伴噺鍙樺寲锛屽強鏃跺埛鏂扮鐗囨樉绀?    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
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
    -- 鍒锋柊鎵€鏈夊浘鏍囬鑹茬姸鎬?    self:RefreshAllIconColors()
    -- 姣忔鎵撳紑榛樿閫変腑鐧界嫾
    self:OnSlotButtonClicked("bailang")
end
-- 璁剧疆UImage鐨凚rush鐫€鑹诧紙TintColor锛変负鐧借壊
function shenyin:SetIconBrushWhite(imageWidget)
    if not imageWidget then return end
    local brush = imageWidget:GetBrush()
    if brush then
        brush.TintColor = UGCObjectUtility.NewStruct("SlateColor")
        brush.TintColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
        imageWidget:SetBrush(brush)
    end
end
-- 鍒锋柊鎵€鏈夌褰卞浘鏍囩殑棰滆壊锛堝凡瑙ｉ攣=鐧借壊锛屾湭瑙ｉ攣=淇濇寔榛樿鐏拌壊锛?function shenyin:RefreshAllIconColors()
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
-- 鑾峰彇褰撳墠閫変腑鎸夐挳鐨勫悶鍣€嶇巼锛堟寜绛夌骇绾挎€ф彃鍊硷細1绾?base锛?00绾?max锛?function shenyin:GetEcexpBonus(buttonName)
    local cfg = EcexpConfig[buttonName]
    if not cfg then return 0 end
    local lv = self.SlotLevels[buttonName] or 1
    if lv >= MAX_LEVEL then
        return cfg.max
    end
    -- 1绾?base, 100绾?max, 绾挎€ф彃鍊?    local bonus = cfg.base + (cfg.max - cfg.base) * (lv - 1) / (MAX_LEVEL - 1)
    return math.floor(bonus)
end
-- 鑾峰彇鍝佽川瀵瑰簲鐨勫悕瀛?function shenyin:GetDetailText(buttonName)
    local texts = DetailTexts[buttonName]
    if not texts then return "" end
    local quality = self.SlotQualities[buttonName] or 1
    return texts[quality] or texts[#texts]
end
-- 鏇存柊璇︽儏鍥剧墖锛堟牴鎹綋鍓嶉€変腑鐨勭褰卞拰鍝佽川锛?function shenyin:UpdateDetailImage(buttonName)
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
-- 鑾峰彇鎶€鑳借矾寰勶紙鏍规嵁鍝佽川锛?function shenyin:GetSkillPath(skillName, quality)
    quality = quality or 1
    if quality <= 1 then
        return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/' .. skillName .. '.' .. skillName .. '_C')
    else
        return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/SY' .. quality .. '/' .. skillName .. '.' .. skillName .. '_C')
    end
end
function shenyin:GetPairByButton(buttonName)
    -- 鐧界嫾鐗规畩澶勭悊锛堟病鏈夋寜閽?杈规鎺т欢锛?    if buttonName == "bailang" then
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
-- 鏇存柊鍗囩骇/鍗囧搧鏉愭枡鍥剧墖
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
    -- 鏇存柊纰庣墖鏁伴噺鏄剧ず
    if self.itemnumb then
        local virtualID = ItemVirtualIDs[buttonName]
        if virtualID then
            local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
            if VIM then
                local count = VIM:GetItemNum(virtualID) or 0
                -- 鍑忓幓鏈湴棰勬墸鏁伴噺
                local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
                local displayCount = math.max(count - pending, 0)
                -- ugcprint("[shenyin] GetItemNum: virtualID=" .. tostring(virtualID) .. ", count=" .. tostring(count) .. ", pending=" .. tostring(pending) .. ", display=" .. tostring(displayCount))
                self.itemnumb:SetText(tostring(displayCount))
            else
                -- ugcprint("[shenyin] 閿欒锛氭棤娉曡幏鍙朧irtualItemManager")
                self.itemnumb:SetText("0")
            end
        else
            self.itemnumb:SetText("0")
        end
    end
end
-- 鏇存柊淇℃伅鏄剧ず锛堝綋鍓嶇瓑绾с€佷笅涓€绛夌骇銆佸悶鍣€嶇巼銆佹妧鑳戒粙缁嶏級
function shenyin:UpdateInfoDisplay(buttonName)
    local state = self.SlotStates[buttonName]
    local lv = self.SlotLevels[buttonName] or 1
    local cfg = EcexpConfig[buttonName]

    -- 褰撳墠绛夌骇
    if self.TextBlock_currentlevel then
        if state == STATE_UNLOCK then
            self.TextBlock_currentlevel:SetText("--")
        else
            self.TextBlock_currentlevel:SetText(tostring(lv))
        end
    end

    -- 涓嬩竴绛夌骇
    if self.TextBlock_nextlevel then
        if state == STATE_UNLOCK or lv >= MAX_LEVEL then
            self.TextBlock_nextlevel:SetText("--")
        else
            self.TextBlock_nextlevel:SetText(tostring(lv + 1))
        end
    end

    -- 褰撳墠绛夌骇鍚炲櫖鍊嶇巼
    if self.TextBlock_currentshhuxing then
        if state == STATE_UNLOCK or not cfg then
            self.TextBlock_currentshhuxing:SetText("--")
        else
            local currentBonus = self:GetEcexpBonus(buttonName)
            self.TextBlock_currentshhuxing:SetText(tostring(currentBonus) .. "%")
        end
    end

    -- 涓嬩竴绛夌骇鍚炲櫖鍊嶇巼
    if self.TextBlock_nextlevelshuxing then
        if state == STATE_UNLOCK or not cfg or lv >= MAX_LEVEL then
            self.TextBlock_nextlevelshuxing:SetText("--")
        else
            -- 涓存椂璁＄畻涓嬩竴绾х殑鍊嶇巼
            local nextBonus = cfg.base + (cfg.max - cfg.base) * lv / (MAX_LEVEL - 1)
            nextBonus = math.floor(nextBonus)
            self.TextBlock_nextlevelshuxing:SetText(tostring(nextBonus) .. "%")
        end
    end

    -- 鎶€鑳戒粙缁?    if self.TextBlock_jieshao then
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
    -- 宸茶В閿佷笖鏈弧绾ф椂鏄剧ず鍗囩骇鎸夐挳
    if self.AddLevel then
        local canLevel = (state ~= STATE_UNLOCK) and (lv < MAX_LEVEL)
        self.AddLevel:SetVisibility(canLevel and 0 or 1)
    end
    -- 宸茶В閿佷笖鏈弧鍝佽川鏃舵樉绀哄崌鍝佹寜閽?    if self.Addquality then
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
-- 閫氳繃RPC鍦ㄦ湇鍔＄娣诲姞/绉婚櫎琚姩鎶€鑳?+ 澧炲噺Ecexp
function shenyin:ApplySkill(skillName, isWear, quality)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local skillPath = self:GetSkillPath(skillName, quality)
    -- ugcprint("[shenyin] ApplySkill: skill=" .. tostring(skillName) .. ", quality=" .. tostring(quality) .. ", isWear=" .. tostring(isWear) .. ", path=" .. tostring(skillPath))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetShenyingSkill", skillPath, isWear)
end
-- 閫氳繃RPC璁剧疆绁炲奖涓存椂Ecexp锛堢洿鎺ヨ缃€硷紝涓嶆槸鍔犲噺锛?function shenyin:ApplyEcexp(amount)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    -- ugcprint("[shenyin] SetShenyinEcexp: " .. tostring(amount))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetShenyinEcexp", amount)
end
-- 瑙ｉ攣
function shenyin:OnUnlockClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    -- 瑙ｉ攣闇€瑕佹秷鑰?00涓鐗?    local virtualID = ItemVirtualIDs[self.SelectedButton]
    if virtualID then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM then
            local count = VIM:GetItemNum(virtualID) or 0
            local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
            if count - pending < 100 then
                self:ShowTip("纰庣墖涓嶈冻锛岃В閿侀渶瑕?00涓鐗?)
                return
            end
        end
        -- 鏈湴棰勬墸
        self.PendingCost = self.PendingCost or {}
        self.PendingCost[virtualID] = (self.PendingCost[virtualID] or 0) + 100
        -- 閫氳繃RPC鍦ㄦ湇鍔＄娑堣€楃鐗?        local PlayerState = UGCGameSystem.GetLocalPlayerState()
        if PlayerState then
            UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", virtualID, 100)
        end
    end
    self.SlotStates[self.SelectedButton] = STATE_UNWEAR
    if self[pair.border] then
        self[pair.border]:SetVisibility(0)
        self[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
    end
    -- 瑙ｉ攣鍚庢妸瀵瑰簲鍥剧墖鐨凚rush鐫€鑹茶涓虹櫧鑹?FFFFFFFF)
    if pair.icon and self[pair.icon] then
        -- ugcprint("[shenyin] OnUnlockClicked: 璁剧疆Brush TintColor涓虹櫧鑹? icon=" .. tostring(pair.icon))
        self:SetIconBrushWhite(self[pair.icon])
    end
    self:UpdateActionButtons()
    self:UpdateItemImages(self.SelectedButton)
    self:UpdateInfoDisplay(self.SelectedButton)
    self:UpdateLevelDisplay()
    self:SaveToServer()
end
-- 绌挎埓
function shenyin:OnWearClicked()
    if not self.SelectedButton then return end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    -- 鍗镐笅鏃х殑锛圲I鐘舵€侊級
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
    -- 搴旂敤鎶€鑳斤紙鍝佽川鍐冲畾璺緞锛?    self:ApplySkill(pair.skill, true, self.SlotQualities[self.SelectedButton])
    -- 璁剧疆绁炲奖涓存椂Ecexp
    self.CurrentEcexpBonus = self:GetEcexpBonus(self.SelectedButton)
    self:ApplyEcexp(self.CurrentEcexpBonus)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("宸茬┛鎴?)
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
    -- 绉婚櫎鎶€鑳?    self:ApplySkill(pair.skill, false, self.SlotQualities[self.SelectedButton])
    -- 娓呴櫎绁炲奖涓存椂Ecexp
    self.CurrentEcexpBonus = 0
    self:ApplyEcexp(0)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("宸插嵏涓?)
end
-- 鍙崌绛夌骇锛岀┛鎴翠腑鍒欐洿鏂癊cexp鍔犳垚
function shenyin:OnAddLevelClicked()
    if not self.SelectedButton then return end
    local state = self.SlotStates[self.SelectedButton]
    if state == STATE_UNLOCK then return end
    local lv = self.SlotLevels[self.SelectedButton] or 1
    if lv >= MAX_LEVEL then return end
    -- 妫€鏌ョ鐗囨槸鍚﹁冻澶燂紙鍗囩骇娑堣€?涓級
    local virtualID = ItemVirtualIDs[self.SelectedButton]
    if virtualID then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM then
            local count = VIM:GetItemNum(virtualID) or 0
            -- 鍔犱笂鏈湴棰勬墸鏁伴噺鍋氬垽鏂?            local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
            if count - pending < 1 then
                self:ShowTip("纰庣墖涓嶈冻")
                return
            end
        end
        -- 鏈湴棰勬墸
        self.PendingCost = self.PendingCost or {}
        self.PendingCost[virtualID] = (self.PendingCost[virtualID] or 0) + 1
        -- 閫氳繃RPC鍦ㄦ湇鍔＄娑堣€楃鐗?        local PlayerState = UGCGameSystem.GetLocalPlayerState()
        if PlayerState then
            UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", virtualID, 1)
        end
    end
    self.SlotLevels[self.SelectedButton] = lv + 1
    -- 濡傛灉姝ｅ湪绌挎埓锛屾鏌cexp鏄惁鍥犲埌100绾ц€屽彉鍖?    if state == STATE_WEAR then
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
    self:ShowTip("鍗囩骇鎴愬姛")
end
-- 鍗囧搧璐紝鏀瑰彉鎶€鑳借矾寰勫拰detail鍚嶅瓧
function shenyin:OnAddQualityClicked()
    if not self.SelectedButton then return end
    local state = self.SlotStates[self.SelectedButton]
    if state == STATE_UNLOCK then return end
    local quality = self.SlotQualities[self.SelectedButton] or 1
    if quality >= MAX_QUALITY then return end
    -- 妫€鏌ョ鐗囨槸鍚﹁冻澶燂紙杩涢樁娑堣€?00涓級
    local virtualID = ItemVirtualIDs[self.SelectedButton]
    if virtualID then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM then
            local count = VIM:GetItemNum(virtualID) or 0
            local pending = (self.PendingCost and self.PendingCost[virtualID]) or 0
            if count - pending < 100 then
                self:ShowTip("纰庣墖涓嶈冻")
                return
            end
        end
        -- 鏈湴棰勬墸
        self.PendingCost = self.PendingCost or {}
        self.PendingCost[virtualID] = (self.PendingCost[virtualID] or 0) + 100
        -- 閫氳繃RPC鍦ㄦ湇鍔＄娑堣€楃鐗?        local PlayerState = UGCGameSystem.GetLocalPlayerState()
        if PlayerState then
            UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", virtualID, 100)
        end
    end
    local pair = self:GetPairByButton(self.SelectedButton)
    if not pair then return end
    self.SlotQualities[self.SelectedButton] = quality + 1
    -- 濡傛灉姝ｅ湪绌挎埓锛岄噸鏂板簲鐢ㄦ柊鍝佽川鎶€鑳?    if state == STATE_WEAR then
        self:ApplySkill(pair.skill, true, quality + 1)
    end
    -- 鍒锋柊detail鍚嶅瓧鍜屽浘鐗?    if self.detail then
        self.detail:SetText(self:GetDetailText(self.SelectedButton))
    end
    self:UpdateDetailImage(self.SelectedButton)
    self:UpdateInfoDisplay(self.SelectedButton)
    self:UpdateItemImages(self.SelectedButton)
    self:UpdateActionButtons()
    self:SaveToServer()
    self:ShowTip("杩涢樁鎴愬姛")
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
-- 搴忓垪鍖栫褰辨暟鎹负瀛楃涓诧細button:state:level:quality;button:state:level:quality;...
function shenyin:SerializeData()
    local parts = {}
    -- 鐧界嫾
    local s = self.SlotStates["bailang"] or STATE_UNWEAR
    local l = self.SlotLevels["bailang"] or 1
    local q = self.SlotQualities["bailang"] or 1
    table.insert(parts, "bailang:" .. s .. ":" .. tostring(l) .. ":" .. tostring(q))
    -- 鍏朵粬绁炲奖
    for _, pair in ipairs(ButtonBorderMap) do
        local st = self.SlotStates[pair.button] or STATE_UNLOCK
        local lv = self.SlotLevels[pair.button] or 1
        local qu = self.SlotQualities[pair.button] or 1
        table.insert(parts, pair.button .. ":" .. st .. ":" .. tostring(lv) .. ":" .. tostring(qu))
    end
    return table.concat(parts, ";")
end

-- 鍙嶅簭鍒楀寲瀛楃涓叉仮澶嶇褰辨暟鎹?function shenyin:DeserializeData(dataStr)
    if not dataStr or dataStr == "" then return end
    for entry in string.gmatch(dataStr, "([^;]+)") do
        local btn, st, lv, qu = string.match(entry, "([^:]+):([^:]+):([^:]+):([^:]+)")
        if btn and st then
            self.SlotStates[btn] = st
            self.SlotLevels[btn] = tonumber(lv) or 1
            self.SlotQualities[btn] = tonumber(qu) or 1
        end
    end
    -- ugcprint("[shenyin] DeserializeData 瀹屾垚")
end

-- 浠庢湇鍔＄鍚屾鐨勫瓨妗ｆ暟鎹姞杞?function shenyin:LoadSavedData(dataStr)
    -- ugcprint("[shenyin] LoadSavedData: " .. tostring(dataStr))
    self:DeserializeData(dataStr)
end

-- 閫氱煡鏈嶅姟绔繚瀛樼褰辨暟鎹?function shenyin:SaveToServer()
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        local dataStr = self:SerializeData()
        -- ugcprint("[shenyin] SaveToServer: " .. tostring(dataStr))
        UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SaveShenyinData", dataStr)
    end
end

function shenyin:Destruct()
    -- 绉婚櫎铏氭嫙鐗╁搧鏁伴噺鍙樺寲鐩戝惉
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if VIM then
        VIM.OnItemNumUpdatedDelegate:Remove(self.OnItemNumUpdated, self)
    end
end
-- 铏氭嫙鐗╁搧鏁伴噺鍙樺寲鍥炶皟锛屽埛鏂板綋鍓嶉€変腑绁炲奖鐨勭鐗囨暟閲?function shenyin:OnItemNumUpdated()
    -- 鏈嶅姟绔暟閲忓凡鍚屾锛屾竻闄ゆ湰鍦伴鎵?    self.PendingCost = {}
    if self.SelectedButton then
        self:UpdateItemImages(self.SelectedButton)
    end
end
-- 鏄剧ず鎻愮ず淇℃伅锛堥€氳繃MMainUI锛?function shenyin:ShowTip(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end
return shenyin
