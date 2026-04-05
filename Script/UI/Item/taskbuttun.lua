---@class taskbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_231 UButton
--Edit Below--
local taskbuttun = { bInitDoOnce = false }

-- Related UI logic.
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

-- Related UI logic.
taskbuttun.TaskUI = nil

function taskbuttun:Construct()
	self:LuaInit();
    -- Log this action.
    
    -- Related UI logic.
    if self.Button_231 then
        self.Button_231.OnClicked:Add(self.OnButtonClicked, self)
        -- Log this action.
    else
        -- Log this action.
    end
    
    -- Log this action.
end

-- Related UI logic.
function taskbuttun:GetTaskUI()
    -- Log this action.
    
    -- Related UI logic.
    if not pc then
        -- Log this action.
        return nil
    end
    -- Log this action.
    
    -- Related UI logic.
    if pc.MMainUI then
        -- Log this action.
        if pc.MMainUI.TASK then
            -- Log this action.
            return pc.MMainUI.TASK, true  -- 杩斿洖 taskUI 鍜?isEmbedded 鏍囧織
        else
            -- Log this action.
        end
    else
        -- Log this action.
    end
    
    -- Related UI logic.
    -- Log this action.
    
    -- Related UI logic.
        -- Log this action.
        return self.TaskUI, false
    end
    
    -- Related UI logic.
    self.TaskUI = UGCGameData.GetUI(pc, "TASK")
    if self.TaskUI then
        -- Log this action.
    else
        -- Log this action.
    end
    
    return self.TaskUI, false
end

-- Related UI logic.
function taskbuttun:OnButtonClicked()
    -- Log this action.
    
    local taskUI, isEmbedded = self:GetTaskUI()
    if not taskUI then
        -- Log this action.
        return
    end
    
    -- Log this action.
    
    if isEmbedded then
        -- Related UI logic.
        -- Log this action.
        
        if currentVisibility == ESlateVisibility.Collapsed or currentVisibility == ESlateVisibility.Hidden then
            -- Related UI logic.
                taskUI:RefreshTaskUI()
            end
            taskUI:SetVisibility(ESlateVisibility.Visible)
            -- Related UI logic.
            local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
            if MainControlPanel then
                UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
                UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
            end
            local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
            if SkillPanel then
                UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
            end
        else
            taskUI:SetVisibility(ESlateVisibility.Collapsed)
            -- Related UI logic.
            if MainControlPanel then
                UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
                UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
            end
            local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
            if SkillPanel then
                UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
            end
        end
    else
        -- Related UI logic.
        if not taskUI:IsInViewport() then
            if taskUI.RefreshTaskUI then
                taskUI:RefreshTaskUI()
            end
            taskUI:AddToViewport(2000)
            -- Log this action.
        else
            -- Log this action.
        end
    end
end

function taskbuttun:Destruct()
    --ugcprint("[taskbuttun] UI Destruct")
    self.TaskUI = nil
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

function taskbuttun:Button_231_OnUnhovered()
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

function taskbuttun:Button_231_OnPressed()
	-- Related UI logic.
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
	return nil;
end

function taskbuttun:Button_231_OnReleased()
	-- Related UI logic.
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
	return nil;
end

-- [Editor Generated Lua] function define End;

return taskbuttun
