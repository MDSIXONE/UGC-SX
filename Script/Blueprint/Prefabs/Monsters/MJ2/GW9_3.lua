---@class GW9_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW9_3怪物实例（MonsterID: 339）
local GW9_3 = BaseMonster.New(339, "GW9_3")

return GW9_3
