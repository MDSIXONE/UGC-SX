---@class MMainUI_C:UUserWidget
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')
local UIPanelToggles = UGCGameSystem.UGCRequire('Script.Common.UIPanelToggles')
local CountdownTimer = UGCGameSystem.UGCRequire('Script.Common.CountdownTimer')
local UIFeatureToggle = UGCGameSystem.UGCRequire('Script.Common.UIFeatureToggle')

local MMainUI = { bInitDoOnce = false }

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

function MMainUI:InitShounaState()
    self.isShounaButtnsHidden = false
    if self.shouna then
        if self.shouna.Image_0 then self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible) end
        if self.shouna.Image_1 then self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed) end
    end
end

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

function MMainUI:GetFeatureToggleState(stateField)
    return UIFeatureToggle.GetFeatureToggleState(self, stateField)
end

function MMainUI:SetFeatureToggleState(stateField, gameDataField, enabled)
    UIFeatureToggle.SetFeatureToggleState(self, stateField, gameDataField, enabled)
end

function MMainUI:IsFeatureUnlocked(itemID)
    return UIFeatureToggle.IsFeatureUnlocked(self, itemID)
end

function MMainUI:JumpToFeaturePurchase(productID)
    UIFeatureToggle.JumpToFeaturePurchase(self, productID)
end

function MMainUI:OnAutoTunshiClicked()
    UIFeatureToggle.OnAutoTunshiClicked(self)
end

function MMainUI:OnAutoPickupClicked()
    UIFeatureToggle.OnAutoPickupClicked(self)
end

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

function MMainUI:ShowTalentTip(level)
    if not self.TalentTip then return end
    self.TalentTip:SetTalentInfo(level)
    self.TalentTip:SetVisibility(ESlateVisibility.Visible)
end

function MMainUI:ShowTouxiangDetail()
    if not self.touxiangdetail then return end
    if self.touxiangdetail.Show then
        self.touxiangdetail:Show()
    else
        self.touxiangdetail:SetVisibility(ESlateVisibility.Visible)
    end
end

function MMainUI:ShowShouchong()
    if not self.shouchong then return end
    self.shouchong:SetVisibility(ESlateVisibility.Visible)
end

function MMainUI:HideShouchong()
    if not self.shouchong then return end
    self.shouchong:SetVisibility(ESlateVisibility.Collapsed)
end

function MMainUI:ShowTunshi()
    if not self.tunshi then return end
    self.tunshi:SetVisibility(ESlateVisibility.Visible)
end

function MMainUI:TryAutoTunshiConsume()
    if self.bAutoTunshiConsumeCD then return end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then return end

    self.bAutoTunshiConsumeCD = true
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_DestroyNearbyCorpses")

    if self.tunshi then
        self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
    end

    UGCTimerUtility.CreateLuaTimer(0.3, function()
        self.bAutoTunshiConsumeCD = false
    end, false, "MMainUI_AutoTunshiCD_" .. tostring(self))
end

function MMainUI:HideTunshi()
    if not self.tunshi then return end
    self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
end

function MMainUI:ShowConfirmPurchase(purchaseInfo)
    if not self.ConfirmPurchase_UIBP then return end
    if self.ConfirmPurchase_UIBP.SetPurchaseInfo then
        self.ConfirmPurchase_UIBP:SetPurchaseInfo(purchaseInfo)
    end
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Visible)
end

function MMainUI:HideConfirmPurchase()
    if not self.ConfirmPurchase_UIBP then return end
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Collapsed)
end

function MMainUI:ToggleShenyin()
    if not self.shenyin then return end
    if self.shenyin:GetVisibility() == ESlateVisibility.Collapsed or self.shenyin:GetVisibility() == ESlateVisibility.Hidden then
        self.shenyin:Show()
    else
        self.shenyin:OnCancelClicked()
    end
end

function MMainUI:ShowShenyin()
    if not self.shenyin then return end
    self.shenyin:Show()
end

function MMainUI:HideShenyin()
    if not self.shenyin then return end
    self.shenyin:OnCancelClicked()
end

