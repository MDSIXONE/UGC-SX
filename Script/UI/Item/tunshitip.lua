---@class tunshitip_C:UUserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field Image_0 UImage
---@field tunshitiptext UTextBlock
--Edit Below--
local tunshitip = { 
    bInitDoOnce = false,
    messageQueue = {},   -- 娑堟伅闃熷垪
    isProcessing = false -- 鏄惁姝ｅ湪澶勭悊闃熷垪
} 


function tunshitip:Construct()
	self:LuaInit();
	
end


-- function tunshitip:Tick(MyGeometry, InDeltaTime)

-- end

-- function tunshitip:Destruct()

-- end

-- Related UI logic.
function tunshitip:ShowTips(message)
	-- Log this action.
	
	-- Related UI logic.
	table.insert(self.messageQueue, message)
	-- Log this action.
	
	-- Related UI logic.
	if not self.isProcessing then
		self:ProcessQueue()
	end
end

-- Related UI logic.
function tunshitip:ProcessQueue()
	-- Related UI logic.
	if #self.messageQueue == 0 then
		self.isProcessing = false
		-- Related UI logic.
		self:SetVisibility(ESlateVisibility.Collapsed)
		-- Log this action.
		return
	end
	
	-- Related UI logic.
	self.isProcessing = true
	
	-- Related UI logic.
	local message = table.remove(self.messageQueue, 1)
	-- Log this action.
	
	-- Related UI logic.
	self:ShowSingleMessage(message)
	
	-- Related UI logic.
	local nextDelegate = ObjectExtend.CreateDelegate(self, function()
		self:ProcessQueue()
	end)
	KismetSystemLibrary.K2_SetTimerDelegateForLua(nextDelegate, self, 0.4, false)
end

-- Related UI logic.
function tunshitip:ShowSingleMessage(message)
	if not self.tunshitiptext then
		-- Log this action.
		return
	end
	
	-- Related UI logic.
	self:SetVisibility(ESlateVisibility.Visible)
	
	-- Related UI logic.
	self.tunshitiptext:SetVisibility(ESlateVisibility.Visible)
	
	-- Related UI logic.
	self.tunshitiptext:SetText(message)
	
	-- Related UI logic.
	if self.NewAnimation_1 then
		self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
		-- Log this action.
	end
	
	-- Related UI logic.
	local hideDelegate = ObjectExtend.CreateDelegate(self, function()
		-- Related UI logic.
		if #self.messageQueue == 0 and not self.isProcessing then
			self:SetVisibility(ESlateVisibility.Collapsed)
			-- Log this action.
		end
	end)
	
	KismetSystemLibrary.K2_SetTimerDelegateForLua(hideDelegate, self, 0.3, false)
end

-- [Editor Generated Lua] function define Begin:
function tunshitip:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	self.tunshitiptext:BindingProperty("Text", self.tunshitiptext_Text, self);
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	-- [Editor Generated Lua] BindingEvent End;
end

function tunshitip:tunshitiptext_Text(ReturnValue)
	return "";
end

-- [Editor Generated Lua] function define End;

return tunshitip
