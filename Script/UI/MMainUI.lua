---@class MMainUI_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field active ctive_C
---@field activebuttun ctivebuttun_C
---@field addexp ddexp_C
---@field chuansong chuansong_C
---@field chuansong_2 chuansong_2_C
---@field chuansongbuttun chuansongbuttun_C
---@field chuansongbuttun_2 chuansongbuttun_2_C
---@field ConfirmPurchase_UIBP ConfirmPurchase_UIBP_C
---@field FriendList FriendList_C
---@field help help_C
---@field huicheng huicheng_C
---@field Inventorybuttun Inventorybuttun_C
---@field jiange jiange_C
---@field jiangebuttun jiangebuttun_C
---@field jiaocheng1 jiaocheng1_C
---@field jiaochengbuttun jiaochengbuttun_C
---@field Numchoose Numchoose_C
---@field Settlement Settlement_C
---@field Settlement_2 Settlement_2_C
---@field SettlementTip SettlementTip_C
---@field shenyin shenyin_C
---@field shenyingbuttun shenyingbuttun_C
---@field shouchongbuttun shouchongbuttun_C
---@field shoucong shoucong_C
---@field shouna shouna_C
---@field TalenTreeButtun TalenTreeButtun_C
---@field TalentTip TalentTip_C
---@field TalentTree TalentTree_C
---@field TASK TASK_C
---@field taskbuttun taskbuttun_C
---@field teambuttun teambuttun_C
---@field TestButton TestButton_C
---@field TextBlock_mobnum UTextBlock
---@field TextBlock_timeout UTextBlock
---@field tip tip_C
---@field touxiang touxiang_C
---@field touxiangdetail touxiangdetail_C
---@field tunshi tunshi_C
---@field tunshitip tunshitip_C
---@field UGC_RankingList_IngameBut_UIBP UGC_RankingList_IngameBut_UIBP_C
---@field WB_Inventory WB_Inventory_C
---@field WB_Team WB_Team_C
---@field WB_Teamiinvite WB_Teamiinvite_C
---@field WBP_OpenLotteryButton WBP_OpenLotteryButton_C
---@field WBP_RankingListBtn WBP_RankingListBtn_C
---@field wujingbuttun wujingbuttun_C
---@field wujingjiange wujingjiange_C
---@field xuemai xuemai_C
---@field xuzhang xuzhang_C
---@field zdshiqu zdshiqu_C
---@field zdtunshi zdtunshi_C
---@field zhuansheng zhuansheng_C
---@field zhuanshengbuttun zhuanshengbuttun_C
--Edit Below--
---@class MMainUI_C:UUserWidget
---
--- MMainUI 是游戏主界面中央控制器，负责所有 UI 面板的显示/隐藏、按钮状态管理、
--- Mode1002（战斗模式）的特殊处理、工具栏收放等功能。
--- 所有面板、按钮的初始化与显隐逻辑均集中于此。
---
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')
local UIPanelToggles = UGCGameSystem.UGCRequire('Script.Common.UIPanelToggles')
local CountdownTimer = UGCGameSystem.UGCRequire('Script.Common.CountdownTimer')
local UIFeatureToggle = UGCGameSystem.UGCRequire('Script.Common.UIFeatureToggle')

local MMainUI = { bInitDoOnce = false }

--- 初始化入口，UI 控件加载完成后由引擎自动调用。
--- 依次执行：UI 控件绑定初始化、按钮可见性设置、面板初始状态设置、收放按钮状态设置，
--- 并根据当前模式判断是否进入 Mode1002（战斗模式）。
function MMainUI:Construct()
    self:UIInit()
    self:InitButtonVisibility()
    self:InitPanelVisibility()
    self:InitShounaState()

    local currentModeID = UGCMultiMode.GetModeID()
    ugcprint("[MMainUI] Current mode ID: " .. tostring(currentModeID))
    if currentModeID and currentModeID == 1002 then
        self:InitMode1002()
    else
        -- 延迟 2 秒再次检测模式 ID，防止初始化时模式尚未切换完成
        UGCTimerUtility.CreateLuaTimer(2.0, function()
            local modeID = UGCMultiMode.GetModeID()
            ugcprint("[MMainUI] Delayed mode ID check: " .. tostring(modeID))
            if modeID and modeID == 1002 then
                self:InitMode1002()
            else
                self:HideFriendListPanel()
            end
        end, false, "MMainUI_CheckMode")
    end
