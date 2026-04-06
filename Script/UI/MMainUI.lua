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
---@field taskblank taskblank_C
---@field taskbuttun taskbuttun_C
---@field teambuttun teambuttun_C
---@field TestButton TestButton_C
---@field TextBlock_timeout UTextBlock
---@field TextBlock_mobnum UTextBlock
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
---@field zdshiqu zdshiqu_C
---@field zdtunshi zdtunshi_C
---@field zhuansheng zhuansheng_C
---@field zhuanshengbuttun zhuanshengbuttun_C
--Edit Below--
local MMainUI = { bInitDoOnce = false }
local AUTO_TUNSHI_UNLOCK_ITEM_ID = 9001
local AUTO_PICKUP_UNLOCK_ITEM_ID = 9002
local AUTO_TUNSHI_PRODUCT_ID = 9000112
local AUTO_PICKUP_PRODUCT_ID = 9000113

function MMainUI:Construct()
    --ugcprint("========== MMainUI:Construct start ==========")
    self:UIInit()
    
    -- Initialize the shouna fold-out feature
    self.isShounaButtnsHidden = false
    --ugcprint("[MMainUI] Initialized shouna state: isShounaButtnsHidden = false")
    
    -- Initialize the shouna image state: show Image_0 and hide Image_1
    if self.shouna then
        if self.shouna.Image_0 then
            self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shouna Image_0 initialized as visible")
        end
        if self.shouna.Image_1 then
            self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shouna Image_1 initialized as hidden")
        end
    end
    
    -- Show buttons and hide panels on startup
    if self.chuansongbuttun then
        self.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
    end
    
    if self.zhuanshengbuttun then
        self.zhuanshengbuttun:SetVisibility(ESlateVisibility.Visible)
    end
    
    if self.touxiang then
        self.touxiang:SetVisibility(ESlateVisibility.Visible)
    end

    if self.WBP_OpenLotteryButton then
        self.WBP_OpenLotteryButton:SetVisibility(ESlateVisibility.Visible)
    end
    
    if self.TalenTreeButtun then
        self.TalenTreeButtun:SetVisibility(ESlateVisibility.Visible)
    end
    
    if self.ShopV2_OpenShopButton_UIBP then
        self.ShopV2_OpenShopButton_UIBP:SetVisibility(ESlateVisibility.Visible)
    end

    if self.TestButton then
        self.TestButton:SetVisibility(ESlateVisibility.Collapsed)
    end

    if self.WBP_RankingListBtn then
        self.WBP_RankingListBtn:SetVisibility(ESlateVisibility.Collapsed)
    end

    if self.jiaocheng1 then
        self.jiaocheng1:SetVisibility(ESlateVisibility.Collapsed)
    end
    
    -- Hide teleport and rebirth panels on startup
    if self.chuansong then
        self.chuansong:HideAllButtons()
    end

    if self.chuansong_2 then
        self.chuansong_2:HideAllButtons()
    end

    if self.chuansongbuttun_2 then
        self.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
    end

    if self.zhuansheng then
        self.zhuansheng:HideAllControls()
    end
    
    -- Hide the talent tree and tip panel on startup
    if self.TalentTree then
        self.TalentTree:SetVisibility(ESlateVisibility.Collapsed)
    end
    
    if self.TalentTip then
        self.TalentTip:SetVisibility(ESlateVisibility.Collapsed)
    end
    
    -- Hide the detail panel on startup
    if self.touxiangdetail then
        self.touxiangdetail:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Show the first top-up button
    if self.shouchongbuttun then
        self.shouchongbuttun:SetVisibility(ESlateVisibility.Visible)
    end

    -- Show the first top-up panel (shoucong)
    if self.shoucong then
        self.shoucong:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] shoucong widget is visible")
    else
        --ugcprint("[MMainUI] Warning: shoucong widget does not exist!")
    end

    -- Hide the consume button on startup
    if self.tunshi then
        self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Hide the consume tip on startup
    if self.tunshitip then
        self.tunshitip:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Show the task button
    if self.taskbuttun then
        self.taskbuttun:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] taskbuttun widget exists and has been set visible")
    else
        --ugcprint("[MMainUI] Warning: taskbuttun widget does not exist!")
    end
    
    -- Hide the task panel on startup
    if self.TASK then
        self.TASK:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] TASK widget exists and has been set hidden")
    else
        --ugcprint("[MMainUI] Warning: TASK widget does not exist!")
    end

    -- Hide the purchase confirmation dialog on startup
    if self.ConfirmPurchase_UIBP then
        self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] ConfirmPurchase_UIBP widget has been hidden")
    else
        --ugcprint("[MMainUI] Warning: ConfirmPurchase_UIBP widget does not exist!")
    end

    -- Show the Shenyin button
    if self.shenyingbuttun then
        self.shenyingbuttun:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] shenyingbuttun button is visible")
    else
        --ugcprint("[MMainUI] Warning: shenyingbuttun widget does not exist!")
    end

    -- Show the inventory button
    if self.Inventorybuttun then
        self.Inventorybuttun:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] Inventorybuttun button is visible")
    else
        --ugcprint("[MMainUI] Warning: Inventorybuttun widget does not exist!")
    end

    -- Hide the Shenyin panel on startup
    if self.shenyin then
        self.shenyin:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Show the Jiange button and hide the Jiange panel
    if self.jiangebuttun then
        self.jiangebuttun:SetVisibility(ESlateVisibility.Visible)
    end
    if self.jiange then
        self.jiange:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Show the Endless Jiange button and hide the Endless Jiange panel
    if self.wujingbuttun then
        self.wujingbuttun:SetVisibility(ESlateVisibility.Visible)
    end
    if self.wujingjiange then
        self.wujingjiange:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Hide the progress bar on startup
    if self.jdutiao then
        self.jdutiao:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Hide the Endless Jiange settlement UI on startup
    if self.ta_settlement then
        self.ta_settlement:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Hide the inventory panel on startup
    if self.WB_Inventory then
        self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] WB_Inventory inventory panel has been hidden")
    else
        --ugcprint("[MMainUI] Warning: WB_Inventory widget does not exist!")
    end
    
    -- Hide the dungeon settlement UI on startup
    if self.Settlement then
        self.Settlement:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] Settlement settlement UI has been hidden")
    else
        --ugcprint("[MMainUI] Warning: Settlement widget does not exist!")
    end
    
    if self.Settlement_2 then
        self.Settlement_2:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] Settlement_2 timeout UI has been hidden")
    else
        --ugcprint("[MMainUI] Warning: Settlement_2 widget does not exist!")
    end
    
    if self.SettlementTip then
        self.SettlementTip:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] SettlementTip match tip UI has been hidden")
    else
        --ugcprint("[MMainUI] Warning: SettlementTip widget does not exist!")
    end

    -- Initialize the quantity selector for bulk chest opening
    if self.Numchoose then
        self.Numchoose:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Show the team button
    if self.teambuttun then
        self.teambuttun:SetVisibility(ESlateVisibility.Visible)
    end

    -- Hide the team panel on startup
    if self.WB_Team then
        if self.WB_Team.Hide then
            self.WB_Team:Hide()
        else
            self.WB_Team:SetVisibility(ESlateVisibility.Collapsed)
        end
    end

    -- Hide the team invite panel on startup
    if self.WB_Teamiinvite then
        self.WB_Teamiinvite:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Show the event button and hide the event panel
    if self.activebuttun then
        self.activebuttun:SetVisibility(ESlateVisibility.Visible)
    end
    if self.active then
        self.active:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Hide the tip panel on startup
    if self.tip then
        self.tip:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- Hide the countdown text on startup
    if self.TextBlock_timeout then
        self.TextBlock_timeout:SetVisibility(ESlateVisibility.Collapsed)
    end
    -- Hide the kill count text on startup
    if self.TextBlock_mobnum then
        self.TextBlock_mobnum:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- FriendList should not appear on the normal (non-1002) main UI.
    self:HideFriendListPanel()

    -- Hide teleport-related buttons based on the mode ID (mode 1002 does not use teleport)
    local currentModeID = UGCMultiMode.GetModeID()
    ugcprint("[MMainUI] Current mode ID: " .. tostring(currentModeID))
    if currentModeID and currentModeID == 1002 then
        self:HideTeleportButtons()
        self:ApplyMode1002MainButtons()
        self:ScheduleMode1002ButtonEnforce()
        self:StartCountdown(100)
        -- Create and show the custom team panel
        self:CreateFriendListUI(true)
        -- Initialize the kill count display
        if self.TextBlock_mobnum then
            self.TextBlock_mobnum:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
            self.TextBlock_mobnum:SetText("0/10")
        end
        -- Show the mission tip for 10 seconds
        self:ShowTipDuration("在限定时间内击败40只狼怪，并保护防御塔存活", 10)
    else
        -- The mode ID may not be ready yet; check again after 2 seconds
        UGCTimerUtility.CreateLuaTimer(2.0, function()
            local modeID = UGCMultiMode.GetModeID()
            ugcprint("[MMainUI] Delayed mode ID check: " .. tostring(modeID))
            if modeID and modeID == 1002 then
                self:HideTeleportButtons()
                self:ApplyMode1002MainButtons()
                self:ScheduleMode1002ButtonEnforce()
                self:StartCountdown(100)
                -- Create and show the custom team panel
                self:CreateFriendListUI(true)
                -- Initialize the kill count display
                if self.TextBlock_mobnum then
                    self.TextBlock_mobnum:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
                    self.TextBlock_mobnum:SetText("0/10")
                end
                -- Show the mission tip for 10 seconds
                self:ShowTipDuration("在限定时间内击败40只狼怪，并保护防御塔存活", 10)
            else
                self:HideFriendListPanel()
            end
        end, false, "MMainUI_CheckMode")
    end
    
    --ugcprint("========== MMainUI:Construct complete ==========")
