---@class WB_Slot_C:UUserWidget
---@field Button_0 UButton
---@field Image_0 UImage
---@field Image_1 UImage
---@field TextBlock_0 UTextBlock
--Edit Below--
local WB_Slot = { bInitDoOnce = false } 

-- 寮曞叆UGCGameData
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function WB_Slot:Construct()
	--ugcprint("[WB_Slot] Construct 琚皟鐢?)
	
	-- 鍒濆鍖栧疄渚嬪彉閲?
	self.RecipeData = nil
	
	-- 闅愯棌Image_1锛堥粯璁ら殣钘忥紝鍙湁鍙悎鎴愭椂鎵嶆樉绀猴級
	if self.Image_1 then
		self.Image_1:SetVisibility(2)  -- 2 = Hidden
	end
	
	-- 妫€鏌ユ槸鍚︿负鏄剧ず妯″紡
	if self.IsDisplayMode then
		--ugcprint("[WB_Slot] 鏄剧ず妯″紡锛屽姞杞芥樉绀烘暟鎹?)
		self:LoadDisplayData()
		return
	end
	
	-- 濡傛灉澶栭儴璁剧疆浜哛ecipeID锛屼娇鐢ㄥ閮ㄧ殑
	if self.RecipeID then
		--ugcprint("[WB_Slot] 浣跨敤閰嶆柟ID: " .. tostring(self.RecipeID))
		
		self:LuaInit()
		
		-- 鏍规嵁妯″紡鍔犺浇涓嶅悓鐨勯厤鏂规暟鎹?
		if self.IsFenjieMode then
			self:LoadFenjieData(self.RecipeID)
		else
			self:LoadRecipeData(self.RecipeID)
		end
		
		-- 璁剧疆鐗╁搧鍥炬爣
		self:SetItemIcon()
		
		-- 鏇存柊鐗╁搧鏁伴噺鏄剧ず
		self:UpdateItemCount()
	else
		--ugcprint("[WB_Slot] 璀﹀憡锛氭湭璁剧疆RecipeID")
	end
end

-- 鍔犺浇閰嶆柟鏁版嵁
function WB_Slot:LoadRecipeData(recipeID)
	-- ugcprint("[WB_Slot] 寮€濮嬪姞杞介厤鏂规暟鎹紝閰嶆柟ID: " .. tostring(recipeID))
	
	-- 浠庨厤鏂硅〃璇诲彇閰嶆柟
	local recipeConfig = UGCGameData.GetRecipeConfig(recipeID)
	if recipeConfig then
		-- ugcprint("[WB_Slot] 閰嶆柟鍔犺浇鎴愬姛")
		
		-- 鎵撳嵃閰嶆柟琛ㄧ殑鎵€鏈夊瓧娈碉紙鍏抽敭璋冭瘯淇℃伅锛?
		-- ugcprint("[WB_Slot] ===== 閰嶆柟琛ㄥ瓧娈?=====")
		for key, value in pairs(recipeConfig) do
			-- ugcprint("[WB_Slot]   " .. tostring(key) .. " = " .. tostring(value))
		end
		-- ugcprint("[WB_Slot] ===== 瀛楁鎵撳嵃缁撴潫 =====")
		
		-- 浠庨厤鏂硅〃鑾峰彇铏氭嫙杈撳嚭鐗╁搧ID
		local virtualOutputItemID = recipeConfig["铏氭嫙鐗╁搧ID"]
		-- ugcprint("[WB_Slot] 铏氭嫙杈撳嚭鐗╁搧ID: " .. tostring(virtualOutputItemID))
		
		-- 璇诲彇杈撳嚭鏉愭枡鏁伴噺
		local outputCount = recipeConfig["鏁伴噺"] or recipeConfig["杈撳嚭鏉愭枡锛堟暟閲忥級"] or 1
		-- ugcprint("[WB_Slot] 杈撳嚭鏉愭枡鏁伴噺: " .. tostring(outputCount))
		
		-- 璇诲彇鍚堟垚閰嶆柟鏁扮粍
		local craftRecipeArray = recipeConfig["鍚堟垚閰嶆柟"]
		if not craftRecipeArray then
			-- ugcprint("[WB_Slot] 閿欒锛氭湭鎵惧埌'鍚堟垚閰嶆柟'瀛楁锛佽妫€鏌ヤ笂闈㈡墦鍗扮殑瀛楁鍚?)
			self.RecipeData = {
				InputItemID = nil,
				InputCount = 0,
				OutputItemID = nil,
				OutputCount = outputCount,
				RecipeID = recipeID,
				InputMaterials = {}
			}
			return
		end
		
		-- ugcprint("[WB_Slot] 鎵惧埌鍚堟垚閰嶆柟鏁扮粍锛屾潗鏂欐暟閲? " .. tostring(#craftRecipeArray))
		
		-- 瀛樺偍鎵€鏈夎緭鍏ユ潗鏂?
		local inputMaterials = {}
		
		-- 閬嶅巻鍚堟垚閰嶆柟鏁扮粍锛坢aterial鏄疷E userdata锛?
		for i = 1, #craftRecipeArray do
			local material = craftRecipeArray[i]
			if material then
				-- ugcprint("[WB_Slot] 鏉愭枡 " .. i .. " 绫诲瀷: " .. type(material))
				
				-- 鐢╬call + 鏂规嫭鍙疯闂畊serdata瀛楁
				local ok, virtualInputItemID = pcall(function() return material["鏉愭枡铏氭嫙鐗╁搧ID"] end)
				local ok2, inputCount = pcall(function() return material["鎵€闇€鏁伴噺"] end)
				
				if not ok then
					-- ugcprint("[WB_Slot] 鏉愭枡 " .. i .. " 璁块棶鏉愭枡铏氭嫙鐗╁搧ID澶辫触: " .. tostring(virtualInputItemID))
					virtualInputItemID = nil
				end
				if not ok2 then
					-- ugcprint("[WB_Slot] 鏉愭枡 " .. i .. " 璁块棶鎵€闇€鏁伴噺澶辫触: " .. tostring(inputCount))
					inputCount = nil
				end
				
				-- ugcprint("[WB_Slot] 鏉愭枡 " .. i .. " - 铏氭嫙ID: " .. tostring(virtualInputItemID) .. ", 鏁伴噺: " .. tostring(inputCount))
				
				-- 浣跨敤鏄犲皠琛ㄥ皢铏氭嫙鐗╁搧ID杞崲涓哄疄闄呯墿鍝両D
				if virtualInputItemID then
					local inputMapping = UGCGameData.GetItemMapping(virtualInputItemID)
					if inputMapping and inputMapping["ClassicItemID"] then
						local realInputItemID = inputMapping["ClassicItemID"]
						-- ugcprint("[WB_Slot] 鏉愭枡 " .. i .. " 鏄犲皠鍚庣殑鐪熷疄ID: " .. tostring(realInputItemID))
						
						table.insert(inputMaterials, {
							VirtualItemID = virtualInputItemID,
							RealItemID = realInputItemID,
							Count = inputCount
						})
					else
						-- ugcprint("[WB_Slot] 璀﹀憡锛氭潗鏂?" .. i .. " 鏈壘鍒版槧灏?)
					end
				else
					-- ugcprint("[WB_Slot] 璀﹀憡锛氭潗鏂?" .. i .. " virtualInputItemID涓簄il")
				end
			else
				-- ugcprint("[WB_Slot] 璀﹀憡锛氭潗鏂?" .. i .. " 涓簄il")
			end
		end
		
		-- ugcprint("[WB_Slot] 瑙ｆ瀽瀹屾垚锛屾湁鏁堟潗鏂欐暟閲? " .. tostring(#inputMaterials))
		
		-- 浣跨敤鏄犲皠琛ㄥ皢铏氭嫙杈撳嚭鐗╁搧ID杞崲涓哄疄闄呯墿鍝両D
		local realOutputItemID = nil
		if virtualOutputItemID then
			local outputMapping = UGCGameData.GetItemMapping(virtualOutputItemID)
			if outputMapping and outputMapping["ClassicItemID"] then
				realOutputItemID = outputMapping["ClassicItemID"]
				-- ugcprint("[WB_Slot] 鏄犲皠鍚庣殑杈撳嚭鐗╁搧ID: " .. tostring(realOutputItemID))
			end
		end
		
		-- 鏋勫缓閰嶆柟鏁版嵁
		local firstMaterial = inputMaterials[1]
		self.RecipeData = {
			InputItemID = firstMaterial and firstMaterial.RealItemID or nil,
			InputCount = firstMaterial and firstMaterial.Count or 0,
			OutputItemID = realOutputItemID,
			OutputCount = outputCount,
			RecipeID = recipeID,
			VirtualInputItemID = firstMaterial and firstMaterial.VirtualItemID or nil,
			VirtualOutputItemID = virtualOutputItemID,
			InputMaterials = inputMaterials
		}
	else
		-- ugcprint("[WB_Slot] 閿欒锛氭湭鎵惧埌閰嶆柟锛岄厤鏂笽D: " .. tostring(recipeID))
		self.RecipeData = {
			InputItemID = nil,
			InputCount = 0,
			OutputItemID = nil,
			OutputCount = 1,
			RecipeID = recipeID,
			InputMaterials = {}
		}
	end
	
	-- ugcprint("[WB_Slot] 閰嶆柟鏁版嵁鍔犺浇瀹屾垚, InputMaterials鏁伴噺: " .. tostring(self.RecipeData and #self.RecipeData.InputMaterials or "nil"))
end

-- 鍔犺浇鍒嗚В閰嶆柟鏁版嵁
function WB_Slot:LoadFenjieData(recipeID)
	-- ugcprint("[WB_Slot] 寮€濮嬪姞杞藉垎瑙ｆ暟鎹紝閰嶆柟ID: " .. tostring(recipeID))
	
	local fenjieConfig = UGCGameData.GetFenjieConfig(recipeID)
	if fenjieConfig then
		-- ugcprint("[WB_Slot] 鍒嗚В閰嶆柟鍔犺浇鎴愬姛")
		
		-- 鎵撳嵃鍒嗚В琛ㄧ殑鎵€鏈夊瓧娈?
		-- ugcprint("[WB_Slot] ===== 鍒嗚В琛ㄥ瓧娈?=====")
		for key, value in pairs(fenjieConfig) do
			-- ugcprint("[WB_Slot]   " .. tostring(key) .. " = " .. tostring(value))
		end
		-- ugcprint("[WB_Slot] ===== 瀛楁鎵撳嵃缁撴潫 =====")
		
		-- 浠庡垎瑙ｈ〃鑾峰彇铏氭嫙杈撳嚭鐗╁搧ID锛堝垎瑙ｇ殑杈撳叆鐗╁搧锛屽嵆瑕佽鍒嗚В鐨勭墿鍝侊級
		local virtualOutputItemID = fenjieConfig["铏氭嫙鐗╁搧ID"]
		-- ugcprint("[WB_Slot] 铏氭嫙鐗╁搧ID: " .. tostring(virtualOutputItemID))
		
		-- 璇诲彇鏁伴噺
		local outputCount = fenjieConfig["鏁伴噺"] or 1
		-- ugcprint("[WB_Slot] 鏁伴噺: " .. tostring(outputCount))
		
		-- 璇诲彇鍒嗚В閰嶆柟鏁扮粍锛堝垎瑙ｅ悗寰楀埌鐨勬潗鏂欙級
		local fenjieRecipeArray = fenjieConfig["鍚堟垚閰嶆柟"] or fenjieConfig["鍒嗚В閰嶆柟"]
		if not fenjieRecipeArray then
			-- ugcprint("[WB_Slot] 閿欒锛氭湭鎵惧埌鍒嗚В閰嶆柟瀛楁锛佽妫€鏌ヤ笂闈㈡墦鍗扮殑瀛楁鍚?)
			self.RecipeData = {
				InputItemID = nil,
				InputCount = 0,
				OutputItemID = nil,
				OutputCount = outputCount,
				RecipeID = recipeID,
				InputMaterials = {},
				IsFenjie = true
			}
			return
		end
		
		-- ugcprint("[WB_Slot] 鎵惧埌鍒嗚В閰嶆柟鏁扮粍锛屾潗鏂欐暟閲? " .. tostring(#fenjieRecipeArray))
		
		-- 瀛樺偍鎵€鏈夎緭鍑烘潗鏂欙紙鍒嗚В鍚庤幏寰楃殑涓滆タ锛?
		local outputMaterials = {}
		
		for i = 1, #fenjieRecipeArray do
			local material = fenjieRecipeArray[i]
			if material then
				local ok, virtualItemID = pcall(function() return material["鏉愭枡铏氭嫙鐗╁搧ID"] end)
				local ok2, count = pcall(function() return material["鎵€闇€鏁伴噺"] end)
				
				if not ok then virtualItemID = nil end
				if not ok2 then count = nil end
				
				-- ugcprint("[WB_Slot] 鍒嗚В浜у嚭 " .. i .. " - 铏氭嫙ID: " .. tostring(virtualItemID) .. ", 鏁伴噺: " .. tostring(count))
				
				if virtualItemID then
					local mapping = UGCGameData.GetItemMapping(virtualItemID)
					if mapping and mapping["ClassicItemID"] then
						local realItemID = mapping["ClassicItemID"]
						table.insert(outputMaterials, {
							VirtualItemID = virtualItemID,
							RealItemID = realItemID,
							Count = count
						})
					end
				end
			end
		end
		
		-- 鏄犲皠琚垎瑙ｇ墿鍝佺殑鐪熷疄ID
		local realOutputItemID = nil
		if virtualOutputItemID then
			local outputMapping = UGCGameData.GetItemMapping(virtualOutputItemID)
			if outputMapping and outputMapping["ClassicItemID"] then
				realOutputItemID = outputMapping["ClassicItemID"]
			end
		end
		
		-- 鍒嗚В妯″紡涓嬶細InputMaterials = 闇€瑕佹秷鑰楃殑鐗╁搧锛堣鍒嗚В鐨勶級锛孫utputMaterials = 鍒嗚В鍚庤幏寰楃殑
		self.RecipeData = {
			InputItemID = realOutputItemID,
			InputCount = outputCount,
			OutputItemID = nil,
			OutputCount = 0,
			RecipeID = recipeID,
			VirtualInputItemID = virtualOutputItemID,
			VirtualOutputItemID = virtualOutputItemID,
			InputMaterials = {{
				VirtualItemID = virtualOutputItemID,
				RealItemID = realOutputItemID,
				Count = outputCount
			}},
			OutputMaterials = outputMaterials,
			IsFenjie = true
		}
	else
		-- ugcprint("[WB_Slot] 閿欒锛氭湭鎵惧埌鍒嗚В閰嶆柟锛孖D: " .. tostring(recipeID))
		self.RecipeData = {
			InputItemID = nil,
			InputCount = 0,
			OutputItemID = nil,
			OutputCount = 1,
			RecipeID = recipeID,
			InputMaterials = {},
			IsFenjie = true
		}
	end
	
	-- ugcprint("[WB_Slot] 鍒嗚В鏁版嵁鍔犺浇瀹屾垚")
end

-- [Editor Generated Lua] function define Begin:
function WB_Slot:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true
	--ugcprint("[WB_Slot] LuaInit 寮€濮嬬粦瀹氫簨浠?)
	
	-- 缁戝畾鎸夐挳鐐瑰嚮浜嬩欢
	if self.Button_0 and not self.IsDisplayMode then
		self.Button_0.OnPressed:Add(self.OnButtonClicked, self)
		--ugcprint("[WB_Slot] Button_0 鐐瑰嚮浜嬩欢缁戝畾鎴愬姛")
	elseif self.IsDisplayMode then
		--ugcprint("[WB_Slot] 鏄剧ず妯″紡锛岃烦杩囨寜閽粦瀹?)
		if self.Button_0 then
			self.Button_0:SetIsEnabled(false)
		end
	else
		--ugcprint("[WB_Slot] 璀﹀憡锛氭湭鎵惧埌 Button_0")
	end
end
-- [Editor Generated Lua] function define End;

-- 璁剧疆鐗╁搧鍥炬爣
function WB_Slot:SetItemIcon()
	if not self.RecipeData then
		return
	end
	
	local virtualOutputItemID = self.RecipeData.VirtualOutputItemID
	if not virtualOutputItemID then
		return
	end
	
	-- 浠庣墿鍝佽〃鑾峰彇鐗╁搧閰嶇疆
	local itemConfig = UGCGameData.GetItemConfig(virtualOutputItemID)
	if not itemConfig then
		return
	end
	
	-- 鑾峰彇灏廼con璺緞
	local iconPath = itemConfig["ItemSmallIcon"]
	if not iconPath then
		return
	end
	
	if not self.Image_0 then
		return
	end
	
	-- 浣跨敤UGCObjectUtility.GetPathBySoftObjectPath浠嶴oftObjectPath鑾峰彇璺緞瀛楃涓?
	local pathString = UGCObjectUtility.GetPathBySoftObjectPath(iconPath)
	
	if pathString and pathString ~= "" then
		local IconTexture = UGCObjectUtility.LoadObject(pathString)
		if IconTexture then
			self.Image_0:SetBrushFromTexture(IconTexture)
		end
	end
end

-- 鏇存柊鐗╁搧鏁伴噺鏄剧ず
function WB_Slot:UpdateItemCount()
	if not self.TextBlock_0 then
		return
	end
	
	if not self.RecipeData then
		self.TextBlock_0:SetText("x0")
		if self.Image_1 then
			self.Image_1:SetVisibility(2)  -- 2 = Hidden
		end
		return
	end
	
	-- 鏄剧ず杈撳嚭鏁伴噺
	local countText = "x" .. tostring(self.RecipeData.OutputCount)
	self.TextBlock_0:SetText(countText)
	
	-- 璁剧疆涓虹櫧鑹?
	local whiteColor = UGCObjectUtility.NewStruct("SlateColor")
	whiteColor.SpecifiedColor = UGCObjectUtility.NewStruct("LinearColor", 1, 1, 1, 1)
	self.TextBlock_0:SetColorAndOpacity(whiteColor)
	
	-- 妫€鏌ユ墍鏈夋潗鏂欐槸鍚﹀厖瓒?
	local canCraft = true
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	
	if PlayerController and self.RecipeData.InputMaterials then
		for i, material in ipairs(self.RecipeData.InputMaterials) do
			local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, material.RealItemID)
			if currentCount < material.Count then
				canCraft = false
				break
			end
		end
	else
		canCraft = false
	end
	
	-- 鏍规嵁鏄惁鍙悎鎴愭樉绀烘垨闅愯棌Image_1
	if self.Image_1 then
		if canCraft then
			self.Image_1:SetVisibility(0)  -- 0 = Visible
		else
			self.Image_1:SetVisibility(2)  -- 2 = Hidden
		end
	end
end

-- 鎸夐挳鐐瑰嚮浜嬩欢
function WB_Slot:OnButtonClicked()
	--ugcprint("[WB_Slot] 鎸夐挳琚偣鍑?)
	
	if not self.RecipeData then
		--ugcprint("[WB_Slot] 閿欒锛氶厤鏂规暟鎹负绌?)
		return
	end
	
	local PlayerController = UGCGameSystem.GetLocalPlayerController()
	if not PlayerController then
		--ugcprint("[WB_Slot] 閿欒锛氳幏鍙栫帺瀹舵帶鍒跺櫒澶辫触")
		return
	end
	
	-- 鏌ユ壘鐖剁骇 WB_Inventory 骞惰皟鐢?ShowCraftDetails
	if PlayerController.MMainUI and PlayerController.MMainUI.WB_Inventory then
		--ugcprint("[WB_Slot] 璋冪敤 WB_Inventory 鏄剧ず璇︽儏锛岄厤鏂笽D: " .. tostring(self.RecipeData.RecipeID))
		PlayerController.MMainUI.WB_Inventory:ShowCraftDetails(self.RecipeData)
	else
		--ugcprint("[WB_Slot] 閿欒锛氭壘涓嶅埌 WB_Inventory UI")
	end
end

function WB_Slot:Tick(MyGeometry, InDeltaTime)
	-- 姣忓抚鏇存柊鐗╁搧鏁伴噺鏄剧ず鍜孖mage_1鐘舵€?
	if self.RecipeData then
		self:UpdateItemCount()
	end
end

-- 鍔犺浇鏄剧ず鏁版嵁锛堢敤浜庤鎯呮樉绀猴級
function WB_Slot:LoadDisplayData()
	-- 杩欎釜鍑芥暟鐣欑┖锛岀敱WB_Slot_2澶勭悊
end

return WB_Slot
