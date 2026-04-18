---@class UIWidgetFactory
---Factory for creating UI widget instances.

local UIWidgetFactory = {}

function UIWidgetFactory.GetUI(PlayerController, UIName)
    if UIName == "choujiang" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/Lottery/OfficialPackage/Asset/Lottery/Blueprint/WBP_OpenLotteryButton.WBP_OpenLotteryButton_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "touxiang" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/touxiang.touxiang_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "chuansong" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/chuansong.chuansong_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "zhuansheng" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/zhuansheng.zhuansheng_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "shop" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/ShopV2/OfficialPackage/Asset/ShopV2/Blueprint/ShopV2_OpenShopButton_UIBP.ShopV2_OpenShopButton_UIBP_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "libao" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('ExtendResource/GiftPack/OfficialPackage/Asset/GiftPack/Blueprint/WBP_GiftPackBtn.WBP_GiftPackBtn_C'))
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "MMainUI" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/MMainUI.MMainUI_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "JiangeUI" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/JiangeUI.JiangeUI_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "MainWidget" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/MainWidget.MainWidget_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "taskbuttun" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/taskbuttun.taskbuttun_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "ConfirmPurchase" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/ConfirmPurchase_UIBP.ConfirmPurchase_UIBP_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)

    elseif UIName == "WB_Team" then
        local class = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Team.WB_Team_C'))
        if not class then return nil end
        return UserWidget.NewWidgetObjectBP(PlayerController, class)
    end

    return nil
end

return UIWidgetFactory
