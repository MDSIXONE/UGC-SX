---@class chengse1_C:PESkillTemplate_Base_C
--Edit Below--
local chengse1 = {}
 
function chengse1:OnEnableSkill_BP()
    chengse1.SuperClass.OnEnableSkill_BP(self)
end

function chengse1:OnDisableSkill_BP()
    chengse1.SuperClass.OnDisableSkill_BP(self)
end

function chengse1:OnActivateSkill_BP()
    chengse1.SuperClass.OnActivateSkill_BP(self)
end

function chengse1:OnDeActivateSkill_BP()
    chengse1.SuperClass.OnDeActivateSkill_BP(self)
end

function chengse1:CanActivateSkill_BP()
    return chengse1.SuperClass.CanActivateSkill_BP(self)
end

return chengse1