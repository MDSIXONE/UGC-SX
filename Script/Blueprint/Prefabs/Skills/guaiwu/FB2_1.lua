---@class FB2_1_C:PESkillTemplate_Base_C
---@field SkillAnimationIndex int32
--Edit Below--
local FB2_1 = {}
 
function FB2_1:OnEnableSkill_BP()
    FB2_1.SuperClass.OnEnableSkill_BP(self)
end

function FB2_1:OnDisableSkill_BP()
    FB2_1.SuperClass.OnDisableSkill_BP(self)
end

function FB2_1:OnActivateSkill_BP()
    FB2_1.SuperClass.OnActivateSkill_BP(self)
end

function FB2_1:OnDeActivateSkill_BP()
    FB2_1.SuperClass.OnDeActivateSkill_BP(self)
end

function FB2_1:CanActivateSkill_BP()
    return FB2_1.SuperClass.CanActivateSkill_BP(self)
end

return FB2_1