---@class chuansong_2_C:UUserWidget
---@field CanvasPanel_0 UCanvasPanel
---@field fuben1 UButton
---@field fuben1_Text UTextBlock
---@field fuben2 UButton
---@field fuben2_Text UTextBlock
---@field fuben3 UButton
---@field fuben3_Text UTextBlock
---@field fuben4 UButton
---@field fuben4_Text UTextBlock
---@field HorizontalBox_135 UHorizontalBox
---@field Image_53 UImage
---@field Image_54 UImage
---@field Image_55 UImage
---@field Image_56 UImage
---@field ImageEx_25 UImageEx
---@field Zhuansheng_cancel UButton
--Edit Below--
local chuansong = { bInitDoOnce = false }

-- 闅愯棌鎵€鏈夋帶浠?
function chuansong:HideAllButtons()
	if self.fuben1 then self.fuben1:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben1_Text then self.fuben1_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben2 then self.fuben2:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben2_Text then self.fuben2_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben3 then self.fuben3:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben3_Text then self.fuben3_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben4 then self.fuben4:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben4_Text then self.fuben4_Text:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben5 then self.fuben5:SetVisibility(ESlateVisibility.Collapsed) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Collapsed) end
	if self.Zhuansheng_cancel then self.Zhuansheng_cancel:SetVisibility(ESlateVisibility.Collapsed) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Collapsed) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Collapsed) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Collapsed) end
end

-- 鏄剧ず鎵€鏈夋帶浠?
function chuansong:ShowAllButtons()
	if self.fuben1 then self.fuben1:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben1_Text then self.fuben1_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben2 then self.fuben2:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben2_Text then self.fuben2_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben3 then self.fuben3:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben3_Text then self.fuben3_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben4 then self.fuben4:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben4_Text then self.fuben4_Text:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben5 then self.fuben5:SetVisibility(ESlateVisibility.Visible) end
	if self.fuben6 then self.fuben6:SetVisibility(ESlateVisibility.Visible) end
	if self.Zhuansheng_cancel then self.Zhuansheng_cancel:SetVisibility(ESlateVisibility.Visible) end
	if self.ImageEx_25 then self.ImageEx_25:SetVisibility(ESlateVisibility.Visible) end
	if self.HorizontalBox_135 then self.HorizontalBox_135:SetVisibility(ESlateVisibility.Visible) end
	if self.CanvasPanel_0 then self.CanvasPanel_0:SetVisibility(ESlateVisibility.Visible) end
end

function chuansong:Construct()
	self:LuaInit();
	-- 鍒濆鍖栨椂闅愯棌鎵€鏈夋寜閽?
	self:HideAllButtons()
end

-- function chuansong:Tick(MyGeometry, InDeltaTime)
-- end

-- function chuansong:Destruct()
-- end

-- [Editor Generated Lua] function define Begin:
function chuansong:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	if self.fuben1 then self.fuben1.OnClicked:Add(self.fuben1_OnClicked, self) end
	if self.fuben2 then self.fuben2.OnClicked:Add(self.fuben2_OnClicked, self) end
	if self.fuben3 then self.fuben3.OnClicked:Add(self.fuben3_OnClicked, self) end
	if self.fuben4 then self.fuben4.OnClicked:Add(self.fuben4_OnClicked, self) end
	if self.fuben5 then self.fuben5.OnClicked:Add(self.fuben5_OnClicked, self) end
	if self.fuben6 then self.fuben6.OnClicked:Add(self.fuben6_OnClicked, self) end
	-- 缁戝畾鍙栨秷鎸夐挳浜嬩欢
	if self.Zhuansheng_cancel then
		self.Zhuansheng_cancel.OnClicked:Add(self.Zhuansheng_cancel_OnClicked, self)
	end
	-- [Editor Generated Lua] BindingEvent End;
end

