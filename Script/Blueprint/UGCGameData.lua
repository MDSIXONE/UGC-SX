local UGCGameData = {}

-- Global dead monster list
UGCGameData.DeadMonsters = UGCGameData.DeadMonsters or {}

--- Format number into a string with unit suffix
--- @param num number The number to format
--- @return string Formatted string
function UGCGameData.FormatNumber(num)
    if not num or num == 0 then
        return "0"
    end
    
    -- Less than 10k, display directly
    if num < 10000 then
        return tostring(math.floor(num))
    end
    
    -- Between 10k and 100M, display in "wan" (10k) unit
    if num < 100000000 then
        local wan = num / 10000
        -- Keep 2 decimals, trim trailing zeros
        local formatted = string.format("%.2f", wan)
        formatted = formatted:gsub("%.?0+$", "")
        return formatted .. "wan"
    end
    
    -- Over 100M, display in "yi" (100M) unit
    local yi = num / 100000000
    -- Keep 2 decimals, trim trailing zeros
    local formatted = string.format("%.2f", yi)
    formatted = formatted:gsub("%.?0+$", "")
    return formatted .. "yi"
end

-- Task table path
UGCGameData.TaskTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/TASK.TASK')

-- Recipe table path
UGCGameData.RecipeTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/peifang.peifang')

-- Item table path
UGCGameData.ItemTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCObject.UGCObject')

-- Item mapping table path
UGCGameData.ItemMappingTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCObjectMapping.UGCObjectMapping')

-- Dungeon mode table path
UGCGameData.FubenTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/FuBenconfig.FuBenconfig')

-- Dungeon reward table path
UGCGameData.FubenrewordTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Fubenreword.Fubenreword')

-- Decompose table path
UGCGameData.FenjieTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/fenjiebiao.fenjiebiao')

-- Charge table path
UGCGameData.ChongzhiTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Chongzhibiao.Chongzhibiao')

-- Jiange reward config (template-aligned virtual item flow)
UGCGameData.JiangeRewardVirtualItemID = 5666
UGCGameData.JiangeDailyRewardCount = 1
UGCGameData.JiangeSettlementRewardCount = 1
UGCGameData.JiangeFloorRewardConfig = {
    [100] = 100,
    [200] = 200,
    [300] = 300,
    [400] = 400,
    [500] = 500,
    [600] = 600,
    [700] = 700,
    [800] = 800,
    [900] = 900,
    [1000] = 1000,
}

--- Get task config
--- @param taskRowIndex number Task row index
--- @return table|nil Task config data
function UGCGameData.GetTaskConfig(taskRowIndex)
    local config = UGCGameSystem.GetTableDataByRowName(UGCGameData.TaskTablePath, tostring(taskRowIndex))
    if config then
        --[[ugcprint(string.format("[UGCGameData] GetTaskConfig(%d) success", taskRowIndex))]]
    else
        --[[ugcprint(string.format("[UGCGameData] GetTaskConfig(%d) failed - config not found, path: %s", taskRowIndex, UGCGameData.TaskTablePath))]]
    end
    return config
end

--- Get all task configs
--- @return table|nil All task config data
function UGCGameData.GetAllTaskConfig()
    return UGCGameSystem.GetTableData(UGCGameData.TaskTablePath)
end

--- Get recipe config
--- @param recipeID number Recipe ID
--- @return table|nil Recipe config data
function UGCGameData.GetRecipeConfig(recipeID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.RecipeTablePath, tostring(recipeID))
end

