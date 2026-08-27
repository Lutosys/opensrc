local utility = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
}

function utility:desync(cf, delay)
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end

    self.conn = self.RunService.Heartbeat:Connect(function()
        local char = self.LocalPlayer.Character
        if not char then 
            return
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            return
        end

        local oldcf = hrp.CFrame
        hrp.CFrame = cf

        self.RunService:BindToRenderStep("101", 101, function()
            hrp.CFrame = oldcf
            self.RunService:UnbindFromRenderStep("101")
        end)
    end)

    task.delay(delay, function()
        if self.conn then
            self.conn:Disconnect()
            self.conn = nil
        end
    end)
end

function utility:GetDropoffCFrame()
    local s, r = pcall(function(...)
        local d = self.Dumpsters:QueryDescendants("[$Arrow]")[1]
        return d:GetPivot()
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:Dropoff()
    local s, r = pcall(function(...)
        local dropoff = self:GetDropoffCFrame()
        if not dropoff then return end

        self:desync(dropoff, 0.5)

        task.wait(0.25)

        local char = self.LocalPlayer.Character
        if not char then return end

        local myhrp = char:FindFirstChild("HumanoidRootPart")
        if not myhrp then return end

        self.EmptyBackpack:FireServer()

        return true
    end)

    return s == r
end

function utility:GetAllLeaves()
    local s, r = pcall(function(...)
        return self.Leaves:GetChildren()
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:InventoryFull()
    local s, r = pcall(function(...)
        return self.LocalPlayer:GetAttribute("Leaves") >= self.LocalPlayer:GetAttribute("LeafCapacity")
    end)

    if s and r then
        return r
    end

    return false
end

function utility:CollectLeave(idx)
    pcall(function(...)
        self.CollectLeaf:FireServer(idx)
    end)
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    self.Remotes = self.ReplicatedStorage:FindFirstChild("Remotes")
    if not self.Remotes then
        return warn("Failed to get remotes folder")
    end

    self.CollectLeaf = self.Remotes:FindFirstChild("CollectLeaf")
    if not self.CollectLeaf then
        return warn("Failed to get CollectLeaf remote")
    end

    self.EmptyBackpack = self.Remotes:FindFirstChild("EmptyBackpack")
    if not self.EmptyBackpack then
        return warn("Failed to get Emptybackpack remote")
    end

    self.Map = self.Workspace:FindFirstChild("Map")
    if not self.Map then
        return warn("didnt get map")
    end

    self.Dumpsters = self.Map:FindFirstChild("Dumpsters")
    if not self.Dumpsters then
        return warn("didnt get Dumpsters")
    end

    self.Leaves = self.Workspace:FindFirstChild("Leaves")
    if not self.Leaves then
        return warn("failed to get Leaves")
    end


    task.spawn(function()
        while task.wait(0.01) do
            if not self:InventoryFull() then
                for idx, leave in ipairs(self:GetAllLeaves()) do   
                    if self.LocalPlayer:DistanceFromCharacter(leave.Position) < 10 then 
                        self:CollectLeave(idx, leave)
                        task.wait(0.02)
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.66) do
            if self:InventoryFull() then
                self:Dropoff()
            end
        end
    end)

    return warn('success')
end

utility:init()
