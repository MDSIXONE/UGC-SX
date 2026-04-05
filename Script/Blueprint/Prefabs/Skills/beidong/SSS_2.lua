---@class SSS_2_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local SSS_2 = {}
 
function SSS_2:OnEnableSkill_BP()
    SSS_2.SuperClass.OnEnableSkill_BP(self)
end

function SSS_2:OnDisableSkill_BP()
    SSS_2.SuperClass.OnDisableSkill_BP(self)
end

function SSS_2:OnActivateSkill_BP()
    SSS_2.SuperClass.OnActivateSkill_BP(self)
end

function SSS_2:OnDeActivateSkill_BP()
    SSS_2.SuperClass.OnDeActivateSkill_BP(self)
end

function SSS_2:CanActivateSkill_BP()
    return SSS_2.SuperClass.CanActivateSkill_BP(self)
end

return SSS_2