end

function MMainUI:UIInit()
    if self.bInitDoOnce then
        return
    end

    self.bInitDoOnce = true

    if self.zdtunshi then
        if self.zdtunshi.OnClicked then
            -- Compatibility with the old structure: direct button.
            self.zdtunshi.OnClicked:Add(self.OnAutoTunshiClicked, self)
        elseif self.zdtunshi.RefreshFromPlayerState then
            -- New structure: reference the child widget.
            self.zdtunshi:RefreshFromPlayerState()
        end
    end

    if self.zdshiqu then
        if self.zdshiqu.OnClicked then
            -- Compatibility with the old structure: direct button.
            self.zdshiqu.OnClicked:Add(self.OnAutoPickupClicked, self)
        elseif self.zdshiqu.RefreshFromPlayerState then
            -- New structure: reference the child widget.
            self.zdshiqu:RefreshFromPlayerState()
        end
    end

    -- Related UI logic.
end

function MMainUI:GetFeatureToggleState(stateField)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return false
    end

    return playerState[stateField] == true
end

function MMainUI:SetFeatureToggleState(stateField, gameDataField, enabled)
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        return
    end

    playerState[stateField] = (enabled == true)
    if playerState.GameData then
        playerState.GameData[gameDataField] = (enabled == true)
    end
