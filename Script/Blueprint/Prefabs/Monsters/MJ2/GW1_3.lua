---@class GW1_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW1_3怪物实例（MonsterID: 331）
local GW1_3 = BaseMonster.New(331, "GW1_3")

return GW1_3
