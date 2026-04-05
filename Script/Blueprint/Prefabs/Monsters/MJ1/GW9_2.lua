---@class GW9_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW9_2怪物实例（MonsterID: 329）
local GW9_2 = BaseMonster.New(329, "GW9_2")

return GW9_2