end

function MMainUI:IsFeatureUnlocked(itemID)
    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return false
    end

    local virtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not virtualItemManager then
        return false
    end

    local itemNum = virtualItemManager:GetItemNum(itemID, playerController) or 0
    return itemNum > 0
end

function MMainUI:JumpToFeaturePurchase(productID)
    if self.shoucong then
        if productID and productID > 0 then
            self.shoucong.ProductID = productID
        end

        if self.shoucong.OnConfirmPurchase then
            self.shoucong:OnConfirmPurchase()
        elseif self.shoucong.OnClick then
            self.shoucong:OnClick()
        end
    end
end

function MMainUI:OnAutoTunshiClicked()
    if not self:IsFeatureUnlocked(AUTO_TUNSHI_UNLOCK_ITEM_ID) then
		self:ShowTip("自动吞噬功能未解锁，前往购买。")
        self:JumpToFeaturePurchase(AUTO_TUNSHI_PRODUCT_ID)
        return
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return
    end

    local newState = not self:GetFeatureToggleState("UGCAutoTunshiEnabled")
    self:SetFeatureToggleState("UGCAutoTunshiEnabled", "AutoTunshiEnabled", newState)
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_SetAutoTunshiEnabled", newState)

    if self.zdtunshi and self.zdtunshi.SetToggleState then
        self.zdtunshi:SetToggleState(newState)
    elseif self.zdtunshi and self.zdtunshi.RefreshFromPlayerState then
        self.zdtunshi:RefreshFromPlayerState()
    end

    if newState then
        self:ShowTip("自动吞噬已开启。")
    else
        self:ShowTip("自动吞噬已关闭。")
    end
end

