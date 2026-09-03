local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}

function utility:ValidTimeToAttack()
    local s, r = pcall(function()
        local char = self.LocalPlayer.Character
        if not char then 
            return false
        end

        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            return false
        end 

        local Handle = tool:FindFirstChild("Handle")
        if not Handle then 
            return false    
        end 

        local Params = OverlapParams.new()
        Params.ExcludeInstances = {char, tool, Handle}

        local parts = self.Workspace:GetPartsInPart(Handle, Params)
        for _, part in ipairs(parts) do
            if part:IsDescendantOf(self.Workspace.Players) then
                local c = part:FindFirstAncestorOfClass("Model")
                if self.LocalPlayer:GetAttribute("InCutscene") then
                    continue
                end
                local p = self.Players:GetPlayerFromCharacter(c)
                if p:GetAttribute("InCutscene") then
                    continue
                end
                return true
            end
        end 

        return false
    end)

    if s and r then
        return true
    end 

    return false
end 

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    self.Shared = self.ReplicatedStorage:WaitForChild("Shared", 3)
    if not self.Shared then
        return warn('failed to get shared')
    end

    self.Modules = self.Shared:FindFirstChild("Modules")
    if not self.Modules then
        return warn('failed to get modules')
    end
 
    self.NetworkManagerNew = require(self.Modules.NetworkManagerNew)
    if not self.NetworkManagerNew then
        return warn('failed to get NetworkManagerNew')
    end

    self.General = self.NetworkManagerNew.General
    if not self.General then
        return warn('failed to get General')
    end

    self.ToolServiceBasic = self.General.ToolServiceBasic
    if not self.ToolServiceBasic then
        return warn('failed to get ToolServiceBasic')
    end

    self.l = tick()

    self.conn = self.RunService.RenderStepped:Connect(function()
        if self:ValidTimeToAttack() then
            if tick() - self.l >= 0.8 then
                local char = self.LocalPlayer.Character
                if not char then 
                    return
                end

                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    return
                end 

                self.ToolServiceBasic:Fire("ToolActivated", tool, nil)

                print('attack')

                self.l = tick()
            end 
        end
    end)

    if not self.conn then
        return warn("failed to create conn")
    end

    return warn("successful init")
end

utility:init()
