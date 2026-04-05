---@class GW6_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW6_3怪物实例（MonsterID: 336）
local GW6_3 = BaseMonster.New(336, "GW6_3")

return GW6_3
