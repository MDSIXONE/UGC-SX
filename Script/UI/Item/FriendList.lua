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
---@field TextBlock_1killmob UTextBlock
---@field TextBlock_2killmob UTextBlock
---@field TextBlock_3killmob UTextBlock
---@field TextBlock_4killmob UTextBlock
--Edit Below--
local FriendList = { bInitDoOnce = false }

-- Related UI logic.
local SLOT_CONFIG = {
    [1] = { canvas = "CanvasPanel_1team", image = "Image_1team", name = "name1", bar = "ProgressBar_1team", killText = "TextBlock_1killmob" },
    [2] = { canvas = "CanvasPanel_2team", image = "Image_2team", name = "name2", bar = "ProgressBar_2team", killText = "TextBlock_2killmob" },
    [3] = { canvas = "CanvasPanel_3team", image = "Image_3team", name = "name3", bar = "ProgressBar_3team", killText = "TextBlock_3killmob" },
    [4] = { canvas = "CanvasPanel_4team", image = "Image_4team", name = "name4", bar = "ProgressBar_4team", killText = "TextBlock_4killmob" },
}

function FriendList:Construct()
    self:LuaInit()
    self.PlayerKillCountMap = {}
    -- Related UI logic.
    for i = 1, 4 do
        local cfg = SLOT_CONFIG[i]
        if self[cfg.canvas] then
            self[cfg.canvas]:SetVisibility(ESlateVisibility.Collapsed)
        end
        if self[cfg.killText] then
            self[cfg.killText]:SetText("0")
            self[cfg.killText]:SetVisibility(ESlateVisibility.Visible)
        end
    end
    -- Related UI logic.
    UGCTimerUtility.CreateLuaTimer(2.0, function()
        self:RefreshTeamInfo()
        -- Related UI logic.
        self.UpdateTimer = UGCTimerUtility.CreateLuaTimer(1.0, function()
            self:UpdateHealthBars()
        end, true, "FriendList_UpdateHP")
    end, false, "FriendList_InitDelay")
end

function FriendList:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
end

-- Related UI logic.
function FriendList:GetTeamPlayers()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return {} end
    local localPawn = PC.Pawn or PC:K2_GetPawn()

    local localTeamID = nil
    if localPawn and UGCObjectUtility.IsObjectValid(localPawn) then
        localTeamID = UGCPawnAttrSystem.GetTeamID(localPawn)
    end

    if localTeamID == nil or localTeamID < 0 then
        local localPlayerState = UGCGameSystem.GetLocalPlayerState()
        if localPlayerState then
            localTeamID = localPlayerState.TeamID
        end
    end

    if localTeamID == nil or localTeamID < 0 then return {} end

    local localPlayerKey = tostring(UGCGameSystem.GetPlayerKeyByPlayerController(PC) or "")

    local teamPawns = UGCTeamSystem.GetPlayerPawnsByTeamID(localTeamID)
    if not teamPawns then return {} end

    local keyedEntries = {}
    local keyedOrder = {}
    local keyScore = {}

    for _, pawn in ipairs(teamPawns) do
        if pawn and UGCObjectUtility.IsObjectValid(pawn) then
            local playerKey = UGCGameSystem.GetPlayerKeyByPlayerPawn(pawn)

            if playerKey == nil or playerKey == 0 then
                local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(pawn)
                if playerState and UGCPlayerStateSystem and UGCPlayerStateSystem.GetPlayerKeyInt64 then
                    local fallbackPlayerKey = UGCPlayerStateSystem.GetPlayerKeyInt64(playerState)
                    if fallbackPlayerKey and tostring(fallbackPlayerKey) ~= "0" then
                        playerKey = tostring(fallbackPlayerKey)
                    end
                end
            end

            local normalizedPlayerKey = nil
            if playerKey ~= nil then
                local keyText = tostring(playerKey)
                if keyText ~= "" and keyText ~= "0" then
                    normalizedPlayerKey = keyText
                end
            end

            local isSelf = (normalizedPlayerKey ~= nil and normalizedPlayerKey == localPlayerKey) or (pawn == localPawn)
            local playerName = UGCPawnAttrSystem.GetPlayerName(pawn) or "未知"

            local dedupeKey = nil
            if normalizedPlayerKey ~= nil then
                dedupeKey = normalizedPlayerKey
            elseif isSelf then
                dedupeKey = "self_fallback"
            end

            local candidateScore = 0
            if isSelf and localPawn and pawn == localPawn then
                candidateScore = candidateScore + 100
            end
            local hp = UGCAttributeSystem.GetGameAttributeValue(pawn, 'Health') or 0
            if hp > 0 then
                candidateScore = candidateScore + 10
            end

            local entryPlayerKey = normalizedPlayerKey
            if entryPlayerKey == nil and isSelf then
                entryPlayerKey = localPlayerKey
            end

            local entry = { pawn = pawn, name = playerName, isSelf = isSelf, playerKey = entryPlayerKey }
            if dedupeKey ~= nil then
                local existingScore = keyScore[dedupeKey]
                if existingScore == nil then
                    keyedEntries[dedupeKey] = entry
                    keyScore[dedupeKey] = candidateScore
                    table.insert(keyedOrder, dedupeKey)
                elseif candidateScore > existingScore then
                    keyedEntries[dedupeKey] = entry
                    keyScore[dedupeKey] = candidateScore
                end
            else
                table.insert(keyedOrder, entry)
            end
        end
    end

    local players = {}
    local selfEntry = nil
    for _, keyOrEntry in ipairs(keyedOrder) do
        local entry = nil
        if type(keyOrEntry) == "table" then
            entry = keyOrEntry
        else
            entry = keyedEntries[keyOrEntry]
        end

        if entry then
            if entry.isSelf then
                selfEntry = entry
            else
                table.insert(players, entry)
            end
        end
    end

    if selfEntry then
        table.insert(players, 1, selfEntry)
    end

    return players
