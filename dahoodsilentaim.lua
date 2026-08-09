
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

local myhrp = nil

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
        warn("couldnt get origin ( cam )")
        return false
    end

    local params: RaycastParams = RaycastParams.new()
    if not params or typeof(params) ~= "RaycastParams" then 
        warn("couldnt create params")
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

        local head: BasePart? = char:FindFirstChild("Head"):: BasePart?

        if not head then continue end
        local screenPos: Vector3, onScreen: boolean = camera:WorldToViewportPoint(hrp.Position)

        if onScreen then
            local distance: number = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
               if not isVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

local shoot = filtergc("function", {Name = "shoot"}, true)
local old
old = hookfunction(shoot, function(self)
    if self ~= LocalPlayer then
        return old(self)
    end
    if target then
        self.ForcedOrigin = target.Position + Vector3.new(0,5,0)
        self.AimPosition = target.Position
    end
    return old(self)
end)
