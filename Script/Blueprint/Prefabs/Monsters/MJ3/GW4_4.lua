---@class GW4_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW4_4怪物实例（MonsterID: 344）
local GW4_4 = BaseMonster.New(344, "GW4_4")

return GW4_4
