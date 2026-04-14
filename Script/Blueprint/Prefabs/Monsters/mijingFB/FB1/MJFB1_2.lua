---@class MJFB1_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建MJFB1_2怪物实例（MonsterID: 323）
local MJFB1_2 = BaseMonster.New(323, "MJFB1_2")

return MJFB1_2
