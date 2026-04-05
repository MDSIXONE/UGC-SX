---@class chengsefazhang_C:PESkillTemplate_Base_C
--Edit Below--
local lvsefazhang = {}
 
function lvsefazhang:OnEnableSkill_BP()
    lvsefazhang.SuperClass.OnEnableSkill_BP(self)
end

function lvsefazhang:OnDisableSkill_BP()
    lvsefazhang.SuperClass.OnDisableSkill_BP(self)
end

function lvsefazhang:OnActivateSkill_BP()
    lvsefazhang.SuperClass.OnActivateSkill_BP(self)
end

function lvsefazhang:OnDeActivateSkill_BP()
    lvsefazhang.SuperClass.OnDeActivateSkill_BP(self)
end

function lvsefazhang:CanActivateSkill_BP()
    return lvsefazhang.SuperClass.CanActivateSkill_BP(self)
end

return lvsefazhang