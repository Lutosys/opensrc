local Workspace = cloneref(workspace)
local Stages = Workspace.Map.Stage

local function getLavas()
    local s, r = pcall(function(...)
        local d = Stages:GetDescendants()
        local re = {}
        for _, obj in ipairs(d) do
            if obj.Name:lower():find("lava") or obj.Name:lower():find("trigger") then
                local t = obj:QueryDescendants("#TouchInterest")
                for _, touch in ipairs(t) do
                    if not table.find(re, touch) then
                        table.insert(re, touch)
                    end
                end
            end
        end

        return re
    end)

    if s then
        return r
    end

    return {}
end

local function disableLava()
    local s, r = pcall(function(...)
        local patched = 0

        for _, t in ipairs(getLavas()) do
            if tostring(t) == "TouchInterest" then
                t:Destroy()
                patched += 1
            end
        end

        return patched
    end)

    if s and r ~= 0 then
        return r
    end

    return 0
end

local function begin()
    pcall(function(...)
        local r = disableLava()
        if r ~= 0 then
            warn("disabled: "..tostring(r).. " lava/triggers")
        else
            warn("disabled nothing")
        end
    end)
end

begin()

while true do
    task.wait(5)

    begin()
end
