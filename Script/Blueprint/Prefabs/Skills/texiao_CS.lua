---@class texiao_CS_C:PESkillTemplate_Base_C
--Edit Below--
local texiao_CS = {}
 
function texiao_CS:OnEnableSkill_BP()
    texiao_CS.SuperClass.OnEnableSkill_BP(self)
end

function texiao_CS:OnDisableSkill_BP()
    texiao_CS.SuperClass.OnDisableSkill_BP(self)
end

function texiao_CS:OnActivateSkill_BP()
    texiao_CS.SuperClass.OnActivateSkill_BP(self)
end

function texiao_CS:OnDeActivateSkill_BP()
    texiao_CS.SuperClass.OnDeActivateSkill_BP(self)
end

function texiao_CS:CanActivateSkill_BP()
    return texiao_CS.SuperClass.CanActivateSkill_BP(self)
end

return texiao_CS