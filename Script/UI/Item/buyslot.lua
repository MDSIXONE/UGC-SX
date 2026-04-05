---@class buyslot_C:UUserWidget
---@field Button_0 UButton
---@field Itemslot Itemslot_C
---@field TextBlock_0 UTextBlock
---@field TextBlock_count UTextBlock
---@field TextBlock_current UTextBlock
--Edit Below--
UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage.Script.ShopV2.ShopV2Manager")

local buyslot = { bInitDoOnce = false }

local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function buyslot:Construct()
    self:LuaInit()
end

function buyslot:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true
    if self.Button_0 then
        self.Button_0.OnClicked:Add(self.OnButtonClicked, self)
    end
end

--- Set data and refresh display
--- @param rowIndex number Charge table row index
--- @param config table Charge table config (contains itemid, itemnum, itemcount)
--- @param currentSpend number Current cumulative spend amount
--- @param claimed boolean Whether already claimed
function buyslot:SetData(rowIndex, config, currentSpend, claimed)
    self.RowIndex = rowIndex
    self.Config = config
    self.CurrentSpend = currentSpend or 0
    self.Claimed = claimed or false

    local needCount = config.itemcount or 0
    self.NeedCount = needCount
    self.CanClaim = (self.CurrentSpend >= needCount) and (not self.Claimed)

    -- Display required spend amount
    if self.TextBlock_count then
        self.TextBlock_count:SetText("Total spend: " .. tostring(needCount))
    end

    -- Display current spend / required spend
    if self.TextBlock_current then
        self.TextBlock_current:SetText(tostring(math.floor(self.CurrentSpend)) .. "/" .. tostring(math.floor(needCount)))
    end

    -- Display button text
    if self.TextBlock_0 then
        if self.Claimed then
            self.TextBlock_0:SetText("Claimed")
        elseif self.CanClaim then
            self.TextBlock_0:SetText("Claim")
        else
            self.TextBlock_0:SetText("Go Spend")
        end
    end

    -- Disable button when already claimed
    if self.Button_0 then
        self.Button_0:SetIsEnabled(not self.Claimed)
    end

    -- Set Itemslot to display item info
    if self.Itemslot and self.Itemslot.SetItemData then
        self.Itemslot:SetItemData(config.itemid, config.itemnum)
    end
end

function buyslot:OnButtonClicked()
    if self.Claimed then return end

    if self.CanClaim then
        -- Claim reward: send RPC to server
        local playerState = UGCGameSystem.GetLocalPlayerState()
        if playerState then
            UnrealNetwork.CallUnrealRPC(playerState, playerState, "Server_ClaimChongzhiReward", self.RowIndex)
            -- ugcprint("[buyslot] Claiming charge reward, row " .. tostring(self.RowIndex))
        end
        -- Update display to claimed
        self.Claimed = true
        self.CanClaim = false
        if self.TextBlock_0 then
            self.TextBlock_0:SetText("Claimed")
        end
        if self.Button_0 then
            self.Button_0:SetIsEnabled(false)
        end
    else
        -- Go spend: close activity panel, open shop
        local pc = UGCGameSystem.GetLocalPlayerController()
        if pc and pc.MMainUI and pc.MMainUI.active then
            pc.MMainUI.active:OnCancelClicked()
        end
        if ShopV2Manager then
            ShopV2Manager:OpenMainUI(0)
            -- ugcprint("[buyslot] Shop opened")
        else
            -- ugcprint("[buyslot] Error: ShopV2Manager does not exist")
        end
    end
end

function buyslot:Destruct()
end

return buyslot
