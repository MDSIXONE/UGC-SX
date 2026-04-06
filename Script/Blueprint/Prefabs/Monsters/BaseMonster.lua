---@class BaseMonster
--通用怪物基类，所有层级怪物都继承此类
local BaseMonster = {}

local UGCGameData = require("Script.Blueprint.UGCGameData")

---创建怪物实例（用于继承）
---@param monsterID number 怪物ID
---@param className string 类名（如 "F1_1"）
---@return table 怪物实例
function BaseMonster.New(monsterID, className)
    local monster = {
        MonsterID = monsterID,
        bIsDead = false,
        tickCount = 0,
        bTunshiShown = false,
        bCanTunshiExp = false,
    }
    
    function monster:ReceiveBeginPlay()
        monster.SuperClass.ReceiveBeginPlay(self)
        
        local monsterConfig = UGCGameData.GetMonsterConfig(self.MonsterID)
        local killExp = monsterConfig and tonumber(monsterConfig.KillExp) or 0
        self.bCanTunshiExp = (killExp > 0)
        if monsterConfig and monsterConfig.MonsterHealth and UGCGameSystem.IsServer(self) then
            local health = monsterConfig.MonsterHealth
            UGCAttributeSystem.SetGameAttributeValue(self, 'HealthMax', health)
            UGCAttributeSystem.SetGameAttributeValue(self, 'Health', health)
        end
    end
    
    function monster:ReceiveTick(DeltaTime)
        monster.SuperClass.ReceiveTick(self, DeltaTime)
        
        if not self.bIsDead then
            return
        end
        
        self.tickCount = (self.tickCount or 0) + 1
        if self.tickCount % 30 ~= 0 then
            return
        end

        -- 不产出经验的怪物不参与吞噬按钮逻辑
        if not self.bCanTunshiExp then
            if self.bTunshiShown then
                local localPlayer = UGCGameSystem.GetLocalPlayerPawn()
                local playerController = localPlayer and localPlayer:GetController()
                if playerController and playerController.MMainUI and playerController.MMainUI.HideTunshi then
                    playerController.MMainUI:HideTunshi()
                end
                self.bTunshiShown = false
            end
            return
        end
        
        local localPlayer = UGCGameSystem.GetLocalPlayerPawn()
        if not localPlayer then
            return
        end
        
        -- 检查玩家是否开启了直接获取经验
        local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(localPlayer)
        local autoTunshiEnabled = false
        if playerState then
            local directExpEnabled = playerState.GameData and playerState.GameData.DirectExpEnabled
            autoTunshiEnabled = (playerState.GameData and playerState.GameData.AutoTunshiEnabled) or (playerState.UGCAutoTunshiEnabled == true)
            if directExpEnabled == nil then
                directExpEnabled = true  -- 默认开启
            end
            
            -- 如果开启了直接获取经验，不显示吞噬按钮
            if directExpEnabled then
                if self.bTunshiShown then
                    local playerController = localPlayer:GetController()
                    if playerController and playerController.MMainUI then
                        if playerController.MMainUI.HideTunshi then
                            playerController.MMainUI:HideTunshi()
                            self.bTunshiShown = false
                        end
                    end
                end
                return
            end
        end
        
        local myLocation = self:K2_GetActorLocation()
        local playerLocation = localPlayer:K2_GetActorLocation()
        local diffX = myLocation.X - playerLocation.X
        local diffY = myLocation.Y - playerLocation.Y
        local diffZ = myLocation.Z - playerLocation.Z
        local distance = math.sqrt(diffX*diffX + diffY*diffY + diffZ*diffZ)
        local hasNearbyPlayer = (distance < 1000)

        --ugcprint("[" .. className .. "] hasNearbyPlayer=" .. tostring(hasNearbyPlayer) .. ", bTunshiShown=" .. tostring(self.bTunshiShown))

        local playerController = localPlayer:GetController()
        if not playerController then
            return
        end

        local mainUI = playerController.MMainUI
        --ugcprint("[" .. className .. "] mainUI=" .. tostring(mainUI))

        if mainUI then
            if hasNearbyPlayer and autoTunshiEnabled then
                if self.bTunshiShown and mainUI.HideTunshi then
                    mainUI:HideTunshi()
                    self.bTunshiShown = false
                end
                if mainUI.TryAutoTunshiConsume then
                    mainUI:TryAutoTunshiConsume()
                end
            elseif hasNearbyPlayer and not self.bTunshiShown then
                if mainUI.ShowTunshi then
                    mainUI:ShowTunshi()
                    self.bTunshiShown = true
                end
            elseif not hasNearbyPlayer and self.bTunshiShown then
                if mainUI.HideTunshi then
                    mainUI:HideTunshi()
                    self.bTunshiShown = false
                end
            end
        end
    end

    function monster:ReceiveEndPlay(EndPlayReason)
        if monster.SuperClass and monster.SuperClass.ReceiveEndPlay then
            monster.SuperClass.ReceiveEndPlay(self, EndPlayReason)
        end

        -- 尸体被系统清理时，兜底隐藏吞噬按钮，避免出现空按钮
        if self.bTunshiShown then
            local localPlayer = UGCGameSystem.GetLocalPlayerPawn()
            local playerController = localPlayer and localPlayer:GetController()
            if playerController and playerController.MMainUI and playerController.MMainUI.HideTunshi then
                playerController.MMainUI:HideTunshi()
            end
            self.bTunshiShown = false
        end

        -- 服务端同步清理死亡列表中的失效引用
        if self:HasAuthority() and UGCGameData.DeadMonsters then
            local newDeadMonsters = {}
            for _, deadMonster in ipairs(UGCGameData.DeadMonsters) do
                if deadMonster and deadMonster ~= self and UGCObjectUtility.IsObjectValid(deadMonster) then
                    table.insert(newDeadMonsters, deadMonster)
                end
            end
            UGCGameData.DeadMonsters = newDeadMonsters
        end
    end
    
    function monster:BPDie(KillingDamage, EventInstigator, DamageCauser, DamageEvent, DamageTypeID)
        self.bIsDead = true
        
        if self:HasAuthority() then
            -- 掉落物品
            self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})
            
            -- 副本积分系统：击杀怪物ID为322的怪物加10分
            if self.MonsterID == 322 and EventInstigator then
                local PlayerState = EventInstigator.PlayerState
                if PlayerState and PlayerState.TeamID then
                    local TeamID = PlayerState.TeamID
                    -- ugcprint("[" .. className .. "] 击杀怪物ID=322，给队伍 " .. tostring(TeamID) .. " 加10分")
                    UGCLevelFlowSystem.LevelAddScore(TeamID, 10)
                else
                    -- ugcprint("[" .. className .. "] 警告：无法获取击杀者的队伍ID")
                end
            end
            
            -- 根据开关决定是否直接给予经验
            local directExpGiven = false
            local monsterConfig = self.MonsterID and UGCGameData.GetMonsterConfig(self.MonsterID) or nil
            local canGainExp = monsterConfig and monsterConfig.KillExp and monsterConfig.KillExp > 0
            self.bCanTunshiExp = (canGainExp == true)

            if canGainExp then
                local killerPawn = nil
                
                -- 尝试从 EventInstigator 获取玩家
                if EventInstigator then
                    killerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(EventInstigator)
                end
                
                -- 如果没有获取到，尝试从 DamageCauser 获取
                if not killerPawn and DamageCauser then
                    local controller = DamageCauser:GetController()
                    if controller then
                        killerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(controller)
                    end
                end
                
                if killerPawn then
                    local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(killerPawn)
                    if playerState then
                        -- 检查直接经验开关
                        local directExpEnabled = playerState.GameData and playerState.GameData.DirectExpEnabled
                        if directExpEnabled == nil then
                            directExpEnabled = true  -- 默认开启
                        end
                        
                        if directExpEnabled and playerState.AddExp then
                            local exp = monsterConfig.KillExp
                            playerState:AddExp(exp)
                            directExpGiven = true
                            --ugcprint("[" .. className .. "] 怪物死亡，直接给予玩家 " .. exp .. " 点经验")
                        else
                            --ugcprint("[" .. className .. "] 怪物死亡，直接经验开关已关闭，需要吞噬获取经验")
                        end
                        
                        -- 击杀计数统一由 UGCGameMode:OnPostBeKilledDS 处理，避免重复累计
                    end
                end
            end
            
            -- 只有可产出经验且未直接发放经验时，才加入死亡列表供吞噬使用
            if canGainExp and not directExpGiven then
                table.insert(UGCGameData.DeadMonsters, self)
            end
        end
    end
    
    return monster
end

return BaseMonster
