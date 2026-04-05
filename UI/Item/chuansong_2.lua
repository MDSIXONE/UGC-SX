---@class chuansong_2_C:UUserWidget
---@field CanvasPanel_0 UCanvasPanel
---@field fuben1 UButton
---@field fuben1_Text UTextBlock
---@field fuben2 UButton
---@field fuben2_Text UTextBlock
---@field fuben3 UButton
---@field fuben3_Text UTextBlock
---@field fuben4 UButton
---@field fuben4_Text UTextBlock
---@field HorizontalBox_135 UHorizontalBox
---@field Image_53 UImage
---@field Image_54 UImage
---@field Image_55 UImage
---@field Image_56 UImage
---@field ImageEx_25 UImageEx
---@field Zhuansheng_cancel UButton
--Edit Below--
local chuansong = { bInitDoOnce = false }

-- 隐藏所有控件
function chuansong:HideAllButtons()
	if self.fuben1 then self.fuben1:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben1_Text then self.fuben1_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben2 then self.fuben2:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben2_Text then self.fuben2_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben3 then self.fuben3:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben3_Text then self.fuben3_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben4 then self.fuben4:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben4_Text then self.fuben4_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben5 then self.fuben5:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Collapsed) end
	if self.Zhuansheng_cancel then self.Zhuansheng_cancel:SetVisibility(ESlateVisibility.Collapsed) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Collapsed) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Collapsed) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Collapsed) end
end

-- 显示所有控件
function chuansong:ShowAllButtons()
	if self.fuben1 then self.fuben1:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben1_Text then self.fuben1_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben2 then self.fuben2:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben2_Text then self.fuben2_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben3 then self.fuben3:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben3_Text then self.fuben3_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben4 then self.fuben4:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben4_Text then self.fuben4_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben5 then self.fuben5:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Visible) end
	if self.Zhuansheng_cancel then self.Zhuansheng_cancel:SetVisibility(ESlateVisibility.Visible) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Visible) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Visible) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Visible) end
end

function chuansong:Construct()
	self:LuaInit();
	-- 初始化时隐藏所有按钮
	self:HideAllButtons()
end

-- function chuansong:Tick(MyGeometry, InDeltaTime)
-- end

-- function chuansong:Destruct()
-- end

-- [Editor Generated Lua] function define Begin:
function chuansong:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	if self.fuben1 then self.fuben1.OnClicked:Add(self.fuben1_OnClicked, self) end
	if self.fuben2 then self.fuben2.OnClicked:Add(self.fuben2_OnClicked, self) end
	if self.fuben3 then self.fuben3.OnClicked:Add(self.fuben3_OnClicked, self) end
	if self.fuben4 then self.fuben4.OnClicked:Add(self.fuben4_OnClicked, self) end
	if self.fuben5 then self.fuben5.OnClicked:Add(self.fuben5_OnClicked, self) end
	if self.fuben6 then self.fuben6.OnClicked:Add(self.fuben6_OnClicked, self) end
	-- 绑定取消按钮事件
	if self.Zhuansheng_cancel then
		self.Zhuansheng_cancel.OnClicked:Add(self.Zhuansheng_cancel_OnClicked, self)
	end
	-- [Editor Generated Lua] BindingEvent End;
end

-- 通用传送函数 - 通过 RPC 发送到服务器执行
-- @param x 目标位置 X 坐标
-- @param y 目标位置 Y 坐标
-- @param z 目标位置 Z 坐标
-- @param yaw 目标朝向角度（可选，不传则不改变朝向）
function chuansong:TeleportToLocation(x, y, z, yaw)
    --ugcprint("chuansong: TeleportToLocation 开始")
    --ugcprint("chuansong: 目标位置 X=" .. x .. " Y=" .. y .. " Z=" .. z .. " Yaw=" .. tostring(yaw or "无"))
    
    local ok, err = pcall(function()
        -- 获取本地玩家控制器
        local PlayerController = UGCGameSystem.GetLocalPlayerController()
        if not PlayerController then
            --ugcprint("chuansong: 错误 - 无法获取 PlayerController")
            return
        end
        
        -- 通过 RPC 调用服务器传送
        --ugcprint("chuansong: 调用 Server_TeleportPlayer RPC")
        if yaw then
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z, yaw)
        else
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z)
        end
        --ugcprint("chuansong: 已发送传送请求到服务器")
    end)
    
    if not ok then
        --ugcprint("chuansong: 发送传送请求失败: " .. tostring(err))
    end
    
    -- 传送后隐藏传送界面
    self:HideAllButtons()
    
    -- 显示传送按钮
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun_2 then
        pc.MMainUI.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
    end
end

-- 获取玩家转生次数
function chuansong:GetPlayerRebirthCount()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if ps then
            -- 优先使用复制属性
            return ps.UGCPlayerRebirthCount or (ps.GameData and ps.GameData.PlayerRebirthCount) or 0
        end
    end
    return 0
end

-- 检查是否满足传送条件
function chuansong:CheckRebirthRequirement(requiredRebirth, fubenName)
    local rebirthCount = self:GetPlayerRebirthCount()
    if rebirthCount < requiredRebirth then
        --ugcprint("chuansong: " .. fubenName .. " 需要转生 " .. requiredRebirth .. " 次，当前转生次数: " .. rebirthCount)
        -- 可以在这里添加提示UI
        return false
    end
    return true
end

function chuansong:fuben1_OnClicked()
    --ugcprint("chuansong: fuben1 被点击")
    -- fuben1 需要转生 >= 1 次
    if not self:CheckRebirthRequirement(1, "fuben1") then
        return
    end
    self:TeleportToLocation(19036.871094, 50498.203125, 621.236023, 90)
end

function chuansong:fuben2_OnClicked()
    --ugcprint("chuansong: fuben2 被点击")
    -- fuben2 需要转生 >= 2 次
    if not self:CheckRebirthRequirement(2, "fuben2") then
        return
    end
    self:TeleportToLocation(141600.15625, -7472.247559, 287.76004, 90)
end

function chuansong:fuben3_OnClicked()
    --ugcprint("chuansong: fuben3 被点击")
    -- fuben3 需要转生 >= 3 次
    if not self:CheckRebirthRequirement(3, "fuben3") then
        return
    end
    self:TeleportToLocation(61460.460938, 10271.99707, 1646.93457, 90)
end

function chuansong:fuben4_OnClicked()
    --ugcprint("chuansong: fuben4 被点击")
    -- fuben4 需要转生 >= 4 次
    if not self:CheckRebirthRequirement(4, "fuben4") then
        return
    end
    self:TeleportToLocation(42936.683594, 135209.75, 15358.039062, 90)
end

function chuansong:fuben5_OnClicked()
    self:TeleportToLocation(18670.0, 24520.0, 200.0, 90)
end

function chuansong:fuben6_OnClicked()
    self:TeleportToLocation(18670.0, 24520.0, 200.0)
end

-- 取消按钮点击事件处理
function chuansong:Zhuansheng_cancel_OnClicked()
	--ugcprint("chuansong_2: 取消按钮被点击")
	-- 隐藏所有按钮
	self:HideAllButtons()

	-- 通过 PlayerController 获取 MMainUI
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun_2 then
		--ugcprint("chuansong_2: 找到 MMainUI，显示传送按钮")
		pc.MMainUI.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
	else
		--ugcprint("chuansong_2: 错误 - 无法找到 MMainUI")
	end
end

-- [Editor Generated Lua] function define End;

return chuansong