---@class shuihanchi_C:PESkillTemplate_Base_C
--Edit Below--
local shuihanchi = {}
 
function shuihanchi:OnEnableSkill_BP()
    shuihanchi.SuperClass.OnEnableSkill_BP(self)
end

function shuihanchi:OnDisableSkill_BP()
    shuihanchi.SuperClass.OnDisableSkill_BP(self)
end

function shuihanchi:OnActivateSkill_BP()
    shuihanchi.SuperClass.OnActivateSkill_BP(self)
end

function shuihanchi:OnDeActivateSkill_BP()
    shuihanchi.SuperClass.OnDeActivateSkill_BP(self)
end

function shuihanchi:CanActivateSkill_BP()
    return shuihanchi.SuperClass.CanActivateSkill_BP(self)
end

return shuihanchi