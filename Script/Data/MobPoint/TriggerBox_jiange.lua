---@class TriggerBox_jiange_C:TriggerBox
---@field SpawnerManagers ULuaArrayHelper<AActor>
--Edit Below--
-- 鏃犲敖鍓戦榿瑙﹀彂鐩掞細鐜╁杩涘叆鍚庡欢杩?绉掑惎鍔ㄥ埛鎬紝绂诲紑鏆傚仠娓呴櫎+閲嶇疆灞傛暟
local TriggerBox_jiange = {}

function TriggerBox_jiange:ReceiveBeginPlay()
    TriggerBox_jiange.SuperClass.ReceiveBeginPlay(self)
    self:LuaInit()
end

function TriggerBox_jiange:LuaInit()
    if self.bInitDoOnce then return end
    self.bInitDoOnce = true

    self.PlayersInZone = {}
    self.bSpawnerStarted = false

    self.CollisionComponent.OnComponentBeginOverlap:Add(self.OnBeginOverlap, self)
    self.CollisionComponent.OnComponentEndOverlap:Add(self.OnEndOverlap, self)
    -- ugcprint("[TriggerBox_jiange] 鍒濆鍖栧畬鎴愶紝纰版挒浜嬩欢宸茬粦瀹?)
end

function TriggerBox_jiange:GetPlayerCount()
    local count = 0
    for _ in pairs(self.PlayersInZone or {}) do count = count + 1 end
    return count
end

function TriggerBox_jiange:OnBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not OtherActor or not OtherActor.PlayerState then return end

    self.PlayersInZone[tostring(OtherActor)] = OtherActor
    local count = self:GetPlayerCount()
    -- ugcprint("[TriggerBox_jiange] 鐜╁杩涘叆锛屽綋鍓嶇帺瀹舵暟: " .. count)

    if count == 1 and not self.bSpawnerStarted then
        -- ugcprint("[TriggerBox_jiange] 绗竴涓帺瀹惰繘鍏ワ紝4绉掑悗鍚姩鍒锋€?)
        self.bSpawnerStarted = true
        local this = self
        UGCGameSystem.SetTimer(this, function()
            if this:GetPlayerCount() > 0 then
                -- ugcprint("[TriggerBox_jiange] 寤惰繜4绉掑埌锛屽惎鍔ㄥ埛鎬?)
                this:StartAllSpawners()
            else
                -- ugcprint("[TriggerBox_jiange] 寤惰繜4绉掑埌锛屼絾鐜╁宸茬寮€锛屽彇娑堝埛鎬?)
                this.bSpawnerStarted = false
            end
        end, 4.0, false)
    end
end

function TriggerBox_jiange:StartAllSpawners()
    if not self.SpawnerManagers then
        -- ugcprint("[TriggerBox_jiange] 閿欒锛歋pawnerManagers 涓簄il")
        return
    end

    local count = self.SpawnerManagers:Num()
    -- ugcprint("[TriggerBox_jiange] 寮€濮嬪惎鍔?SpawnerManagers锛屾暟閲? " .. count)
    for i = 1, count do
        local spawner = self.SpawnerManagers:Get(i)
        -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " = " .. tostring(spawner))
        if spawner then
            -- 鍏堟敞鍐孫wnerTriggerBox锛堟渶閲嶈锛屾斁鏈€鍓嶉潰锛?
            spawner.OwnerTriggerBox = self

            -- 鍏堝惎鍔ㄥ埛鎬紙鍏抽敭閫昏緫鏀惧湪璋冭瘯涔嬪墠锛岄槻姝㈣皟璇曞穿婧冨鑷村埛鎬笉鍚姩锛?
            local startOk, startErr = pcall(function()
                spawner:ResetSpawnerManager(true)
                spawner:StartSpawnerManager()
                spawner:ResumeSpawnerManager()
            end)
            if startOk then
                -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 鍚姩瀹屾垚")
            else
                -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 鍚姩澶辫触: " .. tostring(startErr))
            end

            -- 璋冭瘯淇℃伅锛堝叏閮╬call鍖呰９锛屼笉褰卞搷涓婚€昏緫锛?
            pcall(function()
                local className = spawner:GetClass() and spawner:GetClass():GetName() or "unknown"
                -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 绫诲悕: " .. className)
            end)

            pcall(function()
                if spawner.SpawnPoints then
                    local spCount = spawner.SpawnPoints:Num()
                    -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " SpawnPoints鏁伴噺: " .. spCount)
                else
                    -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " SpawnPoints涓簄il")
                end
            end)

            pcall(function()
                if spawner.WaveConfigs then
                    -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " WaveConfigs鏁伴噺: " .. spawner.WaveConfigs:Num())
                else
                    -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " WaveConfigs涓簄il")
                end
            end)

            pcall(function()
                -- ugcprint("[TriggerBox_jiange] SpawnerManager " .. i .. " 灞炴€у垪琛?")
                for k, v in pairs(spawner) do
                    -- ugcprint("[TriggerBox_jiange]   " .. tostring(k) .. " = " .. tostring(v))
                end
            end)
        end
    end
