---@class jiange_C:UUserWidget
---@field cancel UButton
---@field duanzhaoshi UImage
---@field Image_0 UImage
---@field Image_1 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_8 UImage
---@field Image_9 UImage
---@field Image_10 UImage
---@field Image_11 UImage
---@field Image_12 UImage
---@field levelup UButton
---@field name UTextBlock
---@field ProgressBar_level UProgressBar
---@field TextBlock_current UTextBlock
---@field TextBlock_detail UTextBlock
---@field TextBlock_need UTextBlock
---@field TextBlock_skill UTextBlock
---@field wear UButton
---@field weartip UTextBlock
--Edit Below--
local jiange = { bInitDoOnce = false }

-- Configuration table used by this widget.
local SWORD_LEVELS = {
    {
        name = "啸月寒锋",
        skill = "bailangjian",
        icon = "bailangjian",
        atkPercent = 100,
        upgradeCost = 1,
        detail = "神剑攻击提升100%",
        skillDesc = "释放寒霜剑气，造成范围伤害并提升神剑攻击100%。",
    },
    {
        name = "幽冥毒剑",
        skill = "kuishejian",
        icon = "kuishejian",
        atkPercent = 200,
        upgradeCost = 2,
        detail = "神剑攻击提升200%",
        skillDesc = "释放毒雾剑气，持续伤害周围目标并提升神剑攻击200%。",
    },
    {
        name = "白虎霜魄剑",
        skill = "baihujian",
        icon = "baihujian",
        atkPercent = 200,
        upgradeCost = 3,
        detail = "神剑攻击提升200%",
        skillDesc = "召唤白虎剑魂冲锋，命中造成高额伤害并提升神剑攻击200%。",
    },
    {
        name = "白泽破邪剑",
        skill = "bifangjian",
        icon = "baizejian",
        atkPercent = 300,
        upgradeCost = 4,
        detail = "神剑攻击提升300%",
        skillDesc = "引导白泽之力斩击前方，造成范围伤害并提升神剑攻击300%。",
    },
    {
        name = "麒麟镇天剑",
        skill = "qilingjian",
        icon = "qilingjian",
        atkPercent = 400,
        upgradeCost = 5,
        detail = "神剑攻击提升400%",
        skillDesc = "麒麟剑气震地，对周围敌人造成伤害并提升神剑攻击400%。",
    },
    {
        name = "凤凰涅槃剑",
        skill = "zhuquejian",
        icon = "fenhuanjian",
        atkPercent = 500,
        upgradeCost = 10,
        detail = "神剑攻击提升500%",
        skillDesc = "凤凰火羽剑雨，造成持续灼烧伤害并提升神剑攻击500%。",
    },
    {
        name = "神龙苍穹剑",
        skill = "shenlongjian",
        icon = "shenlongjian",
        atkPercent = 1000,
        upgradeCost = 0,
        detail = "神剑攻击提升1000%",
        skillDesc = "神龙天降剑阵，造成巨额范围伤害并提升神剑攻击1000%。",
    },
}
local MAX_LEVEL = #SWORD_LEVELS
local FORGE_COUNT_SYNC_LOCK_SECONDS = 0.9

function jiange:Construct()
    self:LuaInit()
    self.CurrentLevel = 1
    self.UpgradeProgress = 0 -- 
    self.IsWearing = false
    self.ForgeConsumePending = false
    self.ForgeCountSyncLocked = false
    self.ForgeCountSyncValue = nil
    self.ForgeCountSyncLockVersion = 0

    -- Acquire local player references.
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.SavedJiangeLevel then
        self.CurrentLevel = PC.SavedJiangeLevel or 1
        self.UpgradeProgress = PC.SavedJiangeProgress or 0
        -- Keep this section consistent with the original UI flow.
    end

    if self.weartip then self.weartip:SetText("穿戴") end
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()
    self:UpdateCostDisplay()
    self:RefreshCostDisplayDelayed(0.2)
    self:SetVisibility(1)
end

function jiange:Show()
    self:SetVisibility(0)
    self:UpdateCostDisplay()
    self:RefreshCostDisplayDelayed(0.2)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end
end

function jiange:OnCancelClicked()
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end
    self:SetVisibility(2)
end

