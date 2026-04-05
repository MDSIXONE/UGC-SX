local UGCGameData = {}

-- 全局死亡怪物列表
UGCGameData.DeadMonsters = UGCGameData.DeadMonsters or {}

---格式化数字为带单位的字符串
---@param num number 要格式化的数字
---@return string 格式化后的字符串
function UGCGameData.FormatNumber(num)
    if not num or num == 0 then
        return "0"
    end
    
    -- 小于1万,直接显示
    if num < 10000 then
        return tostring(math.floor(num))
    end
    
    -- 1万到1亿之间,显示"万"
    if num < 100000000 then
        local wan = num / 10000
        -- 保留2位小数,去掉末尾的0
        local formatted = string.format("%.2f", wan)
        formatted = formatted:gsub("%.?0+$", "")
        return formatted .. "万"
    end
    
    -- 1亿以上,显示"亿"
    local yi = num / 100000000
    -- 保留2位小数,去掉末尾的0
    local formatted = string.format("%.2f", yi)
    formatted = formatted:gsub("%.?0+$", "")
    return formatted .. "亿"
end

-- 任务表格路径
UGCGameData.TaskTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/TASK.TASK')

-- 配方表路径
UGCGameData.RecipeTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/peifang.peifang')

-- 物品表路径
UGCGameData.ItemTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCObject.UGCObject')

-- 物品映射表路径
UGCGameData.ItemMappingTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCObjectMapping.UGCObjectMapping')

-- 副本模式表路径
UGCGameData.FubenTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/FuBenconfig.FuBenconfig')

-- 副本奖励表路径
UGCGameData.FubenrewordTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Fubenreword.Fubenreword')

---获取任务配置
---@param taskRowIndex number 任务行序
---@return table|nil 任务配置数据
function UGCGameData.GetTaskConfig(taskRowIndex)
    local config = UGCGameSystem.GetTableDataByRowName(UGCGameData.TaskTablePath, tostring(taskRowIndex))
    if config then
        --[[ugcprint(string.format("[UGCGameData] GetTaskConfig(%d) 成功", taskRowIndex))]]
    else
        --[[ugcprint(string.format("[UGCGameData] GetTaskConfig(%d) 失败 - 未找到配置，路径: %s", taskRowIndex, UGCGameData.TaskTablePath))]]
    end
    return config
end

---获取所有任务配置
---@return table|nil 所有任务配置数据
function UGCGameData.GetAllTaskConfig()
    return UGCGameSystem.GetTableData(UGCGameData.TaskTablePath)
end

---获取配方配置
---@param recipeID number 配方ID
---@return table|nil 配方配置数据
function UGCGameData.GetRecipeConfig(recipeID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.RecipeTablePath, tostring(recipeID))
end

