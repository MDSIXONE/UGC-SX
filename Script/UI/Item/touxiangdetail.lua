---@class touxiangdetail_C:UUserWidget
---@field ATTACK UTextBlock
---@field ATTACKup UTextBlock
---@field Base_Attack UTextBlock
---@field Base_HP UTextBlock
---@field Base_Magic UTextBlock
---@field Bland UTextBlock
---@field bland_up UTextBlock
---@field Button_ATTACKup UButton
---@field Button_blandup UButton
---@field Button_hpup UButton
---@field Button_MAGICup UButton
---@field Current_MAXHP UTextBlock
---@field currentpoint UTextBlock
---@field Detail_Cancel General_SecondLevelButton_3_C
---@field Ecexp UTextBlock
---@field hpup UTextBlock
---@field Image_0 UImage
---@field Image_39 UImage
---@field leijixiaofei UTextBlock
---@field LIVE UTextBlock
---@field MAGIC UTextBlock
---@field MAGICup UTextBlock
---@field name UTextBlock
---@field tou tou_C
---@field VIP UTextBlock
---@field zhandouli UTextBlock
--Edit Below--
local touxiangdetail = { bInitDoOnce = false, bFullScreenLayerApplied = false } 


function touxiangdetail:Construct()
	self:LuaInit();
    
    -- Bind widget property text or values.
    self.ATTACK:BindingProperty("Text", self.ATTACK_Text, self)
    self.MAGIC:BindingProperty("Text", self.MAGIC_Text, self)
    self.LIVE:BindingProperty("Text", self.LIVE_Text, self)
    self.Ecexp:BindingProperty("Text", self.Ecexp_Text, self)
    self.Base_Attack:BindingProperty("Text", self.Base_Attack_Text, self)
    self.Base_HP:BindingProperty("Text", self.Base_HP_Text, self)
    self.Base_Magic:BindingProperty("Text", self.Base_Magic_Text, self)
    
    -- Bind widget property text or values.
    self.Current_MAXHP:BindingProperty("Text", self.Current_MAXHP_Text, self)

    if self.currentpoint then
        self.currentpoint:BindingProperty("Text", self.currentpoint_Text, self)
    end
    
    -- Bind widget property text or values.
    self.Bland:BindingProperty("Text", self.Bland_Text, self)
    
    -- Bind widget property text or values.
    self.leijixiaofei:BindingProperty("Text", self.leijixiaofei_Text, self)

    -- Guard condition before running this branch.
    if self.VIP then
        self.VIP:BindingProperty("Text", self.VIP_Text, self)
    end
    
    -- Bind widget property text or values.
    self.ATTACKup:BindingProperty("Text", self.ATTACKup_Text, self)
    self.MAGICup:BindingProperty("Text", self.MAGICup_Text, self)
    self.hpup:BindingProperty("Text", self.hpup_Text, self)
    self.bland_up:BindingProperty("Text", self.bland_up_Text, self)
    
    -- Register button interaction handlers.
    self.Button_ATTACKup.OnClicked:Add(self.OnATTACKupClicked, self)
    self.Button_MAGICup.OnClicked:Add(self.OnMAGICupClicked, self)
    self.Button_hpup.OnClicked:Add(self.OnHpupClicked, self)
    self.Button_blandup.OnClicked:Add(self.OnBlandupClicked, self)
    
    -- Guard condition before running this branch.
    if self.Detail_Cancel and self.Detail_Cancel.Button_Levels2_3 then
        self.Detail_Cancel.Button_Levels2_3.OnClicked:Add(self.OnCancelClicked, self)
    end

    -- Guard condition before running this branch.
    if self.name then
        self.name:BindingProperty("Text", self.name_Text, self)
    end
    if self.zhandouli then
        self.zhandouli:BindingProperty("Text", self.zhandouli_Text, self)
    end

    -- Delay execution until dependent data is ready.
    UGCGameSystem.SetTimer(self, function()
        self:InitAvatar()
    end, 2.0, false)
end

function touxiangdetail:ApplyFullScreenLayer()
    if self.bFullScreenLayerApplied then
        return
    end

    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end

    self.bFullScreenLayerApplied = true
end

function touxiangdetail:ReleaseFullScreenLayer()
    if not self.bFullScreenLayerApplied then
        return
    end

    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end

    self.bFullScreenLayerApplied = false
end

