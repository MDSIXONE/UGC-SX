---@class lvse_C:PESkillTemplate_Base_C
--Edit Below--
local lvse = {}
 
function lvse:OnEnableSkill_BP()
    lvse.SuperClass.OnEnableSkill_BP(self)
end

function lvse:OnDisableSkill_BP()
    lvse.SuperClass.OnDisableSkill_BP(self)
end

function lvse:OnActivateSkill_BP()
    lvse.SuperClass.OnActivateSkill_BP(self)
end

function lvse:OnDeActivateSkill_BP()
    lvse.SuperClass.OnDeActivateSkill_BP(self)
end

function lvse:CanActivateSkill_BP()
    return lvse.SuperClass.CanActivateSkill_BP(self)
end

return lvse