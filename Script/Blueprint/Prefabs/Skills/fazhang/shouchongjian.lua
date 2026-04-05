---@class shouchongjian_C:PESkillTemplate_Base_C
--Edit Below--
local shouchongjian = {}
 
function shouchongjian:OnEnableSkill_BP()
    shouchongjian.SuperClass.OnEnableSkill_BP(self)
end

function shouchongjian:OnDisableSkill_BP()
    shouchongjian.SuperClass.OnDisableSkill_BP(self)
end

function shouchongjian:OnActivateSkill_BP()
    shouchongjian.SuperClass.OnActivateSkill_BP(self)
end

function shouchongjian:OnDeActivateSkill_BP()
    shouchongjian.SuperClass.OnDeActivateSkill_BP(self)
end

function shouchongjian:CanActivateSkill_BP()
    return shouchongjian.SuperClass.CanActivateSkill_BP(self)
end

return shouchongjian