---获取所有配方配置
---@return table|nil 所有配方配置数据
function UGCGameData.GetAllRecipeConfig()
    local allRecipes = UGCGameSystem.GetTableData(UGCGameData.RecipeTablePath)
    if allRecipes then
        --ugcprint("[UGCGameData] GetAllRecipeConfig 成功，配方数量: " .. tostring(#allRecipes))
    else
        --ugcprint("[UGCGameData] GetAllRecipeConfig 失败 - 路径: " .. tostring(UGCGameData.RecipeTablePath))
    end
    return allRecipes
end

---获取物品配置
---@param itemID number 物品ID
---@return table|nil 物品配置数据
function UGCGameData.GetItemConfig(itemID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.ItemTablePath, tostring(itemID))
end

---获取所有物品配置
---@return table|nil 所有物品配置数据
function UGCGameData.GetAllItemConfig()
    return UGCGameSystem.GetTableData(UGCGameData.ItemTablePath)
end

---获取物品映射配置（虚拟物品ID -> 经典物品ID）
---@param virtualItemID number 虚拟物品ID
---@return table|nil 映射配置数据
function UGCGameData.GetItemMapping(virtualItemID)
    --ugcprint("[UGCGameData.GetItemMapping] 查询映射，虚拟ID: " .. tostring(virtualItemID))
    --ugcprint("[UGCGameData.GetItemMapping] 映射表路径: " .. tostring(UGCGameData.ItemMappingTablePath))
    local result = UGCGameSystem.GetTableDataByRowName(UGCGameData.ItemMappingTablePath, tostring(virtualItemID))
    if result then
        --ugcprint("[UGCGameData.GetItemMapping] 找到映射数据")
    else
        --ugcprint("[UGCGameData.GetItemMapping] 未找到映射数据")
    end
    return result
end

---获取所有物品映射配置
---@return table|nil 所有映射配置数据
function UGCGameData.GetAllItemMapping()
    return UGCGameSystem.GetTableData(UGCGameData.ItemMappingTablePath)
end

---获取副本模式配置
---@param modeID number 副本模式ID
---@return table|nil 副本模式配置数据
function UGCGameData.GetFubenConfig(modeID)
    ugcprint("[UGCGameData] GetFubenConfig 被调用, modeID=" .. tostring(modeID))
    ugcprint("[UGCGameData] FubenTablePath=" .. tostring(UGCGameData.FubenTablePath))
    
    -- 遍历所有配置,找到ModeID匹配的行
    local allConfigs = UGCGameSystem.GetTableData(UGCGameData.FubenTablePath)
    ugcprint("[UGCGameData] allConfigs=" .. tostring(allConfigs))
    
    if allConfigs then
        ugcprint("[UGCGameData] allConfigs类型: " .. type(allConfigs))
        local count = 0
        for rowName, config in pairs(allConfigs) do
            count = count + 1
            ugcprint("[UGCGameData] 行" .. count .. ": rowName=" .. tostring(rowName) .. ", ModeID=" .. tostring(config.ModeID))
            if config.ModeID == modeID then
                ugcprint("[UGCGameData] 找到匹配的配置!")
                return config
            end
        end
        ugcprint("[UGCGameData] 遍历了 " .. count .. " 行,未找到ModeID=" .. tostring(modeID))
    else
        ugcprint("[UGCGameData] allConfigs为nil,无法读取数据表")
    end
    return nil
end

---获取所有副本模式配置
---@return table|nil 所有副本模式配置数据
function UGCGameData.GetAllFubenConfig()
    return UGCGameSystem.GetTableData(UGCGameData.FubenTablePath)
end

---获取副本奖励配置
---@param configID number 奖励配置ID
---@return table|nil 副本奖励配置数据
function UGCGameData.GetFubenrewordByID(configID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameData.FubenrewordTablePath, tostring(configID))
end

---获取所有副本奖励配置
---@return table|nil 所有副本奖励配置数据
function UGCGameData.GetAllFubenreword()
    return UGCGameSystem.GetTableData(UGCGameData.FubenrewordTablePath)
end

---获取副本模式的关卡流管理器配置
---@param modeID number 副本模式ID
---@return string|nil 关卡流管理器路径
function UGCGameData.GetGameModeActorMgrConfig(modeID)
    local config = UGCGameData.GetFubenConfig(modeID)
    if config then
        return config.GameModeActorMgr or config.ActorMgrPath or config.MgrPath
    end
    return nil
end

function UGCGameData.GetLevelConfig(Lv)
    -- 配置表命名规则: "1" + 等级数字(至少3位)
    -- 1-999级: 1001-1999 (使用 %03d)
    -- 1000级以上: 11000, 11001, ... (直接拼接)
    local rowName
    if Lv < 1000 then
        -- 1-999级使用3位格式
        rowName = string.format("1%03d", Lv)
    else
        -- 1000级以上直接拼接
        rowName = "1" .. tostring(Lv)
    end
    
    local config = UGCGameSystem.GetTableDataByRowName(UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Level.Level'), rowName)
    
    -- 如果没有找到配置,使用默认值或基于等级计算
    if not config then
        --ugcprint("[UGCGameData] 警告：等级 " .. Lv .. " (rowName: " .. rowName .. ") 没有配置数据，使用默认计算值")
        
        -- 创建默认配置,属性随等级增长
        -- 基础公式: 每级增加固定值
        local baseExpPerLevel = 10000  -- 每级所需基础经验
        local expGrowth = 100          -- 每级经验增长
        
        config = {
            Exp = baseExpPerLevel + (Lv - 1) * expGrowth,  -- 升级所需经验
            AddHP = 21000 + (Lv - 1) * 500,                -- 每级增加生命值
            AddHIT = 2300 + (Lv - 1) * 50,                 -- 每级增加攻击力
            AddMG = 6900 + (Lv - 1) * 150,                 -- 每级增加魔法值
        }
        
        --ugcprint("[UGCGameData] 等级 " .. Lv .. " 使用默认配置: Exp=" .. config.Exp .. ", HP=" .. config.AddHP .. ", Attack=" .. config.AddHIT .. ", Magic=" .. config.AddMG)
    end
    
    return config
end

function UGCGameData.GetMonsterConfig(MonsterID)
    return UGCGameSystem.GetTableDataByRowName(UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/Monster.Monster'),tostring(MonsterID))
end

function UGCGameData.GetUI(PlayerController, UIName)
    --ugcprint("[UGCGameData.GetUI] 请求创建UI: " .. tostring(UIName))
    
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
        --ugcprint("[UGCGameData.GetUI] 开始加载 MMainUI 类")
        local MMainUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/MMainUI.MMainUI_C'))
        if not MMainUIClass then
            --ugcprint("[UGCGameData.GetUI] 错误：无法加载 MMainUI 类")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MMainUI 类加载成功，创建实例")
        local MMainUI = UserWidget.NewWidgetObjectBP(PlayerController, MMainUIClass)
        if not MMainUI then
            --ugcprint("[UGCGameData.GetUI] 错误：无法创建 MMainUI 实例")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MMainUI 实例创建成功")
        return MMainUI

    elseif UIName == "MainWidget" then
        --ugcprint("[UGCGameData.GetUI] 开始加载 MainWidget 类")
        local MainWidgetClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/MainWidget.MainWidget_C'))
        if not MainWidgetClass then
            --ugcprint("[UGCGameData.GetUI] 错误：无法加载 MainWidget 类")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MainWidget 类加载成功，创建实例")
        local MainWidget = UserWidget.NewWidgetObjectBP(PlayerController, MainWidgetClass)
        if not MainWidget then
            --ugcprint("[UGCGameData.GetUI] 错误：无法创建 MainWidget 实例")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] MainWidget 实例创建成功")
        return MainWidget

    elseif UIName == "taskbuttun" then
        local TaskButtonClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/taskbuttun.taskbuttun_C'))
        if not TaskButtonClass then
            --ugcprint("[UGCGameData.GetUI] 错误：无法加载 taskbuttun 类")
            return nil
        end
        local TaskButton = UserWidget.NewWidgetObjectBP(PlayerController, TaskButtonClass)
        return TaskButton
    
    elseif UIName == "TASK" then
        local TaskUIClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/TASK.TASK_C'))
        if not TaskUIClass then
            --ugcprint("[UGCGameData.GetUI] 错误：无法加载 TASK 类")
            return nil
        end
        local TaskUI = UserWidget.NewWidgetObjectBP(PlayerController, TaskUIClass)
        return TaskUI
    
    elseif UIName == "ConfirmPurchase" then
        --ugcprint("[UGCGameData.GetUI] 开始加载 ConfirmPurchase_UIBP 类")
        local ConfirmPurchaseClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/ConfirmPurchase_UIBP.ConfirmPurchase_UIBP_C'))
        if not ConfirmPurchaseClass then
            --ugcprint("[UGCGameData.GetUI] 错误：无法加载 ConfirmPurchase_UIBP 类")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] ConfirmPurchase_UIBP 类加载成功，创建实例")
        local ConfirmPurchase = UserWidget.NewWidgetObjectBP(PlayerController, ConfirmPurchaseClass)
        if not ConfirmPurchase then
            --ugcprint("[UGCGameData.GetUI] 错误：无法创建 ConfirmPurchase_UIBP 实例")
            return nil
        end
        --ugcprint("[UGCGameData.GetUI] ConfirmPurchase_UIBP 实例创建成功")
        return ConfirmPurchase

    elseif UIName == "WB_Team" then
        local TeamClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Team.WB_Team_C'))
        if not TeamClass then
            --ugcprint("[UGCGameData.GetUI] 错误：无法加载 WB_Team 类")
            return nil
        end
        local Team = UserWidget.NewWidgetObjectBP(PlayerController, TeamClass)
        return Team
    end
    
    --ugcprint("[UGCGameData.GetUI] 警告：未知的UI名称: " .. tostring(UIName))
    return nil
end

return UGCGameData