end

--- 设置按钮的初始可见性。
--- 1. 将所有常用按钮设为可见（显示组）；
--- 2. 将测试按钮、排名前按钮等临时隐藏（隐藏组）。
function MMainUI:InitButtonVisibility()
    local visibleButtons = {
        self.chuansongbuttun, self.zhuanshengbuttun, self.touxiang,
        self.WBP_OpenLotteryButton, self.TalenTreeButtun, self.ShopV2_OpenShopButton_UIBP,
        self.TestButton, self.WBP_RankingListBtn, self.jiaocheng1,
        self.chuansongbuttun_2, self.shouchongbuttun, self.shoucong,
        self.shenyingbuttun, self.taskbuttun, self.Inventorybuttun,
        self.jiangebuttun, self.wujingbuttun, self.teambuttun,
        self.activebuttun,
    }
    for _, btn in ipairs(visibleButtons) do
        if btn then btn:SetVisibility(ESlateVisibility.Visible) end
    end

    local hiddenButtons = {
        self.TestButton, self.WBP_RankingListBtn, self.jiaocheng1,
        self.ShopV2_OpenShopButton_UIBP,
    }
    for _, btn in ipairs(hiddenButtons) do
        if btn then btn:SetVisibility(ESlateVisibility.Collapsed) end
    end
end

--- 设置各面板的初始可见状态（默认为隐藏）。
--- 隐藏：天赋树、背包详情、背包、升级、邮件、经验条、结算、背包、吞噬、队伍等所有功能面板。
--- 并在末尾隐藏好友列表面板。
function MMainUI:InitPanelVisibility()
    if self.chuansong then self.chuansong:HideAllButtons() end
    if self.chuansong_2 then self.chuansong_2:HideAllButtons() end
    if self.zhuansheng then self.zhuansheng:HideAllControls() end

    local hiddenPanels = {
        self.TalentTree, self.TalentTip, self.touxiangdetail,
        self.shenyin, self.jiange, self.wujingjiange,
        self.jdutiao, self.ta_settlement, self.WB_Inventory,
        self.Settlement, self.Settlement_2, self.SettlementTip,
        self.tunshi, self.tunshitip, self.WB_Team, self.WB_Teamiinvite,
        self.active, self.tip, self.TextBlock_timeout, self.TextBlock_mobnum,
        self.Numchoose, self.ConfirmPurchase_UIBP,
    }
    for _, panel in ipairs(hiddenPanels) do
        if panel then panel:SetVisibility(ESlateVisibility.Collapsed) end
    end

    self:HideFriendListPanel()
end

--- 初始化收放工具栏（Shouna）的状态。
--- 工具栏默认展开：显示展开图标 Image_0，隐藏收起图标 Image_1。
--- 同时重置隐藏标记 isShounaButtnsHidden 为 false。
function MMainUI:InitShounaState()
    self.isShounaButtnsHidden = false
    if self.shouna then
        if self.shouna.Image_0 then self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible) end
        if self.shouna.Image_1 then self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed) end
    end
end

--- Mode1002（战斗模式）初始化入口。
--- 1. 隐藏所有传送类按钮（防止玩家在战斗中传送）；
--- 2. 应用 Mode1002 专属按钮白名单/黑名单；
--- 3. 延迟多次强制刷新按钮状态（防止初始化顺序问题导致按钮残留）；
--- 4. 启动倒计时（限时战斗）；
--- 5. 动态创建好友列表 UI（击杀排行榜）；
--- 6. 显示击杀计数器文本（0/10 初始值）；
--- 7. 弹出 10 秒提示说明战斗目标。
function MMainUI:InitMode1002()
    self:HideTeleportButtons()
    self:ApplyMode1002MainButtons()
    self:ScheduleMode1002ButtonEnforce()
    CountdownTimer.StartCountdown(self, 100)
    self:CreateFriendListUI(true)
    if self.TextBlock_mobnum then
        self.TextBlock_mobnum:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.TextBlock_mobnum:SetText("0/10")
    end
    CountdownTimer.ShowTipDuration(self, "在限定时间内击败40只狼怪，并保护防御塔存活", 10)
