---@class jiaochengbuttun_C:UUserWidget
---@field Button_0 UButton
--Edit Below--
local jiaochengbuttun = { bInitDoOnce = false } 

function jiaochengbuttun:Construct()
	self:LuaInit()
end

function jiaochengbuttun:LuaInit()
	if self.bInitDoOnce then
		return
	end
	self.bInitDoOnce = true

	if self.Button_0 then
		self.Button_0.OnClicked:Add(self.OnButtonClicked, self)
	end
end

function jiaochengbuttun:OnButtonClicked()
	local pc = UGCGameSystem.GetLocalPlayerController()
	if not (pc and pc.MMainUI and pc.MMainUI.xuzhang) then
		return
	end

	local panel = pc.MMainUI.xuzhang
	if panel.ShowPanel then
		panel:ShowPanel()
	elseif panel.Show then
		panel:Show()
	else
		if panel.WidgetSwitcher_0 and panel.WidgetSwitcher_0.SetActiveWidgetIndex then
			panel.WidgetSwitcher_0:SetActiveWidgetIndex(0)
		end
		panel:SetVisibility(ESlateVisibility.Visible)
	end
end

-- function jiaochengbuttun:Tick(MyGeometry, InDeltaTime)

-- end

-- function jiaochengbuttun:Destruct()

-- end

return jiaochengbuttun