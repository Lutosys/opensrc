for index, value in next, getgc(true) do
    if type(value) == "function" then
        if debug.getinfo(value).name == "accelerate" then
            hookfunction(value, function()
                return
            end)
        end
    end
end
