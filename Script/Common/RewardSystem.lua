---@class RewardSystem
---Reward claiming, serialization, and grant helpers.
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

local RewardSystem = {}

function RewardSystem.SerializeClaimedChongzhi(self, claimedMap)
    if not claimedMap then
        return ""
    end

    local ids = {}
    for rewardID, claimed in pairs(claimedMap) do
        if claimed then
            table.insert(ids, tonumber(rewardID) or rewardID)
        end
    end

    table.sort(ids, function(a, b)
        return (tonumber(a) or 0) < (tonumber(b) or 0)
    end)

    local serialized = {}
    for _, rewardID in ipairs(ids) do
        table.insert(serialized, tostring(rewardID))
    end
    return table.concat(serialized, ",")
end

function RewardSystem.DeserializeClaimedChongzhi(self, claimedStr)
    local claimedMap = {}
    if not claimedStr or claimedStr == "" then
        return claimedMap
    end

    for token in string.gmatch(claimedStr, "([^,]+)") do
        local rewardID = tonumber(token)
        if rewardID then
            claimedMap[rewardID] = true
        end
    end
    return claimedMap
end

function RewardSystem.NormalizeClaimedChongzhiMap(self, claimedRaw)
    local claimedMap = {}
    if type(claimedRaw) ~= "table" then
        return claimedMap
    end

    for key, value in pairs(claimedRaw) do
        local keyID = tonumber(key)
        if keyID and (value == true or value == 1 or value == "1" or value == "true") then
            claimedMap[keyID] = true
        end

        local valueID = tonumber(value)
        if valueID and valueID > 0 then
            claimedMap[valueID] = true
        end
    end

    return claimedMap
end

---Grant reward to player
local function GrantRewardToPlayerState(playerState, itemID, itemCount)
    itemID = tonumber(itemID) or 0
    itemCount = math.floor(tonumber(itemCount) or 0)
    if itemID <= 0 or itemCount <= 0 then
        return false
    end

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(playerState)
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    if VirtualItemManager and PC then
        local addResult = nil
        local addOk = pcall(function()
            addResult = VirtualItemManager:AddVirtualItem(PC, itemID, itemCount)
        end)
        if addOk and (addResult == nil or addResult == true or (type(addResult) == "number" and addResult > 0)) then
            return true
        end
    end

    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(playerState)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local addedCount = UGCBackpackSystemV2.AddItemV2(PlayerPawn, itemID, itemCount)
        if addedCount == true then
            return true
        end
        if type(addedCount) == "number" and addedCount > 0 then
            return true
        end
    end

    return false
end
RewardSystem.GrantRewardToPlayerState = GrantRewardToPlayerState

function RewardSystem.Server_ClaimChongzhiReward(self, rewardID)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    rewardID = math.floor(tonumber(rewardID) or 0)
    if rewardID <= 0 then return end

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    local function NotifyChongzhiClaimResult(success, tipText)
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnChongzhiClaimResult", success == true, rewardID, tipText or "")
        end
    end

    self.ChongzhiClaimPending = self.ChongzhiClaimPending or {}
    if self.ChongzhiClaimPending[rewardID] then
        NotifyChongzhiClaimResult(false, "领取处理中，请稍后")
        return
    end
    self.ChongzhiClaimPending[rewardID] = true

    local function FinishClaim(success, tipText)
        self.ChongzhiClaimPending[rewardID] = nil
        NotifyChongzhiClaimResult(success, tipText)
    end

    if self.ClaimedChongzhi and (self.ClaimedChongzhi[rewardID] or self.ClaimedChongzhi[tostring(rewardID)]) then
        FinishClaim(false, "该奖励已领取")
        return
    end

    local rewardConfig = UGCGameData.GetChongzhiRewardConfig(rewardID)
    if not rewardConfig then
        FinishClaim(false, "奖励配置不存在")
        return
    end

    local requiredSpend = rewardConfig.RequiredSpend or 0
    local currentSpend = self:GetTotalSpendCount()
    if currentSpend < requiredSpend then
        FinishClaim(false, "累计充值不足，无法领取")
        return
    end

    local rewardItemID = tonumber(rewardConfig.RewardItemID or rewardConfig.ItemID or rewardConfig.itemid) or 0
    local rewardItemCount = math.floor(tonumber(rewardConfig.RewardItemCount or rewardConfig.ItemCount or rewardConfig.itemnum) or 0)
    if rewardItemID <= 0 or rewardItemCount <= 0 then
        FinishClaim(false, "奖励配置异常")
        return
    end

    if not GrantRewardToPlayerState(self, rewardItemID, rewardItemCount) then
        FinishClaim(false, "发放奖励失败，请稍后再试")
        return
    end

    if not self.ClaimedChongzhi then
        self.ClaimedChongzhi = {}
    end
    self.ClaimedChongzhi[rewardID] = true
    self:ReplicateSpendProperties()
    self:DataSave()
    FinishClaim(true, "充值奖励领取成功")