end

--- UI 控件的蓝图绑定与事件注册。
--- 使用 bInitDoOnce 确保只执行一次，防止重复绑定事件。
--- 注册自动吞噬按钮和自动拾取按钮的点击回调。
function MMainUI:UIInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true

    if self.zdtunshi then
        if self.zdtunshi.OnClicked then
            self.zdtunshi.OnClicked:Add(self.OnAutoTunshiClicked, self)
        elseif self.zdtunshi.RefreshFromPlayerState then
            self.zdtunshi:RefreshFromPlayerState()
        end
    end

    if self.zdshiqu then
        if self.zdshiqu.OnClicked then
            self.zdshiqu.OnClicked:Add(self.OnAutoPickupClicked, self)
        elseif self.zdshiqu.RefreshFromPlayerState then
            self.zdshiqu:RefreshFromPlayerState()
        end
    end
end

--- 读取功能开关状态（代理到 UIFeatureToggle）。
--- stateField: 功能标识字符串（如 "AutoTunshi", "AutoPickup" 等）。
--- 返回值: 布尔值，表示该功能当前是否启用。
function MMainUI:GetFeatureToggleState(stateField)
    return UIFeatureToggle.GetFeatureToggleState(self, stateField)
end

--- 设置功能开关状态（代理到 UIFeatureToggle）。
--- stateField: 功能标识；gameDataField: 存档字段名；enabled: 是否启用。
function MMainUI:SetFeatureToggleState(stateField, gameDataField, enabled)
    UIFeatureToggle.SetFeatureToggleState(self, stateField, gameDataField, enabled)
end

--- 检查指定功能是否已解锁（代理到 UIFeatureToggle）。
--- itemID: 功能对应的道具或商品 ID。
--- 返回值: 布尔值，已解锁返回 true。
function MMainUI:IsFeatureUnlocked(itemID)
    return UIFeatureToggle.IsFeatureUnlocked(self, itemID)
end

--- 跳转到指定功能的购买页面（代理到 UIFeatureToggle）。
--- productID: 商品 ID，用于打开内购面板。
function MMainUI:JumpToFeaturePurchase(productID)
    UIFeatureToggle.JumpToFeaturePurchase(self, productID)
end

--- 自动吞噬按钮点击处理（代理到 UIFeatureToggle）。
--- 处理功能解锁检查和吞噬逻辑。
function MMainUI:OnAutoTunshiClicked()
    UIFeatureToggle.OnAutoTunshiClicked(self)
end

--- 自动拾取按钮点击处理（代理到 UIFeatureToggle）。
--- 处理功能解锁检查和拾取逻辑。
function MMainUI:OnAutoPickupClicked()
    UIFeatureToggle.OnAutoPickupClicked(self)
end

--- 切换天赋树面板的显示/隐藏状态。
--- 如果当前为隐藏则刷新 UI 并显示，否则隐藏。
--- 显示时会激活面板层级（ApplyWidgetLayer(true)），关闭时反之。
function MMainUI:ToggleTalentTree()
    if not self.TalentTree then return end

    if self.TalentTree:GetVisibility() == ESlateVisibility.Collapsed then
        self.TalentTree:RefreshUI()
        self.TalentTree:SetVisibility(ESlateVisibility.Visible)
        UIPanelToggles.ApplyWidgetLayer(true)
    else
        self.TalentTree:SetVisibility(ESlateVisibility.Collapsed)
        UIPanelToggles.ApplyWidgetLayer(false)
    end
end

--- 显示天赋提示面板。
--- level: 当前天赋等级，用于显示对应天赋信息。
--- @param level number 天赋等级
function MMainUI:ShowTalentTip(level)
    if not self.TalentTip then return end
    self.TalentTip:SetTalentInfo(level)
    self.TalentTip:SetVisibility(ESlateVisibility.Visible)
