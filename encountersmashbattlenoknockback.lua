local utility = {
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
}

utility.DisableConns = function(self)
    local success, errormessage = pcall(function()
        for _, conn in pairs(getconnections(game.ReplicatedStorage.RE.Blob.OnClientEvent)) do 
            conn:Disable() 
        end
    end)

    if not success then
        warn("failed to disable conn reason: "..tostring(errormessage))
    end 

    warn("success")
end

utility:DisableConns()
