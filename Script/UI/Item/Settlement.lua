---@class Settlement_C:UUserWidget
---@field Image_0 UImage
---@field sure UButton
---@field UniformGridPanel_1 UUniformGridPanel
---@field WB_Slot_2 WB_Slot_2_C
--Edit Below--
local Settlement = { bInitDoOnce = false }

-- 寮曞叆UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function Settlement:Construct()
	-- ugcprint("[Settlement] Construct 琚皟鐢?)
	self:LuaInit()
	
	-- 鍒涘缓濂栧姳鐗╁搧妲戒綅
	self:CreateRewardSlots()
end

function Settlement:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	
	-- ugcprint("[Settlement] LuaInit 瀹屾垚")
	
	-- 缁戝畾 sure 鎸夐挳鐐瑰嚮浜嬩欢
	if self.sure then
		self.sure.OnClicked:Add(self.OnSureButtonClicked, self)
		-- ugcprint("[Settlement] sure 鎸夐挳鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	else
		-- ugcprint("[Settlement] 閿欒锛歴ure 鎸夐挳涓嶅瓨鍦?)
	end
end

-- 鍒涘缓濂栧姳鐗╁搧妲戒綅
function Settlement:CreateRewardSlots()
	-- ugcprint("[Settlement] 寮€濮嬪垱寤哄鍔辩墿鍝佹Ы浣?)
	local matchRewardVirtualID = 5666
	
	if not self.UniformGridPanel_1 then
		-- ugcprint("[Settlement] 閿欒锛歎niformGridPanel_1 涓嶅瓨鍦?)
		return
	end
	
	-- 娓呯┖闈㈡澘
	self.UniformGridPanel_1:ClearChildren()
	
	-- 璋冭瘯锛氭墦鍗版暟鎹〃璺緞
	-- ugcprint("[Settlement] 濂栧姳琛ㄨ矾寰? " .. tostring(UGCGameData.FubenrewordTablePath))
	
	-- 璇诲彇濂栧姳鏁版嵁琛?
	local allRewards = UGCGameData.GetAllFubenreword()
	if not allRewards then
		-- ugcprint("[Settlement] 閿欒锛氭棤娉曡鍙栧壇鏈鍔辫〃")
		-- ugcprint("[Settlement] allRewards = " .. tostring(allRewards))
		return
	end
	
	-- ugcprint("[Settlement] 鎴愬姛璇诲彇鍓湰濂栧姳琛?)
	-- ugcprint("[Settlement] 濂栧姳鏁版嵁绫诲瀷: " .. type(allRewards))
	
	-- 鍔犺浇 WB_Slot_2 绫?
	local SlotClass = UGCObjectUtility.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/UI/Item/WB_Slot_2.WB_Slot_2_C'))
	if not SlotClass then
		-- ugcprint("[Settlement] 閿欒锛氭棤娉曞姞杞?WB_Slot_2 绫?)
		return
	end
	
	-- 鑾峰彇鐜╁鎺у埗鍣?
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		-- ugcprint("[Settlement] 閿欒锛氭棤娉曡幏鍙栫帺瀹舵帶鍒跺櫒")
		return
	end

	-- 鍖归厤缁撶畻鍥哄畾灞曠ず閿婚€犵煶锛堣櫄鎷熺墿鍝両D=5666锛夛紝鏁伴噺娌跨敤濂栧姳琛ㄦ€诲拰
	local totalRewardCount = 0
	for _, rewardData in pairs(allRewards) do
		local itemCount = math.floor(tonumber(rewardData["鏁伴噺"]) or 0)
		if itemCount > 0 then
			totalRewardCount = totalRewardCount + itemCount
		end
	end

	if totalRewardCount <= 0 then
		-- ugcprint("[Settlement] 璀﹀憡锛氬鍔辫〃鏁伴噺涓?锛屼笉灞曠ず濂栧姳妲戒綅")
		return
	end

	local slotWidget = UserWidget.NewWidgetObjectBP(PlayerController, SlotClass)
	if not slotWidget then
		-- ugcprint("[Settlement] 閿欒锛氭棤娉曞垱寤烘Ы浣嶅疄渚?)
		return
	end

	slotWidget.DisplayItemID = matchRewardVirtualID
	slotWidget.DisplayCount = totalRewardCount
	slotWidget.IsInputItem = false

	if slotWidget.LoadDisplayData then
		slotWidget:LoadDisplayData()
	end

	local gridSlot = self.UniformGridPanel_1:AddChildToUniformGrid(slotWidget)
	if gridSlot then
		gridSlot:SetRow(0)
		gridSlot:SetColumn(0)
		gridSlot:SetHorizontalAlignment(2)
		gridSlot:SetVerticalAlignment(2)
		-- ugcprint("[Settlement] 濂栧姳妲戒綅宸叉坊鍔? 铏氭嫙ID=" .. tostring(matchRewardVirtualID) .. ", 鏁伴噺=" .. tostring(totalRewardCount))
	else
		-- ugcprint("[Settlement] 閿欒锛欰ddChildToUniformGrid 杩斿洖 nil")
	end

	-- ugcprint("[Settlement] 濂栧姳鐗╁搧妲戒綅鍒涘缓瀹屾垚")
end

-- sure 鎸夐挳鐐瑰嚮浜嬩欢
function Settlement:OnSureButtonClicked()
	-- ugcprint("[Settlement] sure 鎸夐挳琚偣鍑伙紝鍑嗗鍙戞斁濂栧姳骞惰繘鍏ョ粨绠?)
	
	-- 閫氳繃鏈嶅姟鍣≧PC鍙戞斁濂栧姳
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if PlayerController then
		-- ugcprint("[Settlement] 璋冪敤鏈嶅姟鍣≧PC鍙戞斁濂栧姳")
		UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_GiveRewards")
	end
	
	-- 鍏抽棴 Settlement UI
	self:RemoveFromParent()
	-- ugcprint("[Settlement] Settlement UI 宸插叧闂?)
	
	-- 閫氱煡 LevelReward 杩涘叆缁撶畻
	if self.OnSureClicked then
		self.OnSureClicked()
	end
end

return Settlement
