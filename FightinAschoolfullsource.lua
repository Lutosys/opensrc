local styles = {
    "Compound V", "Heavy Hitter", "Philly", "Hitman", "Boxer", "Muay Thai",
    "Peak A Boo", "Slap Boxer", "Amateur", "Aggressive", "Ninja", "Bo Staff",
    "SAVAGE", "Striker", "Stud", "Blade", "Hawk", "Bones", "Squabble", "Karate",
    "Baddie", "Jaw Breaker", "CRASH OUT", "Kicker", "Jeet Kune Do", "Dukes",
    "YN", "Ali", "Foreman", "McGregor", "Khabib", "Crowbars", "Cane", "Tanto",
    "Karambit", "OMNI", "Woozy Brawler", "Blades Of Chaos", "Luffy", "Dr Oc",
    "Popeye", "Flick Boxer"
}

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer
local localplayer = Players.LocalPlayer
local PlayerGui = localplayer:WaitForChild("PlayerGui")
local interfarce = localplayer:WaitForChild("Communicate"):WaitForChild("Interface")
local interfarceremote = interfarce:WaitForChild("RemoteEvent")
local interfarceremotefunc = interfarce:FindFirstChild("RemoteFunction")

local Main = PlayerGui:WaitForChild("Main")
local MenusFolder = Main:WaitForChild("Menus")
local Inventory = MenusFolder:WaitForChild("Inventory")
local MenusFrame = Inventory:WaitForChild("Menus")
local HeavysList = MenusFrame:WaitForChild("Heavy"):WaitForChild("List")
local Emotes = ReplicatedStorage.Animations.Emotes

local Options = Library.Options
local Toggles = Library.Toggles

local function getRemote()
    local character = localplayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local rightHand = character:FindFirstChild("RightHand")
    local core = character:FindFirstChild("Core")
    if not rootPart or not rightHand or not core then return end
    return core:FindFirstChild("Communicate"):FindFirstChildOfClass("RemoteEvent")
end

local function GetFriendStatus(player)
    if player == localplayer then return false end
    local success, result = pcall(function()
        return localplayer:GetFriendStatus(player)
    end)
    if success then
        return result == Enum.FriendStatus.Friend or
               result == Enum.FriendStatus.FriendRequestSent or
               result == Enum.FriendStatus.FriendRequestReceived
    end
    return false
end

local Loading = Library:CreateLoading({
    Title = "Dynamic  ·  Style Changer",
    TotalSteps = 4
})

Loading:SetMessage("Starting up...")
Loading:SetCurrentStep(1)
task.wait(.4)

Loading:SetCurrentStep(2)
Loading:ShowSidebarPage(true)
Loading:SetMessage("Fetching version info")
Loading.Sidebar:AddLabel("User: " .. game.Players.LocalPlayer.Name)
Loading.Sidebar:AddLabel("Script by L10")
Loading.Sidebar:AddLabel("Version 1.0.0")
task.wait(.4)

Loading:SetMessage("Loading configs...")
Loading:SetCurrentStep(3)
task.wait(.4)

Loading:SetCurrentStep(4)
Loading:SetDescription("All systems ready.")
task.wait(.4)
Loading:Continue()

local Window = Library:CreateWindow({
    Title = "Dynamic",
    Footer = "by L10  ·  v1.0.0",
    NotifySide = "Right",
})

Library:Notify({
    Title = "Dynamic loaded",
    Description = "Press Right Control to toggle the UI.",
    Time = 5,
})

Library.KeybindFrame.Visible = true

local CombatTab = Window:AddTab({
    Name = "Combat",
    Icon = "swords"
})

local General = CombatTab:AddLeftGroupbox("Kill Aura")
local StyleChangerGroup = CombatTab:AddRightGroupbox("Style Changer")

local ExploitTab = Window:AddTab({
    Name = "Exploits",
    Icon = "zap"
})

local Exploit = ExploitTab:AddLeftGroupbox("Blatant Exploits")

local MovementTab = Window:AddTab({
    Name = "Movement",
    Icon = "zap"
})

local MoveGroup = MovementTab:AddLeftGroupbox("Movement Customization")
local TeleportGroup = MovementTab:AddRightGroupbox("Position Bookmarks & World Teleports")

local FarmingTab = Window:AddTab({
    Name = "Farming",
    Icon = "sprout"
})

local AutoFarmBox = FarmingTab:AddLeftGroupbox("Auto Farm Engine")
local AutoMoneyBox = FarmingTab:AddRightGroupbox("Economy Controls")

local MiscTab = Window:AddTab({
    Name = "Social",
    Icon = "users"
})

