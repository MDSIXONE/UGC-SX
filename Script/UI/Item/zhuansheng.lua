---@class zhuansheng_C:UUserWidget
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

-- 转生图片控件列表（从1到12，转生一次显示一个，从zhuansheng1开始）
local zhuanshengImages = {
	"zhuansheng1", "zhuansheng2", "zhuansheng3", "zhuansheng4",
	"zhuansheng5", "zhuansheng6", "zhuansheng7", "zhuansheng8",
	"zhuansheng9", "zhuansheng10", "zhuansheng11", "zhuansheng12"
} 

-- 隐藏所有控件
function zhuansheng:HideAllControls()
	if self.zhuansheng_back then self.zhuansheng_back:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Button then self.zhuansheng_Button:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Tips then self.zhuansheng_Tips:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_cancel then self.zhuansheng_cancel:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Text2 then self.zhuansheng_Text2:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_Text1 then self.zhuansheng_Text1:SetVisibility(ESlateVisibility.Collapsed) end
	if self.zhuansheng_help then self.zhuansheng_help:SetVisibility(ESlateVisibility.Collapsed) end
	-- 隐藏所有转生图片
	for _, imageName in ipairs(zhuanshengImages) do
		local imageWidget = self[imageName]
		if imageWidget then
			imageWidget:SetVisibility(ESlateVisibility.Collapsed)
		end
	end
end

-- 显示所有控件
function zhuansheng:ShowAllControls()
	if self.zhuansheng_back then self.zhuansheng_back:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Button then self.zhuansheng_Button:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Tips then self.zhuansheng_Tips:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_cancel then self.zhuansheng_cancel:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Text2 then self.zhuansheng_Text2:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_Text1 then self.zhuansheng_Text1:SetVisibility(ESlateVisibility.Visible) end
	if self.zhuansheng_help then self.zhuansheng_help:SetVisibility(ESlateVisibility.Visible) end
	-- 更新转生图片显示状态
	self:UpdateZhuanshengImages()
	-- 更新Tips文本
	self:UpdateTipsText()
end

-- 更新Tips文本
function zhuansheng:UpdateTipsText()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then return end
	
	if playerState.GetRebirthInfo then
		local rebirthInfo = playerState:GetRebirthInfo()
		if rebirthInfo.canRebirth then
			self.zhuansheng_Tips:SetText("可转生")
		else
			-- 检查具体是哪个条件不满足
			local levelOk = rebirthInfo.currentLevel >= rebirthInfo.requiredLevel
			local combatOk = rebirthInfo.currentCombatPower >= rebirthInfo.requiredCombatPower
			
			if not levelOk and not combatOk then
				self.zhuansheng_Tips:SetText("等级和战斗力未达到")
			elseif not levelOk then
				self.zhuansheng_Tips:SetText("等级未到达")
			else
				self.zhuansheng_Tips:SetText("战斗力未到达")
			end
		end
	end
end

function zhuansheng:Construct()
	self:LuaInit();
	-- 初始化时隐藏所有控件
	self:HideAllControls()
end

-- 根据转生次数更新转生图片显示状态
function zhuansheng:UpdateZhuanshengImages()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then return end
	
	local rebirthCount = 0
	if playerState.GetRebirthInfo then
		local rebirthInfo = playerState:GetRebirthInfo()
		rebirthCount = rebirthInfo.rebirthCount or 0
	end
	
	-- 根据转生次数显示对应数量的图片（从zhuansheng1开始显示）
	-- 转生1次显示zhuansheng1，转生2次显示zhuansheng1和zhuansheng2，以此类推
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
	-- 绑定取消按钮事件
	if self.zhuansheng_cancel then
		self.zhuansheng_cancel.OnClicked:Add(self.zhuansheng_cancel_OnClicked, self);
	end
	-- 绑定帮助按钮事件
	if self.zhuansheng_help then
		self.zhuansheng_help.OnClicked:Add(self.zhuansheng_help_OnClicked, self);
	end
	-- [Editor Generated Lua] BindingEvent End;
end

