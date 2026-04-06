---@class chuansong_2_C:UUserWidget
---@field CanvasPanel_0 UCanvasPanel
---@field fuben1 UButton
---@field fuben1_Text UTextBlock
---@field fuben2 UButton
---@field fuben2_Text UTextBlock
---@field fuben3 UButton
---@field fuben3_Text UTextBlock
---@field fuben4 UButton
---@field fuben4_Text UTextBlock
---@field HorizontalBox_135 UHorizontalBox
---@field Image_53 UImage
---@field Image_54 UImage
---@field Image_55 UImage
---@field Image_56 UImage
---@field ImageEx_25 UImageEx
---@field Zhuansheng_cancel UButton
--Edit Below--
local chuansong = { bInitDoOnce = false }

-- Hide all buttons.
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
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Collapsed) end
	if self.Zhuansheng_cancel then self.Zhuansheng_cancel:SetVisibility(ESlateVisibility.Collapsed) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Collapsed) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Collapsed) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Collapsed) end
end

-- Show all buttons.
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
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Visible) end
	if self.Zhuansheng_cancel then self.Zhuansheng_cancel:SetVisibility(ESlateVisibility.Visible) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Visible) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Visible) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Visible) end
end

function chuansong:Construct()
	self:LuaInit();
	-- Execute the next UI update step.
	self:HideAllButtons()
end

-- function chuansong:Tick(MyGeometry, InDeltaTime)
-- end

-- function chuansong:Destruct()
-- end

-- [Editor Generated Lua] function define Begin:
function chuansong:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	if self.fuben1 then self.fuben1.OnClicked:Add(self.fuben1_OnClicked, self) end
	if self.fuben2 then self.fuben2.OnClicked:Add(self.fuben2_OnClicked, self) end
	if self.fuben3 then self.fuben3.OnClicked:Add(self.fuben3_OnClicked, self) end
	if self.fuben4 then self.fuben4.OnClicked:Add(self.fuben4_OnClicked, self) end
	if self.fuben5 then self.fuben5.OnClicked:Add(self.fuben5_OnClicked, self) end
	if self.fuben6 then self.fuben6.OnClicked:Add(self.fuben6_OnClicked, self) end
	-- Guard condition before running this branch.
	if self.Zhuansheng_cancel then
		self.Zhuansheng_cancel.OnClicked:Add(self.Zhuansheng_cancel_OnClicked, self)
	end
	-- [Editor Generated Lua] BindingEvent End;
end

-- Widget member function definition.
-- Widget member function definition.
-- Widget member function definition.
-- Widget member function definition.
-- Teleport to location.
function chuansong:TeleportToLocation(x, y, z, yaw)
    -- Keep this section consistent with the original UI flow.
    -- Keep this section consistent with the original UI flow.
    
    local ok, err = pcall(function()
        -- Acquire local player references.
        local PlayerController = UGCGameSystem.GetLocalPlayerController()
        if not PlayerController then
            -- Exit early when requirements are not met.
            return
        end
        
        -- Guard condition before running this branch.
        -- Guard condition before running this branch.
        if yaw then
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z, yaw)
        else
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z)
        end
        -- Keep this section consistent with the original UI flow.
    end)
    
    if not ok then
        -- Keep this section consistent with the original UI flow.
    end
    
    -- Execute the next UI update step.
    self:HideAllButtons()
    
    -- Acquire local player references.
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun_2 then
        pc.MMainUI.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
    end
end

-- Get player rebirth count.
function chuansong:GetPlayerRebirthCount()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if ps then
            -- Exit early when requirements are not met.
            return ps.UGCPlayerRebirthCount or (ps.GameData and ps.GameData.PlayerRebirthCount) or 0
        end
    end
    return 0
end

-- Check rebirth requirement.
function chuansong:CheckRebirthRequirement(requiredRebirth, fubenName)
    local rebirthCount = self:GetPlayerRebirthCount()
    if rebirthCount < requiredRebirth then
        -- Acquire local player references.
        -- Acquire local player references.
        local pc = UGCGameSystem.GetLocalPlayerController()
        if pc and pc.MMainUI and pc.MMainUI.ShowTip then
            pc.MMainUI:ShowTip("转生次数不足，无法传送到该副本。")
        end
        return false
    end
    return true
end

function chuansong:fuben1_OnClicked()
    -- Guard condition before running this branch.
    -- Guard condition before running this branch.
    if not self:CheckRebirthRequirement(1, "fuben1") then
        return
    end
    self:TeleportToLocation(19036.871094, 50498.203125, 621.236023, 90)
end

function chuansong:fuben2_OnClicked()
    -- Guard condition before running this branch.
    -- Guard condition before running this branch.
    if not self:CheckRebirthRequirement(2, "fuben2") then
        return
    end
    self:TeleportToLocation(141600.15625, -7472.247559, 287.76004, 90)
end

function chuansong:fuben3_OnClicked()
    -- Guard condition before running this branch.
    -- Guard condition before running this branch.
    if not self:CheckRebirthRequirement(3, "fuben3") then
        return
    end
    self:TeleportToLocation(61460.460938, 10271.99707, 1646.93457, 90)
end

function chuansong:fuben4_OnClicked()
    -- Guard condition before running this branch.
    -- Guard condition before running this branch.
    if not self:CheckRebirthRequirement(4, "fuben4") then
        return
    end
    self:TeleportToLocation(42936.683594, 135209.75, 15358.039062, 90)
end

function chuansong:fuben5_OnClicked()
    self:TeleportToLocation(18670.0, 24520.0, 200.0, 90)
end

function chuansong:fuben6_OnClicked()
    self:TeleportToLocation(18670.0, 24520.0, 200.0)
end

-- Zhuansheng cancel on clicked.
function chuansong:Zhuansheng_cancel_OnClicked()
	-- Execute the next UI update step.
	-- Execute the next UI update step.
	self:HideAllButtons()

	-- Acquire local player references.
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun_2 then
		-- Configure initial widget visibility.
		pc.MMainUI.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
	else
		-- Keep this section consistent with the original UI flow.
	end
end

-- [Editor Generated Lua] function define End;

return chuansong
