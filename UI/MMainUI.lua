---@class MMainUI_C:UUserWidget
---@field addexp ddexp_C
---@field chuansong chuansong_C
---@field chuansong_2 chuansong_2_C
---@field chuansongbuttun chuansongbuttun_C
---@field chuansongbuttun_2 chuansongbuttun_2_C
---@field ConfirmPurchase_UIBP ConfirmPurchase_UIBP_C
---@field help help_C
---@field huicheng huicheng_C
---@field Inventorybuttun Inventorybuttun_C
---@field jdutiao jdutiao_C
---@field jiange jiange_C
---@field jiangebuttun jiangebuttun_C
---@field jiaocheng1 jiaocheng1_C
---@field Settlement Settlement_C
---@field Settlement_2 Settlement_2_C
---@field SettlementTip SettlementTip_C
---@field shenyin shenyin_C
---@field shenyingbuttun shenyingbuttun_C
---@field shouchongbuttun shouchongbuttun_C
---@field shoucong shoucong_C
---@field shouna shouna_C
---@field ta_settlement ta_settlement_C
---@field TalenTreeButtun TalenTreeButtun_C
---@field TalentTip TalentTip_C
---@field TalentTree TalentTree_C
---@field TASK TASK_C
---@field taskbuttun taskbuttun_C
---@field teambuttun teambuttun_C
---@field TestButton TestButton_C
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
---@field zhuansheng zhuansheng_C
---@field zhuanshengbuttun zhuanshengbuttun_C
--Edit Below--
local MMainUI = { bInitDoOnce = false }

