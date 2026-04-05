---@class jinse_C:PESkillTemplate_Base_C
--Edit Below--
local jinse = {}
 
function jinse:OnEnableSkill_BP()
    jinse.SuperClass.OnEnableSkill_BP(self)
end

function jinse:OnDisableSkill_BP()
    jinse.SuperClass.OnDisableSkill_BP(self)
end

function jinse:OnActivateSkill_BP()
    jinse.SuperClass.OnActivateSkill_BP(self)
end

function jinse:OnDeActivateSkill_BP()
    jinse.SuperClass.OnDeActivateSkill_BP(self)
end

function jinse:CanActivateSkill_BP()
    return jinse.SuperClass.CanActivateSkill_BP(self)
end

return jinse