function MMainUI:OnAutoPickupClicked()
    if not self:IsFeatureUnlocked(AUTO_PICKUP_UNLOCK_ITEM_ID) then
		self:ShowTip("自动拾取功能未解锁，前往购买。")
        self:JumpToFeaturePurchase(AUTO_PICKUP_PRODUCT_ID)
        return
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return
    end

    local newState = not self:GetFeatureToggleState("UGCAutoPickupEnabled")
    self:SetFeatureToggleState("UGCAutoPickupEnabled", "AutoPickupEnabled", newState)
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_SetAutoPickupEnabled", newState)

    if self.zdshiqu and self.zdshiqu.SetToggleState then
        self.zdshiqu:SetToggleState(newState)
    elseif self.zdshiqu and self.zdshiqu.RefreshFromPlayerState then
        self.zdshiqu:RefreshFromPlayerState()
    end

    if newState then
        self:ShowTip("自动拾取已开启。")
    else
        self:ShowTip("自动拾取已关闭。")
    end
end

-- Toggle the talent tree panel
function MMainUI:ToggleTalentTree()
    if not self.TalentTree then
        --ugcprint("[MMainUI] Error: TalentTree does not exist")
        return
    end
    
    if self.TalentTree:GetVisibility() == ESlateVisibility.Collapsed then
        self.TalentTree:RefreshUI()
        self.TalentTree:SetVisibility(ESlateVisibility.Visible)
        local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
        if MainControlPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        if SkillPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
        end
        --ugcprint("[MMainUI] Talent tree is now visible")
    else
        self.TalentTree:SetVisibility(ESlateVisibility.Collapsed)
        local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
        if MainControlPanel then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        if SkillPanel then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
        end
        --ugcprint("[MMainUI] Talent tree is now hidden")
    end
end

-- Show the talent confirmation dialog
function MMainUI:ShowTalentTip(level)
    if not self.TalentTip then
        --ugcprint("[MMainUI] Error: TalentTip does not exist")
        return
    end
    
    self.TalentTip:SetTalentInfo(level)
    self.TalentTip:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Talent tip dialog is visible, level: " .. level)
end

-- Show the avatar detail panel
function MMainUI:ShowTouxiangDetail()
    if not self.touxiangdetail then
        --ugcprint("[MMainUI] Error: touxiangdetail does not exist")
        return
    end

    if self.touxiangdetail.Show then
        self.touxiangdetail:Show()
    else
        self.touxiangdetail:SetVisibility(ESlateVisibility.Visible)
    end
    --ugcprint("[MMainUI] Avatar detail panel is visible")
end

-- Show the first top-up panel
function MMainUI:ShowShouchong()
    if not self.shouchong then
        --ugcprint("[MMainUI] Error: shouchong does not exist")
        return
    end

    self.shouchong:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] First top-up panel is visible")
end

-- Hide the first top-up panel
function MMainUI:HideShouchong()
    if not self.shouchong then
        --ugcprint("[MMainUI] Error: shouchong does not exist")
        return
    end

    self.shouchong:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] First top-up panel is hidden")
end

-- Show the consume button
function MMainUI:ShowTunshi()
    --ugcprint("[MMainUI] ShowTunshi was called")
    if not self.tunshi then
        --ugcprint("[MMainUI] Error: tunshi widget does not exist")
        return
    end
    --ugcprint("[MMainUI] Showing the consume button")
    self.tunshi:SetVisibility(ESlateVisibility.Visible)
end

function MMainUI:TryAutoTunshiConsume()
    if self.bAutoTunshiConsumeCD then
        return
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if not playerController then
        return
    end

    self.bAutoTunshiConsumeCD = true
    UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_DestroyNearbyCorpses")

    if self.tunshi then
        self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
    end

    UGCTimerUtility.CreateLuaTimer(0.3, function()
        self.bAutoTunshiConsumeCD = false
    end, false, "MMainUI_AutoTunshiCD_" .. tostring(self))
end

-- Hide the consume button
function MMainUI:HideTunshi()
    --ugcprint("[MMainUI] HideTunshi was called")
    if not self.tunshi then
        --ugcprint("[MMainUI] Error: tunshi widget does not exist")
        return
    end
    --ugcprint("[MMainUI] Hiding the consume button")
    self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
end

-- Show the purchase confirmation dialog
function MMainUI:ShowConfirmPurchase(purchaseInfo)
    if not self.ConfirmPurchase_UIBP then
        --ugcprint("[MMainUI] Error: ConfirmPurchase_UIBP widget does not exist")
        return
    end
    
    -- Set the purchase information.
    if self.ConfirmPurchase_UIBP.SetPurchaseInfo then
        self.ConfirmPurchase_UIBP:SetPurchaseInfo(purchaseInfo)
    end
    
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Purchase confirmation dialog is visible")
end