function jiange:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.wear then self.wear.OnClicked:Add(self.OnWearClicked, self) end
    if self.levelup then self.levelup.OnClicked:Add(self.OnLevelUpClicked, self) end
    if self.cancel then self.cancel.OnClicked:Add(self.OnCancelClicked, self) end
end

function jiange:GetSkillPath(level)
    local cfg = SWORD_LEVELS[level]
    if not cfg then return nil end
    return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. cfg.skill .. '.' .. cfg.skill .. '_C')
end

function jiange:GetIconPath(level)
    local cfg = SWORD_LEVELS[level]
    if not cfg then return nil end
    return UGCGameSystem.GetUGCResourcesFullPath('PNG/shenjian/' .. cfg.icon .. '.' .. cfg.icon)
end

-- Update sword display.
function jiange:UpdateSwordDisplay()
    local cfg = SWORD_LEVELS[self.CurrentLevel]
    if not cfg then return end

    if self.Image_2 then
        local iconPath = self:GetIconPath(self.CurrentLevel)
        if iconPath then
            local texture = LoadObject(iconPath)
            if texture then
                self.Image_2:SetBrushFromTexture(texture)
            end
        end
    end

    if self.name then
        self.name:SetText(cfg.name)
    end
    if self.TextBlock_detail then
        self.TextBlock_detail:SetText(cfg.detail)
    end
    if self.TextBlock_skill then
        self.TextBlock_skill:SetText(cfg.skillDesc)
    end
end

function jiange:UpdateProgressBar()
    if self.ProgressBar_level then
        self.ProgressBar_level:SetPercent(self.UpgradeProgress / 100)
    end
end

-- Get forge stone count.
function jiange:GetForgeStoneCount()
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VIM then
        return 0
    end

    local PC = UGCGameSystem.GetLocalPlayerController()
    local count = 0
    if PC then
        count = VIM:GetItemNum(5666, PC) or 0
    else
        count = VIM:GetItemNum(5666) or 0
    end

    return tonumber(count) or 0
end

-- Update cost display.
function jiange:UpdateCostDisplay()
    -- Guard condition before running this branch.
    if self.TextBlock_current then
        local count = nil
        if self.ForgeCountSyncLocked and self.ForgeCountSyncValue ~= nil then
            count = self.ForgeCountSyncValue
        else
            count = self:GetForgeStoneCount()
        end
        self.TextBlock_current:SetText(tostring(count))
    end

    -- Guard condition before running this branch.
    if self.TextBlock_need then
        if self.CurrentLevel < MAX_LEVEL then
            self.TextBlock_need:SetText("1")
        else
            self.TextBlock_need:SetText("--")
        end
    end
end

function jiange:LockForgeCountDisplay(remainCount, lockSeconds)
    local normalizedCount = math.max(0, math.floor(tonumber(remainCount) or 0))
    self.ForgeCountSyncLocked = true
    self.ForgeCountSyncValue = normalizedCount
    self.ForgeCountSyncLockVersion = (self.ForgeCountSyncLockVersion or 0) + 1
    local lockVersion = self.ForgeCountSyncLockVersion

    if self.TextBlock_current then
        self.TextBlock_current:SetText(tostring(normalizedCount))
    end

    UGCGameSystem.SetTimer(self, function()
        if not self then
            return
        end

        if self.ForgeCountSyncLockVersion ~= lockVersion then
            return
        end

        self.ForgeCountSyncLocked = false
        self.ForgeCountSyncValue = nil
        if self.UpdateCostDisplay then
            self:UpdateCostDisplay()
        end
    end, lockSeconds or FORGE_COUNT_SYNC_LOCK_SECONDS, false)
end

function jiange:RefreshCostDisplayDelayed(delay)
    UGCGameSystem.SetTimer(self, function()
        if self and self.UpdateCostDisplay then
            self:UpdateCostDisplay()
        end
    end, delay or 0.2, false)
end

function jiange:SetForgeConsumePending(pending)
    self.ForgeConsumePending = (pending == true)
    if self.levelup and self.levelup.SetIsEnabled then
        self.levelup:SetIsEnabled(not self.ForgeConsumePending)
    end
end

