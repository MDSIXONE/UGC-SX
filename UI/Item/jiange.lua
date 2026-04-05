---@class jiange_C:UUserWidget
---@field cancel UButton
---@field duanzhaoshi UImage
---@field Image_0 UImage
---@field Image_2 UImage
---@field levelup UButton
---@field ProgressBar_level UProgressBar
---@field wear UButton
---@field weartip UTextBlock
--Edit Below--
local jiange = { bInitDoOnce = false }

-- 7级升级路线配置：名字、技能文件名、图片文件名
local SWORD_LEVELS = {
    { name = "啸月寒锋",     skill = "bailangjian",   icon = "bailangjian" },
    { name = "幽冥毒剑",     skill = "kuishejian",    icon = "kuishejian" },
    { name = "白虎霜魄剑",   skill = "baihujian",     icon = "baihujian" },
    { name = "白泽破邪剑",   skill = "bifangjian",    icon = "baizejian" },
    { name = "麒麟镇天剑",   skill = "qilingjian",    icon = "qilingjian" },
    { name = "凤凰涅槃剑",   skill = "zhuquejian",    icon = "fenhuanjian" },
    { name = "神龙苍穹剑",   skill = "shenlongjian",  icon = "shenlongjian" },
}
local MAX_LEVEL = #SWORD_LEVELS

function jiange:Construct()
    self:LuaInit()
    self.CurrentLevel = 1
    self.IsWearing = false

    if self.weartip then self.weartip:SetText("穿戴") end
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()
    self:SetVisibility(1) -- 初始隐藏
end

function jiange:Show()
    self:SetVisibility(0)
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

    if self.wear then
        self.wear.OnClicked:Add(self.OnWearClicked, self)
    end
    if self.levelup then
        self.levelup.OnClicked:Add(self.OnLevelUpClicked, self)
    end
    if self.cancel then
        self.cancel.OnClicked:Add(self.OnCancelClicked, self)
    end
end

-- 获取当前等级的技能路径
function jiange:GetSkillPath(level)
    local cfg = SWORD_LEVELS[level]
    if not cfg then return nil end
    return UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. cfg.skill .. '.' .. cfg.skill .. '_C')
end

-- 获取当前等级的图片路径
function jiange:GetIconPath(level)
    local cfg = SWORD_LEVELS[level]
    if not cfg then return nil end
    return UGCGameSystem.GetUGCResourcesFullPath('PNG/shenjian/' .. cfg.icon .. '.' .. cfg.icon)
end

-- 更新神剑图片和名字显示
function jiange:UpdateSwordDisplay()
    local cfg = SWORD_LEVELS[self.CurrentLevel]
    if not cfg then return end

    -- 更新Image_2显示对应等级的图片
    if self.Image_2 then
        local iconPath = self:GetIconPath(self.CurrentLevel)
        if iconPath then
            local texture = LoadObject(iconPath)
            if texture then
                self.Image_2:SetBrushFromTexture(texture)
            end
        end
    end
end

-- 更新进度条（当前等级 / 最大等级）
function jiange:UpdateProgressBar()
    if self.ProgressBar_level then
        self.ProgressBar_level:SetPercent((self.CurrentLevel - 1) / (MAX_LEVEL - 1))
    end
end

-- 通过RPC在服务端添加/移除神剑技能
function jiange:ApplySkill(isWear)
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if not PlayerState then return end
    local skillPath = self:GetSkillPath(self.CurrentLevel)
    if not skillPath then return end
    ugcprint("[jiange] ApplySkill: level=" .. tostring(self.CurrentLevel) .. ", isWear=" .. tostring(isWear) .. ", path=" .. tostring(skillPath))
    UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_SetJiangeSkill", skillPath, isWear)
end

-- 穿戴/卸下按钮
function jiange:OnWearClicked()
    if self.IsWearing then
        -- 卸下
        self:ApplySkill(false)
        self.IsWearing = false
        if self.weartip then self.weartip:SetText("穿戴") end
    else
        -- 穿戴
        self:ApplySkill(true)
        self.IsWearing = true
        if self.weartip then self.weartip:SetText("卸下") end
    end
end

-- 升级按钮
function jiange:OnLevelUpClicked()
    if self.CurrentLevel >= MAX_LEVEL then return end

    local wasWearing = self.IsWearing

    -- 如果正在穿戴，先移除旧技能（服务端会清除所有神剑技能）
    self.CurrentLevel = self.CurrentLevel + 1

    -- 更新UI
    self:UpdateSwordDisplay()
    self:UpdateProgressBar()

    -- 如果穿戴中，重新应用新等级技能
    if wasWearing then
        self:ApplySkill(true)
    end
end

function jiange:Destruct()
end

return jiange
