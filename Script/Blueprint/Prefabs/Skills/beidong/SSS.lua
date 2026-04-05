---@class SSS_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local SSS = {}
 
function SSS:OnEnableSkill_BP()
    SSS.SuperClass.OnEnableSkill_BP(self)
end

function SSS:OnDisableSkill_BP()
    SSS.SuperClass.OnDisableSkill_BP(self)
end

function SSS:OnActivateSkill_BP()
    SSS.SuperClass.OnActivateSkill_BP(self)
end

function SSS:OnDeActivateSkill_BP()
    SSS.SuperClass.OnDeActivateSkill_BP(self)
end

function SSS:CanActivateSkill_BP()
    return SSS.SuperClass.CanActivateSkill_BP(self)
end

return SSS