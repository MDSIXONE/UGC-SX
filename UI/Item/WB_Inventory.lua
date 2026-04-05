---@class WB_Inventory_C:UUserWidget
---@field Button_0 UButton
---@field cancel UButton
---@field detail UOverlay
---@field Image_0 UImage
---@field Image_2 UImage
---@field itemname UTextBlock
---@field page0 UButton
---@field page1 UButton
---@field page2 UButton
---@field page3 UButton
---@field page4 UButton
---@field page5 UButton
---@field page6 UButton
---@field ScrollBox_0 UScrollBox
---@field WrapBox_0 UWrapBox
---@field WrapBox_1 UWrapBox
---@field WrapBox_2 UWrapBox
--Edit Below--
local WB_Inventory = { bInitDoOnce = false } 

-- 引入UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Inventory:Construct()
	--ugcprint("[WB_Inventory] Construct 被调用")
	
	-- 初始化当前页签（默认显示page0）
	self.CurrentPage = "page0"
	
	self:LuaInit()
	
	-- 隐藏详情区域（一开始没有选择物品）
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
		--ugcprint("[WB_Inventory] 详情区域已隐藏")
	end
	
	-- 设置WrapBox_0一排最多4个
	if self.WrapBox_0 then
		self.WrapBox_0:SetInnerSlotPadding(Vector2D.New(5, 5))
		self.WrapBox_0.bExplicitWrapSize = true
		self.WrapBox_0.WrapSize = 400
	end

	-- 动态创建合成槽位
	self:CreateCraftSlots()
end

-- [Editor Generated Lua] function define Begin:
function WB_Inventory:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	--ugcprint("[WB_Inventory] LuaInit 完成")
	
	-- 绑定合成按钮点击事件
	if self.Button_0 then
		self.Button_0.OnPressed:Add(self.OnCraftButtonClicked, self)
		--ugcprint("[WB_Inventory] Button_0 点击事件绑定成功")
	else
		--ugcprint("[WB_Inventory] 警告：未找到 Button_0")
	end
	
	-- 绑定取消按钮点击事件
	if self.cancel then
		self.cancel.OnPressed:Add(self.OnCancelButtonClicked, self)
		--ugcprint("[WB_Inventory] cancel 点击事件绑定成功")
	else
		--ugcprint("[WB_Inventory] 警告：未找到 cancel")
	end
	
	-- 绑定页签按钮点击事件
	if self.page0 then
		self.page0.OnPressed:Add(function()
			self:SwitchPage("page0")
		end, self)
		--ugcprint("[WB_Inventory] page0 点击事件绑定成功")
	end
	
	if self.page1 then
		self.page1.OnPressed:Add(function()
			self:SwitchPage("page1")
		end, self)
		--ugcprint("[WB_Inventory] page1 点击事件绑定成功")
	end
	
	if self.page2 then
		self.page2.OnPressed:Add(function()
			self:SwitchPage("page2")
		end, self)
		--ugcprint("[WB_Inventory] page2 点击事件绑定成功")
	end
	
	if self.page3 then
		self.page3.OnPressed:Add(function()
			self:SwitchPage("page3")
		end, self)
	end
	
	if self.page4 then
		self.page4.OnPressed:Add(function()
			self:SwitchPage("page4")
		end, self)
	end
	
	if self.page5 then
		self.page5.OnPressed:Add(function()
			self:SwitchPage("page5")
		end, self)
	end
	
	if self.page6 then
		self.page6.OnPressed:Add(function()
			self:SwitchPage("page6")
		end, self)
	end
end
-- [Editor Generated Lua] function define End;

