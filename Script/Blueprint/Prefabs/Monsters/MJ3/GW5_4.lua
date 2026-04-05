---@class GW5_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW5_4怪物实例（MonsterID: 345）
local GW5_4 = BaseMonster.New(345, "GW5_4")

return GW5_4
