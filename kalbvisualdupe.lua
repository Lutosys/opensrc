local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plots = game.Workspace:WaitForChild("Plots")
local OwnerPlot = nil

while OwnerPlot == nil do
    task.wait(0.5)
    for i, v in pairs(Plots:GetChildren()) do
        if tostring(v:GetAttribute("Owner")) == game.Players.LocalPlayer.Name then
            OwnerPlot = v
        end
    end
end

local SlotsTable = {}
local Slots = OwnerPlot:FindFirstChild("Slots")

local function SetupSlot(slot)
    local NewInstance = Instance.new("Part")
    NewInstance.Name = "PlacedPart"
    NewInstance.CFrame = slot.CFrame
    NewInstance.Transparency = 1
    NewInstance.Anchored = true
    NewInstance.CanCollide = false
    NewInstance.Parent = slot
    
    NewInstance:SetAttribute("Coins", 0)
    NewInstance:SetAttribute("ID", "")
    NewInstance:SetAttribute("lastCollect", 0)
    NewInstance:SetAttribute("Level", 1)
    NewInstance:SetAttribute("Mutation", "")
    
    NewInstance:AddTag("PlacedPart")
end

for i, slot in pairs(Slots:GetChildren()) do
    if slot:FindFirstChild("PlacedPart") then
        if not table.find(SlotsTable, slot) then
            table.insert(SlotsTable, slot)
        end
    else
        SetupSlot(slot)
        table.insert(SlotsTable, slot)
    end
end

Slots.ChildAdded:Connect(function(slot)
    if slot:FindFirstChild("PlacedPart") then
        if not table.find(SlotsTable, slot) then
            table.insert(SlotsTable, slot)
        end
    else
        if not table.find(SlotsTable, slot) then
            SetupSlot(slot)
            table.insert(SlotsTable, slot)
        end
    end
end)

local brainrots = {
    "Noobini Pizzanini", "Lirili Larila", "Tim Cheese", "Talpa Di Fero", "Svinina Bombardino", "Pipi Kiwi", "Fruli Frula", "Trippi Troppi",
    "Gangster Footera", "Bobrito Bandito", "Boneca Ambalabu", "Ta Ta Ta Ta Sahur", "Ballerina Cappuccina", "Cappuccino Assassino", "Brr Brr Patapim", "Cacto Hipopotamo",
    "Garamararam", "Madung", "Waterdino", "Pesto Mortioni", "Pannaburro", "Orcalero", "Mangolini Parrocini", "John Pork", "Gattatino Nyanino",
    "Chimpanzini Bananini", "Plan Red", "Plan Blue", "Capi Taco", "Trulimero Trulicina", "Bambini Crostini", "Elefantucci Bananucci", "Bananita Dolphinita", "Salamino Pinguino",
    "Penguino Cocosino", "67", "Burbaloni Luliloli", "Chef Crabracadabra", "Capybara Eggplant", "Bangello", "Elefanto Frigo", "Rinooccio Verdini", "Glorbo Fruttodrillo",
    "Udin Din Din Dun", "Pandaccini Bananini", "Octopusini Bluberini", "Strawberelli Flamingelli", "Sigma Boy", "Frigo Camelo", "Orangutini Ananasini", "Rhino Toasterino", "Bombardiro Crocodilo",
    "Bombini Gusini", "Tuff Toucan", "Fryuro", "Burguro", "Guest666", "Zibra Zubra Zibralini", "Cavallo Virtuso", "Gorillo Watermelondrillo", "Cocofanto Elefanto",
    "Girafa Celeste", "Tralalero Tralala", "Tralalerita Tralala", "Peant Jarro", "Dipperi Chiperini", "Rexosaurus", "1x1x1x1", "Matteo", "Espresso Signora",
    "Alessio", "Tripi Tropi Tropa Tripa", "SWAG SODA", "Stoppo Luminino", "Torrtuginni Dragonfrutini", "Tictac Sahur", "Los Primos Blue", "Cactus Pingu", "La Vacca Saturno Saturnita", "Agarrini La Palini",
    "Karkerkar Kurkur", "Blackhole Goat", "Cappuccino Clownino", "Compactoroni Diskaloni", "Nuclearo Dinossauro", "Chillin Chilli", "Crazylone Pizaione", "Corn Sahur", "Meowl", "Strawberry Elephant",
    "Dragonfrutina Dolphinita", "Guerriro Digitale", "Chicleteira Bicicleteira", "Pot Hotspot", "Krupuk Pagi Pagi", "Beluga Beluga", "Tralaledon", "Anpali Babel", "Los Primos", "Mastodontico Telepiedone",
    "Espresso Shockantoni", "Ketupat Kepat", "Professora 67", "Astro Tim", "Dumbelloni", "Baba Yaga", "Don Tiramisotto", "Kicky", "Smelloni Papayoni", "Barbelloni Gymrattoni",
    "W", "Dragon Cannelloni", "Spaghetti Tualetti", "Esok Sekolah", "Job Job Job Sahur", "Yess My Examen", "Lucky Kick", "Rocky", "Hat Tricky", "GOAT",
    "Bronze Block Medali", "Golden Block Cuppy", "Silver Block Cuppy", "Bronze Block Cuppy", "Golden Block Medali", "Silver Block Medali", "Castlino Fortini", "Bambu Sahur", "Bottellini", "Los Nooo My Hotspotsitos", "Ketchuru Matsuru"
}

local ValidMutations = {
    "Golden", "Diamond", "Plasma", "Radioactive", "Molten", "Void", "Shadow", "Electrified", "Rainbow", "Virus", "Volcanic", "Wet", "Alien", "Bacon", "Enchanted", "Phantom", "Astral", "Heavenly", "Carnival", "Block Cup"
}

local function SetBrainrot(slot, brainrot, mutation, level)
    local PlacedPart = slot:FindFirstChild("PlacedPart")
    if not PlacedPart then
        return
    end

    PlacedPart:SetAttribute("ID", brainrot)
    PlacedPart:SetAttribute("Mutation", mutation)
    PlacedPart:SetAttribute("Level", level)
end

local function clearall()
    for i, slot in pairs(SlotsTable) do
        local placedpart = slot:FindFirstChild("PlacedPart")
        if placedpart then
            placedpart:SetAttribute("ID", "")
            placedpart:SetAttribute("Mutation", "")
        end
    end
end

while true do
    for i,v in pairs(SlotsTable) do
        SetBrainrot(v, brainrots[math.random(1, #brainrots)], ValidMutations[math.random(1, #ValidMutations)], math.random(1,1000))
    end
    wait(5)
    clearall()
end
