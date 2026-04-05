---@class TASK_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_cancel UButton
---@field Image_95 UImage
---@field WrapBox_0 UWrapBox
--Edit Below--
local TASK = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

-- 浠诲姟鐘舵€佹枃鏈?local TASK_STATUS_TEXT = {
    [0] = "鏈畬鎴?,
    [1] = "鍙鍙?,
    [2] = "宸查鍙?
}

function TASK:Construct()
    self:LuaInit()
    self.CurrentPage = 0

    if self.Button_cancel then
        self.Button_cancel.OnClicked:Add(self.OnCancelClicked, self)
    end
    -- 缁戝畾椤电鎸夐挳
    if self.Button_0 then
        self.Button_0.OnClicked:Add(function() self:SwitchPage(0) end, self)
    end
    if self.Button_1 then
        self.Button_1.OnClicked:Add(function() self:SwitchPage(1) end, self)
    end
    if self.Button_2 then
        self.Button_2.OnClicked:Add(function() self:SwitchPage(2) end, self)
    end

    self:RefreshTaskUI()
end

function TASK:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
end

-- 鍒囨崲椤电
function TASK:SwitchPage(pageIndex)
    if self.CurrentPage == pageIndex then return end
    self.CurrentPage = pageIndex
    -- ugcprint("[TASK] 鍒囨崲鍒伴〉绛? " .. tostring(pageIndex))
    self:RefreshTaskUI()
end

--- 鍒锋柊浠诲姟UI锛氭牴鎹綋鍓嶉〉绛捐繃婊や换鍔★紝鍔ㄦ€佸垱寤篢askslot
function TASK:RefreshTaskUI()
    if not self.WrapBox_0 then
        -- ugcprint("[TASK] 閿欒锛歐rapBox_0 涓嶅瓨鍦?)
        return
    end
    self.WrapBox_0:ClearChildren()

    local playerState = self:GetLocalPlayerState()
    if not playerState or not playerState.GetTaskStatus then
        -- ugcprint("[TASK] 閿欒锛氭棤娉曡幏鍙朠layerState鎴朑etTaskStatus")
        return
    end

    local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/Taskslot.Taskslot_C'))
    if not SlotClass then
        -- ugcprint("[TASK] 閿欒锛氭棤娉曞姞杞絋askslot绫?)
        return
    end

    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then return end

    -- 閬嶅巻鎵€鏈変换鍔￠厤缃紝鎸塸age杩囨护
    local allTasks = UGCGameData.GetAllTaskConfig()
    if not allTasks then
        -- ugcprint("[TASK] 閿欒锛氭棤娉曡幏鍙栦换鍔￠厤缃〃")
        return
    end

    -- 鏀堕泦褰撳墠椤电鐨勪换鍔″苟鎸夎鍚嶆帓搴?    local pageTasks = {}
    for rowName, taskConfig in pairs(allTasks) do
        local taskPage = taskConfig.page or 0
        if taskPage == self.CurrentPage then
            table.insert(pageTasks, { rowIndex = tonumber(rowName), config = taskConfig })
        end
    end
    table.sort(pageTasks, function(a, b) return a.rowIndex < b.rowIndex end)

    local count = 0
    for _, taskData in ipairs(pageTasks) do
        local i = taskData.rowIndex
        local taskConfig = taskData.config
        local taskStatus = playerState:GetTaskStatus(i)

        local slot = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
        if slot then
            self.WrapBox_0:AddChild(slot)

            if slot.TextBlock_taskdetail then
                local desc = taskConfig.taskdetail or taskConfig.taskname or ("浠诲姟" .. tostring(i))
                slot.TextBlock_taskdetail:SetText(tostring(desc))
            end

            if slot.TextBlock_buttun then
                slot.TextBlock_buttun:SetText(TASK_STATUS_TEXT[taskStatus] or "鏈煡")
            end

            if slot.Button_0 then
                slot.Button_0:SetIsEnabled(taskStatus == 1)
                local rowIndex = i
                slot.Button_0.OnClicked:Add(function()
                    self:OnTaskSlotClicked(rowIndex)
                end, self)
            end

            count = count + 1
            -- ugcprint("[TASK] 鍒涘缓浠诲姟妲戒綅 " .. i .. ", 椤电: " .. tostring(self.CurrentPage) .. ", 鐘舵€? " .. tostring(taskStatus))
        end
    end
    -- ugcprint("[TASK] 椤电 " .. tostring(self.CurrentPage) .. " 鍏?" .. count .. " 涓换鍔?)
end

--- 浠诲姟妲戒綅鎸夐挳鐐瑰嚮锛氶鍙栧鍔?function TASK:OnTaskSlotClicked(taskRowIndex)
    -- ugcprint("[TASK] 鐐瑰嚮棰嗗彇浠诲姟 " .. tostring(taskRowIndex))
    local playerState = self:GetLocalPlayerState()
    if not playerState then return end

    local taskStatus = playerState:GetTaskStatus(taskRowIndex)
    if taskStatus ~= 1 then return end

    UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimTaskReward", taskRowIndex)
end

function TASK:OnCancelClicked()
    self:SetVisibility(ESlateVisibility.Collapsed)
    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end
end

function TASK:GetLocalPlayerState()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        return UGCGameSystem.GetPlayerStateByPlayerController(pc)
    end
    return nil
end

function TASK:Destruct()
end

return TASK
