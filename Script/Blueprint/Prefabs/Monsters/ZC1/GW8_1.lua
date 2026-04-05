---@class GW8_1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW8_1怪物实例（MonsterID: 318）
local GW8_1 = BaseMonster.New(318, "GW8_1")

return GW8_1
