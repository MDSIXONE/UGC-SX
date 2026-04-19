---@class UGCGameData
---Thin facade that re-exports all DataConfig functions for backward compatibility.
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')
local DataConfig = UGCGameSystem.UGCRequire('Script.Common.DataConfig')

local UGCGameData = {}

UGCGameData.DeadMonsters = UGCGameData.DeadMonsters or {}

function UGCGameData.FormatNumber(num)
    return DataConfig.FormatNumber(num)
end

UGCGameData.TaskTablePath = DataConfig.TaskTablePath
UGCGameData.RecipeTablePath = DataConfig.RecipeTablePath
UGCGameData.ItemTablePath = DataConfig.ItemTablePath
UGCGameData.ItemMappingTablePath = DataConfig.ItemMappingTablePath
UGCGameData.FubenTablePath = DataConfig.FubenTablePath
UGCGameData.FubenrewordTablePath = DataConfig.FubenrewordTablePath
UGCGameData.FenjieTablePath = DataConfig.FenjieTablePath
UGCGameData.ChongzhiTablePath = DataConfig.ChongzhiTablePath
UGCGameData.JiangeRewardVirtualItemID = Config_PlayerData.JiangeRewardVirtualItemID
UGCGameData.JiangeDailyRewardCount = Config_PlayerData.JiangeDailyRewardCount
UGCGameData.JiangeSettlementRewardCount = Config_PlayerData.JiangeSettlementRewardCount
UGCGameData.JiangeFloorRewardConfig = Config_PlayerData.JiangeFloorRewardConfig

function UGCGameData.GetTaskConfig(taskRowIndex)
    return DataConfig.GetTaskConfig(taskRowIndex)
end

function UGCGameData.GetAllTaskConfig()
    return DataConfig.GetAllTaskConfig()
end

function UGCGameData.GetRecipeConfig(recipeID)
    return DataConfig.GetRecipeConfig(recipeID)
end

function UGCGameData.GetAllRecipeConfig()
    return DataConfig.GetAllRecipeConfig()
end

function UGCGameData.GetFenjieConfig(recipeID)
    return DataConfig.GetFenjieConfig(recipeID)
end

function UGCGameData.GetAllFenjieConfig()
    return DataConfig.GetAllFenjieConfig()
end

function UGCGameData.GetItemConfig(itemID)
    return DataConfig.GetItemConfig(itemID)
end

function UGCGameData.GetAllItemConfig()
    return DataConfig.GetAllItemConfig()
end

function UGCGameData.GetItemMapping(virtualItemID)
    return DataConfig.GetItemMapping(virtualItemID)
end

function UGCGameData.GetAllItemMapping()
    return DataConfig.GetAllItemMapping()
end

function UGCGameData.GetFubenConfig(modeID)
    return DataConfig.GetFubenConfig(modeID)
end

function UGCGameData.GetAllFubenConfig()
    return DataConfig.GetAllFubenConfig()
end

function UGCGameData.GetFubenrewordByID(configID)
    return DataConfig.GetFubenrewordByID(configID)
end

function UGCGameData.GetAllFubenreword()
    return DataConfig.GetAllFubenreword()
end

function UGCGameData.GetChongzhiConfig(rowIndex)
    return DataConfig.GetChongzhiConfig(rowIndex)
end

function UGCGameData.GetAllChongzhiConfig()
    return DataConfig.GetAllChongzhiConfig()
end

function UGCGameData.GetChongzhiRewardConfig(rowIndex)
    return DataConfig.GetChongzhiRewardConfig(rowIndex)
end

function UGCGameData.GetTaSettlementReward(floorNum)
    return DataConfig.GetTaSettlementReward(floorNum)
end

function UGCGameData.GetJiangeFloorReward(floorNum)
    return DataConfig.GetJiangeFloorReward(floorNum)
end

function UGCGameData.GetJiangeDailyReward()
    return DataConfig.GetJiangeDailyReward()
end

function UGCGameData.GetGameModeActorMgrConfig(modeID)
    return DataConfig.GetGameModeActorMgrConfig(modeID)
end

function UGCGameData.GetLevelConfig(Lv)
    return DataConfig.GetLevelConfig(Lv)
end

function UGCGameData.GetMonsterConfig(MonsterID)
    return DataConfig.GetMonsterConfig(MonsterID)
end

function UGCGameData.GetUI(PlayerController, UIName)
    local UIWidgetFactory = UGCGameSystem.UGCRequire('Script.Common.UIWidgetFactory')
    return UIWidgetFactory.GetUI(PlayerController, UIName)
end

return UGCGameData
