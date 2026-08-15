local utility = {
	shoot = filtergc("function", {Name = 'shoot'}, true),
	recoil = filtergc("function", {Name = 'recoil'}, true),
}

local success, spreaderrormessage = pcall(function()
	local getRayDirections = clonefunction(debug.getupvalue(utility.shoot, 7))
	debug.setupvalue(utility.shoot, 7, function(p1,p2,p3,p4,p5)
		return getRayDirections(p1,p2,0,p4,p5)
	end)
end)

if success then
	warn("no spread success")
else
	warn("no spread error: "..tostring(spreaderrormessage))
end

local success2, recoilerror = pcall(function()
	hookfunction(utility.recoil, function()
		return
	end)
end)

if success2 then
	warn("no recoil success")
else
	warn("no recoil error: "..tostring(recoilerror))
end
