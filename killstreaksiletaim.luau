--!strict

assert(typeof(filtergc) == "function", "your executor doesnt support filtergc")
assert(typeof(hookfunction) == "function", "your executor doesnt support hookfunction")

local target: Instance? = nil

local Workspace: Workspace? = game:GetService("Workspace")
if not Workspace then return warn("Workspace did not initialize") end 
local Players: Players? = game:GetService("Players")
if not Players then return warn("Players did not initialize") end 
local RunService: RunService? = game:GetService("RunService")
if not RunService then return warn("RunService did not initialize") end 
local ReplicatedStorage: ReplicatedStorage? = game:GetService("ReplicatedStorage")
if not ReplicatedStorage then return warn("ReplicatedStorage did not initialize") end 
local Shared: Instance? = ReplicatedStorage:WaitForChild("Shared", 3)
if not Shared then return warn("Shared did not initialize") end 
local Net: any? = Shared:WaitForChild("Net", 3)
if not Net then return warn("Net did not initialize") end 
local success: boolean, Module: any = pcall(require, Net)
if not success or not Module then return warn("Module did not initialize") end 
local packets: any = Module.packets
if not packets then return warn("packets did not initialize") end 
local AttackFunc = filtergc("function", {Name = "Attack"}, true)
if not AttackFunc then return warn("Didnt get attackfuncc") end
local DoAttack = debug.getproto(AttackFunc, 1)
if not DoAttack then return warn("Didnt get DoAttack") end
local secretpacketname = debug.getconstant(DoAttack, 76)
if not secretpacketname then return warn("failed to get attack packet name") end
local attack: any = packets[secretpacketname]
if not attack then return warn("attack did not initialize") end
local send = attack.send
if not send then return warn("send did not initialize") end

local Teams = require(Shared.Config.Teams)
local IsFriendly = nil
for _, func in pairs(Teams) do
	if typeof(func) == "function" and debug.info(func, "l") == 56 then
        IsFriendly = func
    end
end
if not IsFriendly then
    return warn("failed to get isfriendly func")
end

local LocalPlayer: Player? = Players.LocalPlayer
if not LocalPlayer then return warn("LocalPlayer did not initialize") end 

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

        if IsFriendly(v, LocalPlayer) then continue end

        if onScreen then
            local distance: number = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
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

local hookSuccess: boolean, errormessage: any = pcall(function()
    local old
    old = hookfunction(send, function(args)
        if target and target:IsA("BasePart") then
            local cam: Camera? = Workspace.CurrentCamera
            if cam then
                local origin: Vector3 = cam.CFrame.Position
                local direction: Vector3 = (target.Position - origin).Unit

                if typeof(args) == "table" then   
                    for key, arg in pairs(args) do
                        if typeof(arg) == "table" then
                            args[key] = {Ray.new(origin, direction)}
                        end
                    end
                end
            end
        end
        return old(args)
    end)
end)

if not hookSuccess then
    warn("error:" ..tostring(errormessage))
    return
end 

warn("ready")
