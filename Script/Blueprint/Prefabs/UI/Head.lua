---@class Head_C:UUserWidget
---@field level UTextBlock
---@field name UTextBlock
---@field zhandouli UTextBlock
---@field zhuansheng UTextBlock
--Edit Below--
local Head = { bInitDoOnce = false }

function Head:Construct()
    self:LuaInit();
end

function Head:Destruct()
end

-- [Editor Generated Lua] function define Begin:
function Head:LuaInit()
    if self.bInitDoOnce then
        return;
    end
    self.bInitDoOnce = true;
    
    -- 使用BindingProperty绑定文本更新
    self.level:BindingProperty("Text", self.Level_Text, self);
    self.name:BindingProperty("Text", self.Name_Text, self);
    self.zhandouli:BindingProperty("Text", self.CombatPower_Text, self);
    self.zhuansheng:BindingProperty("Text", self.Rebirth_Text, self);
end

function Head:Level_Text(ReturnValue)
    -- 获取本地PlayerController（不变量）
    local controller = UGCGameSystem.GetLocalPlayerController()
    if not controller then
        return "Lv.1"
    end
    
    -- 通过Controller获取当前Pawn（每次都是最新的）
    local playerpawn = controller:K2_GetPawn()
    if not playerpawn then
        return "Lv.1"
    end
    
    -- 获取当前等级
    local level = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Level') or 0)
    
    -- 如果属性还没同步（值为0），使用默认值
    if level == 0 then level = 1 end
    
    return "Lv." .. tostring(level)
end

function Head:Name_Text(ReturnValue)
    -- 获取本地PlayerController（不变量）
    local controller = UGCGameSystem.GetLocalPlayerController()
    if not controller then
        return "玩家"
    end
    
    -- 通过Controller获取PlayerState
    local playerState = controller.PlayerState
    if not playerState then
        return "玩家"
    end
    
    local playerName = playerState.PlayerName
    if playerName and playerName ~= "" then
        return playerName
    end
    
    return "玩家"
end

function Head:CombatPower_Text(ReturnValue)
    -- 获取本地PlayerController（不变量）
    local controller = UGCGameSystem.GetLocalPlayerController()
    if not controller then
        return "战力: 0"
    end
    
    -- 通过Controller获取当前Pawn（每次都是最新的）
    local playerpawn = controller:K2_GetPawn()
    if not playerpawn then
        return "战力: 0"
    end
    
    -- 获取当前属性值
    local maxHp = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'HealthMax') or 0)
    local attack = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Attack') or 0)
    local magic = math.floor(UGCAttributeSystem.GetGameAttributeValue(playerpawn, 'Magic') or 0)
    
    -- 如果属性还没同步（值为0），使用默认值
    if maxHp == 0 then maxHp = 100 end
    if attack == 0 then attack = 20 end
    if magic == 0 then magic = 10 end
    
    local combatPower = math.floor(maxHp * 0.05 + attack * 0.7 + magic * 0.25)
    
    local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
    return "战力: " .. UGCGameData.FormatNumber(combatPower)
end

function Head:Rebirth_Text(ReturnValue)
    -- 获取本地PlayerController（不变量）
    local controller = UGCGameSystem.GetLocalPlayerController()
    if not controller then
        return "转生: 0"
    end
    
    -- 通过Controller获取PlayerState
    local playerState = controller.PlayerState
    if not playerState then
        return "转生: 0"
    end
    
    local rebirthCount = 0
    if playerState.UGCPlayerRebirthCount ~= nil then
        rebirthCount = playerState.UGCPlayerRebirthCount
    elseif playerState.GameData and playerState.GameData.PlayerRebirthCount ~= nil then
        rebirthCount = playerState.GameData.PlayerRebirthCount
    end
    
    return "转生: " .. tostring(rebirthCount)
end

-- [Editor Generated Lua] function define End;

return Head
