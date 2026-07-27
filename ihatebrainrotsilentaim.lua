--!strict

if not hookfunction or typeof(hookfunction) ~= "function" then
    warn("hookfunction is not a function ( poor executor )")
end

local getRayDirections: (any) = filtergc("function", {Name = "getRayDirections"}, true)
if not getRayDirections or typeof(getRayDirections) ~= "function" then
    return warn("getRayDirections is nonexisten / not a function")
end 

local Workspace = game:GetService("Workspace") :: Workspace?
if not Workspace then 
    return warn("getservice (Workspace) failed")
end 
local RunService: RunService? = game:GetService("RunService")
if not RunService then 
    return warn("getservice (RunService) failed")
end 
local ReplicatedStorage: ReplicatedStorage? = game:GetService("ReplicatedStorage")
if not ReplicatedStorage then 
    return warn("getservice (ReplicatedStorage) failed")
end 
local Players: Players? = game:GetService("Players")
if not Players then 
    return warn("getservice (Players) failed")
end 

local ActiveEnemies: Instance? = Workspace:WaitForChild("ActiveEnemies", 10)
if not ActiveEnemies then
    return warn("failed to get ActiveEnemies instance")
end

local LocalPlayer: Player? = Players.LocalPlayer
if not LocalPlayer then 
    return warn("failed to get LocalPlayer")
end 

local targettingenemy: Instance? = nil

local function isVisible(target: BasePart?): boolean
    if not target then 
        return false 
    end 

    local character: Model? = LocalPlayer.Character
    if not character then 
        return false 
    end

    local params: RaycastParams = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = true

    if not params or typeof(params) ~= "RaycastParams" then 
        return false 
    end

    local camera: Camera? = Workspace.CurrentCamera
    if not camera then 
        return false 
    end

    local origincframe: CFrame? = camera.CFrame
    if not origincframe or typeof(origincframe) ~= "CFrame" then 
        return false 
    end 

    local originpos: Vector3? = origincframe.Position
    if not originpos or typeof(originpos) ~= "Vector3" then 
        return false 
    end 

    local targetpos: Vector3 = target.Position
    if not targetpos or typeof(targetpos) ~= "Vector3" then 
        return false 
    end 

    local direction: Vector3 = (targetpos - originpos)
    if not direction or typeof(direction) ~= "Vector3" then 
        return false 
    end 

    local result: RaycastResult? = workspace:Raycast(originpos, direction, params)
    
    if result then
        local model: Model? = result.Instance:FindFirstAncestorOfClass("Model")
        if model then
            if model.Parent and model.Parent.Name == "ActiveEnemies" then
                return true
            end
        end
    end

    return false
end

local function getClosestEnemy(): BasePart?
    local closestdistance: number = math.huge
    local closest: BasePart? = nil
    local camera: Camera? = Workspace.CurrentCamera

    if not camera then
        return nil
    end

    for _, enemy: Instance? in pairs(ActiveEnemies:GetChildren()) do
        if enemy and enemy.Parent ~= nil then   
            local hrp: Instance? = enemy:FindFirstChild("HumanoidRootPart")
            if not hrp or not hrp:IsA("BasePart") then continue end
            local humanoid: Humanoid? = enemy:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health == 0 then continue end   

            local screenpos: Vector3, onscreen: boolean = camera:WorldToViewportPoint(hrp.Position)
            if onscreen then
                local distance: number = (Vector2.new(screenpos.X, screenpos.Y) - camera.ViewportSize / 2).Magnitude
                if distance < closestdistance then
                    if not isVisible(hrp) then continue end
                    closestdistance = distance
                    closest = hrp
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    targettingenemy = getClosestEnemy()
end)

local old: any
local success: boolean, errormessage: string = pcall(function(...)
    old = hookfunction(getRayDirections, function(p1,p2,p3,p4)
        if targettingenemy then
            local cam: Camera? = Workspace.CurrentCamera
            if cam then
                local origincframe: CFrame? = cam.CFrame
                if origincframe or typeof(origincframe) == "CFrame" then
                    local originpos: Vector3? = origincframe.Position
                    if originpos or typeof(originpos) == "Vector3" then
                        if targettingenemy:IsA("BasePart") then
                            local targetPos = targettingenemy.Position :: any
                            if targetPos then
                                p1 = CFrame.lookAt(originpos, targetPos)
                                p3 = 0
                            end
                        end
                    end
                end
            end
        end
        return old(p1,p2,p3,p4)
    end)    
end)

if not success then
    warn("error: "..tostring(errormessage))
    return
end

print("success")
