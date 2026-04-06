---@class chuansong_C:UUserWidget
---@field CanvasPanel_0 UCanvasPanel
---@field fuben1 UButton
---@field fuben1_Text UTextBlock
---@field fuben2 UButton
---@field fuben2_Text UTextBlock
---@field fuben3 UButton
---@field fuben3_Text UTextBlock
---@field fuben4 UButton
---@field fuben4_Text UTextBlock
---@field fuben5 UButton
---@field fuben5_Text UTextBlock
---@field fuben6 UButton
---@field fuben6_Text UTextBlock
---@field fuben_cansel General_SecondLevelButton_3_C
---@field Image_1 UImage
---@field ImageEx_25 UImageEx
--Edit Below--
local chuansong = { bInitDoOnce = false, bFullScreenActive = false }

-- Related UI logic.
function chuansong:HideAllButtons()
	if self.fuben1 then self.fuben1:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben1_Text then self.fuben1_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben2 then self.fuben2:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben2_Text then self.fuben2_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben3 then self.fuben3:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben3_Text then self.fuben3_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben4 then self.fuben4:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben4_Text then self.fuben4_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben5 then self.fuben5:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben5_Text then self.fuben5_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben6_Text then self.fuben6_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben_cansel then self.fuben_cansel:SetVisibility(ESlateVisibility.Collapsed) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Collapsed) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Collapsed) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Collapsed) end
end

-- Related UI logic.
function chuansong:ShowAllButtons()
	if self.fuben1 then self.fuben1:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben1_Text then self.fuben1_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben2 then self.fuben2:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben2_Text then self.fuben2_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben3 then self.fuben3:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben3_Text then self.fuben3_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben4 then self.fuben4:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben4_Text then self.fuben4_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben5 then self.fuben5:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben5_Text then self.fuben5_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben6_Text then self.fuben6_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben_cansel then self.fuben_cansel:SetVisibility(ESlateVisibility.Visible) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Visible) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Visible) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Visible) end
    self:EnterFullScreen()
end

-- Related UI logic.
function chuansong:EnterFullScreen()
    if self.bFullScreenActive then
        return
    end
    self.bFullScreenActive = true

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

-- Related UI logic.
function chuansong:ExitFullScreen()
    if not self.bFullScreenActive then
        return
    end
    self.bFullScreenActive = false

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

function chuansong:Construct()
	self:LuaInit();
	-- Related UI logic.
	self:HideAllButtons()
end

-- function chuansong:Tick(MyGeometry, InDeltaTime)
-- end

function chuansong:Destruct()
	self:ExitFullScreen()
end

-- [Editor Generated Lua] function define Begin:
function chuansong:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	self.fuben1.OnClicked:Add(self.fuben1_OnClicked, self);
	self.fuben2.OnClicked:Add(self.fuben2_OnClicked, self);
	self.fuben3.OnClicked:Add(self.fuben3_OnClicked, self);
	self.fuben4.OnClicked:Add(self.fuben4_OnClicked, self);
	self.fuben5.OnClicked:Add(self.fuben5_OnClicked, self);
	self.fuben6.OnClicked:Add(self.fuben6_OnClicked, self);
	-- Related UI logic.
	if self.fuben_cansel then
		self.fuben_cansel.Button_Levels2_3.OnClicked:Add(self.fuben_cancel_OnClicked, self);
	end
	-- [Editor Generated Lua] BindingEvent End;
end

-- Related UI logic.
-- Related UI logic.
-- Related UI logic.
-- Related UI logic.
-- Related UI logic.
function chuansong:TeleportToLocation(x, y, z, yaw)
    -- Log this action.
    -- Log this action.
    
    local ok, err = pcall(function()
        -- Related UI logic.
        local PlayerController = UGCGameSystem.GetLocalPlayerController()
        if not PlayerController then
            -- Log this action.
            return
        end
        
        -- Related UI logic.
        -- Log this action.
        if yaw then
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z, yaw)
        else
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z)
        end
        -- Log this action.
    end)
    
    if not ok then
        -- Log this action.
    end
    
    -- Related UI logic.
    self:HideAllButtons()
    self:ExitFullScreen()
    
    -- Related UI logic.
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun then
        pc.MMainUI.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
    end
end

-- Related UI logic.
function chuansong:ShowTip(text)
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.ShowTip then
        pc.MMainUI:ShowTip(text)
    end
end

-- Related UI logic.
function chuansong:GetPlayerRebirthCount()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if ps then
            return ps.UGCPlayerRebirthCount or (ps.GameData and ps.GameData.PlayerRebirthCount) or 0
        end
    end
    return 0
end

-- Related UI logic.
function chuansong:GetPlayerLevel()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if ps then
            return ps.UGCPlayerLevel or (ps.GameData and ps.GameData.PlayerLevel) or 1
        end
    end
    return 1
end

-- Related UI logic.
function chuansong:CheckRequirement(requiredRebirth, requiredLevel)
    local rebirthCount = self:GetPlayerRebirthCount()
    if rebirthCount < requiredRebirth then
		self:ShowTip("转生次数不足，需要转生" .. requiredRebirth .. "次")
        return false
    end
    local level = self:GetPlayerLevel()
    if level < requiredLevel then
		self:ShowTip("等级不足，需要" .. requiredLevel .. "级")
        return false
    end
    return true
end

function chuansong:fuben1_OnClicked()
    if not self:CheckRequirement(0, 1) then return end
    self:TeleportToLocation(181548.640625, 123572.679688, 523.233398, 180)
end

function chuansong:fuben2_OnClicked()
    if not self:CheckRequirement(1, 50) then return end
    self:TeleportToLocation(19060.339844, 45293.621094, 1091.622925, 270)
end

function chuansong:fuben3_OnClicked()
    if not self:CheckRequirement(2, 100) then return end
    self:TeleportToLocation(145806.609375, -7294.645508, 373.386414, 360)
end

function chuansong:fuben4_OnClicked()
    if not self:CheckRequirement(3, 200) then return end
    self:TeleportToLocation(50184.515625, 130875.375, 239.292038, 180)
end

function chuansong:fuben5_OnClicked()
    if not self:CheckRequirement(4, 350) then return end
    self:TeleportToLocation(87271.648438, 68284.21875, 271.10553, 270)
end

function chuansong:fuben6_OnClicked()
    if not self:CheckRequirement(5, 500) then return end
    -- self:TeleportToLocation(18670.0, 24520.0, 200.0)
end

-- Related UI logic.
function chuansong:fuben_cancel_OnClicked()
	-- Log this action.
	-- Related UI logic.
	self:HideAllButtons()
    self:ExitFullScreen()
	
	-- Related UI logic.
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun then
		-- Log this action.
		pc.MMainUI.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
	else
		-- Log this action.
	end
end

-- [Editor Generated Lua] function define End;

return chuansong
