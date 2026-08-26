local utility = {
    dropkick = Instance.new("Animation"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    AnimationClipProvider = game:GetService("AnimationClipProvider"),
    conns = {}
}

utility.dropkick.AnimationId = "rbxassetid://133566007754001"

utility.CheckValidRigType = function(h)
    local s, r = pcall(function(...)
        return h.RigType == Enum.HumanoidRigType.R15
    end)
    if s and r then
        return true
    end
    return false
end

function utility:MouseDetection(a)
    local s, r = pcall(function(...)
        local track = a:LoadAnimation(self.dropkick)
        if not track then return end

        local char = a:FindFirstAncestorOfClass("Model")
        if not char then return end

        local hum = a:FindFirstAncestorOfClass("Humanoid")
        if not hum then return end

        local mouse = self.LocalPlayer:GetMouse()

        if self.conns[mouse.Button1Down] then
            self.conns[mouse.Button1Down]:Disconnect()
            self.conns[mouse.Button1Down] = nil
        end

        self.conns[mouse.Button1Down] = mouse.Button1Down:Connect(function()
            pcall(function(...)
                track:Play()

                local root = char.LeftLowerLeg

                local oldvelocity = root.Velocity

                repeat self.RunService.Heartbeat:Wait()
                    hum.HipHeight = 2.5008
                    local velocity, movel = root.Velocity, 0.1
                    root.Velocity = velocity * 1000000 + Vector3.new(0,1000000,0)

                    self.RunService.RenderStepped:Wait()

                    root.Velocity = velocity

                    self.RunService.Stepped:Wait()

                    root.Velocity = velocity + Vector3.new(0, movel ,0)
                until track.IsPlaying == false

                hum.HipHeight = 2.0008

                root.Velocity = oldvelocity
            end)
        end)
    end)

    if s then
        return "success"
    end

    return r
end

function utility:BeginDropkickHook(char)
    task.wait(1)

    if not char then
        return warn("failed to get valid characher")
    end
    local hum = char:WaitForChild("Humanoid", 1)
    if not hum then
        return warn("Failed to get humanoid")
    end

    if not self.CheckValidRigType(hum) then
        return self.LocalPlayer:Kick("Change avater to r15")
    end

    local animator = hum:WaitForChild("Animator", 1)
    if not animator then 
        return warn("failed to get animator")
    end

    return self:MouseDetection(animator)
end

function utility:init()
    local s, r = pcall(function()
        return self.AnimationClipProvider:GetAnimationClipAsync(self.dropkick.AnimationId)
    end)

    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    if r.Name == nil then
        return self.LocalPlayer:Kick("failed to get animation")
    end 

    self.character = self.LocalPlayer.Character
    if not self.character then
        return warn("failed to get character")
    end

    self:BeginDropkickHook(self.character)

    self.charadded = self.LocalPlayer.CharacterAdded:Connect(function(character)
        self:BeginDropkickHook(character)
    end)
    
    self.Noclip = self.RunService.Stepped:Connect(function(a0: number)
        local char = game.Players.LocalPlayer.Character
        if not char then return end

        for _, child in pairs(char:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide == true then
                child.CanCollide = false
            end
        end
    end)

    if not self.charadded or not self.Noclip then
        return warn("failed to intiliaze charadded/runserviceloop")
    end

    return warn("success")
end

utility:init()
