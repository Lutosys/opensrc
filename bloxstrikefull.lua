local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local hitboxsafe = true
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = 'Radon | Bloxstrike',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    Footer = "made by L10"
})

local Tabs = {
    Combat = Window:AddTab('Combat', 'swords'),
    Visuals = Window:AddTab('Visuals', 'eye'),
    Weapons = Window:AddTab('Weapons', 'crosshair'),
    StyleChanger = Window:AddTab('StyleChanger', 'paintbrush'),
    Settings = Window:AddTab('Settings', 'settings'),
}

local SkinsBox = Tabs.StyleChanger:AddLeftGroupbox("Skins", "palette")
local Skins2Box = Tabs.StyleChanger:AddRightGroupbox("Skins 2", "brush")
local getPlayersOnTeam = filtergc("function", {Name = "getPlayersOnTeam"}, true)

local function IsEnemy(p)
    local Counter = getPlayersOnTeam("Counter-Terrorists")
    local Terr = getPlayersOnTeam("Terrorists")
    
    if table.find(Terr, game.Players.LocalPlayer) and table.find(Terr, p) then
        return true
    end

    if table.find(Counter, game.Players.LocalPlayer) and table.find(Counter, p) then
        return true
    end

    return false
end

local ApplySkinTextures = nil

for _, obj in next, getgc() do
    if type(obj) == "function" and debug.getinfo(obj).name == "ApplySkinTextures" then
        ApplySkinTextures = obj
        break 
    end 
end

local function getCurrentWeapon() return Workspace.Camera:FindFirstChildOfClass("Model") end

local Skins = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skins")

local skinList = {}
for key, skin in next, Skins:GetChildren() do
    if #skin:GetChildren() > 1 then
        table.insert(skinList, skin)
    end
end