function MMainUI:Construct()
    --ugcprint("========== MMainUI:Construct 开始 ==========")
    self:UIInit()
    
    -- 初始化 shouna 收纳功能
    self.isShounaButtnsHidden = false
    --ugcprint("[MMainUI] 初始化 shouna 状态: isShounaButtnsHidden = false")
    
    -- 初始化 shouna 图片状态：显示 Image_0，隐藏 Image_1
    if self.shouna then
        if self.shouna.Image_0 then
            self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shouna Image_0 初始化为显示")
        end
        if self.shouna.Image_1 then
            self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shouna Image_1 初始化为隐藏")
        end
    end
    
    -- 初始化时显示按钮，隐藏界面
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
    
    -- 初始化时隐藏传送和转生界面
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
    
    -- 初始化时隐藏天赋树和提示框
    if self.TalentTree then
        self.TalentTree:SetVisibility(ESlateVisibility.Collapsed)
    end
    
    if self.TalentTip then
        self.TalentTip:SetVisibility(ESlateVisibility.Collapsed)
    end
    
    -- 初始化时隐藏详情界面
    if self.touxiangdetail then
        self.touxiangdetail:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 显示首充按钮
    if self.shouchongbuttun then
        self.shouchongbuttun:SetVisibility(ESlateVisibility.Visible)
    end

    -- 显示首充界面（shoucong）
    if self.shoucong then
        self.shoucong:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] shoucong 组件已显示")
    else
        --ugcprint("[MMainUI] 警告: shoucong 组件不存在!")
    end

    -- 初始化时隐藏吞噬按钮
    if self.tunshi then
        self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 初始化时隐藏吞噬提示
    if self.tunshitip then
        self.tunshitip:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 显示任务按钮
    if self.taskbuttun then
        self.taskbuttun:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] taskbuttun 组件存在，已设置为可见")
    else
        --ugcprint("[MMainUI] 警告: taskbuttun 组件不存在!")
    end
    
    -- 初始化时隐藏任务面板
    if self.TASK then
        self.TASK:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] TASK 组件存在，已设置为隐藏")
    else
        --ugcprint("[MMainUI] 警告: TASK 组件不存在!")
    end

    -- 初始化时隐藏购买确认对话框
    if self.ConfirmPurchase_UIBP then
        self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] ConfirmPurchase_UIBP 组件已隐藏")
    else
        --ugcprint("[MMainUI] 警告: ConfirmPurchase_UIBP 组件不存在!")
    end

    -- 显示神影按钮
    if self.shenyingbuttun then
        self.shenyingbuttun:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] shenyingbuttun 按钮已显示")
    else
        --ugcprint("[MMainUI] 警告: shenyingbuttun 组件不存在!")
    end

    -- 显示背包按钮
    if self.Inventorybuttun then
        self.Inventorybuttun:SetVisibility(ESlateVisibility.Visible)
        --ugcprint("[MMainUI] Inventorybuttun 按钮已显示")
    else
        --ugcprint("[MMainUI] 警告: Inventorybuttun 组件不存在!")
    end

    -- 初始化时隐藏神影界面
    if self.shenyin then
        self.shenyin:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 显示剑阁按钮，隐藏剑阁界面
    if self.jiangebuttun then
        self.jiangebuttun:SetVisibility(ESlateVisibility.Visible)
    end
    if self.jiange then
        self.jiange:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 显示无尽剑阁按钮，隐藏无尽剑阁界面
    if self.wujingbuttun then
        self.wujingbuttun:SetVisibility(ESlateVisibility.Visible)
    end
    if self.wujingjiange then
        self.wujingjiange:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 初始化时隐藏进度条
    if self.jdutiao then
        self.jdutiao:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 初始化时隐藏无尽剑阁结算UI
    if self.ta_settlement then
        self.ta_settlement:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 初始化时隐藏背包界面
    if self.WB_Inventory then
        self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] WB_Inventory 背包界面已隐藏")
    else
        --ugcprint("[MMainUI] 警告: WB_Inventory 组件不存在!")
    end
    
    -- 初始化时隐藏副本结算UI
    if self.Settlement then
        self.Settlement:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] Settlement 结算UI已隐藏")
    else
        --ugcprint("[MMainUI] 警告: Settlement 组件不存在!")
    end
    
    if self.Settlement_2 then
        self.Settlement_2:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] Settlement_2 超时UI已隐藏")
    else
        --ugcprint("[MMainUI] 警告: Settlement_2 组件不存在!")
    end
    
    if self.SettlementTip then
        self.SettlementTip:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[MMainUI] SettlementTip 匹配提示UI已隐藏")
    else
        --ugcprint("[MMainUI] 警告: SettlementTip 组件不存在!")
    end

    -- 显示队伍按钮
    if self.teambuttun then
        self.teambuttun:SetVisibility(ESlateVisibility.Visible)
    end

    -- 初始化时隐藏队伍界面
    if self.WB_Team then
        self.WB_Team:SetVisibility(ESlateVisibility.Collapsed)
    end

    -- 初始化时隐藏队伍邀请界面
    if self.WB_Teamiinvite then
        self.WB_Teamiinvite:SetVisibility(ESlateVisibility.Collapsed)
    end
    
    --ugcprint("========== MMainUI:Construct 完成 ==========")
end

function MMainUI:UIInit()
    --ugcprint("MMainUI: UIInit 完成")
end

-- 切换天赋树显示
function MMainUI:ToggleTalentTree()
    if not self.TalentTree then
        --ugcprint("[MMainUI] 错误：TalentTree 不存在")
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
        --ugcprint("[MMainUI] 天赋树已显示")
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
        --ugcprint("[MMainUI] 天赋树已隐藏")
    end
end

-- 显示天赋确认提示框
function MMainUI:ShowTalentTip(level)
    if not self.TalentTip then
        --ugcprint("[MMainUI] 错误：TalentTip 不存在")
        return
    end
    
    self.TalentTip:SetTalentInfo(level)
    self.TalentTip:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] 天赋提示框已显示，等级: " .. level)
end

-- 显示头像详情界面
function MMainUI:ShowTouxiangDetail()
    if not self.touxiangdetail then
        --ugcprint("[MMainUI] 错误：touxiangdetail 不存在")
        return
    end
    
    self.touxiangdetail:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] 头像详情界面已显示")
end