-- Hide the purchase confirmation dialog
function MMainUI:HideConfirmPurchase()
    if not self.ConfirmPurchase_UIBP then
        --ugcprint("[MMainUI] Error: ConfirmPurchase_UIBP widget does not exist")
        return
    end
    
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] Purchase confirmation dialog is hidden")
end

-- Toggle the Shenyin panel
function MMainUI:ToggleShenyin()
    if not self.shenyin then
        return
    end
    
    if self.shenyin:GetVisibility() == ESlateVisibility.Collapsed or self.shenyin:GetVisibility() == ESlateVisibility.Hidden then
        self.shenyin:Show()
    else
        self.shenyin:OnCancelClicked()
    end
end

-- Show the Shenyin panel
function MMainUI:ShowShenyin()
    if not self.shenyin then
        return
    end
    
    self.shenyin:Show()
end

-- Hide the Shenyin panel
function MMainUI:HideShenyin()
    if not self.shenyin then
        return
    end
    
    self.shenyin:OnCancelClicked()
end

-- Toggle the Jiange panel
function MMainUI:ToggleJiange()
    if not self.jiange then return end
    if self.jiange:GetVisibility() == ESlateVisibility.Collapsed or self.jiange:GetVisibility() == ESlateVisibility.Hidden then
        self.jiange:Show()
    else
        self.jiange:OnCancelClicked()
    end
end

-- Toggle the Endless Jiange panel
function MMainUI:ToggleWujingjiange()
    if not self.wujingjiange then return end
    if self.wujingjiange:GetVisibility() == ESlateVisibility.Collapsed or self.wujingjiange:GetVisibility() == ESlateVisibility.Hidden then
        self.wujingjiange:Show()
    else
        self.wujingjiange:OnCancelClicked()
    end
end

-- Toggle the inventory panel
function MMainUI:ToggleInventory()
    if not self.WB_Inventory then
        --ugcprint("[MMainUI] Error: WB_Inventory widget does not exist")
        return
    end
    
    if self.WB_Inventory:GetVisibility() == ESlateVisibility.Collapsed then
        self.WB_Inventory:SetVisibility(ESlateVisibility.Visible)
        local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
        if MainControlPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        if SkillPanel then
            UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
        end
    else
        self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
        local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
        if MainControlPanel then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
        end
        local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
        if SkillPanel then
            UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
        end
    end
end

-- Show the inventory panel.
function MMainUI:ShowInventory()
    if not self.WB_Inventory then
        --ugcprint("[MMainUI] Error: WB_Inventory widget does not exist")
        return
    end
    
    self.WB_Inventory:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Inventory panel is visible")
end

-- Hide the inventory panel.
function MMainUI:HideInventory()
    if not self.WB_Inventory then
        --ugcprint("[MMainUI] Error: WB_Inventory widget does not exist")
        return
    end
    
    self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] Inventory panel is hidden")
end

