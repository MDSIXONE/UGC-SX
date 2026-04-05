---@class FB2_2_C:BP_UGC_GenericMobPawn_Base_C
---@field LogicPartManager ULogicPartManagerComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建FB2_2怪物实例（MonsterID: 202）
local FB2_2 = BaseMonster.New(322, "FB2_2")

return FB2_2
