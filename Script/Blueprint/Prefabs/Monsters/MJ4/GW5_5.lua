---@class GW5_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW5_5怪物实例（MonsterID: 355）
local GW5_5 = BaseMonster.New(355, "GW5_5")

return GW5_5
