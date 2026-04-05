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

-- 7绾у崌绾ц矾绾块厤缃?
local SWORD_LEVELS = {
    {
        name = "鍟告湀瀵掗攱",
        skill = "bailangjian",
        icon = "bailangjian",
        atkPercent = 100,
        upgradeCost = 1,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏100%",
        skillDesc = "鐙肩兢鍟告湀锛屽墤鍏夊鏈堜笅瀵掗湝锛岄攱鍒╅毦鎸°€傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?00%",
    },
    {
        name = "骞藉啣姣掑墤",
        skill = "kuishejian",
        icon = "kuishejian",
        atkPercent = 200,
        upgradeCost = 2,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏200%",
        skillDesc = "姣掕泧濡傚菇鍐ユ潃鎵嬶紝鍓戝垉鑷甫鍓ф瘨銆傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?00%",
    },
    {
        name = "鐧借檸闇滈瓌鍓?,
        skill = "baihujian",
        icon = "baihujian",
        atkPercent = 200,
        upgradeCost = 3,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏200%",
        skillDesc = "鐧借檸鍑濈巹鍐颁箣鍔涳紝涓绘潃浼愶紝钑村惈鏃犲敖瀵掑啲涔嬫皵銆傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?00%",
    },
    {
        name = "鐧芥辰鐮撮偑鍓?,
        skill = "bifangjian",
        icon = "baizejian",
        atkPercent = 300,
        upgradeCost = 4,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏300%",
        skillDesc = "鐧芥辰鐭ユ檽涓囩墿锛屽彲鐮撮櫎涓€鍒囧够璞″拰閭銆傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?00%",
    },
    {
        name = "楹掗簾闀囧ぉ鍓?,
        skill = "qilingjian",
        icon = "qilingjian",
        atkPercent = 400,
        upgradeCost = 5,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏400%",
        skillDesc = "楹掗簾涓虹憺鍏戒箣棣栵紝钑村惈娴戝帤澶у湴涔嬪姏銆傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?00%",
    },
    {
        name = "鍑ゅ嚢娑呮鍓?,
        skill = "zhuquejian",
        icon = "fenhuanjian",
        atkPercent = 500,
        upgradeCost = 10,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏500%",
        skillDesc = "鍑ゅ嚢鎺屾帶娑呮涔嬬伀锛屾繏姝绘椂娴寸伀閲嶇敓銆傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?00%",
    },
    {
        name = "绁為緳鑻嶇┕鍓?,
        skill = "shenlongjian",
        icon = "shenlongjian",
        atkPercent = 1000,
        upgradeCost = 0,
        detail = "浣╂埓鍚庡鍔犳渶澶ф敾鍑诲姏1000%",
        skillDesc = "铻嶅悎杩滃彜绁為緳榄傞瓌涓庢硶鍒欙紝鎷ユ湁姣佺伃澶╁湴涔嬪姏銆傛瘡绉掑悜鍓嶆柟鍙戝皠涓€鏋氶鍓戯紝浼ゅ涓烘敾鍑诲姏鐨?000%",
    },
}
local MAX_LEVEL = #SWORD_LEVELS

function jiange:Construct()
    self:LuaInit()
    self.CurrentLevel = 1
    self.UpgradeProgress = 0  -- 褰撳墠鍗囩骇杩涘害锛?~100
    self.IsWearing = false
    self.ForgeConsumePending = false

    -- 浠嶱C璇诲彇瀛樻。鏁版嵁
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.SavedJiangeLevel then
        self.CurrentLevel = PC.SavedJiangeLevel or 1
        self.UpgradeProgress = PC.SavedJiangeProgress or 0
        -- ugcprint("[jiange] 璇诲彇瀛樻。: level=" .. tostring(self.CurrentLevel) .. ", progress=" .. tostring(self.UpgradeProgress))
    end

    if self.weartip then self.weartip:SetText("绌挎埓") end
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

-- 鏇存柊绁炲墤鍥剧墖銆佸悕瀛椼€佸睘鎬с€佹妧鑳芥樉绀?
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

