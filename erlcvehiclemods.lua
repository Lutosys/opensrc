local vehicles = workspace.Vehicles

local function getLocalCar()
    for _, car in next, vehicles:GetChildren() do
        if car:GetAttribute("Owner") and car:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
            return car
        end
    end
    return nil 
end

local carinfo = {}

local function saveCarStat(car, stat, value)
    if not carinfo[car] then
        carinfo[car] = {}
    end
    
    if carinfo[car][stat] == nil then
        carinfo[car][stat] = value
    end
end

local function setCarStat(stat, value)
    local currentCar = getLocalCar()
    if not currentCar then
        return
    end
    
    local info = require(currentCar["Drive Controller"])
    if not info then
        return
    end
    
    saveCarStat(currentCar, "Horsepower", info.Horsepower)
    saveCarStat(currentCar, "PeakRPM", info.PeakRPM)
    saveCarStat(currentCar, "PeakSharpness", info.PeakSharpness)
    saveCarStat(currentCar, "FinalDrive", info.FinalDrive)
    saveCarStat(currentCar, "Ratios", info.Ratios)
    saveCarStat(currentCar, "Redline", info.Redline)
    saveCarStat(currentCar, "EqPoint", info.EqPoint)
    
    info[stat] = value
end

local function ResetCarStat(car, stat)
    if not car or not carinfo[car] or carinfo[car][stat] == nil then
        warn("No saved value to reset for " .. stat)
        return
    end
    
    local info = require(car["Drive Controller"])
    if info then
        info[stat] = carinfo[car][stat]
    end
end

local function ResetAllCarStats()
    local currentCar = getLocalCar()
    if not currentCar then
        return
    end
    
    if not carinfo[currentCar] then
        return
    end
    
    local stats = {"Horsepower", "PeakRPM", "PeakSharpness", "FinalDrive", "Ratios", "Redline", "EqPoint", "BrakeForce", "PBrakeForce", "BrakeBias", "BrakeAccel"}
    for _, stat in ipairs(stats) do
        ResetCarStat(currentCar, stat)
    end
end

setCarStat("Horsepower", 9999)
setCarStat("PeakRPM", 10000)
setCarStat("PeakSharpness", 999)
setCarStat("FinalDrive", 1)
setCarStat("Ratios", {0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03})
setCarStat("Redline", 25000)
setCarStat("EqPoint", 15000)
