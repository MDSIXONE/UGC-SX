---@class GW8_4_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW8_4怪物实例（MonsterID: 348）
local GW8_4 = BaseMonster.New(348, "GW8_4")

return GW8_4
