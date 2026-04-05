---@class touxiang_C:UUserWidget
---@field CanvasPanel_0 UCanvasPanel
---@field EXP UProgressBar
---@field exptiptext UTextBlock
---@field General_ShopPlay_UIBP General_ShopPlay_UIBP_C
---@field Hp UProgressBar
---@field tou tou_C
---@field touxiangdetail UButton
--Edit Below--
local touxiang = { bInitDoOnce = false } 


function touxiang:Construct()
	self:LuaInit();
    self.General_ShopPlay_UIBP.HP_Text:BindingProperty("Text", self.HP_Text_Text, self);
    self.General_ShopPlay_UIBP.MG_Text:BindingProperty("Text", self.MG_Text_Text, self);
    self.General_ShopPlay_UIBP.Attack_Text:BindingProperty("Text", self.Attack_Text_Text, self);
    self.General_ShopPlay_UIBP.Level_Text:BindingProperty("Text", self.Level_Text_Text, self);
    self.General_ShopPlay_UIBP.Live_Text:BindingProperty("Text", self.Live_Text_Text, self);
    
    -- 绑定经验值显示
    if self.exptiptext then
        self.exptiptext:BindingProperty("Text", self.EXP_Text_Text, self);
    end
    
    -- 如果有战斗力字段，绑定战斗力显示
    if self.General_ShopPlay_UIBP.CombatPower_Text then
        self.General_ShopPlay_UIBP.CombatPower_Text:BindingProperty("Text", self.CombatPower_Text_Text, self);
    end

    -- 延迟初始化玩家头像（等待PlayerState数据就绪）
    UGCGameSystem.SetTimer(self, function()
        self:InitAvatar()
    end, 2.0, false)
end

-- 初始化头像控件（Common_Avatar_BP.InitView）
-- InitView(Style, UID, IconURL, Gender, FrameLevel, PlayerLevel, IgnoreFrame, IsMySelf)
function touxiang:InitAvatar()
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

function touxiang:HP_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    if playerpawn then
        local hp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Health') or 0)
        local maxHp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'HealthMax') or 0)
        -- 如果属性还没同步（值为0），使用 GameData 或默认值
        if hp == 0 then
            if playerState and playerState.GameData then
                hp = playerState.GameData.PlayerHp or 100
            else
                hp = 100
            end
        end
        if maxHp == 0 then
            if playerState and playerState.GameData then
                maxHp = playerState.GameData.PlayerMaxHp or 100
            else
                maxHp = 100
            end
        end
        return "" .. tostring(hp) .. "/" .. tostring(maxHp)
    end
    return "100/100";
end

function touxiang:EXP_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local currentExp = 0
    local currentLevel = 1
    
    if playerpawn then
        -- 从属性系统获取经验值
        currentExp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'EXP') or 0)
        currentLevel = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Level') or 0)
        
        -- 如果属性还没同步,使用 GameData
        if currentExp == 0 then
            if playerState and playerState.GameData then
                currentExp = playerState.GameData.PlayerExp or 0
            end
        end
        if currentLevel == 0 then
            if playerState and playerState.GameData then
                currentLevel = playerState.GameData.PlayerLevel or 1
            else
                currentLevel = 1
            end
        end
    end
    
    -- 获取当前等级配置,查看升级所需经验
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    local levelConfig = UGCGameData.GetLevelConfig(currentLevel)
    
    if levelConfig and levelConfig.Exp and levelConfig.Exp > 0 then
        return UGCGameData.FormatNumber(currentExp) .. "/" .. UGCGameData.FormatNumber(levelConfig.Exp)
    end
    
    -- 如果没有配置,只显示当前经验
    return UGCGameData.FormatNumber(currentExp)
end

function touxiang:MG_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    if playerpawn then
        local magic = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Magic') or 0)
        -- 如果属性还没同步（值为0），使用 GameData 或默认值
        if magic == 0 then
            if playerState and playerState.GameData then
                magic = playerState.GameData.PlayerMagic or 10
            else
                magic = 10
            end
        end
        local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
        return UGCGameData.FormatNumber(magic)
    end
    return "10";
end

function touxiang:Attack_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    if playerpawn then
        local attack = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Attack') or 0)
        -- 如果属性还没同步（值为0），使用 GameData 或默认值
        if attack == 0 then
            if playerState and playerState.GameData then
                attack = playerState.GameData.PlayerAttack or 20
            else
                attack = 20
            end
        end
        local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
        return UGCGameData.FormatNumber(attack)
    end
    return "20";
end

function touxiang:Level_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    if playerpawn then
        local level = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Level') or 0)
        -- 如果属性还没同步（值为0），使用 GameData 或默认值
        if level == 0 then
            if playerState and playerState.GameData then
                level = playerState.GameData.PlayerLevel or 1
            else
                level = 1
            end
        end
        return "" .. tostring(level)
    end
    return "1";
end

