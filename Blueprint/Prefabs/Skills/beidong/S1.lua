---@class S1_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local S1 = {}
 
function S1:OnEnableSkill_BP()
    S1.SuperClass.OnEnableSkill_BP(self)
end

function S1:OnDisableSkill_BP()
    S1.SuperClass.OnDisableSkill_BP(self)
end

function S1:OnActivateSkill_BP()
    S1.SuperClass.OnActivateSkill_BP(self)
end

function S1:OnDeActivateSkill_BP()
    S1.SuperClass.OnDeActivateSkill_BP(self)
end

function S1:CanActivateSkill_BP()
    return S1.SuperClass.CanActivateSkill_BP(self)
end

return S1