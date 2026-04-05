---@class bx_3_C:Template_ItemHandle_C
--Edit Below--
local bx_1 = {}

local BACKPACK_ITEM_ID = 8310174
local GIFT_PACK_ID = 323

function bx_1:CanUseV2()
    return true
end

function bx_1:OnUseV2()
    -- Log the use callback.
    local BackpackComp = UGCItemSystemV2.GetOwnBackpackComponent(self)
    -- Return early if the backpack component is missing.
    local PlayerController = BackpackComp:GetOwner()
    -- Return early if the player controller is missing.

    local ownedCount = UGCBackpackSystemV2.GetItemCountV2(PlayerController, BACKPACK_ITEM_ID)
    -- Return early if no box is available.

    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Client_ShowBaoxiangNumchoose", BACKPACK_ITEM_ID, ownedCount, GIFT_PACK_ID)
end

return bx_1