function touxiang:Live_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return "转生: 0次"
    end
    
    -- 优先使用复制属性（自动同步），如果没有则使用 GameData，最后使用默认值0
    local rebirthCount = 0
    if playerState.UGCPlayerRebirthCount ~= nil then
        rebirthCount = playerState.UGCPlayerRebirthCount
    elseif playerState.GameData and playerState.GameData.PlayerRebirthCount ~= nil then
        rebirthCount = playerState.GameData.PlayerRebirthCount
    end
    
    return "转生: " .. tostring(rebirthCount) .. "次"
end

-- 战斗力显示
-- 战斗力 = 最大生命*5% + 攻击力*70% + 魔法值*25%
function touxiang:CombatPower_Text_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    
    local maxHp = 100
    local attack = 20
    local magic = 10
    
    if playerpawn then
        -- 从 Pawn 属性获取
        maxHp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'HealthMax') or 0)
        attack = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Attack') or 0)
        magic = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Magic') or 0)
        
        -- 如果属性还没同步（值为0），使用 GameData 或默认值
        if maxHp == 0 then
            if playerState and playerState.GameData then
                maxHp = playerState.GameData.PlayerMaxHp or 100
            else
                maxHp = 100
            end
        end
        if attack == 0 then
            if playerState and playerState.GameData then
                attack = playerState.GameData.PlayerAttack or 20
            else
                attack = 20
            end
        end
        if magic == 0 then
            if playerState and playerState.GameData then
                magic = playerState.GameData.PlayerMagic or 10
            else
                magic = 10
            end
        end
    end
    
    local combatPower = math.floor(maxHp * 0.05 + attack * 0.7 + magic * 0.25)
    
    -- 使用格式化函数
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return UGCGameData.FormatNumber(combatPower)
end

-- function touxiang:Tick(MyGeometry, InDeltaTime)

-- end

-- function touxiang:Destruct()

-- end

-- [Editor Generated Lua] function define Begin:
function touxiang:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	if self.Hp then
		self.Hp:BindingProperty("Percent", self.Hp_Percent, self);
	end
	self.EXP:BindingProperty("Percent", self.EXP_Percent, self);
	self.exptiptext:BindingProperty("Text", self.exptiptext_Text, self);
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	if self.touxiangdetail then
		self.touxiangdetail.OnClicked:Add(self.touxiangdetail_OnClicked, self);
	end
	-- [Editor Generated Lua] BindingEvent End;
end

function touxiang:touxiangdetail_OnClicked()
    --ugcprint("[touxiang] 详情按钮被点击")
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.touxiangdetail then
        -- 全屏显示详情界面
        pc.MMainUI.touxiangdetail:Show()
        --ugcprint("[touxiang] 显示详情界面成功")
    else
        --ugcprint("[touxiang] 无法找到详情界面")
    end
end

-- 血量条百分比
function touxiang:Hp_Percent(ReturnValue)
	local playerState = UGCGameSystem.GetLocalPlayerState()
	local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
	
	local hp = 100
	local maxHp = 100
	
	if playerpawn then
		hp = UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Health') or 0
		maxHp = UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'HealthMax') or 0
		
		-- 如果属性还没同步，使用 GameData
		if hp == 0 then
			if playerState and playerState.GameData then
				hp = playerState.GameData.PlayerHp or 100
			else
				hp = 100
			end
		end
		if maxHp == 0 then
			if playerState and playerState.GameData then
				maxHp = playerState.GameData.PlayerMaxHp or 100
			else
				maxHp = 100
			end
		end
	end
	
	-- 返回 0-1 之间的百分比
	if maxHp > 0 then
		return hp / maxHp
	end
	return 1.0
end

-- 经验条百分比
function touxiang:EXP_Percent(ReturnValue)
	local playerState = UGCGameSystem.GetLocalPlayerState()
	local playerpawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
	
	local currentExp = 0
	local currentLevel = 1
	
	if playerpawn then
		-- 从属性系统获取经验值
		currentExp = UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'EXP') or 0
		currentLevel = UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Level') or 0
		
		-- 如果属性还没同步,使用 GameData
		if currentExp == 0 then
			if playerState and playerState.GameData then
				currentExp = playerState.GameData.PlayerExp or 0
			end
		end
		if currentLevel == 0 then
			if playerState and playerState.GameData then
				currentLevel = playerState.GameData.PlayerLevel or 1
			else
				currentLevel = 1
			end
		end
	end
	
	-- 确保等级是整数
	currentLevel = math.floor(currentLevel)
	
	-- 获取当前等级配置,查看升级所需经验
	local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
	local levelConfig = UGCGameData.GetLevelConfig(currentLevel)
	
	if not levelConfig or not levelConfig.Exp or levelConfig.Exp <= 0 then
		-- 如果没有配置或已达最高等级,返回满经验
		return 1.0
	end
	
	local requiredExp = levelConfig.Exp
	local percent = math.min(currentExp / requiredExp, 1.0)
	
	-- 返回 0-1 之间的百分比
	return percent
end

function touxiang:exptiptext_Text(ReturnValue)
	return "";
end

-- [Editor Generated Lua] function define End;

return touxiang