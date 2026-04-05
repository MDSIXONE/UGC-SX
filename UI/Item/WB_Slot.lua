---@class WB_Slot_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local WB_Slot = { bInitDoOnce = false } 

-- 引入UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Slot:Construct()
	--ugcprint("[WB_Slot] Construct 被调用")
	
	-- 初始化实例变量
	self.RecipeData = nil
	
	-- 隐藏Image_1（默认隐藏，只有可合成时才显示）
	if self.Image_1 then
		self.Image_1:SetVisibility(2)  -- 2 = Hidden
	end
	
	-- 检查是否为显示模式
	if self.IsDisplayMode then
		--ugcprint("[WB_Slot] 显示模式，加载显示数据")
		self:LoadDisplayData()
		return
	end
	
	-- 如果外部设置了RecipeID，使用外部的
	if self.RecipeID then
		--ugcprint("[WB_Slot] 使用配方ID: " .. tostring(self.RecipeID))
		
		self:LuaInit()
		
		-- 加载配方数据
		self:LoadRecipeData(self.RecipeID)
		
		-- 设置物品图标
		self:SetItemIcon()
		
		-- 更新物品数量显示
		self:UpdateItemCount()
	else
		--ugcprint("[WB_Slot] 警告：未设置RecipeID")
	end
end

