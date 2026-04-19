---@class taskbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_231 UButton
--Edit Below--
local taskbuttun = { bInitDoOnce = false }

function taskbuttun:Construct()
	self:LuaInit();

	if self.Button_231 then
		self.Button_231.OnClicked:Add(self.OnButtonClicked, self)
	end
end

function taskbuttun:OnButtonClicked()
	if TaskManager then
		TaskManager:OpenTaskMainUI()
	end
end

function taskbuttun:Destruct()
end

-- [Editor Generated Lua] function define Begin:
function taskbuttun:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;

	-- [Editor Generated Lua] BindingEvent Begin:
	self.Button_231.OnUnhovered:Add(self.Button_231_OnUnhovered, self);
	self.Button_231.OnHovered:Add(self.Button_231_OnHovered, self);
	self.Button_231.OnReleased:Add(self.Button_231_OnReleased, self);
	self.Button_231.OnPressed:Add(self.Button_231_OnPressed, self);
	-- [Editor Generated Lua] BindingEvent End;
end

function taskbuttun:Button_231_OnHovered()
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

function taskbuttun:Button_231_OnUnhovered()
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

function taskbuttun:Button_231_OnPressed()
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
	return nil;
end

function taskbuttun:Button_231_OnReleased()
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
	return nil;
end

-- [Editor Generated Lua] function define End;

return taskbuttun