-- 显示首充界面
function MMainUI:ShowShouchong()
    if not self.shouchong then
        --ugcprint("[MMainUI] 错误：shouchong 不存在")
        return
    end

    self.shouchong:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] 首充界面已显示")
end

-- 隐藏首充界面
function MMainUI:HideShouchong()
    if not self.shouchong then
        --ugcprint("[MMainUI] 错误：shouchong 不存在")
        return
    end

    self.shouchong:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] 首充界面已隐藏")
end

-- 显示吞噬按钮
function MMainUI:ShowTunshi()
    --ugcprint("[MMainUI] ShowTunshi 被调用")
    if not self.tunshi then
        --ugcprint("[MMainUI] 错误：tunshi 组件不存在")
        return
    end
    --ugcprint("[MMainUI] 显示吞噬按钮")
    self.tunshi:SetVisibility(ESlateVisibility.Visible)
end

-- 隐藏吞噬按钮
function MMainUI:HideTunshi()
    --ugcprint("[MMainUI] HideTunshi 被调用")
    if not self.tunshi then
        --ugcprint("[MMainUI] 错误：tunshi 组件不存在")
        return
    end
    --ugcprint("[MMainUI] 隐藏吞噬按钮")
    self.tunshi:SetVisibility(ESlateVisibility.Collapsed)
end

-- 显示购买确认对话框
function MMainUI:ShowConfirmPurchase(purchaseInfo)
    if not self.ConfirmPurchase_UIBP then
        --ugcprint("[MMainUI] 错误：ConfirmPurchase_UIBP 组件不存在")
        return
    end
    
    -- 设置购买信息
    if self.ConfirmPurchase_UIBP.SetPurchaseInfo then
        self.ConfirmPurchase_UIBP:SetPurchaseInfo(purchaseInfo)
    end
    
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] 购买确认对话框已显示")
end

-- 隐藏购买确认对话框
function MMainUI:HideConfirmPurchase()
    if not self.ConfirmPurchase_UIBP then
        --ugcprint("[MMainUI] 错误：ConfirmPurchase_UIBP 组件不存在")
        return
    end
    
    self.ConfirmPurchase_UIBP:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] 购买确认对话框已隐藏")
end

-- 切换神影界面显示
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

-- 显示神影界面
function MMainUI:ShowShenyin()
    if not self.shenyin then
        return
    end
    
    self.shenyin:Show()
end

-- 隐藏神影界面
function MMainUI:HideShenyin()
    if not self.shenyin then
        return
    end
    
    self.shenyin:OnCancelClicked()
end

-- 切换剑阁界面显示
function MMainUI:ToggleJiange()
    if not self.jiange then return end
    if self.jiange:GetVisibility() == ESlateVisibility.Collapsed or self.jiange:GetVisibility() == ESlateVisibility.Hidden then
        self.jiange:Show()
    else
        self.jiange:OnCancelClicked()
    end
end

-- 切换无尽剑阁界面显示
function MMainUI:ToggleWujingjiange()
    if not self.wujingjiange then return end
    if self.wujingjiange:GetVisibility() == ESlateVisibility.Collapsed or self.wujingjiange:GetVisibility() == ESlateVisibility.Hidden then
        self.wujingjiange:Show()
    else
        self.wujingjiange:OnCancelClicked()
    end
end

-- 切换背包界面显示
function MMainUI:ToggleInventory()
    if not self.WB_Inventory then
        --ugcprint("[MMainUI] 错误：WB_Inventory 组件不存在")
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

-- 显示背包界面
function MMainUI:ShowInventory()
    if not self.WB_Inventory then
        --ugcprint("[MMainUI] 错误：WB_Inventory 组件不存在")
        return
    end
    
    self.WB_Inventory:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] 背包界面已显示")
end

-- 隐藏背包界面
function MMainUI:HideInventory()
    if not self.WB_Inventory then
        --ugcprint("[MMainUI] 错误：WB_Inventory 组件不存在")
        return
    end
    
    self.WB_Inventory:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] 背包界面已隐藏")
end

