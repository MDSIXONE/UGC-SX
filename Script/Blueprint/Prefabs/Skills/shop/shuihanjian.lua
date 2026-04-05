---@class shuihanjian_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local shuihanjian = {}
 
function shuihanjian:OnEnableSkill_BP()
    shuihanjian.SuperClass.OnEnableSkill_BP(self)
end

function shuihanjian:OnDisableSkill_BP()
    shuihanjian.SuperClass.OnDisableSkill_BP(self)
end

function shuihanjian:OnActivateSkill_BP()
    shuihanjian.SuperClass.OnActivateSkill_BP(self)
end

function shuihanjian:OnDeActivateSkill_BP()
    shuihanjian.SuperClass.OnDeActivateSkill_BP(self)
end

function shuihanjian:CanActivateSkill_BP()
    return shuihanjian.SuperClass.CanActivateSkill_BP(self)
end

return shuihanjian