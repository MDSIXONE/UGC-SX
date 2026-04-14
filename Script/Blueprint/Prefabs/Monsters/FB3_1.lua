---@class FB3_1_C:BP_UGC_GenericMobPawn_Base_C
---@field LogicPartManager ULogicPartManagerComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建FB1_1怪物实例
-- MonsterID需要在Monster.Monster配置表中设置
-- 如果不知道ID，可以设置为 101（FB1_1的建议ID）
local FB1_1 = BaseMonster.New(311, "FB1_1")

return FB1_1
