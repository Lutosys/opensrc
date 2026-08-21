getgenv().config = {
    HaveToFace = false,
}

local utility = {
    GuardAction = game:GetService("ReplicatedStorage").Controllers.PlayerInputController.InputActions.CharacterGameplayContext.EquippedWeaponContext.GuardAction,
    LocalPlayer = game.Players.LocalPlayer,
    Camera = workspace.CurrentCamera,
    MaxAngle = 30,
}

local function safefire(signal)
    local success, _ = pcall(function(...)
        return firesignal
    end)
    if not success then return warn("firesignal is nil") end    
    local success2, result2 = pcall(function(...)
        return firesignal(signal)
    end)
    if success2 then
        return result2
    end 
    return warn('failed to firesignal: '..tostring(result2))
end

local function Block(time)
    safefire(utility.GuardAction.Pressed)
    task.wait(time)
    safefire(utility.GuardAction.Released)
end

local function GetClosetPlayer()
    local closet = nil
    local closetdistance = math.huge

    for _, plr in game.Players:GetPlayers() do
        if plr == utility.LocalPlayer then continue end

        local character = plr.Character
        if not character then continue end

        if not character:GetAttribute("Health") or character:GetAttribute("Health") <= 0 then
            continue
        end

        local head = character:FindFirstChild("Head")
        if not head then continue end

        local mychar = utility.LocalPlayer.Character
        if not mychar then continue end

        local myhrp = mychar:FindFirstChild("HumanoidRootPart")
        if not myhrp then continue end

        local hum = character:FindFirstChild("Humanoid")
        if not hum then continue end

        local distance = (utility.Camera.CFrame.Position - head.CFrame.Position).Magnitude
        local _, onscreen = utility.Camera:WorldToViewportPoint(head.Position)
        if onscreen then
            if distance < closetdistance and distance <= 30 then
                closet = {
                    char = character,
                    head = head,
                    hum = hum,
                }
                closetdistance = distance
            end
        end
    end

    return closet or nil
end

local function IsInAngle(enemyHead)
    local mychar = utility.LocalPlayer.Character
    if not mychar then return false end

    local myhead = mychar:FindFirstChild("Head")
    if not myhead then return false end

    local dir = (workspace.CurrentCamera.CFrame.Position - enemyHead.Position).Unit
    local enemylook = enemyHead.CFrame.LookVector
    local result = dir:Dot(enemylook)

    if result > .5 then
        return true
    end

    return false
end

local function ShouldParry()
    local ClosestPlayer = GetClosetPlayer()
    if not ClosestPlayer then
        return false, 0
    end

    if getgenv().config.HaveToFace then
        local IsIn = IsInAngle(ClosestPlayer.head)
        if not IsIn then
            return false, 0
        end
    end 

    local hum = ClosestPlayer.hum
    if not hum then return false, 0 end

    local animator = hum:FindFirstChild("Animator")
    if not animator then return false, 0 end

    local animationlist = animator:GetPlayingAnimationTracks()
    for i, animationTrack in pairs(animationlist) do
        if tostring(animationTrack.Length):find("0.933") and animationTrack.TimePosition <= 0.15 then
            return true, 0.15
        elseif tostring(animationTrack.Length):find("1.20000") and animationTrack.TimePosition <= 0.42 then
            return true, 0.42
        end
    end

    return false, 0
end

while true do
    game:GetService("RunService").RenderStepped:Wait()
    local p, d = ShouldParry()
    if p and d then
        Block(d)
    end
end
