local utility = {
    Players = game:GetService("Players")
}

utility.disconnect = function(char)
    wait(1)

    if not char then
        return
    end

    local IsRagdoll = char:WaitForChild("IsRagdoll", 1)
    if not IsRagdoll then
        return 
    end

    IsRagdoll:Destroy()

    return warn("destroyed instance")
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then    
        return warn("no get localplayer why")
    end

    self.disconnect(self.LocalPlayer.Character)

    self.LocalPlayer.CharacterAdded:Connect(self.disconnect)

    return warn("success")
end

utility:init()
