---@class GW7_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW7_4怪物实例（MonsterID: 347）
local GW7_4 = BaseMonster.New(347, "GW7_4")

return GW7_4
