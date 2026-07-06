local actor = getactors()[1]

run_on_actor(actor, [=[
    local target = nil

    local function isVisible(target)
        local origin = game.workspace.CurrentCamera.CFrame
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
        params.IgnoreWater = true

        local direction = (target.Position - origin.Position)
        local result = workspace:Raycast(origin.Position, direction, params)

        if result then
            return game.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
        else
            return true
        end
    end

    local function GetClosestPlayer()
        local closestDistance = math.huge
        local closest = nil
        local camera = workspace.CurrentCamera

        for _, v in pairs(game.Players:GetPlayers()) do
            if v == game.Players.LocalPlayer then continue end
            
            local char = v.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local myteam = game.Players.LocalPlayer.Team and game.Players.LocalPlayer.Team.Name
            local theirTeam = v.Team and v.Team.Name

            if myteam == theirTeam then
                continue
            end 

            local head = char:FindFirstChild("Head")
            if not head then continue end
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
                if distance < closestDistance then
                    if not isVisible(head) then continue end
                    closestDistance = distance
                    closest = head
                end
            end
        end

        return closest
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        target = GetClosestPlayer()
    end)

    for i, v in pairs(getgc()) do   
        if type(v) == "function" and islclosure(v) then
            if debug.info(v, "a") == 2 and #debug.getupvalues(v) == 2 and #debug.getconstants(v) == 17 and debug.info(v,"n"):len() <= 10 then
                local old
                old = hookfunction(v, function(p1,p2)
                    if target and target.Position then
                        local mychar = game.Players.LocalPlayer.Character
                        if mychar then
                            local head = mychar:FindFirstChild("Head")
                            if head then
                                local direction = (target.Position - head.Position) 
                                p1 = Ray.new(head.Position, direction)
                            end 
                        end 
                    end 
                    return old(p1,p2)
                end)
            end 
        end 
    end 
]=])
