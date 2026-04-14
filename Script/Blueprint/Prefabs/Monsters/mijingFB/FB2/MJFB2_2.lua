---@class MJFB2_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建MJFB2_2怪物实例（MonsterID: 202）
local MJFB2_2 = BaseMonster.New(322, "MJFB2_2")

return MJFB2_2