local PlayerListBox = MiscTab:AddLeftGroupbox("Player Inspector")
local ActionsBox = MiscTab:AddRightGroupbox("Actions")
local UtilityBox = MiscTab:AddLeftGroupbox("Utilities & Emotes")

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
                if u.Inventory and u.Inventory.Unlocked_Styles and debug.info(data, "l") == 5823 then
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

local WorldTab = Window:AddTab({
    Name = "World",
    Icon = "globe"
})

local LightingGroup = WorldTab:AddLeftGroupbox("Lighting Engine")
local PerformanceBox = WorldTab:AddRightGroupbox("Optimization & Performance")

local StyleChangerToggle = StyleChangerGroup:AddToggle("StyleChanger1", {
    Text = "Enable Style Changer",
    Default = false,
})

StyleChangerGroup:AddDivider()

local StyleClassesList = StyleChangerGroup:AddDropdown("StyleClassesList1", {
    Text = "Active Style",
    Values = styles,
    Default = 1,
    Multi = false,
})

function utility:Init()
    self:bypassadonis()

    self.metahook = self:SafeHook("hookmetamethod", "__index", function(s, key)
        if tostring(s) == "Class" and key == "Value" then
            if tostring(getcallingscript()) == "Core" or tostring(getcallingscript()) == "Interface" then
                if StyleChangerToggle.Value then
                    print("Ha")
                    return StyleClassesList.Value
                end
            end
        end
        return self.metahook(s, key)
    end)

    return
end

utility:Init()

local KillAuraToggle = General:AddToggle("KillAura", {
    Text = "Kill Aura",
    Default = false,
})
KillAuraToggle:AddKeyPicker("KillAuraKey", {
    Default = "R",
    Text = "Kill Aura",
    Mode = "Toggle",
    SyncToggleState = true,
})

General:AddDivider()

local EquipFistsToggle = General:AddToggle("EquipFists", {
    Text = "Auto-Equip Fists",
    Default = false,
})
EquipFistsToggle:AddKeyPicker("EquipFistsKey", {
    Default = "C",
    Text = "Auto-Equip Fists",
    Mode = "Toggle",
    SyncToggleState = true,
})

General:AddDivider()

General:AddCheckbox("IgnoreFriends", {
    Text = "Ignore Friends",
    Default = true,
})

General:AddDivider()

General:AddDropdown("AttackMode", {
    Text = "Attack Mode",
    Multi = false,
    Values = {"Attack", "Heavy", "Slam", "Shove"},
    Default = 1
})

local attackArgs = {
    ["Attack"] = {"Attack", "LeftHand"},
    ["Slam"]   = {"Slam", ""},
    ["Heavy"]  = {"Attack", "RightHand", true},
    ["Shove"]  = {"Shove"},
}

local lastAttackTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
    if os.clock() - lastAttackTime < 0.2 then return end
    lastAttackTime = os.clock()
    if not KillAuraToggle.Value then return end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer == localplayer then continue end
        local mychar = localplayer.Character
        if not mychar then continue end

        if EquipFistsToggle.Value then
            local backpack = localplayer.Backpack
            if backpack and backpack:FindFirstChild("Fight") then
                backpack.Fight.Parent = mychar
            end
        end

        local myhrp = mychar:FindFirstChild("HumanoidRootPart")
        if not myhrp then continue end

        local char = targetPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health == 0 then continue end

        if Toggles.IgnoreFriends.Value and GetFriendStatus(targetPlayer) then continue end

        if (myhrp.Position - hrp.Position).Magnitude <= 8 and Options.AttackMode.Value then
            local hitboxFunc = filtergc("function", { Name = "DoHitbox" }, true)
            hitboxFunc(unpack(attackArgs[Options.AttackMode.Value]))
        end
    end
end)

local lastGrabbedPlayer = nil
local inputConnection = nil
local MAX_GRAB_DISTANCE = 5

local function release()
    if not lastGrabbedPlayer then return end
    if inputConnection then inputConnection:Disconnect(); inputConnection = nil end
    if lastGrabbedPlayer.Character then
        local remote = getRemote()
        if remote then
            remote:FireServer("Throw", { Object = lastGrabbedPlayer.Character, Type = "Bench" })
        end
    end
    lastGrabbedPlayer = nil
end

