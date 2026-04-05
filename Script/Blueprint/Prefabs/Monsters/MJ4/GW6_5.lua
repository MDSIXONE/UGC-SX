---@class GW6_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW6_5怪物实例（MonsterID: 356）
local GW6_5 = BaseMonster.New(356, "GW6_5")

return GW6_5
