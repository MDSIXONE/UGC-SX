---@class S_C:PESkillPassiveSkillTemplate_C
--Edit Below--
local S = {}
 
function S:OnEnableSkill_BP()
    S.SuperClass.OnEnableSkill_BP(self)
end

function S:OnDisableSkill_BP()
    S.SuperClass.OnDisableSkill_BP(self)
end

function S:OnActivateSkill_BP()
    S.SuperClass.OnActivateSkill_BP(self)
end

function S:OnDeActivateSkill_BP()
    S.SuperClass.OnDeActivateSkill_BP(self)
end

function S:CanActivateSkill_BP()
    return S.SuperClass.CanActivateSkill_BP(self)
end

return S