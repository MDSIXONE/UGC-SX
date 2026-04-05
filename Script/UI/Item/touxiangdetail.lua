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
    
    -- 缁戝畾鏁板€兼樉绀?
    self.ATTACK:BindingProperty("Text", self.ATTACK_Text, self)
    self.MAGIC:BindingProperty("Text", self.MAGIC_Text, self)
    self.LIVE:BindingProperty("Text", self.LIVE_Text, self)
    self.Ecexp:BindingProperty("Text", self.Ecexp_Text, self)
    self.Base_Attack:BindingProperty("Text", self.Base_Attack_Text, self)
    self.Base_HP:BindingProperty("Text", self.Base_HP_Text, self)
    self.Base_Magic:BindingProperty("Text", self.Base_Magic_Text, self)
    
    -- 缁戝畾褰撳墠鏈€澶ц閲忔樉绀?
    self.Current_MAXHP:BindingProperty("Text", self.Current_MAXHP_Text, self)
    
    -- 缁戝畾琛€鑴夊睘鎬ф樉绀?
    self.Bland:BindingProperty("Text", self.Bland_Text, self)
    
    -- 缁戝畾绱鍏呭€兼樉绀?
    self.leijixiaofei:BindingProperty("Text", self.leijixiaofei_Text, self)

    -- 缁戝畾VIP绛夌骇鏄剧ず
    if self.VIP then
        self.VIP:BindingProperty("Text", self.VIP_Text, self)
    end
    
    -- 缁戝畾鍔犵偣娆℃暟鏄剧ず
    self.ATTACKup:BindingProperty("Text", self.ATTACKup_Text, self)
    self.MAGICup:BindingProperty("Text", self.MAGICup_Text, self)
    self.hpup:BindingProperty("Text", self.hpup_Text, self)
    self.bland_up:BindingProperty("Text", self.bland_up_Text, self)
    
    -- 缁戝畾鍔犵偣鎸夐挳
    self.Button_ATTACKup.OnClicked:Add(self.OnATTACKupClicked, self)
    self.Button_MAGICup.OnClicked:Add(self.OnMAGICupClicked, self)
    self.Button_hpup.OnClicked:Add(self.OnHpupClicked, self)
    self.Button_blandup.OnClicked:Add(self.OnBlandupClicked, self)
    
    -- 缁戝畾鍏抽棴鎸夐挳
    if self.Detail_Cancel and self.Detail_Cancel.Button_Levels2_3 then
        self.Detail_Cancel.Button_Levels2_3.OnClicked:Add(self.OnCancelClicked, self)
    end

    -- 缁戝畾鐜╁鍚嶅瓧鍜屾垬鏂楀姏
    if self.name then
        self.name:BindingProperty("Text", self.name_Text, self)
    end
    if self.zhandouli then
        self.zhandouli:BindingProperty("Text", self.zhandouli_Text, self)
    end

    -- 寤惰繜鍒濆鍖栧ご鍍?
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

-- 鍒濆鍖栧ご鍍?
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

-- 鏀诲嚮鍔涙樉绀?
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
    return "鏀诲嚮鍔? " .. UGCGameData.FormatNumber(attack)
end

-- 榄旀硶鍊兼樉绀?
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
    return "榄旀硶鍊? " .. UGCGameData.FormatNumber(magic)
end

-- 杞敓娆℃暟鏄剧ず
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
    return "杞敓: " .. tostring(rebirthCount) .. "娆?
end

-- 鍚炲櫖棰濆鍔犳垚鏄剧ず
function touxiangdetail:Ecexp_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local bonusPercent = 1
    
    if playerState and playerState.GameData then
        bonusPercent = playerState.GameData.PlayerEcexp or 1
    end
    
    return "鍚炲櫖鍔犳垚: " .. tostring(bonusPercent) .. "%"
end

-- 鍩虹鏀诲嚮鍔涙樉绀?
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
    return "鍩虹鏀诲嚮鍔? " .. UGCGameData.FormatNumber(baseAttack)
end

