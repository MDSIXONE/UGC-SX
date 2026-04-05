---@class TASK_C:UUserWidget
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_4 UButton
---@field Button_5 UButton
---@field Button_cancel UButton
---@field Image_95 UImage
---@field Image_buttun1 UImage
---@field Image_buttun2 UImage
---@field Image_buttun3 UImage
---@field Image_buttun4 UImage
---@field Image_buttun5 UImage
--Edit Below--
local TASK = { bInitDoOnce = false }
-- 手动引入 UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
-- 任务状态文本（用于日志）
local TASK_STATUS_TEXT = {
    [0] = "未完成",
    [1] = "可领取",
    [2] = "已领取"
}
-- 任务状态图片路径
local TASK_STATUS_IMAGE = {
    [0] = nil,  -- 未完成：不显示图片
    [1] = UGCGameSystem.GetUGCResourcesFullPath('PNG/renwu2.renwu2'),  -- 可领取
    [2] = UGCGameSystem.GetUGCResourcesFullPath('PNG/renwu3.renwu3')   -- 已领取
}
---设置任务状态图片
---@param imageWidget UImage 图片组件
---@param taskStatus number 任务状态
local function SetTaskStatusImage(imageWidget, taskStatus)
    if not imageWidget then return end
    
    local imagePath = TASK_STATUS_IMAGE[taskStatus]
    if imagePath then
        -- 有图片路径，加载并显示图片
        local texture = UGCObjectUtility.LoadObject(imagePath)
        if texture then
            imageWidget:SetBrushFromTexture(texture, false)
            imageWidget:SetVisibility(ESlateVisibility.Visible)
        end
    else
        -- 未完成状态，隐藏图片
        imageWidget:SetVisibility(ESlateVisibility.Collapsed)
    end
end
function TASK:Construct()
	self:LuaInit();
    --ugcprint("[TASK] ========== UI Construct 开始 ==========")
    
    -- 绑定关闭按钮
    if self.Button_cancel then
        self.Button_cancel.OnClicked:Add(self.OnCancelClicked, self)
        --ugcprint("[TASK] 关闭按钮绑定成功")
    else
        --ugcprint("[TASK] 警告: Button_cancel 不存在")
    end
    
    -- 绑定任务1领取按钮
    if self.Button_1 then
        self.Button_1.OnClicked:Add(self.OnButton1Clicked, self)
        --ugcprint("[TASK] 任务1按钮绑定成功")
    else
        --ugcprint("[TASK] 警告: Button_1 不存在")
    end
    
    -- 绑定任务2领取按钮
    if self.Button_2 then
        self.Button_2.OnClicked:Add(self.OnButton2Clicked, self)
        --ugcprint("[TASK] 任务2按钮绑定成功")
    else
        --ugcprint("[TASK] 警告: Button_2 不存在")
    end
    
    -- 绑定任务3领取按钮
    if self.Button_3 then
        self.Button_3.OnClicked:Add(self.OnButton3Clicked, self)
        --ugcprint("[TASK] 任务3按钮绑定成功")
    else
        --ugcprint("[TASK] 警告: Button_3 不存在")
    end
    
    -- 绑定任务4领取按钮
    if self.Button_4 then
        self.Button_4.OnClicked:Add(self.OnButton4Clicked, self)
        --ugcprint("[TASK] 任务4按钮绑定成功")
    else
        --ugcprint("[TASK] 警告: Button_4 不存在")
    end
    
    -- 绑定任务5领取按钮
    if self.Button_5 then
        self.Button_5.OnClicked:Add(self.OnButton5Clicked, self)
        --ugcprint("[TASK] 任务5按钮绑定成功")
    else
        --ugcprint("[TASK] 警告: Button_5 不存在")
    end
    
    --ugcprint("[TASK] ========== UI Construct 完成 ==========")
    
    -- 初始化任务UI
    self:RefreshTaskUI()