local function grab(targetUser)
    release()
    if not targetUser or not targetUser.Character or targetUser == localplayer then return end
    lastGrabbedPlayer = targetUser

    local remote = getRemote()
    if not remote then return end

    remote:FireServer("Pickup", { Object = targetUser.Character, Type = "Bench" }, false)

    local character = targetUser.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Once(function()
            if lastGrabbedPlayer == targetUser then release() end
        end)
    end

    targetUser.CharacterAdded:Once(function()
        if lastGrabbedPlayer == targetUser then release() end
    end)

    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode[Options.PlayerThrowKey.Value] then
            if lastGrabbedPlayer and lastGrabbedPlayer.Character then
                remote:FireServer("Throw", { Object = lastGrabbedPlayer.Character, Type = "Bench" }, false)
                lastGrabbedPlayer = nil
            end
        end
    end)
end

local function findClosestPlayer()
    local localCharacter = localplayer.Character
    if not localCharacter then return nil end
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    local closestPlayer = nil
    local minDistance = MAX_GRAB_DISTANCE

    for _, player in ipairs(Players:GetPlayers()) do
        if player == localplayer then continue end
        local targetCharacter = player.Character
        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

        if targetRoot and targetCharacter.Parent and targetCharacter.Parent.Name == "Live" then
            local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

