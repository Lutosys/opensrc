while wait() do
local args = {
	buffer.fromstring("\001\001\f\000Security Car"),
	{
		workspace:WaitForChild("Spawners"):WaitForChild("DOE Spawner")
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Libraries"):WaitForChild("ByteNetMax"):WaitForChild("system"):WaitForChild("ByteNetReliable"):FireServer(unpack(args))


local args = {
	buffer.fromstring("\001\001\f\000Security Car"),
	{
		workspace:WaitForChild("Spawners"):WaitForChild("DOE Spawner")
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Libraries"):WaitForChild("ByteNetMax"):WaitForChild("system"):WaitForChild("ByteNetReliable"):FireServer(unpack(args))

end
