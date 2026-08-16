--credits to phem

for _, func in next, getgc() do
    if typeof(func) == "function" and debug.getinfo(func, "n").name == "f" then
        for _, upvalue in pairs(debug.getupvalues(func)) do
            if typeof(upvalue) == "table" then
                setmetatable(upvalue, {
                    __index = function()
                        print("index1")
                    end,
                    __newindex = function()
                        print("index2")
                    end
                })
            end
        end
    end
end