end

--- 显示头像详情面板。
--- 优先调用面板的 Show() 方法（若存在），否则直接设置可见性。
function MMainUI:ShowTouxiangDetail()
    if not self.touxiangdetail then return end
    if self.touxiangdetail.Show then
        self.touxiangdetail:Show()
    else
        self.touxiangdetail:SetVisibility(ESlateVisibility.Visible)
    end
end

--- 显示首充面板。
function MMainUI:ShowShouchong()
    if not self.shouchong then return end
    self.shouchong:SetVisibility(ESlateVisibility.Visible)
end

--- 隐藏首充面板。
function MMainUI:HideShouchong()
    if not self.shouchong then return end
    self.shouchong:SetVisibility(ESlateVisibility.Collapsed)
end

--- 显示吞噬面板。
function MMainUI:ShowTunshi()
    if not self.tunshi then return end
    self.tunshi:SetVisibility(ESlateVisibility.Visible)
end

--- 尝试执行自动吞噬消耗。
--- 内置 0.3 秒冷却（bAutoTunshiConsumeCD）防止重复触发。
--- 调用 Server_DestroyNearbyCorpses RPC 通知服务器销毁附近尸体，
--- 完成后自动隐藏吞噬面板并重置冷却。
function MMainUI:TryAutoTunshiConsume()
    if self.bAutoTunshiConsumeCD then return end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then return end

    self.bAutoTunshiConsumeCD = true
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_DestroyNearbyCorpses")

    if self.tunshi then
        self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 0.3 秒后解除冷却，允许下次触发
    UGCTimerUtility.CreateLuaTimer(0.3, function()
        self.bAutoTunshiConsumeCD = false
    end, false, "MMainUI_AutoTunshiCD_" .. tostring(self))
end

--- 隐藏吞噬面板。
function MMainUI:HideTunshi()
    if not self.tunshi then return end
    self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
end

--- 显示购买确认面板。
--- purchaseInfo: 包含商品信息的结构体，传递给确认面板显示详情。
--- @param purchaseInfo table 商品信息
function MMainUI:ShowConfirmPurchase(purchaseInfo)
    if not self.ConfirmPurchase_UIBP then return end
    if self.ConfirmPurchase_UIBP.SetPurchaseInfo then
        self.ConfirmPurchase_UIBP:SetPurchaseInfo(purchaseInfo)
    end
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Visible)
end

--- 隐藏购买确认面板。
function MMainUI:HideConfirmPurchase()
    if not self.ConfirmPurchase_UIBP then return end
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Collapsed)
end

--- 切换神印面板的显示/隐藏状态。
--- 如果当前为隐藏或不可见则调用 Show() 显示，否则调用 OnCancelClicked() 关闭。
function MMainUI:ToggleShenyin()
    if not self.shenyin then return end
    if self.shenyin:GetVisibility() == ESlateVisibility.Collapsed or self.shenyin:GetVisibility() == ESlateVisibility.Hidden then
        self.shenyin:Show()
    else
        self.shenyin:OnCancelClicked()
    end
end

--- 显示神印面板。
function MMainUI:ShowShenyin()
    if not self.shenyin then return end
    self.shenyin:Show()
end

--- 隐藏神印面板（调用面板自身的关闭逻辑）。
function MMainUI:HideShenyin()
    if not self.shenyin then return end
    self.shenyin:OnCancelClicked()
end

--- 切换间隔面板的显示/隐藏状态。
--- 逻辑同 ToggleShenyin：隐藏时显示，显示时调用 OnCancelClicked 关闭。
function MMainUI:ToggleJiange()
    if not self.jiange then return end
    if self.jiange:GetVisibility() == ESlateVisibility.Collapsed or self.jiange:GetVisibility() == ESlateVisibility.Hidden then
        self.jiange:Show()
    else
        self.jiange:OnCancelClicked()
    end
end

