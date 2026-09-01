local utility = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

utility.GetConnections = function(obj, signal)
    local s, r = pcall(function(...)
        return getconnections(obj[signal])
    end)
    if s and r then
        return r    
    end

    warn("failed to getconnections error: "..tostring(r))

    return nil
end

utility.Disconnect = function(conns)
    local s, r = pcall(function(...)
        local patched = 0

        for _, conn in next, conns do   
            conn:Disconnect()
            patched +=1
        end

        return patched
    end)
    if s and r ~= 0 then
        return warn("patched: "..tostring(r).. " connections")  
    end
    return warn("patched nothing: "..tostring(r))
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    if not getconnections then
        return self.LocalPlayer:Kick("Unsupported executor missing getconnections")
    end

    self.Packages = self.ReplicatedStorage:FindFirstChild("Packages")
    if not self.Packages then
        return warn('failed to get Packages')
    end

    self.Networking = self.Packages:FindFirstChild("Networking")
    if not self.Networking then
        return warn('failed to get Networking')
    end

    self["RE/RigSync/Refresh"] = self.Networking:FindFirstChild("RE/RigSync/Refresh")
    if not self["RE/RigSync/Refresh"] then
        return warn('failed to get RE/RigSync/Refresh')
    end

    self.connections = self.GetConnections(self["RE/RigSync/Refresh"], "OnClientEvent")
    if not self.connections then
        return
    end

    return self.Disconnect(self.connections)
end

utility:init()
