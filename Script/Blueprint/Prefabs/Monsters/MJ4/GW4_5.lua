---@class GW4_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW4_5怪物实例（MonsterID: 354）
local GW4_5 = BaseMonster.New(354, "GW4_5")

return GW4_5