function jiange:ApplyForgeProgress()
    -- Local helper value for this logic block.
    local addTenths = math.random(1, 10) -- Generate random value.
    self.UpgradeProgress = self.UpgradeProgress + addTenths / 10

    local tipText = string.format("锻造进度 +%.1f%%", addTenths / 10)

    -- Guard condition before running this branch.
    if self.UpgradeProgress >= 100 then
        self.UpgradeProgress = 0

        local wasWearing = self.IsWearing
        self.CurrentLevel = self.CurrentLevel + 1

        self:UpdateSwordDisplay()

        if wasWearing then
            self:ApplySkill(true)
            self:ApplyAtkBonus(true)
        end

        tipText = "神剑升级成功"
    end

    self:UpdateProgressBar()
    self:SaveToServer()
    self:ShowTipViaMain(tipText)
end

function jiange:OnForgeConsumeResult(success, remainCount, tipText)
    self:SetForgeConsumePending(false)

    if remainCount ~= nil then
        self:LockForgeCountDisplay(remainCount)
    end

    if not success then
        if tipText and tipText ~= "" then
            self:ShowTipViaMain(tipText)
        else
            self:ShowTipViaMain("锻造失败，请检查材料数量")
        end
        self:RefreshCostDisplayDelayed(0.2)
        return
    end

    self:ApplyForgeProgress()
end

function jiange:ApplySkill(isWear)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local skillPath = self:GetSkillPath(self.CurrentLevel)
    if not skillPath then return end
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetJiangeSkill", skillPath, isWear)
end

-- Apply atk bonus.
function jiange:ApplyAtkBonus(isWear)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local cfg = SWORD_LEVELS[self.CurrentLevel]
    local bonus = 0
    if isWear and cfg then
        bonus = cfg.atkPercent
    end
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetJiangeAtkBonus", bonus)
end

function jiange:OnWearClicked()
    if self.IsWearing then
        self:ApplySkill(false)
        self:ApplyAtkBonus(false)
        self.IsWearing = false
        if self.weartip then self.weartip:SetText("穿戴") end
        self:ShowTipViaMain("已卸下神剑")
    else
        self:ApplySkill(true)
        self:ApplyAtkBonus(true)
        self.IsWearing = true
        if self.weartip then self.weartip:SetText("卸下") end
        self:ShowTipViaMain("已穿戴神剑")
    end
end

function jiange:OnLevelUpClicked()
    if self.CurrentLevel >= MAX_LEVEL then return end
    if self.ForgeConsumePending then
        self:ShowTipViaMain("消耗处理中，请稍后")
        return
    end

    -- Local helper value for this logic block.
    local cost = 1

    -- Local helper value for this logic block.
    local count = self:GetForgeStoneCount()
    -- Guard condition before running this branch.
    if count < cost then
        self:ShowTipViaMain("锻造石不足，无法升级")
        return
    end

    -- Local helper value for this logic block.
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then
        self:ShowTipViaMain("无法获取玩家状态")
        return
    end

    self:SetForgeConsumePending(true)
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_RemoveVirtualItem", 5666, cost)

    -- Delay execution until dependent data is ready.
    UGCGameSystem.SetTimer(self, function()
        if self and self.ForgeConsumePending then
            self:SetForgeConsumePending(false)
            self:UpdateCostDisplay()
        end
    end, 1.2, false)
end

function jiange:ShowTipViaMain(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end

function jiange:Destruct()
end

-- Load saved data.
function jiange:LoadSavedData(level, progress)
    local incomingLevel = math.floor(tonumber(level) or 1)
    local incomingProgress = tonumber(progress) or 0
    incomingProgress = math.max(0, math.min(100, incomingProgress))

    -- Ignore stale same-level progress sync to avoid immediate rollback.
    if self.CurrentLevel and self.UpgradeProgress then
        if incomingLevel < self.CurrentLevel then
            return
        end
        if incomingLevel == self.CurrentLevel and incomingProgress + 0.05 < self.UpgradeProgress then
            return
        end
    end

    self.CurrentLevel = incomingLevel
    self.UpgradeProgress = incomingProgress
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()
    self:UpdateCostDisplay()
end

-- Save to server.
function jiange:SaveToServer()
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SaveJiangeData", self.CurrentLevel, self.UpgradeProgress)
    end
end

return jiange
