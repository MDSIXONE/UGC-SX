---@class VirtualItemSystem
---Virtual item and backpack operations.
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')

local VirtualItemSystem = {}

local FORGE_STONE_ITEM_ID = 5666

local function GetVirtualItemCount(itemID, playerController)
    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    if not VirtualItemManager then
        return 0
    end

    local queryOk, queryRet = pcall(function()
        if playerController then
            return VirtualItemManager:GetItemNum(itemID, playerController)
        end
        return VirtualItemManager:GetItemNum(itemID)
    end)
    if queryOk then
        return math.max(0, tonumber(queryRet) or 0)
    end

    local fallbackOk, fallbackRet = pcall(function()
        return VirtualItemManager:GetItemNum(itemID)
    end)
    if fallbackOk then
        return math.max(0, tonumber(fallbackRet) or 0)
    end

    return 0
end

local function ParseRemoveResult(result)
    if result == nil then
        return true
    end

    local resultType = type(result)
    if resultType == "boolean" then
        return result
    end
    if resultType == "number" then
        return result > 0
    end
    if resultType == "table" then
        if result.bSucceeded ~= nil then
            return result.bSucceeded == true
        end
        if result.bSuccess ~= nil then
            return result.bSuccess == true
        end
        if result.Success ~= nil then
            return result.Success == true
        end
        if result.Result ~= nil then
            return result.Result == true
        end
    end

    return false
end

function VirtualItemSystem.Server_RemoveVirtualItem(self, virtualItemID, count)
    if not UGCGameSystem.IsServer(self) then return end

    virtualItemID = tonumber(virtualItemID) or 0
    count = math.floor(tonumber(count) or 0)
    if virtualItemID <= 0 or count <= 0 then return end

    local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
    local PC = UGCGameSystem.GetPlayerControllerByPlayerState(self)
    if (not VirtualItemManager) or (not PC) then
        return
    end

    if virtualItemID == FORGE_STONE_ITEM_ID then
        local function NotifyForgeConsumeResult(success, tipText)
            UnrealNetwork.CallUnrealRPC(PC, PC, "Client_OnJiangeForgeConsumeResult", success == true, GetVirtualItemCount(virtualItemID, PC), tipText or "")
        end

        local callbackDone = false
        local beforeCount = GetVirtualItemCount(virtualItemID, PC)

        local callOk = pcall(function()
            VirtualItemManager:RemoveVirtualItem(PC, virtualItemID, count, function(result)
                callbackDone = true
                local success = ParseRemoveResult(result)
                if success then
                    NotifyForgeConsumeResult(true, "")
                else
                    NotifyForgeConsumeResult(false, "锻造石不足，无法升级")
                end
            end)
        end)

        if not callOk then
            local fallbackResult = nil
            local fallbackOk = pcall(function()
                fallbackResult = VirtualItemManager:RemoveVirtualItem(PC, virtualItemID, count)
            end)

            if (not fallbackOk) or (not ParseRemoveResult(fallbackResult)) then
                NotifyForgeConsumeResult(false, "锻造石不足，无法升级")
                return
            end

            NotifyForgeConsumeResult(true, "")
            return
        end

        UGCGameSystem.SetTimer(self, function()
            if callbackDone then
                return
            end

            local afterCount = GetVirtualItemCount(virtualItemID, PC)
            if afterCount <= (beforeCount - count) then
                NotifyForgeConsumeResult(true, "")
            else
                NotifyForgeConsumeResult(false, "锻造石不足，无法升级")
            end
        end, 0.35, false)

        return
    end

    VirtualItemManager:RemoveVirtualItem(PC, virtualItemID, count)
end

function VirtualItemSystem.Server_RemoveBackpackItem(self, itemID, count)
    if not UGCGameSystem.IsServer(self) then return end

    itemID = tonumber(itemID) or 0
    count = math.floor(tonumber(count) or 0)
    if itemID <= 0 or count <= 0 then return end

    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        UGCBackpackSystemV2.RemoveItemV2(PlayerPawn, itemID, count)
    end
end

function VirtualItemSystem.Server_AddSpendCount(self, amount)
    if not UGCGameSystem.IsServer(self) then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then
        return
    end

    self.GameData.PlayerVIP = Config_PlayerData.CalcVIPLevelBySpend(self:GetTotalSpendCount())
    self:ReplicateSpendProperties()
    self:UpdateSpendRank()
    self:DataSave()
end

function VirtualItemSystem.Server_AddShopBuyCount(self)
end

return VirtualItemSystem
