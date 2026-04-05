---@class CommonTriggerBox_C:TriggerBox
---@field SpawnerManagers ULuaArrayHelper<AActor>
---@field InstanceName string
-- 通用TriggerBox触发盒
-- 可以在编辑器中设置不同的名称，无需创建多个文件
local CommonTriggerBox = {}

function CommonTriggerBox:ReceiveBeginPlay()
    -- 从蓝图属性中获取名称，如果没有设置则使用默认名称
    local instanceName = self.InstanceName or "CommonTriggerBox"
    -- ugcprint("[" .. instanceName .. "] ReceiveBeginPlay 被调用")
    
    CommonTriggerBox.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit(instanceName)
end

function CommonTriggerBox:LuaInit(instanceName)
    -- ugcprint("[" .. instanceName .. "] LuaInit 被调用")
    if self.bInitDoOnce then
        -- ugcprint("[" .. instanceName .. "] 已经初始化过，跳过")
        return
    end
    self.bInitDoOnce = true
    self.instanceName = instanceName
    
    -- 初始化区域内玩家列表
    self.PlayersInZone = {}
    
    -- ugcprint("[" .. instanceName .. "] 开始绑定碰撞事件")
    self.CollisionComponent.OnComponentBeginOverlap:Add(self.CollisionComponent_OnComponentBeginOverlap, self)
    self.CollisionComponent.OnComponentEndOverlap:Add(self.CollisionComponent_OnComponentEndOverlap, self)
    -- ugcprint("[" .. instanceName .. "] 碰撞事件绑定完成")
end

-- 获取区域内玩家数量
function CommonTriggerBox:GetPlayerCount()
    local count = 0
    for _ in pairs(self.PlayersInZone or {}) do
        count = count + 1
    end
    return count
end

function CommonTriggerBox:CollisionComponent_OnComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not OtherActor then return end
    
    local isPlayer = OtherActor.PlayerState ~= nil
    if not isPlayer then return end
    
    local actorKey = tostring(OtherActor)
    self.PlayersInZone[actorKey] = OtherActor
    local playerCount = self:GetPlayerCount()
    -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 玩家进入区域，当前玩家数: " .. playerCount)
    
    if playerCount == 1 then
        if self.SpawnerManagers then
            local count = self.SpawnerManagers:Num()
            -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 检测到第一个玩家，准备恢复 " .. count .. " 个刷怪管理器")
            for i = 1, count do
                local spawner = self.SpawnerManagers:Get(i)
                if spawner and spawner.ResumeSpawnerManager then
                    spawner:ResumeSpawnerManager()
                    -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 恢复刷怪管理器 " .. i)
                else
                    -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 警告：刷怪管理器 " .. i .. " 无效或没有ResumeSpawnerManager方法")
                end
            end
        else
            -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 警告：SpawnerManagers 为空")
        end
    end
end

function CommonTriggerBox:CollisionComponent_OnComponentEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor then return end
    
    local isPlayer = OtherActor.PlayerState ~= nil
    if not isPlayer then return end
    
    local actorKey = tostring(OtherActor)
    self.PlayersInZone[actorKey] = nil
    local playerCount = self:GetPlayerCount()
    -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 玩家离开区域，剩余玩家数: " .. playerCount)
    
    if playerCount == 0 then
        -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 所有玩家离开，暂停并清除怪物")
        if self.SpawnerManagers then
            local count = self.SpawnerManagers:Num()
            for i = 1, count do
                local spawner = self.SpawnerManagers:Get(i)
                if spawner then
                    if spawner.PauseSpawnerManager then
                        spawner:PauseSpawnerManager()
                        -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 暂停刷怪管理器 " .. i)
                    end
                    if spawner.CleanAllMobs then
                        spawner:CleanAllMobs(true)
                        -- ugcprint("[" .. (self.instanceName or "CommonTriggerBox") .. "] 清除刷怪管理器 " .. i .. " 的怪物")
                    end
                end
            end
        end
    end
end

return CommonTriggerBox