-- 鍩虹鐢熷懡鍊兼樉绀?
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
    return "鍩虹鐢熷懡鍊? " .. UGCGameData.FormatNumber(baseHp)
end

-- 鍩虹榄旀硶鍊兼樉绀?
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
    return "鍩虹榄旀硶鍊? " .. UGCGameData.FormatNumber(baseMagic)
end

-- 褰撳墠鏈€澶ц閲忔樉绀?
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
    return "鏈€澶ц閲? " .. UGCGameData.FormatNumber(maxHp)
end

-- 琛€鑴夊睘鎬ф樉绀?
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
    return "琛€鑴? " .. UGCGameData.FormatNumber(bland)
end

-- 绱鍏呭€兼樉绀?
function touxiangdetail:leijixiaofei_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local spendCount = 0
    if playerState then
        spendCount = playerState.UGCSpendCount or 0
    end
    return "绱鍏呭€? " .. tostring(spendCount)
end

-- VIP绛夌骇鏄剧ず锛堟寜绱鍏呭€硷級
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

-- 鍔犵偣娆℃暟鏄剧ず
function touxiangdetail:ATTACKup_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualAttack or (playerState.GameData and playerState.GameData.PlayerManualAttack) or 0
    end
    return "鏀诲嚮鍔犵偣: " .. tostring(count)
end

function touxiangdetail:MAGICup_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualMagic or (playerState.GameData and playerState.GameData.PlayerManualMagic) or 0
    end
    return "榄旀硶鍔犵偣: " .. tostring(count)
end

function touxiangdetail:hpup_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualHp or (playerState.GameData and playerState.GameData.PlayerManualHp) or 0
    end
    return "鐢熷懡鍔犵偣: " .. tostring(count)
end

function touxiangdetail:bland_up_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local count = 0
    if playerState then
        count = playerState.UGCPlayerManualBland or (playerState.GameData and playerState.GameData.PlayerManualBland) or 0
    end
    return "琛€鑴夊姞鐐? " .. tostring(count)
end

-- 鏄剧ず鎻愮ず
function touxiangdetail:ShowTip(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end

-- 鍔犵偣鎸夐挳鍥炶皟
function touxiangdetail:OnATTACKupClicked()
    -- ugcprint("[touxiangdetail] 鏀诲嚮鍔犵偣鎸夐挳鐐瑰嚮")
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddManualPoint", "attack")
        self:ShowTip("鏀诲嚮鍔?2")
    end
end

function touxiangdetail:OnMAGICupClicked()
    -- ugcprint("[touxiangdetail] 榄旀硶鍔犵偣鎸夐挳鐐瑰嚮")
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddManualPoint", "magic")
        self:ShowTip("榄旀硶鍊?1")
    end
end

function touxiangdetail:OnHpupClicked()
    -- ugcprint("[touxiangdetail] 鐢熷懡鍔犵偣鎸夐挳鐐瑰嚮")
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddManualPoint", "hp")
        self:ShowTip("鐢熷懡鍊?5")
    end
end

function touxiangdetail:OnBlandupClicked()
    -- ugcprint("[touxiangdetail] 琛€鑴夊姞鐐规寜閽偣鍑?)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_AddManualPoint", "bland")
        self:ShowTip("琛€鑴?10")
    end
end

-- 鍏ㄥ睆鏄剧ず璇︽儏鐣岄潰
function touxiangdetail:Show()
    self:SetVisibility(ESlateVisibility.Visible)
    self:ApplyFullScreenLayer()
    -- 鍒锋柊澶村儚
    self:InitAvatar()
end

-- 鍏抽棴鎸夐挳鐐瑰嚮
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

-- 鐜╁鍚嶅瓧鏄剧ず
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

-- 鎴樻枟鍔涙樉绀?
function touxiangdetail:zhandouli_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        local combatPower = playerState.UGCPlayerCombatPower or 0
        local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
        return "鎴樻枟鍔? " .. UGCGameData.FormatNumber(combatPower)
    end
    return "鎴樻枟鍔? 0"
end

return touxiangdetail