--- Get all recipe configs
--- @return table|nil All recipe config data
function UGCGameData.GetAllRecipeConfig()
    local allRecipes = UGCGameSystem.GetTableData(UGCGameData.RecipeTablePath)
    if allRecipes then
        --ugcprint("[UGCGameData] GetAllRecipeConfig success, recipe count: " .. tostring(#allRecipes))
    else
        --ugcprint("[UGCGameData] GetAllRecipeConfig failed - path: " .. tostring(UGCGameData.RecipeTablePath))
    end
    return allRecipes
end

--- Get decompose recipe config
--- @param recipeID number Decompose recipe ID
--- @return table|nil Decompose recipe config data
function UGCGameData.GetFenjieConfig(recipeID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.FenjieTablePath, tostring(recipeID))
end

--- Get all decompose recipe configs
--- @return table|nil All decompose recipe config data
function UGCGameData.GetAllFenjieConfig()
    local allFenjie = UGCGameSystem.GetTableData(UGCGameData.FenjieTablePath)
    if allFenjie then
        --ugcprint("[UGCGameData] GetAllFenjieConfig success")
    else
        --ugcprint("[UGCGameData] GetAllFenjieConfig failed - path: " .. tostring(UGCGameData.FenjieTablePath))
    end
    return allFenjie
end

--- Get item config
--- @param itemID number Item ID
--- @return table|nil Item config data
function UGCGameData.GetItemConfig(itemID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.ItemTablePath, tostring(itemID))
end

--- Get all item configs
--- @return table|nil All item config data
function UGCGameData.GetAllItemConfig()
    return UGCGameSystem.GetTableData(UGCGameData.ItemTablePath)
end

--- Get item mapping config (virtual item ID -> classic item ID)
--- @param virtualItemID number Virtual item ID
--- @return table|nil Mapping config data
function UGCGameData.GetItemMapping(virtualItemID)
    --ugcprint("[UGCGameData.GetItemMapping] Querying mapping, virtual ID: " .. tostring(virtualItemID))
    --ugcprint("[UGCGameData.GetItemMapping] Mapping table path: " .. tostring(UGCGameData.ItemMappingTablePath))
    local result = UGCGameSystem.GetTableDataByRowName(UGCGameData.ItemMappingTablePath, tostring(virtualItemID))
    if result then
        --ugcprint("[UGCGameData.GetItemMapping] Mapping data found")
    else
        --ugcprint("[UGCGameData.GetItemMapping] Mapping data not found")
    end
    return result
end

--- Get all item mapping configs
--- @return table|nil All mapping config data
function UGCGameData.GetAllItemMapping()
    return UGCGameSystem.GetTableData(UGCGameData.ItemMappingTablePath)
end

--- Get dungeon mode config
--- @param modeID number Dungeon mode ID
--- @return table|nil Dungeon mode config data
function UGCGameData.GetFubenConfig(modeID)
    -- ugcprint("[UGCGameData] GetFubenConfig called, modeID=" .. tostring(modeID))
    -- ugcprint("[UGCGameData] FubenTablePath=" .. tostring(UGCGameData.FubenTablePath))
    
    -- Iterate all configs to find the row matching ModeID
    local allConfigs = UGCGameSystem.GetTableData(UGCGameData.FubenTablePath)
    -- ugcprint("[UGCGameData] allConfigs=" .. tostring(allConfigs))
    
    if allConfigs then
        -- ugcprint("[UGCGameData] allConfigs type: " .. type(allConfigs))
        local count = 0
        for rowName, config in pairs(allConfigs) do
            count = count + 1
            -- ugcprint("[UGCGameData] row" .. count .. ": rowName=" .. tostring(rowName) .. ", ModeID=" .. tostring(config.ModeID))
            if config.ModeID == modeID then
                -- ugcprint("[UGCGameData] Matching config found!")
                return config
            end
        end
        -- ugcprint("[UGCGameData] Iterated " .. count .. " rows, ModeID=" .. tostring(modeID) .. " not found")
    else
        -- ugcprint("[UGCGameData] allConfigs is nil, unable to read data table")
    end
    return nil
end

--- Get all dungeon mode configs
--- @return table|nil All dungeon mode config data
function UGCGameData.GetAllFubenConfig()
    return UGCGameSystem.GetTableData(UGCGameData.FubenTablePath)
end

--- Get dungeon reward config
--- @param configID number Reward config ID
--- @return table|nil Dungeon reward config data
function UGCGameData.GetFubenrewordByID(configID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.FubenrewordTablePath, tostring(configID))
end

--- Get all dungeon reward configs
--- @return table|nil All dungeon reward config data
function UGCGameData.GetAllFubenreword()
    return UGCGameSystem.GetTableData(UGCGameData.FubenrewordTablePath)
end

--- Get charge table config (single row)
--- @param rowIndex number Row index
--- @return table|nil Charge config data
function UGCGameData.GetChongzhiConfig(rowIndex)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.ChongzhiTablePath, tostring(rowIndex))
end

--- Get all charge table configs
--- @return table|nil All charge config data
function UGCGameData.GetAllChongzhiConfig()
    return UGCGameSystem.GetTableData(UGCGameData.ChongzhiTablePath)
end

--- Get charge reward config (normalized fields for UI/server compatibility)
--- @param rowIndex number Row index
--- @return table|nil Charge reward config data
function UGCGameData.GetChongzhiRewardConfig(rowIndex)
    local rawConfig = UGCGameData.GetChongzhiConfig(rowIndex)
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

    -- Keep compatibility aliases for old callers.
    rewardConfig.ItemID = rewardItemID
    rewardConfig.ItemCount = rewardItemCount

    return rewardConfig
end

--- Get Jiange settlement reward config
--- @param floorNum number Current cleared floor
--- @return table|nil Reward config data
function UGCGameData.GetTaSettlementReward(floorNum)
    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        return nil
    end

    local itemID = tonumber(UGCGameData.JiangeRewardVirtualItemID) or 0
    local itemCount = tonumber(UGCGameData.JiangeSettlementRewardCount) or 0
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

--- Get Jiange floor reward config
--- @param floorNum number Target floor number
--- @return table|nil Reward config data
function UGCGameData.GetJiangeFloorReward(floorNum)
    floorNum = math.floor(tonumber(floorNum) or 0)
    if floorNum <= 0 then
        return nil
    end

    local floorRewardCount = UGCGameData.JiangeFloorRewardConfig and UGCGameData.JiangeFloorRewardConfig[floorNum]
    floorRewardCount = math.floor(tonumber(floorRewardCount) or 0)
    if floorRewardCount <= 0 then
        return nil
    end

    local itemID = tonumber(UGCGameData.JiangeRewardVirtualItemID) or 0
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

--- Get Jiange daily reward config
--- @return table|nil Reward config data
function UGCGameData.GetJiangeDailyReward()
    local itemID = tonumber(UGCGameData.JiangeRewardVirtualItemID) or 0
    local itemCount = math.floor(tonumber(UGCGameData.JiangeDailyRewardCount) or 0)
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

--- Get dungeon mode level flow manager config
--- @param modeID number Dungeon mode ID
--- @return string|nil Level flow manager path
function UGCGameData.GetGameModeActorMgrConfig(modeID)
    local config = UGCGameData.GetFubenConfig(modeID)
    if config then
        return config.GameModeActorMgr or config.ActorMgrPath or config.MgrPath
    end
    return nil
end

function UGCGameData.GetLevelConfig(Lv)
    -- Config table naming rule: "1" + level number (at least 3 digits)
    -- Level 1-999: 1001-1999 (using %03d)
    -- Level 1000+: 11000, 11001, ... (direct concatenation)
    local rowName
    if Lv < 1000 then
        -- Level 1-999 use 3-digit format
        rowName = string.format("1%03d", Lv)
    else
        -- Level 1000+ direct concatenation
        rowName = "1" .. tostring(Lv)
    end
    
    local config = UGCGameSystem.GetTableDataByRowName(UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Level.Level'), rowName)
    
    -- If config not found, use default values or calculate based on level
    if not config then
        --ugcprint("[UGCGameData] Warning: level " .. Lv .. " (rowName: " .. rowName .. ") has no config data, using default calculated values")
        
        -- Create default config with stats growing per level
        -- Base formula: fixed increment per level
        local baseExpPerLevel = 10000  -- Base exp required per level
        local expGrowth = 100          -- Exp growth per level
        
        config = {
            Exp = baseExpPerLevel + (Lv - 1) * expGrowth,  -- Exp required to level up
            AddHP = 21000 + (Lv - 1) * 500,                -- HP increase per level
            AddHIT = 2300 + (Lv - 1) * 50,                 -- Attack increase per level
            AddMG = 6900 + (Lv - 1) * 150,                 -- Magic increase per level
        }
        
        --ugcprint("[UGCGameData] Level " .. Lv .. " using default config: Exp=" .. config.Exp .. ", HP=" .. config.AddHP .. ", Attack=" .. config.AddHIT .. ", Magic=" .. config.AddMG)
    end
    
    return config
end

function UGCGameData.GetMonsterConfig(MonsterID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Monster.Monster'),tostring(MonsterID))
end

function UGCGameData.GetUI(PlayerController, UIName)
    --ugcprint("[UGCGameData.GetUI] Requesting UI creation: " .. tostring(UIName))
    
    if UIName == "choujiang" then
        local choujiangClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/Lottery/OfficialPackage/Asset/Lottery/Blueprint/WBP_OpenLotteryButton.WBP_OpenLotteryButton_C'))
        local choujiang = UserWidget.NewWidgetObjectBP(PlayerController, choujiangClass)
        return choujiang

    elseif UIName == "touxiang" then
        local TouxiangClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/touxiang.touxiang_C'))
        local Touxiang = UserWidget.NewWidgetObjectBP(PlayerController, TouxiangClass)
        return Touxiang

    elseif UIName == "chuansong" then
        local ChuansongClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/chuansong.chuansong_C'))
        local Chuansong = UserWidget.NewWidgetObjectBP(PlayerController, ChuansongClass)
        return Chuansong

    elseif UIName == "zhuansheng" then
        local ZhuanshengClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/zhuansheng.zhuansheng_C'))
        local Zhuansheng = UserWidget.NewWidgetObjectBP(PlayerController, ZhuanshengClass)
        return Zhuansheng
        
    elseif UIName == "shop" then
        local ShopOpenUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/ShopV2/OfficialPackage/Asset/ShopV2/Blueprint/ShopV2_OpenShopButton_UIBP.ShopV2_OpenShopButton_UIBP_C'))
        local ShopOpenUI = UserWidget.NewWidgetObjectBP(PlayerController, ShopOpenUIClass)
        return ShopOpenUI
    
    elseif UIName == "libao" then
        local libaoOpenUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/GiftPack/OfficialPackage/Asset/GiftPack/Blueprint/WBP_GiftPackBtn.WBP_GiftPackBtn_C'))
        local libaoOpenUI = UserWidget.NewWidgetObjectBP(PlayerController, libaoOpenUIClass)
        return libaoOpenUI

    elseif UIName == "MMainUI" then
        --ugcprint("[UGCGameData.GetUI] Loading MMainUI class")
        local MMainUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/MMainUI.MMainUI_C'))
        if not MMainUIClass then
            --ugcprint("[UGCGameData.GetUI] Error: failed to load MMainUI class")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MMainUI class loaded, creating instance")
        local MMainUI = UserWidget.NewWidgetObjectBP(PlayerController, MMainUIClass)
        if not MMainUI then
            --ugcprint("[UGCGameData.GetUI] Error: failed to create MMainUI instance")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MMainUI instance created successfully")
        return MMainUI

    elseif UIName == "JiangeUI" then
        local JiangeUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/JiangeUI.JiangeUI_C'))
        if not JiangeUIClass then return nil end
        local JiangeUI = UserWidget.NewWidgetObjectBP(PlayerController, JiangeUIClass)
        return JiangeUI

    elseif UIName == "MainWidget" then
        --ugcprint("[UGCGameData.GetUI] Loading MainWidget class")
        local MainWidgetClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/MainWidget.MainWidget_C'))
        if not MainWidgetClass then
            --ugcprint("[UGCGameData.GetUI] Error: failed to load MainWidget class")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MainWidget class loaded, creating instance")
        local MainWidget = UserWidget.NewWidgetObjectBP(PlayerController, MainWidgetClass)
        if not MainWidget then
            --ugcprint("[UGCGameData.GetUI] Error: failed to create MainWidget instance")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MainWidget instance created successfully")
        return MainWidget

    elseif UIName == "taskbuttun" then
        local TaskButtonClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/taskbuttun.taskbuttun_C'))
        if not TaskButtonClass then
            --ugcprint("[UGCGameData.GetUI] Error: failed to load taskbuttun class")
            return nil
        end
        local TaskButton = UserWidget.NewWidgetObjectBP(PlayerController, TaskButtonClass)
        return TaskButton
    
    elseif UIName == "TASK" then
        local TaskUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/TASK.TASK_C'))
        if not TaskUIClass then
            --ugcprint("[UGCGameData.GetUI] Error: failed to load TASK class")
            return nil
        end
        local TaskUI = UserWidget.NewWidgetObjectBP(PlayerController, TaskUIClass)
        return TaskUI
    
    elseif UIName == "ConfirmPurchase" then
        --ugcprint("[UGCGameData.GetUI] Loading ConfirmPurchase_UIBP class")
        local ConfirmPurchaseClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/ConfirmPurchase_UIBP.ConfirmPurchase_UIBP_C'))
        if not ConfirmPurchaseClass then
            --ugcprint("[UGCGameData.GetUI] Error: failed to load ConfirmPurchase_UIBP class")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] ConfirmPurchase_UIBP class loaded, creating instance")
        local ConfirmPurchase = UserWidget.NewWidgetObjectBP(PlayerController, ConfirmPurchaseClass)
        if not ConfirmPurchase then
            --ugcprint("[UGCGameData.GetUI] Error: failed to create ConfirmPurchase_UIBP instance")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] ConfirmPurchase_UIBP instance created successfully")
        return ConfirmPurchase

    elseif UIName == "WB_Team" then
        local TeamClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Team.WB_Team_C'))
        if not TeamClass then
            --ugcprint("[UGCGameData.GetUI] Error: failed to load WB_Team class")
            return nil
        end
        local Team = UserWidget.NewWidgetObjectBP(PlayerController, TeamClass)
        return Team
    end
    
    --ugcprint("[UGCGameData.GetUI] Warning: unknown UI name: " .. tostring(UIName))
    return nil
end

return UGCGameData
