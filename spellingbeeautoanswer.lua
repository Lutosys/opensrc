local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    log = {},
}

utility.blacklist = {
    "rbxassetid://12222253",
    "rbxassetid://17628156770",
    "rbxassetid://105021424858998",
    "rbxassetid://95612104164800",
    "rbxassetid://17619822633",
    "rbxassetid://94474124409510",
    "rbxassetid://17628228607",
    "rbxassetid://17628141406",
    "rbxassetid://17619877976",
    "rbxassetid://17682310784",
    "rbxassetid://17619555286"
}

utility.getcleanstring = function(str)
    return str:gsub("[^%w]", "")
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed")
    end

    if not hookfunction then
        return self.LocalPlayer:Kick("bad executor no hookfunction")
    end

    self.Events = self.ReplicatedStorage:WaitForChild("Events")
    if not self.Events then
        return warn("failed")
    end
    self.PlaySounds = self.Events:WaitForChild("PlaySound")
    if not self.PlaySounds then
        return warn("failed")
    end
    self.PlayerText = self.Events:FindFirstChild("PlayerText")
    if not self.PlayerText then
        return warn("failed")
    end
    self.OnPlaySound = getconnections(self.PlaySounds.OnClientEvent)[1].Function
    if not self.OnPlaySound then
        return warn("failed")
    end

    self.SoundHook = hookfunction(self.OnPlaySound, function(p1, p2, p3, p4, p5)
        task.spawn(function()
            if table.find(self.blacklist, tostring(p2)) then
                return
            end

            local audioplayer = Instance.new("AudioPlayer")
            audioplayer.AssetId = tostring(p2)
            audioplayer.Parent = workspace
            
            local stt = Instance.new("AudioSpeechToText")
            stt.Enabled = true
            stt.Parent = workspace

            local wire = Instance.new("Wire")
            wire.SourceInstance = audioplayer
            wire.TargetInstance = stt
            wire.Parent = stt

            audioplayer:Play()

            stt:GetPropertyChangedSignal("Text"):Connect(function(...)
                if not stt.Text:lower():find("spell") then
                    table.insert(self.log, stt.Text)    
                end
            end)
        end)    
        
        return self.SoundHook(p1, p2, p3, p4, p5)
    end)

    if not self.SoundHook then
        return warn("failed")
    end

    task.spawn(function()
        while task.wait() do
            if #self.log > 0 then
                task.wait(0.5)
                local textToProcess = self.log[1]
                local cleananswer = self.getcleanstring(textToProcess)
                local new = ""
                for letter in cleananswer:gmatch(".") do
                    task.wait(math.random(1, 10) / 100)
                    new = new .. letter
                    self.PlayerText:FireServer(
                        new,
                        workspace:GetServerTimeNow(),
                        false
                    )
                end
                
                task.wait(math.random() * 0.1 + 0.1)
                self.PlayerText:FireServer(
                    new,
                    workspace:GetServerTimeNow(),
                    true
                )

                table.clear(self.log)
            end
        end
    end)

    return warn("success")
end

utility:init()
