local utility = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

function utility:GetFoods()
    local s, r = pcall(function(...)
        local r = {}

        for _, item in ipairs(self.Items:GetChildren()) do
            if item and item:GetAttribute("RestoreHunger") then
                table.insert(r, item)
            end
        end

        return r
    end)

    if s and r then
        return r
    end

    return {}
end

function utility:GetClosetFood()
    local s, r = pcall(function(...)
        local c = nil
        local cd = math.huge

        for _, food in next, self:GetFoods() do
            local h = food:FindFirstChild("Handle")
            if not h then
                continue
            end

            self.refuel = food:GetAttribute("RestoreHunger")
            self.hunger = self.LocalPlayer:GetAttribute("Hunger") 

            if self.hunger and self.refuel then
                if (self.hunger + self.refuel) > 200 then
                    continue
                end
            end

            local dist = self.LocalPlayer:DistanceFromCharacter(h.Position)
            if dist and dist < cd and dist < 30 then
                cd = dist
                c = food
            end
        end

        return c    
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:Eat(food)
    local s, r = pcall(function(...)
        task.spawn(function()
            return self.RequestConsumeItem:InvokeServer(food)
        end)
    end)

    if s then
        return warn("ate: "..tostring(food))
    end

    return
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    self.RequestConsumeItem = self.ReplicatedStorage:FindFirstChild("RequestConsumeItem", true)
    if not self.RequestConsumeItem then
        return warn("failed to get RequestConsumeItem")
    end

    self.Items = self.Workspace:FindFirstChild("Items")
    if not self.Items then
        return warn("Failed to get items")
    end

    self.l = tick()
    
    self.conn = self.RunService.Heartbeat:Connect(function()
        if tick() - self.l >= 0.1 then
            self.l = tick()
            self.food = self:GetClosetFood()
            if self.food then
                self:Eat(self.food)
            end
        end
    end)

    if not self.conn then
        return warn("failed to create conn")
    end

    return warn("success init")
end

utility:init()
