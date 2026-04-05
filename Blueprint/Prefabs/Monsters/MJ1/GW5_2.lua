---@class GW5_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW5_1怪物实例（MonsterID: 151）
local GW5_1 = BaseMonster.New(325, "GW5_1")

return GW5_1
