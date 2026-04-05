---@class GW7_5_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW7_5怪物实例（MonsterID: 357）
local GW7_5 = BaseMonster.New(357, "GW7_5")

return GW7_5