local PlayerThrowToggle = Exploit:AddToggle("PlayerThrow", {
    Text = "Player Throw",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Player Throw", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

PlayerThrowToggle:AddKeyPicker("PlayerThrowKey", {
    Default = "E",
    Text = "Throw Key",
    Mode = "Toggle",
    Callback = function()
        if PlayerThrowToggle.Value then
            local closestPlayer = findClosestPlayer()
            if closestPlayer then pcall(function() grab(closestPlayer) end) end
        end
    end
})

localplayer.CharacterAdded:Connect(function()
    release()
end)

Exploit:AddDivider()

local AutoWeaveToggle = Exploit:AddToggle("AutoWeave", {
    Text = "Auto Weave",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Auto Weave", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

AutoWeaveToggle:AddKeyPicker("AutoWeaveKey", {
    Default = "T",
    Text = "Auto Weave",
    Mode = "Toggle",
    SyncToggleState = true
})

Exploit:AddDivider()

Exploit:AddSlider("WeaveInterval1", {
    Text = "Weave Interval",
    Default = 0.20,
    Min = 0.1,
    Max = 0.5,
    Rounding = 3,
    Compact = false,
    Suffix = "s"
})

task.spawn(function()
    while true do
        task.wait()
        if AutoWeaveToggle.Value then
            local remote = getRemote()
            if remote then
                remote:FireServer("Weave", nil, true)
                task.wait(Options.WeaveInterval1.Value)
                remote:FireServer("Weave", nil, false)
            end
        end
    end
end)

Exploit:AddDivider()

Exploit:AddToggle("HitboxExpander", {
    Text = "Hitbox Expander",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Hitbox Expander", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

Exploit:AddDivider()

Exploit:AddSlider("HitboxSlider1", {
    Text = "Hitbox Size",
    Default = 6.7,
    Min = 3,
    Max = 13,
    Rounding = 1,
    Compact = false,
    Suffix = "u"
})

Exploit:AddSlider("TransparencySlider1", {
    Text = "Hitbox Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = false,
})

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == localplayer then continue end
            local char = player.Character
            if not char then continue end
            local part = char:FindFirstChild("HumanoidRootPart")
            if not part or not part:IsA("BasePart") then continue end

            if Toggles.HitboxExpander.Value then
                local rootSize = Options.HitboxSlider1.Value
                part.Size = Vector3.new(rootSize, rootSize, rootSize)
                part.Transparency = Options.TransparencySlider1.Value
                part.CanCollide = false
            else
                local originalSize = part:FindFirstChild("OriginalSize")
                if originalSize then part.Size = originalSize.Value end
                part.CanCollide = true
            end
        end
    end)
end)

StyleChangerGroup:AddDivider()

local HeavyChangerToggle = StyleChangerGroup:AddToggle("HeavyChanger", {
    Text = "Heavy Attack Changer",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Heavy Attack Changer", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

HeavyChangerToggle:OnChanged(function(value)
    if not value then
        for _, v in pairs(HeavysList:GetDescendants()) do
            if v.Name == "Equipped" and v.Visible then
                local revertHeavy = v.Parent.Parent.Name
                local server = localplayer:FindFirstChild("Server")
                if server and server:FindFirstChild("Heavy") then
                    server.Heavy.Value = revertHeavy
                end
                return
            end
        end
    end
end)


local Heavys = {
    "Flying Knee", "Truck", "Drop Kick", "Flying Kick",
    "Side Kick", "Hard Swing", "Strong Shove", "Heavy Haymaker"
}

StyleChangerGroup:AddDropdown("HeavyDropdown", {
    Text = "Heavy Attack",
    Values = Heavys,
    Default = 1,
    Multi = false
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if HeavyChangerToggle.Value then
            local server = localplayer:FindFirstChild("Server")
            if server and server:FindFirstChild("Heavy") then
                server.Heavy.Value = Options.HeavyDropdown.Value
            end
        end
    end
end)

local speedConn
local SpeedToggle = MoveGroup:AddToggle("Speed", {
    Text = "Speed Boost",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Speed Boost", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

SpeedToggle:AddKeyPicker("SpeedKey", {
    Default = "LeftShift",
    Text = "Speed Key",
    Mode = "Hold",
})

MoveGroup:AddDivider()

MoveGroup:AddSlider("SpeedAmount", {
    Text = "Speed Amount",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " studs/s"
})

local speedConnection = nil
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

SpeedToggle:OnChanged(function(state)
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    if state then
        speedConnection = RunService.Heartbeat:Connect(function()
            if not SpeedToggle.Value then return end
            local shouldApplySpeed = isMobile or UserInputService:IsKeyDown(Enum.KeyCode[Options.SpeedKey.Value])
            if shouldApplySpeed then
                local character = localplayer.Character
                if not character then return end
                local HRP = character:FindFirstChild("HumanoidRootPart")
                local Humanoid = character:FindFirstChild("Humanoid")
                if HRP and Humanoid then
                    HRP.AssemblyLinearVelocity = (HRP.AssemblyLinearVelocity * Vector3.new(0, 1, 0)) +
                                                  Humanoid.MoveDirection * Options.SpeedAmount.Value
                end
            end
        end)
    end
end)


local locations = {
    ["Leaderboards"]  = Vector3.new(-199, 5, 59),
    ["Library"]       = Vector3.new(-122, 5, 131),
    ["Gym"]           = Vector3.new(-200, 5, -12),
    ["Training Room"] = Vector3.new(-95, 5, -32),
    ["Outside"]       = Vector3.new(-199, 7, -153),
    ["Roof"]          = Vector3.new(-205, 42, -21),
    ["Cafeteria"]     = Vector3.new(-343, 5, 128)
}

TeleportGroup:AddDropdown("SelectLocation", {
    Text = "Destination",
    Values = {"Leaderboards", "Library", "Gym", "Training Room", "Outside", "Roof", "Cafeteria"},
    Default = 1
})

TeleportGroup:AddButton("Teleport", {
    Text = "Teleport Now",
    Func = function()
        pcall(function()
            local char = localplayer.Character
            if not char then return end
            Library:Notify({ Title = "Teleporting", Description = "To: " .. Options.SelectLocation.Value, Time = 4 })
            char:MoveTo(locations[Options.SelectLocation.Value])
        end)
    end
})

TeleportGroup:AddDivider()

TeleportGroup:AddDropdown("SelectServer", {
    Text = "Server Type",
    Values = {"VC", "Comp"},
    Default = 1
})

TeleportGroup:AddButton("TeleportServer", {
    Text = "Switch Server",
    Func = function()
        if Options.SelectServer.Value then
            Library:Notify({ Title = "Switching Server", Description = Options.SelectServer.Value, Time = 4 })
            interfarceremote:FireServer("TeleportTo" .. Options.SelectServer.Value)
        end
    end
})

TeleportGroup:AddDivider()

local savedPosition = nil

TeleportGroup:AddButton("SaveCurrentPosition", {
    Text = "Save Position",
    Func = function()
        pcall(function()
            local char = localplayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            savedPosition = hrp.Position
            Library:Notify({ Title = "Position Saved", Description = tostring(hrp.Position), Time = 4 })
        end)
    end
})

TeleportGroup:AddButton("TeleportToSaved", {
    Text = "Return to Bookmark",
    Func = function()
        pcall(function()
            local char = localplayer.Character
            if not char or not savedPosition then return end
            Library:Notify({ Title = "Returning", Description = tostring(savedPosition), Time = 4 })
            char:MoveTo(savedPosition)
        end)
    end
})

local currentEmoteTrack = nil
local selectedEmote = "L Dance"
local loopEmoteEnabled = false

local emoteNames = {}
for _, emote in pairs(Emotes:GetChildren()) do
    if not table.find(emoteNames, emote.Name) then
        table.insert(emoteNames, emote.Name)
    end
end

local function updateLoopEmote()
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    local targetEmote = Emotes:FindFirstChild(selectedEmote)
    if not targetEmote or not targetEmote:FindFirstChild("Main") then return end

    if currentEmoteTrack then
        currentEmoteTrack.Looped = false
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
    end

    if loopEmoteEnabled then
        local track = animator:LoadAnimation(targetEmote.Main)
        track.Looped = true
        track:Play()
        currentEmoteTrack = track
    end
end

local LoopEmoteToggle = UtilityBox:AddToggle("LoopEmote", {
    Text = "Loop Emote",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Loop Emote", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

LoopEmoteToggle:OnChanged(function(value)
    loopEmoteEnabled = value
    if value then
        updateLoopEmote()
    else
        if currentEmoteTrack then
            currentEmoteTrack.Looped = false
            currentEmoteTrack:Stop()
            currentEmoteTrack = nil
        end
    end
end)

UtilityBox:AddDivider()

local EmoteDropdown = UtilityBox:AddDropdown("EmoteDropdown", {
    Text = "Select Emote",
    Values = emoteNames,
    Default = table.find(emoteNames, "L Dance") or 1,
    Multi = false
})

EmoteDropdown:OnChanged(function(value)
    selectedEmote = value
    if loopEmoteEnabled then updateLoopEmote() end
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    currentEmoteTrack = nil
    if loopEmoteEnabled then updateLoopEmote() end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if loopEmoteEnabled and currentEmoteTrack and not currentEmoteTrack.IsPlaying then
            currentEmoteTrack:Play()
        end
    end
end)

local antiFlingConnection = nil

ActionsBox:AddCheckbox("FlingPrevention", {
    Text = "Anti-Fling",
    Default = true,
    Func = function(state)
        Library:Notify({ Title = "Anti-Fling", Description = state and "Enabled" or "Disabled", Time = 4 })

        if antiFlingConnection then antiFlingConnection:Disconnect(); antiFlingConnection = nil end

        if state then
            antiFlingConnection = RunService.Stepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localplayer and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end
            end)
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localplayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end
    end
})

ActionsBox:AddDivider()

local enableChatSpam = UtilityBox:AddToggle("EnableChatSpam", {
    Text = "Chat Spammer",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Chat Spammer", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

UtilityBox:AddDivider()

UtilityBox:AddInput("CustomMessage", {
    Text = "Message",
    Default = "L10 BEST",
    Placeholder = "Enter a message..."
})

UtilityBox:AddSlider("SpamDelay", {
    Text = "Spam Delay",
    Default = 3,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Suffix = "s"
})

task.spawn(function()
    while true do
        task.wait()
        if enableChatSpam.Value and interfarceremote and Options.CustomMessage.Value ~= "" then
            interfarceremote:FireServer("Broadcast", Options.CustomMessage.Value, 1)
            task.wait(Options.SpamDelay.Value)
        end
    end
end)

AutoFarmBox:AddCheckbox("AutoFarm", {
    Text = "Enable Auto Farm",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Auto Farm", Description = state and "Started" or "Stopped", Time = 4 })
    end
})
AutoFarmBox:AddDivider()

AutoFarmBox:AddSlider("DistanceX", {
    Text = "Offset X (forward)",
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Suffix = "u"
})

AutoFarmBox:AddSlider("DistanceY", {
    Text = "Offset Y (height)",
    Default = 3,
    Min = 0,
    Max = 5,
    Rounding = 2,
    Suffix = "u"
})

AutoFarmBox:AddDivider()

AutoFarmBox:AddCheckbox("LookAtPlayer", {
    Text = "Look At Target",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Look At Target", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

AutoFarmBox:AddCheckbox("AutoRespawn", {
    Text = "Auto Respawn",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Auto Respawn", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

AutoFarmBox:AddDivider()

AutoFarmBox:AddSlider("RespawnDelay", {
    Text = "Respawn Timeout",
    Default = 30,
    Min = 0,
    Max = 120,
    Rounding = 0,
    Suffix = "s"
})

AutoFarmBox:AddDivider()

local TPPLOT1 = AutoFarmBox:AddToggle("TPPLOT1", {
    Text = "Lock to Plot 1",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Plot 1 Lock", Description = state and "Active" or "Off", Time = 4 })
    end
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if TPPLOT1.Value then
            pcall(function() localplayer.Character:MoveTo(Vector3.new(-74, 4, -4)) end)
        end
    end
end)

local TPPLOT2 = AutoFarmBox:AddToggle("TPPLOT2", {
    Text = "Lock to Plot 2",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Plot 2 Lock", Description = state and "Active" or "Off", Time = 4 })
    end
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if TPPLOT2.Value then
            pcall(function() localplayer.Character:MoveTo(Vector3.new(-83, 4, -5)) end)
        end
    end
end)

local AUTORESETPLAYER = AutoFarmBox:AddToggle("AUTORESETPLAYER", {
    Text = "Auto Reset Self",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Auto Reset", Description = state and "Active" or "Off", Time = 4 })
    end
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if AUTORESETPLAYER.Value then
            task.wait(3)
            pcall(function() localplayer.Character.Humanoid:TakeDamage(100) end)
        end
    end
end)

task.spawn(function()
    local ATTACK_COOLDOWN = 0.2
    local LOOP_STEP = 0.025
    local TELEPORT_AFTER_KILL = Vector3.new(-205, 42, -21)

    local attackTimer = 0
    local loopTimer = 0
    local cam = workspace.CurrentCamera

    local function restoreCamera()
        if not cam then return end
        if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
        local mychar = localplayer.Character
        local hum = mychar and mychar:FindFirstChildWhichIsA("Humanoid")
        if hum and cam.CameraSubject ~= hum then cam.CameraSubject = hum end
    end

    local function applyCameraMode(isLookAtOn)
        if isLookAtOn then
            localplayer.CameraMode = Enum.CameraMode.LockFirstPerson
        else
            localplayer.CameraMode = Enum.CameraMode.Classic
        end
    end

    local function isFriendlyCharacter(char)
        for _, highlight in ipairs(char:GetChildren()) do
            if highlight:IsA("Highlight") and highlight.OutlineColor == Color3.fromRGB(143, 255, 137) then
                return true
            end
        end
        return false
    end

    local function disableCollisions(char)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    local function tryAutoRespawn()
        if not Toggles.AutoRespawn.Value then return end
        local mychar = localplayer.Character
        local myhumanoid = mychar and mychar:FindFirstChild("Humanoid")
        if myhumanoid then myhumanoid:TakeDamage(999) end
    end

    local function equipFightTool(mychar)
        local backpack = localplayer.Backpack
        if backpack and backpack:FindFirstChild("Fight") then
            backpack.Fight.Parent = mychar
        end
    end

    restoreCamera()
    localplayer.CharacterAdded:Connect(restoreCamera)

    while true do
        local dt = RunService.Heartbeat:Wait()
        loopTimer += dt
        if loopTimer < LOOP_STEP then continue end
        loopTimer -= LOOP_STEP

        if not Toggles.AutoFarm.Value then applyCameraMode(false); continue end

        for _, player in ipairs(Players:GetPlayers()) do
            if player == localplayer then continue end
            local char = player.Character
            if not char or not char.Parent then continue end
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            if isFriendlyCharacter(char) or char:FindFirstChildOfClass("ForceField") then continue end

            disableCollisions(char)
            local targetStart = os.clock()

            repeat
                local stepDt = RunService.Heartbeat:Wait()
                attackTimer += stepDt

                if not player.Parent then break end
                if not char.Parent then break end
                if player.Character ~= char then break end
                if os.clock() - targetStart >= Options.RespawnDelay.Value then tryAutoRespawn(); break end
                if not Toggles.AutoFarm.Value then break end

                local mychar = localplayer.Character
                if not mychar then break end

                local myhrp = mychar:FindFirstChild("HumanoidRootPart")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not myhrp or not hrp or humanoid.Health <= 0 then break end
                if isFriendlyCharacter(char) or char:FindFirstChildOfClass("ForceField") then break end

                equipFightTool(mychar)

                local offset = (-hrp.CFrame.LookVector * Options.DistanceX.Value) + Vector3.new(0, -Options.DistanceY.Value, 0)
                local targetPosition = hrp.Position + offset
                myhrp.CFrame = CFrame.lookAt(targetPosition, hrp.Position)

                if Toggles.LookAtPlayer.Value and cam and myhrp then
                    applyCameraMode(true)
                    local hum = mychar:FindFirstChildWhichIsA("Humanoid")
                    if not hum then applyCameraMode(false); break end
                    if cam.CameraSubject ~= hum then cam.CameraSubject = hum end
                    cam.CameraType = Enum.CameraType.Custom
                    cam.CFrame = myhrp.CFrame
                else
                    applyCameraMode(false)
                end

                if attackTimer >= ATTACK_COOLDOWN then
                    attackTimer -= ATTACK_COOLDOWN
                    local hitboxFunc = filtergc("function", { Name = "DoHitbox" }, true)
                    hitboxFunc(unpack(attackArgs.Attack))
                end
            until humanoid.Health <= 0 or not player.Parent or not char.Parent or player.Character ~= char

            applyCameraMode(false)

            if humanoid.Health <= 0 and char.Parent and player.Character == char then
                local mychar = localplayer.Character
                local myhrp = mychar and mychar:FindFirstChild("HumanoidRootPart")
                if myhrp then myhrp.CFrame = CFrame.new(TELEPORT_AFTER_KILL) end
            end
        end
    end
end)

local function transfer(target, amount)
    if not interfarceremotefunc or not amount or not target then return end
    pcall(function() interfarceremotefunc:InvokeServer("Send_Money", amount, target) end)
end

AutoMoneyBox:AddCheckbox("EnableAutoTransfer", {
    Text = "Enable Auto Transfer",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Auto Transfer", Description = state and "Running" or "Stopped", Time = 4 })
    end
})

AutoMoneyBox:AddDivider()

AutoMoneyBox:AddDropdown("PlayerToSendTo", {
    Text = "Send To",
    Default = 1,
    SpecialType = "Player",
    Excludelocalplayer = true
})

AutoMoneyBox:AddDivider()

AutoMoneyBox:AddSlider("TransferInterval", {
    Text = "Transfer Interval",
    Default = 30,
    Min = 0,
    Max = 60,
    Rounding = 0,
    Suffix = "s"
})

AutoMoneyBox:AddSlider("MinimumBalance", {
    Text = "Keep Balance",
    Default = 10000,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Suffix = "$"
})

AutoMoneyBox:AddDivider()

AutoMoneyBox:AddButton({
    Text = "Transfer All Now",
    Func = function()
        local leaderstats = localplayer:FindFirstChild("leaderstats")
        if not leaderstats then return end
        local money = leaderstats:FindFirstChild("Lunch Money")
        if not money then return end
        local target = Options.PlayerToSendTo.Value
        if not target or not target.Parent then return end
        Library:Notify({ Title = "Transferring", Description = "$" .. money.Value .. " to " .. target.Name, Time = 5 })
        transfer(target, money.Value)
    end
})

task.spawn(function()
    while true do
        task.wait()
        if not Toggles.EnableAutoTransfer.Value then continue end
        local leaderstats = localplayer:FindFirstChild("leaderstats")
        if not leaderstats then continue end
        local money = leaderstats:FindFirstChild("Lunch Money")
        if not money then continue end
        local target = Options.PlayerToSendTo.Value
        if not target or not target.Parent then continue end
        local amount = Options.MinimumBalance.Value
        if money.Value > amount then
            transfer(target, amount)
            task.wait(Options.TransferInterval.Value)
        end
    end
end)

AutoMoneyBox:AddDivider()

AutoMoneyBox:AddCheckbox("EnableAutoServerHop", {
    Text = "Auto Server Hop",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Server Hopper", Description = state and "Active" or "Stopped", Time = 4 })
    end
})

AutoMoneyBox:AddDivider()

AutoMoneyBox:AddSlider("PlayerCountThreshold", {
    Text = "Hop if Below",
    Default = 5,
    Min = 0,
    Max = 30,
    Rounding = 0,
    Suffix = " players"
})

local availableServers = {}

task.spawn(function()
    while true do
        task.wait(1.5)
        if not Toggles.EnableAutoServerHop.Value then continue end
        if #Players:GetPlayers() >= Options.PlayerCountThreshold.Value then continue end

        local success, result = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                    "/servers/Public?sortOrder=Asc&limit=100"
                )
            )
        end)

        if success and result and result.data then
            table.clear(availableServers)
            for _, server in ipairs(result.data) do
                if server.playing > Options.PlayerCountThreshold.Value + 5 and
                   server.playing < server.maxPlayers and
                   server.id ~= game.JobId then
                    table.insert(availableServers, server.id)
                end
            end

            if #availableServers > 0 then
                local serverId = availableServers[math.random(#availableServers)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, localplayer)
            end
        end
    end
end)

PlayerListBox:AddDropdown("PlayerSelected23", {
    Text = "Select Player",
    Default = 1,
    SpecialType = "Player"
})

PlayerListBox:AddDivider()

local classLabel  = PlayerListBox:AddLabel("Class: --")
local killsLabel  = PlayerListBox:AddLabel("Kills: --")
local moneyLabel  = PlayerListBox:AddLabel("Money: --")
local respectLabel = PlayerListBox:AddLabel("Respect: --")

task.spawn(function()
    while true do
        task.wait(1)
        local target = Options.PlayerSelected23.Value
        if not target then continue end
        local leaderstats = target:FindFirstChild("leaderstats")
        if not leaderstats then continue end
        local class   = leaderstats:FindFirstChild("Class")
        local kills   = leaderstats:FindFirstChild("Kills")
        local money   = leaderstats:FindFirstChild("Lunch Money")
        local respect = leaderstats:FindFirstChild("Respect")
        if class and kills and money and respect then
            classLabel:SetText("Class: " .. tostring(class.Value))
            killsLabel:SetText("Kills: " .. tostring(kills.Value))
            moneyLabel:SetText("Money: $" .. tostring(money.Value))
            respectLabel:SetText("Respect: " .. tostring(respect.Value))
        end
    end
end)

ActionsBox:AddButton({
    Text = "Invite to Party",
    Func = function()
        pcall(function()
            local target = Options.PlayerSelected23.Value
            if not target then return end
            interfarceremote:FireServer("InviteToParty", target)
        end)
        Library:Notify({ Title = "Party Invite", Description = "Invitation sent!", Time = 4 })
    end
})

ActionsBox:AddDivider()

ActionsBox:AddButton({
    Text = "Teleport To Player",
    Func = function()
        Library:Notify({ Title = "Teleporting", Description = "Moving to player...", Time = 4 })
        pcall(function()
            local mychar = localplayer.Character or localplayer.CharacterAdded:Wait()
            if not mychar then return end
            local target = Options.PlayerSelected23.Value
            if not target then return end
            local targetchar = target.Character or target.CharacterAdded:Wait()
            if not targetchar then return end
            local targethrp = targetchar:FindFirstChild("HumanoidRootPart")
            if not targethrp then return end
            mychar:MoveTo(targethrp.Position)
        end)
    end,
})

ActionsBox:AddDivider()

ActionsBox:AddToggle("FollowBot", {
    Text = "Follow Bot",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Follow Bot", Description = state and "Enabled" or "Disabled", Time = 4 })
    end
})

ActionsBox:AddDivider()

ActionsBox:AddSlider("FollowDistance", {
    Text = "Follow Distance",
    Default = 3,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Suffix = "u"
})

RunService.RenderStepped:Connect(function()
    if not Toggles.FollowBot.Value then return end
    local mychar = localplayer.Character
    if not mychar then return end
    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
    if not myhrp then return end
    local target = Options.PlayerSelected23.Value
    if not target then return end
    local targetchar = target.Character
    if not targetchar then return end
    local targethrp = targetchar:FindFirstChild("HumanoidRootPart")
    if not targethrp then return end
    local offset = -targethrp.CFrame.LookVector * Options.FollowDistance.Value
    myhrp.CFrame = targethrp.CFrame + offset
end)

LightingGroup:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Fullbright", Description = state and "On" or "Off", Time = 4 })
    end
})

PerformanceBox:AddToggle("RemoveParticles", {
    Text = "Remove Particles",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Remove Particles", Description = state and "Removed" or "Restored", Time = 4 })
    end
})

PerformanceBox:AddDivider()

PerformanceBox:AddToggle("RemoveDecals", {
    Text = "Remove Decals",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Remove Decals", Description = state and "Hidden" or "Visible", Time = 4 })
    end
})

PerformanceBox:AddDivider()

PerformanceBox:AddToggle("RemoveShadows", {
    Text = "Remove Shadows",
    Default = false,
    Func = function(state)
        Library:Notify({ Title = "Remove Shadows", Description = state and "Off" or "On", Time = 4 })
    end
})

task.spawn(function()
    local particleConnection = nil
    local decalCache = {}

    local function setupParticleRemoval()
        if particleConnection then particleConnection:Disconnect() end
        if Toggles.RemoveParticles.Value then
            particleConnection = workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
                    descendant:Destroy()
                end
            end)
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
                    descendant:Destroy()
                end
            end
        end
    end

    local function cacheDecals()
        decalCache = {}
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("Decal") then table.insert(decalCache, descendant) end
        end
    end

    cacheDecals()
    setupParticleRemoval()

    Toggles.RemoveParticles:OnChanged(setupParticleRemoval)

    Toggles.RemoveDecals:OnChanged(function(value)
        local transparency = value and 1 or 0
        for _, decal in ipairs(decalCache) do
            if decal and decal.Parent then decal.Transparency = transparency end
        end
    end)

    Toggles.RemoveShadows:OnChanged(function(value)
        Lighting.GlobalShadows = not value
    end)

    Toggles.Fullbright:OnChanged(function(value)
        Lighting.Brightness = value and 2 or 1
    end)

    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Decal") then
            table.insert(decalCache, descendant)
            descendant.Transparency = Toggles.RemoveDecals.Value and 1 or 0
        end
    end)
end)

local ConfigTab = Window:AddTab({
    Name = "Config",
    Icon = "settings"
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})

ThemeManager:SetFolder("l10scripthub")
SaveManager:SetFolder("l10scripthub/fias")

SaveManager:BuildConfigSection(ConfigTab)
ThemeManager:ApplyToTab(ConfigTab)

SaveManager:LoadAutoloadConfig()
