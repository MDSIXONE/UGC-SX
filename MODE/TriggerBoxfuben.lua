---@class TriggerBoxfuben_C:TriggerBox
--Edit Below--
local TriggerBoxfuben = {}

function TriggerBoxfuben:ReceiveBeginPlay()
    TriggerBoxfuben.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit()
end

function TriggerBoxfuben:LuaInit()
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true
    
    ugcprint("[TriggerBoxfuben] LuaInit 被调用")
    
    -- 绑定进入和离开碰撞事件
    self.CollisionComponent.OnComponentBeginOverlap:Add(self.CollisionComponent_OnComponentBeginOverlap, self)
    self.CollisionComponent.OnComponentEndOverlap:Add(self.CollisionComponent_OnComponentEndOverlap, self)
    
    ugcprint("[TriggerBoxfuben] 碰撞事件已绑定")
end

---玩家进入触发盒
function TriggerBoxfuben:CollisionComponent_OnComponentBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not OtherActor then
        return
    end
    
    -- 判断是否是玩家
    local isPlayer = OtherActor.PlayerState ~= nil
    if not isPlayer then
        return
    end
    
    ugcprint("[TriggerBoxfuben] 玩家进入触发盒")
    
    -- 获取玩家控制器
    local playerController = OtherActor:GetPlayerControllerSafety()
    if playerController then
        ugcprint("[TriggerBoxfuben] 获取到玩家控制器，准备显示模式选择UI")
        
        -- 检查是否在客户端
        if not UGCGameSystem.IsServer() then
            ugcprint("[TriggerBoxfuben] 在客户端，打开模式选择UI")
            UGCMultiMode.SetModeChooseUIVisible(true)
        else
            ugcprint("[TriggerBoxfuben] 在服务端，跳过UI显示")
        end
    else
        ugcprint("[TriggerBoxfuben] 无法获取玩家控制器")
    end
end

---玩家离开触发盒
function TriggerBoxfuben:CollisionComponent_OnComponentEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor then
        return
    end
    
    -- 判断是否是玩家
    local isPlayer = OtherActor.PlayerState ~= nil
    if not isPlayer then
        return
    end
    
    ugcprint("[TriggerBoxfuben] 玩家离开触发盒")
    
    -- 获取玩家控制器
    local playerController = OtherActor:GetPlayerControllerSafety()
    if playerController then
        ugcprint("[TriggerBoxfuben] 获取到玩家控制器，准备关闭模式选择UI")
        
        -- 检查是否在客户端
        if not UGCGameSystem.IsServer() then
            ugcprint("[TriggerBoxfuben] 在客户端，关闭模式选择UI")
            UGCMultiMode.SetModeChooseUIVisible(false)
        else
            ugcprint("[TriggerBoxfuben] 在服务端，跳过UI关闭")
        end
    else
        ugcprint("[TriggerBoxfuben] 无法获取玩家控制器")
    end
end

return TriggerBoxfuben