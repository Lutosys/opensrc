local utility = {
	Workspace = game:GetService("Workspace"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
}
function utility:CollectEgg(e)
	local s,r = pcall(function(...)
		self.Event:FireServer(
			"Collect Egg",
			e.Name
		)
		e:Destroy()
	end)

	if not s then
		return warn("err: "..tostring(r))
	end

	return
end

function utility:init()
	self.Eggs = self.Workspace:FindFirstChild("Eggs")
	if not self.Eggs then
		return warn(":failed to ge teggs")
	end

	self.Event = self.ReplicatedStorage:FindFirstChild("__remoteevent", true)
	if not self.Event then
		return warn("failed to get Event")
	end

    for _, egg in ipairs(Eggs:GetChildren()) do
		self:CollectEgg(egg)
    end

	Eggs.ChildAdded:Connect(function(e)
		self:CollectEgg(e)
	end)

	return warn("sucess init")
end

utility:init()
