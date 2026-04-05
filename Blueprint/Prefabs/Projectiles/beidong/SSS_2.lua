---@class SSS_2_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local SSS_2 = {}
 
--[[
function SSS_2:ReceiveBeginPlay()
    SSS_2.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS_2:ReceiveTick(DeltaTime)
    SSS_2.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS_2:ReceiveEndPlay()
    SSS_2.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS_2:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS_2:GetAvailableServerRPCs()
    return
end
--]]

return SSS_2