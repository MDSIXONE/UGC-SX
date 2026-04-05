---@class chuansong_C:UUserWidget
---@field CanvasPanel_0 UCanvasPanel
---@field fuben1 UButton
---@field fuben1_Text UTextBlock
---@field fuben2 UButton
---@field fuben2_Text UTextBlock
---@field fuben3 UButton
---@field fuben3_Text暗影城堡 UTextBlock
---@field fuben4 UButton
---@field fuben4_Text UTextBlock
---@field fuben5 UButton
---@field fuben5_Text UTextBlock
---@field fuben6 UButton
---@field fuben6_Text UTextBlock
---@field fuben_cansel General_SecondLevelButton_3_C
---@field HorizontalBox_135 UHorizontalBox
---@field ImageEx_25 UImageEx
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
	if self.fuben5_Text then self.fuben5_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben6_Text then self.fuben6_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben_cansel then self.fuben_cansel:SetVisibility(ESlateVisibility.Collapsed) end
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
	if self.fuben5_Text then self.fuben5_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben6_Text then self.fuben6_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben_cansel then self.fuben_cansel:SetVisibility(ESlateVisibility.Visible) end
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
	self.fuben1.OnClicked:Add(self.fuben1_OnClicked, self);
	self.fuben2.OnClicked:Add(self.fuben2_OnClicked, self);
	self.fuben3.OnClicked:Add(self.fuben3_OnClicked, self);
	self.fuben4.OnClicked:Add(self.fuben4_OnClicked, self);
	self.fuben5.OnClicked:Add(self.fuben5_OnClicked, self);
	self.fuben6.OnClicked:Add(self.fuben6_OnClicked, self);
	-- 绑定取消按钮事件
	if self.fuben_cansel then
		self.fuben_cansel.Button_Levels2_3.OnClicked:Add(self.fuben_cancel_OnClicked, self);
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
    if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun then
        pc.MMainUI.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
    end
end

function chuansong:fuben1_OnClicked()
    --ugcprint("chuansong: fuben1 被点击")
    self:TeleportToLocation(181548.640625, 123572.679688, 523.233398, 180)
end

function chuansong:fuben2_OnClicked()
    self:TeleportToLocation(19060.339844, 45293.621094, 1091.622925, 270)
end

function chuansong:fuben3_OnClicked()
    self:TeleportToLocation(145806.609375, -7294.645508, 373.386414, 360)
end

function chuansong:fuben4_OnClicked()
    self:TeleportToLocation(50184.515625, 130875.375, 239.292038, 180)
end

function chuansong:fuben5_OnClicked()
    self:TeleportToLocation(87271.648438, 68284.21875, 271.10553, 270)
end

function chuansong:fuben6_OnClicked()
    -- self:TeleportToLocation(18670.0, 24520.0, 200.0)
end

-- 添加取消按钮点击事件处理
function chuansong:fuben_cancel_OnClicked()
	--ugcprint("chuansong: 取消按钮被点击")
	-- 隐藏所有按钮
	self:HideAllButtons()
	
	-- 通过 PlayerController 获取 MMainUI（因为这些是兄弟组件，不是父子关系）
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun then
		--ugcprint("chuansong: 找到 MMainUI，显示传送按钮")
		pc.MMainUI.chuansongbuttun:SetVisibility(ESlateVisibility.Visible)
	else
		--ugcprint("chuansong: 错误 - 无法找到 MMainUI")
	end
end

-- [Editor Generated Lua] function define End;

return chuansong