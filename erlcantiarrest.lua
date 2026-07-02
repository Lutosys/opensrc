local LocalPlayer = game.Players.LocalPlayer

local function isHandcuffed()
    if LocalPlayer:FindFirstChild("In_Handcuffs") and LocalPlayer.In_Handcuffs.Value ~= LocalPlayer.Name then
        return true
    end
    return false
end

while wait() do
    if isHandcuffed() then
        pcall(function(...)
            game:GetService("ReplicatedStorage").FE.Actions.Environmental:FireServer(100)
            task.defer(function()
                wait(0.1)
                game:GetService("ReplicatedStorage").FE.DeathRespawn:FireServer()
            end)
        end)
    end
end
