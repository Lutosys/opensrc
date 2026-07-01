game:GetService("RunService").RenderStepped:Connect(function()
    for _, conn in ipairs(getconnections(game:GetService("ScriptContext").Error)) do
        conn:Disable()
    end
end)

local Rayfield
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

local Window
if Rayfield then
    pcall(function()
        Window = Rayfield:CreateWindow({
            Name = "Vehicle Tyre Popper",
            Icon = 0,
            LoadingTitle = "Vehicle Tyre Popper",
            LoadingSubtitle = "by dawid",
            Theme = "Default",
        })
    end)
end

local Tabs = {}
if Window then
    pcall(function()
        Tabs.Main = Window:CreateTab("Main", 4483362458)
    end)
end

local VehicleDropdown = nil
local currentVehicles = {}
local targetRemote = nil
local hasGotten = false

local function getVehicles()
    local success, result = pcall(function()
        local tbl = {}
        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then return tbl end

        for _, v in next, vehiclesFolder:GetChildren() do
            pcall(function()
                local driverSeat = v:FindFirstChild("DriverSeat")
                if driverSeat then
                    local occupant = driverSeat.Occupant
                    if occupant and occupant.Parent then
                        local player = game.Players:GetPlayerFromCharacter(occupant.Parent)
                        if player then
                            table.insert(tbl, player.Name)
                        end
                    end
                end
            end)
        end
        return tbl
    end)
    
    if success and result then
        currentVehicles = result
        return result
    else
        return {}
    end
end

local function updateDropdown()
    pcall(function()
        local vehicles = getVehicles()
        if VehicleDropdown and VehicleDropdown.Refresh then
            pcall(function()
                VehicleDropdown:Refresh(vehicles)
            end)
        end
    end)
end

local function getVehicleByName(name)
    local success, result = pcall(function()
        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then return nil end

        for _, v in next, vehiclesFolder:GetChildren() do
            local foundVehicle = nil
            pcall(function()
                local driverSeat = v:FindFirstChild("DriverSeat")
                if driverSeat then
                    local occupant = driverSeat.Occupant
                    if occupant and occupant.Parent then
                        local player = game.Players:GetPlayerFromCharacter(occupant.Parent)
                        if player and player.Name == name then
                            foundVehicle = v
                        end
                    end
                end
            end)
            if foundVehicle then return foundVehicle end
        end
        return nil
    end)
    return success and result or nil
end
local hasNotified = false

local function popTiresOnVehicle(vehicle)
    pcall(function()
        if not targetRemote or not vehicle then return end
        task.spawn(function()
            pcall(function()
                local wheels = vehicle:FindFirstChild("Wheels")
                if not wheels then return end
                
                for _, wheel in next, wheels:GetChildren() do
                    pcall(function()
                        if wheel and wheel.CanCollide == true then
                            local targetPart = wheel:FindFirstChild("Base")
                            if targetPart and targetPart:IsA("BasePart") then
                                pcall(function()
                                    local arg = {
                                        Normal = Vector3.new(0,0,-1),
                                        Instance = targetPart,
                                        Position = targetPart.Position
                                    }
                                    
                                    local t3 = {{targetPart, 1}}
                                    
                                    targetRemote:FireServer({
                                        "5.56x45mm",          
                                        Vector3.zero,  
                                        Vector3.zero,
                                        Vector3.new(0,0,0),    
                                        arg,                   
                                        t3                    
                                    })
                                end)

                                task.defer(function()
                                    if not hasNotified then
                                        hasNotified = true
                                        wait(1)
                                        pcall(function()
                                            local FE = game:GetService("ReplicatedStorage").FE
                                            FE.Weapons.ForceReload:Fire()
                                            FE.Weapons.UpdateHUD:Fire()
                                            Rayfield:Notify({
                                                Title = "Reload",
                                                Content = "Your weapon is reloading now",
                                                Duration = 2
                                            })
                                            task.defer(function()
                                                wait(5)
                                                Rayfield:Notify({
                                                    Title = "Reload",
                                                    Content = "Your weapon should have reloaded",
                                                    Duration = 2
                                                })
                                                hasNotified = false
                                            end)
                                        end)
                                    end
                                end)
                                task.wait(0.15)
                            end
                        end
                    end)
                end
            end)
        end)
    end)
