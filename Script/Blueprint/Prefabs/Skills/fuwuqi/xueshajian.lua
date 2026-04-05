---@class xueshajian_C:PESkillTemplate_Base_C
--Edit Below--
local xueshajian = {}
 
function xueshajian:OnEnableSkill_BP()
    xueshajian.SuperClass.OnEnableSkill_BP(self)
end

function xueshajian:OnDisableSkill_BP()
    xueshajian.SuperClass.OnDisableSkill_BP(self)
end

function xueshajian:OnActivateSkill_BP()
    xueshajian.SuperClass.OnActivateSkill_BP(self)
end

function xueshajian:OnDeActivateSkill_BP()
    xueshajian.SuperClass.OnDeActivateSkill_BP(self)
end

function xueshajian:CanActivateSkill_BP()
    return xueshajian.SuperClass.CanActivateSkill_BP(self)
end

return xueshajian