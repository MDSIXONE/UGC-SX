---@class SingleMode_1_LevelReward_C:UGCLevelReward
--Edit Below--
local SingleMode_1_LevelReward = {}

function SingleMode_1_LevelReward:LuaExecute()
    -- ugcprint("[LevelReward] ========== 鍏冲簳濂栧姳瑙﹀彂 ==========")
    
    -- 鑾峰彇褰撳墠鍏冲崱鍐呯殑鎵€鏈夌帺瀹?
    local AllPlayer = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    
    if AllPlayer and #AllPlayer > 0 then
        -- ugcprint("[LevelReward] 褰撳墠鍏冲崱鐜╁鏁伴噺: " .. tostring(#AllPlayer))
        
        for k, v in pairs(AllPlayer) do
            -- ugcprint("[LevelReward] 鐜╁ " .. tostring(k) .. " 瑙﹀彂鍏冲簳濂栧姳")
            
            -- 鍦ㄦ湇鍔＄鐨?PlayerController 涓繚瀛?LevelRewardActor 寮曠敤
            if v then
                v.CurrentLevelRewardActor = self
                -- ugcprint("[LevelReward] 鍦?PlayerController 涓繚瀛樹簡 LevelRewardActor 寮曠敤")
                
                -- 閫氳繃瀹㈡埛绔疪PC鏄剧ず Settlement UI
                -- ugcprint("[LevelReward] 璋冪敤瀹㈡埛绔疪PC鏄剧ず Settlement UI")
                UnrealNetwork.CallUnrealRPC(v, v, "Client_ShowSettlementUI")
            end
        end
    else
        -- ugcprint("[LevelReward] 璀﹀憡锛氬綋鍓嶅叧鍗℃病鏈夌帺瀹?)
        -- 濡傛灉娌℃湁鐜╁锛岀洿鎺ュ畬鎴?
        self:OnFinish()
    end
    
    -- ugcprint("[LevelReward] 鍏冲簳濂栧姳瑙﹀彂瀹屾垚锛岀瓑寰呯帺瀹剁偣鍑?sure 鎸夐挳")
    -- 娉ㄦ剰锛氫笉鍦ㄨ繖閲岃皟鐢?OnFinish()锛岀瓑寰呯帺瀹剁偣鍑?sure 鎸夐挳鍚庡啀璋冪敤
end

return SingleMode_1_LevelReward
