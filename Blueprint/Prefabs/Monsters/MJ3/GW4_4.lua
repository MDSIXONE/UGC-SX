---@class GW4_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW4_1怪物实例（MonsterID: 141）
local GW4_1 = BaseMonster.New(334, "GW4_1")

return GW4_1