--- 切换无间隔面板的显示/隐藏状态。
--- 逻辑同 ToggleShenyin 和 ToggleJiange。
function MMainUI:ToggleWujingjiange()
    if not self.wujingjiange then return end
    if self.wujingjiange:GetVisibility() == ESlateVisibility.Collapsed or self.wujingjiange:GetVisibility() == ESlateVisibility.Hidden then
        self.wujingjiange:Show()
    else
        self.wujingjiange:OnCancelClicked()
    end
end

--- 切换背包面板的显示/隐藏状态。
--- 显示时激活面板层级，隐藏时取消激活。
function MMainUI:ToggleInventory()
    if not self.WB_Inventory then return end

    if self.WB_Inventory:GetVisibility() == ESlateVisibility.Collapsed then
        self.WB_Inventory:SetVisibility(ESlateVisibility.Visible)
        UIPanelToggles.ApplyWidgetLayer(true)
    else
        self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
        UIPanelToggles.ApplyWidgetLayer(false)
    end
end

--- 显示背包面板。
function MMainUI:ShowInventory()
    if not self.WB_Inventory then return end
    self.WB_Inventory:SetVisibility(ESlateVisibility.Visible)
end

--- 隐藏背包面板。
function MMainUI:HideInventory()
    if not self.WB_Inventory then return end
    self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
end

--- 切换工具栏收放状态（显示/隐藏两组功能按钮）。
--- 如果当前处于 Mode1002 模式则不执行收放，直接应用 Mode1002 按钮规则。
--- 展开状态：显示 Image_0 收起图标，隐藏 Image_1 显示展开图标，显示所有功能按钮；
--- 收起状态：隐藏 Image_0，显示 Image_1，隐藏除神印、境界按钮外的所有功能按钮。
--- 传送按钮在隐藏状态下仍受 TeleportButtonsHidden 标记影响（如已被 HideTeleportButtons 隐藏则跳过）。
function MMainUI:ToggleShounaButtons()
    if self:IsMode1002() then
        self.isShounaButtnsHidden = false
        self:ApplyMode1002MainButtons()
        return
    end

    if not self.shouna then return end

    if self.isShounaButtnsHidden then
        -- 展开工具栏
        if self.shouna.Image_0 then self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible) end
        if self.shouna.Image_1 then self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed) end

        local showButtons = {
            self.chuansongbuttun, self.chuansongbuttun_2, self.Inventorybuttun,
            self.shenyingbuttun, self.jiangebuttun, self.shouchongbuttun,
            self.shoucong, self.TalenTreeButtun, self.taskbuttun,
            self.WBP_OpenLotteryButton, self.zhuanshengbuttun,
            self.UGC_RankingList_IngameBut_UIBP, self.teambuttun, self.activebuttun,
        }
        for _, btn in ipairs(showButtons) do
            if btn then
                if self.TeleportButtonsHidden and (btn == self.chuansongbuttun or btn == self.chuansongbuttun_2) then
                    -- 传送按钮已被单独隐藏，跳过
                else
                    btn:SetVisibility(ESlateVisibility.Visible)
                end
            end
        end
        self.isShounaButtnsHidden = false
    else
        -- 收起工具栏
        if self.shouna.Image_0 then self.shouna.Image_0:SetVisibility(ESlateVisibility.Collapsed) end
        if self.shouna.Image_1 then self.shouna.Image_1:SetVisibility(ESlateVisibility.Visible) end

        local hideButtons = {
            self.chuansongbuttun, self.chuansongbuttun_2, self.Inventorybuttun,
            self.shenyingbuttun, self.jiangebuttun, self.wujingbuttun,
            self.shouchongbuttun, self.shoucong, self.TalenTreeButtun, self.taskbuttun, self.zhuanshengbuttun,
            self.UGC_RankingList_IngameBut_UIBP, self.teambuttun, self.activebuttun,
        }
        for _, btn in ipairs(hideButtons) do
            if btn then btn:SetVisibility(ESlateVisibility.Collapsed) end
        end
        self.isShounaButtnsHidden = true
    end
end

--- 判断当前是否处于 Mode1002 战斗模式。
--- 返回: 布尔值。
function MMainUI:IsMode1002()
    local modeID = UGCMultiMode.GetModeID()
    return modeID and modeID == 1002
