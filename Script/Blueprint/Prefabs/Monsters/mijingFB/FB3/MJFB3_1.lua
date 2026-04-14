---@class MJFB3_1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建MJFB3_1怪物实例（MonsterID: 344）
local MJFB3_1 = BaseMonster.New(344, "MJFB3_1")

return MJFB3_1
