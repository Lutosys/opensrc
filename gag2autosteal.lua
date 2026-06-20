local function safeRequire(module)
    local success, result = pcall(function()
        return require(module)
    end)

    if not success then
        warn("error requiring module: "..tostring(module).. " got error: "..tostring(result))
        return nil
    end

    return result
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
if not ReplicatedStorage then
    warn("Couldnt get reference to ReplicatedStorage")
    return
end

local Players = game:GetService("Players")
if not Players then
    warn("Couldnt get reference to Players")
    return
end

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules", 10)
if not SharedModules then
    warn("Couldnt get SharedModules folder")
    return
end

local Networking = SharedModules:WaitForChild("Networking", 10)
if not Networking then
    warn("Couldnt get Networking")
    return
end

local Flags = SharedModules:WaitForChild("Flags", 10)
if not Flags then
    warn("Couldnt get Flags")
    return
end

local StealFlags = Flags:WaitForChild("StealFlags", 10)
if not StealFlags then
    warn("Couldnt get StealFlags")
    return
end

local FruitValueCalc = SharedModules:WaitForChild("FruitValueCalc", 10)
if not FruitValueCalc then
    warn("Couldnt get FruitValueCalc")
    return
end

local NetworkModule = safeRequire(Networking)
local StealFlagsModule = safeRequire(StealFlags)
local FruitValueCalcModule = safeRequire(FruitValueCalc)

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("LocalPlayer is nil")
    return
end

local Gardens = workspace:WaitForChild("Gardens", 10)
if not Gardens then
    warn("Couldnt get Gardens")
    return
end

local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts", 10)
if not PlayerScripts then
    warn("PlayerScripts is nil")
    return
end

local Controllers = PlayerScripts:WaitForChild("Controllers", 10)
if not Controllers then
    warn("Controllers is nil")
    return
end

local PlantLifecycleHandler = Controllers:WaitForChild("PlantLifecycleHandler", 10)
if not PlantLifecycleHandler then
    warn("PlantLifecycleHandler is nil")
    return
end

local PlantCycleModule = safeRequire(PlantLifecycleHandler)
if not PlantCycleModule then
    warn("PlantCycleModule failed to load")
    return
end

local RunService = game:GetService("RunService")
if not RunService then
    warn("RunService is nil")
    return
end

local Night = ReplicatedStorage:WaitForChild("Night", 10)
if not Night then
    warn("Night is nil")
end

local OwnerPlot
local startTime = tick()
local timeout = 30

while OwnerPlot == nil and tick() - startTime < timeout do
    task.wait(0.1)
    pcall(function()
        for _, plot in pairs(Gardens:GetChildren()) do
            if plot and plot:GetAttribute("Owner") == LocalPlayer.Name then
                OwnerPlot = plot
                break
            end
        end
    end)
end

if not OwnerPlot then
    warn("owner plot not found after timeout")
    return
end

local function canSteal(player)
    if not player then
        return false
    end

    local suc, result = pcall(function()
        return player:GetAttribute("IsInOwnGarden")
    end)

    if not suc then
        warn("Error occurred: "..tostring(result))
        return false
    end
    
    return result or false
end

local function teleportto(hrp, startCFrame, targetCFrame, speed)
    if not targetCFrame or typeof(targetCFrame) ~= "CFrame" then
        warn("TARGETCFRAME: You passed something that isnt a CFrame")
        return
    end

    if not startCFrame or typeof(startCFrame) ~= "CFrame" then
        warn("startCFrame: You passed something that isnt a CFrame")
        return
    end

    if not hrp or typeof(hrp) ~= "Instance" then
        warn("hrp: You passed something that isnt an Instance")
        return
    end

    if not speed or typeof(speed) ~= "number" or speed <= 0 then
        warn("SPEED: You passed something that isnt a valid number")
        return
    end

    local distance = (targetCFrame.Position - startCFrame.Position).Magnitude
    local duration = distance / speed
    local con
    local elp = 0

    pcall(function()
        con = RunService.RenderStepped:Connect(function(dt)
            pcall(function()
                elp = elp + dt
                
                if elp >= duration then
                    if hrp and hrp.Parent ~= nil then
                        hrp.CFrame = targetCFrame
                    end
                    if con then
                        con:Disconnect()
                    end
                    return
                end

                local alpha = elp / duration

                if hrp and hrp.Parent ~= nil then
                    hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
                else
                    warn("You respawned during a steal!")
                    if con then
                        con:Disconnect()
                    end
                    return
                end
            end)
        end)
    end)

    if not con then
        warn("Failed to create teleport connection")
        return
    end

    local waitStart = tick()
    while con.Connected and tick() - waitStart < duration + 2 do
        task.wait()
    end

    if con.Connected then
        pcall(function()
            con:Disconnect()
        end)
    end
end

local function isNightTime()
    if not Night then
        return false
    end

    local success, isBool = pcall(function()
        return Night:IsA("BoolValue")
    end)

    if not success or not isBool then
        return false
    end

    return Night.Value == true
end

