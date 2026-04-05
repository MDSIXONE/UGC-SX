---@class C_C:PESkillTemplate_Base_C
--Edit Below--
local C = {}
 
function C:OnEnableSkill_BP()
    C.SuperClass.OnEnableSkill_BP(self)
end

function C:OnDisableSkill_BP()
    C.SuperClass.OnDisableSkill_BP(self)
end

function C:OnActivateSkill_BP()
    C.SuperClass.OnActivateSkill_BP(self)
end

function C:OnDeActivateSkill_BP()
    C.SuperClass.OnDeActivateSkill_BP(self)
end

function C:CanActivateSkill_BP()
    return C.SuperClass.CanActivateSkill_BP(self)
end

return C