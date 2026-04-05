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
	-- Log that the button was clicked.
	
	-- Get the required consume reference.
	local playerPawn = UGCGameSystem.GetLocalPlayerPawn()
	if not playerPawn then
		-- Log the error state.
		return
	end
	
	-- Get the required consume reference.
	local playerController = playerPawn:GetController()
	if not playerController then
		-- Log the error state.
		return
	end
	
	-- Log this action.
	
	-- Related UI logic.
	UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_DestroyNearbyCorpses")
	-- Log that the request was sent to the server.
	
	-- Hide the consume UI element.
	if playerController.MMainUI then
		local mainUI = playerController.MMainUI
		-- Log this action.
		
		if mainUI.HideTunshi then
			mainUI:HideTunshi()
			-- Log that the UI is hidden.
		end
	else
		-- Log the error state.
	end
	
	return nil;
end

function tunshi:tunshi_OnHovered()
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
	return nil;
end

function tunshi:tunshi_OnUnhovered()
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
	return nil;
end

function tunshi:tunshi_OnPressed()
	-- Related UI logic.
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
	return nil;
end

function tunshi:tunshi_OnReleased()
	-- Related UI logic.
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
	return nil;
end

-- [Editor Generated Lua] function define End;

return tunshi
