---@class GW7_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW7_3怪物实例（MonsterID: 337）
local GW7_3 = BaseMonster.New(337, "GW7_3")

return GW7_3
