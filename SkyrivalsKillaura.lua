local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    target = nil,
}

function utility:getsword()
    local s, r = pcall(function(...)
        local t = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if t:FindFirstChild("MeleeScript") then
            return t
        end
        return nil
    end)
    if s and r then
        return r  
    end
    return nil
end

function utility:getorigin(root)
    local s, r = pcall(function(...)
        return (root.CFrame * CFrame.new(0, self.GameConfig.HRPMeleeOffset, 0)).Position + Vector3.new(0, 0.25, 0)
    end)
    if s and r then
        return r  
    end
    return nil
end

function utility:attack(char)
    if not char then
        return
    end

    local mychar = self.LocalPlayer.Character
    if not mychar then 
        return
    end

    local myroot = mychar:FindFirstChild("HumanoidRootPart")
    if not myroot then 
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return
    end

    local tool = self:getsword()
    if not tool then
        return
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        return
    end

    local hit = handle:FindFirstChild("Hit")
    if not hit then
        return
    end

    self.MeleeAttackBegin:FireServer(tool)

    self.ValidateHit:FireServer(
        myroot.Position,
        hrp,
        hrp.Position,
        tool.Name,
        {
            Knockback = 200,
            FireAdd = 0,
            Damage = 100,
            Type = "Melee",
            KnockbackTime = 0.2,
            LastYVel = 0,
            MeleeOrigin = self:getorigin(myroot),
            NewYVel = 0,
            HitEffectsForMe = true,
            Sound = hit,
            BloodData = {
                Enabled = true,
                Blood1 = true
            }
        },
        nil,
        "9329KC"
    )
end

function utility:getcloset()
    local closet = nil
    local closetdist = math.huge

    for i, plr in pairs(self.Players:GetPlayers()) do
        if plr == self.LocalPlayer then
            continue
        end

        local myteam = self.LocalPlayer.Team and self.LocalPlayer.Team.Name
        local theirteam = plr.Team and plr.Team.Name

        if theirteam == "Lobby" or myteam == "Lobby" then
            continue
        end

        if myteam ~= "Players" then
            if myteam == theirteam then
                continue
            end
        end

        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end    
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end   

        local dist = self.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist <= 15 and dist < closetdist then
            closetdist = dist
            closet = char  
        end 
    end

    return closet
end

function utility:init()
  self.LocalPlayer = self.Players.LocalPlayer
  if not self.LocalPlayer then
      return warn("failed to get localplayer")
  end

  self.Remotes = self.ReplicatedStorage:FindFirstChild("Remotes")
  if not self.Remotes then
      return warn("failed to get remotes")
  end

  self.MeleeAttackBegin = self.Remotes:FindFirstChild("MeleeAttackBegin")
  if not self.MeleeAttackBegin then
      return warn("failed to get MeleeAttackBegin")
  end

  self.ValidateHit = self.Remotes:FindFirstChild("ValidateHit")
  if not self.ValidateHit then
      return warn("failed to get ValidateHit")
  end

  self.GameConfig = require(self.ReplicatedStorage:FindFirstChild("GameConfig"))
  if not self.GameConfig then
      return warn("failed to get gameconfig")
  end

  self.lastattack = tick()
  self.conn = self.RunService.RenderStepped:Connect(function(a0: number)
      self.target = self:getcloset()
      if self.target then
          if tick() - self.lastattack >= 0.1 then
              self:attack(self.target)
              self.lastattack = tick()
          end
      end
  end)
  if not self.conn then
      return warn('failed to createconn')
  end
  return warn('success')
end

utility:init()