function MMainUI:ToggleJiange()
    if not self.jiange then return end
    if self.jiange:GetVisibility() == ESlateVisibility.Collapsed or self.jiange:GetVisibility() == ESlateVisibility.Hidden then
        self.jiange:Show()
    else
        self.jiange:OnCancelClicked()
    end
end

function MMainUI:ToggleWujingjiange()
    if not self.wujingjiange then return end
    if self.wujingjiange:GetVisibility() == ESlateVisibility.Collapsed or self.wujingjiange:GetVisibility() == ESlateVisibility.Hidden then
        self.wujingjiange:Show()
    else
        self.wujingjiange:OnCancelClicked()
    end
end

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

function MMainUI:ShowInventory()
    if not self.WB_Inventory then return end
    self.WB_Inventory:SetVisibility(ESlateVisibility.Visible)
end

function MMainUI:HideInventory()
    if not self.WB_Inventory then return end
    self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
end

function MMainUI:ToggleShounaButtons()
    if self:IsMode1002() then
        self.isShounaButtnsHidden = false
        self:ApplyMode1002MainButtons()
        return
    end

    if not self.shouna then return end

    if self.isShounaButtnsHidden then
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
                    -- skip
                else
                    btn:SetVisibility(ESlateVisibility.Visible)
                end
            end
        end
        self.isShounaButtnsHidden = false
    else
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

function MMainUI:IsMode1002()
    local modeID = UGCMultiMode.GetModeID()
    return modeID and modeID == 1002
end

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

function MMainUI:ShowSettlement()
    if self.Settlement then self.Settlement:SetVisibility(ESlateVisibility.Visible) end
end

function MMainUI:HideSettlement()
    if self.Settlement then self.Settlement:SetVisibility(ESlateVisibility.Collapsed) end
end

function MMainUI:ShowSettlement_2()
    if self.Settlement_2 then self.Settlement_2:SetVisibility(ESlateVisibility.Visible) end
end

function MMainUI:HideSettlement_2()
    if self.Settlement_2 then self.Settlement_2:SetVisibility(ESlateVisibility.Collapsed) end
end

function MMainUI:ShowSettlementTip()
    if self.SettlementTip then self.SettlementTip:SetVisibility(ESlateVisibility.Visible) end
end

function MMainUI:HideSettlementTip()
    if self.SettlementTip then self.SettlementTip:SetVisibility(ESlateVisibility.Collapsed) end
end

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

function MMainUI:HideTeleportButtons()
    local buttons = {self.wujingbuttun, self.chuansongbuttun, self.chuansongbuttun_2, self.huicheng}
    for _, btn in ipairs(buttons) do
        if btn then btn:SetVisibility(ESlateVisibility.Collapsed) end
    end
    self.TeleportButtonsHidden = true
    ugcprint("[MMainUI] Match mode: teleport buttons are hidden")
end

function MMainUI:ShowTeleportButtons()
    local buttons = {self.wujingbuttun, self.chuansongbuttun, self.chuansongbuttun_2, self.huicheng}
    for _, btn in ipairs(buttons) do
        if btn then btn:SetVisibility(ESlateVisibility.Visible) end
    end
    self.TeleportButtonsHidden = false
    ugcprint("[MMainUI] Teleport buttons are visible again")
end

function MMainUI:StartCountdown(totalSeconds)
    CountdownTimer.StartCountdown(self, totalSeconds)
end

function MMainUI:UpdateCountdownText()
    CountdownTimer.UpdateCountdownText(self)
end

function MMainUI:StopCountdown()
    CountdownTimer.StopCountdown(self)
end

function MMainUI:RequestCountdownTimeoutExit(reason)
    CountdownTimer.RequestCountdownTimeoutExit(self, reason)
end

function MMainUI:ShowTip(text)
    CountdownTimer.ShowTip(self, text)
end

function MMainUI:ShowTipDuration(text, duration)
    CountdownTimer.ShowTipDuration(self, text, duration)
end

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

function MMainUI:UpdateMobKillCount(currentKills, requiredKills)
    if not self.TextBlock_mobnum then return end
    self.TextBlock_mobnum:SetText(tostring(currentKills) .. "/" .. tostring(requiredKills))
    ugcprint("[MMainUI] Kill count updated: " .. tostring(currentKills) .. "/" .. tostring(requiredKills))
end

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
