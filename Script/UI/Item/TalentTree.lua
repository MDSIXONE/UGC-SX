---@class TalentTree_C:UUserWidget
---@field Attack UNewButton
---@field canPointcount UTextBlock
---@field HF UNewButton
---@field Hp UNewButton
---@field Hp2 UNewButton
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_8 UImage
---@field introduce_Text UTextBlock
---@field Sikll UNewButton
---@field Speed UNewButton
---@field SS UNewButton
---@field Talent_cancel UButton
---@field Talent_name UTextBlock
---@field Talent_Sure UButton
---@field TalentPoint_Text UTextBlock
---@field YaoShe UNewButton
---@field ZD UNewButton
--Edit Below--
local TalentTree = { bInitDoOnce = false }
-- Related UI logic.
local TALENT_TYPE = {
    NONE = 0,
    HP = 1,           -- 鐢熷懡鍔犳垚 (Hp鎸夐挳)
    ATTACK = 2,       -- 鏀诲嚮鍔犳垚 (Attack鎸夐挳)
    MAGIC = 3,        -- 榄旀硶鍔犳垚 (Hp2鎸夐挳)
    SPEED = 4,        -- 绉婚€熷姞鎴?(Speed鎸夐挳)
    ACCURACY = 5,     -- 鍑嗗害鍔犳垚 (ZD鎸夐挳)
    HIP_FIRE = 6,     -- 鑵板皠鍔犳垚 (YaoShe鎸夐挳)
    SKILL_HASTE = 7,  -- 鎶€鑳芥€ラ€?(Sikll鎸夐挳)
    HP_REGEN = 8,     -- 鐢熷懡鎭㈠ (HF鎸夐挳)
    FIRE_RATE = 9,    -- 灏勯€熷姞鎴?(SS鎸夐挳)
}
-- Related UI logic.
-- Related UI logic.
local TALENT_CONFIG = {
    [TALENT_TYPE.HP] = {
        name = "鐢熷懡鍔犳垚",
        cost = 1,
        maxLevel = 1000,
        desc = "姣忔鍗囩骇澧炲姞鏈€澶х敓鍛?%",
        dataField = "PlayerTalent1",
    },
    [TALENT_TYPE.ATTACK] = {
        name = "鏀诲嚮鍔犳垚",
        cost = 1,
        maxLevel = 1000,
        desc = "姣忔鍗囩骇澧炲姞鏈€澶ф敾鍑?%",
        dataField = "PlayerTalent2",
    },
    [TALENT_TYPE.MAGIC] = {
        name = "榄旀硶鍔犳垚",
        cost = 1,
        maxLevel = 1000,
        desc = "姣忔鍗囩骇澧炲姞鏈€澶ч瓟娉?%",
        dataField = "PlayerTalent3",
    },
    [TALENT_TYPE.SPEED] = {
        name = "绉婚€熷姞鎴?,
        cost = 3,
        maxLevel = 50,
        desc = "姣忔鍗囩骇澧炲姞1%绉诲姩閫熷害",
        dataField = "PlayerTalent4",
    },
    [TALENT_TYPE.ACCURACY] = {
        name = "鍑嗗害鍔犳垚",
        cost = 3,
        maxLevel = 100,
        desc = "姣忔鍗囩骇姘村钩銆佸瀭鐩村悗鍧愬姏-0.01",
        dataField = "PlayerTalent5",
    },
    [TALENT_TYPE.HIP_FIRE] = {
        name = "鑵板皠鍔犳垚",
        cost = 3,
        maxLevel = 100,
        desc = "姣忔鍗囩骇杩炲彂鏁ｅ皠-0.01",
        dataField = "PlayerTalent6",
    },
    [TALENT_TYPE.SKILL_HASTE] = {
        name = "鎶€鑳芥€ラ€?,
        cost = 5,
        maxLevel = 100,
        desc = "姣忔鍗囩骇鎶€鑳芥€ラ€?0.01",
        dataField = "PlayerTalent7",
    },
    [TALENT_TYPE.HP_REGEN] = {
        name = "鐢熷懡鎭㈠",
        cost = 5,
        maxLevel = 100,
        desc = "姣忔鍗囩骇姣忕鎭㈠鏈€澶х敓鍛?.001",
        dataField = "PlayerTalent8",
    },
    [TALENT_TYPE.FIRE_RATE] = {
        name = "灏勯€熷姞鎴?,
        cost = 5,
        maxLevel = 50,
        desc = "姣忔鍗囩骇灏勫嚮闂撮殧-0.01",
        dataField = "PlayerTalent9",
    },
}
function TalentTree:Construct()
    self:LuaInit()
end
function TalentTree:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    -- Log this action.
    
    -- Related UI logic.
    
    -- Related UI logic.
    self:HideDetailControls()
    
    -- Related UI logic.
    -- Related UI logic.
    if self.Hp then
        self.Hp.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.HP) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.Attack then
        self.Attack.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.ATTACK) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.Hp2 then
        self.Hp2.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.MAGIC) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.Speed then
        self.Speed.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.SPEED) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.ZD then
        self.ZD.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.ACCURACY) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.YaoShe then
        self.YaoShe.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.HIP_FIRE) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.Sikll then
        self.Sikll.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.SKILL_HASTE) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.HF then
        self.HF.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.HP_REGEN) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    if self.SS then
        self.SS.OnClicked:Add(function() self:OnTalentClicked(TALENT_TYPE.FIRE_RATE) end, self)
        -- Log this action.
    end
    
    -- Related UI logic.
        self.Talent_Sure.OnClicked:Add(self.OnSureClicked, self)
        -- Log this action.
    end
    if self.Talent_cancel then
        self.Talent_cancel.OnClicked:Add(self.OnCancelClicked, self)
        -- Log this action.
    end
    
    -- Related UI logic.
    
    -- Log this action.
