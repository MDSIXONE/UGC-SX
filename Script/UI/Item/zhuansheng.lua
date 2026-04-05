---@class zhuansheng_C:UUserWidget
---@field Image_0 UImage
---@field zhuansheng1 UImage
---@field zhuansheng2 UImage
---@field zhuansheng3 UImage
---@field zhuansheng4 UImage
---@field zhuansheng5 UImage
---@field zhuansheng6 UImage
---@field zhuansheng7 UImage
---@field zhuansheng8 UImage
---@field zhuansheng_back UImage
---@field zhuansheng_Button UButton
---@field zhuansheng_cancel UButton
---@field zhuansheng_help UButton
---@field zhuansheng_Text1 UTextBlock
---@field zhuansheng_Text2 UTextBlock
---@field zhuansheng_Tips UTextBlock
--Edit Below--
local zhuansheng = { bInitDoOnce = false }

-- Related UI logic.
local zhuanshengImages = {
	"zhuansheng1", "zhuansheng2", "zhuansheng3", "zhuansheng4",
	"zhuansheng5", "zhuansheng6", "zhuansheng7", "zhuansheng8",
	"zhuansheng9", "zhuansheng10", "zhuansheng11", "zhuansheng12"
} 

-- Related UI logic.
function zhuansheng:HideAllControls()
	if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_back then self.zhuansheng_back:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Button then self.zhuansheng_Button:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Tips then self.zhuansheng_Tips:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_cancel then self.zhuansheng_cancel:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Text2 then self.zhuansheng_Text2:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Text1 then self.zhuansheng_Text1:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_help then self.zhuansheng_help:SetVisibility(ESlateVisibility.Collapsed) end
	-- Related UI logic.
	for _, imageName in ipairs(zhuanshengImages) do
		local imageWidget = self[imageName]
		if imageWidget then
			imageWidget:SetVisibility(ESlateVisibility.Collapsed)
		end
	end
end

-- Related UI logic.
function zhuansheng:ShowAllControls()
	if self.Image_0 then self.Image_0:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_back then self.zhuansheng_back:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Button then self.zhuansheng_Button:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Tips then self.zhuansheng_Tips:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_cancel then self.zhuansheng_cancel:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Text2 then self.zhuansheng_Text2:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Text1 then self.zhuansheng_Text1:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_help then self.zhuansheng_help:SetVisibility(ESlateVisibility.Visible) end
	-- Related UI logic.
	self:UpdateZhuanshengImages()
	-- Related UI logic.
	self:UpdateTipsText()
end