function zhuansheng:zhuansheng_Text2_Text(ReturnValue)
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then
		return "获取玩家状态失败"
	end
	
	-- 使用转生信息获取函数
	if playerState.GetRebirthInfo then
		local rebirthInfo = playerState:GetRebirthInfo()
		
		-- 检查是否已达到最大转生次数
		if rebirthInfo.rebirthCount >= rebirthInfo.maxRebirthCount then
			return "已达到最大转生次数(" .. rebirthInfo.maxRebirthCount .. "次)"
		end
		
		-- 获取格式化函数
		local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
		
		-- 检查等级和战斗力是否达到转生要求
		local levelOk = rebirthInfo.currentLevel >= rebirthInfo.requiredLevel
		local combatOk = rebirthInfo.currentCombatPower >= rebirthInfo.requiredCombatPower
		
		if not levelOk or not combatOk then
			local text = ""
			if not levelOk then
				text = "等级达到" .. rebirthInfo.requiredLevel .. "级 (当前" .. rebirthInfo.currentLevel .. "级)"
			end
			if not combatOk then
				if text ~= "" then text = text .. "\n" end
				text = text .. "战斗力达到" .. UGCGameData.FormatNumber(rebirthInfo.requiredCombatPower) .. " (当前" .. UGCGameData.FormatNumber(rebirthInfo.currentCombatPower) .. ")"
			end
			return text
		end
		
		return "可以转生 (第" .. (rebirthInfo.rebirthCount + 1) .. "次)"
	else
		-- 兼容旧版本代码
		return "获取转生信息失败"
	end
end

function zhuansheng:zhuansheng_Button_OnClicked()
	local playerState = UGCGameSystem.GetLocalPlayerState()
	if not playerState then
		--ugcprint("[zhuansheng] 错误：无法获取玩家状态")
		return
	end
	
	-- 检查是否可以转生
	local canRebirth, reason = playerState:CanRebirth()
	if not canRebirth then
		--ugcprint("[zhuansheng] 转生失败: " .. reason)
		return
	end
	
	-- 调用服务器RPC执行转生
	local pc = UGCGameSystem.GetPlayerControllerByPlayerState(playerState)
	if pc then
		-- 获取当前转生次数，用于立即隐藏对应图片
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
		--ugcprint("[zhuansheng] 已发送转生请求到服务器")

		-- 立即显示对应转生图片（当前转生次数+1，因为Lua数组从1开始）
		-- 第1次转生显示zhuansheng1，第2次转生显示zhuansheng2，以此类推
		local nextImageIndex = currentRebirthCount + 1
		local nextImageName = zhuanshengImages[nextImageIndex]
		--ugcprint("[zhuansheng] 当前转生次数: " .. currentRebirthCount .. ", 要显示的图片索引: " .. nextImageIndex)
		if nextImageName then
			local imageWidget = self[nextImageName]
			if imageWidget then
				imageWidget:SetVisibility(ESlateVisibility.Visible)
				--ugcprint("[zhuansheng] 立即显示图片: " .. nextImageName)
			else
				--ugcprint("[zhuansheng] 图片控件不存在: " .. nextImageName)
			end
		else
			--ugcprint("[zhuansheng] 图片名称不存在，索引: " .. nextImageIndex)
		end
	else
		--ugcprint("[zhuansheng] 错误：无法获取玩家控制器")
	end
end

-- 取消按钮点击事件
function zhuansheng:zhuansheng_cancel_OnClicked()
	--ugcprint("zhuansheng: 取消按钮被点击")
	-- 隐藏所有控件
	self:HideAllControls()
	
	-- 通过 PlayerController 获取 MMainUI（因为这些是兄弟组件，不是父子关系）
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.zhuanshengbuttun then
		--ugcprint("zhuansheng: 找到 MMainUI，显示转生按钮")
		pc.MMainUI.zhuanshengbuttun:SetVisibility(ESlateVisibility.Visible)
	else
		--ugcprint("zhuansheng: 错误 - 无法找到 MMainUI")
	end
end

-- 帮助按钮点击事件
function zhuansheng:zhuansheng_help_OnClicked()
	--ugcprint("zhuansheng: 帮助按钮被点击")
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.help then
		pc.MMainUI.help:SetVisibility(ESlateVisibility.Visible)
		--ugcprint("zhuansheng: 显示帮助界面")
	else
		--ugcprint("zhuansheng: 错误 - 无法找到帮助界面")
	end
end

-- [Editor Generated Lua] function define End;

return zhuansheng