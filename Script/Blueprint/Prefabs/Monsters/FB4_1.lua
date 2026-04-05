---@class FB4_1_C:BP_UGC_GenericMobPawn_Base_C
---@field LogicPartManager ULogicPartManagerComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建FB4_1怪物实例（MonsterID: 401）
local FB4_1 = BaseMonster.New(341, "FB4_1")

return FB4_1
