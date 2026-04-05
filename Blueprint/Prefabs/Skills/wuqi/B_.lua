---@class B__C:PESkillTemplate_Base_C
--Edit Below--
local B_ = {}
 
function B_:OnEnableSkill_BP()
    B_.SuperClass.OnEnableSkill_BP(self)
end

function B_:OnDisableSkill_BP()
    B_.SuperClass.OnDisableSkill_BP(self)
end

function B_:OnActivateSkill_BP()
    B_.SuperClass.OnActivateSkill_BP(self)
end

function B_:OnDeActivateSkill_BP()
    B_.SuperClass.OnDeActivateSkill_BP(self)
end

function B_:CanActivateSkill_BP()
    return B_.SuperClass.CanActivateSkill_BP(self)
end

return B_