end
---刷新任务UI显示
function TASK:RefreshTaskUI()
    --ugcprint("[TASK] ========== 刷新任务UI 开始 ==========")
    
    -- 获取本地玩家的 PlayerState
    local playerState = self:GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TASK] 错误: 无法获取 PlayerState")
        return
    end
    --ugcprint("[TASK] 成功获取 PlayerState")
    
    -- 检查 GetTaskStatus 方法是否存在
    if not playerState.GetTaskStatus then
        --ugcprint("[TASK] 错误: PlayerState 没有 GetTaskStatus 方法")
        return
    end
    --ugcprint("[TASK] PlayerState.GetTaskStatus 方法存在")
    
    -- 刷新任务1
    self:RefreshTask1(playerState)
    -- 刷新任务2
    self:RefreshTask2(playerState)
    -- 刷新任务3
    self:RefreshTask3(playerState)
    -- 刷新任务4
    self:RefreshTask4(playerState)
    -- 刷新任务5
    self:RefreshTask5(playerState)
    
    --ugcprint("[TASK] ========== 刷新任务UI 完成 ==========")
end
---刷新任务1显示
---@param playerState ASTExtraPlayerState
function TASK:RefreshTask1(playerState)
    local taskRowIndex = 1
    
    -- 获取任务状态 (0:未完成, 1:可领取, 2:已领取)
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    --ugcprint(string.format("[TASK] 任务%d状态: %d (%s)", taskRowIndex, taskStatus, TASK_STATUS_TEXT[taskStatus] or "未知"))
    
    -- 设置任务状态图片
    SetTaskStatusImage(self.Image_buttun1, taskStatus)
    
    -- 设置按钮是否可点击 (只有"可领取"状态才能点击)
    if self.Button_1 then
        self.Button_1:SetIsEnabled(taskStatus == 1)
    end
end
---任务1领取按钮点击
function TASK:OnButton1Clicked()
    --ugcprint("[TASK] 点击领取任务1")
    
    local playerState = self:GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TASK] 无法获取 PlayerState")
        return
    end
    
    local taskRowIndex = 1
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    
    -- 检查是否可领取
    if taskStatus ~= 1 then
        --ugcprint("[TASK] 任务1不可领取")
        return
    end
    
    -- 调用服务器 RPC 领取奖励
    --ugcprint("[TASK] 调用服务器领取任务1奖励")
    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end
---刷新任务2显示
---@param playerState ASTExtraPlayerState
function TASK:RefreshTask2(playerState)
    local taskRowIndex = 2
    
    -- 获取任务状态 (0:未完成, 1:可领取, 2:已领取)
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    --ugcprint(string.format("[TASK] 任务%d状态: %d (%s)", taskRowIndex, taskStatus, TASK_STATUS_TEXT[taskStatus] or "未知"))
    
    -- 设置任务状态图片
    SetTaskStatusImage(self.Image_buttun2, taskStatus)
    
    -- 设置按钮是否可点击 (只有"可领取"状态才能点击)
    if self.Button_2 then
        self.Button_2:SetIsEnabled(taskStatus == 1)
    end
end
---任务2领取按钮点击
function TASK:OnButton2Clicked()
    --ugcprint("[TASK] 点击领取任务2")
    
    local playerState = self:GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TASK] 无法获取 PlayerState")
        return
    end
    
    local taskRowIndex = 2
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    
    -- 检查是否可领取
    if taskStatus ~= 1 then
        --ugcprint("[TASK] 任务2不可领取")
        return
    end
    
    -- 调用服务器 RPC 领取奖励
    --ugcprint("[TASK] 调用服务器领取任务2奖励")
    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end
---刷新任务3显示
---@param playerState ASTExtraPlayerState
function TASK:RefreshTask3(playerState)
    local taskRowIndex = 3
    
    -- 获取任务状态 (0:未完成, 1:可领取, 2:已领取)
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    --ugcprint(string.format("[TASK] 任务%d状态: %d (%s)", taskRowIndex, taskStatus, TASK_STATUS_TEXT[taskStatus] or "未知"))
    
    -- 设置任务状态图片
    SetTaskStatusImage(self.Image_buttun3, taskStatus)
    
    -- 设置按钮是否可点击 (只有"可领取"状态才能点击)
    if self.Button_3 then
        self.Button_3:SetIsEnabled(taskStatus == 1)
    end
end
---任务3领取按钮点击
function TASK:OnButton3Clicked()
    --ugcprint("[TASK] 点击领取任务3")
    
    local playerState = self:GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TASK] 无法获取 PlayerState")
        return
    end
    
    local taskRowIndex = 3
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    
    -- 检查是否可领取
    if taskStatus ~= 1 then
        --ugcprint("[TASK] 任务3不可领取")
        return
    end
    
    -- 调用服务器 RPC 领取奖励
    --ugcprint("[TASK] 调用服务器领取任务3奖励")
    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end
