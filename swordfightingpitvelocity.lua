local KnockbackVelocity = game:GetService("ReplicatedStorage").Remotes.Knockback

local velocitypercent = 0

local oldknockback
oldknockback = hookfunction(getconnections(KnockbackVelocity.OnClientEvent)[1].Function, function(a1,a2)
    local x,y,z = a2.X, a2.Y, a2.Z
    x = x * velocitypercent/100
    y = y * velocitypercent/100
    z = z * velocitypercent/100

    return oldknockback(a1,Vector3.new(x,y,z))
end)
