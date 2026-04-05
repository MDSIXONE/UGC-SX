---@class WB_Slot_2_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local WB_Slot_2 = { bInitDoOnce = false } 

-- Related UI logic.
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Slot_2:Construct()
	-- Log this action.
	
	-- Related UI logic.
	if self.DisplayItemID then
		self:LoadDisplayData()
	end
end

-- Related UI logic.
function WB_Slot_2:LoadDisplayData()
	if not self.DisplayItemID then
		-- Log this action.
		return
	end
	
	-- Log this action.
	
	-- Related UI logic.
	local itemConfig = UGCGameData.GetItemConfig(self.DisplayItemID)
	if itemConfig and itemConfig["ItemSmallIcon"] then
		local iconPath = itemConfig["ItemSmallIcon"]
		local pathString = UGCObjectUtility.GetPathBySoftObjectPath(iconPath)
		if pathString and pathString ~= "" and self.Image_0 then
			local IconTexture = UGCObjectUtility.LoadObject(pathString)
			if IconTexture then
				self.Image_0:SetBrushFromTexture(IconTexture)
				-- Log this action.
			end
		end
	end
	
	-- Related UI logic.
	if self.TextBlock_0 and self.DisplayCount then
		if self.IsInputItem then
			-- Related UI logic.
			local PlayerController = UGCGameSystem.GetLocalPlayerController()
			if PlayerController then
				-- Related UI logic.
				local mapping = UGCGameData.GetItemMapping(self.DisplayItemID)
				if mapping and mapping["ClassicItemID"] then
					local realItemID = mapping["ClassicItemID"]
					local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, realItemID)
					local countText = tostring(currentCount) .. "/" .. tostring(self.DisplayCount)
					self.TextBlock_0:SetText(countText)
					
					-- Related UI logic.
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
			-- Related UI logic.
			self.TextBlock_0:SetText("x" .. tostring(self.DisplayCount))
			-- Related UI logic.
			local whiteColor = UGCObjectUtility.NewStruct("SlateColor")
			whiteColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
			self.TextBlock_0:SetColorAndOpacity(whiteColor)
		end
		-- Log this action.
	end
end

function WB_Slot_2:Tick(MyGeometry, InDeltaTime)
	-- Related UI logic.
	if self.IsInputItem and self.DisplayItemID and self.DisplayCount then
		local PlayerController = UGCGameSystem.GetLocalPlayerController()
		if PlayerController and self.TextBlock_0 then
			local mapping = UGCGameData.GetItemMapping(self.DisplayItemID)
			if mapping and mapping["ClassicItemID"] then
				local realItemID = mapping["ClassicItemID"]
				local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, realItemID)
				local countText = tostring(currentCount) .. "/" .. tostring(self.DisplayCount)
				self.TextBlock_0:SetText(countText)
				
				-- Related UI logic.
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
