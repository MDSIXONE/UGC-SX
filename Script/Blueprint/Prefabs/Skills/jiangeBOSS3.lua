---@class jiangeBOSS3_C:PESkillTemplate_Base_C
--Edit Below--
local jiangeBOSS3 = {}
 
function jiangeBOSS3:OnEnableSkill_BP()
    jiangeBOSS3.SuperClass.OnEnableSkill_BP(self)
end

function jiangeBOSS3:OnDisableSkill_BP()
    jiangeBOSS3.SuperClass.OnDisableSkill_BP(self)
end

function jiangeBOSS3:OnActivateSkill_BP()
    jiangeBOSS3.SuperClass.OnActivateSkill_BP(self)
end

function jiangeBOSS3:OnDeActivateSkill_BP()
    jiangeBOSS3.SuperClass.OnDeActivateSkill_BP(self)
end

function jiangeBOSS3:CanActivateSkill_BP()
    return jiangeBOSS3.SuperClass.CanActivateSkill_BP(self)
end

return jiangeBOSS3