---@class MJFB2_1_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建MJFB2_1怪物实例（MonsterID: 314）
local MJFB2_1 = BaseMonster.New(314, "MJFB2_1")

return MJFB2_1
