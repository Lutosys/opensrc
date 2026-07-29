--!strict

assert(typeof(hookfunction) == "function", "your executor doesnt support hookfunction")
assert(typeof(filtergc) == "function", "your executor doesnt support filtergc")

local Workspace: Workspace? = game:GetService("Workspace")
if not Workspace then return warn("did not get Workspace") end 
local Players: Players? = game:GetService("Players")
if not Players then return warn("did not get Players") end 
local RunService: RunService? = game:GetService("RunService")
if not RunService then return warn("did not get RunService") end 

local Cast: (any) = filtergc("function", {Name = "Cast"}, true)
if not Cast or typeof(Cast) ~= "function" then return warn("Cast returned nil or not a function") end
local CanPlayersPVP: (any) = filtergc("function", {Name = "CanPlayersPVP"}, true)
if not CanPlayersPVP or typeof(CanPlayersPVP) ~= "function" then return warn("CanPlayersPVP returned nil or not a function") end

local LocalPlayer: Player = Players.LocalPlayer
if not LocalPlayer then return warn("didnt get localplayer") end

local target: Instance? = nil

local function isVisible(target: Instance?): boolean
    if not target or typeof(target) ~= "Instance" or target.Parent == nil then 
        warn("target is nil/passed a weird userdata")
        return false 
    end 

    local cam: Camera? = Workspace.CurrentCamera
    if not cam then warn("camera is nil"); return false end 
    local char: Model? = LocalPlayer.Character
    if not char then warn("character is nil"); return false end
    local origin: CFrame = Workspace.CurrentCamera.CFrame
    if not origin or typeof(origin) ~= "CFrame" then 
        return false
    end
    local params: RaycastParams = RaycastParams.new()
    if not params or typeof(params) ~= "RaycastParams" then 
        return false 
    end 

    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    params.IgnoreWater = true

    if not target:IsA("BasePart") then return false end
    
    local direction: Vector3 = (target.Position - origin.Position)
    local result: RaycastResult? = Workspace:Raycast(origin.Position, direction, params)

    if result then
        local model: Instance? = result.Instance:FindFirstAncestorOfClass("Model")
        return model ~= nil
    else
        return true
    end
end

local function GetClosestPlayer(): Instance?
    local closestDistance: number = math.huge
    local closest: Instance = nil
    local camera: Camera = workspace.CurrentCamera

    local plrs: {Player} = Players:GetPlayers()

    for _, v in pairs(plrs) do
        if v == LocalPlayer then continue end
        
        local char: Model? = v.Character
        if not char then continue end

        local hrp: Instance? = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp:IsA("BasePart")  then continue end
        local hum: Humanoid? = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local head: Instance? = char:FindFirstChild("Head")
        if not head or not head:IsA("BasePart") then continue end 
        if CanPlayersPVP and CanPlayersPVP(LocalPlayer, v) then
            local screenPos: Vector3, onScreen: boolean = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance: number  = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
                if distance < closestDistance then
                    if not isVisible(head) then continue end
                    closestDistance = distance
                    closest = head
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

local old = nil
local hookSuccess, err = pcall(function()
    old = hookfunction(Cast, function(origin: Vector3, direction: Vector3, params: RaycastParams)
        if tostring(getfenv(debug.info(2,"f")).script) == "Shooter" then
            if target and target:IsA("BasePart") then
                direction = (target.Position - origin).Unit
            end
        end
        return old(origin,direction,params)
    end)
end)

if not hookSuccess then
    warn("failed to hook: " .. tostring(err))
    return
end

warn("success")
