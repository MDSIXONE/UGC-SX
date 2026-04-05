---@class Itemslot_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_name UTextBlock
---@field TextBlock_num UTextBlock
--Edit Below--
local Itemslot = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function Itemslot:Construct()
end

--- 璁剧疆鐗╁搧鏁版嵁骞跺埛鏂版樉绀?
---@param itemID number 鐗╁搧ID锛圲GCObject琛ㄤ腑鐨処D锛?
---@param itemNum number 鐗╁搧鏁伴噺
function Itemslot:SetItemData(itemID, itemNum)
    if not itemID then return end

    -- 鏄剧ず鐗╁搧鏁伴噺
    if self.TextBlock_num then
        self.TextBlock_num:SetText("x" .. tostring(itemNum or 1))
    end

    -- 浠庣墿鍝佽〃鑾峰彇鐗╁搧閰嶇疆
    local itemConfig = UGCGameData.GetItemConfig(itemID)
    if not itemConfig then
        -- ugcprint("[Itemslot] 鏈壘鍒扮墿鍝侀厤缃? itemID=" .. tostring(itemID))
        return
    end

    -- 鏄剧ず鐗╁搧鍚嶇О
    if self.TextBlock_name then
        local name = itemConfig.ItemName or ""
        self.TextBlock_name:SetText(tostring(name))
    end

    -- 鍔犺浇鐗╁搧鍥剧墖锛堝弬鑰僕B_Slot鐨勬柟寮忥級
    if self.Image_0 then
        local iconPath = itemConfig["ItemSmallIcon"]
        if iconPath then
            local pathString = UGCObjectUtility.GetPathBySoftObjectPath(iconPath)
            if pathString and pathString ~= "" then
                local IconTexture = UGCObjectUtility.LoadObject(pathString)
                if IconTexture then
                    self.Image_0:SetBrushFromTexture(IconTexture)
                end
            end
        end
    end
end

function Itemslot:Destruct()
end

return Itemslot
