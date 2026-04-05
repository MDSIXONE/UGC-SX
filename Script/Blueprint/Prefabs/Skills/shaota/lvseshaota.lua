---@class lvseshaota_C:PESkillTemplate_Base_C
--Edit Below--
local lvseshaota = {}
 
function lvseshaota:OnEnableSkill_BP()
    lvseshaota.SuperClass.OnEnableSkill_BP(self)
end

function lvseshaota:OnDisableSkill_BP()
    lvseshaota.SuperClass.OnDisableSkill_BP(self)
end

function lvseshaota:OnActivateSkill_BP()
    lvseshaota.SuperClass.OnActivateSkill_BP(self)
end

function lvseshaota:OnDeActivateSkill_BP()
    lvseshaota.SuperClass.OnDeActivateSkill_BP(self)
end

function lvseshaota:CanActivateSkill_BP()
    return lvseshaota.SuperClass.CanActivateSkill_BP(self)
end

return lvseshaota