-- 加载配方数据
function WB_Slot:LoadRecipeData(recipeID)
	ugcprint("[WB_Slot] 开始加载配方数据，配方ID: " .. tostring(recipeID))
	
	-- 从配方表读取配方
	local recipeConfig = UGCGameData.GetRecipeConfig(recipeID)
	if recipeConfig then
		ugcprint("[WB_Slot] 配方加载成功")
		
		-- 打印配方表的所有字段（关键调试信息）
		ugcprint("[WB_Slot] ===== 配方表字段 =====")
		for key, value in pairs(recipeConfig) do
			ugcprint("[WB_Slot]   " .. tostring(key) .. " = " .. tostring(value))
		end
		ugcprint("[WB_Slot] ===== 字段打印结束 =====")
		
		-- 从配方表获取虚拟输出物品ID
		local virtualOutputItemID = recipeConfig["虚拟物品ID"]
		ugcprint("[WB_Slot] 虚拟输出物品ID: " .. tostring(virtualOutputItemID))
		
		-- 读取输出材料数量
		local outputCount = recipeConfig["数量"] or recipeConfig["输出材料（数量）"] or 1
		ugcprint("[WB_Slot] 输出材料数量: " .. tostring(outputCount))
		
		-- 读取合成配方数组
		local craftRecipeArray = recipeConfig["合成配方"]
		if not craftRecipeArray then
			ugcprint("[WB_Slot] 错误：未找到'合成配方'字段！请检查上面打印的字段名")
			self.RecipeData = {
				InputItemID = nil,
				InputCount = 0,
				OutputItemID = nil,
				OutputCount = outputCount,
				RecipeID = recipeID,
				InputMaterials = {}
			}
			return
		end
		
		ugcprint("[WB_Slot] 找到合成配方数组，材料数量: " .. tostring(#craftRecipeArray))
		
		-- 存储所有输入材料
		local inputMaterials = {}
		
		-- 遍历合成配方数组（material是UE userdata）
		for i = 1, #craftRecipeArray do
			local material = craftRecipeArray[i]
			if material then
				ugcprint("[WB_Slot] 材料 " .. i .. " 类型: " .. type(material))
				
				-- 用pcall + 方括号访问userdata字段
				local ok, virtualInputItemID = pcall(function() return material["材料虚拟物品ID"] end)
				local ok2, inputCount = pcall(function() return material["所需数量"] end)
				
				if not ok then
					ugcprint("[WB_Slot] 材料 " .. i .. " 访问材料虚拟物品ID失败: " .. tostring(virtualInputItemID))
					virtualInputItemID = nil
				end
				if not ok2 then
					ugcprint("[WB_Slot] 材料 " .. i .. " 访问所需数量失败: " .. tostring(inputCount))
					inputCount = nil
				end
				
				ugcprint("[WB_Slot] 材料 " .. i .. " - 虚拟ID: " .. tostring(virtualInputItemID) .. ", 数量: " .. tostring(inputCount))
				
				-- 使用映射表将虚拟物品ID转换为实际物品ID
				if virtualInputItemID then
					local inputMapping = UGCGameData.GetItemMapping(virtualInputItemID)
					if inputMapping and inputMapping["ClassicItemID"] then
						local realInputItemID = inputMapping["ClassicItemID"]
						ugcprint("[WB_Slot] 材料 " .. i .. " 映射后的真实ID: " .. tostring(realInputItemID))
						
						table.insert(inputMaterials, {
							VirtualItemID = virtualInputItemID,
							RealItemID = realInputItemID,
							Count = inputCount
						})
					else
						ugcprint("[WB_Slot] 警告：材料 " .. i .. " 未找到映射")
					end
				else
					ugcprint("[WB_Slot] 警告：材料 " .. i .. " virtualInputItemID为nil")
				end
			else
				ugcprint("[WB_Slot] 警告：材料 " .. i .. " 为nil")
			end
		end
		
		ugcprint("[WB_Slot] 解析完成，有效材料数量: " .. tostring(#inputMaterials))
		
		-- 使用映射表将虚拟输出物品ID转换为实际物品ID
		local realOutputItemID = nil
		if virtualOutputItemID then
			local outputMapping = UGCGameData.GetItemMapping(virtualOutputItemID)
			if outputMapping and outputMapping["ClassicItemID"] then
				realOutputItemID = outputMapping["ClassicItemID"]
				ugcprint("[WB_Slot] 映射后的输出物品ID: " .. tostring(realOutputItemID))
			end
		end
		
		-- 构建配方数据
		local firstMaterial = inputMaterials[1]
		self.RecipeData = {
			InputItemID = firstMaterial and firstMaterial.RealItemID or nil,
			InputCount = firstMaterial and firstMaterial.Count or 0,
			OutputItemID = realOutputItemID,
			OutputCount = outputCount,
			RecipeID = recipeID,
			VirtualInputItemID = firstMaterial and firstMaterial.VirtualItemID or nil,
			VirtualOutputItemID = virtualOutputItemID,
			InputMaterials = inputMaterials
		}
	else
		ugcprint("[WB_Slot] 错误：未找到配方，配方ID: " .. tostring(recipeID))
		self.RecipeData = {
			InputItemID = nil,
			InputCount = 0,
			OutputItemID = nil,
			OutputCount = 1,
			RecipeID = recipeID,
			InputMaterials = {}
		}
	end
	
	ugcprint("[WB_Slot] 配方数据加载完成, InputMaterials数量: " .. tostring(self.RecipeData and #self.RecipeData.InputMaterials or "nil"))
end

-- [Editor Generated Lua] function define Begin:
function WB_Slot:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	--ugcprint("[WB_Slot] LuaInit 开始绑定事件")
	
	-- 绑定按钮点击事件
	if self.Button_0 and not self.IsDisplayMode then
		self.Button_0.OnPressed:Add(self.OnButtonClicked, self)
		--ugcprint("[WB_Slot] Button_0 点击事件绑定成功")
	elseif self.IsDisplayMode then
		--ugcprint("[WB_Slot] 显示模式，跳过按钮绑定")
		if self.Button_0 then
			self.Button_0:SetIsEnabled(false)
		end
	else
		--ugcprint("[WB_Slot] 警告：未找到 Button_0")
	end
end
-- [Editor Generated Lua] function define End;

-- 设置物品图标
function WB_Slot:SetItemIcon()
	if not self.RecipeData then
		return
	end
	
	local virtualOutputItemID = self.RecipeData.VirtualOutputItemID
	if not virtualOutputItemID then
		return
	end
	
	-- 从物品表获取物品配置
	local itemConfig = UGCGameData.GetItemConfig(virtualOutputItemID)
	if not itemConfig then
		return
	end
	
	-- 获取小icon路径
	local iconPath = itemConfig["ItemSmallIcon"]
	if not iconPath then
		return
	end
	
	if not self.Image_0 then
		return
	end
	
	-- 使用UGCObjectUtility.GetPathBySoftObjectPath从SoftObjectPath获取路径字符串
	local pathString = UGCObjectUtility.GetPathBySoftObjectPath(iconPath)
	
	if pathString and pathString ~= "" then
		local IconTexture = UGCObjectUtility.LoadObject(pathString)
		if IconTexture then
			self.Image_0:SetBrushFromTexture(IconTexture)
		end
	end
end

-- 更新物品数量显示
function WB_Slot:UpdateItemCount()
	if not self.TextBlock_0 then
		return
	end
	
	if not self.RecipeData then
		self.TextBlock_0:SetText("x0")
		if self.Image_1 then
			self.Image_1:SetVisibility(2)  -- 2 = Hidden
		end
		return
	end
	
	-- 显示输出数量
	local countText = "x" .. tostring(self.RecipeData.OutputCount)
	self.TextBlock_0:SetText(countText)
	
	-- 设置为白色
	local whiteColor = UGCObjectUtility.NewStruct("SlateColor")
	whiteColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
	self.TextBlock_0:SetColorAndOpacity(whiteColor)
	
	-- 检查所有材料是否充足
	local canCraft = true
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	
	if PlayerController and self.RecipeData.InputMaterials then
		for i, material in ipairs(self.RecipeData.InputMaterials) do
			local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
			if currentCount < material.Count then
				canCraft = false
				break
			end
		end
	else
		canCraft = false
	end
	
	-- 根据是否可合成显示或隐藏Image_1
	if self.Image_1 then
		if canCraft then
			self.Image_1:SetVisibility(0)  -- 0 = Visible
		else
			self.Image_1:SetVisibility(2)  -- 2 = Hidden
		end
	end
end

-- 按钮点击事件
function WB_Slot:OnButtonClicked()
	--ugcprint("[WB_Slot] 按钮被点击")
	
	if not self.RecipeData then
		--ugcprint("[WB_Slot] 错误：配方数据为空")
		return
	end
	
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		--ugcprint("[WB_Slot] 错误：获取玩家控制器失败")
		return
	end
	
	-- 查找父级 WB_Inventory 并调用 ShowCraftDetails
	if PlayerController.MMainUI and PlayerController.MMainUI.WB_Inventory then
		--ugcprint("[WB_Slot] 调用 WB_Inventory 显示详情，配方ID: " .. tostring(self.RecipeData.RecipeID))
		PlayerController.MMainUI.WB_Inventory:ShowCraftDetails(self.RecipeData)
	else
		--ugcprint("[WB_Slot] 错误：找不到 WB_Inventory UI")
	end
end

function WB_Slot:Tick(MyGeometry, InDeltaTime)
	-- 每帧更新物品数量显示和Image_1状态
	if self.RecipeData then
		self:UpdateItemCount()
	end
end

-- 加载显示数据（用于详情显示）
function WB_Slot:LoadDisplayData()
	-- 这个函数留空，由WB_Slot_2处理
end

return WB_Slot