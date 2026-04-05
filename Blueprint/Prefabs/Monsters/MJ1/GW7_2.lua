---@class GW7_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW7_1怪物实例（MonsterID: 171）
local GW7_1 = BaseMonster.New(327, "GW7_1")

return GW7_1
