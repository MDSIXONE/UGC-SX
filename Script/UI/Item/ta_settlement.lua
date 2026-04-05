---@class ta_settlement_C:UUserWidget
---@field Image_0 UImage
---@field quit UButton
---@field settlementtip UTextBlock
---@field sure UButton
---@field UniformGridPanel_1 UUniformGridPanel
--Edit Below--
local ta_settlement = { bInitDoOnce = false }

function ta_settlement:Construct()
    -- ugcprint("[ta_settlement] Construct 琚皟鐢?)
    self:LuaInit()
    self:CreateRewardSlots()
end

function ta_settlement:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true

    if self.sure then
        self.sure.OnClicked:Add(self.OnSureClicked, self)
        -- ugcprint("[ta_settlement] sure 鎸夐挳缁戝畾鎴愬姛")
    end

    if self.quit then
        self.quit.OnClicked:Add(self.OnQuitClicked, self)
        -- ugcprint("[ta_settlement] quit 鎸夐挳缁戝畾鎴愬姛")
    end

    local levelNum = self.DisplayLevelNum or 1
    if self.settlementtip then
        self.settlementtip:SetText("鎭枩閫氳繃绗? .. tostring(levelNum) .. "灞傦紝鑾峰緱濂栧姳濡備笅")
    end
end

-- 鍒涘缓濂栧姳鐗╁搧妲戒綅锛堝浐瀹氭樉绀?涓敾閫犵煶锛?
function ta_settlement:CreateRewardSlots()
    -- ugcprint("[ta_settlement] 寮€濮嬪垱寤哄鍔辩墿鍝佹Ы浣嶏紙閿婚€犵煶x1锛?)

    if not self.UniformGridPanel_1 then
        -- ugcprint("[ta_settlement] 閿欒锛歎niformGridPanel_1 涓嶅瓨鍦?)
        return
    end

    self.UniformGridPanel_1:ClearChildren()

    local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
    if not SlotClass then
        -- ugcprint("[ta_settlement] 閿欒锛氭棤娉曞姞杞?WB_Slot_2 绫?)
        return
    end

    local PlayerController = UGCGameSystem.GetLocalPlayerController()
    if not PlayerController then
        -- ugcprint("[ta_settlement] 閿欒锛氭棤娉曡幏鍙栫帺瀹舵帶鍒跺櫒")
        return
    end

    -- 鍥哄畾濂栧姳锛?涓敾閫犵煶锛堣櫄鎷熺墿鍝両D=5666锛?
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

    -- ugcprint("[ta_settlement] 濂栧姳妲戒綅鍒涘缓瀹屾垚锛氶敾閫犵煶x1")
end

-- sure鎸夐挳锛氶鍙栧鍔卞苟缁х画涓嬩竴鍏?
function ta_settlement:OnSureClicked()
    -- ugcprint("[ta_settlement] sure 琚偣鍑伙紝棰嗗彇濂栧姳骞剁户缁笅涓€鍏?)
    self:SetVisibility(2) -- Collapsed

    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC then
        -- 鍙戞斁1涓敾閫犵煶濂栧姳
        local PS = UGCGameSystem.GetLocalPlayerState()
        if PS then
            UnrealNetwork.CallUnrealRPC(PS, PS, "Server_GiveTaReward")
        end
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ResumeTriggerBoxSpawning")
        -- 寤惰繜鍒锋柊jiange閿婚€犵煶鏁伴噺鏄剧ず
        self:DelayRefreshJiange(PC)
    end
end

-- quit鎸夐挳锛氶鍙栧鍔憋紝閫€鍑猴紝浼犻€佸洖鍑虹敓鐐癸紝鎭㈠涓荤晫闈?
function ta_settlement:OnQuitClicked()
    -- ugcprint("[ta_settlement] quit 琚偣鍑伙紝棰嗗彇濂栧姳骞朵紶閫佸洖鍑虹敓鐐?)
    self:SetVisibility(2) -- Collapsed

    -- 鍙戞斁1涓敾閫犵煶濂栧姳
    local PS = UGCGameSystem.GetLocalPlayerState()
    if PS then
        UnrealNetwork.CallUnrealRPC(PS, PS, "Server_GiveTaReward")
    end

    -- 鑾峰彇PC锛堝绉嶆柟寮忓皾璇曪級
    local PC = self:GetOwningPlayer()
    if not PC then
        -- ugcprint("[ta_settlement] GetOwningPlayer 杩斿洖nil锛屽皾璇旼etLocalPlayerController")
        PC = UGCGameSystem.GetLocalPlayerController()
    end
    if not PC then
        -- ugcprint("[ta_settlement] GetLocalPlayerController 杩斿洖nil锛屽皾璇曢€氳繃Pawn鑾峰彇")
        local Pawn = UGCGameSystem.GetLocalPlayerPawn()
        if Pawn then
            PC = Pawn:GetController()
        end
    end
    if not PC then
        -- ugcprint("[ta_settlement] 閿欒锛氭棤娉曡幏鍙朠C")
        return
    end

    -- ugcprint("[ta_settlement] PC鑾峰彇鎴愬姛锛屽彂閫佷紶閫丷PC")
    -- 浼犻€佸洖涓诲煄锛堜娇鐢≧PC锛岀湡鏈哄吋瀹癸級
    UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportPlayer", 19053.320312, 50346.1875, 535.063049)

    -- 淇濆瓨鍓戦榿灞傛暟
    local PlayerState = UGCGameSystem.GetLocalPlayerState()
    if PlayerState then
        PlayerState:DataSave()
    end

    -- 浠庤鍙ｅ畬鍏ㄧЩ闄iangeUI锛岄伩鍏嶆嫤鎴Щ鍔ㄦ憞鏉嗚緭鍏?
    if PC.JiangeUI then
        PC.JiangeUI:RemoveFromParent()
        PC.JiangeUI = nil
        -- ugcprint("[ta_settlement] JiangeUI 宸蹭粠瑙嗗彛绉婚櫎")
    end
    if PC.MMainUI then
        PC.MMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end

    -- ugcprint("[ta_settlement] 浼犻€佸畬鎴愶紝涓荤晫闈㈠凡鎭㈠")
end

-- 寤惰繜鍒锋柊jiange閿婚€犵煶鏁伴噺鏄剧ず
function ta_settlement:DelayRefreshJiange(PC)
    UGCTimerUtility.CreateLuaTimer(
        0.5,
        function()
            if PC and PC.MMainUI and PC.MMainUI.jiange then
                if PC.MMainUI.jiange.UpdateCostDisplay then
                    PC.MMainUI.jiange:UpdateCostDisplay()
                    -- ugcprint("[ta_settlement] jiange閿婚€犵煶鏁伴噺宸插埛鏂?)
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
