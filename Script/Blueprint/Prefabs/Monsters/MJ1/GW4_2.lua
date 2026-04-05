---@class GW4_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW4_2怪物实例（MonsterID: 324）
local GW4_2 = BaseMonster.New(324, "GW4_2")

return GW4_2
