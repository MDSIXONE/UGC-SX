---@class chuansongbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field CanvasPanel_0 UCanvasPanel
---@field chuansong_buttun UButton
---@field chuansongbuttun_Text UTextBlock
--Edit Below--
local chuansongbuttun = { bInitDoOnce = false } 

function chuansongbuttun:Construct()
	self:LuaInit();
end

-- function chuansongbuttun:Tick(MyGeometry, InDeltaTime)

-- end

-- function chuansongbuttun:Destruct()

-- end

-- [Editor Generated Lua] function define Begin:
function chuansongbuttun:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	self.chuansong_buttun.OnClicked:Add(self.chuansong_buttun_OnClicked, self);
	self.chuansong_buttun.OnHovered:Add(self.chuansong_buttun_OnHovered, self);
	self.chuansong_buttun.OnUnhovered:Add(self.chuansong_buttun_OnUnhovered, self);
	self.chuansong_buttun.OnPressed:Add(self.chuansong_buttun_OnPressed, self);
	self.chuansong_buttun.OnReleased:Add(self.chuansong_buttun_OnReleased, self);
	-- [Editor Generated Lua] BindingEvent End;
end

function chuansongbuttun:chuansong_buttun_OnClicked()
	-- Log this action.
	
	-- Related UI logic.
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI then
		-- Log this action.
		pc.MMainUI.chuansong:ShowAllButtons()
		self:SetVisibility(ESlateVisibility.Collapsed)
	else
		-- Log this action.
	end
end

function chuansongbuttun:chuansong_buttun_OnHovered()
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

function chuansongbuttun:chuansong_buttun_OnUnhovered()
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

function chuansongbuttun:chuansong_buttun_OnPressed()
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
end

function chuansongbuttun:chuansong_buttun_OnReleased()
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
end

-- [Editor Generated Lua] function define End;

return chuansongbuttun
