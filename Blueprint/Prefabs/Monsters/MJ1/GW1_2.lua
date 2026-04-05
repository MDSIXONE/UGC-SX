---@class GW1_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW1_1怪物实例（MonsterID: 111）
local GW1_1 = BaseMonster.New(321, "GW1_1")

return GW1_1
