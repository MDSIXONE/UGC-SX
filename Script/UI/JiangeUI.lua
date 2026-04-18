---@class JiangeUI_C:UUserWidget
---@field Button_EXIT UButton
---@field Image_0 UImage
---@field ta_settlement ta_settlement_C
---@field TextBlock_chengshu UTextBlock
local JiangeUI = { bInitDoOnce = false }

function JiangeUI:Construct()
    self:LuaInit()
    self:UpdateFloorText()
    -- Hide settlement panel on initialization.
    if self.ta_settlement then
        self.ta_settlement:SetVisibility(ESlateVisibility.Collapsed)
    end
end

function JiangeUI:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.Button_EXIT then
        self.Button_EXIT.OnClicked:Add(self.OnExitClicked, self)
    end
end

-- Update floor text display.
function JiangeUI:UpdateFloorText()
    if not self.TextBlock_chengshu then return end
    local floor = 0
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        floor = (PC.JiangeFloor or 0) + 1
    end
    self.TextBlock_chengshu:SetText(tostring(floor))
end

function JiangeUI:OnExitClicked()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    -- Save current Jiange floor.
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        PlayerState:DataSave()
    end

    -- Teleport back to main city.
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportPlayer", 19053.320312, 50346.1875, 535.063049)

    -- Restore main UI visibility.
    if PC.MMainUI then
        PC.MMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end

    -- Remove JiangeUI from viewport to avoid input blocking.
    PC.JiangeUI = nil
    self:RemoveFromParent()
end

return JiangeUI
