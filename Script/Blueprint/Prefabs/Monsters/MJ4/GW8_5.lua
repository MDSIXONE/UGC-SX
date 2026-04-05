---@class GW8_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW8_5怪物实例（MonsterID: 358）
local GW8_5 = BaseMonster.New(358, "GW8_5")

return GW8_5
