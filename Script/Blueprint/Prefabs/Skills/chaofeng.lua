---@class chaofeng_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local chaofeng = {}
 
function chaofeng:OnEnableSkill_BP()
    chaofeng.SuperClass.OnEnableSkill_BP(self)
end

function chaofeng:OnDisableSkill_BP()
    chaofeng.SuperClass.OnDisableSkill_BP(self)
end

function chaofeng:OnActivateSkill_BP()
    chaofeng.SuperClass.OnActivateSkill_BP(self)
end

function chaofeng:OnDeActivateSkill_BP()
    chaofeng.SuperClass.OnDeActivateSkill_BP(self)
end

function chaofeng:CanActivateSkill_BP()
    return chaofeng.SuperClass.CanActivateSkill_BP(self)
end

return chaofeng