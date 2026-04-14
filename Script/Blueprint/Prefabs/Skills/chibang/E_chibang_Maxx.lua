---@class E_chibang_Maxx_C:PESkillTemplate_Base_C
--Edit Below--
local E_chibang_Maxx = {}
 
function E_chibang_Maxx:OnEnableSkill_BP()
    E_chibang_Maxx.SuperClass.OnEnableSkill_BP(self)
end

function E_chibang_Maxx:OnDisableSkill_BP()
    E_chibang_Maxx.SuperClass.OnDisableSkill_BP(self)
end

function E_chibang_Maxx:OnActivateSkill_BP()
    E_chibang_Maxx.SuperClass.OnActivateSkill_BP(self)
end

function E_chibang_Maxx:OnDeActivateSkill_BP()
    E_chibang_Maxx.SuperClass.OnDeActivateSkill_BP(self)
end

function E_chibang_Maxx:CanActivateSkill_BP()
    return E_chibang_Maxx.SuperClass.CanActivateSkill_BP(self)
end

return E_chibang_Maxx