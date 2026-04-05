---@class SS1_C:PESkillTemplate_Base_C
--Edit Below--
local SS1 = {}
 
function SS1:OnEnableSkill_BP()
    SS1.SuperClass.OnEnableSkill_BP(self)
end

function SS1:OnDisableSkill_BP()
    SS1.SuperClass.OnDisableSkill_BP(self)
end

function SS1:OnActivateSkill_BP()
    SS1.SuperClass.OnActivateSkill_BP(self)
end

function SS1:OnDeActivateSkill_BP()
    SS1.SuperClass.OnDeActivateSkill_BP(self)
end

function SS1:CanActivateSkill_BP()
    return SS1.SuperClass.CanActivateSkill_BP(self)
end

return SS1