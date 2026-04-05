---@class Settlement_C:UUserWidget
---@field Image_0 UImage
---@field sure UButton
---@field UniformGridPanel_1 UUniformGridPanel
---@field WB_Slot_2 WB_Slot_2_C
--Edit Below--
local Settlement = { bInitDoOnce = false }

-- Local helper value for this logic block.
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function Settlement:Construct()
	-- Initialize widget state and bindings.
	self:LuaInit()
	
	-- Execute the next UI update step.
	self:CreateRewardSlots()
end

function Settlement:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.sure then
		self.sure.OnClicked:Add(self.OnSureButtonClicked, self)
		-- Continue registering UI interaction callbacks.
	else
		-- Keep this section consistent with the original UI flow.
	end
end

-- Create reward slots.
function Settlement:CreateRewardSlots()
	-- Local helper value for this logic block.
	local matchRewardVirtualID = 5666
	
	if not self.UniformGridPanel_1 then
		-- Exit early when requirements are not met.
		return
	end
	
	-- Keep this section consistent with the original UI flow.
	self.UniformGridPanel_1:ClearChildren()
	
	-- Local helper value for this logic block.
	-- Local helper value for this logic block.
	
	-- Local helper value for this logic block.
	local allRewards = UGCGameData.GetAllFubenreword()
	if not allRewards then
		-- Exit early when requirements are not met.
		-- ugcprint("[Settlement] allRewards = " .. tostring(allRewards))
		return
	end
	
	-- Local helper value for this logic block.
	-- Local helper value for this logic block.
	
	-- Local helper value for this logic block.
	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
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

	-- Local helper value for this logic block.
	local totalRewardCount = 0
	for _, rewardData in pairs(allRewards) do
		local itemCount = math.floor(tonumber(rewardData["閺佷即鍣?]) or 0)
		if itemCount > 0 then
			totalRewardCount = totalRewardCount + itemCount
		end
	end

	if totalRewardCount <= 0 then
		-- Exit early when requirements are not met.
		return
	end

	local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
	if not slotWidget then
		-- Exit early when requirements are not met.
		return
	end

	slotWidget.DisplayItemID = matchRewardVirtualID
	slotWidget.DisplayCount = totalRewardCount
	slotWidget.IsInputItem = false

	if slotWidget.LoadDisplayData then
		slotWidget:LoadDisplayData()
	end

	local gridSlot = self.UniformGridPanel_1:AddChildToUniformGrid(slotWidget)
	if gridSlot then
		gridSlot:SetRow(0)
		gridSlot:SetColumn(0)
		gridSlot:SetHorizontalAlignment(2)
		gridSlot:SetVerticalAlignment(2)
		-- Keep this section consistent with the original UI flow.
	else
		-- Keep this section consistent with the original UI flow.
	end

	-- Keep this section consistent with the original UI flow.
end

-- Handle sure button button click.
function Settlement:OnSureButtonClicked()
	-- Acquire local player references.
	
	-- Acquire local player references.
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if PlayerController then
		-- Keep this section consistent with the original UI flow.
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_GiveRewards")
	end
	
	-- Execute the next UI update step.
	self:RemoveFromParent()
	-- Guard condition before running this branch.
	
	-- Guard condition before running this branch.
	if self.OnSureClicked then
		self.OnSureClicked()
	end
end

return Settlement
