---@class GW6_1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW6_1怪物实例（MonsterID: 161）
local GW6_1 = BaseMonster.New(316, "GW6_1")

return GW6_1
