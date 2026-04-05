---@class ta_settlement_C:UUserWidget
---@field Image_0 UImage
---@field quit UButton
---@field settlementtip UTextBlock
---@field sure UButton
---@field UniformGridPanel_1 UUniformGridPanel
--Edit Below--
local ta_settlement = { bInitDoOnce = false }

function ta_settlement:Construct()
    -- Initialize widget state and bindings.
    self:LuaInit()
    self:CreateRewardSlots()
end

function ta_settlement:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true

    if self.sure then
        self.sure.OnClicked:Add(self.OnSureClicked, self)
        -- Continue registering UI interaction callbacks.
    end

    if self.quit then
        self.quit.OnClicked:Add(self.OnQuitClicked, self)
        -- Continue registering UI interaction callbacks.
    end

    local levelNum = self.DisplayLevelNum or 1
    if self.settlementtip then
        self.settlementtip:SetText("閹厼鏋╅柅姘崇箖缁? .. tostring(levelNum) .. "鐏炲偊绱濋懢宄扮繁婵傛牕濮虫俊鍌欑瑓")
    end
end

-- Create reward slots.
function ta_settlement:CreateRewardSlots()
    -- Guard condition before running this branch.

    if not self.UniformGridPanel_1 then
        -- Exit early when requirements are not met.
        return
    end

    self.UniformGridPanel_1:ClearChildren()

    local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
    if not SlotClass then
        -- Exit early when requirements are not met.
        return
    end

    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then
        -- Exit early when requirements are not met.
        return
    end

    -- Local helper value for this logic block.
    local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
    if slotWidget then
        slotWidget.DisplayItemID = 5666
        slotWidget.DisplayCount = 1
        slotWidget.IsInputItem = false
        slotWidget:LoadDisplayData()

        local gridSlot = self.UniformGridPanel_1:AddChildToUniformGrid(slotWidget)
        if gridSlot then
            gridSlot:SetRow(0)
            gridSlot:SetColumn(0)
            gridSlot:SetHorizontalAlignment(2)
            gridSlot:SetVerticalAlignment(2)
        end
    end

    -- Keep this section consistent with the original UI flow.
end

-- Handle sure button click.
function ta_settlement:OnSureClicked()
    -- Configure initial widget visibility.
    self:SetVisibility(2) -- Collapsed

    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        -- Local helper value for this logic block.
        local PS = UGCGameSystem.GetLocalPlayerState()
        if PS then
            UnrealNetwork.CallUnrealRPC(PS, PS, "Server_GiveTaReward")
        end
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ResumeTriggerBoxSpawning")
        -- Execute the next UI update step.
        self:DelayRefreshJiange(PC)
    end
end

-- Handle quit button click.
function ta_settlement:OnQuitClicked()
    -- Configure initial widget visibility.
    self:SetVisibility(2) -- Collapsed

    -- Local helper value for this logic block.
    local PS = UGCGameSystem.GetLocalPlayerState()
    if PS then
        UnrealNetwork.CallUnrealRPC(PS, PS, "Server_GiveTaReward")
    end

    -- Local helper value for this logic block.
    local PC = self:GetOwningPlayer()
    if not PC then
        -- Acquire local player references.
        PC = UGCGameSystem.GetLocalPlayerController()
    end
    if not PC then
        -- Local helper value for this logic block.
        local Pawn = UGCGameSystem.GetLocalPlayerPawn()
        if Pawn then
            PC = Pawn:GetController()
        end
    end
    if not PC then
        -- Exit early when requirements are not met.
        return
    end

    -- Keep this section consistent with the original UI flow.
    -- Keep this section consistent with the original UI flow.
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportPlayer", 19053.320312, 50346.1875, 535.063049)

    -- Local helper value for this logic block.
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        PlayerState:DataSave()
    end

    -- Guard condition before running this branch.
    if PC.JiangeUI then
        PC.JiangeUI:RemoveFromParent()
        PC.JiangeUI = nil
        -- Keep this section consistent with the original UI flow.
    end
    if PC.MMainUI then
        PC.MMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end

    -- Keep this section consistent with the original UI flow.
end

-- Delay refresh jiange.
function ta_settlement:DelayRefreshJiange(PC)
    UGCTimerUtility.CreateLuaTimer(
        0.5,
        function()
            if PC and PC.MMainUI and PC.MMainUI.jiange then
                if PC.MMainUI.jiange.UpdateCostDisplay then
                    PC.MMainUI.jiange:UpdateCostDisplay()
                    -- Keep this section consistent with the original UI flow.
                end
            end
        end,
        false,
        "RefreshJiange_Timer"
    )
end

function ta_settlement:Destruct()
end

return ta_settlement