---刷新任务4显示
---@param playerState ASTExtraPlayerState
function TASK:RefreshTask4(playerState)
    local taskRowIndex = 4
    
    -- 获取任务状态 (0:未完成, 1:可领取, 2:已领取)
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    --ugcprint(string.format("[TASK] 任务%d状态: %d (%s)", taskRowIndex, taskStatus, TASK_STATUS_TEXT[taskStatus] or "未知"))
    
    -- 设置任务状态图片
    SetTaskStatusImage(self.Image_buttun4, taskStatus)
    
    -- 设置按钮是否可点击 (只有"可领取"状态才能点击)
    if self.Button_4 then
        self.Button_4:SetIsEnabled(taskStatus == 1)
    end
end
---任务4领取按钮点击
function TASK:OnButton4Clicked()
    --ugcprint("[TASK] 点击领取任务4")
    
    local playerState = self:GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TASK] 无法获取 PlayerState")
        return
    end
    
    local taskRowIndex = 4
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    
    -- 检查是否可领取
    if taskStatus ~= 1 then
        --ugcprint("[TASK] 任务4不可领取")
        return
    end
    
    -- 调用服务器 RPC 领取奖励
    --ugcprint("[TASK] 调用服务器领取任务4奖励")
    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end
---刷新任务5显示
---@param playerState ASTExtraPlayerState
function TASK:RefreshTask5(playerState)
    local taskRowIndex = 5
    
    -- 获取任务状态 (0:未完成, 1:可领取, 2:已领取)
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    --ugcprint(string.format("[TASK] 任务%d状态: %d (%s)", taskRowIndex, taskStatus, TASK_STATUS_TEXT[taskStatus] or "未知"))
    
    -- 设置任务状态图片
    SetTaskStatusImage(self.Image_buttun5, taskStatus)
    
    -- 设置按钮是否可点击 (只有"可领取"状态才能点击)
    if self.Button_5 then
        self.Button_5:SetIsEnabled(taskStatus == 1)
    end
end
---任务5领取按钮点击
function TASK:OnButton5Clicked()
    --ugcprint("[TASK] 点击领取任务5")
    
    local playerState = self:GetLocalPlayerState()
    if not playerState then
        --ugcprint("[TASK] 无法获取 PlayerState")
        return
    end
    
    local taskRowIndex = 5
    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    
    -- 检查是否可领取
    if taskStatus ~= 1 then
        --ugcprint("[TASK] 任务5不可领取")
        return
    end
    
    -- 调用服务器 RPC 领取奖励
    --ugcprint("[TASK] 调用服务器领取任务5奖励")
    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end
---关闭按钮点击
function TASK:OnCancelClicked()
    --ugcprint("[TASK] 点击关闭按钮")
    
    -- 判断是否在视口中（动态创建模式）还是嵌入组件
    if self:IsInViewport() then
        -- 检查是否有父组件（嵌入模式的标志）
        local parent = self:GetParent()
        --ugcprint("[TASK] 父组件: " .. tostring(parent))
        
        if parent then
            -- 嵌入模式：隐藏任务面板
            self:SetVisibility(ESlateVisibility.Collapsed)
            --ugcprint("[TASK] 嵌入模式：任务面板已隐藏")
        else
            -- 动态创建模式：从视口移除
            -- 清空 taskbuttun 的引用
            local pc = UGCGameSystem.GetLocalPlayerController()
            if pc and pc.TaskButtonUI then
                pc.TaskButtonUI.TaskUI = nil
            end
            self:RemoveFromParent()
            --ugcprint("[TASK] 动态模式：已从视口移除")
        end
    else
        -- 嵌入模式：隐藏任务面板
        self:SetVisibility(ESlateVisibility.Collapsed)
        --ugcprint("[TASK] 任务面板已隐藏")
    end
end
---获取本地玩家的 PlayerState
---@return ASTExtraPlayerState|nil
function TASK:GetLocalPlayerState()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        return UGCGameSystem.GetPlayerStateByPlayerController(pc)
    end
    return nil
end
---获取本地玩家的 Pawn
---@return ASTExtraPlayerCharacter|nil
function TASK:GetLocalPlayerPawn()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        return pc:K2_GetPawn()
    end
    return nil
end
function TASK:Destruct()
    --ugcprint("[TASK] UI Destruct")
end
-- [Editor Generated Lua] function define Begin:
function TASK:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	-- [Editor Generated Lua] BindingEvent End;
end
-- [Editor Generated Lua] function define End;
return TASK