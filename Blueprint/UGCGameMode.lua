---@class UGCGameMode_C:BP_UGCGameBase_C
--Edit Below--
local UGCGameMode = {}

-- 导入必需的模块
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function UGCGameMode:ReceiveBeginPlay()
    UGCGameMode.SuperClass.ReceiveBeginPlay(self)
    
    -- 初始化模式
    if self:HasAuthority() then
        ugcprint("[UGCGameMode] ========== GameMode 开始初始化 ==========")
        
        -- 获取当前模式ID
        local ModeID = UGCMultiMode.GetModeID()
        ugcprint("[UGCGameMode] 当前模式ID: " .. tostring(ModeID))
        
        -- 在副本模式(1002)时初始化关卡流
        if ModeID == 1002 then
            ugcprint("[UGCGameMode] 检测到副本模式1002，准备初始化关卡流")
            self:InitLevelFlow(ModeID)
        else
            ugcprint("[UGCGameMode] 模式 " .. tostring(ModeID) .. "，跳过关卡流初始化")
        end
        
        self:InitMode()
        ugcprint("[UGCGameMode] ========== GameMode 初始化完成 ==========")
    end
end

---初始化关卡流程
---@param ModeID number 模式ID
function UGCGameMode:InitLevelFlow(ModeID)
    ugcprint("[UGCGameMode] 开始初始化关卡流，模式ID: " .. tostring(ModeID))
    
    -- 从数据表获取关卡流管理器路径
    local MgrPath = UGCGameData.GetGameModeActorMgrConfig(ModeID)
    
    if MgrPath and MgrPath ~= "" then
        local fullPath = UGCGameSystem.GetUGCResourcesFullPath(MgrPath)
        ugcprint("[UGCGameMode] 关卡流管理器路径: " .. tostring(fullPath))
        UGCLevelFlowSystem.EnableLevelFlow(fullPath)
        ugcprint("[UGCGameMode] 关卡流初始化完成")
    else
        ugcprint("[UGCGameMode] 警告：模式 " .. tostring(ModeID) .. " 没有配置关卡流管理器")
    end
end

function UGCGameMode:InitMode()
    -- 注册怪物死亡事件监听器
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.MobPawn.PostBeKilled, self, self.OnPostBeKilledDS)
    
    -- 注册玩家离开事件监听器
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerLeave, self, self.OnPlayerLeave)
    
    -- 注册玩家被击败事件监听器
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerPawn.PawnDefeat, self, self.OnPlayerDefeat)
    
    -- 注册玩家复活事件监听器
    UGCGenericMessageSystem.ListenGlobalMessage(self, UGCGenericMessageSystem.Messages.UGC.PlayerPawn.PawnRespawn, self, self.OnPlayerRespawn)
    
    ugcprint("[UGCGameMode] 事件监听器注册完成")
end

-- 玩家被击败时自动复活
function UGCGameMode:OnPlayerDefeat(VictimPlayerKey, InstigatorPlayerKey, DamageType)
    --ugcprint("[UGCGameMode] ========== 玩家被击败事件触发 ==========")
    --ugcprint("[UGCGameMode] 被击败玩家 PlayerKey: " .. tostring(VictimPlayerKey))
    
    if not VictimPlayerKey then
        --ugcprint("[UGCGameMode] 错误：VictimPlayerKey 无效")
        return
    end
    
    --ugcprint("[UGCGameMode] 3秒后复活玩家...")
    UGCGameSystem.RespawnPlayer(VictimPlayerKey, 3.0, true, 0.01)
    --ugcprint("[UGCGameMode] 已调用 RespawnPlayer")
end

-- 玩家复活后恢复属性
function UGCGameMode:OnPlayerRespawn(PlayerKey)
    --ugcprint("[UGCGameMode] ========== 玩家复活事件触发 ==========")
    --ugcprint("[UGCGameMode] 复活玩家 PlayerKey: " .. tostring(PlayerKey))
    
    if not PlayerKey then
        --ugcprint("[UGCGameMode] 错误：PlayerKey 无效")
        return
    end
    
    -- 获取 PlayerState
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerKey(PlayerKey)
    if PlayerState and PlayerState.UpdateClientAttributes then
        --ugcprint("[UGCGameMode] 恢复玩家属性...")
        PlayerState:UpdateClientAttributes()
    end
    
    -- 复活时回满血
    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerKey(PlayerKey)
    if PlayerPawn and UGCObjectUtility.IsObjectValid(PlayerPawn) then
        local maxHealth = UGCAttributeSystem.GetGameAttributeValue(PlayerPawn, 'HealthMax') or 100
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, 'Health', maxHealth)
        --ugcprint("[UGCGameMode] 复活回满血: " .. tostring(maxHealth))
    end
end

-- 玩家离开时保存数据
function UGCGameMode:OnPlayerLeave(PlayerController)
    --ugcprint("[UGCGameMode] ========== 玩家离开事件触发 ==========")
    
    if not PlayerController or not UGCObjectUtility.IsObjectValid(PlayerController) then
        --ugcprint("[UGCGameMode] 错误：PlayerController 无效")
        return
    end
    
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
    if PlayerState and PlayerState.DataSave then
        --ugcprint("[UGCGameMode] 保存玩家数据...")
        PlayerState:DataSave()
    end
end

-- 核心经验获取逻辑
function UGCGameMode:OnPostBeKilledDS(Victim, CauserController)
    --ugcprint("[UGCGameMode] ========== 怪物死亡事件触发 ==========")
    
    if not Victim or not UGCObjectUtility.IsObjectValid(Victim) then
        --ugcprint("[UGCGameMode] 错误：Victim 无效")
        return
    end
    
    if not CauserController or not UGCObjectUtility.IsObjectValid(CauserController) then
        --ugcprint("[UGCGameMode] 错误：CauserController 无效")
        return
    end
    
    if not CauserController:IsPlayerController() then
        --ugcprint("[UGCGameMode] 击杀者不是玩家，忽略")
        return
    end
    
    -- 从配置表获取怪物信息
    local MonsterDetailCfg = UGCGameData.GetMonsterConfig(Victim.MonsterID)
    if not MonsterDetailCfg then
        --ugcprint("[UGCGameMode] 警告：未找到怪物配置 MonsterID=" .. tostring(Victim.MonsterID))
        return
    end
    
    -- 检查玩家的直接经验开关状态
    local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(CauserController)
    if PlayerState then
        local directExpEnabled = PlayerState.GameData and PlayerState.GameData.DirectExpEnabled
        if directExpEnabled == nil then
            directExpEnabled = true  -- 默认开启
        end
        
        if directExpEnabled then
            --ugcprint("[UGCGameMode] 直接经验模式已开启，怪物死亡时会自动给予经验")
        else
            --ugcprint("[UGCGameMode] 直接经验模式已关闭，需要吞噬才能获得经验")
        end
        
        -- 增加击杀计数（用于任务系统）
        if PlayerState.AddKillCount then
            PlayerState:AddKillCount()
            --ugcprint("[UGCGameMode] 已增加击杀计数")
        end
    end
end

return UGCGameMode
