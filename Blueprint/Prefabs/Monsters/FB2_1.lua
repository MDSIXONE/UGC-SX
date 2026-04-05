---@class FB2_1_C:BP_UGC_GenericMobPawn_Base_C
---@field LogicPartManager ULogicPartManagerComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建FB2_1怪物实例（MonsterID: 201）
local FB2_1 = BaseMonster.New(321, "FB2_1")

return FB2_1
