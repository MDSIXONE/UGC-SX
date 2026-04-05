---@class FriendList_C:UUserWidget
---@field CanvasPanel_73 UCanvasPanel
---@field CanvasPanel_74 UCanvasPanel
---@field CanvasPanel_75 UCanvasPanel
---@field CanvasPanel_1team UCanvasPanel
---@field CanvasPanel_2team UCanvasPanel
---@field CanvasPanel_3team UCanvasPanel
---@field CanvasPanel_4team UCanvasPanel
---@field CanvasPanel_SingalBar UCanvasPanel
---@field Image_1team UImage
---@field Image_2team UImage
---@field Image_3team UImage
---@field Image_4team UImage
---@field name1 UTextBlock
---@field name2 UTextBlock
---@field name3 UTextBlock
---@field name4 UTextBlock
---@field ProgressBar_1team UProgressBar
---@field ProgressBar_2team UProgressBar
---@field ProgressBar_3team UProgressBar
---@field ProgressBar_4team UProgressBar
--Edit Below--
local FriendList = { bInitDoOnce = false }

-- 姣忎釜妲戒綅瀵瑰簲鐨勬帶浠舵槧灏?
local SLOT_CONFIG = {
    [1] = { canvas = "CanvasPanel_1team", image = "Image_1team", name = "name1", bar = "ProgressBar_1team" },
    [2] = { canvas = "CanvasPanel_2team", image = "Image_2team", name = "name2", bar = "ProgressBar_2team" },
    [3] = { canvas = "CanvasPanel_3team", image = "Image_3team", name = "name3", bar = "ProgressBar_3team" },
    [4] = { canvas = "CanvasPanel_4team", image = "Image_4team", name = "name4", bar = "ProgressBar_4team" },
}

function FriendList:Construct()
    self:LuaInit()
    -- 鍏堥殣钘忔墍鏈夋Ы浣?
    for i = 1, 4 do
        local cfg = SLOT_CONFIG[i]
        if self[cfg.canvas] then
            self[cfg.canvas]:SetVisibility(ESlateVisibility.Collapsed)
        end
    end
    -- 寤惰繜鍚姩鍒锋柊锛堢瓑鐜╁鏁版嵁灏辩华锛?
    UGCTimerUtility.CreateLuaTimer(2.0, function()
        self:RefreshTeamInfo()
        -- 姣忕鍒锋柊琛€鏉?
        self.UpdateTimer = UGCTimerUtility.CreateLuaTimer(1.0, function()
            self:UpdateHealthBars()
        end, true, "FriendList_UpdateHP")
    end, false, "FriendList_InitDelay")
end

function FriendList:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
end

-- 鑾峰彇鍚岄槦鐜╁鍒楄〃锛堟帓闄よ嚜宸憋級
function FriendList:GetTeamPlayers()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return {} end
    local localPawn = PC.Pawn or PC:K2_GetPawn()
    if not localPawn or not UGCObjectUtility.IsObjectValid(localPawn) then return {} end

    local localTeamID = UGCPawnAttrSystem.GetTeamID(localPawn)
    local localPlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PC)

    local teamPawns = UGCTeamSystem.GetPlayerPawnsByTeamID(localTeamID)
    if not teamPawns then return {} end

    local players = {}
    for _, pawn in ipairs(teamPawns) do
        if pawn and UGCObjectUtility.IsObjectValid(pawn) then
            local playerKey = UGCGameSystem.GetPlayerKeyByPlayerPawn(pawn)
            if playerKey ~= localPlayerKey then
                local playerName = UGCPawnAttrSystem.GetPlayerName(pawn) or "鏈煡"
                table.insert(players, { pawn = pawn, name = playerName })
            end
        end
    end
    return players
end

-- 鍒锋柊闃熶紞淇℃伅锛堝悕瀛?+ 鍒濆琛€鏉?+ 鏄剧ず/闅愯棌妲戒綅锛?
function FriendList:RefreshTeamInfo()
    local players = self:GetTeamPlayers()
    self.TeamPawns = {}

    for i = 1, 4 do
        local cfg = SLOT_CONFIG[i]
        local playerData = players[i]
        if playerData then
            self.TeamPawns[i] = playerData.pawn
            if self[cfg.canvas] then
                self[cfg.canvas]:SetVisibility(ESlateVisibility.Visible)
            end
            if self[cfg.name] then
                self[cfg.name]:SetText(playerData.name)
            end
            -- 璁剧疆鍒濆琛€鏉?
            self:UpdateSlotHealth(i)
        else
            self.TeamPawns[i] = nil
            if self[cfg.canvas] then
                self[cfg.canvas]:SetVisibility(ESlateVisibility.Collapsed)
            end
        end
    end
    -- ugcprint("[FriendList] 闃熶紞鍒锋柊瀹屾垚锛岄槦鍙嬫暟閲? " .. tostring(#players))
end

-- 鏇存柊鍗曚釜妲戒綅琛€鏉?
function FriendList:UpdateSlotHealth(index)
    local cfg = SLOT_CONFIG[index]
    local pawn = self.TeamPawns and self.TeamPawns[index]
    if not pawn or not UGCObjectUtility.IsObjectValid(pawn) then
        if self[cfg.bar] then
            self[cfg.bar]:SetPercent(0)
        end
        return
    end

    local hp = UGCAttributeSystem.GetGameAttributeValue(pawn, 'Health') or 0
    local maxHp = UGCAttributeSystem.GetGameAttributeValue(pawn, 'HealthMax') or 1
    if maxHp <= 0 then maxHp = 1 end
    local percent = math.max(0, math.min(hp / maxHp, 1))

    if self[cfg.bar] then
        self[cfg.bar]:SetPercent(percent)
    end
end

-- 姣忕鏇存柊鎵€鏈夎鏉?
function FriendList:UpdateHealthBars()
    for i = 1, 4 do
        self:UpdateSlotHealth(i)
    end
end

function FriendList:Destruct()
    if self.UpdateTimer then
        UGCTimerUtility.StopLuaTimer(self.UpdateTimer)
        self.UpdateTimer = nil
    end
end

return FriendList
