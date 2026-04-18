---@class UIWidgetFactory
---Factory for creating UI widget instances.
--- UI Widget 实例工厂，通过 UIName 字符串动态创建 UI 组件

local UIWidgetFactory = {}

--- 根据 UIName 动态创建 UI Widget 实例
---@param PlayerController userdata 玩家控制器实例
---@param UIName string UI 名称标识
---@return userdata|nil 返回创建的 Widget 实例，若创建失败则返回 nil
function UIWidgetFactory.GetUI(PlayerController, UIName)
    -- 抽奖按钮：打开抽奖界面的按钮组件
    if UIName == "choujiang" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/Lottery/OfficialPackage/Asset/Lottery/Blueprint/WBP_OpenLotteryButton.WBP_OpenLotteryButton_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 头像：玩家头像显示组件
    elseif UIName == "touxiang" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/touxiang.touxiang_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 传送：传送功能按钮组件
    elseif UIName == "chuansong" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/chuansong.chuansong_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 转生：转生系统按钮组件
    elseif UIName == "zhuansheng" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/zhuansheng.zhuansheng_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 商店：打开商店界面的按钮组件
    elseif UIName == "shop" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/ShopV2/OfficialPackage/Asset/ShopV2/Blueprint/ShopV2_OpenShopButton_UIBP.ShopV2_OpenShopButton_UIBP_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 礼包：礼包购买按钮组件
    elseif UIName == "libao" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/GiftPack/OfficialPackage/Asset/GiftPack/Blueprint/WBP_GiftPackBtn.WBP_GiftPackBtn_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 主界面：游戏主界面 UI 面板
    elseif UIName == "MMainUI" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/MMainUI.MMainUI_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 剑阁 UI：剑阁副本界面组件
    elseif UIName == "JiangeUI" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/JiangeUI.JiangeUI_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 主 Widget：主界面核心 Widget 组件
    elseif UIName == "MainWidget" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/MainWidget.MainWidget_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 任务按钮：任务追踪按钮组件
    elseif UIName == "taskbuttun" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/taskbuttun.taskbuttun_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 确认购买：购买确认弹窗组件
    elseif UIName == "ConfirmPurchase" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/ConfirmPurchase_UIBP.ConfirmPurchase_UIBP_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    -- 队伍面板：组队功能面板组件
    elseif UIName == "WB_Team" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Team.WB_Team_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)
    end

    -- 未匹配的 UIName 返回 nil
    return nil
end

return UIWidgetFactory
