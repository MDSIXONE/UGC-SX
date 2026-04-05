---@class bx_1_C:Template_ItemHandle_C
--Edit Below--
local bx_1 = {}

local BACKPACK_ITEM_ID = 8310167  -- 鑳屽寘鐗╁搧ID
local GIFT_PACK_ID = 321          -- 瀵瑰簲绀煎寘ID

--- 鐗╁搧鏄惁鍙互浣跨敤锛堟湇鍔＄鐢熸晥锛?
function bx_1:CanUseV2()
    return true
end

--- 鐗╁搧琚娇鐢ㄦ椂鍥炶皟锛堟湇鍔＄鐢熸晥锛?
function bx_1:OnUseV2()
    -- ugcprint("[bx_1] OnUseV2 瑙﹀彂")

    local BackpackComp = UGCItemSystemV2.GetOwnBackpackComponent(self)
    if not BackpackComp then
        -- ugcprint("[bx_1] 閿欒锛氭棤娉曡幏鍙朆ackpackComponent")
        return
    end
    local PlayerController = BackpackComp:GetOwner()
    if not PlayerController then
        -- ugcprint("[bx_1] 閿欒锛氭棤娉曡幏鍙朠layerController")
        return
    end

    local ownedCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, BACKPACK_ITEM_ID)
    -- ugcprint("[bx_1] 褰撳墠瀹濈鏁伴噺: " .. tostring(ownedCount))

    if not ownedCount or ownedCount <= 0 then
        -- ugcprint("[bx_1] 娌℃湁瀹濈鍙敤")
        return
    end

    -- ugcprint("[bx_1] 閫氱煡瀹㈡埛绔脊鍑烘暟閲忛€夋嫨鍣? 鏁伴噺: " .. tostring(ownedCount) .. " GiftPackID: " .. tostring(GIFT_PACK_ID))
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_ShowBaoxiangNumchoose", BACKPACK_ITEM_ID, ownedCount, GIFT_PACK_ID)
end

return bx_1
