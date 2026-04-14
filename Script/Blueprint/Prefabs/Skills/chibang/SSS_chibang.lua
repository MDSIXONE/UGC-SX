---@class SSS_chibang_C:PESkillTemplate_Base_C
--Edit Below--
local SSS_chibang = {}
 
function SSS_chibang:OnEnableSkill_BP()
    SSS_chibang.SuperClass.OnEnableSkill_BP(self)
end

function SSS_chibang:OnDisableSkill_BP()
    SSS_chibang.SuperClass.OnDisableSkill_BP(self)
end

function SSS_chibang:OnActivateSkill_BP()
    SSS_chibang.SuperClass.OnActivateSkill_BP(self)
end

function SSS_chibang:OnDeActivateSkill_BP()
    SSS_chibang.SuperClass.OnDeActivateSkill_BP(self)
end

function SSS_chibang:CanActivateSkill_BP()
    return SSS_chibang.SuperClass.CanActivateSkill_BP(self)
end

return SSS_chibang