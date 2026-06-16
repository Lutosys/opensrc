local gardens = game.Workspace:WaitForChild("Gardens")
local Networking = require(game:GetService("ReplicatedStorage").SharedModules.Networking)

local OwnerPlot
while OwnerPlot == nil do
    wait(0.1)
    for _, plot in pairs(gardens:GetChildren()) do
        if plot:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
            OwnerPlot = plot
            break
        end
    end
end

local function isGrown(plant)
    local maxAge = plant:GetAttribute("MaxAge")
    local currentAge = plant:GetAttribute("Age")

    if maxAge == nil or currentAge == nil then
        return false
    end

    return currentAge >= maxAge
end

local function getharvestableplants()
    local plants = {}
    local plantsFolder = OwnerPlot:FindFirstChild("Plants")
    
    if not plantsFolder then return plants end

    for _, plant in pairs(plantsFolder:GetChildren()) do
        local fruitsFolder = plant:FindFirstChild("Fruits")
        
        if fruitsFolder then
            for _, fruit in pairs(fruitsFolder:GetChildren()) do
                if fruit:IsA("Model") and isGrown(fruit) then
                    table.insert(plants, fruit)
                end
            end
        else
            if plant:IsA("Model") and isGrown(plant) then
                table.insert(plants, plant)
            end
        end
    end
    return plants
end

local function harvest(plant)
    if not plant then return end
    
    local id = plant:GetAttribute("PlantId")
    local fruitid = plant:GetAttribute("FruitId") or ""
    
    if id then
        Networking.Garden.CollectFruit:Fire(id,fruitid)
    end
end

while wait(0.01) do
    for i,v in pairs(getharvestableplants()) do
        harvest(v)
    end
end
