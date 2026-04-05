---@class GW3_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW3_5怪物实例（MonsterID: 353）
local GW3_5 = BaseMonster.New(353, "GW3_5")

return GW3_5
