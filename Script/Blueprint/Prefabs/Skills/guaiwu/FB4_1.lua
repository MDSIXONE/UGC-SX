---@class BP_EliteSoldiers_Skill_1_C:PESkillTemplate_Base_C
--Edit Below--
local FB4_1 = {}
 
function FB4_1:OnEnableSkill_BP()
    FB4_1.SuperClass.OnEnableSkill_BP(self)
end

function FB4_1:OnDisableSkill_BP()
    FB4_1.SuperClass.OnDisableSkill_BP(self)
end

function FB4_1:OnActivateSkill_BP()
    FB4_1.SuperClass.OnActivateSkill_BP(self)
end

function FB4_1:OnDeActivateSkill_BP()
    FB4_1.SuperClass.OnDeActivateSkill_BP(self)
end

function FB4_1:CanActivateSkill_BP()
    return FB4_1.SuperClass.CanActivateSkill_BP(self)
end

return FB4_1