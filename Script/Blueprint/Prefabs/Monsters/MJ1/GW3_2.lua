---@class GW3_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW3_2怪物实例（MonsterID: 323）
local GW3_2 = BaseMonster.New(323, "GW3_2")

return GW3_2
