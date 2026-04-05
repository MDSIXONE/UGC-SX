---@class jiange_C:UUserWidget
---@field cancel UButton
---@field duanzhaoshi UImage
---@field Image_0 UImage
---@field Image_2 UImage
---@field levelup UButton
---@field name UTextBlock
---@field ProgressBar_level UProgressBar
---@field TextBlock_current UTextBlock
---@field TextBlock_detail UTextBlock
---@field TextBlock_need UTextBlock
---@field TextBlock_skill UTextBlock
---@field wear UButton
---@field weartip UTextBlock
--Edit Below--
local jiange = { bInitDoOnce = false }

-- Configuration table used by this widget.
local SWORD_LEVELS = {
    {
        name = "閸熷憡婀€鐎垫帡鏀?,
        skill = "bailangjian",
        icon = "bailangjian",
        atkPercent = 100,
        upgradeCost = 1,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插100%",
        skillDesc = "閻欒偐鍏㈤崯鍛婃箑閿涘苯澧ら崗澶婎洤閺堝牅绗呯€垫帡婀濋敍宀勬敱閸掆晠姣﹂幐掳鈧倹鐦＄粔鎺戞倻閸撳秵鏌熼崣鎴濈殸娑撯偓閺嬫岸顥ｉ崜鎴礉娴笺倕顔婃稉鐑樻暰閸戣濮忛惃?00%",
    },
    {
        name = "楠炶棄鍟ｅВ鎺戝ⅳ",
        skill = "kuishejian",
        icon = "kuishejian",
        atkPercent = 200,
        upgradeCost = 2,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插200%",
        skillDesc = "濮ｆ帟娉ф俊鍌氳弴閸愩儲娼冮幍瀣剁礉閸撴垵鍨夐懛顏勭敨閸撗勭槰閵嗗倹鐦＄粔鎺戞倻閸撳秵鏌熼崣鎴濈殸娑撯偓閺嬫岸顥ｉ崜鎴礉娴笺倕顔婃稉鐑樻暰閸戣濮忛惃?00%",
    },
    {
        name = "閻у€熸闂囨粓鐡岄崜?,
        skill = "baihujian",
        icon = "baihujian",
        atkPercent = 200,
        upgradeCost = 3,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插200%",
        skillDesc = "閻у€熸閸戞繄宸归崘棰佺閸旀冻绱濇稉缁樻絻娴兼劧绱濋拺鏉戞儓閺冪姴鏁栫€垫帒鍟叉稊瀣毜閵嗗倹鐦＄粔鎺戞倻閸撳秵鏌熼崣鎴濈殸娑撯偓閺嬫岸顥ｉ崜鎴礉娴笺倕顔婃稉鐑樻暰閸戣濮忛惃?00%",
    },
    {
        name = "閻ц姤杈伴惍鎾亼閸?,
        skill = "bifangjian",
        icon = "baizejian",
        atkPercent = 300,
        upgradeCost = 4,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插300%",
        skillDesc = "閻ц姤杈伴惌銉︽娑撳洨澧块敍灞藉讲閻挳娅庢稉鈧崚鍥у鐠炩€虫嫲闁亞顨ら妴鍌涚槨缁夋帒鎮滈崜宥嗘煙閸欐垵鐨犳稉鈧弸姘额棧閸撴埊绱濇导銈咁唺娑撶儤鏁鹃崙璇插閻?00%",
    },
    {
        name = "妤规帡绨鹃梹鍥с亯閸?,
        skill = "qilingjian",
        icon = "qilingjian",
        atkPercent = 400,
        upgradeCost = 5,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插400%",
        skillDesc = "妤规帡绨炬稉铏规喓閸忔垝绠ｆ＃鏍电礉閽戞潙鎯堝ù鎴濆袱婢堆冩勾娑斿濮忛妴鍌涚槨缁夋帒鎮滈崜宥嗘煙閸欐垵鐨犳稉鈧弸姘额棧閸撴埊绱濇导銈咁唺娑撶儤鏁鹃崙璇插閻?00%",
    },
    {
        name = "閸戙倕鍤㈠☉鍛潏閸?,
        skill = "zhuquejian",
        icon = "fenhuanjian",
        atkPercent = 500,
        upgradeCost = 10,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插500%",
        skillDesc = "閸戙倕鍤㈤幒灞惧付濞戝懏顫堟稊瀣紑閿涘本绻忓缁樻濞村浼€闁插秶鏁撻妴鍌涚槨缁夋帒鎮滈崜宥嗘煙閸欐垵鐨犳稉鈧弸姘额棧閸撴埊绱濇导銈咁唺娑撶儤鏁鹃崙璇插閻?00%",
    },
    {
        name = "缁佺偤绶抽懟宥団敃閸?,
        skill = "shenlongjian",
        icon = "shenlongjian",
        atkPercent = 1000,
        upgradeCost = 0,
        detail = "娴ｂ晜鍩撻崥搴☆杻閸旂姵娓舵径褎鏁鹃崙璇插1000%",
        skillDesc = "閾诲秴鎮庢潻婊冨綔缁佺偤绶虫鍌炵搶娑撳孩纭堕崚娆欑礉閹枫儲婀佸В浣轰純婢垛晛婀存稊瀣閵嗗倹鐦＄粔鎺戞倻閸撳秵鏌熼崣鎴濈殸娑撯偓閺嬫岸顥ｉ崜鎴礉娴笺倕顔婃稉鐑樻暰閸戣濮忛惃?000%",
    },
}
local MAX_LEVEL = #SWORD_LEVELS

