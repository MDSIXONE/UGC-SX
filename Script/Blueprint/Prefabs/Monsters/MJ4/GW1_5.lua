---@class GW1_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW1_5怪物实例（MonsterID: 351）
local GW1_5 = BaseMonster.New(351, "GW1_5")

return GW1_5