-- 切换收纳按钮状态
function MMainUI:ToggleShounaButtons()
    --ugcprint("[MMainUI] ========== ToggleShounaButtons 被调用 ==========")
    --ugcprint("[MMainUI] 当前状态 isShounaButtnsHidden: " .. tostring(self.isShounaButtnsHidden))
    
    if not self.shouna then
        --ugcprint("[MMainUI] 错误：shouna 组件不存在")
        return
    end
    
    if self.isShounaButtnsHidden then
        -- 当前是隐藏状态，点击后显示
        --ugcprint("[MMainUI] 准备显示所有按钮")
        
        -- 切换图片：显示 Image_0，隐藏 Image_1
        if self.shouna.Image_0 then
            self.shouna.Image_0:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] Image_0 已显示")
        else
            --ugcprint("[MMainUI] 错误：Image_0 不存在")
        end
        
        if self.shouna.Image_1 then
            self.shouna.Image_1:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] Image_1 已隐藏")
        else
            --ugcprint("[MMainUI] 错误：Image_1 不存在")
        end
        
        -- 显示所有按钮
        if self.chuansongbuttun then
            self.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] chuansongbuttun 已显示")
        end
        if self.chuansongbuttun_2 then
            self.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] chuansongbuttun_2 已显示")
        end
        if self.Inventorybuttun then
            self.Inventorybuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] Inventorybuttun 已显示")
        end
        if self.shenyingbuttun then
            self.shenyingbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shenyingbuttun 已显示")
        end
        if self.jiangebuttun then
            self.jiangebuttun:SetVisibility(ESlateVisibility.Visible)
        end
        if self.wujingbuttun then
            self.wujingbuttun:SetVisibility(ESlateVisibility.Visible)
        end
        if self.shouchongbuttun then
            self.shouchongbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shouchongbuttun 已显示")
        end
        if self.shoucong then
            self.shoucong:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] shoucong 已显示")
        end
        if self.TalenTreeButtun then
            self.TalenTreeButtun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] TalenTreeButtun 已显示")
        end
        if self.taskbuttun then
            self.taskbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] taskbuttun 已显示")
        end
        if self.WBP_OpenLotteryButton then
            self.WBP_OpenLotteryButton:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] WBP_OpenLotteryButton 已显示")
        end
        if self.zhuanshengbuttun then
            self.zhuanshengbuttun:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] zhuanshengbuttun 已显示")
        end
        if self.UGC_RankingList_IngameBut_UIBP then
            self.UGC_RankingList_IngameBut_UIBP:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] UGC_RankingList_IngameBut_UIBP 已显示")
        end
        if self.teambuttun then
            self.teambuttun:SetVisibility(ESlateVisibility.Visible)
        end
        
        self.isShounaButtnsHidden = false
        --ugcprint("[MMainUI] 所有按钮已显示，状态更新为: false")
    else
        -- 当前是显示状态，点击后隐藏
        --ugcprint("[MMainUI] 准备隐藏所有按钮")
        
        -- 切换图片：隐藏 Image_0，显示 Image_1
        if self.shouna.Image_0 then
            self.shouna.Image_0:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] Image_0 已隐藏")
        else
            --ugcprint("[MMainUI] 错误：Image_0 不存在")
        end
        
        if self.shouna.Image_1 then
            self.shouna.Image_1:SetVisibility(ESlateVisibility.Visible)
            --ugcprint("[MMainUI] Image_1 已显示")
        else
            --ugcprint("[MMainUI] 错误：Image_1 不存在")
        end
        
        -- 隐藏所有按钮
        if self.chuansongbuttun then
            self.chuansongbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] chuansongbuttun 已隐藏")
        end
        if self.chuansongbuttun_2 then
            self.chuansongbuttun_2:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] chuansongbuttun_2 已隐藏")
        end
        if self.Inventorybuttun then
            self.Inventorybuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] Inventorybuttun 已隐藏")
        end
        if self.shenyingbuttun then
            self.shenyingbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shenyingbuttun 已隐藏")
        end
        if self.jiangebuttun then
            self.jiangebuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        if self.wujingbuttun then
            self.wujingbuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        if self.shouchongbuttun then
            self.shouchongbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shouchongbuttun 已隐藏")
        end
        if self.shoucong then
            self.shoucong:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] shoucong 已隐藏")
        end
        if self.TalenTreeButtun then
            self.TalenTreeButtun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] TalenTreeButtun 已隐藏")
        end
        if self.taskbuttun then
            self.taskbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] taskbuttun 已隐藏")
        end
        if self.WBP_OpenLotteryButton then
            self.WBP_OpenLotteryButton:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] WBP_OpenLotteryButton 已隐藏")
        end
        if self.zhuanshengbuttun then
            self.zhuanshengbuttun:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] zhuanshengbuttun 已隐藏")
        end
        if self.UGC_RankingList_IngameBut_UIBP then
            self.UGC_RankingList_IngameBut_UIBP:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[MMainUI] UGC_RankingList_IngameBut_UIBP 已隐藏")
        end
        if self.teambuttun then
            self.teambuttun:SetVisibility(ESlateVisibility.Collapsed)
        end
        
        self.isShounaButtnsHidden = true
        --ugcprint("[MMainUI] 所有按钮已隐藏，状态更新为: true")
    end
    
    --ugcprint("[MMainUI] ========== ToggleShounaButtons 完成 ==========")
