---@class PESkill_UGC_Apprentice_Skill_1_C:PESkillTemplate_Base_C
--Edit Below--
local MJFB4_1 = {}
 
function MJFB4_1:OnEnableSkill_BP()
    MJFB4_1.SuperClass.OnEnableSkill_BP(self)
end

function MJFB4_1:OnDisableSkill_BP()
    MJFB4_1.SuperClass.OnDisableSkill_BP(self)
end

function MJFB4_1:OnActivateSkill_BP()
    MJFB4_1.SuperClass.OnActivateSkill_BP(self)
end

function MJFB4_1:OnDeActivateSkill_BP()
    MJFB4_1.SuperClass.OnDeActivateSkill_BP(self)
end

function MJFB4_1:CanActivateSkill_BP()
    return MJFB4_1.SuperClass.CanActivateSkill_BP(self)
end

return MJFB4_1