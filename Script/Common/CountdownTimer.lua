---@class CountdownTimer
---Shared countdown timer and tip logic used by MMainUI.

local CountdownTimer = {}

function CountdownTimer.ClearTimerSafe(owner, timerHandle, timerName)
    if not timerHandle then
        return
    end

    local okClearTimer, clearTimerErr = pcall(function()
        if UGCGameSystem and UGCGameSystem.ClearTimer then
            UGCGameSystem.ClearTimer(owner, timerHandle)
            return
        end

        if UGCTimerUtility and UGCTimerUtility.StopLuaTimer then
            UGCTimerUtility.StopLuaTimer(timerHandle)
            return
        end

        if UGCTimerUtility and UGCTimerUtility.RemoveLuaTimer then
            UGCTimerUtility.RemoveLuaTimer(timerHandle)
            return
        end

        error("no available timer clear API")
    end)

    if not okClearTimer then
        ugcprint("[CountdownTimer] Failed to clear timer, timer=" .. tostring(timerName) .. ", err=" .. tostring(clearTimerErr))
    end
end

function CountdownTimer.RequestCountdownTimeoutExit(self, reason)
    if self.CountdownExitRequestSent then
        ugcprint("[CountdownTimer] Timeout exit RPC already sent, skip duplicate. reason=" .. tostring(reason))
        return
    end

    if self.CountdownExitRequestPending then
        ugcprint("[CountdownTimer] Timeout exit RPC is pending, skip duplicate. reason=" .. tostring(reason))
        return
    end

    self.CountdownExitRequestPending = true
    self.CountdownExitRequestRetryCount = 0

    local function TryNotify(tag)
        if self.CountdownExitRequestSent then
            self.CountdownExitRequestPending = false
            return
        end

        self.CountdownExitRequestRetryCount = (self.CountdownExitRequestRetryCount or 0) + 1

        local playerController = UGCGameSystem.GetLocalPlayerController()
        if playerController then
            local okRPC, rpcErr = pcall(function()
                UnrealNetwork.CallUnrealRPC(playerController, playerController, "Server_NotifyTimeOutFinish")
            end)

            if okRPC then
                self.CountdownExitRequestSent = true
                self.CountdownExitRequestPending = false
                ugcprint("[CountdownTimer] Timeout exit RPC sent. attempt=" .. tostring(self.CountdownExitRequestRetryCount) .. ", tag=" .. tostring(tag))
                return
            end

            ugcprint("[CountdownTimer] Timeout exit RPC failed. attempt=" .. tostring(self.CountdownExitRequestRetryCount) .. ", tag=" .. tostring(tag) .. ", err=" .. tostring(rpcErr))
        else
            ugcprint("[CountdownTimer] Timeout exit RPC failed: local player controller is nil. attempt=" .. tostring(self.CountdownExitRequestRetryCount) .. ", tag=" .. tostring(tag))
        end

        if (self.CountdownExitRequestRetryCount or 0) >= 3 then
            self.CountdownExitRequestPending = false
            ugcprint("[CountdownTimer] Timeout exit RPC retry limit reached, stop retrying")
            return
        end

        UGCGameSystem.SetTimer(self, function()
            TryNotify("Retry")
        end, 0.8, false)
    end

    TryNotify(reason or "Unknown")
end

function CountdownTimer.StartCountdown(self, totalSeconds)
    ugcprint("[CountdownTimer] StartCountdown called, totalSeconds=" .. tostring(totalSeconds))

    if not self.TextBlock_timeout then
        ugcprint("[CountdownTimer] Error: TextBlock_timeout does not exist")
        return
    end

    self:StopCountdown()

    self.CountdownRemaining = math.max(0, math.floor(tonumber(totalSeconds) or 0))
    self.CountdownTimeoutTriggered = false
    self.CountdownExitRequestPending = false
    self.CountdownExitRequestSent = false
    self.CountdownExitRequestRetryCount = 0
    self.TextBlock_timeout:SetVisibility(ESlateVisibility.SelfHitTestInvisible)

    self:UpdateCountdownText()

    self.CountdownTimerHandle = UGCGameSystem.SetTimer(self, function()
        if self.CountdownTimeoutTriggered then
            self:StopCountdown()
            return
        end

        self.CountdownRemaining = (self.CountdownRemaining or 0) - 1
        if self.CountdownRemaining <= 0 then
            self.CountdownRemaining = 0
            self:UpdateCountdownText()
            self.CountdownTimeoutTriggered = true
            ugcprint("[CountdownTimer] Countdown ended, triggering the timeout exit flow")
            CountdownTimer.RequestCountdownTimeoutExit(self, "CountdownEnded")
            self:ShowTip("时间到了，挑战失败。")

            self:StopCountdown()
        else
            self:UpdateCountdownText()
        end
    end, 1.0, true)

    ugcprint("[CountdownTimer] Countdown started, total duration=" .. tostring(totalSeconds) .. " seconds")
end

function CountdownTimer.UpdateCountdownText(self)
    if not self.TextBlock_timeout then return end
    local remaining = self.CountdownRemaining or 0
    local minutes = math.floor(remaining / 60)
    local seconds = remaining % 60
    local timeStr = string.format("Time remaining until challenge ends: %02d:%02d", minutes, seconds)
    self.TextBlock_timeout:SetText(timeStr)
end

function CountdownTimer.StopCountdown(self)
    if self.CountdownTimerHandle then
        CountdownTimer.ClearTimerSafe(self, self.CountdownTimerHandle, "CountdownTimer")
        self.CountdownTimerHandle = nil
    end
end

function CountdownTimer.ShowTip(self, text)
    if not self.tip then return end
    if self.tip.tiptext then
        self.tip.tiptext:SetText(text)
    end
    self.tip:SetVisibility(ESlateVisibility.Visible)
    if self.NewAnimation_1 then
        self:StopAnimation(self.NewAnimation_1)
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
    end
    if self.TipTimerHandle then
        CountdownTimer.ClearTimerSafe(self, self.TipTimerHandle, "TipTimer")
    end
    self.TipTimerHandle = UGCGameSystem.SetTimer(self, function()
        if self.tip then
            self.tip:SetVisibility(ESlateVisibility.Collapsed)
        end
        self.TipTimerHandle = nil
    end, 2.0, false)
end

function CountdownTimer.ShowTipDuration(self, text, duration)
    if not self.tip then return end
    if self.tip.tiptext then
        self.tip.tiptext:SetText(text)
    end
    self.tip:SetVisibility(ESlateVisibility.Visible)
    if self.NewAnimation_1 then
        self:StopAnimation(self.NewAnimation_1)
        self:PlayAnimation(self.NewAnimation_1, 0, 1, 0, 1)
    end
    if self.TipTimerHandle then
        CountdownTimer.ClearTimerSafe(self, self.TipTimerHandle, "TipDurationTimer")
    end
    self.TipTimerHandle = UGCGameSystem.SetTimer(self, function()
        if self.tip then
            self.tip:SetVisibility(ESlateVisibility.Collapsed)
        end
        self.TipTimerHandle = nil
    end, duration or 2.0, false)
end

return CountdownTimer
