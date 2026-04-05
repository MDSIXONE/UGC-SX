---@class GW6_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW6_2怪物实例（MonsterID: 326）
local GW6_2 = BaseMonster.New(326, "GW6_2")

return GW6_2
