---@class shouchongbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field shouchong_buttun UButton
--Edit Below--
UGCGameSystem.UGCRequire("ExtendResource.SignInEvent.OfficialPackage." .. "Script.SignInEvent.SignInEventManager")

local shouchongbuttun = { bInitDoOnce = false }

function shouchongbuttun:Construct()
    self:LuaInit()
end

function shouchongbuttun:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true

    -- 绑定按钮事件
    self.shouchong_buttun.OnClicked:Add(self.shouchong_buttun_OnClicked, self)
    self.shouchong_buttun.OnHovered:Add(self.shouchong_buttun_OnHovered, self)
    self.shouchong_buttun.OnUnhovered:Add(self.shouchong_buttun_OnUnhovered, self)
    self.shouchong_buttun.OnPressed:Add(self.shouchong_buttun_OnPressed, self)
    self.shouchong_buttun.OnReleased:Add(self.shouchong_buttun_OnReleased, self)
end

function shouchongbuttun:shouchong_buttun_OnClicked()
    --ugcprint("[shouchongbuttun] 按钮被点击，打开签到主界面")

    -- 参考 SignInEvent TestButton 的打开逻辑
    if SignInEventManager and SignInEventManager.OpenMainUI then
        SignInEventManager:OpenMainUI()
    else
        --ugcprint("[shouchongbuttun] 错误 - SignInEventManager 不存在")
    end
end

function shouchongbuttun:shouchong_buttun_OnHovered()
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

function shouchongbuttun:shouchong_buttun_OnUnhovered()
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

function shouchongbuttun:shouchong_buttun_OnPressed()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
    end
end

function shouchongbuttun:shouchong_buttun_OnReleased()
    if self.NewAnimation_1 then
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
    end
end

return shouchongbuttun