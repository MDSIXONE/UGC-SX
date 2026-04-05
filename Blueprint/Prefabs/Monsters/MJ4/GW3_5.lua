---@class GW3_1_C:BP_UGC_GenericMobPawn_Base_C
---@field LogicPartManager ULogicPartManagerComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW3_1怪物实例（MonsterID: 131）
local GW3_1 = BaseMonster.New(333, "GW3_1")

return GW3_1