-- Toggle the shouna button state
function MMainUI:ToggleShounaButtons()
    --ugcprint("[MMainUI] ========== ToggleShounaButtons called ==========")
    --ugcprint("[MMainUI] Current state isShounaButtnsHidden: " .. tostring(self.isShounaButtnsHidden))

    if self:IsMode1002() then
        self.isShounaButtnsHidden = false
        self:ApplyMode1002MainButtons()
        return
    end
    
    if not self.shouna then
        --ugcprint("[MMainUI] Error: shouna widget does not exist")
        return
    end
    
    if self.isShounaButtnsHidden then
        -- When hidden, clicking shows the buttons
        --ugcprint("[MMainUI] Prepare to show all buttons.")
        
        -- Switch images: show Image_0 and hide Image_1
        if self.shouna.Image_0 then
            self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] Image_0 is visible")
        else
            --ugcprint("[MMainUI] Error: Image_0 does not exist")
        end
        
        if self.shouna.Image_1 then
            self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] Image_1 is hidden")
        else
            --ugcprint("[MMainUI] Error: Image_1 does not exist")
        end
        
        -- Show all buttons
        if self.chuansongbuttun then
            if not self.TeleportButtonsHidden then
                self.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
            end
            --ugcprint("[MMainUI] chuansongbuttun is visible")
        end
        if self.chuansongbuttun_2 then
            if not self.TeleportButtonsHidden then
                self.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
            end
            --ugcprint("[MMainUI] chuansongbuttun_2 is visible")
        end
        if self.Inventorybuttun then
            self.Inventorybuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] Inventorybuttun is visible")
        end
        if self.shenyingbuttun then
            self.shenyingbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shenyingbuttun is visible")
        end
        if self.jiangebuttun then
            self.jiangebuttun:SetVisibility(ESlateVisibility.Visible)
        end
        if self.wujingbuttun then
            if not self.TeleportButtonsHidden then
                self.wujingbuttun:SetVisibility(ESlateVisibility.Visible)
            end
        end
        if self.shouchongbuttun then
            self.shouchongbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shouchongbuttun is visible")
        end
        if self.shoucong then
            self.shoucong:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shoucong is visible")
        end
        if self.TalenTreeButtun then
            self.TalenTreeButtun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] TalenTreeButtun is visible")
        end
        if self.taskbuttun then
            self.taskbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] taskbuttun is visible")
        end
        if self.WBP_OpenLotteryButton then
            self.WBP_OpenLotteryButton:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] WBP_OpenLotteryButton is visible")
        end
        if self.zhuanshengbuttun then
            self.zhuanshengbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] zhuanshengbuttun is visible")
        end
        if self.UGC_RankingList_IngameBut_UIBP then
            self.UGC_RankingList_IngameBut_UIBP:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] UGC_RankingList_IngameBut_UIBP is visible")
        end
        if self.teambuttun then
            self.teambuttun:SetVisibility(ESlateVisibility.Visible)
        end
        if self.activebuttun then
            self.activebuttun:SetVisibility(ESlateVisibility.Visible)
        end
        
        self.isShounaButtnsHidden = false
        --ugcprint("[MMainUI] All buttons are visible; state updated to false")
    else
        -- When visible, clicking hides the buttons
        --ugcprint("[MMainUI] Prepare to hide all buttons.")
        
        -- Switch images: hide Image_0 and show Image_1.
        if self.shouna.Image_0 then
            self.shouna.Image_0:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] Image_0 is hidden")
        else
            --ugcprint("[MMainUI] Error: Image_0 does not exist")
        end
        
        if self.shouna.Image_1 then
            self.shouna.Image_1:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] Image_1 is visible")
        else
            --ugcprint("[MMainUI] Error: Image_1 does not exist")
        end
        
        -- Hide all buttons
        if self.chuansongbuttun then
            self.chuansongbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] chuansongbuttun is hidden")
        end
        if self.chuansongbuttun_2 then
            self.chuansongbuttun_2:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] chuansongbuttun_2 is hidden")
        end
        if self.Inventorybuttun then
            self.Inventorybuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] Inventorybuttun is hidden")
        end
        if self.shenyingbuttun then
            self.shenyingbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shenyingbuttun is hidden")
        end
        if self.jiangebuttun then
            self.jiangebuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        if self.wujingbuttun then
            self.wujingbuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        if self.shouchongbuttun then
            self.shouchongbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shouchongbuttun is hidden")
        end
        if self.shoucong then
            self.shoucong:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shoucong is hidden")
        end
        if self.TalenTreeButtun then
            self.TalenTreeButtun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] TalenTreeButtun is hidden")
        end
        if self.taskbuttun then
            self.taskbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] taskbuttun is hidden")
        end
        if self.WBP_OpenLotteryButton then
            self.WBP_OpenLotteryButton:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] WBP_OpenLotteryButton is hidden")
        end
        if self.zhuanshengbuttun then
            self.zhuanshengbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] zhuanshengbuttun is hidden")
        end
        if self.UGC_RankingList_IngameBut_UIBP then
            self.UGC_RankingList_IngameBut_UIBP:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] UGC_RankingList_IngameBut_UIBP is hidden")
        end
        if self.teambuttun then
            self.teambuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        if self.activebuttun then
            self.activebuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        
        self.isShounaButtnsHidden = true
        --ugcprint("[MMainUI] All buttons are hidden; state updated to true")
    end
    
    -- Related UI logic.
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

