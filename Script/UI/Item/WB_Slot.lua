---@class WB_Slot_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local WB_Slot = { bInitDoOnce = false } 

-- Local helper value for this logic block.
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Slot:Construct()
	-- Keep this section consistent with the original UI flow.
	
	-- Keep this section consistent with the original UI flow.
	self.RecipeData = nil
	
	-- Guard condition before running this branch.
	if self.Image_1 then
		self.Image_1:SetVisibility(2)  -- 2 = Hidden
	end
	
	-- Guard condition before running this branch.
	if self.IsDisplayMode then
		-- Execute the next UI update step.
		self:LoadDisplayData()
		return
	end
	
	-- Guard condition before running this branch.
	if self.RecipeID then
		-- Initialize widget state and bindings.
		
		self:LuaInit()
		
		-- Guard condition before running this branch.
		if self.IsFenjieMode then
			self:LoadFenjieData(self.RecipeID)
		else
			self:LoadRecipeData(self.RecipeID)
		end
		
		-- Execute the next UI update step.
		self:SetItemIcon()
		
		-- Execute the next UI update step.
		self:UpdateItemCount()
	else
		-- Keep this section consistent with the original UI flow.
	end
end

-- Load recipe data.
function WB_Slot:LoadRecipeData(recipeID)
	-- Local helper value for this logic block.
	
	-- Local helper value for this logic block.
	local recipeConfig = UGCGameData.GetRecipeConfig(recipeID)
	if recipeConfig then
		-- Iterate through related data or widgets.
		
		-- Iterate through related data or widgets.
		-- Iterate through related data or widgets.
		for key, value in pairs(recipeConfig) do
			-- ugcprint("[WB_Slot]   " .. tostring(key) .. " = " .. tostring(value))
		end
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local virtualOutputItemID = recipeConfig["虚拟物品ID"]
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local outputCount = recipeConfig["数量"] or recipeConfig["输出材料（数量）"] or 1
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local craftRecipeArray = recipeConfig["合成配方"]
		if not craftRecipeArray then
			-- Keep this section consistent with the original UI flow.
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
		
		-- Configuration table used by this widget.
		
		-- Configuration table used by this widget.
		local inputMaterials = {}
		
		-- Iterate through related data or widgets.
		for i = 1, #craftRecipeArray do
			local material = craftRecipeArray[i]
			if material then
				-- Keep this section consistent with the original UI flow.
				
				-- Keep this section consistent with the original UI flow.
				local ok, virtualInputItemID = pcall(function() return material["材料虚拟物品ID"] end)
				local ok2, inputCount = pcall(function() return material["所需数量"] end)
				
				if not ok then
					-- Keep this section consistent with the original UI flow.
					virtualInputItemID = nil
				end
				if not ok2 then
					-- Keep this section consistent with the original UI flow.
					inputCount = nil
				end
				
				-- Guard condition before running this branch.
				
				-- Guard condition before running this branch.
				if virtualInputItemID then
					local inputMapping = UGCGameData.GetItemMapping(virtualInputItemID)
					if inputMapping and inputMapping["ClassicItemID"] then
						local realInputItemID = inputMapping["ClassicItemID"]
						-- Keep this section consistent with the original UI flow.
						
						table.insert(inputMaterials, {
							VirtualItemID = virtualInputItemID,
							RealItemID = realInputItemID,
							Count = inputCount
						})
					else
						-- Keep this section consistent with the original UI flow.
					end
				else
					-- Keep this section consistent with the original UI flow.
				end
			else
				-- Keep this section consistent with the original UI flow.
			end
		end
		
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local realOutputItemID = nil
		if virtualOutputItemID then
			local outputMapping = UGCGameData.GetItemMapping(virtualOutputItemID)
			if outputMapping and outputMapping["ClassicItemID"] then
				realOutputItemID = outputMapping["ClassicItemID"]
				-- Keep this section consistent with the original UI flow.
			end
		end
		
		-- Local helper value for this logic block.
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
		-- Keep this section consistent with the original UI flow.
		self.RecipeData = {
			InputItemID = nil,
			InputCount = 0,
			OutputItemID = nil,
			OutputCount = 1,
			RecipeID = recipeID,
			InputMaterials = {}
		}
	end
	
	-- Keep this section consistent with the original UI flow.
end

