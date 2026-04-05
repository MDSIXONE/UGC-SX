---@class GW7_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW7_2怪物实例（MonsterID: 327）
local GW7_2 = BaseMonster.New(327, "GW7_2")

return GW7_2
