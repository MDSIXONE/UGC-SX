---@class WB_Inventory_C:UUserWidget
---@field Button_0 UButton
---@field cancel UButton
---@field detail UOverlay
---@field fenjieorhecheng UNewButton
---@field horfbuttun UTextBlock
---@field HorizontalBox_1 UHorizontalBox
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
---@field TextBlock_2 UTextBlock
---@field tip tip_C
---@field WrapBox_0 UWrapBox
---@field WrapBox_1 UWrapBox
---@field WrapBox_2 UWrapBox
--Edit Below--
local WB_Inventory = { bInitDoOnce = false } 

-- Local helper value for this logic block.
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Inventory:Construct()
	-- Keep this section consistent with the original UI flow.
	
	-- Keep this section consistent with the original UI flow.
	self.CurrentPage = "page0"
	-- Keep this section consistent with the original UI flow.
	self.IsFenjieMode = false
	
	self:LuaInit()
	
	-- Guard condition before running this branch.
	if self.horfbuttun then
		self.horfbuttun:SetText("合成")
	end
	
	-- Guard condition before running this branch.
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
	end

	-- Guard condition before running this branch.
	if self.itemname then
		self.itemname:SetVisibility(ESlateVisibility.Collapsed)
	end
	if self.HorizontalBox_1 then
		self.HorizontalBox_1:SetVisibility(ESlateVisibility.Collapsed)
	end
	
	-- Guard condition before running this branch.
	if self.WrapBox_0 then
		self.WrapBox_0:SetInnerSlotPadding(Vector2D.New(5, 5))
		self.WrapBox_0.bExplicitWrapSize = true
		self.WrapBox_0.WrapSize = 400
	end

	-- Execute the next UI update step.
	self:CreateCraftSlots()
end

-- [Editor Generated Lua] function define Begin:
function WB_Inventory:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.Button_0 then
		self.Button_0.OnPressed:Add(self.OnCraftButtonClicked, self)
		-- Continue registering UI interaction callbacks.
	else
		-- Keep this section consistent with the original UI flow.
	end
	
	-- Guard condition before running this branch.
	if self.cancel then
		self.cancel.OnPressed:Add(self.OnCancelButtonClicked, self)
		-- Continue registering UI interaction callbacks.
	else
		-- Keep this section consistent with the original UI flow.
	end
	
	-- Guard condition before running this branch.
	if self.fenjieorhecheng then
		self.fenjieorhecheng.OnPressed:Add(self.OnFenjieOrHechengClicked, self)
		-- Continue registering UI interaction callbacks.
	else
		-- Keep this section consistent with the original UI flow.
	end
	
	-- Guard condition before running this branch.
	if self.page0 then
		self.page0.OnPressed:Add(function()
			self:SwitchPage("page0")
		end, self)
		-- Keep this section consistent with the original UI flow.
	end
	
	if self.page1 then
		self.page1.OnPressed:Add(function()
			self:SwitchPage("page1")
		end, self)
		-- Keep this section consistent with the original UI flow.
	end
	
	if self.page2 then
		self.page2.OnPressed:Add(function()
			self:SwitchPage("page2")
		end, self)
		-- Keep this section consistent with the original UI flow.
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

-- Create craft slots.
function WB_Inventory:CreateCraftSlots()
	-- Local helper value for this logic block.
	
	-- Local helper value for this logic block.
	local allRecipes = nil
	if self.IsFenjieMode then
		allRecipes = UGCGameData.GetAllFenjieConfig()
		if not allRecipes then
			-- Exit early when requirements are not met.
			return
		end
	else
		allRecipes = UGCGameData.GetAllRecipeConfig()
		if not allRecipes then
			-- Exit early when requirements are not met.
			return
		end
	end
	
	-- Configuration table used by this widget.
	local recipeArray = {}
	for recipeName, recipeData in pairs(allRecipes) do
		local order = recipeData["顺序"] or 999
		local page = recipeData["页签"]
		
		local pageStr = "page0"
		if page ~= nil then
			pageStr = "page" .. tostring(page)
		end
		
		-- Guard condition before running this branch.
		if pageStr == self.CurrentPage then
			table.insert(recipeArray, {
				name = recipeName,
				order = order,
				page = pageStr,
				data = recipeData
			})
		end
	end
	
	-- Keep this section consistent with the original UI flow.
	table.sort(recipeArray, function(a, b)
		return a.order < b.order
	end)
	
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.WrapBox_1 then
		self.WrapBox_1:ClearChildren()
	else
		-- Exit early when requirements are not met.
		return
	end
	
	-- Local helper value for this logic block.
	local slotPath = 'Asset/UI/Item/WB_Slot.WB_Slot_C'
	local fullPath = UGCGameSystem.GetUGCResourcesFullPath(slotPath)
	local SlotClass = UGCObjectUtility.LoadClass(fullPath)
	if not SlotClass then
		-- Exit early when requirements are not met.
		return
	end
	
	-- Acquire local player references.
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- Exit early when requirements are not met.
		return
	end
	
	-- Iterate through related data or widgets.
	for i, recipe in ipairs(recipeArray) do
		local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
		if slotWidget then
			slotWidget.RecipeID = recipe.name
			-- Keep this section consistent with the original UI flow.
			slotWidget.IsFenjieMode = self.IsFenjieMode
			self.WrapBox_1:AddChild(slotWidget)
		else
			-- Keep this section consistent with the original UI flow.
		end
	end
	
	-- Keep this section consistent with the original UI flow.
