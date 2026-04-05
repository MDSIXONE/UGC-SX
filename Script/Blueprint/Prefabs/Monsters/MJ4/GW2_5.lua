---@class GW2_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW2_5怪物实例（MonsterID: 352）
local GW2_5 = BaseMonster.New(352, "GW2_5")

return GW2_5