local function getDecay(model)
    if not PlantCycleModule then
        warn("PlantCycleModule not loaded")
        return 0
    end

    local success, Entries = pcall(function()
        return PlantCycleModule:GetActiveEntries()
    end)

    if not success or not Entries or typeof(Entries) ~= "table" then
        warn("Entries is not a table or failed to get")
        return 0
    end

    if not model or not model:IsA("Model") then
        warn("Arg you passed is not a model")
        return 0
    end

    for plantid, planttable in pairs(Entries) do
        local found = false
        local decayValue = 0
        
        pcall(function()
            if planttable and planttable.Model and planttable.Model == model then
                local a, b = string.match(plantid, "^(%d+)_(.+)$")
                if a and b then
                    local decaySuccess, decay = pcall(function()
                        return PlantCycleModule:GetDecayAlpha(tonumber(a), b)
                    end)
                    if decaySuccess then
                        decayValue = decay or 0
                        found = true
                    end
                end
            end
        end)

        if found then
            return decayValue
        end
    end

    return 0
end

local function getBestPlant()
    local best
    local bestnumber = -1

    local GardenChildren = Gardens:GetChildren()
    if not GardenChildren or typeof(GardenChildren) ~= "table" then
        warn("GardenChildren is not a table")
        return best, bestnumber
    end

    for _, plot in pairs(GardenChildren) do
        if plot and plot:IsA("Model") then
            local Plants = plot:FindFirstChild("Plants")
            if Plants then
                local PlantsChildren = Plants:GetChildren()
                if PlantsChildren and typeof(PlantsChildren) == "table" then
                    for _, model in pairs(PlantsChildren) do
                        if model and model:IsA("Model") then
                            local Fruits = model:FindFirstChild("Fruits")
                            if Fruits then
                                local FruitsChildren = Fruits:GetChildren()
                                if FruitsChildren and typeof(FruitsChildren) == "table" then
                                    for _, fruit in pairs(FruitsChildren) do
                                        if fruit and fruit:IsA("Model") then
                                            local seedName = model:GetAttribute("SeedName") or model:GetAttribute("CorePartName")
                                            if seedName then
                                                local plantid = model:GetAttribute("PlantId")
                                                if plantid then
                                                    if StealFlagsModule and StealFlagsModule.IsPlantStealable then
                                                        local valid = StealFlagsModule.IsPlantStealable(seedName)
                                                        if valid then
                                                            local targetuserid = model:GetAttribute("UserId")
                                                            if targetuserid then
                                                                local targetplayer = Players:GetPlayerByUserId(tonumber(targetuserid))
                                                                if targetplayer then
                                                                    if not canSteal(targetplayer) then
                                                                        local mutation = fruit:GetAttribute("Mutation") or ""
                                                                        local sizeMultiplier = fruit:GetAttribute("SizeMulti") or 1
                                                                        local decayAlpha = getDecay(model)
                                                                        
                                                                        if FruitValueCalcModule then
                                                                            local calcSuccess, value = pcall(function()
                                                                                return FruitValueCalcModule(
                                                                                    seedName,
                                                                                    sizeMultiplier,
                                                                                    mutation,
                                                                                    LocalPlayer,
                                                                                    decayAlpha
                                                                                )
                                                                            end)
                                                                            
                                                                            if calcSuccess and value and value > bestnumber then
                                                                                bestnumber = value
                                                                                best = model
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    else
                                                        warn("StealFlags module not properly loaded")
                                                        return best, bestnumber
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return best, bestnumber
end

local function performSteal(model)
    if not isNightTime() then
        warn("Only execute when its night")
        return 
    end

    if not model then
        warn("There are no stealable plants")
        return
    end

    local ownerId = tonumber(model:GetAttribute("UserId"))
    if not ownerId then
        warn("Owner ID couldnt be grabbed from attribute.")
        return
    end

    local plantId = model:GetAttribute("PlantId")
    if not plantId or type(plantId) ~= "string" then
        warn("Plant ID couldnt be grabbed from attribute.")
        return
    end

    local fruitId = model:GetAttribute("FruitId") or ""
    if type(fruitId) ~= "string" then
        warn("Fruit ID couldnt be grabbed from attribute.")
        return
    end
    
    local char = LocalPlayer.Character
    if not char then
        warn("couldnt get character")
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        warn("couldnt get humanoidrootpart")
        return
    end

    local plotsizeref = OwnerPlot:FindFirstChild("PlotSizeReference")
    if not plotsizeref then 
        warn("Couldnt get dropoff loc")
        return
    end
    
    local oldPos = plotsizeref.CFrame

    local basePart = model:FindFirstChildWhichIsA("BasePart")
    if not basePart then
        warn("Couldnt find BasePart in model")
        return
    end
    
    local target = basePart.CFrame + Vector3.new(0, 3, 0)

    teleportto(hrp, oldPos, target, 33.8)

    task.wait(1)

    if NetworkModule and NetworkModule.Steal then
        if NetworkModule.Steal.BeginSteal then
            NetworkModule.Steal.BeginSteal:Fire(ownerId, plantId, fruitId)
        end
        if NetworkModule.Steal.CompleteSteal then
            NetworkModule.Steal.CompleteSteal:Fire()
        end
    else
        warn("Network module not properly loaded")
        teleportto(hrp, target, oldPos, 33.8)
        return
    end

    task.wait(1)

    teleportto(hrp, target, oldPos, 33.8)
end

local success, err = pcall(function()
    local best, bestnumber = getBestPlant()
    
    if best then
        performSteal(best)
    else
        warn("No valid plants to steal. Best number: " .. tostring(bestnumber))
    end
end)

if not success then
    warn("failed: " .. tostring(err))
end