-- 动态创建合成槽位
function WB_Inventory:CreateCraftSlots()
	--ugcprint("[WB_Inventory] 开始创建合成槽位，当前页签: " .. tostring(self.CurrentPage))
	
	-- 获取所有配方
	local allRecipes = UGCGameData.GetAllRecipeConfig()
	if not allRecipes then
		--ugcprint("[WB_Inventory] 错误：无法获取配方表")
		return
	end
	
	-- 将配方转换为数组并读取顺序和页签
	local recipeArray = {}
	for recipeName, recipeData in pairs(allRecipes) do
		local order = recipeData["顺序"] or 999  -- 如果没有顺序字段，默认排在最后
		local page = recipeData["页签"]
		
		-- 将页签转换为字符串格式（page0, page1, page2）
		local pageStr = "page0"  -- 默认page0
		if page ~= nil then
			pageStr = "page" .. tostring(page)
		end
		
		--ugcprint("[WB_Inventory] 配方: " .. tostring(recipeName) .. ", 顺序: " .. tostring(order) .. ", 页签原始值: " .. tostring(page) .. ", 转换后: " .. pageStr)
		
		-- 只添加当前页签的配方
		if pageStr == self.CurrentPage then
			table.insert(recipeArray, {
				name = recipeName,
				order = order,
				page = pageStr,
				data = recipeData
			})
			--ugcprint("[WB_Inventory] 添加配方到当前页签")
		end
	end
	
	-- 按顺序排序（数字越小越靠前）
	table.sort(recipeArray, function(a, b)
		return a.order < b.order
	end)
	
	--ugcprint("[WB_Inventory] 当前页签配方总数: " .. #recipeArray)
	
	-- 清空WrapBox（如果有默认的WB_Slot，先移除）
	if self.WrapBox_1 then
		self.WrapBox_1:ClearChildren()
		--ugcprint("[WB_Inventory] 已清空WrapBox")
	else
		--ugcprint("[WB_Inventory] 错误：未找到WrapBox_1")
		return
	end
	
	-- 获取WB_Slot类
	local slotPath = 'Asset/UI/Item/WB_Slot.WB_Slot_C'
	local fullPath = UGCGameSystem.GetUGCResourcesFullPath(slotPath)
	--ugcprint("[WB_Inventory] 尝试加载WB_Slot，路径: " .. tostring(fullPath))
	
	local SlotClass = UGCObjectUtility.LoadClass(fullPath)
	if not SlotClass then
		--ugcprint("[WB_Inventory] 错误：无法加载WB_Slot类，完整路径: " .. tostring(fullPath))
		return
	end
	--ugcprint("[WB_Inventory] WB_Slot类加载成功")
	
	-- 获取玩家控制器
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		--ugcprint("[WB_Inventory] 错误：无法获取玩家控制器")
		return
	end
	
	-- 为每个配方创建一个WB_Slot（按排序后的顺序）
	for i, recipe in ipairs(recipeArray) do
		-- 创建WB_Slot实例
		local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
		if slotWidget then
			-- 设置配方ID
			slotWidget.RecipeID = recipe.name
			--ugcprint("[WB_Inventory] 创建槽位 " .. i .. "，配方ID: " .. recipe.name .. ", 顺序: " .. recipe.order)
			
			-- 添加到WrapBox
			self.WrapBox_1:AddChild(slotWidget)
		else
			--ugcprint("[WB_Inventory] 错误：无法创建槽位 " .. i)
		end
	end
	
	--ugcprint("[WB_Inventory] 合成槽位创建完成，共创建 " .. #recipeArray .. " 个槽位")
end

-- 切换页签
function WB_Inventory:SwitchPage(pageName)
	--ugcprint("[WB_Inventory] 切换页签到: " .. tostring(pageName))
	
	if self.CurrentPage == pageName then
		--ugcprint("[WB_Inventory] 已经在当前页签，无需切换")
		return
	end
	
	self.CurrentPage = pageName
	
	-- 清空详情显示
	self:ClearDetailSlots()
	self.CurrentRecipeData = nil
	
	-- 隐藏详情区域
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
		--ugcprint("[WB_Inventory] 详情区域已隐藏")
	end
	
	-- 重新创建槽位
	self:CreateCraftSlots()
end

-- 显示合成详情
function WB_Inventory:ShowCraftDetails(recipeData)
	if not recipeData then
		--ugcprint("[WB_Inventory] 错误：配方数据为空")
		return
	end
	
	--ugcprint("[WB_Inventory] 显示合成详情，配方ID: " .. tostring(recipeData.RecipeID))
	
	-- 显示详情区域
	if self.detail then
		self.detail:SetVisibility(0)  -- 0 = Visible
		--ugcprint("[WB_Inventory] 详情区域已显示")
	end
	
	-- 显示物品名称
	if self.itemname and recipeData.VirtualOutputItemID then
		local itemConfig = UGCGameData.GetItemConfig(recipeData.VirtualOutputItemID)
		if itemConfig and itemConfig.ItemName then
			self.itemname:SetText(tostring(itemConfig.ItemName))
		else
			self.itemname:SetText("")
		end
	end
	
	-- 保存当前选中的配方数据
	self.CurrentRecipeData = recipeData
	
	-- 清空并重新创建详情槽位
	self:ClearDetailSlots()
	self:CreateDetailSlots(recipeData)
end

-- 清空详情槽位
function WB_Inventory:ClearDetailSlots()
	-- 清空WrapBox_0（输出材料）
	if self.WrapBox_0 then
		self.WrapBox_0:ClearChildren()
		--ugcprint("[WB_Inventory] 已清空WrapBox_0（输出材料）")
	end
	
	-- 清空WrapBox_2（输入材料）
	if self.WrapBox_2 then
		self.WrapBox_2:ClearChildren()
		--ugcprint("[WB_Inventory] 已清空WrapBox_2（输入材料）")
	end
end

-- 创建详情槽位
function WB_Inventory:CreateDetailSlots(recipeData)
	-- 创建输出材料槽位（WrapBox_0）
	if self.WrapBox_0 and recipeData.VirtualOutputItemID then
		--ugcprint("[WB_Inventory] 创建输出材料槽位")
		local outputSlot = self:CreateDisplaySlot(recipeData.VirtualOutputItemID, recipeData.OutputCount, false)
		if outputSlot then
			self.WrapBox_0:AddChild(outputSlot)
			--ugcprint("[WB_Inventory] 输出材料槽位已添加")
		end
	end
	
	-- 创建输入材料槽位（WrapBox_2）- 支持多个材料
	if self.WrapBox_2 and recipeData.InputMaterials then
		--ugcprint("[WB_Inventory] 创建输入材料槽位，材料数量: " .. tostring(#recipeData.InputMaterials))
		
		for i, material in ipairs(recipeData.InputMaterials) do
			--ugcprint("[WB_Inventory] 创建材料 " .. i .. " 槽位")
			local inputSlot = self:CreateDisplaySlot(material.VirtualItemID, material.Count, true)
			if inputSlot then
				self.WrapBox_2:AddChild(inputSlot)
				--ugcprint("[WB_Inventory] 材料 " .. i .. " 槽位已添加")
			end
		end
	end
end

-- 创建显示用的槽位（使用WB_Slot_2）
function WB_Inventory:CreateDisplaySlot(virtualItemID, count, isInput)
	--ugcprint("[WB_Inventory] 加载 WB_Slot_2 类")
	
	-- 加载WB_Slot_2类
	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
	if not SlotClass then
		--ugcprint("[WB_Inventory] 错误：无法加载 WB_Slot_2 类")
		return nil
	end
	
	-- 创建槽位实例
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
	if not slotWidget then
		--ugcprint("[WB_Inventory] 错误：无法创建槽位实例")
		return nil
	end
	
	-- 设置显示数据
	slotWidget.DisplayItemID = virtualItemID
	slotWidget.DisplayCount = count
	slotWidget.IsInputItem = isInput
	
	--ugcprint("[WB_Inventory] 创建显示槽位 - 虚拟ID: " .. tostring(virtualItemID) .. ", 数量: " .. tostring(count) .. ", 是否输入: " .. tostring(isInput))
	
	-- 手动调用LoadDisplayData来加载数据
	slotWidget:LoadDisplayData()
	
	return slotWidget
end

-- 合成按钮点击事件
function WB_Inventory:OnCraftButtonClicked()
	ugcprint("[WB_Inventory] ========== 合成按钮被点击 ==========")
	
	if not self.CurrentRecipeData then
		ugcprint("[WB_Inventory] 错误：没有选中配方")
		return
	end
	
	ugcprint("[WB_Inventory] 配方ID: " .. tostring(self.CurrentRecipeData.RecipeID))
	ugcprint("[WB_Inventory] 输出物品ID: " .. tostring(self.CurrentRecipeData.OutputItemID) .. " x " .. tostring(self.CurrentRecipeData.OutputCount))
	
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		ugcprint("[WB_Inventory] 错误：获取玩家控制器失败")
		return
	end
	
	local recipeData = self.CurrentRecipeData
	
	-- 检查所有输入材料是否充足
	if not recipeData.InputMaterials or #recipeData.InputMaterials == 0 then
		ugcprint("[WB_Inventory] 错误：没有输入材料")
		return
	end
	
	ugcprint("[WB_Inventory] 材料总数: " .. tostring(#recipeData.InputMaterials))
	
	-- 检查每个材料的数量
	local allEnough = true
	for i, material in ipairs(recipeData.InputMaterials) do
		local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
		ugcprint("[WB_Inventory] 材料 " .. i .. " - ID:" .. tostring(material.RealItemID) .. " 需要:" .. material.Count .. " 当前:" .. currentCount)
		
		if currentCount < material.Count then
			ugcprint("[WB_Inventory] 材料 " .. i .. " 数量不足")
			allEnough = false
		end
	end
	
	if not allEnough then
		ugcprint("[WB_Inventory] 合成失败：材料不足")
		return
	end
	
	-- 获取PlayerState
	local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
	if not PlayerState then
		ugcprint("[WB_Inventory] 错误：无法获取PlayerState")
		return
	end
	
	-- 构建材料列表（传递给服务器）
	local inputItemIDs = {}
	local inputCounts = {}
	for i, material in ipairs(recipeData.InputMaterials) do
		table.insert(inputItemIDs, material.RealItemID)
		table.insert(inputCounts, material.Count)
	end
	
	ugcprint("[WB_Inventory] 发送RPC - 输入ID: " .. table.concat(inputItemIDs, ",") .. " 数量: " .. table.concat(inputCounts, ",") .. " 输出: " .. tostring(recipeData.OutputItemID) .. " x " .. tostring(recipeData.OutputCount))
	
	-- 调用服务器RPC执行合成
	UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_CraftItem", inputItemIDs, inputCounts, recipeData.OutputItemID, recipeData.OutputCount)
	ugcprint("[WB_Inventory] ✓ RPC已发送")
end

-- 取消按钮点击事件
function WB_Inventory:OnCancelButtonClicked()
	--ugcprint("[WB_Inventory] 取消按钮被点击，隐藏界面")
	self:SetVisibility(ESlateVisibility.Collapsed)
	local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
	if MainControlPanel then
		UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
		UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
	end
	local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
	if SkillPanel then
		UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
	end
end

-- function WB_Inventory:Tick(MyGeometry, InDeltaTime)

-- end

-- function WB_Inventory:Destruct()

-- end

return WB_Inventory