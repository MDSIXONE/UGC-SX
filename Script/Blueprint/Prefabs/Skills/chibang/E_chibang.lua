---@class E_chibang_C:PESkillTemplate_Base_C
--Edit Below--
local E_chibang = {}
 
function E_chibang:OnEnableSkill_BP()
    E_chibang.SuperClass.OnEnableSkill_BP(self)
end

function E_chibang:OnDisableSkill_BP()
    E_chibang.SuperClass.OnDisableSkill_BP(self)
end

function E_chibang:OnActivateSkill_BP()
    E_chibang.SuperClass.OnActivateSkill_BP(self)
end

function E_chibang:OnDeActivateSkill_BP()
    E_chibang.SuperClass.OnDeActivateSkill_BP(self)
end

function E_chibang:CanActivateSkill_BP()
    return E_chibang.SuperClass.CanActivateSkill_BP(self)
end

return E_chibang