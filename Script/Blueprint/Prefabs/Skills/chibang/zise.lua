---@class zise_C:PESkillTemplate_Base_C
--Edit Below--
local zise = {}
 
function zise:OnEnableSkill_BP()
    zise.SuperClass.OnEnableSkill_BP(self)
end

function zise:OnDisableSkill_BP()
    zise.SuperClass.OnDisableSkill_BP(self)
end

function zise:OnActivateSkill_BP()
    zise.SuperClass.OnActivateSkill_BP(self)
end

function zise:OnDeActivateSkill_BP()
    zise.SuperClass.OnDeActivateSkill_BP(self)
end

function zise:CanActivateSkill_BP()
    return zise.SuperClass.CanActivateSkill_BP(self)
end

return zise