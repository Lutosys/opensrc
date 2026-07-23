do
    assert(typeof(filtergc) == "function", "your executor doesnt support filtergc")
    assert(typeof(getrenv) == "function", "your executor doesnt support getrenv")
    assert(typeof(rawequal) == "function", "your executor doesnt support rawequal")
    assert(typeof(newcclosure) == "function", "your executor doesnt support newcclosure")
    assert(typeof(setupvalue) == "function", "your executor doesnt support setupvalue")

    local success, errormessage = pcall(function()
        debug.setupvalue(filtergc("function", {Name = "connectSoundButton"}, true), 2, true)
        local old; old = hookfunction(getrenv().game:GetService("CollectionService").HasTag, newcclosure(function(obj, tag)
            if tag and typeof(tag) == "string" and (rawequal(tag, "Sounds2") or rawequal(tag, "Sounds3")) then return true end; return old(obj, tag); 
        end))
    end)
    if success then
        info("succesfully hooked: reopen sounds gui")
        return
    end
    warn("error in runtime: "..tostring(errormessage))
    return
end
