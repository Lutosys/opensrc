local utility = {
    hooked = {},
    targetstyle = nil,
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    StarterPlayer = game:GetService("StarterPlayer"),
    StarterGui = game:GetService("StarterGui")
}

utility.CollectGarbage = function(includetable)
    local s, r = pcall(function(...)
        return getgc(includetable)
    end)

    if s and r then
        return r    
    end

    return warn('failed to get garbage: '..tostring(r))
end

function utility:SafeHook(typeofhook, metamethod, callback, original)
    local s, r = pcall(function(...)
        if typeofhook == "hookfunction" then
            print("hooking")
            self.hooked[original] = hookfunction(original, callback)
            return self.hooked[original]
        elseif typeofhook == "hookmetamethod" then
            self.hooked[game] = hookmetamethod(game, metamethod, callback)
            return self.hooked[game]
        end 
        return nil
    end)

    if s and r then
        return r    
    end

    return warn("failed to hook: "..tostring(r))
end

function utility:bypassadonis()
    local s, r = pcall(function(...)
        for _, k in next, self.CollectGarbage(true) do
            if typeof(k) == "table" then
                if rawget(k, "Detected") and typeof(k.Detected) == "function" then
                    setthreadidentity(2)

                    self.debughook = self:SafeHook("hookfunction", nil, function(level, letter, ...)
                        if level == k.Detected then
                            return coroutine.yield(coroutine.running())
                        end
                        return self.debughook(level, letter, ...)
                    end, debug.info)

                    if not self.debughook then
                        return false
                    end

                    self.detecthook = self:SafeHook("hookfunction", nil, function(action, info, nocrash)
                        if action ~= "_" then
                            warn("tried to crash")
                        end
                        return true
                    end, k.Detected)

                    setthreadidentity(8)

                    if not self.detecthook then
                        return false
                    end

                    return true
                end
            end
        end

        return false
    end)

    if not s then
        return warn("Failed to bypass: "..tostring(r))
    end

    return warn("successfully bypass")
end

utility.ReturnUpdateInfoFunction = function()
    local s, r = pcall(function(...)
        local temp = filtergc("function", {Name = "updateinfotab"})

        for _, data in pairs(temp) do
            local u = debug.getupvalue(data, 1)
            if u and typeof(u) == "table" then
                if u.Inventory and u.Inventory.Unlocked_Styles and debug.info(data, "l") == 5814 then
                    temp = data
                    break
                end
            end
        end

        return temp
    end)

    if s and r then
        return r
    end

    return warn("failed to get function err:"..tostring(r))
end

function utility:InvokeServer()
    local r = self.RemoteFunction:InvokeServer("GetData")
    
    for k, s in next, self.StylesFolder:GetChildren() do
        r.Inventory.Unlocked_Styles[tostring(s)] = true
    end

    return r
end

