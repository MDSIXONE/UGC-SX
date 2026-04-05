---@class GW9_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW9_5怪物实例（MonsterID: 359）
local GW9_5 = BaseMonster.New(359, "GW9_5")

return GW9_5