-- 鑾峰彇鏈湴鐜╁閿婚€犵煶鏁伴噺锛堣櫄鎷熺墿鍝両D=5666锛?
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

-- 鏇存柊閿婚€犵煶鏁伴噺鏄剧ず
function jiange:UpdateCostDisplay()
    -- 褰撳墠鎷ユ湁鐨勯敾閫犵煶鏁伴噺
    if self.TextBlock_current then
        local count = self:GetForgeStoneCount()
        self.TextBlock_current:SetText(tostring(count))
    end

    -- 鍗囩骇闇€瑕佺殑鏁伴噺锛堟瘡娆″浐瀹氭秷鑰?涓級
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
    -- 闅忔満澧炲姞0.1%~1%杩涘害锛堢敤鏁存暟杩愮畻閬垮厤娴偣璇樊锛屽崟浣?.1%锛?
    local addTenths = math.random(1, 10)  -- 1~10 浠ｈ〃 0.1%~1.0%
    self.UpgradeProgress = self.UpgradeProgress + addTenths / 10

    local tipText = string.format("閿婚€犺繘搴?+%.1f%%", addTenths / 10)

    -- 妫€鏌ユ槸鍚︽弧100%
    if self.UpgradeProgress >= 100 then
        self.UpgradeProgress = 0

        local wasWearing = self.IsWearing
        self.CurrentLevel = self.CurrentLevel + 1

        self:UpdateSwordDisplay()

        if wasWearing then
            self:ApplySkill(true)
            self:ApplyAtkBonus(true)
        end

        tipText = "鍗囩骇鎴愬姛"
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
            self:ShowTipViaMain("閿婚€犵煶娑堣€楀け璐ワ紝璇风◢鍚庨噸璇?)
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

-- 閫氳繃RPC璁剧疆绁炲墤鏀诲嚮鍔涘姞鎴愮櫨鍒嗘瘮
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
        if self.weartip then self.weartip:SetText("绌挎埓") end
        self:ShowTipViaMain("宸插嵏涓?)
    else
        self:ApplySkill(true)
        self:ApplyAtkBonus(true)
        self.IsWearing = true
        if self.weartip then self.weartip:SetText("鍗镐笅") end
        self:ShowTipViaMain("宸茬┛鎴?)
    end
end

function jiange:OnLevelUpClicked()
    if self.CurrentLevel >= MAX_LEVEL then return end
    if self.ForgeConsumePending then
        self:ShowTipViaMain("姝ｅ湪閿婚€犱腑锛岃绋嶅€?)
        return
    end

    -- 姣忔娑堣€?涓敾閫犵煶
    local cost = 1

    -- 妫€鏌ラ敾閫犵煶鏄惁瓒冲
    local count = self:GetForgeStoneCount()
    -- ugcprint("[jiange] 閿婚€犵煶鏁伴噺: " .. tostring(count) .. ", 闇€瑕? " .. tostring(cost))
    if count < cost then
        self:ShowTipViaMain("閿婚€犵煶涓嶈冻")
        return
    end

    -- 閫氳繃RPC鍦ㄦ湇鍔＄娑堣€楅敾閫犵煶
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then
        self:ShowTipViaMain("鏃犳硶杩炴帴鏈嶅姟绔?)
        return
    end

    self:SetForgeConsumePending(true)
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", 5666, cost)

    -- 闃叉鍋跺彂鍥炶皟涓㈠け瀵艰嚧鎸夐挳閿佹锛屽仛涓€娆″厹搴曡В閿佷笌鍒锋柊
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

-- 浠庢湇鍔＄鍚屾鐨勫瓨妗ｆ暟鎹姞杞?
function jiange:LoadSavedData(level, progress)
    -- ugcprint("[jiange] LoadSavedData: level=" .. tostring(level) .. ", progress=" .. tostring(progress))
    self.CurrentLevel = level or 1
    self.UpgradeProgress = progress or 0
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()
    self:UpdateCostDisplay()
end

-- 閫氱煡鏈嶅姟绔繚瀛樼鍓戞暟鎹?
function jiange:SaveToServer()
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SaveJiangeData", self.CurrentLevel, self.UpgradeProgress)
    end
end

return jiange
