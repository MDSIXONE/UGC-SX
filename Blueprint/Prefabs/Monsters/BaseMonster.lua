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
        bTunshiShown = false
    }
    
    function monster:ReceiveBeginPlay()
        monster.SuperClass.ReceiveBeginPlay(self)
        
        local monsterConfig = UGCGameData.GetMonsterConfig(self.MonsterID)
        if monsterConfig and monsterConfig.MonsterHealth then
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
        
        local localPlayer = UGCGameSystem.GetLocalPlayerPawn()
        if not localPlayer then
            return
        end
        
        -- 检查玩家是否开启了直接获取经验
        local playerState = UGCGameSystem.GetPlayerStateByPlayerPawn(localPlayer)
        if playerState then
            local directExpEnabled = playerState.GameData and playerState.GameData.DirectExpEnabled
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
        local allPlayers = UGCGameSystem.GetAllPlayerPawn()
        
        if allPlayers then
            local hasNearbyPlayer = false
            for _, player in pairs(allPlayers) do
                if player then
                    local playerLocation = player:K2_GetActorLocation()
                    local diffX = myLocation.X - playerLocation.X
                    local diffY = myLocation.Y - playerLocation.Y
                    local diffZ = myLocation.Z - playerLocation.Z
                    local distance = math.sqrt(diffX*diffX + diffY*diffY + diffZ*diffZ)
                    
                    if distance < 1000 then
                        hasNearbyPlayer = true
                        break
                    end
                end
            end
            
            --ugcprint("[" .. className .. "] hasNearbyPlayer=" .. tostring(hasNearbyPlayer) .. ", bTunshiShown=" .. tostring(self.bTunshiShown))
            
            local playerController = localPlayer:GetController()
            if not playerController then
                return
            end
            
            local mainUI = playerController.MMainUI
            --ugcprint("[" .. className .. "] mainUI=" .. tostring(mainUI))
            
            if mainUI then
                if hasNearbyPlayer and not self.bTunshiShown then
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
                    ugcprint("[" .. className .. "] 击杀怪物ID=322，给队伍 " .. tostring(TeamID) .. " 加10分")
                    UGCLevelFlowSystem.LevelAddScore(TeamID, 10)
                else
                    ugcprint("[" .. className .. "] 警告：无法获取击杀者的队伍ID")
                end
            end
            
            -- 根据开关决定是否直接给予经验
            local directExpGiven = false
            if self.MonsterID then
                local monsterConfig = UGCGameData.GetMonsterConfig(self.MonsterID)
                if monsterConfig and monsterConfig.KillExp and monsterConfig.KillExp > 0 then
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
                            
                            -- 增加击杀计数（用于任务系统）
                            if playerState.AddKillCount then
                                playerState:AddKillCount()
                            end
                        end
                    end
                end
            end
            
            -- 只有在没有直接给予经验时，才加入死亡列表供吞噬使用
            if not directExpGiven then
                table.insert(UGCGameData.DeadMonsters, self)
            end
        end
    end
    
    return monster
end

return BaseMonster
