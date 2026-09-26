local utility = {
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	Players = game:GetService("Players"),
	used = {"hookmetamethod", "getnamecallmethod"}
}

function utility:SafeHook(game, metamethod, func)
	local s, r = pcall(function(...)
		return hookmetamethod(game, metamethod, func)
	end)

	if s and r then
		return r	
	end

	return warn("failed to hook reason: "..tostring(r))
end

function utility:dependencycheck()
	local s, r = pcall(function(...)
		local e = getgenv()

		for _, f in pairs(self.used) do
			if not e[f] then
				self.LocalPlayer:Kick("Missing: "..tostring(f))
			end
		end
	end)

	if not s then
		return warn("failed: "..tostring(r))
	end

	return
end

function utility:init()
	self.LocalPlayer = self.Players.LocalPlayer
	if not self.LocalPlayer then
		return warn("failed to get LocalPlayer")
	end

    self:dependencycheck()

	self.ReliableRedEvent = self.ReplicatedStorage:FindFirstChild("ReliableRedEvent")
	if not self.ReliableRedEvent then
		return warn("failed to get ReliableRedEvent")
	end

	self.hook = self:SafeHook(game, "__namecall", function(...)
		local s = select(1, ...)
		local a = {select(2, ...)}
		local m = getnamecallmethod()

		if m == "FireServer" and s == self.ReliableRedEvent then
			if a[2] and typeof(a[2]) == "table" then
				if rawget(a[2], "\a") and typeof(a[2]["\a"]) == "table" then
					if a[2]["\a"][1] and typeof(a[2]["\a"][1]) == "table" then
						a[2]["\a"][1][2] = 1
					end
				end
			end 
		end

		return self.hook(s, unpack(a))
	end)

	if not self.hook then
		return
	end

	return warn("success init")
end

utility:init()