-- Init avatar.
function touxiangdetail:InitAvatar()
    if not self.tou then return end
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then return end
    local uid = UGCGameSystem.GetUIDByPlayerState(playerState)
    if not uid then return end
    local iconURL = playerState.IconURL or ""
    local gender = playerState.PlatformGender or 0
    local frameLevel = playerState.SegmentLevel or 0
    local playerLevel = playerState.PlayerLevel or 1
    self.tou:InitView(1, uid, iconURL, gender, frameLevel, playerLevel, false, true)
end

-- Attack text.
function touxiangdetail:ATTACK_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local attack = 20
    if playerpawn then
        attack = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Attack') or 0)
        if attack == 0 and playerState and playerState.GameData then
            attack = playerState.GameData.PlayerAttack or 20
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "攻击力: " .. UGCGameData.FormatNumber(attack)
end

-- Magic text.
function touxiangdetail:MAGIC_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local magic = 10
    if playerpawn then
        magic = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Magic') or 0)
        if magic == 0 and playerState and playerState.GameData then
            magic = playerState.GameData.PlayerMagic or 10
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "魔法值: " .. UGCGameData.FormatNumber(magic)
end

-- Live text.
function touxiangdetail:LIVE_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local rebirthCount = 0
    
    if playerState then
        if playerState.UGCPlayerRebirthCount ~= nil then
            rebirthCount = playerState.UGCPlayerRebirthCount
        elseif playerState.GameData and playerState.GameData.PlayerRebirthCount then
            rebirthCount = playerState.GameData.PlayerRebirthCount
        end
    end
    return "转生: " .. tostring(rebirthCount) .. "次"
end

-- Ecexp text.
function touxiangdetail:Ecexp_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local bonusPercent = 1
    
    if playerState and playerState.GameData then
        bonusPercent = playerState.GameData.PlayerEcexp or 1
    end
    
    return "吞噬加成: " .. tostring(bonusPercent) .. "%"
end

-- Base attack text.
function touxiangdetail:Base_Attack_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local baseAttack = 20
    if playerpawn then
        baseAttack = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Attack') or 0)
        if baseAttack == 0 and playerState and playerState.GameData then
            baseAttack = playerState.GameData.PlayerAttack or 20
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "基础攻击力: " .. UGCGameData.FormatNumber(baseAttack)
end

-- Base hp text.
function touxiangdetail:Base_HP_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local baseHp = 100
    if playerpawn then
        baseHp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'HealthMax') or 0)
        if baseHp == 0 and playerState and playerState.GameData then
            baseHp = playerState.GameData.PlayerMaxHp or 100
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "基础生命值: " .. UGCGameData.FormatNumber(baseHp)
end

-- Base magic text.
function touxiangdetail:Base_Magic_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local baseMagic = 10
    if playerpawn then
        baseMagic = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Magic') or 0)
        if baseMagic == 0 and playerState and playerState.GameData then
            baseMagic = playerState.GameData.PlayerMagic or 10
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "基础魔法值: " .. UGCGameData.FormatNumber(baseMagic)
end

-- Current maxhp text.
function touxiangdetail:Current_MAXHP_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local maxHp = 100
    if playerpawn then
        maxHp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'HealthMax') or 0)
        if maxHp == 0 and playerState and playerState.GameData then
            maxHp = playerState.GameData.PlayerMaxHp or 100
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "当前最大生命: " .. UGCGameData.FormatNumber(maxHp)
end

-- Bland text.
function touxiangdetail:Bland_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local bland = 0
    if playerpawn then
        bland = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'bland') or 0)
        if bland == 0 and playerState and playerState.GameData then
            bland = playerState.GameData.PlayerBland or 0
        end
    end
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "吞噬值: " .. UGCGameData.FormatNumber(bland)
end

-- Leijixiaofei text.
function touxiangdetail:leijixiaofei_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local spendCount = 0
    if playerState then
        spendCount = playerState.UGCSpendCount or 0
    end
    return "累计消费: " .. tostring(spendCount)
end

-- Vip text.
function touxiangdetail:VIP_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local vipLevel = nil

    if playerState and playerState.GameData then
        vipLevel = playerState.GameData.PlayerVIP
    end

    if vipLevel == nil then
        local spendCount = 0
        if playerState then
            spendCount = playerState.UGCSpendCount or 0
        end

        if spendCount >= 3000 then
            vipLevel = 7
        elseif spendCount >= 1000 then
            vipLevel = 6
        elseif spendCount >= 648 then
            vipLevel = 5
        elseif spendCount >= 168 then
            vipLevel = 4
        elseif spendCount >= 98 then
            vipLevel = 3
        elseif spendCount >= 30 then
            vipLevel = 2
        elseif spendCount >= 6 then
            vipLevel = 1
        else
            vipLevel = 0
        end

        if playerState and playerState.GameData then
            playerState.GameData.PlayerVIP = vipLevel
        end
    end

    return "V" .. tostring(vipLevel or 0)
