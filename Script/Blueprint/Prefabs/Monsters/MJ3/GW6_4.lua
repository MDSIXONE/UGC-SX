---@class GW6_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW6_4怪物实例（MonsterID: 346）
local GW6_4 = BaseMonster.New(346, "GW6_4")

return GW6_4
