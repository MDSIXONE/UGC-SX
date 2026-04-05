---@class SS_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local SS = {}
 
function SS:OnEnableSkill_BP()
    SS.SuperClass.OnEnableSkill_BP(self)
end

function SS:OnDisableSkill_BP()
    SS.SuperClass.OnDisableSkill_BP(self)
end

function SS:OnActivateSkill_BP()
    SS.SuperClass.OnActivateSkill_BP(self)
end

function SS:OnDeActivateSkill_BP()
    SS.SuperClass.OnDeActivateSkill_BP(self)
end

function SS:CanActivateSkill_BP()
    return SS.SuperClass.CanActivateSkill_BP(self)
end

return SS