function jiange:Construct()
    self:LuaInit()
    self.CurrentLevel = 1
    self.UpgradeProgress = 0 -- 
    self.IsWearing = false
    self.ForgeConsumePending = false

    -- Acquire local player references.
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.SavedJiangeLevel then
        self.CurrentLevel = PC.SavedJiangeLevel or 1
        self.UpgradeProgress = PC.SavedJiangeProgress or 0
        -- Keep this section consistent with the original UI flow.
    end

    if self.weartip then self.weartip:SetText("缁屾寧鍩?) end
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()
    self:UpdateCostDisplay()
    self:RefreshCostDisplayDelayed(0.2)
    self:SetVisibility(1)
end

function jiange:Show()
    self:SetVisibility(0)
    self:UpdateCostDisplay()
    self:RefreshCostDisplayDelayed(0.2)
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

function jiange:OnCancelClicked()
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

function jiange:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.wear then self.wear.OnClicked:Add(self.OnWearClicked, self) end
    if self.levelup then self.levelup.OnClicked:Add(self.OnLevelUpClicked, self) end
    if self.cancel then self.cancel.OnClicked:Add(self.OnCancelClicked, self) end
end

function jiange:GetSkillPath(level)
    local cfg = SWORD_LEVELS[level]
    if not cfg then return nil end
    return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. cfg.skill .. '.' .. cfg.skill .. '_C')
end

function jiange:GetIconPath(level)
    local cfg = SWORD_LEVELS[level]
    if not cfg then return nil end
    return UGCGameSystem.GetUGCResourcesFullPath('PNG/shenjian/' .. cfg.icon .. '.' .. cfg.icon)
end

-- Update sword display.
function jiange:UpdateSwordDisplay()
    local cfg = SWORD_LEVELS[self.CurrentLevel]
    if not cfg then return end

    if self.Image_2 then
        local iconPath = self:GetIconPath(self.CurrentLevel)
        if iconPath then
            local texture = LoadObject(iconPath)
            if texture then
                self.Image_2:SetBrushFromTexture(texture)
            end
        end
    end

    if self.name then
        self.name:SetText(cfg.name)
    end
    if self.TextBlock_detail then
        self.TextBlock_detail:SetText(cfg.detail)
    end
    if self.TextBlock_skill then
        self.TextBlock_skill:SetText(cfg.skillDesc)
    end
end

function jiange:UpdateProgressBar()
    if self.ProgressBar_level then
        self.ProgressBar_level:SetPercent(self.UpgradeProgress / 100)
    end
end

-- Get forge stone count.
function jiange:GetForgeStoneCount()
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VIM then
        return 0
    end

    local PC = UGCGameSystem.GetLocalPlayerController()
    local count = 0
    if PC then
        count = VIM:GetItemNum(5666, PC) or 0
    else
        count = VIM:GetItemNum(5666) or 0
    end

    return tonumber(count) or 0
end

-- Update cost display.
function jiange:UpdateCostDisplay()
    -- Guard condition before running this branch.
    if self.TextBlock_current then
        local count = self:GetForgeStoneCount()
        self.TextBlock_current:SetText(tostring(count))
    end

    -- Guard condition before running this branch.
    if self.TextBlock_need then
        if self.CurrentLevel < MAX_LEVEL then
            self.TextBlock_need:SetText("1")
        else
            self.TextBlock_need:SetText("--")
        end
    end
end

function jiange:RefreshCostDisplayDelayed(delay)
    UGCGameSystem.SetTimer(self, function()
        if self and self.UpdateCostDisplay then
            self:UpdateCostDisplay()
        end
    end, delay or 0.2, false)
end

function jiange:SetForgeConsumePending(pending)
    self.ForgeConsumePending = (pending == true)
    if self.levelup and self.levelup.SetIsEnabled then
        self.levelup:SetIsEnabled(not self.ForgeConsumePending)
    end
