---@class lanse_C:PESkillTemplate_Base_C
--Edit Below--
local lanse = {}
 
function lanse:OnEnableSkill_BP()
    lanse.SuperClass.OnEnableSkill_BP(self)
end

function lanse:OnDisableSkill_BP()
    lanse.SuperClass.OnDisableSkill_BP(self)
end

function lanse:OnActivateSkill_BP()
    lanse.SuperClass.OnActivateSkill_BP(self)
end

function lanse:OnDeActivateSkill_BP()
    lanse.SuperClass.OnDeActivateSkill_BP(self)
end

function lanse:CanActivateSkill_BP()
    return lanse.SuperClass.CanActivateSkill_BP(self)
end

return lanse