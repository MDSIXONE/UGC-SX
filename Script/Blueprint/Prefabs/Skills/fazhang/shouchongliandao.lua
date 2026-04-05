---@class shouchongliandao_C:PESkillTemplate_Base_C
--Edit Below--
local shouchongliandao = {}
 
function shouchongliandao:OnEnableSkill_BP()
    shouchongliandao.SuperClass.OnEnableSkill_BP(self)
end

function shouchongliandao:OnDisableSkill_BP()
    shouchongliandao.SuperClass.OnDisableSkill_BP(self)
end

function shouchongliandao:OnActivateSkill_BP()
    shouchongliandao.SuperClass.OnActivateSkill_BP(self)
end

function shouchongliandao:OnDeActivateSkill_BP()
    shouchongliandao.SuperClass.OnDeActivateSkill_BP(self)
end

function shouchongliandao:CanActivateSkill_BP()
    return shouchongliandao.SuperClass.CanActivateSkill_BP(self)
end

return shouchongliandao