local sum = 600

local moonChances = {
    {Name = "Rainbow Moon", Chance = 6},
    {Name = "Goldmoon", Chance = 13},
    {Name = "Bloodmoon", Chance = 2},
    {Name = "Moon", Chance = 79}
}

local function getMoonType(cycleID, order)
    local rng = Random.new(cycleID * 1000 + order)
    local roll = rng:NextNumber() * 100
    local sum2 = 0
    
    for _, moon in ipairs(moonChances) do
        sum2 = sum2 + moon.Chance
        if roll <= sum2 then
            return moon.Name
        end
    end
    return "Moon" 
end

local function perdict24()
    local startTime = os.time()
    local endTime = startTime + (24 * 3600) 
    
    for t = startTime, endTime, sum do
        local cycleID = math.floor(t / sum)
        local timeString = os.date("%I:%M %p", t)
        
        local moonType = getMoonType(cycleID, 3)
        
        print(string.format("[%s] CycleID: %d | Phase: Night | Predicted Moon: %s", timeString, cycleID, moonType))
    end
end

perdict24()