end

if Tabs.Main then
    pcall(function()
        Tabs.Main:CreateSection("Vehicle Controls")
    end)

    pcall(function()
        VehicleDropdown = Tabs.Main:CreateDropdown({
            Name = "Select Vehicle",
            Options = getVehicles(),
            CurrentOption = {},
            MultipleOptions = false,
            Flag = "VehicleDropdown",
            Callback = function(Options) end,
        })
    end)

    pcall(function()
        Tabs.Main:CreateButton({
            Name = "Refresh Vehicles",
            Callback = function()
                pcall(function()
                    updateDropdown()
                    if Rayfield then
                        pcall(function()
                            Rayfield:Notify({
                                Title = "Refreshed",
                                Content = "Vehicle list updated!",
                                Duration = 2
                            })
                        end)
                    end
                end)
            end,
        })
    end)

    pcall(function()
        Tabs.Main:CreateButton({
            Name = "Pop All Tyres (Selected)",
            Callback = function()
                pcall(function()
                    local currentOpt = VehicleDropdown and VehicleDropdown.CurrentOption
                    local playerName = type(currentOpt) == "table" and currentOpt[1] or type(currentOpt) == "string" and currentOpt or nil
                    
                    if not playerName or playerName == "" then
                        if Rayfield then
                            pcall(function()
                                Rayfield:Notify({
                                    Title = "Error",
                                    Content = "No vehicle selected!",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    local vehicle = getVehicleByName(playerName)
                    if not vehicle then
                        if Rayfield then
                            pcall(function()
                                Rayfield:Notify({
                                    Title = "Error",
                                    Content = "Vehicle not found!",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    if not targetRemote then 
                        if Rayfield then
                            pcall(function()
                                Rayfield:Notify({
                                    Title = "Remote not retrieved",
                                    Content = "Please spawn a car or shoot once to retrieve the remote.",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    task.spawn(function()
                        pcall(function()
                            popTiresOnVehicle(vehicle)
                        end)
                    end)
                end)
            end,
        })
    end)

    pcall(function()
        Tabs.Main:CreateButton({
            Name = "Pop All Tyres (ALL Vehicles)",
            Callback = function()
                pcall(function()
                    if not targetRemote then 
                        if Rayfield then
                            pcall(function()
                                Rayfield:Notify({
                                    Title = "Remote not retrieved",
                                    Content = "Please spawn a car or shoot once to retrieve the remote.",
                                    Duration = 3
                                })
                            end)
                        end
                        return
                    end
                    
                    pcall(function()
                        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
                        if not vehiclesFolder then return end
                        
                        for _, vehicle in next, vehiclesFolder:GetChildren() do
                            pcall(function()
                                popTiresOnVehicle(vehicle)
                            end)
                        end
                    end)
                end)
            end,
        })
    end)
end

task.spawn(function()
    while task.wait(5) do
        pcall(updateDropdown)
    end
end)

if Rayfield then
    pcall(function()
        Rayfield:LoadConfiguration()
    end)
end

pcall(function()
    for _, v in next, getgc(true) do
        pcall(function()
            if type(v) == "table" then
                if rawget(v, "getRemote") then
                    local old
                    old = hookfunction(v.getRemote, function(name)
                        local result
                        pcall(function()
                            result = old(name)
                        end)
                        
                        pcall(function()
                            if not hasGotten then
                                task.defer(function()
                                    pcall(function()
                                        targetRemote = old("Weapons.ReplicateProjectile")
                                        if targetRemote then
                                            hasGotten = true
                                        end
                                    end) 
                                end)
                            end
                        end)
                        return result
                    end)
                end
            end
        end)
    end
end)

task.spawn(function()
    while not targetRemote do 
        task.wait(0.5) 
    end
    if Rayfield then
        pcall(function()
            Rayfield:Notify({
                Title = "Remote retrieved!",
                Content = "Hold a gun and press Pop All Tyres to pop tires!",
                Duration = 3
            })
        end)
    end
end)
