---@class FB3_1_C:PESkillTemplate_Base_C
--Edit Below--
local FB3_1 = {}
 
function FB3_1:OnEnableSkill_BP()
    FB3_1.SuperClass.OnEnableSkill_BP(self)
end

function FB3_1:OnDisableSkill_BP()
    FB3_1.SuperClass.OnDisableSkill_BP(self)
end

function FB3_1:OnActivateSkill_BP()
    FB3_1.SuperClass.OnActivateSkill_BP(self)
end

function FB3_1:OnDeActivateSkill_BP()
    FB3_1.SuperClass.OnDeActivateSkill_BP(self)
end

function FB3_1:CanActivateSkill_BP()
    return FB3_1.SuperClass.CanActivateSkill_BP(self)
end

return FB3_1