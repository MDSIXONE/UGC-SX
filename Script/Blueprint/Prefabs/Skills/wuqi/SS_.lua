---@class SS__C:PESkillTemplate_Base_C
--Edit Below--
local SS_ = {}
 
function SS_:OnEnableSkill_BP()
    SS_.SuperClass.OnEnableSkill_BP(self)
end

function SS_:OnDisableSkill_BP()
    SS_.SuperClass.OnDisableSkill_BP(self)
end

function SS_:OnActivateSkill_BP()
    SS_.SuperClass.OnActivateSkill_BP(self)
end

function SS_:OnDeActivateSkill_BP()
    SS_.SuperClass.OnDeActivateSkill_BP(self)
end

function SS_:CanActivateSkill_BP()
    return SS_.SuperClass.CanActivateSkill_BP(self)
end

return SS_