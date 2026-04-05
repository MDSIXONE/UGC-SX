---@class S_2_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local S_2 = {}
 
--[[
function S_2:ReceiveBeginPlay()
    S_2.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function S_2:ReceiveTick(DeltaTime)
    S_2.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function S_2:ReceiveEndPlay()
    S_2.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function S_2:GetReplicatedProperties()
    return
end
--]]

--[[
function S_2:GetAvailableServerRPCs()
    return
end
--]]

return S_2