---@class Itemslot_C:UUserWidget
---@field Image_0 UImage
---@field TextBlock_name UTextBlock
---@field TextBlock_num UTextBlock
--Edit Below--
local Itemslot = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function Itemslot:Construct()
end

- -- 
---@param itemID number Virtual item ID.
---@param itemNum number Item count.
function Itemslot:SetItemData(itemID, itemNum)
    if not itemID then return end

    -- Guard condition before running this branch.
    if self.TextBlock_num then
        self.TextBlock_num:SetText("x" .. tostring(itemNum or 1))
    end

    -- Local helper value for this logic block.
    local itemConfig = UGCGameData.GetItemConfig(itemID)
    if not itemConfig then
        -- Exit early when requirements are not met.
        return
    end

    -- Guard condition before running this branch.
    if self.TextBlock_name then
        local name = itemConfig.ItemName or ""
        self.TextBlock_name:SetText(tostring(name))
    end

    -- Guard condition before running this branch.
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
