local utility = {
    Players = cloneref(game:GetService("Players")),
    VirtualInputManager = cloneref(Instance.new("VirtualInputManager")),
}

function utility:SafeWait()
    pcall(function()
        repeat 
            task.wait()
        until self.LocalPlayer.Character ~= nil
        repeat 
            task.wait()
        until self.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil
        repeat 
            task.wait()
        until self.LocalPlayer.Character:FindFirstChild("Head") ~= nil
        repeat 
            task.wait()
        until self.LocalPlayer.Character:FindFirstChild("Humanoid") ~= nil
    end)
end

function utility:IsHoldingWeight()
    local s, r = pcall(function(...)
        self:SafeWait()

        return self.LocalPlayer.Character:FindFirstChild("Weight")
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:GetWeightTool()
    local s, r = pcall(function(...)
        self:SafeWait()

        local weight = self.LocalPlayer.Character:FindFirstChild("Weight")
        if weight then
            return weight
        end

        self.Backpack = self.LocalPlayer.Backpack
        if self.Backpack then
            return self.Backpack:FindFirstChild("Weight")
        end
        
        return nil
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get LocalPlayer")
    end

    self.Backpack = self.LocalPlayer.Backpack
    if not self.Backpack then
        return warn("failed to get Backpack")
    end

    self.muscleEvent = self.LocalPlayer:FindFirstChild("muscleEvent")
    if not self.muscleEvent then
        return warn("failed to get muscleEvent")
    end

    task.spawn(function()
        while task.wait(0.1) do 
            if self:IsHoldingWeight() then
                self.muscleEvent:FireServer("rep")
                continue
            end

            local Weight = self:GetWeightTool()
            if Weight then
                Weight.Parent = self.LocalPlayer.Character
            end
        end
    end)


    task.spawn(function()
        while task.wait(180) do 
            self.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            self.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)


    return warn("success")
end

utility:init()
