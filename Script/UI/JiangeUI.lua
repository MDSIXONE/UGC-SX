---@class JiangeUI_C:UUserWidget
---@field Button_EXIT UButton
---@field Image_0 UImage
---@field ta_settlement ta_settlement_C
---@field TextBlock_chengshu UTextBlock
--Edit Below--
local JiangeUI = { bInitDoOnce = false }

function JiangeUI:Construct()
    self:LuaInit()
    self:UpdateFloorText()
    -- 鍒濆鍖栨椂闅愯棌缁撶畻鐣岄潰
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

-- 鏇存柊灞傛暟鏄剧ず
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
    -- ugcprint("[JiangeUI] Button_EXIT 鐐瑰嚮")
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    -- 淇濆瓨褰撳墠鍓戦榿灞傛暟
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        -- ugcprint("[JiangeUI] 淇濆瓨鍓戦榿灞傛暟: " .. tostring(PC.JiangeFloor or 0))
        PlayerState:DataSave()
    end

    -- 浼犻€佸洖涓诲煄
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportPlayer", 19053.320312, 50346.1875, 535.063049)

    -- 鎭㈠MMainUI
    if PC.MMainUI then
        PC.MMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        -- ugcprint("[JiangeUI] MMainUI 宸叉仮澶嶆樉绀?)
    end

    -- 浠庤鍙ｅ畬鍏ㄧЩ闄iangeUI锛岄伩鍏嶆嫤鎴Щ鍔ㄦ憞鏉嗚緭鍏?
    PC.JiangeUI = nil
    self:RemoveFromParent()
    -- ugcprint("[JiangeUI] JiangeUI 宸蹭粠瑙嗗彛绉婚櫎")
end

return JiangeUI
