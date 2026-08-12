local utility = {
	perfect = -1.5,
	releaseArgs = {
		{
			Shoot = false
		}
	},
	shoot = game:GetService("ReplicatedStorage"):WaitForChild("Aero"):WaitForChild("AeroRemoteServices"):WaitForChild("InputService"):WaitForChild("Shoot"),

}

utility.plr = game.Players.LocalPlayer
utility.characters = workspace.Characters
utility.conns = {}

utility.GetMeter = function(self)
	local success, result = pcall(function()
		local char = self.characters:FindFirstChild(self.plr.Name)
		if not char then return nil end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil end
		local VerticalMeter = hrp:FindFirstChild("VerticalMeter")
		if not VerticalMeter then return nil end
		return VerticalMeter
	end)

	if success then
		return result
	end

	return nil
end

utility.GetMeterOffset = function(self)
	local success, result = pcall(function()
		local VerticalMeter = self:GetMeter()
		if not VerticalMeter then return 0 end

		local Meter_Fill = VerticalMeter:FindFirstChild("Meter_Fill")
		if not Meter_Fill then return 0 end

		local FillGradient = Meter_Fill:FindFirstChild("FillGradient")
		if not FillGradient then return 0 end

		return FillGradient.Offset.Y
	end)

	if success then
		return result
	end

	return 0
end

utility.HookCharacter = function(self)
	local success, result = pcall(function()
		local VerticalMeter = self:GetMeter()
		if not VerticalMeter then return false end

		local Meter_Fill = VerticalMeter:FindFirstChild("Meter_Fill")
		if not Meter_Fill then return false end

		local FillGradient = Meter_Fill:FindFirstChild("FillGradient")
		if not FillGradient then return false end

		utility.conns[FillGradient] = FillGradient:GetPropertyChangedSignal("Offset"):Connect(function()
			local offset = FillGradient.Offset.Y
			if offset then
				if VerticalMeter and VerticalMeter.Enabled then
                    if offset <= self.perfect + 0.15 + self.plr:GetNetworkPing() then
                        self.shoot:FireServer(unpack(self.releaseArgs))
                    end
                end
			end
		end)

		return true
	end)

	if success then
		return true
	end

	return false
end

utility.conns["charadded"] = utility.characters.ChildAdded:Connect(function(c)
	repeat
		wait(0.1)
	until utility:GetMeter() ~= nil

	if utility:HookCharacter() then
		print("hooked")
    else
        warn('failed')
	end
end)

local result = utility:HookCharacter()
if result then
    print("hooked")
else
    warn('failed')
end
