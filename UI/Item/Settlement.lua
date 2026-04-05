---@class Settlement_C:UUserWidget
---@field Image_0 UImage
---@field sure UButton
---@field UniformGridPanel_1 UUniformGridPanel
---@field WB_Slot_2 WB_Slot_2_C
--Edit Below--
local Settlement = { bInitDoOnce = false }

-- 引入UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function Settlement:Construct()
	ugcprint("[Settlement] Construct 被调用")
	self:LuaInit()
	
	-- 创建奖励物品槽位
	self:CreateRewardSlots()
end

function Settlement:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	ugcprint("[Settlement] LuaInit 完成")
	
	-- 绑定 sure 按钮点击事件
	if self.sure then
		self.sure.OnClicked:Add(self.OnSureButtonClicked, self)
		ugcprint("[Settlement] sure 按钮点击事件绑定成功")
	else
		ugcprint("[Settlement] 错误：sure 按钮不存在")
	end
end

-- 创建奖励物品槽位
function Settlement:CreateRewardSlots()
	ugcprint("[Settlement] 开始创建奖励物品槽位")
	
	if not self.UniformGridPanel_1 then
		ugcprint("[Settlement] 错误：UniformGridPanel_1 不存在")
		return
	end
	
	-- 清空面板
	self.UniformGridPanel_1:ClearChildren()
	
	-- 调试：打印数据表路径
	ugcprint("[Settlement] 奖励表路径: " .. tostring(UGCGameData.FubenrewordTablePath))
	
	-- 读取奖励数据表
	local allRewards = UGCGameData.GetAllFubenreword()
	if not allRewards then
		ugcprint("[Settlement] 错误：无法读取副本奖励表")
		ugcprint("[Settlement] allRewards = " .. tostring(allRewards))
		return
	end
	
	ugcprint("[Settlement] 成功读取副本奖励表")
	ugcprint("[Settlement] 奖励数据类型: " .. type(allRewards))
	
	-- 加载 WB_Slot_2 类
	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
	if not SlotClass then
		ugcprint("[Settlement] 错误：无法加载 WB_Slot_2 类")
		return
	end
	
	-- 获取玩家控制器
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		ugcprint("[Settlement] 错误：无法获取玩家控制器")
		return
	end
	
	-- 遍历数据表，为每个奖励创建槽位（最多2行3列，共6个）
	local row = 0
	local col = 0
	local count = 0
	local maxSlots = 6  -- 最多6个槽位（2行 x 3列）
	
	for rowName, rewardData in pairs(allRewards) do
		if count >= maxSlots then
			ugcprint("[Settlement] 已达到最大槽位数量（6个），停止创建")
			break
		end
		
		count = count + 1
		ugcprint("[Settlement] 处理第 " .. count .. " 个奖励, 行名: " .. tostring(rowName))
		
		-- 读取虚拟物品ID和数量
		local virtualItemID = rewardData["虚拟物品ID"]
		local itemCount = rewardData["数量"]
		
		ugcprint("[Settlement] 虚拟物品ID = " .. tostring(virtualItemID) .. ", 数量 = " .. tostring(itemCount))
		
		if virtualItemID and itemCount then
			-- 创建槽位
			local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
			if slotWidget then
				slotWidget.DisplayItemID = virtualItemID
				slotWidget.DisplayCount = itemCount
				slotWidget.IsInputItem = false  -- 这是奖励物品，不是输入材料
				
				-- 手动调用LoadDisplayData来加载数据
				if slotWidget.LoadDisplayData then
					slotWidget:LoadDisplayData()
				end
				
				-- 添加到 UniformGridPanel，返回 Slot
				local gridSlot = self.UniformGridPanel_1:AddChildToUniformGrid(slotWidget)
				if gridSlot then
					-- 设置行列位置
					gridSlot:SetRow(row)
					gridSlot:SetColumn(col)
					
					-- 设置水平和垂直居中对齐
					gridSlot:SetHorizontalAlignment(2)  -- 水平居中
					gridSlot:SetVerticalAlignment(2)    -- 垂直居中
					
					ugcprint("[Settlement] 奖励槽位已添加 - 第" .. count .. "个，位置: (行" .. row .. ", 列" .. col .. ")")
				else
					ugcprint("[Settlement] 错误：AddChildToUniformGrid 返回 nil")
				end
				
				-- 更新位置：每行3列
				col = col + 1
				if col >= 3 then
					col = 0
					row = row + 1
				end
			else
				ugcprint("[Settlement] 错误：无法创建槽位实例")
			end
		else
			ugcprint("[Settlement] 警告：虚拟物品ID或数量为空")
		end
	end
	
	ugcprint("[Settlement] 奖励物品槽位创建完成，共创建 " .. count .. " 个槽位")
end

-- sure 按钮点击事件
function Settlement:OnSureButtonClicked()
	ugcprint("[Settlement] sure 按钮被点击，准备发放奖励并进入结算")
	
	-- 通过服务器RPC发放奖励
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if PlayerController then
		ugcprint("[Settlement] 调用服务器RPC发放奖励")
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_GiveRewards")
	end
	
	-- 关闭 Settlement UI
	self:RemoveFromParent()
	ugcprint("[Settlement] Settlement UI 已关闭")
	
	-- 通知 LevelReward 进入结算
	if self.OnSureClicked then
		self.OnSureClicked()
	end
end

return Settlement