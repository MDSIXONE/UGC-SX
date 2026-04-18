---@class UGCGameState_C:BP_UGCGameState_C
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')
local UGCGameState = {}; 
function UGCGameState:ReceiveBeginPlay()
	self.SuperClass.ReceiveBeginPlay(self);
end
-- function UGCGameState:ReceiveTick(DeltaTime)

-- end
-- function UGCGameState:ReceiveEndPlay()
 
-- end
return UGCGameState;
