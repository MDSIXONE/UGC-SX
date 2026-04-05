---@class SSS1_C:PESkillTemplate_Base_C
--Edit Below--
local SSS1 = {}
 
function SSS1:OnEnableSkill_BP()
    SSS1.SuperClass.OnEnableSkill_BP(self)
end

function SSS1:OnDisableSkill_BP()
    SSS1.SuperClass.OnDisableSkill_BP(self)
end

function SSS1:OnActivateSkill_BP()
    SSS1.SuperClass.OnActivateSkill_BP(self)
end

function SSS1:OnDeActivateSkill_BP()
    SSS1.SuperClass.OnDeActivateSkill_BP(self)
end

function SSS1:CanActivateSkill_BP()
    return SSS1.SuperClass.CanActivateSkill_BP(self)
end

return SSS1