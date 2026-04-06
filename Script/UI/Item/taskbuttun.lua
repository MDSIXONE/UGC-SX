---@class taskbuttun_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Button_231 UButton
--Edit Below--
local taskbuttun = { bInitDoOnce = false }

-- 手动引入 UGCGameData (与 Exampleproject 一致)
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

-- 保存 TASK UI 引用（用于动态创建方式）
taskbuttun.TaskUI = nil

function taskbuttun:Construct()
	self:LuaInit();
    --ugcprint("[taskbuttun] ========== UI Construct 开始 ==========")
    
    -- 绑定按钮点击事件
    if self.Button_231 then
        self.Button_231.OnClicked:Add(self.OnButtonClicked, self)
        --ugcprint("[taskbuttun] Button_231 绑定成功")
    else
        --ugcprint("[taskbuttun] 警告: Button_231 不存在")
    end
    
    --ugcprint("[taskbuttun] ========== UI Construct 完成 ==========")
end

---获取 TASK 组件（优先从 MMainUI 获取嵌入组件，否则动态创建）
function taskbuttun:GetTaskUI()
    --ugcprint("[taskbuttun] GetTaskUI 开始...")
    
    -- 获取本地玩家控制器
    local pc = UGCGameSystem.GetLocalPlayerController()
    if not pc then
        --ugcprint("[taskbuttun] 错误: 无法获取本地控制器")
        return nil
    end
    --ugcprint("[taskbuttun] 成功获取 PlayerController: " .. tostring(pc))
    
    -- 方式1: 尝试从 MMainUI 获取嵌入的 TASK 组件
    if pc.MMainUI then
        --ugcprint("[taskbuttun] 找到 pc.MMainUI: " .. tostring(pc.MMainUI))
        if pc.MMainUI.TASK then
            --ugcprint("[taskbuttun] 找到嵌入的 TASK 组件: " .. tostring(pc.MMainUI.TASK))
            return pc.MMainUI.TASK, true  -- 返回 taskUI 和 isEmbedded 标志
        else
            --ugcprint("[taskbuttun] pc.MMainUI.TASK 不存在")
        end
    else
        --ugcprint("[taskbuttun] pc.MMainUI 不存在")
    end
    
    -- 方式2: 动态创建 TASK UI（与 Exampleproject 一致）
    --ugcprint("[taskbuttun] 使用动态创建方式...")
    
    -- 如果已经创建过且有效，直接返回
    if self.TaskUI and UGCObjectUtility.IsObjectValid(self.TaskUI) then
        --ugcprint("[taskbuttun] 返回已创建的 TaskUI")
        return self.TaskUI, false
    end
    
    -- 创建新的 TASK UI
    self.TaskUI = UGCGameData.GetUI(pc, "TASK")
    if self.TaskUI then
        --ugcprint("[taskbuttun] 动态创建 TASK UI 成功: " .. tostring(self.TaskUI))
    else
        --ugcprint("[taskbuttun] 动态创建 TASK UI 失败")
    end
    
    return self.TaskUI, false
end

---按钮点击事件 - 切换任务UI显示
function taskbuttun:OnButtonClicked()
    --ugcprint("[taskbuttun] ========== 点击任务按钮 ==========")
    
    local taskUI, isEmbedded = self:GetTaskUI()
    if not taskUI then
        --ugcprint("[taskbuttun] 错误: 无法获取 TASK UI")
        return
    end
    
    --[[    --ugcprint(string.format("[taskbuttun] 获取到 TASK UI, 是否嵌入: %s", tostring(isEmbedded)))]]
    
    if not isEmbedded and not taskUI:IsInViewport() then
        taskUI:AddToViewport(2000)
        --ugcprint("[taskbuttun] 任务UI已添加到视口")
    end

    local currentVisibility = taskUI:GetVisibility()
    if currentVisibility == ESlateVisibility.Collapsed or currentVisibility == ESlateVisibility.Hidden then
        if taskUI.ShowPanel then
            taskUI:ShowPanel()
        else
            if taskUI.RefreshTaskUI then
                taskUI:RefreshTaskUI()
            end
            taskUI:SetVisibility(ESlateVisibility.Visible)
        end
    else
        if taskUI.HidePanel then
            taskUI:HidePanel()
        else
            taskUI:SetVisibility(ESlateVisibility.Collapsed)
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
	-- 播放悬停动画（正向）
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
	-- 播放倒放动画
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
	-- 按压时快速播放到末尾
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 2)
	end
	return nil;
end

function taskbuttun:Button_231_OnReleased()
	-- 释放时快速倒放回初始状态
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 1, 2)
	end
	return nil;
end

-- [Editor Generated Lua] function define End;

return taskbuttun