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
	
	-- Related UI logic.
	if self.huicheng_buttun then
		self.huicheng_buttun.OnClicked:Add(self.huicheng_buttun_OnClicked, self)
		self.huicheng_buttun.OnHovered:Add(self.huicheng_buttun_OnHovered, self)
		self.huicheng_buttun.OnUnhovered:Add(self.huicheng_buttun_OnUnhovered, self)
		self.huicheng_buttun.OnPressed:Add(self.huicheng_buttun_OnPressed, self)
		self.huicheng_buttun.OnReleased:Add(self.huicheng_buttun_OnReleased, self)
	end
end

-- Related UI logic.
function huicheng:TeleportToLocation(x, y, z)
	-- Log this action.
	-- Log this action.
	
	local ok, err = pcall(function()
		local PlayerController = UGCGameSystem.GetLocalPlayerController()
		if not PlayerController then
			-- Log this action.
			return
		end
		
		-- Related UI logic.
		-- Log this action.
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z)
		-- Log this action.
	end)
	
	if not ok then
		-- Log this action.
	end
end

-- Related UI logic.
function huicheng:RestoreFullHealth()
	-- Log this action.
	
	local ok, err = pcall(function()
		local PlayerController = UGCGameSystem.GetLocalPlayerController()
		if not PlayerController then
			-- Log this action.
			return
		end
		
		-- Related UI logic.
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_RestoreFullHealth")
		-- Log this action.
	end)
	
	if not ok then
		-- Log this action.
	end
end

-- Related UI logic.
function huicheng:huicheng_buttun_OnClicked()
	-- Log this action.
	-- Related UI logic.
	self:RestoreFullHealth()
	-- Related UI logic.
	self:TeleportToLocation(19053.320312, 50346.1875, 535.063049)
end

function huicheng:huicheng_buttun_OnHovered()
	-- Related UI logic.
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
	-- Related UI logic.
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
	-- Related UI logic.
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
end

function huicheng:huicheng_buttun_OnReleased()
	-- Related UI logic.
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
end

return huicheng
