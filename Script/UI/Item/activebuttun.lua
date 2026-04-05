---@class activebuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_0 UButton
--Edit Below--
local activebuttun = { bInitDoOnce = false }

function activebuttun:Construct()
    self:LuaInit()
end

function activebuttun:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.Button_0 then
        self.Button_0.OnClicked:Add(self.OnButtonClicked, self)
        self.Button_0.OnHovered:Add(self.OnButtonHovered, self)
        self.Button_0.OnUnhovered:Add(self.OnButtonUnhovered, self)
        self.Button_0.OnPressed:Add(self.OnButtonPressed, self)
        self.Button_0.OnReleased:Add(self.OnButtonReleased, self)
    end
end

function activebuttun:OnButtonClicked()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.active then
        pc.MMainUI.active:Show()
    end
end

function activebuttun:OnButtonHovered()
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

function activebuttun:OnButtonUnhovered()
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

function activebuttun:OnButtonPressed()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
    end
end

function activebuttun:OnButtonReleased()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
    end
end

function activebuttun:Destruct()
end

return activebuttun
