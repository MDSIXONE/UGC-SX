-- 通用GLQ刷怪管理器
-- 可以在编辑器中设置不同的名称，无需创建多个文件
local CommonGLQ = {}

function CommonGLQ:ReceiveBeginPlay()
    -- 从蓝图属性中获取名称，如果没有设置则使用默认名称
    local instanceName = self.InstanceName or "CommonGLQ"
    
    CommonGLQ.SuperClass.ReceiveBeginPlay(self)
    
    -- 使用实例变量而不是模块级变量，避免多个实例互相干扰
    self.CurrentWave = 1
    self.IsResetting = false
    
    self:PauseSpawnerManager()
    --ugcprint("[" .. instanceName .. "] ReceiveBeginPlay 初始化成功，已暂停刷怪")
end

-- 当所有怪物死亡时触发（服务器端）
function CommonGLQ:OnAllMobDie()
    local instanceName = self.InstanceName or "CommonGLQ"
    
    -- 防止重置时重复触发
    if self.IsResetting then
        --ugcprint("[" .. instanceName .. "] 正在重置中，跳过OnAllMobDie")
        return
    end
    self.IsResetting = true
    
    --ugcprint("[" .. instanceName .. "] 第 " .. self.CurrentWave .. " 波怪物全部死亡")
    self.CurrentWave = self.CurrentWave + 1

    -- 重置刷怪管理器
    --ugcprint("[" .. instanceName .. "] 调用 ResetSpawnerManager(true)")
    self:ResetSpawnerManager(true)
    
    -- 延迟0.5秒后重新启动
    local this = self
    UGCGameSystem.SetTimer(this, function()
        --ugcprint("[" .. instanceName .. "] 延迟后调用 StartSpawnerManager()")
        this:StartSpawnerManager()
        --ugcprint("[" .. instanceName .. "] 开始第 " .. this.CurrentWave .. " 波")
        this.IsResetting = false
    end, 0.5, false)
end

return CommonGLQ