end

function TriggerBox_jiange:OnEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not OtherActor or not OtherActor.PlayerState then return end

    self.PlayersInZone[tostring(OtherActor)] = nil
    local count = self:GetPlayerCount()
    -- ugcprint("[TriggerBox_jiange] 鐜╁绂诲紑锛屽墿浣欑帺瀹舵暟: " .. count)

    if count == 0 and self.bSpawnerStarted then
        -- ugcprint("[TriggerBox_jiange] 鎵€鏈夌帺瀹剁寮€锛屽仠姝㈠埛鎬苟閲嶇疆灞傛暟")
        self.bSpawnerStarted = false
        if self.SpawnerManagers then
            local num = self.SpawnerManagers:Num()
            for i = 1, num do
                local spawner = self.SpawnerManagers:Get(i)
                if spawner then
                    if spawner.PauseSpawnerManager then
                        spawner:PauseSpawnerManager()
                    end
                    if spawner.CleanAllMobs then
                        spawner:CleanAllMobs(true)
                    end
                end
            end
        end
        -- 閲嶇疆灞傛暟涓哄瓨妗ｆ渶楂樺眰+1
        local GLQjiange = require("Script.Data.MobPoint.GLQjiange")
        if GLQjiange then
            local savedFloor = 0
            local allPCs = UGCGameSystem.GetAllPlayerController()
            if allPCs then
                for _, aPC in pairs(allPCs) do
                    local ps = UGCGameSystem.GetPlayerStateByPlayerController(aPC)
                    if ps and ps.GameData then
                        local f = ps.GameData.PlayerJiangeFloor or 0
                        if f > savedFloor then savedFloor = f end
                    end
                end
            end
            GLQjiange.CurrentFloor = savedFloor + 1
            -- ugcprint("[TriggerBox_jiange] 灞傛暟閲嶇疆涓哄瓨妗ｆ渶楂樺眰+1: " .. GLQjiange.CurrentFloor)
        end
        -- 閲嶇疆spawner鐨勫垵濮嬪寲鏍囪锛屼笅娆¤繘鍏ラ噸鏂拌鍙栧瓨妗?
        if self.SpawnerManagers then
            local num = self.SpawnerManagers:Num()
            for i = 1, num do
                local spawner = self.SpawnerManagers:Get(i)
                if spawner then
                    spawner.bDataInited = false
                    spawner.MobSpawnedThisWave = false
                end
            end
        end
    end
end

-- GLQjiange鍥炶皟锛氶€氱煡鍖哄煙鍐呯帺瀹跺脊缁撶畻UI
function TriggerBox_jiange:NotifyLevelComplete(levelNum)
    -- ugcprint("[TriggerBox_jiange] 绗?" .. tostring(levelNum) .. " 灞傚畬鎴愶紝閫氱煡鐜╁寮圭粨绠桿I")

    local playerCount = 0
    for actorKey, pawn in pairs(self.PlayersInZone or {}) do
        playerCount = playerCount + 1
        if pawn then
            local PC = UGCGameSystem.GetPlayerControllerByPlayerPawn(pawn)
            if PC then
                PC.CurrentTriggerBox = self
                -- ugcprint("[TriggerBox_jiange] 鍙戦€丷PC Client_ShowTaSettlementUI, levelNum=" .. tostring(levelNum))
                UnrealNetwork.CallUnrealRPC(PC, PC, "Client_ShowTaSettlementUI", levelNum)
            end
        end
    end

    -- 濡傛灉PlayersInZone涓虹┖锛岄€氱煡鎵€鏈夌帺瀹?
    if playerCount == 0 then
        -- ugcprint("[TriggerBox_jiange] PlayersInZone涓虹┖锛岄€氱煡鎵€鏈夌帺瀹?)
        local allPCs = UGCGameSystem.GetAllPlayerController()
        if allPCs then
            for _, pc in pairs(allPCs) do
                pc.CurrentTriggerBox = self
                UnrealNetwork.CallUnrealRPC(pc, pc, "Client_ShowTaSettlementUI", levelNum)
            end
        end
    end
end

-- 鐜╁鐐瑰嚮缁х画鍚庯紝鎭㈠鍒锋€?
function TriggerBox_jiange:ResumeSpawning()
    -- ugcprint("[TriggerBox_jiange] 鎭㈠鍒锋€?)
    if self.SpawnerManagers then
        local count = self.SpawnerManagers:Num()
        for i = 1, count do
            local spawner = self.SpawnerManagers:Get(i)
            if spawner and spawner.ResumeAfterSettlement then
                spawner:ResumeAfterSettlement()
            end
        end
    end
end

return TriggerBox_jiange