end

-- Switch page.
function WB_Inventory:SwitchPage(pageName)
	-- Guard condition before running this branch.
	
	if self.CurrentPage == pageName then
		-- Exit early when requirements are not met.
		return
	end
	
	self.CurrentPage = pageName
	
	-- Execute the next UI update step.
	self:ClearDetailSlots()
	self.CurrentRecipeData = nil
	
	-- Guard condition before running this branch.
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
		-- Continue applying initial visibility settings.
	end
	if self.itemname then
		self.itemname:SetVisibility(ESlateVisibility.Collapsed)
	end
	
	-- Execute the next UI update step.
	self:CreateCraftSlots()
end

-- Horfbuttun text.
function WB_Inventory:horfbuttun_Text(ReturnValue)
	return self.IsFenjieMode and "分解" or "合成"
end

-- Handle fenjie or hecheng button click.
function WB_Inventory:OnFenjieOrHechengClicked()
	-- Local helper value for this logic block.
	local now = os.clock()
	if self._lastSwitchTime and (now - self._lastSwitchTime) < 0.5 then
		return
	end
	self._lastSwitchTime = now

	-- Keep this section consistent with the original UI flow.
	
	self.IsFenjieMode = not self.IsFenjieMode
	
	local modeName = self.IsFenjieMode and "分解" or "合成"
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.horfbuttun then
		self.horfbuttun:SetText(modeName)
	end
	
	-- Execute the next UI update step.
	self:ShowTip("当前模式已切换为" .. modeName .. "模式")
	
	-- Execute the next UI update step.
	self:ClearDetailSlots()
	self.CurrentRecipeData = nil
	
	-- Guard condition before running this branch.
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
	end
	if self.itemname then
		self.itemname:SetVisibility(ESlateVisibility.Collapsed)
	end
	
	-- Execute the next UI update step.
	self:CreateCraftSlots()
end

-- Show craft details.
function WB_Inventory:ShowCraftDetails(recipeData)
	if not recipeData then
		-- Exit early when requirements are not met.
		return
	end
	
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.detail then
		self.detail:SetVisibility(0)
	end
	
	-- Keep this section consistent with the original UI flow.
	self.CurrentRecipeData = recipeData
	
	-- Execute the next UI update step.
	self:ClearDetailSlots()
	
	if recipeData.IsFenjie then
		-- Guard condition before running this branch.
		-- Guard condition before running this branch.
		if self.itemname and recipeData.VirtualOutputItemID then
			self.itemname:SetVisibility(ESlateVisibility.Visible)
			local itemConfig = UGCGameData.GetItemConfig(recipeData.VirtualOutputItemID)
			if itemConfig and itemConfig.ItemName then
				self.itemname:SetText(tostring(itemConfig.ItemName))
			else
				self.itemname:SetText("")
			end
		end
		
		-- Guard condition before running this branch.
		if self.WrapBox_0 and recipeData.VirtualOutputItemID then
			local inputSlot = self:CreateDisplaySlot(recipeData.VirtualOutputItemID, recipeData.InputCount, true)
			if inputSlot then
				self.WrapBox_0:AddChild(inputSlot)
			end
		end
		
		-- Guard condition before running this branch.
		if self.WrapBox_2 and recipeData.OutputMaterials then
			for i, material in ipairs(recipeData.OutputMaterials) do
				local outputSlot = self:CreateDisplaySlot(material.VirtualItemID, material.Count, false)
				if outputSlot then
					self.WrapBox_2:AddChild(outputSlot)
				end
			end
		end
	else
		-- Guard condition before running this branch.
		if self.itemname and recipeData.VirtualOutputItemID then
			self.itemname:SetVisibility(ESlateVisibility.Visible)
			local itemConfig = UGCGameData.GetItemConfig(recipeData.VirtualOutputItemID)
			if itemConfig and itemConfig.ItemName then
				self.itemname:SetText(tostring(itemConfig.ItemName))
			else
				self.itemname:SetText("")
			end
		end
		
		self:CreateDetailSlots(recipeData)
	end
end

-- Clear detail slots.
function WB_Inventory:ClearDetailSlots()
	-- Guard condition before running this branch.
	if self.WrapBox_0 then
		self.WrapBox_0:ClearChildren()
		-- Keep this section consistent with the original UI flow.
	end
	
	-- Guard condition before running this branch.
	if self.WrapBox_2 then
		self.WrapBox_2:ClearChildren()
		-- Keep this section consistent with the original UI flow.
	end
end