-- 閫氱敤浼犻€佸嚱鏁?- 閫氳繃 RPC 鍙戦€佸埌鏈嶅姟鍣ㄦ墽琛?
-- @param x 鐩爣浣嶇疆 X 鍧愭爣
-- @param y 鐩爣浣嶇疆 Y 鍧愭爣
-- @param z 鐩爣浣嶇疆 Z 鍧愭爣
-- @param yaw 鐩爣鏈濆悜瑙掑害锛堝彲閫夛紝涓嶄紶鍒欎笉鏀瑰彉鏈濆悜锛?
function chuansong:TeleportToLocation(x, y, z, yaw)
    --ugcprint("chuansong: TeleportToLocation 寮€濮?)
    --ugcprint("chuansong: 鐩爣浣嶇疆 X=" .. x .. " Y=" .. y .. " Z=" .. z .. " Yaw=" .. tostring(yaw or "鏃?))
    
    local ok, err = pcall(function()
        -- 鑾峰彇鏈湴鐜╁鎺у埗鍣?
        local PlayerController = UGCGameSystem.GetLocalPlayerController()
        if not PlayerController then
            --ugcprint("chuansong: 閿欒 - 鏃犳硶鑾峰彇 PlayerController")
            return
        end
        
        -- 閫氳繃 RPC 璋冪敤鏈嶅姟鍣ㄤ紶閫?
        --ugcprint("chuansong: 璋冪敤 Server_TeleportPlayer RPC")
        if yaw then
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z, yaw)
        else
            UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_TeleportPlayer", x, y, z)
        end
        --ugcprint("chuansong: 宸插彂閫佷紶閫佽姹傚埌鏈嶅姟鍣?)
    end)
    
    if not ok then
        --ugcprint("chuansong: 鍙戦€佷紶閫佽姹傚け璐? " .. tostring(err))
    end
    
    -- 浼犻€佸悗闅愯棌浼犻€佺晫闈?
    self:HideAllButtons()
    
    -- 鏄剧ず浼犻€佹寜閽?
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun_2 then
        pc.MMainUI.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
    end
end

-- 鑾峰彇鐜╁杞敓娆℃暟
function chuansong:GetPlayerRebirthCount()
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if ps then
            -- 浼樺厛浣跨敤澶嶅埗灞炴€?
            return ps.UGCPlayerRebirthCount or (ps.GameData and ps.GameData.PlayerRebirthCount) or 0
        end
    end
    return 0
end

-- 妫€鏌ユ槸鍚︽弧瓒充紶閫佹潯浠?
function chuansong:CheckRebirthRequirement(requiredRebirth, fubenName)
    local rebirthCount = self:GetPlayerRebirthCount()
    if rebirthCount < requiredRebirth then
        -- ugcprint("chuansong: " .. fubenName .. " 闇€瑕佽浆鐢?" .. requiredRebirth .. " 娆★紝褰撳墠杞敓娆℃暟: " .. rebirthCount)
        -- 寮瑰嚭鎻愮ず
        local pc = UGCGameSystem.GetLocalPlayerController()
        if pc and pc.MMainUI and pc.MMainUI.ShowTip then
            pc.MMainUI:ShowTip("杞敓娆℃暟涓嶈冻")
        end
        return false
    end
    return true
end

function chuansong:fuben1_OnClicked()
    --ugcprint("chuansong: fuben1 琚偣鍑?)
    -- fuben1 闇€瑕佽浆鐢?>= 1 娆?
    if not self:CheckRebirthRequirement(1, "fuben1") then
        return
    end
    self:TeleportToLocation(19036.871094, 50498.203125, 621.236023, 90)
end

function chuansong:fuben2_OnClicked()
    --ugcprint("chuansong: fuben2 琚偣鍑?)
    -- fuben2 闇€瑕佽浆鐢?>= 2 娆?
    if not self:CheckRebirthRequirement(2, "fuben2") then
        return
    end
    self:TeleportToLocation(141600.15625, -7472.247559, 287.76004, 90)
end

function chuansong:fuben3_OnClicked()
    --ugcprint("chuansong: fuben3 琚偣鍑?)
    -- fuben3 闇€瑕佽浆鐢?>= 3 娆?
    if not self:CheckRebirthRequirement(3, "fuben3") then
        return
    end
    self:TeleportToLocation(61460.460938, 10271.99707, 1646.93457, 90)
end

function chuansong:fuben4_OnClicked()
    --ugcprint("chuansong: fuben4 琚偣鍑?)
    -- fuben4 闇€瑕佽浆鐢?>= 4 娆?
    if not self:CheckRebirthRequirement(4, "fuben4") then
        return
    end
    self:TeleportToLocation(42936.683594, 135209.75, 15358.039062, 90)
end

function chuansong:fuben5_OnClicked()
    self:TeleportToLocation(18670.0, 24520.0, 200.0, 90)
end

function chuansong:fuben6_OnClicked()
    self:TeleportToLocation(18670.0, 24520.0, 200.0)
end

-- 鍙栨秷鎸夐挳鐐瑰嚮浜嬩欢澶勭悊
function chuansong:Zhuansheng_cancel_OnClicked()
	--ugcprint("chuansong_2: 鍙栨秷鎸夐挳琚偣鍑?)
	-- 闅愯棌鎵€鏈夋寜閽?
	self:HideAllButtons()

	-- 閫氳繃 PlayerController 鑾峰彇 MMainUI
	local pc = UGCGameSystem.GetLocalPlayerController()
	if pc and pc.MMainUI and pc.MMainUI.chuansongbuttun_2 then
		--ugcprint("chuansong_2: 鎵惧埌 MMainUI锛屾樉绀轰紶閫佹寜閽?)
		pc.MMainUI.chuansongbuttun_2:SetVisibility(ESlateVisibility.Visible)
	else
		--ugcprint("chuansong_2: 閿欒 - 鏃犳硶鎵惧埌 MMainUI")
	end
end

-- [Editor Generated Lua] function define End;

return chuansong
