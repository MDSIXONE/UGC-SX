---@class month_7_C:Template_ItemHandle_C
--Edit Below--
local month_7 = {}

local BACKPACK_ITEM_ID = 8310188
local GIFT_PACK_ID = 316

function month_7:CanUseV2()
    return true
end

function month_7:OnUseV2()
    -- ugcprint("[month_7] OnUseV2 瑙﹀彂")
    local BackpackComp = UGCItemSystemV2.GetOwnBackpackComponent(self)
    -- if not BackpackComp then ugcprint("[month_7] 閿欒锛氭棤娉曡幏鍙朆ackpackComponent") return end
    local PlayerController = BackpackComp:GetOwner()
    -- if not PlayerController then ugcprint("[month_7] 閿欒锛氭棤娉曡幏鍙朠layerController") return end

    -- 浼樺厛鏌ヨ櫄鎷熺墿鍝佹暟閲忥紙SHOP璐拱鐨勭墿鍝佸瓨鍌ㄥ湪铏氭嫙鐗╁搧绯荤粺涓級
    local ownedCount = 0
    local GiftPackMgr = _G.GiftPackManager
    if GiftPackMgr and GiftPackMgr.GetGiftPackDataByID then
        local ok, gpData = pcall(function() return GiftPackMgr:GetGiftPackDataByID(GIFT_PACK_ID) end)
        if ok and gpData and gpData.ItemID then
            local VIM = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
            if VIM then
                ownedCount = VIM:GetItemNum(gpData.ItemID, PlayerController) or 0
                -- ugcprint("[month_7] 铏氭嫙鐗╁搧鏁伴噺(ID=" .. tostring(gpData.ItemID) .. "): " .. tostring(ownedCount))
            end
        end
    end
    -- fallback鏌ュ疄闄呰儗鍖?
    if ownedCount <= 0 then
        ownedCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, BACKPACK_ITEM_ID) or 0
    end
    -- ugcprint("[month_7] 褰撳墠瀹濈鏁伴噺: " .. tostring(ownedCount))
    -- if not ownedCount or ownedCount <= 0 then ugcprint("[month_7] 娌℃湁鍙敤") return end

    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_ShowBaoxiangNumchoose", BACKPACK_ITEM_ID, ownedCount, GIFT_PACK_ID)
end

return month_7
