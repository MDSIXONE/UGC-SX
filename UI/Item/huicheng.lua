---@class huicheng_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field huicheng_buttun UButton
--Edit Below--
local huicheng = { bInitDoOnce = false } 

function huicheng:Construct()
	self:LuaInit()
end

-- function huicheng:Tick(MyGeometry, InDeltaTime)
-- end

-- function huicheng:Destruct()
-- end

function huicheng:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- 绑定按钮事件
	if self.huicheng_buttun then
		self.huicheng_buttun.OnClicked:Add(self.huicheng_buttun_OnClicked, self)
		self.huicheng_buttun.OnHovered:Add(self.huicheng_buttun_OnHovered, self)
		self.huicheng_buttun.OnUnhovered:Add(self.huicheng_buttun_OnUnhovered, self)
		self.huicheng_buttun.OnPressed:Add(self.huicheng_buttun_OnPressed, self)
		self.huicheng_buttun.OnReleased:Add(self.huicheng_buttun_OnReleased, self)
	end
end

-- 传送到指定位置（回城点）
function huicheng:TeleportToLocation(x, y, z)
	--ugcprint("huicheng: TeleportToLocation 开始")
	--ugcprint("huicheng: 目标位置 X=" .. x .. " Y=" .. y .. " Z=" .. z)
	
	local ok, err = pcall(function()
		local PlayerController = UGCGameSystem.GetLocalPlayerController()
		if not PlayerController then
			--ugcprint("huicheng: 错误 - 无法获取 PlayerController")
			return
		end
		
		-- 通过 RPC 调用服务器传送
		--ugcprint("huicheng: 调用 Server_TeleportPlayer RPC")
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z)
		--ugcprint("huicheng: 已发送传送请求到服务器")
	end)
	
	if not ok then
		--ugcprint("huicheng: 发送传送请求失败: " .. tostring(err))
	end
end

-- 回满血
function huicheng:RestoreFullHealth()
	--ugcprint("huicheng: 请求回满血")
	
	local ok, err = pcall(function()
		local PlayerController = UGCGameSystem.GetLocalPlayerController()
		if not PlayerController then
			--ugcprint("huicheng: 错误 - 无法获取 PlayerController")
			return
		end
		
		-- 通过 RPC 调用服务器回满血
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_RestoreFullHealth")
		--ugcprint("huicheng: 已发送回满血请求到服务器")
	end)
	
	if not ok then
		--ugcprint("huicheng: 发送回满血请求失败: " .. tostring(err))
	end
end

-- 回城按钮点击事件
function huicheng:huicheng_buttun_OnClicked()
	--ugcprint("huicheng: 回城按钮被点击")
	-- 回满血
	self:RestoreFullHealth()
	-- 传送到回城点坐标
	self:TeleportToLocation(19053.320312, 50346.1875, 535.063049)
end

function huicheng:huicheng_buttun_OnHovered()
	-- 播放悬停动画（正向）
	if self.NewAnimation_1 then
		if not self:IsAnimationPlaying(self.NewAnimation_1) then
			self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
		else
			if not self:IsAnimationPlayingForward(self.NewAnimation_1) then
				self:ReverseAnimation(self.NewAnimation_1)
			end
		end
	end
end

function huicheng:huicheng_buttun_OnUnhovered()
	-- 播放倒放动画
	if self.NewAnimation_1 then
		if not self:IsAnimationPlaying(self.NewAnimation_1) then
			self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 1)
		else
			if self:IsAnimationPlayingForward(self.NewAnimation_1) then
				self:ReverseAnimation(self.NewAnimation_1)
			end
		end
	end
end

function huicheng:huicheng_buttun_OnPressed()
	-- 按压时快速播放到末尾
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
end

function huicheng:huicheng_buttun_OnReleased()
	-- 释放时快速倒放回初始状态
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
end

return huicheng