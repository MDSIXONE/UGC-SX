--- 模块说明：
--- SingleModeMgr（副本管理器）用于处理关卡副本的初始化逻辑
--- 主要功能：
---   1. 设置副本总时长（FUBEN_TOTAL_TIME = 100秒）
---   2. 遍历所有玩家，设置阵营ID为1（友方阵营）
---   3. 3秒延迟后打印阵营调试信息，用于调试p1伙伴的阵营关系
---
--- 阵营关系说明（GetCampRelationWithActor返回值）：
---   0 = 友方（Friendly） - 可攻击目标或被保护
---   1 = 中立（Neutral） - 无特殊关系
---   2 = 敌对（Enemy） - 可攻击目标
---
---@class SingleModeMgr_C:UGCLevelActorMgr
--Edit Below--
local SingleModeMgr = {}

--[[
函数说明：ReceiveBeginPlay
功能描述：副本启动时初始化
主要逻辑：
  1. 调用父类的ReceiveBeginPlay
  2. 定义副本总时长常量 FUBEN_TOTAL_TIME = 100
  3. 遍历当前关卡所有玩家控制器，获取每个玩家Pawn的TeamID
  4. 将所有玩家的TeamID对应的阵营ID设置为1（友方阵营）
  5. 创建3秒延迟定时器，用于打印p1伙伴的阵营调试信息
--]]
function SingleModeMgr:ReceiveBeginPlay()
    -- 调用父类的ReceiveBeginPlay，确保父类初始化逻辑正常执行
    SingleModeMgr.SuperClass.ReceiveBeginPlay(self)

    -- 副本总时长常量（单位：秒）
    -- 编辑器中TimeOut设置为9999，实际由代码控制副本超时
    local FUBEN_TOTAL_TIME = 100

    -- 遍历当前关卡中所有玩家控制器，设置阵营ID为1（友方）
    -- 阵营ID说明：1 = 友方阵营，与玩家同一阵营
    local AllPCs = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    if AllPCs then
        for _, PC in pairs(AllPCs) do
            local Pawn = PC:K2_GetPawn()
            if Pawn then
                -- 获取当前Pawn的TeamID
                local TeamID = UGCPawnAttrSystem.GetTeamID(Pawn)
                if TeamID and TeamID >= 0 then
                    -- 将该TeamID对应的阵营设置为1（友方）
                    local success = UGCCampSystem.SetCampForTeam(TeamID, 1)
                    -- 调试信息（已注释）：打印阵营设置结果
                    -- ugcprint("[SingleModeMgr] Team " .. tostring(TeamID) .. " camp set to 1, result=" .. tostring(success))
                end
            end
        end
    end

    -- 副本超时逻辑已改为由客户端倒计时控制，不再由服务器定时器管理
    -- （客户端倒计时归零时触发超时）

    -- 创建3秒延迟定时器，用于打印p1伙伴的阵营关系调试信息
    -- 延迟原因：p1伙伴需要时间生成，需要等待其spawn完成后再查询
    UGCTimerUtility.CreateLuaTimer(3.0, function()
        -- 调试信息分隔线（已注释）
        -- ugcprint("[SingleModeMgr] ========== Camp Debug Info ==========")

        -- 尝试获取p1伙伴的类路径
        -- p1伙伴是副本中的AI伙伴单位，用于测试阵营关系
        local p1Class = nil
        local p1ClassPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Monsters/patner/p1.p1_C')
        if p1ClassPath and p1ClassPath ~= "" then
            -- 加载p1的类对象
            p1Class = UGCObjectUtility.LoadClass(p1ClassPath)
        else
            ugcprint("[SingleModeMgr] p1 类路径为空，跳过阵营调试查询")
        end

        -- 获取当前关卡所有玩家控制器
        local PCs = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
        if PCs then
            for _, PC in pairs(PCs) do
                local Pawn = PC:K2_GetPawn()
                if Pawn then
                    -- 获取当前玩家的TeamID和CampID
                    local TeamID = UGCPawnAttrSystem.GetTeamID(Pawn)
                    local CampID = UGCCampSystem.GetCampIDByTeamID(TeamID)
                    -- 打印玩家的TeamID和CampID（已注释）
                    -- ugcprint("[SingleModeMgr] Player TeamID=" .. tostring(TeamID) .. ", CampID=" .. tostring(CampID))

                    -- 查找p1伙伴并打印阵营关系
                    -- 只有在p1Class存在且UGCActorComponentUtility可用时才查询
                    if p1Class and UGCActorComponentUtility and UGCActorComponentUtility.GetAllActorsOfClass then
                        -- 使用pcall包装，防止GetAllActorsOfClass出错导致崩溃
                        local okGetActors, allActorsOrErr = pcall(function()
                            return UGCActorComponentUtility.GetAllActorsOfClass(self, p1Class)
                        end)

                        if okGetActors then
                            local allActors = allActorsOrErr
                            if allActors and #allActors > 0 then
                                -- 遍历所有p1伙伴（理论上应该只有一个）
                                for _, p1Actor in pairs(allActors) do
                                    -- 获取p1的CampID
                                    local p1CampID = UGCCampSystem.GetCampIDByActor(p1Actor)
                                    -- 获取玩家与p1的阵营关系
                                    -- 阵营关系返回值：0=友方，1=中立，2=敌对
                                    local relation = UGCCampSystem.GetCampRelationWithActor(Pawn, p1Actor)
                                    -- 打印p1的CampID和与玩家的阵营关系（已注释）
                                    -- ugcprint("[SingleModeMgr] p1 CampID=" .. tostring(p1CampID) .. ", relation with player=" .. tostring(relation) .. " (0=Friendly/1=Neutral/2=Enemy)")
                                end
                            else
                                -- 未找到p1伙伴（已注释）
                                -- ugcprint("[SingleModeMgr] p1 Actor not found")
                            end
                        else
                            -- 查询p1 actor失败，打印错误信息
                            ugcprint("[SingleModeMgr] 查询 p1 actor 失败: " .. tostring(allActorsOrErr))
                        end
                    end
                end
            end
        end
        -- 调试信息分隔线（已注释）
        -- ugcprint("[SingleModeMgr] =====================================")
    end, false, "CampDebug_Timer")
end

--[[
函数说明：ReceiveTick（已注释禁用）
功能描述：每帧执行逻辑
说明：当前未启用，如需每帧处理可取消注释
--]]
--[[
function SingleModeMgr:ReceiveTick(DeltaTime)
    SingleModeMgr.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
函数说明：ReceiveEndPlay（已注释禁用）
功能描述：副本结束时清理逻辑
说明：当前未启用，如需清理可取消注释
--]]
--[[
function SingleModeMgr:ReceiveEndPlay()
    SingleModeMgr.SuperClass.ReceiveEndPlay(self)
end
--]]

return SingleModeMgr
