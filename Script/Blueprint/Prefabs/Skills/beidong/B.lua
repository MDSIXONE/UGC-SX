---@class B_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local B = {}
 
function B:OnEnableSkill_BP()
    B.SuperClass.OnEnableSkill_BP(self)
end

function B:OnDisableSkill_BP()
    B.SuperClass.OnDisableSkill_BP(self)
end

function B:OnActivateSkill_BP()
    B.SuperClass.OnActivateSkill_BP(self)
end

function B:OnDeActivateSkill_BP()
    B.SuperClass.OnDeActivateSkill_BP(self)
end

function B:CanActivateSkill_BP()
    return B.SuperClass.CanActivateSkill_BP(self)
end

return B