---@class shouna_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field Image_1 UImage
--Edit Below--
local shouna = { bInitDoOnce = false } 

function shouna:Construct()
	--ugcprint("[shouna] ========== Construct 开始 ==========")
	self:LuaInit()
	--ugcprint("[shouna] ========== Construct 完成 ==========")
end

function shouna:LuaInit()
	if self.bInitDoOnce then
		--ugcprint("[shouna] LuaInit 已经执行过，跳过")
		return
	end
	self.bInitDoOnce = true
	
	--ugcprint("[shouna] LuaInit 开始")
	
	-- 检查组件是否存在
	if self.Button_0 then
		--ugcprint("[shouna] Button_0 存在，准备绑定事件")
		self.Button_0.OnPressed:Add(self.OnButtonClicked, self)
		--ugcprint("[shouna] Button_0 事件绑定完成")
	else
		--ugcprint("[shouna] 错误：Button_0 不存在")
	end
	
	if self.Image_0 then
		--ugcprint("[shouna] Image_0 存在")
	else
		--ugcprint("[shouna] 错误：Image_0 不存在")
	end
	
	if self.Image_1 then
		--ugcprint("[shouna] Image_1 存在")
	else
		--ugcprint("[shouna] 错误：Image_1 不存在")
	end
	
	--ugcprint("[shouna] LuaInit 完成")
end

function shouna:OnButtonClicked()
	--ugcprint("[shouna] ========== 按钮被点击 ==========")
	
	local pc = UGCGameSystem.GetLocalPlayerController()
	if not pc then
		--ugcprint("[shouna] 错误：无法获取 PlayerController")
		return
	end
	--ugcprint("[shouna] 成功获取 PlayerController: " .. tostring(pc))
	
	if not pc.MMainUI then
		--ugcprint("[shouna] 错误：MMainUI 不存在")
		return
	end
	--ugcprint("[shouna] 成功获取 MMainUI: " .. tostring(pc.MMainUI))
	
	if pc.MMainUI.ToggleShounaButtons then
		--ugcprint("[shouna] 调用 ToggleShounaButtons")
		pc.MMainUI:ToggleShounaButtons()
	else
		--ugcprint("[shouna] 错误：ToggleShounaButtons 方法不存在")
	end
end

return shouna