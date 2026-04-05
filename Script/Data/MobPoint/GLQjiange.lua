---@class GLQjiange_C:BP_UGCMobSpawnerManager_C
--Edit Below--
-- 鏃犲敖鍓戦榿鍒锋€鐞嗗櫒锛堝弬鑰?MOBGLQ 妯″紡锛?
local GLQjiange = {}

-- 鍏ㄥ眬灞傛暟锛堟墍鏈夌帺瀹跺叡浜級
GLQjiange.CurrentFloor = 1

-- mob鏁版嵁琛ㄨ矾寰?
local MobTablePath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/mob.mob')

function GLQjiange:ReceiveBeginPlay()
    GLQjiange.SuperClass.ReceiveBeginPlay(self)
    self:InitData()
    -- ugcprint("[GLQjiange] ReceiveBeginPlay 鍒濆鍖栨垚鍔?)

    -- 璋冭瘯淇℃伅锛堝叏閮╬call鍖呰９锛?
    pcall(function()
        local className = self:GetClass() and self:GetClass():GetName() or "unknown"
        -- ugcprint("[GLQjiange] 鑷韩绫诲悕: " .. className)
    end)

    pcall(function()
        if self.SpawnPoints then
            -- ugcprint("[GLQjiange] SpawnPoints鏁伴噺: " .. self.SpawnPoints:Num())
        else
            -- ugcprint("[GLQjiange] SpawnPoints涓簄il锛堟湭閰嶇疆鍒锋€偣锛?)
        end
    end)

    pcall(function()
        -- ugcprint("[GLQjiange] 鑷韩灞炴€у垪琛?")
        for k, v in pairs(self) do
            -- ugcprint("[GLQjiange]   " .. tostring(k) .. " = " .. tostring(v))
        end
    end)
end

function GLQjiange:InitData()
    if self.bDataInited then return end
    self.bDataInited = true

    -- 浠庡瓨妗ｈ鍙栨渶楂樺眰鏁帮紝浠庝笅涓€灞傚紑濮?
    local savedFloor = 0
    local allPCs = UGCGameSystem.GetAllPlayerController()
    if allPCs then
        for _, pc in pairs(allPCs) do
            local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
            if ps and ps.GameData then
                local f = ps.GameData.PlayerJiangeFloor or 0
                if f > savedFloor then savedFloor = f end
            end
        end
    end
    GLQjiange.CurrentFloor = savedFloor + 1

    self.MobSpawnTimerIndex = 0
    self.MobSpawnedThisWave = false
    -- ugcprint("[GLQjiange] InitData 瀹屾垚锛岃捣濮嬪眰=" .. GLQjiange.CurrentFloor)
end

-- 鏍规嵁灞傛暟鑾峰彇鎬墿閰嶇疆
function GLQjiange:GetMobConfig(floor)
    local config = UGCGameSystem.GetTableDataByRowName(MobTablePath, tostring(floor))
    if config then
        -- ugcprint("[GLQjiange] 璇诲彇鍒扮" .. floor .. "灞傞厤缃? HP=" .. tostring(config.mobhp) .. ", AT=" .. tostring(config.mobat))
    else
        -- ugcprint("[GLQjiange] 鏈壘鍒扮" .. floor .. "灞傞厤缃紝浣跨敤榛樿缂╂斁")
    end
    return config
end

-- 鎬墿鍒峰嚭浜嬩欢
function GLQjiange:OnMobSpawn(Mob)
    self:InitData()
    self.MobSpawnedThisWave = true
    -- ugcprint("[GLQjiange] 鎬墿鍒峰嚭: " .. tostring(Mob))

    local floor = GLQjiange.CurrentFloor or 1
    local config = self:GetMobConfig(floor)

    local hp = 100 * floor
    local at = 10 * floor
    if config then
        hp = config.mobhp or hp
        at = config.mobat or at
    end

    if Mob then
        Mob.MobAttack = at
        -- ugcprint("[GLQjiange] 璁剧疆鎬墿鏀诲嚮鍔? " .. tostring(at))

        self.MobSpawnTimerIndex = (self.MobSpawnTimerIndex or 0) + 1
        local timerName = "GLQjiange_SetHP_" .. tostring(self.MobSpawnTimerIndex)
        local mobRef = Mob
        UGCTimerUtility.CreateLuaTimer(0.2, function()
            -- ugcprint("[GLQjiange] 寤惰繜鍥炶皟锛岃缃€墿灞炴€? timer=" .. timerName)
            local ok, err = pcall(function()
                UGCAttributeSystem.SetGameAttributeValue(mobRef, 'HealthMax', hp)
                UGCAttributeSystem.SetGameAttributeValue(mobRef, 'Health', hp)
            end)
            if ok then
                -- ugcprint("[GLQjiange] 璁剧疆鎴愬姛: HP=" .. tostring(hp))
            else
                -- ugcprint("[GLQjiange] 璁剧疆澶辫触: " .. tostring(err))
            end
        end, false, timerName)
    end
end

-- 鎵€鏈夋€墿姝讳骸
function GLQjiange:OnAllMobDie()
    self:InitData()

    -- 鍏抽敭淇濇姢锛氬鏋滄湰娉㈡病鏈夋€墿鐢熸垚杩囷紝蹇界暐锛堥槻姝㈢┖娉㈡棤闄愬惊鐜級
    if not self.MobSpawnedThisWave then
        -- ugcprint("[GLQjiange] 鏈尝鏈敓鎴愯繃鎬墿锛屽拷鐣nAllMobDie锛堟鏌ヨ摑鍥維pawnPoints閰嶇疆锛?)
        return
    end

    -- ugcprint("[GLQjiange] 绗?" .. GLQjiange.CurrentFloor .. " 灞傛€墿鍏ㄧ伃")
    self.MobSpawnedThisWave = false
    self.IsPausedForSettlement = true

    -- 淇濆瓨鏈€楂樺眰鏁板埌鐜╁瀛樻。
    self:SaveFloorRecord(GLQjiange.CurrentFloor)

    -- 閫氱煡 TriggerBox 寮圭粨绠桿I锛堝弬鑰?example MOBGLQ 妯″紡锛?
    if self.OwnerTriggerBox and self.OwnerTriggerBox.NotifyLevelComplete then
        self.OwnerTriggerBox:NotifyLevelComplete(GLQjiange.CurrentFloor)
    else
        -- ugcprint("[GLQjiange] 璀﹀憡锛歄wnerTriggerBox 涓嶅瓨鍦紝鑷姩缁х画涓嬩竴灞?)
        self:ResumeAfterSettlement()
    end
end

-- 鐜╁鐐瑰嚮缁х画鍚庯紝鍗囧眰骞堕噸鏂板埛鎬?
function GLQjiange:ResumeAfterSettlement()
    GLQjiange.CurrentFloor = GLQjiange.CurrentFloor + 1
    -- ugcprint("[GLQjiange] 缁撶畻瀹屾垚锛屽紑濮嬬 " .. GLQjiange.CurrentFloor .. " 灞?)
    self.IsPausedForSettlement = false

    -- 閫氱煡瀹㈡埛绔洿鏂板眰鏁版樉绀?
    self:NotifyFloorUpdate()

    self:ResetSpawnerManager(true)
    local this = self
    UGCGameSystem.SetTimer(this, function()
        this:StartSpawnerManager()
        this:ResumeSpawnerManager()
        -- ugcprint("[GLQjiange] 绗?" .. GLQjiange.CurrentFloor .. " 灞傚埛鎬凡鍚姩")
    end, 0.5, false)
end

-- 淇濆瓨鏈€楂樺眰鏁板埌鎵€鏈夊尯鍩熷唴鐜╁鐨勫瓨妗?
function GLQjiange:SaveFloorRecord(floor)
    local allPCs = UGCGameSystem.GetAllPlayerController()
    if not allPCs then return end
    for _, pc in pairs(allPCs) do
        local playerState = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        if playerState and playerState.GameData then
            local oldFloor = playerState.GameData.PlayerJiangeFloor or 0
            if floor > oldFloor then
                playerState.GameData.PlayerJiangeFloor = floor
                -- ugcprint("[GLQjiange] 鐜╁鏈€楂樺眰鏁版洿鏂? " .. oldFloor .. " -> " .. floor)
                if playerState.DataSave then
                    playerState:DataSave()
                end
                -- 鏇存柊闂叧灞傛暟鎺掕姒?
                if playerState.UpdateJiangeFloorRank then
                    playerState:UpdateJiangeFloorRank()
                end
            end
        end
        -- 閫氱煡瀹㈡埛绔洿鏂板眰鏁版樉绀?
        UnrealNetwork.CallUnrealRPC(pc, pc, "Client_UpdateJiangeFloor", floor)
    end
end

-- 閫氱煡瀹㈡埛绔洿鏂板眰鏁版樉绀猴紙閫氳繃RPC锛?
-- JiangeFloor 瀛樼殑鏄?宸插畬鎴愮殑鏈€楂樺眰鏁?锛屽鎴风鏄剧ず鏃?+1 琛ㄧず"涓嬩竴灞傝鎵撶殑"
function GLQjiange:NotifyFloorUpdate()
    local allPlayers = UGCGameSystem.GetAllPlayerController()
    if not allPlayers then return end
    for _, pc in pairs(allPlayers) do
        local ps = UGCGameSystem.GetPlayerStateByPlayerController(pc)
        local savedFloor = 0
        if ps and ps.GameData then
            savedFloor = ps.GameData.PlayerJiangeFloor or 0
        end
        UnrealNetwork.CallUnrealRPC(pc, pc, "Client_UpdateJiangeFloor", savedFloor)
    end
end

return GLQjiange
