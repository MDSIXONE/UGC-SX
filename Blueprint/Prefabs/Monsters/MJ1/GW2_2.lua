---@class GW2_2_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW2_1怪物实例（MonsterID: 121）
local GW2_1 = BaseMonster.New(322, "GW2_1")

return GW2_1
