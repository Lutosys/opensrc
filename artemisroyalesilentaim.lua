getgenv().config = getgenv().config or {
    Enabled = true,
    TargetPart = "Head",
    FOV = 200,
    Color = Color3.fromRGB(0, 255, 255),
    Thickness = 1.5,
}

local Workspace: Workspace? = game:GetService("Workspace")
if not Workspace then return warn("Workspace did not initialize") end 
local Players: Players? = game:GetService("Players")
if not Players then return warn("Players did not initialize") end 
local RunService: RunService? = game:GetService("RunService")
if not RunService then return warn("RunService did not initialize") end 
local ReplicatedStorage: ReplicatedStorage? = game:GetService("ReplicatedStorage")
if not ReplicatedStorage then return warn("ReplicatedStorage did not initialize") end 
local target: Instance? = nil

local LocalPlayer: Player? = Players.LocalPlayer
if not LocalPlayer then return warn("LocalPlayer did not initialize") end 

local function isVisible(target: Instance?): boolean
    if not target or typeof(target) ~= "Instance" or target.Parent == nil then 
        return false 
    end 

    local cam: Camera? = Workspace.CurrentCamera
    if not cam then return false end 
    local char: Model? = LocalPlayer.Character
    if not char then return false end
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

local UserInputService = game:GetService("UserInputService")

local SilentFovCircle = Drawing.new("Circle")
SilentFovCircle.Position = UserInputService:GetMouseLocation()
SilentFovCircle.Radius = 70
SilentFovCircle.Color = getgenv().config.Color
SilentFovCircle.Filled = false
SilentFovCircle.NumSides = 128
SilentFovCircle.Thickness = 1
SilentFovCircle.Visible = true

local function GetClosestPlayer(): BasePart?
    local closestDistance: number = math.huge
    local closest: BasePart? = nil
    local camera: Camera = Workspace.CurrentCamera
    local GetPlayers: {Player} = Players:GetPlayers()

    for _, v in pairs(GetPlayers) do
        if v == LocalPlayer then continue end

        local char: Model? = v.Character
        if not char then continue end
        local hrp: BasePart? = char:FindFirstChild("HumanoidRootPart"):: BasePart?
        if not hrp then continue end
        local hum: Humanoid? = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local screenPos: Vector3, onScreen: boolean = camera:WorldToViewportPoint(hrp.Position)

        if onScreen then
            local distance: number = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if distance <= SilentFovCircle.Radius and distance < closestDistance then
            if not isVisible(hrp) then continue end
                closestDistance = distance
                closest = hrp
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    target = GetClosestPlayer()
    SilentFovCircle.Color = getgenv().config.Color
    SilentFovCircle.Radius = getgenv().config.FOV
    SilentFovCircle.Thickness = getgenv().config.Thickness
    SilentFovCircle.Position = UserInputService:GetMouseLocation()
end)

local hookedFunctions = {}
local oldFunctions = {}
local Raycast = filtergc("function", {Name = "Raycast"})
while wait(1) do
    Raycast = filtergc("function", {Name = "Raycast"})
    for _, ray in pairs(Raycast) do
        if debug.info(ray, "a") > 2 then
            if not hookedFunctions[ray] then
                print("Hooked!!!!")
                hookedFunctions[ray] = true
                oldFunctions[ray] = hookfunction(ray, function(origin, direction, params)
                    local hit, pos, normal, hum = oldFunctions[ray](origin, direction, params)

                    if target and target:IsA("BasePart") then
                        hit = target
                        pos = target.Position
                        normal = Vector3.new(0,1,0)
                        hum = target.Parent:FindFirstChildOfClass("Humanoid")
                    end
                    return hit,pos,normal,hum
                end)
            end
        end
    end
end
