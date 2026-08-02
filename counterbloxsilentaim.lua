if not hookfunction or typeof(hookfunction) ~= "function" then
    print("Executor is not supported")
end

local Workspace: Workspace? = game:GetService("Workspace")
if not Workspace then return warn("did not get Workspace") end 
local Players: Players? = game:GetService("Players")
if not Players then return warn("did not get Players") end 
local RunService: RunService? = game:GetService("RunService")
if not RunService then return warn("did not get RunService") end 

local LocalPlayer: Player = Players.LocalPlayer
if not LocalPlayer then return warn("didnt get localplayer") end

local target: Instance? = nil

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
        local model: Model? = result.Instance:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then
            return true
        end
        return false
    else
        return true
    end
end

local function isEnemy(player: Player): boolean
	if not player then return false end
	if player == LocalPlayer then return false end
	local Character = player.Character :: Model?
	if not Character then return false end
	local UpperTorso = Character:FindFirstChild("UpperTorso")
	if not UpperTorso then return false end
	local Status = player:FindFirstChild("Status")
	if not Status then return false end
	local Team = Status:FindFirstChild("Team")
	if not Team then return false end
	if Team.Value == "Spectator" then return false end
	local LocalStatus = LocalPlayer:FindFirstChild("Status")
	if not LocalStatus then return false end
	local LocalTeam = LocalStatus:FindFirstChild("Team")
	if not LocalTeam then return false end
	if Team.Value == LocalTeam.Value then return false end
	local Alive = Status:FindFirstChild("Alive")
	if not Alive then return false end
	if not Alive.Value then return false end
	return true
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
        local head: Instance? = char:FindFirstChild("Head")
        if not head or not head:IsA("BasePart") then continue end 
        if not isEnemy(v) then continue end

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
    return closest
end

RunService.RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

local old: any
local success, errormessage = pcall(function()
    old = hookfunction(Ray.new, newcclosure(function(origin, direction)
        local trace = debug.traceback()
        if trace:find("Client") and not trace:find("10420") and not trace:find("10595")then
            if target and target:IsA("BasePart") then
                direction = target.Position -  origin
            end 
        end
        return old(origin, direction)
    end))
end)

if success then
    print("should be working!")
    return
end

print("error: "..tostring(errormessage))