end
-- Related UI logic.
function TalentTree:HideDetailControls()
    if self.Talent_name then
        self.Talent_name:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.introduce_Text then
        self.introduce_Text:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.introduce then
        self.introduce:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.Talent_Sure then
        self.Talent_Sure:SetVisibility(ESlateVisibility.Collapsed)
    end
    if self.canPointcount then
        self.canPointcount:SetVisibility(ESlateVisibility.Collapsed)
    end
end
-- Related UI logic.
function TalentTree:ShowDetailControls(talentType)
    local config = TALENT_CONFIG[talentType]
    if not config then return end
    
    -- Related UI logic.
    if self.Talent_name then
        self.Talent_name:SetText(config.name)
        self.Talent_name:SetVisibility(ESlateVisibility.Visible)
    end
    
    if self.introduce_Text then
        local costText = "闇€瑕? .. config.cost .. "鐐瑰ぉ璧嬬偣鍗囩骇\n" .. config.desc
        self.introduce_Text:SetText(costText)
        self.introduce_Text:SetVisibility(ESlateVisibility.Visible)
    end
    if self.introduce then
        self.introduce:SetVisibility(ESlateVisibility.Visible)
    end
    if self.Talent_Sure then
        self.Talent_Sure:SetVisibility(ESlateVisibility.Visible)
    end
    -- Related UI logic.
        local currentLevel = self:GetTalentLevel(talentType)
        self.canPointcount:SetText("褰撳墠绛夌骇: " .. currentLevel .. "/" .. config.maxLevel)
        self.canPointcount:SetVisibility(ESlateVisibility.Visible)
    end
end
-- Related UI logic.
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        if playerState.GameData and playerState.GameData.PlayerTalentPoints ~= nil then
            return playerState.GameData.PlayerTalentPoints
        elseif playerState.UGCPlayerTalentPoints ~= nil then
            return playerState.UGCPlayerTalentPoints
        end
    end
    return 0
end
-- Related UI logic.
    local config = TALENT_CONFIG[talentType]
    if not config then return 0 end
    
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState and playerState.GameData then
        return playerState.GameData[config.dataField] or 0
    end
    return 0
end
-- Related UI logic.
    if self.TalentPoint_Text then
        local points = self:GetRemainingTalentPoints()
        self.TalentPoint_Text:SetText("鍓╀綑澶╄祴鐐? " .. tostring(points))
    end
end
-- Related UI logic.
function TalentTree:OnTalentClicked(talentType)
    local config = TALENT_CONFIG[talentType]
    if config then
        -- Log this action.
    end
    self:ToggleTalentDetail(talentType)
end
-- Related UI logic.
function TalentTree:ToggleTalentDetail(talentType)
    if self.CurrentTalentType == talentType then
        -- Related UI logic.
        self:HideDetailControls()
        self.CurrentTalentType = TALENT_TYPE.NONE
        -- Log this action.
    else
        -- Related UI logic.
        self:HideDetailControls()
        self.CurrentTalentType = talentType
        self:ShowDetailControls(talentType)
        local config = TALENT_CONFIG[talentType]
        if config then
            -- Log this action.
        end
    end
end
-- Related UI logic.
function TalentTree:OnSureClicked()
    -- Log this action.
    
    if self.CurrentTalentType == TALENT_TYPE.NONE then
        -- Log this action.
        return
    end
    
    local config = TALENT_CONFIG[self.CurrentTalentType]
    if not config then
        -- Log this action.
        return
    end
    
    -- Log this action.
    -- Log this action.
    
    -- Related UI logic.
    local remainingPoints = self:GetRemainingTalentPoints()
    -- Log this action.
    if remainingPoints < config.cost then
        -- Log this action.
        return
    end
    
    -- Related UI logic.
    local currentLevel = self:GetTalentLevel(self.CurrentTalentType)
    -- Log this action.
    if currentLevel >= config.maxLevel then
        -- Log this action.
        return
    end
    
    -- Related UI logic.
    -- Log this action.
    if playerState then
        -- Log this action.
        UnrealNetwork.CallUnrealRPC(
            playerState,
            playerState,
            "Server_AddTalentPointNew",
            self.CurrentTalentType
        )
        -- Log this action.
    else
        -- Log this action.
    end
    
    -- Log this action.
end
-- Related UI logic.
function TalentTree:OnCancelClicked()
    -- Log this action.
    self:SetVisibility(ESlateVisibility.Collapsed)
    self:HideDetailControls()
    self.CurrentTalentType = TALENT_TYPE.NONE
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
-- Related UI logic.
function TalentTree:RefreshUI()
    self:UpdateTalentPointText()
    -- Related UI logic.
        self:ShowDetailControls(self.CurrentTalentType)
    end
end
return TalentTree
