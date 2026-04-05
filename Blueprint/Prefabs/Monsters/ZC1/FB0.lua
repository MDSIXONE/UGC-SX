---@class FB0_C:BP_UGC_GenericStaticMeshMob_C
---@field StaticMesh UStaticMeshComponent
---@field HitBox UCapsuleComponent
--Edit Below--
local BaseMonster = require("Script.Blueprint.Prefabs.Monsters.BaseMonster")

-- 创建FB0怪物实例（MonsterID: 100）
local FB0 = BaseMonster.New(100, "FB0")

return FB0
