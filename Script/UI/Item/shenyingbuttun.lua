---@class shenyingbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_190 UButton
--Edit Below--
local shenyingbuttun = { bInitDoOnce = false } 

function shenyingbuttun:Construct()
    self:LuaInit()
end

function shenyingbuttun:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true

    if self.Button_190 then
        self.Button_190.OnClicked:Add(self.Button_OnClicked, self)
        self.Button_190.OnHovered:Add(self.Button_OnHovered, self)
        self.Button_190.OnUnhovered:Add(self.Button_OnUnhovered, self)
        self.Button_190.OnPressed:Add(self.Button_OnPressed, self)
        self.Button_190.OnReleased:Add(self.Button_OnReleased, self)
    end
end

function shenyingbuttun:Button_OnClicked()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI then
        pc.MMainUI:ToggleShenyin()
    end
end

function shenyingbuttun:Button_OnHovered()
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

function shenyingbuttun:Button_OnUnhovered()
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

function shenyingbuttun:Button_OnPressed()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
    end
end

function shenyingbuttun:Button_OnReleased()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
    end
end

return shenyingbuttun
