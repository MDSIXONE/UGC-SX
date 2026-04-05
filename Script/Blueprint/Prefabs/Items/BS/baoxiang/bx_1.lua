---@class bx_1_C:Template_ItemHandle_C
--Edit Below--
local bx_1 = {}

local BACKPACK_ITEM_ID = 8310167  -- Backpack item ID.
local GIFT_PACK_ID = 321          -- Matching gift pack ID.

--- Check whether the item can be used on the server.
function bx_1:CanUseV2()
    return true
end

--- Handle the item use callback on the server.
function bx_1:OnUseV2()
    -- Log the use callback.

    local BackpackComp = UGCItemSystemV2.GetOwnBackpackComponent(self)
    if not BackpackComp then
        -- Failed to get the backpack component.
        return
    end
    local PlayerController = BackpackComp:GetOwner()
    if not PlayerController then
        -- Failed to get the player controller.
        return
    end

    local ownedCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, BACKPACK_ITEM_ID)
    -- Log the current box count.

    if not ownedCount or ownedCount <= 0 then
        -- No box is available.
        return
    end

    -- Notify the client to open the quantity selector.
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_ShowBaoxiangNumchoose", BACKPACK_ITEM_ID, ownedCount, GIFT_PACK_ID)
end

return bx_1
