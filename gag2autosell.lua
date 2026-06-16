local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = require(ReplicatedStorage.SharedModules.Networking)

while wait(0.5) do
    Networking.NPCS.SellAll:Fire()
end 
