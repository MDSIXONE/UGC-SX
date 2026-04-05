---@class GW2_1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW2_1怪物实例（MonsterID: 312）
local GW2_1 = BaseMonster.New(312, "GW2_1")

return GW2_1
