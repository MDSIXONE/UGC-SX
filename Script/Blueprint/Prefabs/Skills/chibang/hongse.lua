---@class hongse_C:PESkillTemplate_Base_C
--Edit Below--
local hongse = {}
 
function hongse:OnEnableSkill_BP()
    hongse.SuperClass.OnEnableSkill_BP(self)
end

function hongse:OnDisableSkill_BP()
    hongse.SuperClass.OnDisableSkill_BP(self)
end

function hongse:OnActivateSkill_BP()
    hongse.SuperClass.OnActivateSkill_BP(self)
end

function hongse:OnDeActivateSkill_BP()
    hongse.SuperClass.OnDeActivateSkill_BP(self)
end

function hongse:CanActivateSkill_BP()
    return hongse.SuperClass.CanActivateSkill_BP(self)
end

return hongse