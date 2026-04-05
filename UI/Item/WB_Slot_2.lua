---@class WB_Slot_2_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local WB_Slot_2 = { bInitDoOnce = false } 

-- 引入UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Slot_2:Construct()
	--ugcprint("[WB_Slot_2] Construct 被调用")
	
	-- 如果设置了显示数据，加载它
	if self.DisplayItemID then
		self:LoadDisplayData()
	end
end

-- 加载显示数据
function WB_Slot_2:LoadDisplayData()
	if not self.DisplayItemID then
		--ugcprint("[WB_Slot_2] 错误：DisplayItemID 未设置")
		return
	end
	
	--ugcprint("[WB_Slot_2] 加载显示数据，虚拟物品ID: " .. tostring(self.DisplayItemID))
	
	-- 设置图标
	local itemConfig = UGCGameData.GetItemConfig(self.DisplayItemID)
	if itemConfig and itemConfig["ItemSmallIcon"] then
		local iconPath = itemConfig["ItemSmallIcon"]
		local pathString = UGCObjectUtility.GetPathBySoftObjectPath(iconPath)
		if pathString and pathString ~= "" and self.Image_0 then
			local IconTexture = UGCObjectUtility.LoadObject(pathString)
			if IconTexture then
				self.Image_0:SetBrushFromTexture(IconTexture)
				--ugcprint("[WB_Slot_2] 图标设置成功")
			end
		end
	end
	
	-- 设置数量文字
	if self.TextBlock_0 and self.DisplayCount then
		if self.IsInputItem then
			-- 输入材料：显示当前数量/需要数量
			local PlayerController = UGCGameSystem.GetLocalPlayerController()
			if PlayerController then
				-- 需要先获取真实物品ID
				local mapping = UGCGameData.GetItemMapping(self.DisplayItemID)
				if mapping and mapping["ClassicItemID"] then
					local realItemID = mapping["ClassicItemID"]
					local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, realItemID)
					local countText = tostring(currentCount) .. "/" .. tostring(self.DisplayCount)
					self.TextBlock_0:SetText(countText)
					
					-- 设置颜色
					if currentCount >= self.DisplayCount then
						local greenColor = UGCObjectUtility.NewStruct("SlateColor")
						greenColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 0, 1, 0, 1)
						self.TextBlock_0:SetColorAndOpacity(greenColor)
					else
						local redColor = UGCObjectUtility.NewStruct("SlateColor")
						redColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 0, 0, 1)
						self.TextBlock_0:SetColorAndOpacity(redColor)
					end
				end
			end
		else
			-- 输出材料：只显示数量
			self.TextBlock_0:SetText("x" .. tostring(self.DisplayCount))
			-- 设置为白色
			local whiteColor = UGCObjectUtility.NewStruct("SlateColor")
			whiteColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
			self.TextBlock_0:SetColorAndOpacity(whiteColor)
		end
		--ugcprint("[WB_Slot_2] 文字设置成功")
	end
end

function WB_Slot_2:Tick(MyGeometry, InDeltaTime)
	-- 如果是输入材料，每帧更新数量显示
	if self.IsInputItem and self.DisplayItemID and self.DisplayCount then
		local PlayerController = UGCGameSystem.GetLocalPlayerController()
		if PlayerController and self.TextBlock_0 then
			local mapping = UGCGameData.GetItemMapping(self.DisplayItemID)
			if mapping and mapping["ClassicItemID"] then
				local realItemID = mapping["ClassicItemID"]
				local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, realItemID)
				local countText = tostring(currentCount) .. "/" .. tostring(self.DisplayCount)
				self.TextBlock_0:SetText(countText)
				
				-- 更新颜色
				if currentCount >= self.DisplayCount then
					local greenColor = UGCObjectUtility.NewStruct("SlateColor")
					greenColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 0, 1, 0, 1)
					self.TextBlock_0:SetColorAndOpacity(greenColor)
				else
					local redColor = UGCObjectUtility.NewStruct("SlateColor")
					redColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 0, 0, 1)
					self.TextBlock_0:SetColorAndOpacity(redColor)
				end
			end
		end
	end
end

return WB_Slot_2