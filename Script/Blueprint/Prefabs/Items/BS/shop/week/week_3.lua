---@class week_3_C:Template_ItemHandle_C
--Edit Below--
local week_3 = {}

local BACKPACK_ITEM_ID = 8310191
local GIFT_PACK_ID = 306

function week_3:CanUseV2()
    return true
end

function week_3:OnUseV2()
    -- ugcprint("[week_3] OnUseV2 瑙﹀彂")
    local BackpackComp = UGCItemSystemV2.GetOwnBackpackComponent(self)
    -- if not BackpackComp then ugcprint("[week_3] 閿欒锛氭棤娉曡幏鍙朆ackpackComponent") return end
    local PlayerController = BackpackComp:GetOwner()
    -- if not PlayerController then ugcprint("[week_3] 閿欒锛氭棤娉曡幏鍙朠layerController") return end

    local ownedCount = 0
    local GiftPackMgr = _G.GiftPackManager
    if GiftPackMgr and GiftPackMgr.GetGiftPackDataByID then
        local ok, gpData = pcall(function() return GiftPackMgr:GetGiftPackDataByID(GIFT_PACK_ID) end)
        if ok and gpData and gpData.ItemID then
            local VIM = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager")
            if VIM then
                ownedCount = VIM:GetItemNum(gpData.ItemID, PlayerController) or 0
            end
        end
    end
    if ownedCount <= 0 then
        ownedCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, BACKPACK_ITEM_ID) or 0
    end
    -- ugcprint("[week_3] 褰撳墠瀹濈鏁伴噺: " .. tostring(ownedCount))
    -- if not ownedCount or ownedCount <= 0 then ugcprint("[week_3] 娌℃湁鍙敤") return end

    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_ShowBaoxiangNumchoose", BACKPACK_ITEM_ID, ownedCount, GIFT_PACK_ID)
end

return week_3