local midPoint = math.ceil(#skinList / 2)

for i = 1, midPoint do
    local skin = skinList[i]
    SkinsBox:AddDropdown(tostring(skin), {
        Text = tostring(skin),
        Values = skin:GetChildren(),
        Default = 1,
        Multi = false,
    })
end

for i = midPoint + 1, #skinList do
    local skin = skinList[i]
    Skins2Box:AddDropdown(tostring(skin), {
        Text = tostring(skin),
        Values = skin:GetChildren(),
        Default = 1,
        Multi = false,
    })
end

local lastWeapon = nil
local lastSkinValue = nil

task.spawn(function()
    while task.wait(0.1) do
        local currweapon = getCurrentWeapon()
        if currweapon then
            local option = Options[tostring(currweapon)]
            local skinValue = option and option.Value

            if currweapon ~= lastWeapon or skinValue ~= lastSkinValue then
                pcall(function()
                    if skinValue then
                        ApplySkinTextures(currweapon, skinValue.Camera["Factory New"])
                    end
                end)
                lastWeapon = currweapon
                lastSkinValue = skinValue
            end
        else
            lastWeapon = nil
            lastSkinValue = nil
        end
    end
end)

local HitboxList = {"HumanoidRootPart","Head","LeftLowerArm","LowerTorso","RightHand","RightLowerArm","LeftFoot","LeftHand","RightFoot","RightLowerLeg","LeftLowerLeg","RightUpperArm","LeftUpperArm","UpperTorso","RightUpperLeg","LeftUpperLeg"}

local WeaponModsBox = Tabs.Weapons:AddLeftGroupbox("Weapon Mods", "wrench")
local GernadesBox = Tabs.Weapons:AddRightGroupbox("Gernades", "bomb")

GernadesBox:AddToggle("Antiflashbang", {
    Text = "Enable No Flashbang",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

GernadesBox:AddToggle("Antismoke", {
    Text = "Enable No Smoke",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

WeaponModsBox:AddToggle("Firerate", {
    Text = "Enable Firerate Changer",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

WeaponModsBox:AddSlider("FirerateSlider", {
    Text = "Firerate",
    Default = 0.01,
    Min = 0,
    Max = 1,
    Rounding = 3
})

WeaponModsBox:AddToggle("NoRecoil", {
    Text = "Enable No Recoil",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

WeaponModsBox:AddToggle("NoSpread", {
    Text = "Enable No Spread",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

local CombatLegitBox = Tabs.Combat:AddLeftGroupbox("Legit", "target")

CombatLegitBox:AddToggle("Aimbot", {
    Text = "Enable Aimbot",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

Toggles.Aimbot:AddKeyPicker("AimbotHoldkey", {
    Text = "Hold Key",
    Default = "MB2",
    Mode = "Hold",
})

local LegitDependencyBox = CombatLegitBox:AddDependencyBox()

LegitDependencyBox:AddToggle("AimbotUseFovCircle", {
    Text = "Use FOV Circle",
    Default = false,
})

LegitDependencyBox:AddSlider("AimbotFovCircleRadius", {
    Text = "FOV Radius",
    Default = 50,
    Min = 0,
    Max = 300,
    Rounding = 0
})

LegitDependencyBox:AddDropdown("AimbotHitPart", {
    Text = "Hit Selection",
    Values = {
        "HumanoidRootPart",
        "Head", 
        "LeftLowerArm",
        "LowerTorso",
        "RightHand",
        "RightLowerArm",
        "LeftFoot",
        "LeftHand",
        "RightFoot",
        "RightLowerLeg",
        "LeftLowerLeg",
        "RightUpperArm",
        "LeftUpperArm",
        "UpperTorso",
        "RightUpperLeg",
        "LeftUpperLeg"
    },
    Default = "Head",  
    Multi = false,
})

LegitDependencyBox:AddToggle("AimbotTeamCheck", {
    Text = "Enable Team Check",
    Default = true,
})

LegitDependencyBox:AddToggle("AimbotWallCheck", {
    Text = "Enable Wall Check",
    Default = true,
})

CombatLegitBox:AddDivider()

CombatLegitBox:AddToggle("Triggerbot", {
    Text = "Enable Triggerbot",
    Default = false,
})

local LegitDependencyBox2 = CombatLegitBox:AddDependencyBox()

LegitDependencyBox2:AddSlider("TriggerbotDelay", {
    Text = "Delay",
    Default = 0.01,
    Min = 0,
    Max = 1,
    Rounding = 3
})

LegitDependencyBox:SetupDependencies({
    {Toggles.Aimbot, true}
})

LegitDependencyBox2:SetupDependencies({
    {Toggles.Triggerbot, true}
})

local HitboxBox = Tabs.Combat:AddLeftGroupbox("Hitbox Expander", "maximize")

HitboxBox:AddToggle("Hitbox", {
    Text = "Enable Hitbox Expander",
    Default = false,
    Disabled = typeof(hookmetamethod) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

local HitboxDependencyBox = HitboxBox:AddDependencyBox()

HitboxDependencyBox:AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = 7,
    Min = 1,
    Max = 28,
    Rounding = 0
})

HitboxDependencyBox:AddSlider("HitboxTransparency", {
    Text = "Hitbox Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2
})

HitboxDependencyBox:SetupDependencies({
    {Toggles.Hitbox, true}
})

local CombatBlatantBox = Tabs.Combat:AddRightGroupbox("Blatant", "zap")

local RageBlatantBox = Tabs.Combat:AddRightGroupbox("Rage", "flame")

CombatBlatantBox:AddToggle("SilentAim", {
    Text = "Enable Silent Aim",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

local BlatantDependencyBox = CombatBlatantBox:AddDependencyBox()

BlatantDependencyBox:AddToggle("SilentWallbang", {
    Text = "Wallbang",
    Default = false,
})


BlatantDependencyBox:AddToggle("SilentUseFovCircle", {
    Text = "Use FOV Circle",
    Default = false,
})

BlatantDependencyBox:AddSlider("SilentFovCircleRadius", {
    Text = "FOV Radius",
    Default = 50,
    Min = 0,
    Max = 300,
    Rounding = 0
})

BlatantDependencyBox:AddDropdown("SilentHitPart", {
    Text = "Hit Selection",
    Values = {
        "HumanoidRootPart",
        "Head", 
        "LeftLowerArm",
        "LowerTorso",
        "RightHand",
        "RightLowerArm",
        "LeftFoot",
        "LeftHand",
        "RightFoot",
        "RightLowerLeg",
        "LeftLowerLeg",
        "RightUpperArm",
        "LeftUpperArm",
        "UpperTorso",
        "RightUpperLeg",
        "LeftUpperLeg"
    },
    Default = "Head",  
    Multi = false,
})

BlatantDependencyBox:AddToggle("SilentTeamCheck", {
    Text = "Enable Team Check",
    Default = true,
})

BlatantDependencyBox:SetupDependencies({
    {Toggles.SilentAim, true}
})

RageBlatantBox:AddToggle("Ragebot", {
    Text = "Enable Ragebot",
    Default = false,
    Disabled = typeof(hookfunction) ~= "function",
    DisabledTooltip = "This feature is not available on your executor.",
})

local RageDependencyBox = RageBlatantBox:AddDependencyBox()

RageDependencyBox:AddSlider("RageDelay", {
    Text = "Delay",
    Default = 0.01,
    Min = 0,
    Max = 1,
    Rounding = 3
})

RageDependencyBox:AddDropdown("RageHitPart", {
    Text = "Hit Selection",
    Values = {
        "HumanoidRootPart",
        "Head", 
        "LeftLowerArm",
        "LowerTorso",
        "RightHand",
        "RightLowerArm",
        "LeftFoot",
        "LeftHand",
        "RightFoot",
        "RightLowerLeg",
        "LeftLowerLeg",
        "RightUpperArm",
        "LeftUpperArm",
        "UpperTorso",
        "RightUpperLeg",
        "LeftUpperLeg"
    },
    Default = "Head",  
    Multi = false,
})

RageDependencyBox:AddToggle("RagebotVisibleCheck", {
    Text = "Enable Visible Check",
    Default = true,
})

RageDependencyBox:AddToggle("RagebotTeamCheck", {
    Text = "Enable Team Check",
    Default = true,
})

RageDependencyBox:AddToggle("RagebotWallCheck", {
    Text = "Enable Wall Check",
    Default = false,
})

RageDependencyBox:SetupDependencies({
    {Toggles.Ragebot , true}
})

local VisualsESPBox = Tabs.Visuals:AddLeftGroupbox("ESP", "eye")

VisualsESPBox:AddToggle("ESPEnabled", {
    Text = "ESP Enabled",
    Default = false,
})

VisualsESPBox:AddDropdown("ESPBoxType", {
    Text = "Box ESP",
    Values = {"2D Box", "3D Box", "Corner Box", "Disabled"},
    Default = "2D Box",
})

VisualsESPBox:AddToggle("ESPName", {
    Text = "Name ESP",
    Default = false,
})

VisualsESPBox:AddLabel("Name Color"):AddColorPicker("ESPNameColor", {
    Default = Color3.new(1, 1, 1),
    Title = "Name Color",
})

VisualsESPBox:AddToggle("ESPHealth", {
    Text = "Health Bar",
    Default = false,
})

VisualsESPBox:AddToggle("ESPDistance", {
    Text = "Distance ESP",
    Default = false,
})

VisualsESPBox:AddToggle("ESPTracer", {
    Text = "Tracer ESP",
    Default = false,
})

VisualsESPBox:AddDropdown("ESPTracerOrigin", {
    Text = "Tracer Origin",
    Values = {"Bottom", "Top", "Center", "Mouse"},
    Default = "Bottom",
})

VisualsESPBox:AddToggle("ESPSkeleton", {
    Text = "Skeleton ESP",
    Default = false,
})

-- esp was from github/enchaned by ai cuz i cant make good looking esp

local TEAM_COLORS = {
    ["Terrorists"] = Color3.fromRGB(204, 170, 80),      
    ["Counter-Terrorists"] = Color3.fromRGB(100, 149, 200), 
}

local DEFAULT_ESP_COLOR = Color3.new(1, 1, 1)


getgenv().esplib = {
    box = {
        enabled = false,
        type = "2D",
        padding = 1.15,
        fill = Color3.new(1, 1, 1),
        outline = Color3.new(0, 0, 0),
        color = Color3.new(1, 1, 1),
    },
    healthbar = {
        enabled = false,
        fill = Color3.new(0, 1, 0),
        outline = Color3.new(0, 0, 0),
        position = "Top",
    },
    name = {
        enabled = false,
        fill = Color3.new(1, 1, 1),
        size = 13,
    },
    distance = {
        enabled = false,
        fill = Color3.new(1, 1, 1),
        size = 13,
    },
    tracer = {
        enabled = false,
        fill = Color3.new(1, 1, 1),
        outline = Color3.new(0, 0, 0),
        from = "bottom",
    },
    skeleton = {
        enabled = false,
        color = Color3.new(1, 1, 1),
        thickness = 2,
        transparency = 1,
    }
}

local esplib = getgenv().esplib
if not esplib then
    esplib = {
        box = {
            enabled = true,
            type = "2D",
            padding = 1.15,
            fill = Color3.new(1,1,1),
            outline = Color3.new(0,0,0),
            color = Color3.new(1,1,1),
        },
        healthbar = {
            enabled = true,
            fill = Color3.new(0,1,0),
            outline = Color3.new(0,0,0),
            position = "Left",
        },
        name = {
            enabled = true,
            fill = Color3.new(1,1,1),
            size = 13,
        },
        distance = {
            enabled = true,
            fill = Color3.new(1,1,1),
            size = 13,
        },
        tracer = {
            enabled = true,
            fill = Color3.new(1,1,1),
            outline = Color3.new(0,0,0),
            from = "bottom",
        },
        skeleton = {
            enabled = false,
            color = Color3.new(0, 1, 1),
            thickness = 2,
            transparency = 1,
        },
        headcircle = {
            enabled = false,
            fill = Color3.new(1,1,1),
            outline = Color3.new(0,0,0),
            radius = 20,
            thickness = 2,
        },
    }
    getgenv().esplib = esplib
end

local espinstances = {}
getgenv().esplib_instances = espinstances

local espfunctions = {}

local run_service = game:GetService("RunService")
local players = game:GetService("Players")
local user_input_service = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local abs = math.abs
local huge = math.huge
local min_fn = math.min
local floor = math.floor
local clamp = math.clamp

local SKELETON_BONES_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local SKELETON_BONES_R15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local AABB_CORNER_SIGNS = {
    {0,0,0}, {1,0,0}, {0,1,0}, {1,1,0},
    {0,0,1}, {1,0,1}, {0,1,1}, {1,1,1},
}

local BOX_3D_EDGES = {
    {1,2},{2,4},{4,3},{3,1},
    {5,6},{6,8},{8,7},{7,5},
    {1,5},{2,6},{3,7},{4,8},
}

local WorldToViewportPoint = camera.WorldToViewportPoint

local boxCfg = esplib.box
local healthCfg = esplib.healthbar
local nameCfg = esplib.name
local distCfg = esplib.distance
local tracerCfg = esplib.tracer
local skeletonCfg = esplib.skeleton
local headCfg = esplib.headcircle

local partHalfExtentCache = setmetatable({}, { __mode = "k" })

local function get_part_half_extent(part)
    local padding = boxCfg.padding
    local cache = partHalfExtentCache[part]

    if not cache or cache.padding ~= padding then
        local size = part.Size
        cache = {
            hx = size.X * 0.5 * padding,
            hy = size.Y * 0.5 * padding,
            hz = size.Z * 0.5 * padding,
            padding = padding,
        }
        partHalfExtentCache[part] = cache
    end

    return cache.hx, cache.hy, cache.hz
end

local function compute_world_aabb(parts)
    local minX, minY, minZ = huge, huge, huge
    local maxX, maxY, maxZ = -huge, -huge, -huge

    for i = 1, #parts do
        local part = parts[i]
        local hx, hy, hz = get_part_half_extent(part)

        local px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22 = part.CFrame:GetComponents()

        local ehx = abs(r00) * hx + abs(r01) * hy + abs(r02) * hz
        local ehy = abs(r10) * hx + abs(r11) * hy + abs(r12) * hz
        local ehz = abs(r20) * hx + abs(r21) * hy + abs(r22) * hz

        local x1, x2 = px - ehx, px + ehx
        local y1, y2 = py - ehy, py + ehy
        local z1, z2 = pz - ehz, pz + ehz

        if x1 < minX then minX = x1 end
        if y1 < minY then minY = y1 end
        if z1 < minZ then minZ = z1 end
        if x2 > maxX then maxX = x2 end
        if y2 > maxY then maxY = y2 end
        if z2 > maxZ then maxZ = z2 end
    end

    if minX == huge then
        return nil
    end

    return minX, minY, minZ, maxX, maxY, maxZ
end

local function project_aabb_to_screen(minX, minY, minZ, maxX, maxY, maxZ)
    local sMinX, sMinY = huge, huge
    local sMaxX, sMaxY = -huge, -huge
    local onscreen = false

    for i = 1, 8 do
        local s = AABB_CORNER_SIGNS[i]
        local wx = s[1] == 0 and minX or maxX
        local wy = s[2] == 0 and minY or maxY
        local wz = s[3] == 0 and minZ or maxZ

        local pos, visible = WorldToViewportPoint(camera, Vector3.new(wx, wy, wz))
        if visible then
            onscreen = true
            local x, y = pos.X, pos.Y
            if x < sMinX then sMinX = x end
            if y < sMinY then sMinY = y end
            if x > sMaxX then sMaxX = x end
            if y > sMaxY then sMaxY = y end
        end
    end

    if not onscreen then
        return nil, nil, false
    end

    return Vector2.new(sMinX, sMinY), Vector2.new(sMaxX, sMaxY), true
end

local function project_aabb_corners_3d(minX, minY, minZ, maxX, maxY, maxZ)
    local screenCorners = {}
    local onscreen = false

    for i = 1, 8 do
        local s = AABB_CORNER_SIGNS[i]
        local wx = s[1] == 0 and minX or maxX
        local wy = s[2] == 0 and minY or maxY
        local wz = s[3] == 0 and minZ or maxZ

        local pos, visible = WorldToViewportPoint(camera, Vector3.new(wx, wy, wz))
        screenCorners[i] = Vector2.new(pos.X, pos.Y)
        if visible then onscreen = true end
    end

    return screenCorners, onscreen
end

local function get_instance_color(instance, colorGetter)
    if colorGetter then
        return colorGetter(instance)
    end
    return boxCfg.fill
end

local function ensure_character_parts(instance, data)
    if data.partlist then
        return data.partlist
    end

    local list = {}
    local indexMap = setmetatable({}, { __mode = "k" })

    local function addPart(p)
        if p:IsA("BasePart") and not indexMap[p] then
            list[#list + 1] = p
            indexMap[p] = #list

            local conn
            conn = p:GetPropertyChangedSignal("Size"):Connect(function()
                partHalfExtentCache[p] = nil
            end)
            data.sizeConns = data.sizeConns or {}
            data.sizeConns[p] = conn
        end
    end

    local function removePart(p)
        local idx = indexMap[p]
        if idx then
            local lastIdx = #list
            local lastPart = list[lastIdx]
            list[idx] = lastPart
            indexMap[lastPart] = idx
            list[lastIdx] = nil
            indexMap[p] = nil

            if data.sizeConns and data.sizeConns[p] then
                data.sizeConns[p]:Disconnect()
                data.sizeConns[p] = nil
            end
        end
    end

    if instance:IsA("Model") then
        for _, p in next, instance:GetDescendants() do
            addPart(p)
        end
        data.partConnAdd = instance.DescendantAdded:Connect(addPart)
        data.partConnRemove = instance.DescendantRemoving:Connect(removePart)
    elseif instance:IsA("BasePart") then
        addPart(instance)
    end

    data.partlist = list
    return list
end

function espfunctions.add_box(instance)
    if not instance or (espinstances[instance] and espinstances[instance].box) then return end

    local box = {}

    local outline = Drawing.new("Square")
    outline.Thickness = 3
    outline.Filled = false
    outline.Transparency = 1
    outline.Visible = false

    local fill = Drawing.new("Square")
    fill.Thickness = 1
    fill.Filled = false
    fill.Transparency = 1
    fill.Visible = false

    box.outline = outline
    box.fill = fill
    box.corner_fill = {}
    box.corner_outline = {}

    for i = 1, 8 do
        local o = Drawing.new("Line")
        o.Thickness = 3
        o.Transparency = 1
        o.Visible = false

        local f = Drawing.new("Line")
        f.Thickness = 1
        f.Transparency = 1
        f.Visible = false

        box.corner_fill[i] = f
        box.corner_outline[i] = o
    end

    box.box_3d_lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false
        box.box_3d_lines[i] = line
    end

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].box = box
end

function espfunctions.add_healthbar(instance)
    if not instance or (espinstances[instance] and espinstances[instance].healthbar) then return end

    local outline = Drawing.new("Square")
    outline.Thickness = 1
    outline.Filled = true
    outline.Transparency = 1

    local fill = Drawing.new("Square")
    fill.Filled = true
    fill.Transparency = 1

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].healthbar = {
        outline = outline,
        fill = fill,
    }
end

function espfunctions.add_name(instance)
    if not instance or (espinstances[instance] and espinstances[instance].name) then return end

    local text = Drawing.new("Text")
    text.Center = true
    text.Outline = true
    text.Font = 1
    text.Transparency = 1

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].name = text
end

function espfunctions.add_distance(instance)
    if not instance or (espinstances[instance] and espinstances[instance].distance) then return end

    local text = Drawing.new("Text")
    text.Center = true
    text.Outline = true
    text.Font = 1
    text.Transparency = 1

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].distance = text
end

function espfunctions.add_tracer(instance)
    if not instance or (espinstances[instance] and espinstances[instance].tracer) then return end

    local outline = Drawing.new("Line")
    outline.Thickness = 3
    outline.Transparency = 1

    local fill = Drawing.new("Line")
    fill.Thickness = 1
    fill.Transparency = 1

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].tracer = {
        outline = outline,
        fill = fill,
    }
end

function espfunctions.add_skeleton(instance, options)
    if not instance or (espinstances[instance] and espinstances[instance].skeleton) then return end

    options = options or {}
    local thickness = options.thickness or skeletonCfg.thickness

    local isR15 = instance:FindFirstChild("UpperTorso") ~= nil
    local boneNames = isR15 and SKELETON_BONES_R15 or SKELETON_BONES_R6

    local lines = {}
    local bone_parts = {}

    for i = 1, #boneNames do
        local line = Drawing.new("Line")
        line.Thickness = thickness
        line.Transparency = 1
        line.Visible = false
        lines[i] = line

        local partA = instance:FindFirstChild(boneNames[i][1])
        local partB = instance:FindFirstChild(boneNames[i][2])
        bone_parts[i] = { partA, partB }
    end

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].skeleton = {
        lines = lines,
        bone_parts = bone_parts,
        screenCache = {},
    }
end

function espfunctions.add_headcircle(instance)
    if not instance or (espinstances[instance] and espinstances[instance].headcircle) then return end

    local circle = Drawing.new("Circle")
    circle.Thickness = (headCfg and headCfg.thickness) or 2
    circle.Filled = false
    circle.Transparency = 1
    circle.Visible = false
    circle.NumSides = 32

    espinstances[instance] = espinstances[instance] or {}
    espinstances[instance].headcircle = circle
end

local function hide_all(data)
    if data.box then
        data.box.outline.Visible = false
        data.box.fill.Visible = false
        local cf, co, l3 = data.box.corner_fill, data.box.corner_outline, data.box.box_3d_lines
        for i = 1, #cf do cf[i].Visible = false end
        for i = 1, #co do co[i].Visible = false end
        for i = 1, #l3 do l3[i].Visible = false end
    end
    if data.healthbar then
        data.healthbar.outline.Visible = false
        data.healthbar.fill.Visible = false
    end
    if data.name then data.name.Visible = false end
    if data.distance then data.distance.Visible = false end
    if data.tracer then
        data.tracer.outline.Visible = false
        data.tracer.fill.Visible = false
    end
    if data.skeleton then
        local lines = data.skeleton.lines
        for i = 1, #lines do lines[i].Visible = false end
    end
    if data.headcircle then data.headcircle.Visible = false end
end

local function cleanup_instance(instance, data)
    if data.box then
        data.box.outline:Remove()
        data.box.fill:Remove()
        for _, line in next, (data.box.corner_fill) do line:Remove() end
        for _, line in next, (data.box.corner_outline) do line:Remove() end
        for _, line in next, (data.box.box_3d_lines) do line:Remove() end
    end
    if data.healthbar then
        data.healthbar.outline:Remove()
        data.healthbar.fill:Remove()
    end
    if data.name then data.name:Remove() end
    if data.distance then data.distance:Remove() end
    if data.tracer then
        data.tracer.outline:Remove()
        data.tracer.fill:Remove()
    end
    if data.skeleton then
        for _, line in next, (data.skeleton.lines) do line:Remove() end
    end
    if data.headcircle then data.headcircle:Remove() end

    if data.partConnAdd then data.partConnAdd:Disconnect() end
    if data.partConnRemove then data.partConnRemove:Disconnect() end
    if data.sizeConns then
        for _, conn in next, (data.sizeConns) do
            conn:Disconnect()
        end
    end
end

local function get_cached_screen_pos(cache, part)
    local cached = cache[part]
    if cached then
        return cached[1], cached[2]
    end
    local pos, vis = WorldToViewportPoint(camera, part.Position)
    local sp = Vector2.new(pos.X, pos.Y)
    cache[part] = { sp, vis }
    return sp, vis
end

run_service.RenderStepped:Connect(function()
    local camPos = camera.CFrame.Position
    local colorGetter = getgenv().esplib_get_color 
    local vp = camera.ViewportSize

    local boxEnabled = boxCfg.enabled
    local boxType = boxCfg.type
    local healthEnabled = healthCfg.enabled
    local nameEnabled = nameCfg.enabled
    local distEnabled = distCfg.enabled
    local tracerEnabled = tracerCfg.enabled
    local skeletonEnabled = skeletonCfg.enabled
    local headEnabled = headCfg and headCfg.enabled
    local tracerFrom = tracerCfg.from

    for instance, data in next, espinstances do
        if not instance or not instance.Parent then
            cleanup_instance(instance, data)
            espinstances[instance] = nil
            continue
        end

        if instance:IsA("Model") and not instance.PrimaryPart then
            hide_all(data)
            continue
        end

        if not data.humanoid or not data.humanoid.Parent then
            data.humanoid = instance:FindFirstChildOfClass("Humanoid")
        end
        local humanoid = data.humanoid

        if humanoid and humanoid.Health <= 0 then
            hide_all(data)
            continue
        end

        local needBox = boxEnabled and data.box ~= nil
        local needHealthbar = healthEnabled and data.healthbar ~= nil
        local needName = nameEnabled and data.name ~= nil
        local needDistance = distEnabled and data.distance ~= nil
        local needTracer = tracerEnabled and data.tracer ~= nil
        local needSkeleton = skeletonEnabled and data.skeleton ~= nil
        local needHeadcircle = headEnabled and data.headcircle ~= nil

        if data.box and not needBox then
            data.box.outline.Visible = false
            data.box.fill.Visible = false
            local cf, co, l3 = data.box.corner_fill, data.box.corner_outline, data.box.box_3d_lines
            for i = 1, 8 do cf[i].Visible = false; co[i].Visible = false end
            for i = 1, 12 do l3[i].Visible = false end
        end
        if data.healthbar and not needHealthbar then
            data.healthbar.outline.Visible = false
            data.healthbar.fill.Visible = false
        end
        if data.name and not needName then
            data.name.Visible = false
        end
        if data.distance and not needDistance then
            data.distance.Visible = false
        end
        if data.tracer and not needTracer then
            data.tracer.outline.Visible = false
            data.tracer.fill.Visible = false
        end
        if data.skeleton and not needSkeleton then
            local lines = data.skeleton.lines
            for i = 1, #lines do lines[i].Visible = false end
        end
        if data.headcircle and not needHeadcircle then
            data.headcircle.Visible = false
        end

        if not (needBox or needHealthbar or needName or needDistance or needTracer or needSkeleton or needHeadcircle) then
            continue
        end

        local teamColor = get_instance_color(instance, colorGetter)
        local parts = ensure_character_parts(instance, data)

        local min, max, onscreen = nil, nil, false
        local corners_3d, onscreen_3d = nil, false

        if needBox or needHealthbar or needName or needDistance or needTracer then
            local aMinX, aMinY, aMinZ, aMaxX, aMaxY, aMaxZ = compute_world_aabb(parts)
            if aMinX then
                min, max, onscreen = project_aabb_to_screen(aMinX, aMinY, aMinZ, aMaxX, aMaxY, aMaxZ)
                if needBox and boxType == "3D" then
                    corners_3d, onscreen_3d = project_aabb_corners_3d(aMinX, aMinY, aMinZ, aMaxX, aMaxY, aMaxZ)
                end
            end
        end

        if data.box then
            local box = data.box

            if needBox and onscreen then
                local x, y = min.X, min.Y
                local w, h = (max - min).X, (max - min).Y
                local len = min_fn(w, h) * 0.25

                if boxType == "2D" then
                    box.outline.Position = min
                    box.outline.Size = max - min
                    box.outline.Color = boxCfg.outline
                    box.outline.Visible = true

                    box.fill.Position = min
                    box.fill.Size = max - min
                    box.fill.Color = teamColor
                    box.fill.Visible = true

                    local cf, co, l3 = box.corner_fill, box.corner_outline, box.box_3d_lines
                    for i = 1, 8 do cf[i].Visible = false; co[i].Visible = false end
                    for i = 1, 12 do l3[i].Visible = false end

                elseif boxType == "Corner" then
                    local corners = {
                        {Vector2.new(x, y),             Vector2.new(x + len, y)},
                        {Vector2.new(x, y),             Vector2.new(x, y + len)},
                        {Vector2.new(x + w - len, y),   Vector2.new(x + w, y)},
                        {Vector2.new(x + w, y),         Vector2.new(x + w, y + len)},
                        {Vector2.new(x, y + h),         Vector2.new(x + len, y + h)},
                        {Vector2.new(x, y + h - len),   Vector2.new(x, y + h)},
                        {Vector2.new(x + w - len, y + h), Vector2.new(x + w, y + h)},
                        {Vector2.new(x + w, y + h - len), Vector2.new(x + w, y + h)},
                    }

                    for i = 1, 8 do
                        local from, to = corners[i][1], corners[i][2]
                        local dir = (to - from).Unit
                        box.corner_outline[i].From = from - dir
                        box.corner_outline[i].To = to + dir
                        box.corner_outline[i].Color = boxCfg.outline
                        box.corner_outline[i].Visible = true

                        box.corner_fill[i].From = from
                        box.corner_fill[i].To = to
                        box.corner_fill[i].Color = teamColor
                        box.corner_fill[i].Visible = true
                    end

                    box.outline.Visible = false
                    box.fill.Visible = false
                    for i = 1, 12 do box.box_3d_lines[i].Visible = false end

                elseif boxType == "3D" then
                    if corners_3d and #corners_3d == 8 then
                        for i = 1, 12 do
                            local edge = BOX_3D_EDGES[i]
                            box.box_3d_lines[i].From = corners_3d[edge[1]]
                            box.box_3d_lines[i].To = corners_3d[edge[2]]
                            box.box_3d_lines[i].Color = teamColor
                            box.box_3d_lines[i].Visible = onscreen_3d
                        end
                    else
                        for i = 1, 12 do box.box_3d_lines[i].Visible = false end
                    end

                    box.outline.Visible = false
                    box.fill.Visible = false
                    for i = 1, 8 do
                        box.corner_fill[i].Visible = false
                        box.corner_outline[i].Visible = false
                    end
                end
            else
                box.outline.Visible = false
                box.fill.Visible = false
                for i = 1, 8 do
                    box.corner_fill[i].Visible = false
                    box.corner_outline[i].Visible = false
                end
                for i = 1, 12 do box.box_3d_lines[i].Visible = false end
            end
        end

        if data.healthbar then
            local outline, fill = data.healthbar.outline, data.healthbar.fill

            if not needHealthbar or not onscreen then
                outline.Visible = false
                fill.Visible = false
            else
                if humanoid then
                    local height = max.Y - min.Y
                    local padding = 1
                    local x = min.X - 3 - 1 - padding
                    local y = min.Y - padding
                    local health = clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    local fillheight = height * health

                    outline.Color = healthCfg.outline
                    outline.Position = Vector2.new(x, y)
                    outline.Size = Vector2.new(1 + 2 * padding, height + 2 * padding)
                    outline.Visible = true

                    fill.Color = healthCfg.fill
                    fill.Position = Vector2.new(x + padding, y + (height + padding) - fillheight)
                    fill.Size = Vector2.new(1, fillheight)
                    fill.Visible = true
                else
                    outline.Visible = false
                    fill.Visible = false
                end
            end
        end

        if data.name then
            if needName and onscreen then
                local text = data.name
                local center_x = (min.X + max.X) / 2
                local y = min.Y - 15

                local name_str = instance.Name
                if humanoid then
                    if not data.player then
                        data.player = players:GetPlayerFromCharacter(instance)
                    end
                    if data.player then name_str = data.player.Name end
                end

                text.Text = name_str
                text.Size = nameCfg.size
                text.Color = nameCfg.fill
                text.Position = Vector2.new(center_x, y)
                text.Visible = true
            else
                data.name.Visible = false
            end
        end

        if data.distance then
            if needDistance and onscreen then
                local text = data.distance
                local center_x = (min.X + max.X) / 2
                local y = max.Y + 5
                local dist = 999

                if instance:IsA("Model") and instance.PrimaryPart then
                    dist = (camPos - instance.PrimaryPart.Position).Magnitude
                elseif instance:IsA("BasePart") then
                    dist = (camPos - instance.Position).Magnitude
                end

                text.Text = tostring(floor(dist)) .. "m"
                text.Size = distCfg.size
                text.Color = distCfg.fill
                text.Position = Vector2.new(center_x, y)
                text.Visible = true
            else
                data.distance.Visible = false
            end
        end

        if data.tracer then
            if needTracer and onscreen then
                local outline, fill = data.tracer.outline, data.tracer.fill
                local from_pos

                if tracerFrom == "mouse" then
                    local ml = user_input_service:GetMouseLocation()
                    from_pos = Vector2.new(ml.X, ml.Y)
                elseif tracerFrom == "top" then
                    from_pos = Vector2.new(vp.X / 2, 0)
                elseif tracerFrom == "center" then
                    from_pos = Vector2.new(vp.X / 2, vp.Y / 2)
                else
                    from_pos = Vector2.new(vp.X / 2, vp.Y)
                end

                local to_pos = (min + max) / 2

                outline.From = from_pos
                outline.To = to_pos
                outline.Color = tracerCfg.outline
                outline.Visible = true

                fill.From = from_pos
                fill.To = to_pos
                fill.Color = teamColor
                fill.Visible = true
            else
                data.tracer.outline.Visible = false
                data.tracer.fill.Visible = false
            end
        end

        if data.skeleton then
            if needSkeleton and onscreen then
                local bone_parts = data.skeleton.bone_parts
                local lines = data.skeleton.lines
                local screenCache = data.skeleton.screenCache
                for k in next, screenCache do screenCache[k] = nil end

                for i = 1, #bone_parts do
                    local pair = bone_parts[i]
                    local partA, partB = pair[1], pair[2]
                    local line = lines[i]

                    if partA and partB and partA.Parent and partB.Parent then
                        local posA, visA = get_cached_screen_pos(screenCache, partA)
                        local posB, visB = get_cached_screen_pos(screenCache, partB)

                        if visA and visB then
                            line.From = posA
                            line.To = posB
                            line.Color = teamColor
                            line.Thickness = skeletonCfg.thickness
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            else
                local lines = data.skeleton.lines
                for i = 1, #lines do lines[i].Visible = false end
            end
        end

        if data.headcircle then
            if needHeadcircle and onscreen then
                local circle = data.headcircle
                if not data.head or not data.head.Parent then
                    data.head = instance:FindFirstChild("Head")
                end
                local head = data.head

                if head then
                    local head_pos, visible = WorldToViewportPoint(camera, head.Position)
                    if visible then
                        circle.Position = Vector2.new(head_pos.X, head_pos.Y)
                        circle.Radius = headCfg.radius or 20
                        circle.Color = headCfg.fill
                        circle.Thickness = headCfg.thickness or 2
                        circle.Visible = true
                    else
                        circle.Visible = false
                    end
                else
                    circle.Visible = false
                end
            else
                data.headcircle.Visible = false
            end
        end
    end
end)

for k, v in next, espfunctions do
    esplib[k] = v
end

local espCharacters = {}

local function updateESPSettings()
    local boxType = Options.ESPBoxType.Value
    if boxType == "Disabled" then
        esplib.box.enabled = false
    else
        esplib.box.enabled = Toggles.ESPEnabled.Value
        esplib.box.type = boxType:gsub(" Box", "")
    end

    esplib.name.enabled = Toggles.ESPEnabled.Value and Toggles.ESPName.Value
    esplib.name.fill = Options.ESPNameColor.Value

    esplib.healthbar.enabled = Toggles.ESPEnabled.Value and Toggles.ESPHealth.Value

    esplib.distance.enabled = Toggles.ESPEnabled.Value and Toggles.ESPDistance.Value

    esplib.tracer.enabled = Toggles.ESPEnabled.Value and Toggles.ESPTracer.Value
    esplib.tracer.from = Options.ESPTracerOrigin.Value:lower()

    esplib.skeleton.enabled = Toggles.ESPEnabled.Value and Toggles.ESPSkeleton.Value
end

local function addEspToCharacter(character, player)
    if not character then return end
    if espCharacters[character] then return end

    esplib.add_box(character)
    esplib.add_name(character)
    esplib.add_healthbar(character)
    esplib.add_distance(character)
    esplib.add_tracer(character)
    esplib.add_skeleton(character, {
        thickness = 2,
        transparency = 1,
    })

    espCharacters[character] = { player = player }
end

local function removeEspFromCharacter(character)
    if not character then return end
    espCharacters[character] = nil
end

local espActive = true

local function setupPlayerEsp(player)
    if player == Players.LocalPlayer then return end

    if player.Character and espActive then
        addEspToCharacter(player.Character, player)
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        if espActive then
            addEspToCharacter(character, player)
        end
    end)

    player.CharacterRemoving:Connect(function(character)
        removeEspFromCharacter(character)
    end)
end

local function refreshAllCharacters()
    for character, _ in next, espCharacters do
        removeEspFromCharacter(character)
    end
    for _, player in next, Players:GetPlayers() do
        if player ~= Players.LocalPlayer and player.Character then
            addEspToCharacter(player.Character, player)
        end
    end
end

Toggles.ESPEnabled:OnChanged(function()
    updateESPSettings()
    refreshAllCharacters()
end)

Options.ESPBoxType:OnChanged(function()
    updateESPSettings()
end)

Toggles.ESPName:OnChanged(function()
    updateESPSettings()
end)

Options.ESPNameColor:OnChanged(function()
    updateESPSettings()
end)

Toggles.ESPHealth:OnChanged(function()
    updateESPSettings()
end)

Toggles.ESPDistance:OnChanged(function()
    updateESPSettings()
end)

Toggles.ESPTracer:OnChanged(function()
    updateESPSettings()
end)

Options.ESPTracerOrigin:OnChanged(function()
    updateESPSettings()
end)

Toggles.ESPSkeleton:OnChanged(function()
    updateESPSettings()
end)

for _, player in next, Players:GetPlayers() do
    setupPlayerEsp(player)
end

Players.PlayerAdded:Connect(function(player)
    setupPlayerEsp(player)
end)

updateESPSettings()

local function clearAllEsp()
    for character, _ in next, espCharacters do
        removeEspFromCharacter(character)
    end
end

local function restoreAllEsp()
    for _, player in next, Players:GetPlayers() do
        if player ~= Players.LocalPlayer and player.Character then
            addEspToCharacter(player.Character, player)
        end
    end
end

LocalPlayer.CharacterRemoving:Connect(function()
    espActive = false
    clearAllEsp()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    espActive = true
    restoreAllEsp()
end)

if LocalPlayer.Character then
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            espActive = false
            clearAllEsp()
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.Died:Connect(function()
            espActive = false
            clearAllEsp()
        end)
    end
end)

local SilentFovCircle = Drawing.new("Circle")
SilentFovCircle.Position = Workspace.CurrentCamera.ViewportSize / 2
SilentFovCircle.Radius = 70
SilentFovCircle.Color = Color3.fromRGB(255, 0, 0)
SilentFovCircle.Filled = false
SilentFovCircle.NumSides = 128
SilentFovCircle.Thickness = 1
SilentFovCircle.Visible = false

local AimbotFovCircle = Drawing.new("Circle")
AimbotFovCircle.Position = Workspace.CurrentCamera.ViewportSize / 2
AimbotFovCircle.Radius = 70
AimbotFovCircle.Color = Color3.fromRGB(0, 255, 0)
AimbotFovCircle.Filled = false
AimbotFovCircle.NumSides = 128
AimbotFovCircle.Thickness = 1
AimbotFovCircle.Visible = false

local SilentTarget = nil
local AimbotTarget = nil
local RageTarget = nil

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local frameCounter = 0

local function isVisible(target)
    rayParams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
    local result = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position, target.Position - Workspace.CurrentCamera.CFrame.Position, rayParams)
    if result then
        return Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    end
    return true
end

local function FindAllTargets()
    local camera = Workspace.CurrentCamera
    local lchar = Players.LocalPlayer.Character
    if not lchar or not lchar:FindFirstChild("Head") then return end
    local lHeadPos = lchar.Head.Position
    local screenCenter = camera.ViewportSize / 2

    local sDist, sClose = math.huge, nil
    local aDist, aClose = math.huge, nil
    local rDist, rClose = math.huge, nil

    for _, v in next, Players:GetPlayers() do
        if v == LocalPlayer then continue end
        local char = v.Character
        if not char then continue end
        if char:GetAttribute("Dead") then continue end
        if char:GetAttribute("Invincible") then continue end

        local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
		
        local isTeam = IsEnemy(v)

        if Toggles.Ragebot.Value and isTeam == false then
            local rPart = char:FindFirstChild(Options.RageHitPart.Value) or targetPart
            local alive = true
            if Toggles.RagebotVisibleCheck.Value and not onScreen then alive = false end
            if alive and Toggles.RagebotWallCheck.Value and not isVisible(rPart) then alive = false end
            if alive then
                local rd = (lHeadPos - rPart.Position).Magnitude
                if rd < rDist then rDist = rd; rClose = rPart end
            end
        end
        if Toggles.SilentAim.Value and onScreen then
            if not Toggles.SilentTeamCheck.Value or not isTeam then
				local sd = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if sd <= ((Toggles.SilentUseFovCircle.Value and SilentFovCircle.Radius) or 999999) then
                    if sd < sDist then 
						if not Toggles.SilentWallbang.Value then
                            if not isVisible(targetPart) then
                                continue
                            end
                        end
                        sDist = sd; 
                        sClose = targetPart 
                    end
                end
            end
        end

        if Toggles.Aimbot.Value and onScreen then
            if not Toggles.AimbotTeamCheck.Value or not isTeam then
                local ad = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if ad <= ((Toggles.AimbotUseFovCircle.Value and AimbotFovCircle.Radius) or 999999) then
                    if not Toggles.AimbotWallCheck.Value or isVisible(targetPart) then
                        if ad < aDist then aDist = ad; aClose = targetPart end
                    end
                end
            end
        end
    end

    SilentTarget = sClose
    AimbotTarget = aClose
    RageTarget = rClose
end

RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1

    SilentFovCircle.Position = Workspace.CurrentCamera.ViewportSize / 2
    AimbotFovCircle.Position = Workspace.CurrentCamera.ViewportSize / 2
    SilentFovCircle.Visible = Toggles.SilentAim.Value and Toggles.SilentUseFovCircle.Value
    AimbotFovCircle.Visible = Toggles.Aimbot.Value and Toggles.AimbotUseFovCircle.Value
    SilentFovCircle.Radius = Options.SilentFovCircleRadius.Value
    AimbotFovCircle.Radius = Options.AimbotFovCircleRadius.Value

    if frameCounter % 3 == 0 then
        FindAllTargets()
    end

    for _, player in next, Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if Toggles.Hitbox.Value and not IsEnemy(player) and hitboxsafe then
                hrp.Size = Vector3.new(Options.HitboxSize.Value, Options.HitboxSize.Value, Options.HitboxSize.Value)
                hrp.Transparency = Options.HitboxTransparency.Value
            else
                if hrp.Size.X ~= Vector3.new(2,2,2) then
                    hrp.Size = Vector3.new(2, 2, 2)
                    hrp.Transparency = 1
                end
            end
        end
    end
end)

local original = {}
local firerateobjs = {}
local SendFunc = nil
local updateCam = nil
local getCurrentEquipped = nil

pcall(function()
    for _, obj in next, getgc(true) do  
        if type(obj) == "table" and rawget(obj, "FireRate") then
            pcall(function()
                table.insert(original, table.clone(obj))
                table.insert(firerateobjs, obj)
            end)
        end
        if type(obj) == "table" and rawget(obj, "setWeaponRecoil") then
            pcall(function()
                local oldSetWeaponRecoil
                oldSetWeaponRecoil = hookfunction(obj.setWeaponRecoil, function(...)
                    if Toggles.NoRecoil.Value then
                        return
                    end
                    return oldSetWeaponRecoil(...)
                end)
            end)
        end
        if type(obj) == "function" and debug.getinfo(obj).name == "calculateRecoilOffset" then
            pcall(function()
                local calculateRecoilOffset
                calculateRecoilOffset = hookfunction(obj, function(...) 
                    if Toggles.NoRecoil.Value then
                        return UDim2.new() 
                    end
                    return calculateRecoilOffset(...)
                end)
            end)
        end 
        if type(obj) == "table" and rawget(obj, "weaponKick") then
            pcall(function()
                local oldweaponkick
                oldweaponkick = hookfunction(obj.weaponKick, function(p1,p2)
                    if Toggles.NoRecoil.Value then
                        return
                    end
                    return oldweaponkick(p1,p2)
                end)
            end)
        end 
        
        if type(obj) == "table" and rawget(obj, "getTrueSpread") then
            pcall(function()
                local oldgettruespread
                oldgettruespread = hookfunction(obj.getTrueSpread, function(p1)  
                    if Toggles.NoSpread.Value then
                        return 0
                    end
                    return oldgettruespread(p1)
                end)
            end)
        end

        if type(obj) == "function" and debug.getinfo(obj).name == "Flash" then
            pcall(function()
                local oldflash
                oldflash = hookfunction(obj, function(...)
                    if Toggles.Antiflashbang.Value then
                        return
                    end
                    return oldflash(...)
                end)
            end)
        end 
        if type(obj) == "function" and debug.getinfo(obj).name == "CreateVoxel" and debug.getupvalue(obj, 1) and tostring(debug.getupvalue(obj, 1)) == "Smoke" then
            pcall(function()
                local oldsmoke
                oldsmoke = hookfunction(obj, function(...) 
                    if Toggles.Antismoke.Value then
                        return
                    end
                    return oldsmoke(...)
                end) 
            end)
        end
        if type(obj) == "table" and rawget(obj, "shoot") then
            if obj.shoot and typeof(obj.shoot) == "function" and #debug.getupvalues(obj.shoot) == 26 then
                pcall(function()
                    SendFunc = debug.getupvalue(obj.shoot, 14).Inventory.ShootWeapon.Send
                end)
            end
        end
        if type(obj) == 'table' and rawget(obj, "getCurrentEquipped") then
            pcall(function()
                getCurrentEquipped = obj.getCurrentEquipped
            end)
        end
    end
end)

pcall(function(...)
    updateCam = filtergc("table", {Keys = {"updateCamera"}}, true).updateCamera
end)

local function getEquipped()
    local success, result = pcall(function()
        return debug.getupvalue(getCurrentEquipped, 1).CurrentEquipped
    end)

    if not success then
        return nil    
    end

    return result
end

local Weapon = nil

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if getEquipped then
                Weapon = getEquipped()
            end
        end)
    end
end)


local oldUpdateCam
local succes, errorms = pcall(function(...)
    oldUpdateCam = hookfunction(updateCam, function(p1)
        if Toggles.Aimbot and Toggles.Aimbot.Value and AimbotTarget
            and Options.AimbotHoldkey and Options.AimbotHoldkey:GetState() then
            local ok, lookCF = pcall(function()
                return CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, AimbotTarget.Position)
            end)
            if ok and lookCF then p1 = lookCF end
        end
        return oldUpdateCam(p1)
    end)
end)

local old56
pcall(function()
    old56 = hookfunction(task.wait, function(t)
        if t == 5 then
            hitboxsafe = true
            t = 9e9
        end 
        return old56(t)
    end)
end)

task.spawn(function()
    repeat 
        wait()
    until hitboxsafe

    Library:Notify({
        Title = "Success",
        Description = "Hitbox will now work",
        Time = 4,
    })
end)

task.spawn(function()
    while true do
        task.wait(Options.RageDelay.Value or 0.02)  
        if Toggles.Ragebot.Value and RageTarget and Weapon and Weapon.IsEquipped and Weapon.Rounds > 0 then
            Weapon:shoot()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(Options.TriggerbotDelay.Value or 0)
        if Toggles.Triggerbot.Value then
            local mouse = LocalPlayer:GetMouse()
            if mouse and mouse.Target then
                local char = mouse.Target:FindFirstAncestorOfClass("Model")
                if not char then continue end

                local player = Players:GetPlayerFromCharacter(char)
                if not player then continue end 

                if char:GetAttribute("Dead") then continue end
                if char:GetAttribute("Invincible") then continue end

                if IsEnemy(player) then
                    if Weapon and Weapon.IsEquipped and Weapon.Rounds > 0 then
                        Weapon:shoot()
                    end
                end
            end
        end 
    end
end)

local oldshoot
local success3, errormessage3 = pcall(function(...)
    oldshoot = hookfunction(SendFunc, function(...)
        local args = {...}
        if args[1].Bullets[1].Hits[1] then
            if Toggles.Ragebot.Value and RageTarget then
                args[1].Bullets[1].Hits[1].Instance = RageTarget
                args[1].Bullets[1].Hits[1].Position = RageTarget.Position
            end
            if Toggles.SilentAim.Value and SilentTarget then
                args[1].Bullets[1].Hits[1].Instance = SilentTarget
                args[1].Bullets[1].Hits[1].Position = SilentTarget.Position
            end
        end
        return oldshoot(unpack(args))
    end)
end)

task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if Toggles.Firerate.Value then
                for _, obj in next, firerateobjs do
                    pcall(function()
                        setreadonly(obj, false)
                        rawset(obj, "FireRate", math.max(Options.FirerateSlider.Value, 0.01))
                        setreadonly(obj, true)
                    end)
                end
            else
                for i, obj in next, firerateobjs do
                    pcall(function()
                        setreadonly(obj, false)
                        rawset(obj, "FireRate", original[i].FireRate) 
                        setreadonly(obj, true)
                    end)
                end
            end
        end)
    end
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("l10hub")
SaveManager:SetFolder("l10hub/bloxstrike")
SaveManager:SetSubFolder("bloxstrike") 
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
