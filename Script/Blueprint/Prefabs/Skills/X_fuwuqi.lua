---@class X_fuwuqi_C:PESkillTemplate_Base_C
--Edit Below--
local X_fuwuqi = {}
 
function X_fuwuqi:OnEnableSkill_BP()
    X_fuwuqi.SuperClass.OnEnableSkill_BP(self)
end

function X_fuwuqi:OnDisableSkill_BP()
    X_fuwuqi.SuperClass.OnDisableSkill_BP(self)
end

function X_fuwuqi:OnActivateSkill_BP()
    X_fuwuqi.SuperClass.OnActivateSkill_BP(self)
end

function X_fuwuqi:OnDeActivateSkill_BP()
    X_fuwuqi.SuperClass.OnDeActivateSkill_BP(self)
end

function X_fuwuqi:CanActivateSkill_BP()
    return X_fuwuqi.SuperClass.CanActivateSkill_BP(self)
end

return X_fuwuqi