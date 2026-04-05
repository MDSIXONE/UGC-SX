---@class GW9_1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW9_1怪物实例（MonsterID: 319）
local GW9_1 = BaseMonster.New(319, "GW9_1")

return GW9_1