end

--- 隐藏好友列表面板（两种实现方式兼容）。
--- 优先操作 FriendList（预设控件），再处理动态创建的 FriendListUI（Mode1002 使用）。
--- 动态创建的 UI 需先 RemoveFromParent 移除出视图，再置空引用。
function MMainUI:HideFriendListPanel()
    if self.FriendList then
        self.FriendList:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.FriendListUI then
        if UGCObjectUtility.IsObjectValid(self.FriendListUI) then
            self.FriendListUI:SetVisibility(ESlateVisibility.Collapsed)
            self.FriendListUI:RemoveFromParent()
        end
        self.FriendListUI = nil
    end
end

--- 延迟多次强制刷新 Mode1002 按钮状态。
--- 由于 UI 初始化顺序不确定，通过 {0.2s, 0.8s, 2.0s} 三个时间点重复调用
--- ApplyMode1002MainButtons，确保按钮最终状态正确。
function MMainUI:ScheduleMode1002ButtonEnforce()
    local delays = {0.2, 0.8, 2.0}
    for index, delay in ipairs(delays) do
        UGCTimerUtility.CreateLuaTimer(delay, function()
            if self and self:IsMode1002() then
                self:ApplyMode1002MainButtons()
            end
        end, false, "MMainUI_Mode1002Enforce_" .. tostring(index))
    end
end

--- Mode1002 按钮白名单/黑名单控制。
--- 隐藏组（黑名单）：收放工具栏、头像、传送、传送2、背包、无精按钮、首充、首充2、
---   天赋树、任务、抽奖、转生、排行榜、队伍、活动按钮、商城、自动拾取、自动吞噬等。
--- 保留组（白名单）：血脉、神印、境界按钮始终显示。
--- 同时关闭排行榜组件、隐藏神印/境界/无境界面板。
function MMainUI:ApplyMode1002MainButtons()
    local hideWidgets = {
        self.shouna, self.touxiang, self.chuansongbuttun, self.chuansongbuttun_2,
        self.Inventorybuttun, self.wujingbuttun, self.shouchongbuttun, self.shoucong,
        self.TalenTreeButtun, self.taskbuttun, self.WBP_OpenLotteryButton,
        self.zhuanshengbuttun, self.UGC_RankingList_IngameBut_UIBP, self.teambuttun,
        self.activebuttun, self.ShopV2_OpenShopButton_UIBP, self.huicheng,
        self.addexp, self.zdshiqu, self.zdtunshi,
    }
    for _, widget in ipairs(hideWidgets) do
        if widget then widget:SetVisibility(ESlateVisibility.Collapsed) end
    end

    local keepWidgets = {self.xuemai, self.shenyingbuttun, self.jiangebuttun}
    for _, widget in ipairs(keepWidgets) do
        if widget then widget:SetVisibility(ESlateVisibility.Visible) end
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if playerController and playerController.RankingListComponent then
        if playerController.RankingListComponent.CloseRankList then
            playerController.RankingListComponent:CloseRankList()
        elseif playerController.RankingListComponent.RankingListBtn then
            playerController.RankingListComponent.RankingListBtn:SetVisibility(ESlateVisibility.Collapsed)
        end
    end

    if self.shenyin then self.shenyin:SetVisibility(ESlateVisibility.Collapsed) end
    if self.jiange then self.jiange:SetVisibility(ESlateVisibility.Collapsed) end
    if self.wujingjiange then self.wujingjiange:SetVisibility(ESlateVisibility.Collapsed) end
end

--- 显示结算面板（第一套结算界面）。
function MMainUI:ShowSettlement()
    if self.Settlement then self.Settlement:SetVisibility(ESlateVisibility.Visible) end
end

--- 隐藏结算面板（第一套结算界面）。
function MMainUI:HideSettlement()
    if self.Settlement then self.Settlement:SetVisibility(ESlateVisibility.Collapsed) end
end

--- 显示结算面板（第二套结算界面）。
function MMainUI:ShowSettlement_2()
    if self.Settlement_2 then self.Settlement_2:SetVisibility(ESlateVisibility.Visible) end
