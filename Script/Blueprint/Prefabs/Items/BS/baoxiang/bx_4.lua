---@class bx_4_C:Template_ItemHandle_C
--Edit Below--
local bx_1 = {}

local BACKPACK_ITEM_ID = 8310175
local GIFT_PACK_ID = 324

function bx_1:CanUseV2()
    return true
end

function bx_1:OnUseV2()
    -- ugcprint("[bx_4] OnUseV2 瑙﹀彂")
    local BackpackComp = UGCItemSystemV2.GetOwnBackpackComponent(self)
    -- if not BackpackComp then ugcprint("[bx_4] 閿欒锛氭棤娉曡幏鍙朆ackpackComponent") return end
    local PlayerController = BackpackComp:GetOwner()
    -- if not PlayerController then ugcprint("[bx_4] 閿欒锛氭棤娉曡幏鍙朠layerController") return end

    local ownedCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, BACKPACK_ITEM_ID)
    -- if not ownedCount or ownedCount <= 0 then ugcprint("[bx_4] 娌℃湁瀹濈鍙敤") return end

    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_ShowBaoxiangNumchoose", BACKPACK_ITEM_ID, ownedCount, GIFT_PACK_ID)
end

return bx_1
