---@class UGCGameState_C:BP_UGCGameState_C
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')
local UGCGameState = {}; 
function UGCGameState:ReceiveBeginPlay()
	self.SuperClass.ReceiveBeginPlay(self);

	if self:HasAuthority() == true then
		ugcprint("[UGCGameState] Server begin play, skip task button creation")
		return
	end

	local TaskBtnPath = UGCGameSystem.GetUGCResourcesFullPath("ExtendResource/TaskTemplate/OfficialPackage/Asset/Task/Blueprint/WBP_TaskMainUIButton.WBP_TaskMainUIButton_C")
	if TaskBtnPath == nil or TaskBtnPath == "" then
		ugcprint("[UGCGameState] Error: task button class path is empty")
		return
	end

	local TaskBtnClass = UGCObjectUtility.LoadClass(TaskBtnPath)
	if TaskBtnClass == nil then
		ugcprint(string.format("[UGCGameState] Error: failed to load task button class, path=%s", tostring(TaskBtnPath)))
		return
	end

	local TaskBtn = UGCWidgetManagerSystem.CreateWidget(TaskBtnClass)
	if TaskBtn == nil then
		ugcprint("[UGCGameState] Error: failed to create task button widget")
		return
	end

	TaskBtn:AddToViewport()
	ugcprint("[UGCGameState] Task main UI button added to viewport")
end
-- function UGCGameState:ReceiveTick(DeltaTime)

-- end
-- function UGCGameState:ReceiveEndPlay()
 
-- end
return UGCGameState;
