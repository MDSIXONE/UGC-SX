---@class tunshi_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field tunshi UButton
--Edit Below--
local tunshi = { bInitDoOnce = false } 


function tunshi:Construct()
	self:LuaInit();
	
end


-- function tunshi:Tick(MyGeometry, InDeltaTime)

-- end

-- function tunshi:Destruct()

-- end

-- [Editor Generated Lua] function define Begin:
function tunshi:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	self.tunshi.OnClicked:Add(self.tunshi_OnClicked, self);
	self.tunshi.OnHovered:Add(self.tunshi_OnHovered, self);
	self.tunshi.OnUnhovered:Add(self.tunshi_OnUnhovered, self);
	self.tunshi.OnPressed:Add(self.tunshi_OnPressed, self);
	self.tunshi.OnReleased:Add(self.tunshi_OnReleased, self);
	-- [Editor Generated Lua] BindingEvent End;
end

function tunshi:tunshi_OnClicked()
	--ugcprint("[tunshi] 吞噬按钮被点击")
	
	-- 获取本地玩家
	local playerPawn = UGCGameSystem.GetLocalPlayerPawn()
	if not playerPawn then
		--ugcprint("[tunshi] 错误：无法获取本地玩家")
		return
	end
	
	-- 获取 PlayerController
	local playerController = playerPawn:GetController()
	if not playerController then
		--ugcprint("[tunshi] 错误：无法获取 PlayerController")
		return
	end
	
	--ugcprint("[tunshi] 调用服务端 RPC 销毁尸体")
	
	-- 使用 UnrealNetwork.CallUnrealRPC 调用服务端 RPC
	UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_DestroyNearbyCorpses")
	--ugcprint("[tunshi] 已发送销毁尸体请求到服务器")
	
	-- 隐藏吞噬按钮（不显示提示，等待服务器返回后再显示）
	if playerController.MMainUI then
		local mainUI = playerController.MMainUI
		--ugcprint("[tunshi] 获取到 MMainUI")
		
		if mainUI.HideTunshi then
			mainUI:HideTunshi()
			--ugcprint("[tunshi] 吞噬按钮已隐藏")
		end
	else
		--ugcprint("[tunshi] 错误：MMainUI 不存在")
	end
	
	return nil;
end

function tunshi:tunshi_OnHovered()
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
	return nil;
end

function tunshi:tunshi_OnUnhovered()
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
	return nil;
end

function tunshi:tunshi_OnPressed()
	-- 按压时快速播放到末尾
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
	return nil;
end

function tunshi:tunshi_OnReleased()
	-- 释放时快速倒放回初始状态
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
	return nil;
end

-- [Editor Generated Lua] function define End;

return tunshi