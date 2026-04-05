---@class Settlement_2_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local Settlement_2 = { bInitDoOnce = false }

function Settlement_2:Construct()
	-- ugcprint("[Settlement_2] Construct 琚皟鐢?)
	self:LuaInit()
	
	-- 鏄剧ず鍚庣珛鍗虫墽琛屽悗缁祦绋?
	self:ExecuteNextStep()
end

function Settlement_2:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- ugcprint("[Settlement_2] LuaInit 瀹屾垚")
	
	-- 闅愯棌sure鎸夐挳(涓嶅啀闇€瑕?
	if self.sure then
		self.sure:SetVisibility(ESlateVisibility.Collapsed)
		-- ugcprint("[Settlement_2] sure 鎸夐挳宸查殣钘?)
	end
end

-- 鎵ц鍚庣画娴佺▼
function Settlement_2:ExecuteNextStep()
	-- ugcprint("[Settlement_2] 绔嬪嵆鎵ц鍚庣画娴佺▼")
	
	-- 涓嶅叧闂璘I,鐩存帴閫氱煡鎵ц鍚庣画娴佺▼
	if self.OnSureClicked then
		self.OnSureClicked()
	end
end

return Settlement_2
