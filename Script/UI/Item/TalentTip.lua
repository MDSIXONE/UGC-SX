---@class TalentTip_C:UUserWidget
---@field Image_43 UImage
---@field Talent_Cancel General_SecondLevelButton_3_C
---@field Talent_explain UTextBlock
---@field Talent_sure General_SecondLevelButton_1_C
---@field Talent_Tip UTextBlock
---@field VerticalBox_0 UVerticalBox
--Edit Below--
local TalentTip = { bInitDoOnce = false }

-- Handle the talent flow.
TalentTip.CurrentTalentLevel = 0

function TalentTip:Construct()
    self:LuaInit()
end

function TalentTip:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    
    -- Bind the button event.
    if self.Talent_sure then
        -- Related UI logic.
        if self.Talent_sure.Button_0 then
            self.Talent_sure.Button_0.OnClicked:Add(self.OnSureClicked, self)
            -- Log the success state.
        elseif self.Talent_sure.Button_Levels2_1 then
            self.Talent_sure.Button_Levels2_1.OnClicked:Add(self.OnSureClicked, self)
            -- Log the success state.
        else
            -- Log this action.
        end
    end
    
    -- Bind the button event.
    if self.Talent_Cancel then
        if self.Talent_Cancel.Button_Levels2_3 then
            self.Talent_Cancel.Button_Levels2_3.OnClicked:Add(self.OnCancelClicked, self)
            -- Log the success state.
        elseif self.Talent_Cancel.fuben_cancel then
            self.Talent_Cancel.fuben_cancel.OnClicked:Add(self.OnCancelClicked, self)
            -- Log the success state.
        else
            -- Log this action.
        end
    end
end

-- Related UI logic.
function TalentTip:SetTalentInfo(level)
    self.CurrentTalentLevel = level
    
    if self.Talent_Tip then
        self.Talent_Tip:SetText("是否为（Speed" .. level .. "）加点")
    end
    
    if self.Talent_explain then
        self.Talent_explain:SetText("每点增加1%移动速度")
    end
end

-- Handle the confirm action.
function TalentTip:OnSureClicked()
    -- Log this action.
    
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if not playerState then
        -- Log the error state.
        return
    end
    
    -- Handle the talent flow.
    -- Log that the request was sent to the server.
    UnrealNetwork.CallUnrealRPC(
        playerState,
        playerState,
        "Server_UnlockTalent",
        "Speed",
        self.CurrentTalentLevel
    )
    
    -- Show the tip message.
    self:SetVisibility(ESlateVisibility.Collapsed)
end

-- Handle the cancel action.
function TalentTip:OnCancelClicked()
    -- Log this action.
    self:SetVisibility(ESlateVisibility.Collapsed)
end

return TalentTip
