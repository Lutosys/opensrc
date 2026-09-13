local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    hooks = {}
}

function utility:GetEvent(event)
    local s, r = pcall(function(...)
        return self.ReplicatedStorage:FindFirstChild(event, true)        
    end)

    if s and r then
        return r
    end

    return warn("failed to get "..event.. " reason: "..tostring(r))
end

function utility:ShouldRagdollRequest()
    local s, r = pcall(function(...)
        return self.LocalPlayer.Character:GetAttribute("Ragdolling")
    end)

    if s and r then
        return true
    end

    return false
end

function utility:safemetahook(obj, methamethod, call)
    local s, r = pcall(function(...)
        self.hooks[methamethod] = hookmetamethod(obj, methamethod, call)
        return self.hooks[methamethod]
    end)
    if s and r then
        return r
    end
    return warn('failed to hookmetamethod: '..tostring(r))
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    if not hookmetamethod then
        return self.LocalPlayer:Kick("unsupport executor missing hookmetamethod")
    end

    self.Dismember = self:GetEvent("Dismember")
    if not self.Dismember then
        return
    end

    self.RagdollRequest = self:GetEvent("Ragdoll_Request")
    if not self.RagdollRequest then
        return
    end

    self:safemetahook(game, "__namecall", function(...)
        local s = select(1, ...)
        if s and rawequal(s, self.Dismember) then
            return warn('attempt to dismember')
        end
        if getnamecallmethod() == "ChangeState" then
            if select(2, ...) and select(2, ...) == Enum.HumanoidStateType.Physics then
                return warn('attempted to change state to physics')
            end
        end
        return self.hooks["__namecall"](...)
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if self:ShouldRagdollRequest() then
                warn("unragdolling")
                self.RagdollRequest:FireServer()
            end
        end
    end)

    return warn("Success init")
end

utility:init()
