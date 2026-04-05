---@class chengse_C:PESkillTemplate_Base_C
--Edit Below--
local chengse = {}
 
function chengse:OnEnableSkill_BP()
    chengse.SuperClass.OnEnableSkill_BP(self)
end

function chengse:OnDisableSkill_BP()
    chengse.SuperClass.OnDisableSkill_BP(self)
end

function chengse:OnActivateSkill_BP()
    chengse.SuperClass.OnActivateSkill_BP(self)
end

function chengse:OnDeActivateSkill_BP()
    chengse.SuperClass.OnDeActivateSkill_BP(self)
end

function chengse:CanActivateSkill_BP()
    return chengse.SuperClass.CanActivateSkill_BP(self)
end

return chengse