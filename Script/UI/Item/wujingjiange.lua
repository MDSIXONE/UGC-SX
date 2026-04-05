---@class wujingjiange_C:UUserWidget
---@field Button_0 UButton
---@field Button_1 UButton
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_5 UButton
---@field Button_6 UButton
---@field Button_8 UButton
---@field Button_9 UButton
---@field Button_10 UButton
---@field Button_11 UButton
---@field cancel UButton
---@field cengshu UTextBlock
---@field day UTextBlock
---@field get1 UButton
---@field get2 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field Image_2 UImage
---@field Image_3 UImage
---@field Image_4 UImage
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_7 UImage
---@field Image_8 UImage
---@field Image_9 UImage
---@field Image_10 UImage
---@field Image_11 UImage
---@field Image_12 UImage
---@field START UButton
---@field state100 UTextBlock
---@field state1000 UTextBlock
---@field state200 UTextBlock
---@field state300 UTextBlock
---@field state400 UTextBlock
---@field state500 UTextBlock
---@field state600 UTextBlock
---@field state700 UTextBlock
---@field state800 UTextBlock
---@field state900 UTextBlock
---@field TextBlock_5 UTextBlock
--Edit Below--
local wujingjiange = { bInitDoOnce = false, bFullScreenLayerApplied = false }

-- 灞傜骇濂栧姳閰嶇疆锛氬眰鏁?-> 濂栧姳鏁伴噺
local FLOOR_REWARD_CONFIG = {
    [100] = 100, [200] = 200, [300] = 300, [400] = 400, [500] = 500,
    [600] = 600, [700] = 700, [800] = 800, [900] = 900, [1000] = 1000,
}

-- 灞傜骇瀵瑰簲鐨剆tate鎺т欢鍚?
local FLOOR_STATE_MAP = {
    [100] = "state100", [200] = "state200", [300] = "state300", [400] = "state400", [500] = "state500",
    [600] = "state600", [700] = "state700", [800] = "state800", [900] = "state900", [1000] = "state1000",
}

function wujingjiange:Construct()
    self:LuaInit()
    self:SetVisibility(1)
end

function wujingjiange:ApplyFullScreenLayer()
    if self.bFullScreenLayerApplied then
        return
    end

    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.AddWidgetHiddenLayer(SkillPanel)
    end

    self.bFullScreenLayerApplied = true
end

function wujingjiange:ReleaseFullScreenLayer()
    if not self.bFullScreenLayerApplied then
        return
    end

    local MainControlPanel = UGCWidgetManagerSystem.GetMainUI()
    if MainControlPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.MainControlBaseUI)
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(MainControlPanel.ShootingUIPanel)
    end
    local SkillPanel = UGCWidgetManagerSystem.GetSkillRootPanel()
    if SkillPanel then
        UGCWidgetManagerSystem.SubWidgetHiddenLayer(SkillPanel)
    end

    self.bFullScreenLayerApplied = false
end

function wujingjiange:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.START then
        self.START.OnClicked:Add(self.OnStartClicked, self)
    end
    if self.cancel then
        self.cancel.OnClicked:Add(self.OnCancelClicked, self)
    end
    -- 缁戝畾姣忔棩棰嗗彇鎸夐挳
    if self.get1 then
        self.get1.OnClicked:Add(self.OnGet1Clicked, self)
    end
    -- 缁戝畾灞傜骇濂栧姳棰嗗彇鎸夐挳
    if self.get2 then
        self.get2.OnClicked:Add(self.OnGet2Clicked, self)
    end

    -- 缁戝畾灞傜骇鎸夐挳锛圔utton_0~Button_11瀵瑰簲涓嶅悓灞傜骇濂栧姳閫夋嫨锛?
    self.SelectedFloor = 100
    local buttonFloorMap = {
        {btn = "Button_0", floor = 100},
        {btn = "Button_1", floor = 200},
        {btn = "Button_2", floor = 300},
        {btn = "Button_3", floor = 400},
        {btn = "Button_5", floor = 500},
        {btn = "Button_6", floor = 600},
        {btn = "Button_8", floor = 700},
        {btn = "Button_9", floor = 800},
        {btn = "Button_10", floor = 900},
        {btn = "Button_11", floor = 1000},
    }
    for _, mapping in ipairs(buttonFloorMap) do
        local btn = self[mapping.btn]
        local floor = mapping.floor
        if btn then
            btn.OnClicked:Add(function()
                self.SelectedFloor = floor
                -- ugcprint("[wujingjiange] 閫変腑灞傜骇: " .. tostring(floor))
                self:RefreshRewardStates()
            end, self)
        end
    end
