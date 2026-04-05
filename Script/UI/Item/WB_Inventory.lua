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

-- 寮曞叆UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Inventory:Construct()
	--ugcprint("[WB_Inventory] Construct 琚皟鐢?)
	
	-- 鍒濆鍖栧綋鍓嶉〉绛撅紙榛樿鏄剧ずpage0锛?
	self.CurrentPage = "page0"
	-- 鍒濆鍖栨ā寮忥細false=鍚堟垚妯″紡锛宼rue=鍒嗚В妯″紡
	self.IsFenjieMode = false
	
	self:LuaInit()
	
	-- 鍒濆鍖栨寜閽枃瀛?
	if self.horfbuttun then
		self.horfbuttun:SetText("鍚堟垚")
	end
	
	-- 闅愯棌璇︽儏鍖哄煙锛堜竴寮€濮嬫病鏈夐€夋嫨鐗╁搧锛?
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
	end

	-- 鍒濆闅愯棌鐗╁搧鍚嶇О鍜屽悎鎴愭潗鏂欏尯鍩?
	if self.itemname then
		self.itemname:SetVisibility(ESlateVisibility.Collapsed)
	end
	if self.HorizontalBox_1 then
		self.HorizontalBox_1:SetVisibility(ESlateVisibility.Collapsed)
	end
	
	-- 璁剧疆WrapBox_0涓€鎺掓渶澶?涓?
	if self.WrapBox_0 then
		self.WrapBox_0:SetInnerSlotPadding(Vector2D.New(5, 5))
		self.WrapBox_0.bExplicitWrapSize = true
		self.WrapBox_0.WrapSize = 400
	end

	-- 鍔ㄦ€佸垱寤哄悎鎴愭Ы浣?
	self:CreateCraftSlots()
end

-- [Editor Generated Lua] function define Begin:
function WB_Inventory:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	--ugcprint("[WB_Inventory] LuaInit 瀹屾垚")
	
	-- 缁戝畾鍚堟垚鎸夐挳鐐瑰嚮浜嬩欢
	if self.Button_0 then
		self.Button_0.OnPressed:Add(self.OnCraftButtonClicked, self)
		--ugcprint("[WB_Inventory] Button_0 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	else
		--ugcprint("[WB_Inventory] 璀﹀憡锛氭湭鎵惧埌 Button_0")
	end
	
	-- 缁戝畾鍙栨秷鎸夐挳鐐瑰嚮浜嬩欢
	if self.cancel then
		self.cancel.OnPressed:Add(self.OnCancelButtonClicked, self)
		--ugcprint("[WB_Inventory] cancel 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	else
		--ugcprint("[WB_Inventory] 璀﹀憡锛氭湭鎵惧埌 cancel")
	end
	
	-- 缁戝畾鍒嗚В/鍚堟垚鍒囨崲鎸夐挳浜嬩欢
	if self.fenjieorhecheng then
		self.fenjieorhecheng.OnPressed:Add(self.OnFenjieOrHechengClicked, self)
		-- ugcprint("[WB_Inventory] fenjieorhecheng 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	else
		-- ugcprint("[WB_Inventory] 璀﹀憡锛氭湭鎵惧埌 fenjieorhecheng")
	end
	
	-- 缁戝畾椤电鎸夐挳鐐瑰嚮浜嬩欢
	if self.page0 then
		self.page0.OnPressed:Add(function()
			self:SwitchPage("page0")
		end, self)
		--ugcprint("[WB_Inventory] page0 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	end
	
	if self.page1 then
		self.page1.OnPressed:Add(function()
			self:SwitchPage("page1")
		end, self)
		--ugcprint("[WB_Inventory] page1 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	end
	
	if self.page2 then
		self.page2.OnPressed:Add(function()
			self:SwitchPage("page2")
		end, self)
		--ugcprint("[WB_Inventory] page2 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
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

-- 鍔ㄦ€佸垱寤烘Ы浣嶏紙鍚堟垚/鍒嗚В鍏辩敤锛?
function WB_Inventory:CreateCraftSlots()
	-- ugcprint("[WB_Inventory] 寮€濮嬪垱寤烘Ы浣嶏紝妯″紡: " .. (self.IsFenjieMode and "鍒嗚В" or "鍚堟垚") .. "锛岄〉绛? " .. tostring(self.CurrentPage))
	
	-- 鏍规嵁妯″紡鑾峰彇瀵瑰簲鐨勯厤鏂硅〃
	local allRecipes = nil
	if self.IsFenjieMode then
		allRecipes = UGCGameData.GetAllFenjieConfig()
		if not allRecipes then
			-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曡幏鍙栧垎瑙ｈ〃")
			return
		end
	else
		allRecipes = UGCGameData.GetAllRecipeConfig()
		if not allRecipes then
			-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曡幏鍙栭厤鏂硅〃")
			return
		end
	end
	
	-- 灏嗛厤鏂硅浆鎹负鏁扮粍骞惰鍙栭『搴忓拰椤电
	local recipeArray = {}
	for recipeName, recipeData in pairs(allRecipes) do
		local order = recipeData["椤哄簭"] or 999
		local page = recipeData["椤电"]
		
		local pageStr = "page0"
		if page ~= nil then
			pageStr = "page" .. tostring(page)
		end
		
		-- 鍙坊鍔犲綋鍓嶉〉绛剧殑閰嶆柟
		if pageStr == self.CurrentPage then
			table.insert(recipeArray, {
				name = recipeName,
				order = order,
				page = pageStr,
				data = recipeData
			})
		end
	end
	
	-- 鎸夐『搴忔帓搴忥紙鏁板瓧瓒婂皬瓒婇潬鍓嶏級
	table.sort(recipeArray, function(a, b)
		return a.order < b.order
	end)
	
	-- ugcprint("[WB_Inventory] 褰撳墠椤电閰嶆柟鎬绘暟: " .. #recipeArray)
	
	-- 娓呯┖WrapBox
	if self.WrapBox_1 then
		self.WrapBox_1:ClearChildren()
	else
		-- ugcprint("[WB_Inventory] 閿欒锛氭湭鎵惧埌WrapBox_1")
		return
	end
	
	-- 鑾峰彇WB_Slot绫?
	local slotPath = 'Asset/UI/Item/WB_Slot.WB_Slot_C'
	local fullPath = UGCGameSystem.GetUGCResourcesFullPath(slotPath)
	local SlotClass = UGCObjectUtility.LoadClass(fullPath)
	if not SlotClass then
		-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曞姞杞絎B_Slot绫?)
		return
	end
	
	-- 鑾峰彇鐜╁鎺у埗鍣?
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曡幏鍙栫帺瀹舵帶鍒跺櫒")
		return
	end
	
	-- 涓烘瘡涓厤鏂瑰垱寤轰竴涓猈B_Slot
	for i, recipe in ipairs(recipeArray) do
		local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
		if slotWidget then
			slotWidget.RecipeID = recipe.name
			-- 鍛婅瘔WB_Slot褰撳墠鏄惁涓哄垎瑙ｆā寮?
			slotWidget.IsFenjieMode = self.IsFenjieMode
			self.WrapBox_1:AddChild(slotWidget)
		else
			-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曞垱寤烘Ы浣?" .. i)
		end
	end
	
	-- ugcprint("[WB_Inventory] 妲戒綅鍒涘缓瀹屾垚锛屽叡鍒涘缓 " .. #recipeArray .. " 涓?)
end

-- 鍒囨崲椤电
function WB_Inventory:SwitchPage(pageName)
	--ugcprint("[WB_Inventory] 鍒囨崲椤电鍒? " .. tostring(pageName))
	
	if self.CurrentPage == pageName then
		--ugcprint("[WB_Inventory] 宸茬粡鍦ㄥ綋鍓嶉〉绛撅紝鏃犻渶鍒囨崲")
		return
	end
	
	self.CurrentPage = pageName
	
	-- 娓呯┖璇︽儏鏄剧ず
	self:ClearDetailSlots()
	self.CurrentRecipeData = nil
	
	-- 闅愯棌璇︽儏鍖哄煙鍜岀墿鍝佸悕绉?
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
		--ugcprint("[WB_Inventory] 璇︽儏鍖哄煙宸查殣钘?)
	end
	if self.itemname then
		self.itemname:SetVisibility(ESlateVisibility.Collapsed)
	end
	
	-- 閲嶆柊鍒涘缓妲戒綅
	self:CreateCraftSlots()
end

-- 鍒嗚В/鍚堟垚鎸夐挳鏂囧瓧锛堥€氳繃BindingProperty鑷姩鍒锋柊锛?
function WB_Inventory:horfbuttun_Text(ReturnValue)
	return self.IsFenjieMode and "鍒嗚В" or "鍚堟垚"
end

-- 鍒嗚В/鍚堟垚鍒囨崲鎸夐挳鐐瑰嚮浜嬩欢
function WB_Inventory:OnFenjieOrHechengClicked()
	-- 闃叉杩炵画蹇€熺偣鍑?
	local now = os.clock()
	if self._lastSwitchTime and (now - self._lastSwitchTime) < 0.5 then
		return
	end
	self._lastSwitchTime = now

	-- ugcprint("[WB_Inventory] 鍒囨崲鍒嗚В/鍚堟垚妯″紡锛屽綋鍓? " .. (self.IsFenjieMode and "鍒嗚В" or "鍚堟垚"))
	
	self.IsFenjieMode = not self.IsFenjieMode
	
	local modeName = self.IsFenjieMode and "鍒嗚В" or "鍚堟垚"
	-- ugcprint("[WB_Inventory] 鍒囨崲鍚? " .. modeName)
	
	-- 绔嬪嵆鏇存柊鎸夐挳鏂囧瓧锛堜笉渚濊禆BindingProperty鐨勫埛鏂伴鐜囷級
	if self.horfbuttun then
		self.horfbuttun:SetText(modeName)
	end
	
	-- 寮瑰嚭鍒囨崲鎻愮ず
	self:ShowTip("宸插垏鎹㈠埌" .. modeName .. "妯″紡")
	
	-- 娓呯┖璇︽儏鏄剧ず
	self:ClearDetailSlots()
	self.CurrentRecipeData = nil
	
	-- 闅愯棌璇︽儏鍖哄煙鍜岀墿鍝佸悕绉?
	if self.detail then
		self.detail:SetVisibility(ESlateVisibility.Collapsed)
	end
	if self.itemname then
		self.itemname:SetVisibility(ESlateVisibility.Collapsed)
	end
	
	-- 閲嶆柊鍒涘缓妲戒綅
	self:CreateCraftSlots()
end

-- 鏄剧ず璇︽儏锛堝悎鎴?鍒嗚В鍏辩敤锛?
function WB_Inventory:ShowCraftDetails(recipeData)
	if not recipeData then
		-- ugcprint("[WB_Inventory] 閿欒锛氶厤鏂规暟鎹负绌?)
		return
	end
	
	-- ugcprint("[WB_Inventory] 鏄剧ず璇︽儏锛岄厤鏂笽D: " .. tostring(recipeData.RecipeID) .. "锛屽垎瑙ｆā寮? " .. tostring(recipeData.IsFenjie))
	
	-- 鏄剧ず璇︽儏鍖哄煙
	if self.detail then
		self.detail:SetVisibility(0)
	end
	
	-- 淇濆瓨褰撳墠閫変腑鐨勯厤鏂规暟鎹?
	self.CurrentRecipeData = recipeData
	
	-- 娓呯┖骞堕噸鏂板垱寤鸿鎯呮Ы浣?
	self:ClearDetailSlots()
	
	if recipeData.IsFenjie then
		-- 鍒嗚В妯″紡锛氬乏杈规樉绀鸿鍒嗚В鐨勭墿鍝侊紝鍙宠竟鏄剧ず鍒嗚В鍚庤幏寰楃殑鏉愭枡
		-- 鏄剧ず鐗╁搧鍚嶇О锛堣鍒嗚В鐨勭墿鍝侊級
		if self.itemname and recipeData.VirtualOutputItemID then
			self.itemname:SetVisibility(ESlateVisibility.Visible)
			local itemConfig = UGCGameData.GetItemConfig(recipeData.VirtualOutputItemID)
			if itemConfig and itemConfig.ItemName then
				self.itemname:SetText(tostring(itemConfig.ItemName))
			else
				self.itemname:SetText("")
			end
		end
		
		-- WrapBox_0 鏄剧ず琚垎瑙ｇ殑鐗╁搧锛堣緭鍏ワ級
		if self.WrapBox_0 and recipeData.VirtualOutputItemID then
			local inputSlot = self:CreateDisplaySlot(recipeData.VirtualOutputItemID, recipeData.InputCount, true)
			if inputSlot then
				self.WrapBox_0:AddChild(inputSlot)
			end
		end
		
		-- WrapBox_2 鏄剧ず鍒嗚В鍚庤幏寰楃殑鏉愭枡锛堣緭鍑猴級
		if self.WrapBox_2 and recipeData.OutputMaterials then
			for i, material in ipairs(recipeData.OutputMaterials) do
				local outputSlot = self:CreateDisplaySlot(material.VirtualItemID, material.Count, false)
				if outputSlot then
					self.WrapBox_2:AddChild(outputSlot)
				end
			end
		end
	else
		-- 鍚堟垚妯″紡锛氬師鏈夐€昏緫
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

-- 娓呯┖璇︽儏妲戒綅
function WB_Inventory:ClearDetailSlots()
	-- 娓呯┖WrapBox_0锛堣緭鍑烘潗鏂欙級
	if self.WrapBox_0 then
		self.WrapBox_0:ClearChildren()
		--ugcprint("[WB_Inventory] 宸叉竻绌篧rapBox_0锛堣緭鍑烘潗鏂欙級")
	end
	
	-- 娓呯┖WrapBox_2锛堣緭鍏ユ潗鏂欙級
	if self.WrapBox_2 then
		self.WrapBox_2:ClearChildren()
		--ugcprint("[WB_Inventory] 宸叉竻绌篧rapBox_2锛堣緭鍏ユ潗鏂欙級")
	end
end

-- 鍒涘缓璇︽儏妲戒綅
function WB_Inventory:CreateDetailSlots(recipeData)
	-- 鍒涘缓杈撳嚭鏉愭枡妲戒綅锛圵rapBox_0锛?
	if self.WrapBox_0 and recipeData.VirtualOutputItemID then
		--ugcprint("[WB_Inventory] 鍒涘缓杈撳嚭鏉愭枡妲戒綅")
		local outputSlot = self:CreateDisplaySlot(recipeData.VirtualOutputItemID, recipeData.OutputCount, false)
		if outputSlot then
			self.WrapBox_0:AddChild(outputSlot)
			--ugcprint("[WB_Inventory] 杈撳嚭鏉愭枡妲戒綅宸叉坊鍔?)
		end
	end
	
	-- 鍒涘缓杈撳叆鏉愭枡妲戒綅锛圵rapBox_2锛? 鏀寔澶氫釜鏉愭枡
	if self.WrapBox_2 and recipeData.InputMaterials then
		--ugcprint("[WB_Inventory] 鍒涘缓杈撳叆鏉愭枡妲戒綅锛屾潗鏂欐暟閲? " .. tostring(#recipeData.InputMaterials))
		
		for i, material in ipairs(recipeData.InputMaterials) do
			--ugcprint("[WB_Inventory] 鍒涘缓鏉愭枡 " .. i .. " 妲戒綅")
			local inputSlot = self:CreateDisplaySlot(material.VirtualItemID, material.Count, true)
			if inputSlot then
				self.WrapBox_2:AddChild(inputSlot)
				--ugcprint("[WB_Inventory] 鏉愭枡 " .. i .. " 妲戒綅宸叉坊鍔?)
			end
		end
	end
end

-- 鍒涘缓鏄剧ず鐢ㄧ殑妲戒綅锛堜娇鐢╓B_Slot_2锛?
function WB_Inventory:CreateDisplaySlot(virtualItemID, count, isInput)
	--ugcprint("[WB_Inventory] 鍔犺浇 WB_Slot_2 绫?)
	
	-- 鍔犺浇WB_Slot_2绫?
	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
	if not SlotClass then
		--ugcprint("[WB_Inventory] 閿欒锛氭棤娉曞姞杞?WB_Slot_2 绫?)
		return nil
	end
	
	-- 鍒涘缓妲戒綅瀹炰緥
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
	if not slotWidget then
		--ugcprint("[WB_Inventory] 閿欒锛氭棤娉曞垱寤烘Ы浣嶅疄渚?)
		return nil
	end
	
	-- 璁剧疆鏄剧ず鏁版嵁
	slotWidget.DisplayItemID = virtualItemID
	slotWidget.DisplayCount = count
	slotWidget.IsInputItem = isInput
	
	--ugcprint("[WB_Inventory] 鍒涘缓鏄剧ず妲戒綅 - 铏氭嫙ID: " .. tostring(virtualItemID) .. ", 鏁伴噺: " .. tostring(count) .. ", 鏄惁杈撳叆: " .. tostring(isInput))
	
	-- 鎵嬪姩璋冪敤LoadDisplayData鏉ュ姞杞芥暟鎹?
	slotWidget:LoadDisplayData()
	
	return slotWidget
end

-- 鍚堟垚/鍒嗚В鎸夐挳鐐瑰嚮浜嬩欢
function WB_Inventory:OnCraftButtonClicked()
	-- ugcprint("[WB_Inventory] ========== 鎸夐挳琚偣鍑?==========")
	
	if not self.CurrentRecipeData then
		-- ugcprint("[WB_Inventory] 閿欒锛氭病鏈夐€変腑閰嶆柟")
		return
	end
	
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- ugcprint("[WB_Inventory] 閿欒锛氳幏鍙栫帺瀹舵帶鍒跺櫒澶辫触")
		return
	end
	
	local recipeData = self.CurrentRecipeData
	
	if recipeData.IsFenjie then
		-- ===== 鍒嗚В妯″紡 =====
		-- ugcprint("[WB_Inventory] 鎵ц鍒嗚В锛岄厤鏂笽D: " .. tostring(recipeData.RecipeID))
		
		-- 妫€鏌ヨ鍒嗚В鐗╁搧鏄惁鍏呰冻
		if not recipeData.InputMaterials or #recipeData.InputMaterials == 0 then
			-- ugcprint("[WB_Inventory] 閿欒锛氭病鏈夎緭鍏ユ潗鏂?)
			return
		end
		
		local material = recipeData.InputMaterials[1]
		local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
		-- ugcprint("[WB_Inventory] 鍒嗚В鏉愭枡 - ID:" .. tostring(material.RealItemID) .. " 闇€瑕?" .. material.Count .. " 褰撳墠:" .. currentCount)
		
		if currentCount < material.Count then
			-- ugcprint("[WB_Inventory] 鍒嗚В澶辫触锛氭潗鏂欎笉瓒?)
			self:ShowTip("鏉愭枡涓嶈冻")
			return
		end
		
		-- 鑾峰彇PlayerState
		local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
		if not PlayerState then
			-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曡幏鍙朠layerState")
			return
		end
		
		-- 鏋勫缓鍒嗚В鏁版嵁锛氭秷鑰楃殑鐗╁搧ID鍜屾暟閲忥紝浠ュ強浜у嚭鐨勭墿鍝両D鍜屾暟閲?
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
		
		-- ugcprint("[WB_Inventory] 鍙戦€佸垎瑙PC - 娑堣€桰D: " .. table.concat(inputItemIDs, ",") .. " 鏁伴噺: " .. table.concat(inputCounts, ","))
		-- ugcprint("[WB_Inventory] 浜у嚭ID: " .. table.concat(outputItemIDs, ",") .. " 鏁伴噺: " .. table.concat(outputCounts, ","))
		
		-- 璋冪敤鏈嶅姟鍣≧PC鎵ц鍒嗚В锛堝鐢ㄥ悎鎴怰PC锛屼紶澶氫釜杈撳嚭锛?
		UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_CraftItem", inputItemIDs, inputCounts, outputItemIDs, outputCounts)
		-- ugcprint("[WB_Inventory] 鉁?鍒嗚ВRPC宸插彂閫?)
	else
		-- ===== 鍚堟垚妯″紡锛堝師鏈夐€昏緫锛?====
		-- ugcprint("[WB_Inventory] 鎵ц鍚堟垚锛岄厤鏂笽D: " .. tostring(recipeData.RecipeID))
		-- ugcprint("[WB_Inventory] 杈撳嚭鐗╁搧ID: " .. tostring(recipeData.OutputItemID) .. " x " .. tostring(recipeData.OutputCount))
		
		if not recipeData.InputMaterials or #recipeData.InputMaterials == 0 then
			-- ugcprint("[WB_Inventory] 閿欒锛氭病鏈夎緭鍏ユ潗鏂?)
			return
		end
		
		-- ugcprint("[WB_Inventory] 鏉愭枡鎬绘暟: " .. tostring(#recipeData.InputMaterials))
		
		local allEnough = true
		for i, material in ipairs(recipeData.InputMaterials) do
			local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
			-- ugcprint("[WB_Inventory] 鏉愭枡 " .. i .. " - ID:" .. tostring(material.RealItemID) .. " 闇€瑕?" .. material.Count .. " 褰撳墠:" .. currentCount)
			
			if currentCount < material.Count then
				-- ugcprint("[WB_Inventory] 鏉愭枡 " .. i .. " 鏁伴噺涓嶈冻")
				allEnough = false
			end
		end
		
		if not allEnough then
			-- ugcprint("[WB_Inventory] 鍚堟垚澶辫触锛氭潗鏂欎笉瓒?)
			self:ShowTip("鏉愭枡涓嶈冻")
			return
		end
		
		local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
		if not PlayerState then
			-- ugcprint("[WB_Inventory] 閿欒锛氭棤娉曡幏鍙朠layerState")
			return
		end
		
		local inputItemIDs = {}
		local inputCounts = {}
		for i, material in ipairs(recipeData.InputMaterials) do
			table.insert(inputItemIDs, material.RealItemID)
			table.insert(inputCounts, material.Count)
		end
		
		-- ugcprint("[WB_Inventory] 鍙戦€丷PC - 杈撳叆ID: " .. table.concat(inputItemIDs, ",") .. " 鏁伴噺: " .. table.concat(inputCounts, ",") .. " 杈撳嚭: " .. tostring(recipeData.OutputItemID) .. " x " .. tostring(recipeData.OutputCount))
		
		UnrealNetwork.CallUnrealRPC(PlayerState, PlayerState, "Server_CraftItem", inputItemIDs, inputCounts, recipeData.OutputItemID, recipeData.OutputCount)
		-- ugcprint("[WB_Inventory] 鉁?RPC宸插彂閫?)
	end
end

-- 鍙栨秷鎸夐挳鐐瑰嚮浜嬩欢
function WB_Inventory:OnCancelButtonClicked()
	--ugcprint("[WB_Inventory] 鍙栨秷鎸夐挳琚偣鍑伙紝闅愯棌鐣岄潰")
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

-- 鏄剧ず鎻愮ず淇℃伅锛堥€氳繃MMainUI锛?
function WB_Inventory:ShowTip(text)
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.ShowTip then
		pc.MMainUI:ShowTip(text)
	end
end

return WB_Inventory