end

function RewardSystem.Server_GiveTaReward(self, floorNum)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        floorNum = math.floor(tonumber(self.GameData and self.GameData.PlayerJiangeFloor) or 0)
    end
    if floorNum <= 0 then return end

    if floorNum > (self.GameData.PlayerJiangeFloor or 0) then
        self.GameData.PlayerJiangeFloor = floorNum
        local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_UpdateJiangeFloor", floorNum)
        end
        self:UpdateJiangeFloorRank()
    end

    local rewardConfig = UGCGameData.GetTaSettlementReward(floorNum)
    if rewardConfig then
        local rewardItemID = tonumber(rewardConfig.ItemID or rewardConfig.itemid) or 0
        local rewardItemCount = math.floor(tonumber(rewardConfig.ItemCount or rewardConfig.itemcount or rewardConfig.itemnum) or 0)
        if rewardItemID > 0 and rewardItemCount > 0 then
            GrantRewardToPlayerState(self, rewardItemID, rewardItemCount)
        end

        local rewardExp = tonumber(rewardConfig.Exp or rewardConfig.exp) or 0
        if rewardExp > 0 then
            self:AddExp(rewardExp)
        end
    end

    self:DataSave()
end

function RewardSystem.Server_ClaimJiangeFloorReward(self, floorNum)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)

    local function NotifyFloorClaimResult(success, tipText)
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeFloorClaimResult", success, floorNum, tipText or "")
        end
    end

    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        NotifyFloorClaimResult(false, "参数错误")
        return
    end

    local currentFloor = self.GameData.PlayerJiangeFloor or 0
    if currentFloor < floorNum then
        NotifyFloorClaimResult(false, "当前层数不足，无法领取该层奖励")
        return
    end

    local claimed = self.GameData.PlayerJiangeFloorClaimed or ""
    if string.find("," .. claimed .. ",", "," .. tostring(floorNum) .. ",") then
        NotifyFloorClaimResult(false, "该层奖励已领取")
        return
    end

    local rewardConfig = UGCGameData.GetJiangeFloorReward(floorNum)
    local rewardItemID = tonumber(rewardConfig and (rewardConfig.ItemID or rewardConfig.itemid)) or 0
    local rewardItemCount = math.floor(tonumber(rewardConfig and (rewardConfig.ItemCount or rewardConfig.itemcount or rewardConfig.itemnum)) or 0)
    if rewardItemID <= 0 or rewardItemCount <= 0 then
        NotifyFloorClaimResult(false, "奖励配置异常")
        return
    end

    if not GrantRewardToPlayerState(self, rewardItemID, rewardItemCount) then
        NotifyFloorClaimResult(false, "领取失败，请稍后再试")
        return
    end

    if claimed == "" then
        self.GameData.PlayerJiangeFloorClaimed = tostring(floorNum)
    else
        self.GameData.PlayerJiangeFloorClaimed = claimed .. "," .. tostring(floorNum)
    end

    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeRewardData",
            self.GameData.PlayerJiangeFloorClaimed,
            self.GameData.PlayerJiangeDailyClaimDate or "",
            1)
    end

    NotifyFloorClaimResult(true, tostring(floorNum) .. "层奖励领取成功")

    self:DataSave()
end

function RewardSystem.Server_ClaimJiangeDailyReward(self)
    if not UGCGameSystem.IsServer(self) then return end
    self:EnsureDataInitialized()

    local todayStr = os.date("%Y-%m-%d")
    local lastClaimDate = self.GameData.PlayerJiangeDailyClaimDate or ""

    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)

    if lastClaimDate == todayStr then
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", false, 0, "今日已领取过每日奖励")
        end
        return
    end

    local dailyRewardConfig = UGCGameData.GetJiangeDailyReward()
    local rewardItemID = tonumber(dailyRewardConfig and (dailyRewardConfig.ItemID or dailyRewardConfig.itemid)) or 0
    local rewardItemCount = math.floor(tonumber(dailyRewardConfig and (dailyRewardConfig.ItemCount or dailyRewardConfig.itemcount or dailyRewardConfig.itemnum)) or 0)
    if rewardItemID <= 0 or rewardItemCount <= 0 then
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", false, 0, "奖励配置异常")
        end
        return
    end

    if not GrantRewardToPlayerState(self, rewardItemID, rewardItemCount) then
        if PC then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", false, 0, "领取失败，请稍后再试")
        end
        return
    end

    local amount = rewardItemCount

    self.GameData.PlayerJiangeDailyClaimDate = todayStr

    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeDailyClaimResult", true, amount, "领取成功！")
        UnrealNetwork.CallUnrealRPC(PC, PC, "Client_SyncJiangeRewardData",
            self.GameData.PlayerJiangeFloorClaimed or "",
            self.GameData.PlayerJiangeDailyClaimDate,
            amount)
    end

    self:DataSave()
end

return RewardSystem
