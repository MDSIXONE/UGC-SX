---@class SCWQ_jn_C:PESkillTemplate_Base_C
--Edit Below--
local SCWQ_jn = {}
 
function SCWQ_jn:OnEnableSkill_BP()
    SCWQ_jn.SuperClass.OnEnableSkill_BP(self)
end

function SCWQ_jn:OnDisableSkill_BP()
    SCWQ_jn.SuperClass.OnDisableSkill_BP(self)
end

function SCWQ_jn:OnActivateSkill_BP()
    SCWQ_jn.SuperClass.OnActivateSkill_BP(self)
end

function SCWQ_jn:OnDeActivateSkill_BP()
    SCWQ_jn.SuperClass.OnDeActivateSkill_BP(self)
end

function SCWQ_jn:CanActivateSkill_BP()
    return SCWQ_jn.SuperClass.CanActivateSkill_BP(self)
end

return SCWQ_jn