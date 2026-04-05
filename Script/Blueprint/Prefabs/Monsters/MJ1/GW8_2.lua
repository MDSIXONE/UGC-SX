---@class GW8_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW8_2怪物实例（MonsterID: 328）
local GW8_2 = BaseMonster.New(328, "GW8_2")

return GW8_2
