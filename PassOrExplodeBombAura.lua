local utility = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	target = nil
}

function utility:GetBombTool()
	local s, r = pcall(function(...)
        local c = self.LocalPlayer.Character
        if not c then
            return nil
        end

        local b = c:FindFirstChild("BombActive")
        if not b then
            return nil
        end

		return b
	end)

	if s and r then
		return r
	end

	return nil
end

function utility:getclosetplayer()
    local closetdist = math.huge
    local closet = nil

    for key, plr in pairs(self.Players:GetPlayers()) do
        if plr == self.LocalPlayer then
            continue
        end

        if plr:GetAttribute("InThePit") or plr:GetAttribute("IsInRound") then
            local char = plr.Character
            if not char then
                continue
            end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                continue
            end

            local BombActive = self:GetBombTool()
            if not BombActive then
                continue
            end

            local Handle = BombActive:FindFirstChild("Handle")
            if not Handle then
                continue
            end

            local dist = (Handle.Position - hrp.Position).Magnitude
            if dist < 10 and dist < closetdist then
                closetdist = dist
                closet = plr
            end
        end
    end

    return closet
end

function utility:attack(t)
	pcall(function(...)
		local c = t.Character
		if not c then
			return
		end

		local h = c:FindFirstChild("HumanoidRootPart")
		if not h then
			return
		end 

		local mc = self.LocalPlayer.Character
		if not mc then
			return
		end

		local mh = mc:FindFirstChild("HumanoidRootPart")
		if not mh then
			return
		end 


		local b = mc:FindFirstChild("BombActive")
		if not b then
			return
		end

		self.firePass(mh, h, t, "touch", b)
	end)
end

function utility:init()
	self.LocalPlayer = self.Players.LocalPlayer
	if not self.LocalPlayer then
		return warn('failed to get localplayer')
	end

	if not filtergc then
		return self.LocalPlayer:Kick("unsupported executor")
	end

	self.firePass = filtergc("function", {Name = "firePass"}, true)
	if not self.firePass then
		return warn('failed to get firePass function')
	end	

	self.l = tick()
	self.runconn = self.RunService.Heartbeat:Connect(function()
		self.target = self:getclosetplayer()
		if tick() - self.l >= 0.1 then
			self.l = tick()
			if self.target then
				self:attack(self.target)
			end
		end
	end)

	if not self.runconn then
		return warn("failed to create conn")
	end

	return warn("success init")
end

utility:init()
