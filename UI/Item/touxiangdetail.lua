---@class touxiangdetail_C:UUserWidget
---@field ATTACK UTextBlock
---@field Detail_Cancel General_SecondLevelButton_3_C
---@field Ecexp UTextBlock
---@field Image_39 UImage
---@field LIVE UTextBlock
---@field MAGIC UTextBlock
--Edit Below--
local touxiangdetail = { bInitDoOnce = false } 


function touxiangdetail:Construct()
	self:LuaInit();
    
    -- 绑定数值显示
    self.ATTACK:BindingProperty("Text", self.ATTACK_Text, self)
    self.MAGIC:BindingProperty("Text", self.MAGIC_Text, self)
    self.LIVE:BindingProperty("Text", self.LIVE_Text, self)
    self.Ecexp:BindingProperty("Text", self.Ecexp_Text, self)
    
    -- 绑定关闭按钮
    if self.Detail_Cancel and self.Detail_Cancel.Button_Levels2_3 then
        self.Detail_Cancel.Button_Levels2_3.OnClicked:Add(self.OnCancelClicked, self)
        --ugcprint("[touxiangdetail] 关闭按钮绑定成功")
    end
end

-- 攻击力显示
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

-- 魔法值显示
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

-- 转生次数显示
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

-- 吞噬额外加成显示
function touxiangdetail:Ecexp_Text(ReturnValue)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    local bonusPercent = 1
    
    if playerState and playerState.GameData then
        -- 从 GameData 中获取吞噬加成百分比
        bonusPercent = playerState.GameData.PlayerEcexp or 1
    end
    
    return "吞噬加成: " .. tostring(bonusPercent) .. "%"
end

-- 关闭按钮点击
function touxiangdetail:OnCancelClicked()
    --ugcprint("[touxiangdetail] 关闭详情界面")
    self:SetVisibility(ESlateVisibility.Collapsed)
end

-- [Editor Generated Lua] function define Begin:
function touxiangdetail:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
end

-- [Editor Generated Lua] function define End;

return touxiangdetail