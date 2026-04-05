---@class GW3_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW3_4怪物实例（MonsterID: 343）
local GW3_4 = BaseMonster.New(343, "GW3_4")

return GW3_4
