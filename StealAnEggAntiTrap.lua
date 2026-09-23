local utility = {
    Workspace = game:GetService("Workspace"),
}

function utility:GetTraps()
    local s, r = pcall(function(...)
        return self.Workspace:QueryDescendants("#PlayerTrap")
    end)

    if s and r then
        return r
    end

    return {}
end

function utility:DestroyTouch(t)
    local s, r = pcall(function(...)
        local temp = t:FindFirstChild("TouchInterest", true)
        
        if not temp then
            return nil
        end

        temp:Destroy()

        return temp
    end)

    if s then
        warn("success disabled trap debugid: "..tostring(t:GetDebugId()))
        
        self.library.newNotification("Anti Trap", "success disabled trap debugid: "..tostring(t:GetDebugId()), "success")
        
        return r
    end

    return warn('failed to destroy err:' ..tostring(r))
end

function utility:Init()
    getgenv().loadstring = loadstring or function()
        return error("loadstring doesnt exist sob")
    end

    self.s, self.library = pcall(function(...)
        return getgenv().loadstring(game:HttpGet('https://raw.githubusercontent.com/Stefanuk12/ROBLOX/refs/heads/master/Universal/Notifications/Script.lua'))()
    end)

    if not self.s then
        return warn("failed to loadstring library url err:"..tostring(self.library))
    end

    for _, t in ipairs(self:GetTraps()) do
        self:DestroyTouch(t)
    end

    self.Workspace.DescendantAdded:Connect(function(c)
        if c.Name == "PlayerTrap" then
            self:DestroyTouch(c)
        end
    end)
    
    return warn("success")
end

utility:Init()
