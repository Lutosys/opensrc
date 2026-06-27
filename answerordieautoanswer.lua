local player = game.Players.LocalPlayer
local questionsdata = nil

local function getbestanswer(question)
    local answer = nil
    local biggest = 0
    local questiondata = nil
    
    for _, v in pairs(questionsdata) do
        if v.value == question then
            questiondata = v.answers
            break
        end
    end
    
    if not questiondata then
        return warn("No answer found")
    end
    
    for _, v in pairs(questiondata) do
        if type(v) == "table" and v.value then
            if string.len(v.value) > biggest then   
                biggest = string.len(v.value)
                answer = v.value
            end
        end
    end
    
    return answer or ""
end

local function getCurrentQuestion()
    local success, result = pcall(function()
        return game:GetService("Players").LocalPlayer.PlayerGui.Main.Question.Bg.QuestionTxt.Text
    end)
    if success then
        return result
    end
    return nil
end

for i, v in pairs(getgc(true)) do
    if type(v) == "function" then
        pcall(function()
            local upvalue = debug.getupvalue(v, 1)
            if type(upvalue) == "table" then
                for _, value in pairs(upvalue) do
                    if type(value) == "table" and value.id then
                        if type(value.id) == "number" and value.id < 40 then
                            questionsdata = upvalue
                            break
                        end
                    end
                end
            end
        end) 
    end
end

while wait() do
    pcall(function(...)
        local question = getCurrentQuestion()

        if question then
            local Event = game:GetService("ReplicatedStorage").Common.Library.Network.RemoteFunction
            Event:InvokeServer(
                "S_System_NewSubmitAnswer",
                {
                    getbestanswer(question)
                }
            )
        end
    end)
end