end

-- Related UI logic.
function FriendList:RefreshTeamInfo()
    local players = self:GetTeamPlayers()
    self.TeamPawns = {}
    self.TeamPlayerKeys = {}

    for i = 1, 4 do
        local cfg = SLOT_CONFIG[i]
        local playerData = players[i]
        if playerData then
            self.TeamPawns[i] = playerData.pawn
            self.TeamPlayerKeys[i] = playerData.playerKey
            if self[cfg.canvas] then
                self[cfg.canvas]:SetVisibility(ESlateVisibility.Visible)
            end
            if self[cfg.name] then
                self[cfg.name]:SetText(playerData.name)
            end
            if self[cfg.killText] then
                self[cfg.killText]:SetVisibility(ESlateVisibility.Visible)
            end
            -- Related UI logic.
            self:UpdateSlotHealth(i)
            self:UpdateSlotKillCount(i)
        else
            self.TeamPawns[i] = nil
            self.TeamPlayerKeys[i] = nil
            if self[cfg.canvas] then
                self[cfg.canvas]:SetVisibility(ESlateVisibility.Collapsed)
            end
            if self[cfg.killText] then
                self[cfg.killText]:SetText("0")
                self[cfg.killText]:SetVisibility(ESlateVisibility.Collapsed)
            end
        end
    end
    -- Log this action.
end

-- Related UI logic.
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

    if hp <= 0 or maxHp <= 0 then
        local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(pawn)
        if playerState and playerState.GameData then
            if hp <= 0 then
                hp = playerState.GameData.PlayerHp or hp
            end
            if maxHp <= 0 then
                maxHp = playerState.GameData.PlayerMaxHp or maxHp
            end
        end
    end

    if maxHp <= 0 then maxHp = 1 end
    local percent = math.max(0, math.min(hp / maxHp, 1))

    if self[cfg.bar] then
        self[cfg.bar]:SetPercent(percent)
    end
end

-- Related UI logic.
function FriendList:GetPawnKillCount(pawn, playerKey)
    if playerKey and self.PlayerKillCountMap then
        local cached = self.PlayerKillCountMap[tostring(playerKey)]
        if cached ~= nil then
            return cached
        end
    end

    if not pawn or not UGCObjectUtility.IsObjectValid(pawn) then
        return 0
    end

    local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(pawn)
    if not playerState then
        return 0
    end

    local killCount = nil
    if playerState.GetKillCount then
        local ok, value = pcall(playerState.GetKillCount, playerState)
        if ok then
            killCount = tonumber(value)
        end
    end

    if killCount == nil then
        killCount = tonumber(playerState.KillCount)
    end

    if killCount == nil and playerState.GameData then
        killCount = tonumber(playerState.GameData.KillCount)
    end

    killCount = tonumber(killCount)
    if killCount == nil and playerKey and self.PlayerKillCountMap then
        killCount = self.PlayerKillCountMap[tostring(playerKey)]
    end

    killCount = killCount or 0
    if killCount < 0 then
        killCount = 0
    end

    return math.floor(killCount)
end

-- Related UI logic.
function FriendList:SyncPlayerKillCount(playerKey, killCount)
    local key = tostring(playerKey or "")
    if key == "" or key == "0" then
        return
    end

    if not self.PlayerKillCountMap then
        self.PlayerKillCountMap = {}
    end

    local normalizedKillCount = tonumber(killCount) or 0
    if normalizedKillCount < 0 then
        normalizedKillCount = 0
    end
    normalizedKillCount = math.floor(normalizedKillCount)
    self.PlayerKillCountMap[key] = normalizedKillCount
    ugcprint("[FriendList] SyncPlayerKillCount key=" .. tostring(key) .. ", kill=" .. tostring(normalizedKillCount))

    for i = 1, 4 do
        local slotKey = self.TeamPlayerKeys and self.TeamPlayerKeys[i]
        if slotKey and tostring(slotKey) == key then
            self:UpdateSlotKillCount(i)
        end
    end
end

-- Related UI logic.
function FriendList:UpdateSlotKillCount(index)
    local cfg = SLOT_CONFIG[index]
    local killText = self[cfg.killText]
    if not killText then
        return
    end

    local pawn = self.TeamPawns and self.TeamPawns[index]
    local playerKey = self.TeamPlayerKeys and self.TeamPlayerKeys[index]
    local killCount = self:GetPawnKillCount(pawn, playerKey)
    killText:SetText(tostring(killCount))
end

-- Related UI logic.
function FriendList:UpdateHealthBars()
    self:RefreshTeamInfo()
    for i = 1, 4 do
        self:UpdateSlotHealth(i)
        self:UpdateSlotKillCount(i)
    end
end

function FriendList:Destruct()
    if self.UpdateTimer then
        UGCTimerUtility.StopLuaTimer(self.UpdateTimer)
        self.UpdateTimer = nil
    end
end

return FriendList
