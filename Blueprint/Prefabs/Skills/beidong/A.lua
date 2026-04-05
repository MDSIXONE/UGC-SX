---@class A_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local A = {}
 
function A:OnEnableSkill_BP()
    A.SuperClass.OnEnableSkill_BP(self)
end

function A:OnDisableSkill_BP()
    A.SuperClass.OnDisableSkill_BP(self)
end

function A:OnActivateSkill_BP()
    A.SuperClass.OnActivateSkill_BP(self)
end

function A:OnDeActivateSkill_BP()
    A.SuperClass.OnDeActivateSkill_BP(self)
end

function A:CanActivateSkill_BP()
    return A.SuperClass.CanActivateSkill_BP(self)
end

return A