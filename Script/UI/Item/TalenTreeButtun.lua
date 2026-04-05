---@class TalenTreeButtun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_0 UButton
--Edit Below--
local TalenTreeButtun = { bInitDoOnce = false }

function TalenTreeButtun:Construct()
    self:LuaInit()
end

function TalenTreeButtun:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    
    self.Button_0.OnClicked:Add(self.Button_0_OnClicked, self)
    self.Button_0.OnHovered:Add(self.Button_0_OnHovered, self)
    self.Button_0.OnUnhovered:Add(self.Button_0_OnUnhovered, self)
    self.Button_0.OnPressed:Add(self.Button_0_OnPressed, self)
    self.Button_0.OnReleased:Add(self.Button_0_OnReleased, self)
end

function TalenTreeButtun:Button_0_OnClicked()
    -- Log this action.
    
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI then
        pc.MMainUI:ToggleTalentTree()
    else
        -- Log this action.
    end
end

function TalenTreeButtun:Button_0_OnHovered()
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

function TalenTreeButtun:Button_0_OnUnhovered()
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

function TalenTreeButtun:Button_0_OnPressed()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
    end
end

function TalenTreeButtun:Button_0_OnReleased()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
    end
end

return TalenTreeButtun
