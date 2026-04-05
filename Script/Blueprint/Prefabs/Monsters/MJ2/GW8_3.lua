---@class GW8_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW8_3怪物实例（MonsterID: 338）
local GW8_3 = BaseMonster.New(338, "GW8_3")

return GW8_3