end

-- Attac kup text.
function touxiangdetail:ATTACKup_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualAttack or (playerState.GameData and playerState.GameData.PlayerManualAttack) or 0
    end
    return "攻击强化次数: " .. tostring(count)
end

function touxiangdetail:MAGICup_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualMagic or (playerState.GameData and playerState.GameData.PlayerManualMagic) or 0
    end
    return "魔法强化次数: " .. tostring(count)
end

function touxiangdetail:hpup_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualHp or (playerState.GameData and playerState.GameData.PlayerManualHp) or 0
    end
    return "生命强化次数: " .. tostring(count)
end

function touxiangdetail:bland_up_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualBland or (playerState.GameData and playerState.GameData.PlayerManualBland) or 0
    end
    return "吞噬强化次数: " .. tostring(count)
end

function touxiangdetail:GetCurrentTalentPoints()
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return 0
    end

    if playerState.GameData and playerState.GameData.PlayerTalentPoints ~= nil then
        return math.max(0, math.floor(tonumber(playerState.GameData.PlayerTalentPoints) or 0))
    end

    return math.max(0, math.floor(tonumber(playerState.UGCPlayerTalentPoints) or 0))
end

function touxiangdetail:currentpoint_Text(ReturnValue)
    return "天赋点: " .. tostring(self:GetCurrentTalentPoints())
end

-- Show tip.
function touxiangdetail:ShowTip(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end

-- Handle attac kup button click.
function touxiangdetail:OnATTACKupClicked()
    self:RequestManualPoint("attack")
end

function touxiangdetail:OnMAGICupClicked()
    self:RequestManualPoint("magic")
end

function touxiangdetail:OnHpupClicked()
    self:RequestManualPoint("hp")
end

function touxiangdetail:OnBlandupClicked()
    self:RequestManualPoint("bland")
end

function touxiangdetail:RequestManualPoint(pointType)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        self:ShowTip("无法获取玩家状态")
        return
    end

    if self:GetCurrentTalentPoints() <= 0 then
        self:ShowTip("天赋点不足")
        return
    end

    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddManualPoint", pointType)
end

function touxiangdetail:OnManualPointResult(success, pointType, remainTalentPoints, tipText)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local normalizedPoints = math.max(0, math.floor(tonumber(remainTalentPoints) or 0))
    if playerState then
        playerState.UGCPlayerTalentPoints = normalizedPoints
        if playerState.GameData then
            playerState.GameData.PlayerTalentPoints = normalizedPoints
        end
    end

    if tipText and tipText ~= "" then
        self:ShowTip(tostring(tipText))
        return true
    end

    if success then
        if pointType == "attack" then
            self:ShowTip("攻击+2")
        elseif pointType == "magic" then
            self:ShowTip("魔法+1")
        elseif pointType == "hp" then
            self:ShowTip("生命+5")
        elseif pointType == "bland" then
            self:ShowTip("血脉+10")
        else
            self:ShowTip("加点成功")
        end
    else
        self:ShowTip("加点失败")
    end

    return true
end

-- Show.
function touxiangdetail:Show()
    self:SetVisibility(ESlateVisibility.Visible)
    self:ApplyFullScreenLayer()
    -- Execute the next UI update step.
    self:InitAvatar()
end

-- Handle cancel button click.
function touxiangdetail:OnCancelClicked()
    self:ReleaseFullScreenLayer()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function touxiangdetail:Destruct()
    self:ReleaseFullScreenLayer()
end

-- [Editor Generated Lua] function define Begin:
function touxiangdetail:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
end

-- [Editor Generated Lua] function define End;

-- Name text.
function touxiangdetail:name_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        local ok, playerName = pcall(function()
            return playerState:GetPlayerName()
        end)
        if ok and playerName and playerName ~= "" then
            return playerName
        end
    end
    return ""
end

-- Zhandouli text.
function touxiangdetail:zhandouli_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        local combatPower = playerState.UGCPlayerCombatPower or 0
        local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
        return "战斗力: " .. UGCGameData.FormatNumber(combatPower)
    end
    return "战斗力: 0"
end

return touxiangdetail