end

function jiange:ApplyForgeProgress()
    -- Local helper value for this logic block.
    local addTenths = math.random(1, 10) -- Generate random value.
    self.UpgradeProgress = self.UpgradeProgress + addTenths / 10

    local tipText = string.format("闁垮鈧姾绻樻惔?+%.1f%%", addTenths / 10)

    -- Guard condition before running this branch.
    if self.UpgradeProgress >= 100 then
        self.UpgradeProgress = 0

        local wasWearing = self.IsWearing
        self.CurrentLevel = self.CurrentLevel + 1

        self:UpdateSwordDisplay()

        if wasWearing then
            self:ApplySkill(true)
            self:ApplyAtkBonus(true)
        end

        tipText = "閸楀洨楠囬幋鎰"
    end

    self:UpdateProgressBar()
    self:SaveToServer()
    self:ShowTipViaMain(tipText)
end

function jiange:OnForgeConsumeResult(success, remainCount, tipText)
    self:SetForgeConsumePending(false)

    if self.TextBlock_current and remainCount ~= nil then
        self.TextBlock_current:SetText(tostring(tonumber(remainCount) or 0))
    end

    if not success then
        if tipText and tipText ~= "" then
            self:ShowTipViaMain(tipText)
        else
            self:ShowTipViaMain("闁垮鈧姷鐓跺☉鍫ｂ偓妤€銇戠拹銉礉鐠囬鈼㈤崥搴ㄥ櫢鐠?)
        end
        self:RefreshCostDisplayDelayed(0.2)
        return
    end

    self:ApplyForgeProgress()
end

function jiange:ApplySkill(isWear)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local skillPath = self:GetSkillPath(self.CurrentLevel)
    if not skillPath then return end
    -- ugcprint("[jiange] ApplySkill: level=" .. tostring(self.CurrentLevel) .. ", isWear=" .. tostring(isWear))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetJiangeSkill", skillPath, isWear)
end

-- Apply atk bonus.
function jiange:ApplyAtkBonus(isWear)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local cfg = SWORD_LEVELS[self.CurrentLevel]
    local bonus = 0
    if isWear and cfg then
        bonus = cfg.atkPercent
    end
    -- ugcprint("[jiange] SetJiangeAtkBonus: " .. tostring(bonus) .. "%")
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetJiangeAtkBonus", bonus)
end

function jiange:OnWearClicked()
    if self.IsWearing then
        self:ApplySkill(false)
        self:ApplyAtkBonus(false)
        self.IsWearing = false
        if self.weartip then self.weartip:SetText("缁屾寧鍩?) end
        self:ShowTipViaMain("瀹告彃宓忔稉?)
    else
        self:ApplySkill(true)
        self:ApplyAtkBonus(true)
        self.IsWearing = true
        if self.weartip then self.weartip:SetText("閸楅晲绗?) end
        self:ShowTipViaMain("瀹歌尙鈹涢幋?)
    end
end

function jiange:OnLevelUpClicked()
    if self.CurrentLevel >= MAX_LEVEL then return end
    if self.ForgeConsumePending then
        self:ShowTipViaMain("濮濓絽婀柨濠氣偓鐘辫厬閿涘矁顕粙宥呪偓?)
        return
    end

    -- Local helper value for this logic block.
    local cost = 1

    -- Local helper value for this logic block.
    local count = self:GetForgeStoneCount()
    -- Guard condition before running this branch.
    if count < cost then
        self:ShowTipViaMain("闁垮鈧姷鐓舵稉宥堝喕")
        return
    end

    -- Local helper value for this logic block.
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then
        self:ShowTipViaMain("閺冪姵纭舵潻鐐村复閺堝秴濮熺粩?)
        return
    end

    self:SetForgeConsumePending(true)
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", 5666, cost)

    -- Delay execution until dependent data is ready.
    UGCGameSystem.SetTimer(self, function()
        if self and self.ForgeConsumePending then
            self:SetForgeConsumePending(false)
            self:UpdateCostDisplay()
        end
    end, 1.2, false)
end

function jiange:ShowTipViaMain(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end

function jiange:Destruct()
end

-- Load saved data.
function jiange:LoadSavedData(level, progress)
    -- ugcprint("[jiange] LoadSavedData: level=" .. tostring(level) .. ", progress=" .. tostring(progress))
    self.CurrentLevel = level or 1
    self.UpgradeProgress = progress or 0
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()
    self:UpdateCostDisplay()
end

-- Save to server.
function jiange:SaveToServer()
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SaveJiangeData", self.CurrentLevel, self.UpgradeProgress)
    end
end

return jiange