function utility:Init()
    self.StarterGui:SetCore("SendNotification", {
        Title = "Info",
        Text = "A success notification will show up once it is done hooking, check bottom right if nothing shows up check console otherwise join discord."
    })

    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not hookfunction then
        return self.LocalPlayer:Kick("Unsupported executor missing hookfunction")
    end

    if not hookmetamethod then
        return self.LocalPlayer:Kick("Unsupported executor missing hookmetamethod")
    end

    if not debug or not debug.setupvalue then
        return self.LocalPlayer:Kick("Unsupported executor missing setupvalue")
    end

    if not setthreadidentity then
        return self.LocalPlayer:Kick("Unsupported executor missing setthreadidentity")
    end
    
    repeat 
        task.wait()
    until self.LocalPlayer.Character

    self.leaderstats = self.LocalPlayer:WaitForChild("leaderstats", 5)
    if not self.leaderstats then
        return warn("failed to get leaderstats")
    end

    self.Class = self.leaderstats:WaitForChild("Class", 5)
    if not self.Class then
        return warn("failed to get class")
    end

    self.targetstyle = self.Class.Value

    self.Communicate = self.LocalPlayer:WaitForChild("Communicate", 5)
    if not self.Communicate then
        return warn("failed to get Communicate")
    end

    self.Interface = self.Communicate:WaitForChild("Interface", 5)
    if not self.Interface then
        return warn("failed to get Interface")
    end

    self.RemoteFunction = self.Interface:WaitForChild("RemoteFunction", 5)
    if not self.RemoteFunction then
        return warn("failed to get RemoteFunction", 5)
    end

    self.PlayerGui = self.LocalPlayer:WaitForChild("PlayerGui", 5)
    if not self.PlayerGui then
        return warn("failed to get PlayerGui")
    end

    self.Main = self.PlayerGui:WaitForChild("Main", 5)
    if not self.Main then
        return warn("failed to get Main")
    end

    self.Menus = self.Main:WaitForChild("Menus", 5)
    if not self.Menus then
        return warn("failed to get Menus")
    end

    self.Inventory = self.Menus:WaitForChild("Inventory", 5)
    if not self.Inventory then
        return warn("failed to get Inventory")
    end

    self.Menus2 = self.Inventory:WaitForChild("Menus", 5)
    if not self.Menus2 then
        return warn("failed to get Menus2")
    end

    self.Styles = self.Menus2:WaitForChild("Styles", 5)
    if not self.Styles then
        return warn("failed to get Styles")
    end

    self.Info = self.Styles:WaitForChild("Info", 5)
    if not self.Info then
        return warn("failed to get Info")
    end

    self.EQUIP = self.Info:WaitForChild("EQUIP", 5)
    if not self.EQUIP then
        return warn("failed to get EQUIP")
    end

    self.Display = self.Info:WaitForChild("Display", 5)
    if not self.Display then
        return warn("failed to get Display")
    end

    self.ItemName = self.Display:WaitForChild("ItemName", 5)
    if not self.ItemName then
        return warn("failed to get ItemName")
    end

    self.EQUIPPED = self.Info:WaitForChild("EQUIPPED", 5)
    if not self.EQUIPPED then
        return warn("failed to get EQUIPPED")
    end

    self.StarterCharacterScripts = self.StarterPlayer:WaitForChild("StarterCharacterScripts", 5)
    if not self.StarterCharacterScripts then
        return warn("failed to get StarterCharacterScripts")
    end

    self.Core = self.StarterCharacterScripts:WaitForChild("Core", 5)
    if not self.Core then
        return warn("failed to get Core")
    end

    self.Animations = self.Core:WaitForChild("Animations", 5)
    if not self.Animations then
        return warn("failed to get Animations")
    end

    self.StylesFolder = self.Animations:WaitForChild("Styles", 5)
    if not self.StylesFolder then
        return warn("failed to get StylesFolder")
    end

    self.UpdateInfo = self.ReturnUpdateInfoFunction()
    while not self.UpdateInfo or typeof(self.UpdateInfo) ~= "function" do 
        task.wait(0.1)
        self.UpdateInfo = self.ReturnUpdateInfoFunction()
    end

    self.equipconn = self.EQUIP.MouseButton1Click:Connect(function()
        if self.StylesFolder:FindFirstChild(self.ItemName.Text) then
            self.targetstyle = self.ItemName.Text
            self.EQUIP.Visible = false
            self.EQUIPPED.Visible = true
        end
    end)

    if not self.equipconn then
        return warn("failed to create click connection for button")    
    end

    local s, r = pcall(function(...)
        debug.setupvalue(self.UpdateInfo, 2, utility)
    end)

    if not s then
        return warn("failed to setupvalue err: "..tostring(r))
    end

    self:bypassadonis()

    self.metahook = self:SafeHook("hookmetamethod", "__index", function(s, key)
        if tostring(s) == "Class" and key == "Value" then
            if tostring(getcallingscript()) == "Core" or tostring(getcallingscript()) == "Interface" then
                return self.targetstyle
            end
        end
        return self.metahook(s, key)
    end)

    if not self.metahook then
        return
    end

    self.StarterGui:SetCore("SendNotification", {
        Title = "Success",
        Text = "You should be able to equip any style in inventory! join discord if issue"
    })

    return warn('success init')
end

utility:Init()