-- Mode 1002 keeps only the bloodline, Shenyin, and Jiange entrances
function MMainUI:ApplyMode1002MainButtons()
    local hideWidgets = {
        self.shouna,
        self.touxiang,
        self.chuansongbuttun,
        self.chuansongbuttun_2,
        self.Inventorybuttun,
        self.wujingbuttun,
        self.shouchongbuttun,
        self.shoucong,
        self.TalenTreeButtun,
        self.taskbuttun,
        self.WBP_OpenLotteryButton,
        self.zhuanshengbuttun,
        self.UGC_RankingList_IngameBut_UIBP,
        self.teambuttun,
        self.activebuttun,
        self.ShopV2_OpenShopButton_UIBP,
        self.huicheng,
        self.addexp,
        self.zdshiqu,
        self.zdtunshi,
        self.taskblank,
    }

    for _, widget in ipairs(hideWidgets) do
        if widget then
            widget:SetVisibility(ESlateVisibility.Collapsed)
        end
    end

    local keepWidgets = {
        self.xuemai,
        self.shenyingbuttun,
        self.jiangebuttun,
    }

    for _, widget in ipairs(keepWidgets) do
        if widget then
            widget:SetVisibility(ESlateVisibility.Visible)
        end
    end

    local playerController = UGCGameSystem.GetLocalPlayerController()
    if playerController and playerController.RankingListComponent then
        if playerController.RankingListComponent.CloseRankList then
            playerController.RankingListComponent:CloseRankList()
        elseif playerController.RankingListComponent.RankingListBtn then
            playerController.RankingListComponent.RankingListBtn:SetVisibility(ESlateVisibility.Collapsed)
        end
    end

    -- Keep the feature panels collapsed by default and only keep the entrance buttons
    if self.shenyin then
        self.shenyin:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.jiange then
        self.jiange:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.wujingjiange then
        self.wujingjiange:SetVisibility(ESlateVisibility.Collapsed)
    end
end



-- ============ Dungeon UI control functions ============

-- Show the dungeon settlement UI (success)
function MMainUI:ShowSettlement()
    if not self.Settlement then
        --ugcprint("[MMainUI] Error: Settlement widget does not exist.")
        return
    end
    
    self.Settlement:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Settlement UI is visible.")
end

-- Hide the dungeon settlement UI (success)
function MMainUI:HideSettlement()
    if not self.Settlement then
        --ugcprint("[MMainUI] Error: Settlement widget does not exist.")
        return
    end
    
    self.Settlement:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] Settlement settlement UI has been hidden")
end

-- Show the dungeon timeout UI (failure)
function MMainUI:ShowSettlement_2()
    if not self.Settlement_2 then
        --ugcprint("[MMainUI] Error: Settlement_2 widget does not exist.")
        return
    end
    
    self.Settlement_2:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Settlement_2 timeout UI is visible.")
end

-- Hide the dungeon timeout UI (failure)
function MMainUI:HideSettlement_2()
    if not self.Settlement_2 then
        --ugcprint("[MMainUI] Error: Settlement_2 widget does not exist.")
        return
    end
    
    self.Settlement_2:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] Settlement_2 timeout UI has been hidden")
end

-- Show the dungeon match tip UI
function MMainUI:ShowSettlementTip()
    if not self.SettlementTip then
        --ugcprint("[MMainUI] Error: SettlementTip widget does not exist.")
        return
    end
    
    self.SettlementTip:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] SettlementTip match tip UI is visible.")
end

-- Hide the dungeon match tip UI
function MMainUI:HideSettlementTip()
    if not self.SettlementTip then
        --ugcprint("[MMainUI] Error: SettlementTip widget does not exist.")
        return
    end
    
    self.SettlementTip:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] SettlementTip match tip UI has been hidden")
end

-- ============ Team UI control functions ============

-- Toggle the team panel
function MMainUI:ToggleTeam()
    if not self.WB_Team then
        return
    end
    
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


-- Hide teleport buttons that are not needed in match mode
function MMainUI:HideTeleportButtons()
    local buttons = {self.wujingbuttun, self.chuansongbuttun, self.chuansongbuttun_2, self.huicheng}
    for _, btn in ipairs(buttons) do
        if btn then btn:SetVisibility(ESlateVisibility.Collapsed) end
    end
    self.TeleportButtonsHidden = true
    ugcprint("[MMainUI] Match mode: teleport buttons are hidden")
end

-- Restore teleport button visibility
function MMainUI:ShowTeleportButtons()
    local buttons = {self.wujingbuttun, self.chuansongbuttun, self.chuansongbuttun_2, self.huicheng}
    for _, btn in ipairs(buttons) do
        if btn then btn:SetVisibility(ESlateVisibility.Visible) end
    end
    self.TeleportButtonsHidden = false
    ugcprint("[MMainUI] Teleport buttons are visible again")
end

-- ============ Dungeon countdown functions ============