end

function wujingjiange:Show()
    self:SetVisibility(0)
    self:UpdateFloorText()
    self:RefreshRewardStates()
    self:ApplyFullScreenLayer()
end

-- 鏇存柊灞傛暟鏄剧ず
function wujingjiange:UpdateFloorText()
    if not self.cengshu then
        -- ugcprint("[wujingjiange] cengshu 鎺т欢涓嶅瓨鍦?)
        return
    end

    local floor = 0
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        floor = (PC.JiangeFloor or 0) + 1
    end
    self.cengshu:SetText(tostring(floor))
    -- ugcprint("[wujingjiange] 灞傛暟鏄剧ず: " .. tostring(floor))
end

function wujingjiange:OnCancelClicked()
    self:ReleaseFullScreenLayer()
    self:SetVisibility(2)
end

function wujingjiange:OnStartClicked()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then
        -- ugcprint("[wujingjiange] PC涓簄il")
        return
    end

    -- 妫€娴嬪苟鍗镐笅绁炲墤銆佺褰卞拰琛€鑴夛紙鐩存帴鎵ц鍗镐笅閫昏緫锛屼笉璧版寜閽洖璋冿級
    local needTip = false
    if PC.MMainUI then
        -- 鍗镐笅绁炲墤
        local jiangeUI = PC.MMainUI.jiange
        if jiangeUI and jiangeUI.IsWearing then
            jiangeUI:ApplySkill(false)
            jiangeUI:ApplyAtkBonus(false)
            jiangeUI.IsWearing = false
            if jiangeUI.weartip then jiangeUI.weartip:SetText("绌挎埓") end
            -- ugcprint("[wujingjiange] 宸茶嚜鍔ㄥ嵏涓嬬鍓?)
            needTip = true
        end
        -- 鍗镐笅绁炲奖
        local shenyinUI = PC.MMainUI.shenyin
        if shenyinUI and shenyinUI.CurrentWearing then
            local wearingBtn = shenyinUI.CurrentWearing
            local pair = shenyinUI:GetPairByButton(wearingBtn)
            if pair then
                shenyinUI.SlotStates[wearingBtn] = "unwear"
                shenyinUI.CurrentWearing = nil
                if pair.border and shenyinUI[pair.border] then
                    shenyinUI[pair.border]:SetBrushColor({R = 0, G = 0, B = 0, A = 0})
                end
                shenyinUI:ApplySkill(pair.skill, false, shenyinUI.SlotQualities[wearingBtn])
                shenyinUI.CurrentEcexpBonus = 0
                shenyinUI:ApplyEcexp(0)
            end
            -- ugcprint("[wujingjiange] 宸茶嚜鍔ㄥ嵏涓嬬褰?)
            needTip = true
        end

        -- 鍗镐笅琛€鑴夛紙鍚屾鏈湴鎸夐挳鏄剧ず锛?
        local playerState = UGCGameSystem.GetLocalPlayerState()
        local bloodlineEnabled = false
        if playerState then
            if playerState.UGCBloodlineEnabled ~= nil then
                bloodlineEnabled = (playerState.UGCBloodlineEnabled == true)
            elseif playerState.GameData then
                bloodlineEnabled = (playerState.GameData.BloodlineEnabled == true)
            end
        end

        if bloodlineEnabled then
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SetBloodlineEnabled", false)

            if PC.MMainUI.xuemai then
                PC.MMainUI.xuemai.bBloodlineEnabled = false
                if PC.MMainUI.xuemai.UpdateImages then
                    PC.MMainUI.xuemai:UpdateImages()
                end
            end

            -- ugcprint("[wujingjiange] 宸茶嚜鍔ㄥ嵏涓嬭鑴?)
            needTip = true
        end
    end

    if needTip then
        -- 寮瑰嚭鎻愮ず锛岀瓑2绉掓彁绀烘秷澶卞悗鍐嶄紶閫?
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("鎸戞垬鍓戦榿涓€傘€傘€傜鍓戙€佺褰变笌琛€鑴夊凡琚鐢?)
        end
        UGCTimerUtility.CreateLuaTimer(2.0, function()
            self:DoEnterJiange(PC)
        end, false, "WujingJiange_DelayEnter")
    else
        -- 娌℃湁闇€瑕佸嵏涓嬬殑锛岀洿鎺ヨ繘鍏?
        self:DoEnterJiange(PC)
    end
end

-- 瀹為檯鎵ц浼犻€佽繘鍏ュ墤闃佺殑閫昏緫
function wujingjiange:DoEnterJiange(PC)
    if not PC then return end
    -- ugcprint("[wujingjiange] 寮€濮嬩紶閫?)
    -- 閫氳繃RPC璋冪敤鏈嶅姟绔紶閫?
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportPlayer", 268737.21875, 238584.484375, 1118.539795)
    -- 闅愯棌wujingjiange闈㈡澘
    self:SetVisibility(2)

    -- 鎭㈠鍏ㄥ睆閬尅锛圫how鏃跺姞鐨勶級
    self:ReleaseFullScreenLayer()

    -- 鐩存帴鍒囨崲鍒癑iangeUI
    self:SwitchToJiangeUI(PC)
end

-- 闅愯棌MMainUI锛屽垱寤哄苟鏄剧ずJiangeUI
function wujingjiange:SwitchToJiangeUI(PC)
    if not PC then return end

    -- 闅愯棌MMainUI
    if PC.MMainUI then
        PC.MMainUI:SetVisibility(ESlateVisibility.Collapsed)
        -- ugcprint("[wujingjiange] MMainUI 宸查殣钘?)
    end

    -- 鍒涘缓JiangeUI锛堝鏋滆繕娌″垱寤鸿繃锛?
    if not PC.JiangeUI then
        local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
        local jiangeUI = UGCGameData.GetUI(PC, "JiangeUI")
        if jiangeUI then
            PC.JiangeUI = jiangeUI
            jiangeUI:AddToViewport(1100)
            -- ugcprint("[wujingjiange] JiangeUI 宸插垱寤哄苟娣诲姞鍒拌鍙?)
        else
            -- ugcprint("[wujingjiange] 閿欒锛氭棤娉曞垱寤?JiangeUI")
        end
    else
        PC.JiangeUI:SetVisibility(ESlateVisibility.Visible)
        if PC.JiangeUI.UpdateFloorText then
            PC.JiangeUI:UpdateFloorText()
        end
        -- ugcprint("[wujingjiange] JiangeUI 宸叉仮澶嶆樉绀?)
    end
end

-- 瑙ｆ瀽宸查鍙栫殑灞傜骇璁板綍
function wujingjiange:ParseClaimedFloors()
    local PC = UGCGameSystem.GetLocalPlayerController()
    local str = PC and PC.JiangeClaimedFloors or ""
    local claimed = {}
    if str ~= "" then
        for s in string.gmatch(str, "([^,]+)") do
            local n = tonumber(s)
            if n then claimed[n] = true end
        end
    end
    return claimed
end

-- 鍒锋柊鎵€鏈夊鍔辩姸鎬佹樉绀?
function wujingjiange:RefreshRewardStates()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    local playerFloor = PC.JiangeFloor or 0
    local claimed = self:ParseClaimedFloors()

    -- 鏇存柊姣忎釜灞傜骇鐨剆tate鏂囨湰
    for floor, stateName in pairs(FLOOR_STATE_MAP) do
        local stateWidget = self[stateName]
        if stateWidget then
            if claimed[floor] then
                stateWidget:SetText("宸查鍙?)
            elseif playerFloor >= floor then
                stateWidget:SetText("鍙鍙?)
            else
                stateWidget:SetText(tostring(floor) .. "灞?)
            end
        end
    end

    -- 鏇存柊姣忔棩棰嗗彇鏄剧ず
    local dailyAmount = PC.JiangeDailyAmount or 1
    if self.day then
        self.day:SetText(tostring(dailyAmount) .. "*")
    end

    -- ugcprint("[wujingjiange] 濂栧姳鐘舵€佸凡鍒锋柊, 灞傛暟=" .. tostring(playerFloor) .. ", 姣忔棩=" .. tostring(dailyAmount))
end

-- 姣忔棩棰嗗彇鎸夐挳锛坓et1锛?
function wujingjiange:OnGet1Clicked()
    -- ugcprint("[wujingjiange] get1 姣忔棩棰嗗彇鎸夐挳鐐瑰嚮")
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    -- 闃叉缃戠粶寤惰繜鏈熼棿閲嶅鐐瑰嚮
    if self.DailyClaimPending then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("棰嗗彇璇锋眰澶勭悊涓?..")
        end
        return
    end

    -- 妫€鏌ヤ粖澶╂槸鍚﹀凡棰?
    local today = os.date("%Y-%m-%d")
    local lastDate = PC.JiangeDailyClaimDate or ""
    if lastDate == today then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("浠婂ぉ宸茬粡棰嗗彇杩囦簡")
        end
        -- ugcprint("[wujingjiange] 浠婂ぉ宸查鍙栬繃姣忔棩濂栧姳")
        return
    end

    -- 璋冪敤鏈嶅姟绔鍙?
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        self.DailyClaimPending = true
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimJiangeDailyReward")
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("棰嗗彇璇锋眰宸插彂閫?)
        end
        -- ugcprint("[wujingjiange] 鍙戦€佹瘡鏃ラ鍙栬姹?)
    else
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("棰嗗彇澶辫触锛岃绋嶅悗閲嶈瘯")
        end
    end
end

-- 灞傜骇濂栧姳棰嗗彇鎸夐挳锛坓et2锛?
function wujingjiange:OnGet2Clicked()
    local targetFloor = self.SelectedFloor or 100
    -- ugcprint("[wujingjiange] get2 灞傜骇濂栧姳鎸夐挳鐐瑰嚮, 閫変腑灞?" .. tostring(targetFloor))

    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then return end

    local playerFloor = PC.JiangeFloor or 0

    -- 妫€鏌ユ槸鍚﹁揪鍒拌灞?
    if playerFloor < targetFloor then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("鏈揪鍒? .. tostring(targetFloor) .. "灞?)
        end
        -- ugcprint("[wujingjiange] 灞傛暟涓嶈冻: " .. tostring(playerFloor) .. "/" .. tostring(targetFloor))
        return
    end

    -- 妫€鏌ユ槸鍚﹀凡棰嗗彇
    local claimed = self:ParseClaimedFloors()
    if claimed[targetFloor] then
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip("璇ュ眰濂栧姳宸查鍙?)
        end
        -- ugcprint("[wujingjiange] 璇ュ眰濂栧姳宸查鍙? " .. tostring(targetFloor))
        return
    end

    -- 璋冪敤鏈嶅姟绔鍙?
    local playerState = UGCGameSystem.GetLocalPlayerState()
    if playerState then
        local rewardAmount = FLOOR_REWARD_CONFIG[targetFloor] or 0
        UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimJiangeFloorReward", targetFloor)
        if PC.MMainUI and PC.MMainUI.ShowTip then
            PC.MMainUI:ShowTip(tostring(targetFloor) .. "灞傚鍔遍鍙栨垚鍔燂紒鑾峰緱 " .. tostring(rewardAmount) .. " 涓?)
        end
        -- ugcprint("[wujingjiange] 鍙戦€佸眰绾у鍔遍鍙栬姹? " .. tostring(targetFloor))
    end
end

function wujingjiange:Destruct()
    self:ReleaseFullScreenLayer()
end

return wujingjiange
