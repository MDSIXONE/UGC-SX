---@class GW2_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW2_4怪物实例（MonsterID: 342）
local GW2_4 = BaseMonster.New(342, "GW2_4")

return GW2_4
