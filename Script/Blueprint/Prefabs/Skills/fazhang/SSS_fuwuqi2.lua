---@class SSS_fuwuqi2_C:PESkillTemplate_Base_C
---@field SetterActors ULuaArrayHelper<AEmitter>
--Edit Below--
local SSS_fuwuqi2 = {}
 
function SSS_fuwuqi2:OnEnableSkill_BP()
    SSS_fuwuqi2.SuperClass.OnEnableSkill_BP(self)
end

function SSS_fuwuqi2:OnDisableSkill_BP()
    SSS_fuwuqi2.SuperClass.OnDisableSkill_BP(self)
end

function SSS_fuwuqi2:OnActivateSkill_BP()
    SSS_fuwuqi2.SuperClass.OnActivateSkill_BP(self)
end

function SSS_fuwuqi2:OnDeActivateSkill_BP()
    SSS_fuwuqi2.SuperClass.OnDeActivateSkill_BP(self)
end

function SSS_fuwuqi2:CanActivateSkill_BP()
    return SSS_fuwuqi2.SuperClass.CanActivateSkill_BP(self)
end

return SSS_fuwuqi2