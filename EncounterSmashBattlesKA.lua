
local Skill1 = game:GetService("ReplicatedStorage"):FindFirstChild("RE"):FindFirstChild("Champions"):FindFirstChild("Construct"):FindFirstChild("Skill1")

local utility = {
    target = nil,
    RunService = cloneref(game:GetService("RunService")),
    Workspace = cloneref(game:GetService("Workspace")),
    Players = cloneref(game:GetService("Players")),
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
}

utility.getclosetplayer = function(self)
    local closetdist = math.huge
    local closet = nil

    for key, plr in pairs(self.Players:GetPlayers()) do
        if plr == self.LocalPlayer then continue end

        local char = plr.Character
        if not char then continue end   

        if char:GetAttribute("Lobby") then
            continue
        end

        local mychar = self.LocalPlayer.Character
        if not mychar then continue end

        if mychar:GetAttribute("Lobby") then
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end    

        local dist = self.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist < 15 and dist < closetdist then
            closetdist = dist 
            closet = char
        end
    end

    return closet
end

utility.Init = function(self)
    self.LocalPlayer = self.Players.LocalPlayer
    self.DamageRequest = self.ReplicatedStorage:WaitForChild("RE"):WaitForChild("DamageRequest")
    self.runconn = self.RunService.RenderStepped:Connect(function(a0: number)
        self.target = self:getclosetplayer()
    end)
    self.Camera = self.Workspace.CurrentCamera

    self.RE = self.ReplicatedStorage:FindFirstChild("RE")
    self.RF = self.ReplicatedStorage:FindFirstChild("RF")

    self.Champions = self.RE:FindFirstChild("Champions")
    self.ChangeChampion = self.RF:FindFirstChild("ChangeChampion")

    self.ChangeChampion:InvokeServer(
        "Construct"
    )

    warn("success")

    while true do
        wait(0.01)
        if self.target then
            local head = self.target:FindFirstChild("Head")
            if not head then
                continue
            end

            self.MyChampion = self.Champions:FindFirstChild(self.LocalPlayer:GetAttribute("Champion"))
            if not self.MyChampion or self.MyChampion.Name ~= "Construct" then
                self.ChangeChampion:InvokeServer(
                    "Construct"
                )
                continue
            end
            self.Skill1 = self.MyChampion:FindFirstChild("Skill1")
            if not self.Skill1 then
                continue
            end
            
            --[[
            local b = buffer.create(2)
            buffer.writeu16(b, 0, 82)

            self.DamageRequest:FireServer(
                b,
                workspace:GetServerTimeNow(),
                CFrame.new(head.CFrame.Position, head.CFrame.Position + self.Camera.CFrame.LookVector),
                self.target
            )

            --]]

            self.Skill1:FireServer(
                self.target,
                CFrame.new(head.CFrame.Position, head.CFrame.Position + self.Camera.CFrame.LookVector),
                0.99,
                workspace:GetServerTimeNow()
            )
        end
    end
end

utility:Init()
