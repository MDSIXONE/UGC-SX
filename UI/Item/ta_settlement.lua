---@class ta_settlement_C:UUserWidget
---@field Image_0 UImage
---@field quit UButton
---@field settlementtip UTextBlock
---@field sure UButton
---@field UniformGridPanel_1 UUniformGridPanel
--Edit Below--
local ta_settlement = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function ta_settlement:Construct()
    ugcprint("[ta_settlement] Construct 被调用")
    self:LuaInit()
    self:CreateRewardSlots()
end

function ta_settlement:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true

    if self.sure then
        self.sure.OnClicked:Add(self.OnSureClicked, self)
        ugcprint("[ta_settlement] sure 按钮绑定成功")
    end

    if self.quit then
        self.quit.OnClicked:Add(self.OnQuitClicked, self)
        ugcprint("[ta_settlement] quit 按钮绑定成功")
    end

    local levelNum = self.DisplayLevelNum or 1
    if self.settlementtip then
        self.settlementtip:SetText("恭喜通过第" .. tostring(levelNum) .. "层，获得奖励如下")
    end
end

-- 创建奖励物品槽位
function ta_settlement:CreateRewardSlots()
    ugcprint("[ta_settlement] 开始创建奖励物品槽位")

    if not self.UniformGridPanel_1 then
        ugcprint("[ta_settlement] 错误：UniformGridPanel_1 不存在")
        return
    end

    self.UniformGridPanel_1:ClearChildren()

    local allRewards = UGCGameData.GetAllFubenreword()
    if not allRewards then
        ugcprint("[ta_settlement] 错误：无法读取奖励表")
        return
    end

    local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
    if not SlotClass then
        ugcprint("[ta_settlement] 错误：无法加载 WB_Slot_2 类")
        return
    end

    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then
        ugcprint("[ta_settlement] 错误：无法获取玩家控制器")
        return
    end

    local row = 0
    local col = 0
    local count = 0
    local maxSlots = 6

    for rowName, rewardData in pairs(allRewards) do
        if count >= maxSlots then break end
        count = count + 1

        local virtualItemID = rewardData["虚拟物品ID"]
        local itemCount = rewardData["数量"]

        if virtualItemID and itemCount then
            local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
            if slotWidget then
                slotWidget.DisplayItemID = virtualItemID
                slotWidget.DisplayCount = itemCount
                slotWidget.IsInputItem = false
                slotWidget:LoadDisplayData()

                local gridSlot = self.UniformGridPanel_1:AddChildToUniformGrid(slotWidget)
                if gridSlot then
                    gridSlot:SetRow(row)
                    gridSlot:SetColumn(col)
                    gridSlot:SetHorizontalAlignment(2)
                    gridSlot:SetVerticalAlignment(2)
                end

                col = col + 1
                if col >= 3 then
                    col = 0
                    row = row + 1
                end
            end
        end
    end

    ugcprint("[ta_settlement] 奖励槽位创建完成，共 " .. count .. " 个")
end

-- sure按钮：继续下一关
function ta_settlement:OnSureClicked()
    ugcprint("[ta_settlement] sure 被点击，继续下一关")
    self:SetVisibility(2) -- Collapsed

    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ResumeTriggerBoxSpawning")
    end
end

-- quit按钮：退出，传送回出生点
function ta_settlement:OnQuitClicked()
    ugcprint("[ta_settlement] quit 被点击，传送回出生点")
    self:SetVisibility(2) -- Collapsed

    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    -- 传送回出生点
    UGCPlayerControllerSystem.TeleportTo(PC, 179484.53125, 123583.8125, 358.048889)
    ugcprint("[ta_settlement] 传送完成")
end

function ta_settlement:Destruct()
end

return ta_settlement