end

--- 隐藏结算面板（第二套结算界面）。
function MMainUI:HideSettlement_2()
    if self.Settlement_2 then self.Settlement_2:SetVisibility(ESlateVisibility.Collapsed) end
end

--- 显示结算提示面板（结算顶部提示横幅）。
function MMainUI:ShowSettlementTip()
    if self.SettlementTip then self.SettlementTip:SetVisibility(ESlateVisibility.Visible) end
end

--- 隐藏结算提示面板。
function MMainUI:HideSettlementTip()
    if self.SettlementTip then self.SettlementTip:SetVisibility(ESlateVisibility.Collapsed) end
end

--- 切换队伍面板的显示/隐藏状态。
--- 优先调用面板的 Show()/Hide() 方法（若存在），否则直接设置可见性。
--- 如果面板有 CreatePlayerSlots 方法则在显示时调用以初始化玩家槽位。
function MMainUI:ToggleTeam()
    if not self.WB_Team then return end

    if self.WB_Team:GetVisibility() == ESlateVisibility.Collapsed then
        if self.WB_Team.Show then
            self.WB_Team:Show()
        else
            self.WB_Team:SetVisibility(ESlateVisibility.Visible)
            if self.WB_Team.CreatePlayerSlots then
                self.WB_Team:CreatePlayerSlots()
            end
        end
    else
        if self.WB_Team.Hide then
            self.WB_Team:Hide()
        else
            self.WB_Team:SetVisibility(ESlateVisibility.Collapsed)
        end
    end
end

--- 隐藏传送类按钮（Mode1002 或比赛模式使用）。
--- 隐藏：无尽按钮、传送按钮、传送按钮2、回收按钮。
--- 同时设置 TeleportButtonsHidden 标记为 true，打印日志。
--- @see ShowTeleportButtons
function MMainUI:HideTeleportButtons()
    local buttons = {self.wujingbuttun, self.chuansongbuttun, self.chuansongbuttun_2, self.huicheng}
    for _, btn in ipairs(buttons) do
        if btn then btn:SetVisibility(ESlateVisibility.Collapsed) end
    end
    self.TeleportButtonsHidden = true
    ugcprint("[MMainUI] Match mode: teleport buttons are hidden")
end

--- 显示传送类按钮（比赛模式结束后恢复）。
--- 将所有传送按钮重新设为可见，重置 TeleportButtonsHidden 标记为 false。
--- @see HideTeleportButtons
function MMainUI:ShowTeleportButtons()
    local buttons = {self.wujingbuttun, self.chuansongbuttun, self.chuansongbuttun_2, self.huicheng}
    for _, btn in ipairs(buttons) do
        if btn then btn:SetVisibility(ESlateVisibility.Visible) end
    end
    self.TeleportButtonsHidden = false
    ugcprint("[MMainUI] Teleport buttons are visible again")
end

--- 启动倒计时（代理到 CountdownTimer）。
--- totalSeconds: 倒计时总时长（秒）。
function MMainUI:StartCountdown(totalSeconds)
    CountdownTimer.StartCountdown(self, totalSeconds)
end

--- 更新倒计时文本（代理到 CountdownTimer）。
--- 通常由计时器 Tick 驱动，刷新 TextBlock_timeout 显示。
function MMainUI:UpdateCountdownText()
    CountdownTimer.UpdateCountdownText(self)
end

--- 停止倒计时（代理到 CountdownTimer）。
--- 清除计时器，取消倒计时显示。
function MMainUI:StopCountdown()
    CountdownTimer.StopCountdown(self)
end

--- 倒计时结束，通知退出（代理到 CountdownTimer）。
--- reason: 退出原因描述字符串。
--- @param reason string 退出原因
function MMainUI:RequestCountdownTimeoutExit(reason)
    CountdownTimer.RequestCountdownTimeoutExit(self, reason)
end

--- 显示提示文本（代理到 CountdownTimer）。
--- text: 提示内容，短暂显示后自动消失。
--- @param text string 提示文本
function MMainUI:ShowTip(text)
    CountdownTimer.ShowTip(self, text)
