repeat wait(1) until game.Loaded

print("script has been executed")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local lplr = Players.LocalPlayer

if not getfflag or not setfflag or not hookfunction then
    return lplr:Kick("Unsupported Executor")
end

local queue_teleport = queue_on_teleport or (syn and syn.queue_on_teleport)

local placeID = game.PlaceId
local gameID = game.JobId

if queue_teleport then
    lplr.OnTeleport:Connect(function()
        queue_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Lutosys/opensrc/refs/heads/main/pfnorecoil.lua'))()") 
    end)
end

if getfflag("DebugRunParallelLuaOnMainThread") == false then
    setfflag("DebugRunParallelLuaOnMainThread", "true")
    
    print("FFLAG changed, rejoining...")
    
    if gameID and gameID ~= "" then
        TeleportService:TeleportToPlaceInstance(placeID, gameID, lplr)
    else
        TeleportService:Teleport(placeID, lplr)
    end
    return
end

for i, v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "applyImpulse") then
        hookfunction(rawget(v, "applyImpulse"), function()
            return
        end)
        print("function has been hooked")
        break
    end
end
