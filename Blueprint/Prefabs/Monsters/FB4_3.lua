---@class FB4_3_C:BP_UGC_GenericMobPawn_Base_C
---@field LogicPartManager ULogicPartManagerComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建FB4_3怪物实例（MonsterID: 403）
local FB4_3 = BaseMonster.New(343, "FB4_3")

return FB4_3
