---@class GW3_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW3_3怪物实例（MonsterID: 333）
local GW3_3 = BaseMonster.New(333, "GW3_3")

return GW3_3
