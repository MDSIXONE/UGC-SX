---@class Settlement_2_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local Settlement_2 = { bInitDoOnce = false }

function Settlement_2:Construct()
	ugcprint("[Settlement_2] Construct 被调用, self=" .. tostring(self))
	self:LuaInit()
	
	-- 显示后立即执行后续流程
	self:ExecuteNextStep()
end

function Settlement_2:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	ugcprint("[Settlement_2] LuaInit 完成")
end

-- 执行后续流程
function Settlement_2:ExecuteNextStep()
	ugcprint("[Settlement_2] 立即执行后续流程, self=" .. tostring(self))
	
	-- 不关闭UI,直接通知执行后续流程
	if self.OnSureClicked then
		ugcprint("[Settlement_2] OnSureClicked 存在，准备执行, self=" .. tostring(self))
		self.OnSureClicked()
	else
		ugcprint("[Settlement_2] OnSureClicked 为空，本次仅为UI初始化, self=" .. tostring(self))
	end
end

return Settlement_2