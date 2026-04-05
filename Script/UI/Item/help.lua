---@class help_C:UUserWidget
---@field help_cancel UButton
---@field Image_0 UImage
--Edit Below--
local help = { bInitDoOnce = false } 

function help:Construct()
	self:LuaInit()
	-- 初始化时隐藏
	self:SetVisibility(ESlateVisibility.Collapsed)
end

function help:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- 绑定取消按钮事件
	if self.help_cancel then
		self.help_cancel.OnClicked:Add(self.help_cancel_OnClicked, self)
	end
end

-- 取消按钮点击事件
function help:help_cancel_OnClicked()
	--ugcprint("help: 取消按钮被点击")
	self:SetVisibility(ESlateVisibility.Collapsed)
end

-- function help:Tick(MyGeometry, InDeltaTime)

-- end

-- function help:Destruct()

-- end

return help