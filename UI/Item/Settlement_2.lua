---@class Settlement_2_C:UUserWidget
---@field Image_0 UImage
--Edit Below--
local Settlement_2 = { bInitDoOnce = false }

function Settlement_2:Construct()
	ugcprint("[Settlement_2] Construct 被调用")
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
	
	-- 隐藏sure按钮(不再需要)
	if self.sure then
		self.sure:SetVisibility(ESlateVisibility.Collapsed)
		ugcprint("[Settlement_2] sure 按钮已隐藏")
	end
end

-- 执行后续流程
function Settlement_2:ExecuteNextStep()
	ugcprint("[Settlement_2] 立即执行后续流程")
	
	-- 不关闭UI,直接通知执行后续流程
	if self.OnSureClicked then
		self.OnSureClicked()
	end
end

return Settlement_2