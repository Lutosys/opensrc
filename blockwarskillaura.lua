--!strict

--// services

local ReplicatedStorage: ReplicatedStorage? = game:GetService("ReplicatedStorage")
if not ReplicatedStorage then
    return warn("failed to get ReplicatedStorage")
end 

local Players: Players? = game:GetService("Players")
if not Players then
    return warn("failed to get Players")
end 

local Workspace = game:GetService("Workspace")
if not Workspace then
    return warn("failed to get Workspace")
end 

--// getting the attack remote

local GameEvents: Instance? = ReplicatedStorage:WaitForChild("GameEvents", 10) 
if not GameEvents then
    return warn("failed to get GameEvents")
end 

local CombatRemotes: Instance? = GameEvents:WaitForChild("CombatRemotes", 10) 
if not CombatRemotes then
    return warn("failed to get CombatRemotes")
end 

local Combat_RequestAttack = CombatRemotes:WaitForChild("Combat_RequestAttack", 10) :: RemoteEvent?
if not Combat_RequestAttack then
    return warn("failed to get Combat_RequestAttack")
end 

--//stuff

local LocalPlayer = Players.LocalPlayer

--// getting players this way since there are bots

local function getPlayers(): {Model}
    local r: {Model} = {}
    for _, bot: Instance in pairs(Workspace:GetChildren()) do
        if bot:IsA("Model") and bot:GetAttribute("TeamId") then
            table.insert(r, bot)
        end
    end
    for _, plr: Player in pairs(Players:GetPlayers()) do
        local char = plr.Character :: Model
        if char then   
            table.insert(r, char)
        end
    end
    return r
end

--// to check for valid tool

local function getHeldTool(): Tool?
    local Tool: Tool?
    local Character: Model? = LocalPlayer.Character
    if not Character then
        Tool = nil
    else
        Tool = Character:FindFirstChildWhichIsA("Tool")
        if not Tool then
            Tool = nil
        end
    end
    return Tool
end

--// main

task.spawn(function()
    while task.wait(0.05) do
        local tool: Tool? = getHeldTool()
        if tool and tool.Name:find("Sword") then
            local myTeam: string = LocalPlayer.Team and LocalPlayer.Team.Name
            
            for _, char: Model in pairs(getPlayers()) do 
                if char.Name:find("BrainBot") then
                    if char:GetAttribute("TeamId") and char:GetAttribute("TeamId") == myTeam then
                        continue
                    end
                end
                local player: Player? = Players:GetPlayerFromCharacter(char) or nil
                if player then
                    if player.Team.Name == myTeam then
                        continue
                    end
                end

                local humanoid: Humanoid? = char:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health == 0 then continue end   

                print("HUm")

                local hrp = char:FindFirstChild("HumanoidRootPart"):: BasePart?
                if not hrp or not hrp:IsA("BasePart") then 
                    continue 
                end  

                if LocalPlayer:DistanceFromCharacter(hrp.Position) < 30 then
                    Combat_RequestAttack:FireServer(tool:GetAttribute("WeaponType") , char)
                end
            end
        end
    end
end)

print("SUCCESS")
