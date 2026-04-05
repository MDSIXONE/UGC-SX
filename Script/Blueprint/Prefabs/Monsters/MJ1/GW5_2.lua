---@class GW5_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW5_2怪物实例（MonsterID: 325）
local GW5_2 = BaseMonster.New(325, "GW5_2")

return GW5_2
