---@class GW2_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW2_2怪物实例（MonsterID: 322）
local GW2_2 = BaseMonster.New(322, "GW2_2")

return GW2_2
