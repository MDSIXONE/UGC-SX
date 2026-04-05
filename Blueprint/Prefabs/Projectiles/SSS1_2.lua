---@class SSS1_2_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local SSS1_2 = {}
 
--[[
function SSS1_2:ReceiveBeginPlay()
    SSS1_2.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SSS1_2:ReceiveTick(DeltaTime)
    SSS1_2.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SSS1_2:ReceiveEndPlay()
    SSS1_2.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SSS1_2:GetReplicatedProperties()
    return
end
--]]

--[[
function SSS1_2:GetAvailableServerRPCs()
    return
end
--]]

return SSS1_2