end



-- ============ 副本系统UI控制函数 ============

-- 显示副本结算UI（成功）
function MMainUI:ShowSettlement()
    if not self.Settlement then
        --ugcprint("[MMainUI] 错误：Settlement 组件不存在")
        return
    end
    
    self.Settlement:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Settlement 结算UI已显示")
end

-- 隐藏副本结算UI（成功）
function MMainUI:HideSettlement()
    if not self.Settlement then
        --ugcprint("[MMainUI] 错误：Settlement 组件不存在")
        return
    end
    
    self.Settlement:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] Settlement 结算UI已隐藏")
end

-- 显示副本超时UI（失败）
function MMainUI:ShowSettlement_2()
    if not self.Settlement_2 then
        --ugcprint("[MMainUI] 错误：Settlement_2 组件不存在")
        return
    end
    
    self.Settlement_2:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] Settlement_2 超时UI已显示")
end

-- 隐藏副本超时UI（失败）
function MMainUI:HideSettlement_2()
    if not self.Settlement_2 then
        --ugcprint("[MMainUI] 错误：Settlement_2 组件不存在")
        return
    end
    
    self.Settlement_2:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] Settlement_2 超时UI已隐藏")
end

-- 显示副本匹配提示UI
function MMainUI:ShowSettlementTip()
    if not self.SettlementTip then
        --ugcprint("[MMainUI] 错误：SettlementTip 组件不存在")
        return
    end
    
    self.SettlementTip:SetVisibility(ESlateVisibility.Visible)
    --ugcprint("[MMainUI] SettlementTip 匹配提示UI已显示")
end

-- 隐藏副本匹配提示UI
function MMainUI:HideSettlementTip()
    if not self.SettlementTip then
        --ugcprint("[MMainUI] 错误：SettlementTip 组件不存在")
        return
    end
    
    self.SettlementTip:SetVisibility(ESlateVisibility.Collapsed)
    --ugcprint("[MMainUI] SettlementTip 匹配提示UI已隐藏")
end

-- ============ 队伍系统UI控制函数 ============

-- 切换队伍界面显示
function MMainUI:ToggleTeam()
    if not self.WB_Team then
        return
    end
    
    if self.WB_Team:GetVisibility() == ESlateVisibility.Collapsed then
        self.WB_Team:SetVisibility(ESlateVisibility.Visible)
        -- 每次打开时刷新玩家槽位
        if self.WB_Team.CreatePlayerSlots then
            self.WB_Team:CreatePlayerSlots()
        end
    else
        self.WB_Team:SetVisibility(ESlateVisibility.Collapsed)
    end
end


return MMainUI