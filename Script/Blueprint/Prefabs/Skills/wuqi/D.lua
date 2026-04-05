---@class D_C:PESkillTemplate_Active_C
--Edit Below--
local D = {}
 
function D:OnEnableSkill_BP()
    D.SuperClass.OnEnableSkill_BP(self)
end

function D:OnDisableSkill_BP()
    D.SuperClass.OnDisableSkill_BP(self)
end

function D:OnActivateSkill_BP()
    D.SuperClass.OnActivateSkill_BP(self)
end

function D:OnDeActivateSkill_BP()
    D.SuperClass.OnDeActivateSkill_BP(self)
end

function D:CanActivateSkill_BP()
    return D.SuperClass.CanActivateSkill_BP(self)
end

return D