end

--- 显示带持续时间的提示文本（代理到 CountdownTimer）。
--- text: 提示内容；duration: 显示持续时间（秒）。
--- @param text string 提示文本
--- @param duration number 持续秒数
function MMainUI:ShowTipDuration(text, duration)
    CountdownTimer.ShowTipDuration(self, text, duration)
end

--- 动态创建好友列表 UI（Mode1002 击杀排行榜）。
--- forceCreate 为 true 时强制创建；否则仅在 Mode1002 模式下创建。
--- 优先使用预设 FriendList 控件，若不存在则通过 Asset 路径动态加载 FriendList_C 蓝图类，
--- 在本地玩家视口上创建实例（层级 1050）并保存到 self.FriendListUI。
--- 用于显示击杀排名，支持 SyncPlayerKillCount 同步击杀数据。
--- @param forceCreate boolean 是否强制创建（true=无论是否 Mode1002 都创建）
function MMainUI:CreateFriendListUI(forceCreate)
    if not forceCreate and not self:IsMode1002() then
        self:HideFriendListPanel()
        return
    end

    if self.FriendList then
        self.FriendList:SetVisibility(ESlateVisibility.Visible)
    end

    if self.FriendListUI then
        if UGCObjectUtility.IsObjectValid(self.FriendListUI) then
            self.FriendListUI:SetVisibility(ESlateVisibility.Visible)
            if self.FriendList then
                self.FriendList:SetVisibility(ESlateVisibility.Collapsed)
            end
            return
        end
        self.FriendListUI = nil
    end

    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end
    local friendListPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/FriendList.FriendList_C')
    if not friendListPath or friendListPath == "" then
        ugcprint("[MMainUI] Error: FriendList class path is empty")
        return
    end
    local FriendListClass = UGCObjectUtility.LoadClass(friendListPath)
    if not FriendListClass then
        ugcprint("[MMainUI] Error: failed to load the FriendList class")
        return
    end
    local friendListUI = UserWidget.NewWidgetObjectBP(PC, FriendListClass)
    if not friendListUI then
        ugcprint("[MMainUI] Error: failed to create the FriendList instance")
        return
    end
    friendListUI:AddToViewport(1050)
    friendListUI:SetVisibility(ESlateVisibility.Visible)
    self.FriendListUI = friendListUI
    if self.FriendList then
        self.FriendList:SetVisibility(ESlateVisibility.Collapsed)
    end
    ugcprint("[MMainUI] FriendList team panel created")
end

--- 更新击杀计数显示。
--- currentKills: 当前击杀数；requiredKills: 目标击杀数。
--- 格式化为 "当前/目标" 文本（如 "12/40"）显示在 TextBlock_mobnum 上。
--- @param currentKills number 当前击杀数
--- @param requiredKills number 目标击杀数
function MMainUI:UpdateMobKillCount(currentKills, requiredKills)
    if not self.TextBlock_mobnum then return end
    self.TextBlock_mobnum:SetText(tostring(currentKills) .. "/" .. tostring(requiredKills))
    ugcprint("[MMainUI] Kill count updated: " .. tostring(currentKills) .. "/" .. tostring(requiredKills))
end

--- 同步玩家击杀数据到好友列表 UI。
--- playerKey: 玩家唯一标识；killCount: 击杀数。
--- 优先同步到动态创建的 FriendListUI，若无效则回退到预设 FriendList 控件。
--- @param playerKey string 玩家标识
--- @param killCount number 击杀数
function MMainUI:SyncFriendListPlayerKillCount(playerKey, killCount)
    if self.FriendListUI and UGCObjectUtility.IsObjectValid(self.FriendListUI) and self.FriendListUI.SyncPlayerKillCount then
        self.FriendListUI:SyncPlayerKillCount(playerKey, killCount)
        return
    end
    if self.FriendList and UGCObjectUtility.IsObjectValid(self.FriendList) and self.FriendList.SyncPlayerKillCount then
        self.FriendList:SyncPlayerKillCount(playerKey, killCount)
    end
end

return MMainUI
