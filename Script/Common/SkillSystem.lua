---@class SkillSystem
---Player skill system: talent buffs, Shenyin/Jiange passive skills.
local Config_PlayerData = UGCGameSystem.UGCRequire('Script.Common.Config_PlayerData')

local SkillSystem = {}

function SkillSystem.ApplyTalentBuff(self, talentType)
    local config = Config_PlayerData.TALENT_CONFIG[talentType]
    if not config then
        return
    end

    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then
        return
    end

    self:UpdateClientAttributes()
end

function SkillSystem.ApplyAllTalentBuffsInternal(self, Player)
    if not Player then return end

    for _, talentType in ipairs(Config_PlayerData.ENABLED_TALENT_TYPES) do
        local dataField = "PlayerTalent" .. talentType
        local level = self.GameData[dataField] or 0
        local buffPath = Config_PlayerData.TALENT_BUFF_PATH_BY_TYPE[talentType]

        if level > 0 and buffPath and buffPath ~= "" then
            UGCPersistEffectSystem.RemoveBuffByClass(Player, buffPath, -1, nil)
            UGCPersistEffectSystem.AddBuffByClass(Player, buffPath, nil, -1, level)
        end
    end
end

function SkillSystem.ApplyAllTalentBuffs(self)
    for _, talentType in ipairs(Config_PlayerData.ENABLED_TALENT_TYPES) do
        local dataField = "PlayerTalent" .. talentType
        local level = self.GameData[dataField] or 0
        if level > 0 then
            SkillSystem.ApplyTalentBuff(self, talentType)
        end
    end
end

function SkillSystem.Server_SetShenyingSkill(self, skillPath, isWear)
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    for _, skillName in ipairs(Config_PlayerData.ALL_SHENYIN_SKILLS) do
        for lv = 1, 5 do
            local path
            if lv == 1 then
                path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/' .. skillName .. '.' .. skillName .. '_C')
            else
                path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenyin/SY' .. lv .. '/' .. skillName .. '.' .. skillName .. '_C')
            end
            local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, path)
            if skills and #skills > 0 then
                for _, skill in ipairs(skills) do
                    UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
                end
            end
        end
    end

    if isWear then
        UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
    end
end

function SkillSystem.Server_SetJiangeSkill(self, skillPath, isWear)
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    for _, skillName in ipairs(Config_PlayerData.ALL_JIANGE_SKILLS) do
        local path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. skillName .. '.' .. skillName .. '_C')
        local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, path)
        if skills and #skills > 0 then
            for _, skill in ipairs(skills) do
                UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
            end
        end
    end

    if isWear then
        UGCPersistEffectSystem.AddSkillByClass(Player, skillPath)
    end
end

function SkillSystem.Server_SetBloodlineEnabled(self, isEnabled)
    if not UGCGameSystem.IsServer(self) then return end
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then
        return
    end

    if isEnabled then
        local skill = UGCPersistEffectSystem.AddSkillByClass(Player, Config_PlayerData.BLOODLINE_SKILL_PATH)
        if skill then
            self.GameData.BloodlineEnabled = true
            self.UGCBloodlineEnabled = true
        else
            return
        end
    else
        local skills = UGCPersistEffectSystem.GetSkillsByClass(Player, Config_PlayerData.BLOODLINE_SKILL_PATH)
        if skills and #skills > 0 then
            for _, skill in ipairs(skills) do
                UGCPersistEffectSystem.RemoveSkillInstance(Player, skill)
            end
        end
        self.GameData.BloodlineEnabled = false
        self.UGCBloodlineEnabled = false
    end

    UnrealNetwork.RepLazyProperty(self, "UGCBloodlineEnabled")
    UGCAttributeSystem.SetGameAttributeValue(Player, 'bland', isEnabled and 1 or 0)
    self:DataSave()
end

function SkillSystem.ReapplyWearingSkills(self)
    local Player = UGCGameSystem.GetPlayerPawnByPlayerState(self)
    if not Player then return end

    local jiangeLevel = self.GameData.PlayerJiangeLevel or 1
    if jiangeLevel > 0 and jiangeLevel <= 7 then
        local jiangeSkills = {"bailangjian", "kuishejian", "baihujian", "bifangjian", "qilingjian", "zhuquejian", "shenlongjian"}
        local skillName = jiangeSkills[jiangeLevel]
        if skillName then
            local skillPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/shenjian/' .. skillName .. '.' .. skillName .. '_C')
            if skillPath and skillPath ~= "" then
                SkillSystem.Server_SetJiangeSkill(self, skillPath, true)
            end
        end
    end

    local shenyinData = self.GameData.PlayerShenyinData or ""
    if shenyinData ~= "" then
        local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerState(self)
        if PlayerController then
            local PlayerState = self
            local data = {}
            local success = pcall(function()
                data = JsonUtil.DecodeJson(shenyinData)
            end)
            if success and data and data.skillPath then
                SkillSystem.Server_SetShenyingSkill(self, data.skillPath, true)
            end
        end
    end
end

return SkillSystem