-- Start the dungeon countdown
function MMainUI:StartCountdown(totalSeconds)
    ugcprint("[MMainUI] StartCountdown called, totalSeconds=" .. tostring(totalSeconds))
    
    if not self.TextBlock_timeout then
        ugcprint("[MMainUI] Error: TextBlock_timeout does not exist")
        return
    end
    
    -- Stop the previous countdown if one exists
    self:StopCountdown()
    
    self.CountdownRemaining = math.max(0, math.floor(tonumber(totalSeconds) or 0))
    self.CountdownTimeoutTriggered = false
    self.CountdownExitRequestPending = false
    self.CountdownExitRequestSent = false
    self.TextBlock_timeout:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    
    -- Update the display immediately once
    self:UpdateCountdownText()
    
    -- Update once per second
    self.CountdownTimerHandle = UGCGameSystem.SetTimer(self, function()
        if self.CountdownTimeoutTriggered then
            self:StopCountdown()
            return
        end

        self.CountdownRemaining = (self.CountdownRemaining or 0) - 1
        if self.CountdownRemaining <= 0 then
            self.CountdownRemaining = 0
            self:UpdateCountdownText()
            self.CountdownTimeoutTriggered = true
            -- Run the timeout flow before stopping the timer
            ugcprint("[MMainUI] Countdown ended, triggering the timeout exit flow")
            self:ShowTip("时间到了，挑战失败。")

            self:StopCountdown()
        else
            self:UpdateCountdownText()
        end
    end, 1.0, true)
    
    ugcprint("[MMainUI] Countdown started, total duration=" .. tostring(totalSeconds) .. " seconds")
end

-- Update the countdown text display
function MMainUI:UpdateCountdownText()
    if not self.TextBlock_timeout then return end
    local remaining = self.CountdownRemaining or 0
    local minutes = math.floor(remaining / 60)
    local seconds = remaining % 60
    local timeStr = string.format("Time remaining until challenge ends: %02d:%02d", minutes, seconds)
    self.TextBlock_timeout:SetText(timeStr)
end

-- Stop the countdown
function MMainUI:StopCountdown()
    if self.CountdownTimerHandle then
        UGCGameSystem.StopTimer(self.CountdownTimerHandle)
        self.CountdownTimerHandle = nil
    end
end

-- Shared tip method for child widgets
function MMainUI:ShowTip(text)
    if not self.tip then return end
    if self.tip.tiptext then
        self.tip.tiptext:SetText(text)
    end
    self.tip:SetVisibility(ESlateVisibility.Visible)
    -- Stop the current animation first, then replay it from the start
    if self.NewAnimation_1 then
        self:StopAnimation(self.NewAnimation_1)
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
    end
    -- Clear the old hide timer so repeated clicks do not hide the tip too early
    if self.TipTimerHandle then
        UGCGameSystem.StopTimer(self.TipTimerHandle)
    end
    self.TipTimerHandle = UGCGameSystem.SetTimer(self, function()
        if self.tip then
            self.tip:SetVisibility(ESlateVisibility.Collapsed)
        end
        self.TipTimerHandle = nil
    end, 2.0, false)
end

-- Related UI logic.
function MMainUI:CreateFriendListUI(forceCreate)
    if not forceCreate and not self:IsMode1002() then
        self:HideFriendListPanel()
        return
    end

    -- Fallback: keep the embedded FriendList visible in case standalone creation fails.
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

-- Update the global kill count display for mode 1002
function MMainUI:UpdateMobKillCount(currentKills, requiredKills)
    if not self.TextBlock_mobnum then return end
    self.TextBlock_mobnum:SetText(tostring(currentKills) .. "/" .. tostring(requiredKills))
    ugcprint("[MMainUI] Kill count updated: " .. tostring(currentKills) .. "/" .. tostring(requiredKills))
end

-- Tip message with a custom duration
function MMainUI:ShowTipDuration(text, duration)
    if not self.tip then return end
    if self.tip.tiptext then
        self.tip.tiptext:SetText(text)
    end
    self.tip:SetVisibility(ESlateVisibility.Visible)
    if self.NewAnimation_1 then
        self:StopAnimation(self.NewAnimation_1)
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
    end
    if self.TipTimerHandle then
        UGCGameSystem.StopTimer(self.TipTimerHandle)
    end
    self.TipTimerHandle = UGCGameSystem.SetTimer(self, function()
        if self.tip then
            self.tip:SetVisibility(ESlateVisibility.Collapsed)
        end
        self.TipTimerHandle = nil
    end, duration or 2.0, false)
end


return MMainUI


