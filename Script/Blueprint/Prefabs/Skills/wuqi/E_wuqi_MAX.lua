---@class E_wuqi_MAX_C:PESkillTemplate_Base_C
--Edit Below--
local E_wuqi = {}
 
function E_wuqi:OnEnableSkill_BP()
    E_wuqi.SuperClass.OnEnableSkill_BP(self)
end

function E_wuqi:OnDisableSkill_BP()
    E_wuqi.SuperClass.OnDisableSkill_BP(self)
end

function E_wuqi:OnActivateSkill_BP()
    E_wuqi.SuperClass.OnActivateSkill_BP(self)
end

function E_wuqi:OnDeActivateSkill_BP()
    E_wuqi.SuperClass.OnDeActivateSkill_BP(self)
end

function E_wuqi:CanActivateSkill_BP()
    return E_wuqi.SuperClass.CanActivateSkill_BP(self)
end

return E_wuqi