---@class MJFB1_3_C:PESkillTemplate_Base_C
--Edit Below--
local MJFB1_3 = {}
 
function MJFB1_3:OnEnableSkill_BP()
    MJFB1_3.SuperClass.OnEnableSkill_BP(self)
end

function MJFB1_3:OnDisableSkill_BP()
    MJFB1_3.SuperClass.OnDisableSkill_BP(self)
end

function MJFB1_3:OnActivateSkill_BP()
    MJFB1_3.SuperClass.OnActivateSkill_BP(self)
end

function MJFB1_3:OnDeActivateSkill_BP()
    MJFB1_3.SuperClass.OnDeActivateSkill_BP(self)
end

function MJFB1_3:CanActivateSkill_BP()
    return MJFB1_3.SuperClass.CanActivateSkill_BP(self)
end

return MJFB1_3