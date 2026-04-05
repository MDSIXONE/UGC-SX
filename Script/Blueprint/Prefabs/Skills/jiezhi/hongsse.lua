---@class hongsse_C:PESkillTemplate_Base_C
--Edit Below--
local hongsse = {}
 
function hongsse:OnEnableSkill_BP()
    hongsse.SuperClass.OnEnableSkill_BP(self)
end

function hongsse:OnDisableSkill_BP()
    hongsse.SuperClass.OnDisableSkill_BP(self)
end

function hongsse:OnActivateSkill_BP()
    hongsse.SuperClass.OnActivateSkill_BP(self)
end

function hongsse:OnDeActivateSkill_BP()
    hongsse.SuperClass.OnDeActivateSkill_BP(self)
end

function hongsse:CanActivateSkill_BP()
    return hongsse.SuperClass.CanActivateSkill_BP(self)
end

return hongsse