-- Create detail slots.
function WB_Inventory:CreateDetailSlots(recipeData)
	-- Guard condition before running this branch.
	if self.WrapBox_0 and recipeData.VirtualOutputItemID then
		-- Local helper value for this logic block.
		local outputSlot = self:CreateDisplaySlot(recipeData.VirtualOutputItemID, recipeData.OutputCount, false)
		if outputSlot then
			self.WrapBox_0:AddChild(outputSlot)
			-- Keep this section consistent with the original UI flow.
		end
	end
	
	-- Guard condition before running this branch.
	if self.WrapBox_2 and recipeData.InputMaterials then
		-- Iterate through related data or widgets.
		
		for i, material in ipairs(recipeData.InputMaterials) do
			-- Local helper value for this logic block.
			local inputSlot = self:CreateDisplaySlot(material.VirtualItemID, material.Count, true)
			if inputSlot then
				self.WrapBox_2:AddChild(inputSlot)
				-- Keep this section consistent with the original UI flow.
			end
		end
	end
end

-- Create display slot.
function WB_Inventory:CreateDisplaySlot(virtualItemID, count, isInput)
	-- Local helper value for this logic block.
	
	-- Local helper value for this logic block.
	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
	if not SlotClass then
		-- Exit early when requirements are not met.
		return nil
	end
	
	-- Acquire local player references.
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
	if not slotWidget then
		-- Exit early when requirements are not met.
		return nil
	end
	
	-- Keep this section consistent with the original UI flow.
	slotWidget.DisplayItemID = virtualItemID
	slotWidget.DisplayCount = count
	slotWidget.IsInputItem = isInput
	
	-- Keep this section consistent with the original UI flow.
	
	-- Keep this section consistent with the original UI flow.
	slotWidget:LoadDisplayData()
	
	return slotWidget
end

-- Handle craft button button click.
function WB_Inventory:OnCraftButtonClicked()
	-- Guard condition before running this branch.
	
	if not self.CurrentRecipeData then
		-- Exit early when requirements are not met.
		return
	end
	
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- Exit early when requirements are not met.
		return
	end
	
	local recipeData = self.CurrentRecipeData
	
	if recipeData.IsFenjie then
		-- Guard condition before running this branch.
		-- Guard condition before running this branch.
		
		-- Guard condition before running this branch.
		if not recipeData.InputMaterials or #recipeData.InputMaterials == 0 then
			-- Exit early when requirements are not met.
			return
		end
		
		local material = recipeData.InputMaterials[1]
		local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
		-- Guard condition before running this branch.
		
		if currentCount < material.Count then
			-- Execute the next UI update step.
			self:ShowTip("材料不足")
			return
		end
		
		-- Local helper value for this logic block.
		local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
		if not PlayerState then
			-- Exit early when requirements are not met.
			return
		end
		
		-- Configuration table used by this widget.
		local inputItemIDs = {material.RealItemID}
		local inputCounts = {material.Count}
		local outputItemIDs = {}
		local outputCounts = {}
		
		if recipeData.OutputMaterials then
			for i, outMat in ipairs(recipeData.OutputMaterials) do
				table.insert(outputItemIDs, outMat.RealItemID)
				table.insert(outputCounts, outMat.Count)
			end
		end
		
		-- Keep this section consistent with the original UI flow.
		-- Keep this section consistent with the original UI flow.
		
		-- Keep this section consistent with the original UI flow.
		UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_CraftItem", inputItemIDs, inputCounts, outputItemIDs, outputCounts)
		-- Keep this section consistent with the original UI flow.
	else
		-- Guard condition before running this branch.
		-- Guard condition before running this branch.
		-- Guard condition before running this branch.
		
		if not recipeData.InputMaterials or #recipeData.InputMaterials == 0 then
			-- Exit early when requirements are not met.
			return
		end
		
		-- Local helper value for this logic block.
		
		local allEnough = true
		for i, material in ipairs(recipeData.InputMaterials) do
			local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
			-- Guard condition before running this branch.
			
			if currentCount < material.Count then
				-- Keep this section consistent with the original UI flow.
				allEnough = false
			end
		end
		
		if not allEnough then
			-- Execute the next UI update step.
			self:ShowTip("材料不足")
			return
		end
		
		local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
		if not PlayerState then
			-- Exit early when requirements are not met.
			return
		end
		
		local inputItemIDs = {}
		local inputCounts = {}
		for i, material in ipairs(recipeData.InputMaterials) do
			table.insert(inputItemIDs, material.RealItemID)
			table.insert(inputCounts, material.Count)
		end
		
		-- Keep this section consistent with the original UI flow.
		
		UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_CraftItem", inputItemIDs, inputCounts, recipeData.OutputItemID, recipeData.OutputCount)
		-- Keep this section consistent with the original UI flow.
	end
end

-- Handle cancel button button click.
function WB_Inventory:OnCancelButtonClicked()
	-- Configure initial widget visibility.
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

-- Show tip.
function WB_Inventory:ShowTip(text)
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.ShowTip then
		pc.MMainUI:ShowTip(text)
	end
end

return WB_Inventory
