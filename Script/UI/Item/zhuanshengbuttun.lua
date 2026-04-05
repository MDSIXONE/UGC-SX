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
	-- Log this action.
	
	-- Related UI logic.
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI then
		-- Log this action.
		pc.MMainUI.zhuansheng:ShowAllControls()
		self:SetVisibility(ESlateVisibility.Collapsed)
	else
		-- Log this action.
	end
end

-- Related UI logic.
function zhuanshengbuttun:zhuanshengbuttun_OnHovered()
	-- Related UI logic.
	if self.NewAnimation_1 then
		-- Related UI logic.
		if not self:IsAnimationPlaying(self.NewAnimation_1) then
			self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
			-- Log this action.
		else
			-- Related UI logic.
			if not self:IsAnimationPlayingForward(self.NewAnimation_1) then
				self:ReverseAnimation(self.NewAnimation_1)
				-- Log this action.
			end
		end
	end
end

-- Related UI logic.
function zhuanshengbuttun:zhuanshengbuttun_OnUnhovered()
	-- Related UI logic.
	if self.NewAnimation_1 then
		-- Related UI logic.
		if not self:IsAnimationPlaying(self.NewAnimation_1) then
			-- Related UI logic.
			self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 1)
			-- Log this action.
		else
			-- Related UI logic.
			if self:IsAnimationPlayingForward(self.NewAnimation_1) then
				-- Related UI logic.
				self:ReverseAnimation(self.NewAnimation_1)
				-- Log this action.
			end
		end
	end
end

-- Related UI logic.
function zhuanshengbuttun:zhuanshengbuttun_OnPressed()
	if self.NewAnimation_1 then
		-- Related UI logic.
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
		-- Log this action.
	end
end

-- Related UI logic.
function zhuanshengbuttun:zhuanshengbuttun_OnReleased()
	if self.NewAnimation_1 then
		-- Related UI logic.
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
		-- Log this action.
	end
end

-- [Editor Generated Lua] function define End;

return zhuanshengbuttun
