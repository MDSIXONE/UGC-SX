---@class qilingjian_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local jinse = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}
 
function jinse:OnApply_BP()
    jinse.SuperClass.OnApply_BP(self)
    print("jinse:OnApply_BP")
    if not self:HasAuthority() then
        local Character = self:GetNetOwnerActor()
        self.ParticleSystemComponent = GameplayStatics.SpawnEmitterAttachedToActor(self.Particle, Character.Mesh, "root", Vector.New(-45, -45, 90), Rotator.New(-90, 0, 0), Vector.New(3, 3, 3), EAttachLocation.SnapToTarget, true)
    end
end

function jinse:OnDisableSkill_BP()
    jinse.SuperClass.OnDisableSkill_BP(self)

end
 
function jinse:OnUnApply_BP()
    jinse.SuperClass.OnUnApply_BP(self)
    print("jinse:OnUnApply_BP")
    if not self:HasAuthority() then
        if (self.ParticleSystemComponent) then
            self.ParticleSystemComponent:K2_DestroyComponent()
        end
    end
end

function jinse:OnActivateSkill_BP()
    jinse.SuperClass.OnActivateSkill_BP(self)
end

function jinse:OnDeActivateSkill_BP()
    jinse.SuperClass.OnDeActivateSkill_BP(self)
end

function jinse:CanActivateSkill_BP()
    return jinse.SuperClass.CanActivateSkill_BP(self)
end

return jinse