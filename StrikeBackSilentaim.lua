local utility = {
    target = nil,
    RunService = cloneref(game:GetService("RunService")),
    Players = cloneref(game:GetService("Players")),
    Workspace = cloneref(game:GetService("Workspace")),
    UserInputService = cloneref(game:GetService("UserInputService")),
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
}

utility.safeRequire = function(m)
    local s, r = pcall(function(...)
        return require(m)
    end)

    if s and r then
        return r
    end

    return nil
end

utility.safeHookfunction = function(c, n)
    local s, r = pcall(function(...)
        return hookfunction(c, n) 
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:CreateParams()
    local s, r = pcall(function(...)
        local c = self.LocalPlayer.Character
        if not c then return nil end

        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = {c}
        p.IgnoreWater = true

        return p
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:GetCamera()
    local s, r = pcall(function(...)
        local c = self.Workspace.CurrentCamera
        if not c then return nil end    

        return c
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:GetCameraCFrame()
    local s, r = pcall(function(...)
        return self.Camera.CFrame or self:GetCamera().CFrame
    end)
    
    if s and r then
        return r
    end

    return nil
end

utility.ComputeeDirection = function(origin, endpoint)
    local s, r = pcall(function(...)
        return (endpoint - origin)
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:SafeRaycast(origin, direction, params)
    local s, r = pcall(function(...)
        return self.Workspace:Raycast(origin, direction, params)
    end)

    if s and r then
        return r
    end

    return nil
end

utility.IsApartOfFolder = function(inst, folder)
    local s, r = pcall(function(...)
        return inst:FindFirstAncestorOfClass("Model").Parent == folder
    end)

    if s and r then
        return r
    end

    return false
end

utility.safeAdd = function(t, o)
    local s, r = pcall(function(...)
        return table.insert(t, o)
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:isVisible(t)
    if not t then
        return false
    end

    local o = self:GetCameraCFrame().Position
    if not o then
        return false
    end
    local params = self:CreateParams()
    if not params then
        return false
    end

    local direction = self.ComputeeDirection(o, t.Position)
    local result = self:SafeRaycast(o, direction, params)
    if result then
        return self.IsApartOfFolder(result.Instance, self.Character)
    else
        return false
    end
end

function utility:getCharacters() 
    local r = {}
    
    for _, char in pairs(self.Character:GetChildren()) do
        if char:GetAttribute("IsDeath") then
            continue
        end
        if char:GetAttribute("IsTrainingBot") then
            continue
        end
        if tostring(char) == tostring(self.LocalPlayer) then
            continue
        end
        local tT = char:GetAttribute("PlayerCamp")
        local mT = self.Players.LocalPlayer:GetAttribute("PlayerCamp")

        if tT == mT then
            continue
        end

        self.safeAdd(r, char)
    end 

    return r
end

function utility:GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = self.Camera or self:GetCamera()

    for _, char in pairs(self:getCharacters()) do   
        if char:FindFirstChildOfClass("ForceField") then
            continue    
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            continue 
        end
        local head = char:FindFirstChild("Head")
        if not head then 
            continue 
        end
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                if not self:isVisible(head) then
                    continue 
                end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

function utility:init()
   self.LocalPlayer = self.Players.LocalPlayer
   if not self.LocalPlayer then
        return warn("failed to get LocalPlayer")
   end

    if not hookfunction then
        self.LocalPlayer:Kick("Unsupported executor use a better executor like real/madium")
    end

   self.Camera = self:GetCamera()
   if not self.Camera then
        return warn("failed to get camera")
   end

   self.Character = self.Workspace:FindFirstChild("Character")
   if not self.Character then
        return warn("failed to find players folder")
   end

    self.GetTargetConn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
        if self.target then
            print(self.target)
        end
    end)

    if not self.GetTargetConn then
        return warn("failed to create RenderStepped connection")
    end

    self.WeaponsSystem = self.ReplicatedStorage:FindFirstChild("WeaponsSystem")
    if not self.WeaponsSystem then
        return warn("failed to get WeaponsSystem")
    end

    self.WeaponTypes = self.WeaponsSystem:FindFirstChild("WeaponTypes")
    if not self.WeaponTypes then
        return warn("failed to get WeaponTypes")
    end

    self.BulletWeapon = self.WeaponTypes:FindFirstChild("BulletWeapon")
    if not self.BulletWeapon then
        return warn("failed to get BulletWeapon")
    end

    self.BulletWeapon = self.safeRequire(self.BulletWeapon)
    if not self.BulletWeapon then
        return warn("failed to require BulletWeapon")
    end

    self.OldFire = self.safeHookfunction(self.BulletWeapon.fire, function(p2, p3, p4)
        if self.target then
            p4 = self.ComputeeDirection(p3, self.target.Position).Unit
        end
        return self.OldFire(p2,p3,p4)
    end)

   return warn("success")
end

utility:init()
