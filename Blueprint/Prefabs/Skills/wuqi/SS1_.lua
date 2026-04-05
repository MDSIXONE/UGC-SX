---@class SS1__C:PESkillTemplate_Base_C
--Edit Below--
local SS1_ = {}
 
function SS1_:OnEnableSkill_BP()
    SS1_.SuperClass.OnEnableSkill_BP(self)
end

function SS1_:OnDisableSkill_BP()
    SS1_.SuperClass.OnDisableSkill_BP(self)
end

function SS1_:OnActivateSkill_BP()
    SS1_.SuperClass.OnActivateSkill_BP(self)
end

function SS1_:OnDeActivateSkill_BP()
    SS1_.SuperClass.OnDeActivateSkill_BP(self)
end

function SS1_:CanActivateSkill_BP()
    return SS1_.SuperClass.CanActivateSkill_BP(self)
end

return SS1_