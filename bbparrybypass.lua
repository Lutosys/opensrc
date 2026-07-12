local old
old = hookfunction(getrenv().debug.info, function(f, t)
    if type(f) == "function" then
        return "[C]"
    elseif f == 4 and t == "s"  then
        return "ReplicatedStorage.Controllers.SwordsController "
    end

    return old(f, t)
end)

local old2
old2 = hookfunction(getrenv().getfenv, function(l)
    if l ~= nil and type(l) == "number" then
        if l >= 1 and l <= 10 then
            local result = old2(10)
            return result 
        end
    end

    return old2(l)
end)

info("ready")
