---@class tunshitip_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Image_0 UImage
---@field tunshitiptext UTextBlock
--Edit Below--
local tunshitip = { 
    bInitDoOnce = false,
    messageQueue = {},   -- 消息队列
    isProcessing = false -- 是否正在处理队列
} 


function tunshitip:Construct()
	self:LuaInit();
	
end


-- function tunshitip:Tick(MyGeometry, InDeltaTime)

-- end

-- function tunshitip:Destruct()

-- end

-- 显示提示信息
function tunshitip:ShowTips(message)
	--ugcprint("[tunshitip] ShowTips 被调用，消息: " .. tostring(message))
	
	-- 将消息加入队列
	table.insert(self.messageQueue, message)
	--ugcprint("[tunshitip] 消息已加入队列，当前队列长度: " .. #self.messageQueue)
	
	-- 如果没有正在处理队列，开始处理
	if not self.isProcessing then
		self:ProcessQueue()
	end
end

-- 处理队列（立即显示，不等待前一条结束）
function tunshitip:ProcessQueue()
	-- 检查队列是否为空
	if #self.messageQueue == 0 then
		self.isProcessing = false
		--ugcprint("[tunshitip] 队列已空，停止处理")
		return
	end
	
	-- 标记正在处理
	self.isProcessing = true
	
	-- 取出队列第一条消息
	local message = table.remove(self.messageQueue, 1)
	--ugcprint("[tunshitip] 立即显示消息: " .. tostring(message) .. ", 剩余队列: " .. #self.messageQueue)
	
	-- 立即显示这条消息
	self:ShowSingleMessage(message)
	
	-- 0.1秒后处理下一条（不等待当前消息结束）
	local nextDelegate = ObjectExtend.CreateDelegate(self, function()
		self:ProcessQueue()
	end)
	KismetSystemLibrary.K2_SetTimerDelegateForLua(nextDelegate, self, 0.1, false)
end

-- 显示单条消息
function tunshitip:ShowSingleMessage(message)
	if not self.tunshitiptext then
		--ugcprint("[tunshitip] 错误：tunshitiptext 不存在")
		return
	end
	
	-- 显示容器
	self:SetVisibility(ESlateVisibility.Visible)
	
	-- 显示文本组件
	self.tunshitiptext:SetVisibility(ESlateVisibility.Visible)
	
	-- 设置提示文本
	self.tunshitiptext:SetText(message)
	
	-- 播放动画（如果存在）
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
		--ugcprint("[tunshitip] 动画已播放")
	end
	
	-- 0.3秒后隐藏（但不影响下一条的显示）
	local hideDelegate = ObjectExtend.CreateDelegate(self, function()
		-- 只有在队列为空且不在处理时才隐藏容器
		if #self.messageQueue == 0 and not self.isProcessing then
			self:SetVisibility(ESlateVisibility.Collapsed)
			--ugcprint("[tunshitip] 所有提示已完成，容器已隐藏")
		end
	end)
	
	KismetSystemLibrary.K2_SetTimerDelegateForLua(hideDelegate, self, 0.3, false)
end

-- [Editor Generated Lua] function define Begin:
function tunshitip:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	self.tunshitiptext:BindingProperty("Text", self.tunshitiptext_Text, self);
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	-- [Editor Generated Lua] BindingEvent End;
end

function tunshitip:tunshitiptext_Text(ReturnValue)
	return "";
end

-- [Editor Generated Lua] function define End;

return tunshitip