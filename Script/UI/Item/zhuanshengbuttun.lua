---@class zhuanshengbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field CanvasPanel_0 UCanvasPanel
---@field zhuanshengbuttun UButton
--Edit Below--
local zhuanshengbuttun = { bInitDoOnce = false } 

function zhuanshengbuttun:Construct()
	self:LuaInit();
	--ugcprint("[zhuanshengbuttun] UI Construct")
end

-- function zhuanshengbuttun:Tick(MyGeometry, InDeltaTime)

-- end

-- function zhuanshengbuttun:Destruct()

-- end

-- [Editor Generated Lua] function define Begin:
function zhuanshengbuttun:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	self.zhuanshengbuttun.OnClicked:Add(self.zhuanshengbuttun_OnClicked, self);
	self.zhuanshengbuttun.OnHovered:Add(self.zhuanshengbuttun_OnHovered, self);
	self.zhuanshengbuttun.OnUnhovered:Add(self.zhuanshengbuttun_OnUnhovered, self);
	self.zhuanshengbuttun.OnPressed:Add(self.zhuanshengbuttun_OnPressed, self);
	self.zhuanshengbuttun.OnReleased:Add(self.zhuanshengbuttun_OnReleased, self);
	-- [Editor Generated Lua] BindingEvent End;
end

function zhuanshengbuttun:zhuanshengbuttun_OnClicked()
	--ugcprint("[zhuanshengbuttun] 按钮被点击")
	
	-- 通过 PlayerController 获取 MMainUI（因为这些是兄弟组件，不是父子关系）
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI then
		--ugcprint("[zhuanshengbuttun] 找到 MMainUI，显示转生界面")
		pc.MMainUI.zhuansheng:ShowAllControls()
		self:SetVisibility(ESlateVisibility.Collapsed)
	else
		--ugcprint("[zhuanshengbuttun] 错误 - 无法找到 MMainUI")
	end
end

-- 鼠标悬停事件 - 播放动画
function zhuanshengbuttun:zhuanshengbuttun_OnHovered()
	-- 播放悬停动画（正向）
	if self.NewAnimation_1 then
		-- 检查动画是否正在播放，避免重复触发
		if not self:IsAnimationPlaying(self.NewAnimation_1) then
			self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
			--ugcprint("[zhuanshengbuttun] 播放悬停动画")
		else
			-- 如果正在倒放，则反转为正向
			if not self:IsAnimationPlayingForward(self.NewAnimation_1) then
				self:ReverseAnimation(self.NewAnimation_1)
				--ugcprint("[zhuanshengbuttun] 反转为正向播放")
			end
		end
	end
end

-- 鼠标离开事件 - 倒放动画
function zhuanshengbuttun:zhuanshengbuttun_OnUnhovered()
	-- 播放倒放动画（从末尾倒放回初始状态）
	if self.NewAnimation_1 then
		-- 检查动画是否正在播放
		if not self:IsAnimationPlaying(self.NewAnimation_1) then
			-- 动画已停止，重新播放倒放
			self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 1)
			--ugcprint("[zhuanshengbuttun] 倒放悬停动画")
		else
			-- 动画正在播放，检查是否正向播放
			if self:IsAnimationPlayingForward(self.NewAnimation_1) then
				-- 正在正向播放，反转为倒放
				self:ReverseAnimation(self.NewAnimation_1)
				--ugcprint("[zhuanshengbuttun] 反转为倒放")
			end
		end
	end
end

-- 鼠标按下事件 - 播放按压动画
function zhuanshengbuttun:zhuanshengbuttun_OnPressed()
	if self.NewAnimation_1 then
		-- 按压时快速播放到末尾（模拟按下效果）
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
		--ugcprint("[zhuanshengbuttun] 按压动画")
	end
end

-- 鼠标释放事件 - 恢复动画
function zhuanshengbuttun:zhuanshengbuttun_OnReleased()
	if self.NewAnimation_1 then
		-- 释放时快速倒放回初始状态
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
		--ugcprint("[zhuanshengbuttun] 释放动画")
	end
end

-- [Editor Generated Lua] function define End;

return zhuanshengbuttun