-- Related UI logic.
function zhuansheng:UpdateTipsText()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then return end
	
	if playerState.GetRebirthInfo then
		local rebirthInfo = playerState:GetRebirthInfo()
		if rebirthInfo.canRebirth then
			self.zhuansheng_Tips:SetText("鍙浆鐢?)
		else
			-- Related UI logic.
			local levelOk = rebirthInfo.currentLevel >= rebirthInfo.requiredLevel
			local combatOk = rebirthInfo.currentCombatPower >= rebirthInfo.requiredCombatPower
			
			if not levelOk and not combatOk then
				self.zhuansheng_Tips:SetText("绛夌骇鍜屾垬鏂楀姏鏈揪鍒?)
			elseif not levelOk then
				self.zhuansheng_Tips:SetText("绛夌骇鏈埌杈?)
			else
				self.zhuansheng_Tips:SetText("鎴樻枟鍔涙湭鍒拌揪")
			end
		end
	end
end

function zhuansheng:Construct()
	self:LuaInit();
	-- Related UI logic.
	self:HideAllControls()
end

-- Related UI logic.
function zhuansheng:UpdateZhuanshengImages()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then return end
	
	local rebirthCount = 0
	if playerState.GetRebirthInfo then
		local rebirthInfo = playerState:GetRebirthInfo()
		rebirthCount = rebirthInfo.rebirthCount or 0
	end
	
	-- Related UI logic.
	-- Related UI logic.
	for i, imageName in ipairs(zhuanshengImages) do
		local imageWidget = self[imageName]
		if imageWidget then
			if i <= rebirthCount then
				imageWidget:SetVisibility(ESlateVisibility.Visible)
			else
				imageWidget:SetVisibility(ESlateVisibility.Collapsed)
			end
		end
	end
end




-- function zhuansheng:Tick(MyGeometry, InDeltaTime)

-- end

-- function zhuansheng:Destruct()

-- end

-- [Editor Generated Lua] function define Begin:
function zhuansheng:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	self.zhuansheng_Text2:BindingProperty("Text", self.zhuansheng_Text2_Text, self);
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	self.zhuansheng_Button.OnClicked:Add(self.zhuansheng_Button_OnClicked, self);
	-- Related UI logic.
	if self.zhuansheng_cancel then
		self.zhuansheng_cancel.OnClicked:Add(self.zhuansheng_cancel_OnClicked, self);
	end
	-- Related UI logic.
	if self.zhuansheng_help then
		self.zhuansheng_help.OnClicked:Add(self.zhuansheng_help_OnClicked, self);
	end
	-- [Editor Generated Lua] BindingEvent End;
end

function zhuansheng:zhuansheng_Text2_Text(ReturnValue)
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then
		return "鑾峰彇鐜╁鐘舵€佸け璐?
	end
	
	-- Related UI logic.
	if playerState.GetRebirthInfo then
		local rebirthInfo = playerState:GetRebirthInfo()
		
		-- Related UI logic.
		if rebirthInfo.rebirthCount >= rebirthInfo.maxRebirthCount then
			return "宸茶揪鍒版渶澶ц浆鐢熸鏁?" .. rebirthInfo.maxRebirthCount .. "娆?"
		end
		
		-- Related UI logic.
		local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
		
		-- Related UI logic.
		local levelOk = rebirthInfo.currentLevel >= rebirthInfo.requiredLevel
		local combatOk = rebirthInfo.currentCombatPower >= rebirthInfo.requiredCombatPower
		
		if not levelOk or not combatOk then
			local text = ""
			if not levelOk then
				text = "绛夌骇杈惧埌" .. rebirthInfo.requiredLevel .. "绾?(褰撳墠" .. rebirthInfo.currentLevel .. "绾?"
			end
			if not combatOk then
				if text ~= "" then text = text .. "\n" end
				text = text .. "鎴樻枟鍔涜揪鍒? .. UGCGameData.FormatNumber(rebirthInfo.requiredCombatPower) .. " (褰撳墠" .. UGCGameData.FormatNumber(rebirthInfo.currentCombatPower) .. ")"
			end
			return text
		end
		
		return "鍙互杞敓 (绗? .. (rebirthInfo.rebirthCount + 1) .. "娆?"
	else
		-- Related UI logic.
		return "鑾峰彇杞敓淇℃伅澶辫触"
	end
end

function zhuansheng:zhuansheng_Button_OnClicked()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then
		-- Log this action.
		return
	end
	
	-- Related UI logic.
	local canRebirth, reason = playerState:CanRebirth()
	if not canRebirth then
		-- Log this action.
		return
	end
	
	-- Related UI logic.
	local pc = UGCGameSystem.GetPlayerControllerByPlayerState(playerState)
	if pc then
		-- Related UI logic.
		local currentRebirthCount = 0
		if playerState.GetRebirthInfo then
			local rebirthInfo = playerState:GetRebirthInfo()
			currentRebirthCount = rebirthInfo.rebirthCount or 0
		end

		UnrealNetwork.CallUnrealRPC(
			playerState,
			playerState,
			"Server_Rebirth"
		)
		-- Log this action.

		-- Related UI logic.
		-- Related UI logic.
		local nextImageIndex = currentRebirthCount + 1
		local nextImageName = zhuanshengImages[nextImageIndex]
		-- Log this action.
		if nextImageName then
			local imageWidget = self[nextImageName]
			if imageWidget then
				imageWidget:SetVisibility(ESlateVisibility.Visible)
				-- Log this action.
			else
				-- Log this action.
			end
		else
			-- Log this action.
		end
	else
		-- Log this action.
	end
end

-- Related UI logic.
function zhuansheng:zhuansheng_cancel_OnClicked()
	-- Log this action.
	-- Related UI logic.
	self:HideAllControls()
	
	-- Related UI logic.
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.zhuanshengbuttun then
		-- Log this action.
		pc.MMainUI.zhuanshengbuttun:SetVisibility(ESlateVisibility.Visible)
	else
		-- Log this action.
	end
end

-- Related UI logic.
function zhuansheng:zhuansheng_help_OnClicked()
	-- Log this action.
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.help then
		pc.MMainUI.help:SetVisibility(ESlateVisibility.Visible)
		-- Log this action.
	else
		-- Log this action.
	end
end

-- [Editor Generated Lua] function define End;

return zhuansheng
