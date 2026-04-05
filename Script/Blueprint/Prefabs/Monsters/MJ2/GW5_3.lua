---@class GW5_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW5_3怪物实例（MonsterID: 335）
local GW5_3 = BaseMonster.New(335, "GW5_3")

return GW5_3
