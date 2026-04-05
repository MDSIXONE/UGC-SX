---@class baise_C:PESkillTemplate_Base_C
--Edit Below--
local baise = {}
 
function baise:OnEnableSkill_BP()
    baise.SuperClass.OnEnableSkill_BP(self)
end

function baise:OnDisableSkill_BP()
    baise.SuperClass.OnDisableSkill_BP(self)
end

function baise:OnActivateSkill_BP()
    baise.SuperClass.OnActivateSkill_BP(self)
end

function baise:OnDeActivateSkill_BP()
    baise.SuperClass.OnDeActivateSkill_BP(self)
end

function baise:CanActivateSkill_BP()
    return baise.SuperClass.CanActivateSkill_BP(self)
end

return baise