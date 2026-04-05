---@class GW1_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW1_4怪物实例（MonsterID: 341）
local GW1_4 = BaseMonster.New(341, "GW1_4")

return GW1_4
