---@class DataConfig
---Table path constants and Get*Config functions.

local DataConfig = {}

---Format number into a string with unit suffix
function DataConfig.FormatNumber(num)
    if not num or num == 0 then
        return "0"
    end

    if num < 10000 then
        return tostring(math.floor(num))
    end

    if num < 100000000 then
        local wan = num / 10000
        local formatted = string.format("%.2f", wan)
        formatted = formatted:gsub("%.?0+$", "")
        return formatted .. "wan"
    end

    local yi = num / 100000000
    local formatted = string.format("%.2f", yi)
    formatted = formatted:gsub("%.?0+$", "")
    return formatted .. "yi"
end

---Table path constants
DataConfig.TaskTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/TASK.TASK')
DataConfig.RecipeTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/peifang.peifang')
DataConfig.ItemTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCObject.UGCObject')
DataConfig.ItemMappingTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCObjectMapping.UGCObjectMapping')
DataConfig.FubenTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/FuBenconfig.FuBenconfig')
DataConfig.FubenrewordTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Fubenreword.Fubenreword')
DataConfig.FenjieTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/fenjiebiao.fenjiebiao')
DataConfig.ChongzhiTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Chongzhibiao.Chongzhibiao')

function DataConfig.GetTaskConfig(taskRowIndex)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.TaskTablePath, tostring(taskRowIndex))
end

function DataConfig.GetAllTaskConfig()
    return UGCGameSystem.GetTableData(DataConfig.TaskTablePath)
end

function DataConfig.GetRecipeConfig(recipeID)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.RecipeTablePath, tostring(recipeID))
end

function DataConfig.GetAllRecipeConfig()
    return UGCGameSystem.GetTableData(DataConfig.RecipeTablePath)
end

function DataConfig.GetFenjieConfig(recipeID)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.FenjieTablePath, tostring(recipeID))
end

function DataConfig.GetAllFenjieConfig()
    return UGCGameSystem.GetTableData(DataConfig.FenjieTablePath)
end

function DataConfig.GetItemConfig(itemID)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.ItemTablePath, tostring(itemID))
end

function DataConfig.GetAllItemConfig()
    return UGCGameSystem.GetTableData(DataConfig.ItemTablePath)
end

function DataConfig.GetItemMapping(virtualItemID)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.ItemMappingTablePath, tostring(virtualItemID))
end

function DataConfig.GetAllItemMapping()
    return UGCGameSystem.GetTableData(DataConfig.ItemMappingTablePath)
end

function DataConfig.GetFubenConfig(modeID)
    local allConfigs = UGCGameSystem.GetTableData(DataConfig.FubenTablePath)
    if allConfigs then
        for rowName, config in pairs(allConfigs) do
            if config.ModeID == modeID then
                return config
            end
        end
    end
    return nil
end

function DataConfig.GetAllFubenConfig()
    return UGCGameSystem.GetTableData(DataConfig.FubenTablePath)
end

function DataConfig.GetFubenrewordByID(configID)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.FubenrewordTablePath, tostring(configID))
end

function DataConfig.GetAllFubenreword()
    return UGCGameSystem.GetTableData(DataConfig.FubenrewordTablePath)
end

function DataConfig.GetChongzhiConfig(rowIndex)
    return UGCGameSystem.GetTableDataByRowName(DataConfig.ChongzhiTablePath, tostring(rowIndex))
end

function DataConfig.GetAllChongzhiConfig()
    return UGCGameSystem.GetTableData(DataConfig.ChongzhiTablePath)
end

function DataConfig.GetChongzhiRewardConfig(rowIndex)
    local rawConfig = DataConfig.GetChongzhiConfig(rowIndex)
    if not rawConfig then
        return nil
    end

    local rewardConfig = {}
    for k, v in pairs(rawConfig) do
        rewardConfig[k] = v
    end

    local requiredSpend = tonumber(rawConfig.itemcount or rawConfig.NeedSpend or rawConfig.RequiredSpend) or 0
    local rewardItemID = tonumber(rawConfig.itemid or rawConfig.RewardItemID or rawConfig.ItemID) or 0
    local rewardItemCount = tonumber(rawConfig.itemnum or rawConfig.RewardItemCount or rawConfig.ItemNum or rawConfig.ItemCount) or 0

    rewardConfig.RequiredSpend = requiredSpend
    rewardConfig.RewardItemID = rewardItemID
    rewardConfig.RewardItemCount = rewardItemCount
    rewardConfig.ItemID = rewardItemID
    rewardConfig.ItemCount = rewardItemCount

    return rewardConfig
end

function DataConfig.GetTaSettlementReward(floorNum)
    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        return nil
    end

    local itemID = tonumber(Config_PlayerData.JiangeRewardVirtualItemID) or 0
    local itemCount = tonumber(Config_PlayerData.JiangeSettlementRewardCount) or 0
    if itemID <= 0 or itemCount <= 0 then
        return nil
    end

    return {
        ItemID = itemID,
        ItemCount = itemCount,
        itemid = itemID,
        itemcount = itemCount,
        itemnum = itemCount,
        Exp = 0,
    }
end

function DataConfig.GetJiangeFloorReward(floorNum)
    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        return nil
    end

    local floorRewardCount = Config_PlayerData.JiangeFloorRewardConfig and Config_PlayerData.JiangeFloorRewardConfig[floorNum]
    floorRewardCount = math.floor(tonumber(floorRewardCount) or 0)
    if floorRewardCount <= 0 then
        return nil
    end

    local itemID = tonumber(Config_PlayerData.JiangeRewardVirtualItemID) or 0
    if itemID <= 0 then
        return nil
    end

    return {
        ItemID = itemID,
        ItemCount = floorRewardCount,
        itemid = itemID,
        itemcount = floorRewardCount,
        itemnum = floorRewardCount,
    }
end

function DataConfig.GetJiangeDailyReward()
    local itemID = tonumber(Config_PlayerData.JiangeRewardVirtualItemID) or 0
    local itemCount = math.floor(tonumber(Config_PlayerData.JiangeDailyRewardCount) or 0)
    if itemID <= 0 or itemCount <= 0 then
        return nil
    end

    return {
        ItemID = itemID,
        ItemCount = itemCount,
        itemid = itemID,
        itemcount = itemCount,
        itemnum = itemCount,
    }
end

function DataConfig.GetGameModeActorMgrConfig(modeID)
    local config = DataConfig.GetFubenConfig(modeID)
    if config then
        return config.GameModeActorMgr or config.ActorMgrPath or config.MgrPath
    end
    return nil
end

function DataConfig.GetLevelConfig(Lv)
    local rowName
    if Lv < 1000 then
        rowName = string.format("1%03d", Lv)
    else
        rowName = "1" .. tostring(Lv)
    end

    local config = UGCGameSystem.GetTableDataByRowName(UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Level.Level'), rowName)

    if not config then
        config = {
            Exp = 10000 + (Lv - 1) * 100,
            AddHP = 21000 + (Lv - 1) * 500,
            AddHIT = 2300 + (Lv - 1) * 50,
            AddMG = 6900 + (Lv - 1) * 150,
        }
    end

    return config
end

function DataConfig.GetMonsterConfig(MonsterID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Monster.Monster'), tostring(MonsterID))
end

return DataConfig
