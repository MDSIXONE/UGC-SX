---@class S2__C:PESkillTemplate_Base_C
---@field CacheSelectTarget AActor
---@field CacheInitPosition FVector
---@field AttachOffset FVector
--Edit Below--

local S2_ = {
    
}

function S2_:InitSelectTarget()
    self.CacheInitPosition = self:GetOwnerActor():K2_GetActorLocation()
    local TargetList = self:GetSelectTargetActor(EPESkillSelectTarget.E_PESKILL_PickerType_AllTarget)
    if TargetList[1] ~= nil then
        self.CacheSelectTarget = TargetList[1]
    else
        self.CacheSelectTarget = nil
        self:DeActivateSkill(EPESkillDeActivateReason.E_PESKILL_DeActivateReason_Normal)
    end
end


function S2_:AttachToTarget()
    local SelectTargetLocation = self.CacheSelectTarget:K2_GetActorLocation()
    local Rotation = UGCMathUtility.MakeRotator(0,0,0)
    local Scale = UGCMathUtility.MakeVector(1,1,1)
    local SelectTransform = UGCMathUtility.MakeTransform(SelectTargetLocation, Rotation, Scale)
    self:SetSelectTransform(SelectTransform)

    local ActorForward = UGCMathUtility.SubtractVector(self.CacheInitPosition, SelectTargetLocation)
    ActorForward = UGCMathUtility.Normal(ActorForward)
    local ActorRight = UGCMathUtility.CrossVector(ActorForward, UGCMathUtility.GetUpVector())

    local OffsetX = UGCMathUtility.MultiplyVector(ActorForward, self.AttachOffset.X)
    local OffsetY = UGCMathUtility.MultiplyVector(ActorRight, self.AttachOffset.Y)

    local PlayerLocation = UGCMathUtility.AddVector(SelectTargetLocation, OffsetX)
    PlayerLocation = UGCMathUtility.AddVector(PlayerLocation, OffsetY)
    self:GetOwnerActor():K2_SetActorLocation(PlayerLocation) 
end

function S2_:ReturnToInitLocation()
    self:GetOwnerActor():K2_SetActorLocation(self.CacheInitPosition)
end

function S2_:SetCacheTargetLocation()
    local SelectTargetLocation = self.CacheSelectTarget:K2_GetActorLocation()
    local Rotation = UGCMathUtility.MakeRotator(0,0,0)
    local Scale = UGCMathUtility.MakeVector(1,1,1)
    local SelectTransform = UGCMathUtility.MakeTransform(SelectTargetLocation, Rotation, Scale)
    self:SetSelectTransform(SelectTransform)
end

return S2_