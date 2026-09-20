local utility = {
    Workspace = game:GetService("Workspace")
}

function utility:GetComputers()
    local s, r = pcall(function(...)
        return self.Workspace:QueryDescendants("#ComputerTable")
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:AddHighlight(model)
    local s, r = pcall(function(...)
        local h = Instance.new("Highlight")
        h.Parent = model
        h.FillTransparency = 1        
        h.OutlineColor = Color3.fromRGB(255, 0, 0)  
        h.OutlineTransparency = 0      
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  
        h.Adornee = model     
        return h          
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:init()
    local s, r = pcall(function(...)
        for _, c in ipairs(self:GetComputers()) do
            self:AddHighlight(c)
        end
    end)

    if not s then
        return warn("first init failed err:" ..tostring(r))
    end

    self.s2, self.conn = pcall(function(...)
        local a = self.Workspace.DescendantAdded:Connect(function(d)
            if tostring(d) == "ComputerTable" then
                self:AddHighlight(d)
            end
        end)
        return a
    end)

    if not self.s2 then
        return warn("Failed to create conn err: "..tostring(self.conn))
    end

    return warn("success init")
end

utility:init()
