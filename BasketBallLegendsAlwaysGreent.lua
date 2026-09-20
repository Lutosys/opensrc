local utility = {
    Players = game:GetService("Players")   
}

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not getactors then
        return self.LocalPlayer:Kick("Unsupported executor missing getactors")
    end

    if not run_on_actor then
        return self.LocalPlayer:Kick("Unsupported executor missing run_on_actor")
    end

    if not hookmetamethod then
        return self.LocalPlayer:Kick("Unsupported executor missing hookmetamethod")
    end

    self.Actors = getactors()
    if #self.Actors == 0 then
        return warn("0 actors weird")
    end

    self.s, self.r = pcall(function(...)
        run_on_actor(self.Actors[1], [=[
            local su, r = pcall(function(...)
                local old; old = hookmetamethod(game, "__namecall", function(...)
                    local s = select(1, ...)
                    local a = {select(2, ...)}

                    if tostring(s) == "Shoot" then
                        if a[1] and typeof(a[1]) == "number" then
                            a[1] = 1
                        end 
                    end 

                    return old(s, unpack(a))
                end)
                return old
            end)
            if not su then   
                return warn("failed to hook metamethod:" ..tostring(r))
            end

            return warn('success hook')
        ]=])
    end)

    if not self.s then
        return warn("run_on_actor err: "..tostring(self.r))
    end

    return warn('success init')
end

utility:init()
