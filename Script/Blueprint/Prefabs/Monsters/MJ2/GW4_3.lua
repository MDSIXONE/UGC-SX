---@class GW4_3_C:BP_UGC_GenericMobPawn_Base_C
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建GW4_3怪物实例（MonsterID: 334）
local GW4_3 = BaseMonster.New(334, "GW4_3")

return GW4_3
