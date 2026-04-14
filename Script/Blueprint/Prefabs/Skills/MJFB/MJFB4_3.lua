---@class MJFB4_3_C:PESkillTemplate_Base_C
--Edit Below--
local MJFB4_3 = {}
 
function MJFB4_3:OnEnableSkill_BP()
    MJFB4_3.SuperClass.OnEnableSkill_BP(self)
end

function MJFB4_3:OnDisableSkill_BP()
    MJFB4_3.SuperClass.OnDisableSkill_BP(self)
end

function MJFB4_3:OnActivateSkill_BP()
    MJFB4_3.SuperClass.OnActivateSkill_BP(self)
end

function MJFB4_3:OnDeActivateSkill_BP()
    MJFB4_3.SuperClass.OnDeActivateSkill_BP(self)
end

function MJFB4_3:CanActivateSkill_BP()
    return MJFB4_3.SuperClass.CanActivateSkill_BP(self)
end

return MJFB4_3