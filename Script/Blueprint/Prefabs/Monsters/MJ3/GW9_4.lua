---@class GW9_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW9_4怪物实例（MonsterID: 349）
local GW9_4 = BaseMonster.New(349, "GW9_4")

return GW9_4