-- Load fenjie data.
function WB_Slot:LoadFenjieData(recipeID)
	-- Local helper value for this logic block.
	
	local fenjieConfig = UGCGameData.GetFenjieConfig(recipeID)
	if fenjieConfig then
		-- Iterate through related data or widgets.
		
		-- Iterate through related data or widgets.
		-- Iterate through related data or widgets.
		for key, value in pairs(fenjieConfig) do
			-- ugcprint("[WB_Slot]   " .. tostring(key) .. " = " .. tostring(value))
		end
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local virtualOutputItemID = fenjieConfig["虚拟物品ID"]
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local outputCount = fenjieConfig["数量"] or 1
		-- Local helper value for this logic block.
		
		-- Local helper value for this logic block.
		local fenjieRecipeArray = fenjieConfig["分解配方"] or fenjieConfig["合成配方"]
		if not fenjieRecipeArray then
			-- Keep this section consistent with the original UI flow.
			self.RecipeData = {
				InputItemID = nil,
				InputCount = 0,
				OutputItemID = nil,
				OutputCount = outputCount,
				RecipeID = recipeID,
				InputMaterials = {},
				IsFenjie = true
			}
			return
		end
		
		-- Configuration table used by this widget.
		
		-- Configuration table used by this widget.
		local outputMaterials = {}
		
		for i = 1, #fenjieRecipeArray do
			local material = fenjieRecipeArray[i]
			if material then
				local ok, virtualItemID = pcall(function() return material["材料虚拟物品ID"] end)
				local ok2, count = pcall(function() return material["所需数量"] end)
				
				if not ok then virtualItemID = nil end
				if not ok2 then count = nil end
				
				-- Guard condition before running this branch.
				
				if virtualItemID then
					local mapping = UGCGameData.GetItemMapping(virtualItemID)
					if mapping and mapping["ClassicItemID"] then
						local realItemID = mapping["ClassicItemID"]
						table.insert(outputMaterials, {
							VirtualItemID = virtualItemID,
							RealItemID = realItemID,
							Count = count
						})
					end
				end
			end
		end
		
		-- Local helper value for this logic block.
		local realOutputItemID = nil
		if virtualOutputItemID then
			local outputMapping = UGCGameData.GetItemMapping(virtualOutputItemID)
			if outputMapping and outputMapping["ClassicItemID"] then
				realOutputItemID = outputMapping["ClassicItemID"]
			end
		end
		
		-- Keep this section consistent with the original UI flow.
		self.RecipeData = {
			InputItemID = realOutputItemID,
			InputCount = outputCount,
			OutputItemID = nil,
			OutputCount = 0,
			RecipeID = recipeID,
			VirtualInputItemID = virtualOutputItemID,
			VirtualOutputItemID = virtualOutputItemID,
			InputMaterials = {{
				VirtualItemID = virtualOutputItemID,
				RealItemID = realOutputItemID,
				Count = outputCount
			}},
			OutputMaterials = outputMaterials,
			IsFenjie = true
		}
	else
		-- Keep this section consistent with the original UI flow.
		self.RecipeData = {
			InputItemID = nil,
			InputCount = 0,
			OutputItemID = nil,
			OutputCount = 1,
			RecipeID = recipeID,
			InputMaterials = {},
			IsFenjie = true
		}
	end
	
	-- Keep this section consistent with the original UI flow.
end

-- [Editor Generated Lua] function define Begin:
function WB_Slot:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.Button_0 and not self.IsDisplayMode then
		self.Button_0.OnPressed:Add(self.OnButtonClicked, self)
		-- Continue registering UI interaction callbacks.
	elseif self.IsDisplayMode then
		-- Guard condition before running this branch.
		if self.Button_0 then
			self.Button_0:SetIsEnabled(false)
		end
	else
		-- Keep this section consistent with the original UI flow.
	end
end
-- [Editor Generated Lua] function define End;

-- Set item icon.
function WB_Slot:SetItemIcon()
	if not self.RecipeData then
		return
	end
	
	local virtualOutputItemID = self.RecipeData.VirtualOutputItemID
	if not virtualOutputItemID then
		return
	end
	
	-- Local helper value for this logic block.
	local itemConfig = UGCGameData.GetItemConfig(virtualOutputItemID)
	if not itemConfig then
		return
	end
	
	-- Local helper value for this logic block.
	local iconPath = itemConfig["ItemSmallIcon"]
	if not iconPath then
		return
	end
	
	if not self.Image_0 then
		return
	end
	
	-- Local helper value for this logic block.
	local pathString = UGCObjectUtility.GetPathBySoftObjectPath(iconPath)
	
	if pathString and pathString ~= "" then
		local IconTexture = UGCObjectUtility.LoadObject(pathString)
		if IconTexture then
			self.Image_0:SetBrushFromTexture(IconTexture)
		end
	end
end

-- Update item count.
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
	
	-- Local helper value for this logic block.
	local countText = "x" .. tostring(self.RecipeData.OutputCount)
	self.TextBlock_0:SetText(countText)
				local ok, virtualInputItemID = pcall(function() return material["材料虚拟物品ID"] end)
				local ok2, inputCount = pcall(function() return material["所需数量"] end)
	local whiteColor = UGCObjectUtility.NewStruct("SlateColor")
	whiteColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
	self.TextBlock_0:SetColorAndOpacity(whiteColor)
	
	-- Local helper value for this logic block.
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
	
	-- Guard condition before running this branch.
	if self.Image_1 then
		if canCraft then
			self.Image_1:SetVisibility(0)  -- 0 = Visible
		else
			self.Image_1:SetVisibility(2)  -- 2 = Hidden
		end
	end
end

-- Handle button button click.
function WB_Slot:OnButtonClicked()
	-- Guard condition before running this branch.
	
	if not self.RecipeData then
		-- Exit early when requirements are not met.
		return
	end
	
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- Exit early when requirements are not met.
		return
	end
	
	-- Guard condition before running this branch.
	if PlayerController.MMainUI and PlayerController.MMainUI.WB_Inventory then
		-- Keep this section consistent with the original UI flow.
		PlayerController.MMainUI.WB_Inventory:ShowCraftDetails(self.RecipeData)
	else
		-- Keep this section consistent with the original UI flow.
	end
end

function WB_Slot:Tick(MyGeometry, InDeltaTime)
	-- Guard condition before running this branch.
	if self.RecipeData then
		self:UpdateItemCount()
	end
end

-- Load display data.
function WB_Slot:LoadDisplayData()
	-- Keep this section consistent with the original UI flow.
end

return WB_Slot
