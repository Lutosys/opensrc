local Players = game:GetService("Players")

--thanks to gem for the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui()

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "FarmButton"
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0.5, -90, 0.85, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(210, 60, 60) 
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 18
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "Farm: OFF"
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleButton

local isFarming = false

toggleButton.MouseButton1Click:Connect(function()
	isFarming = not isFarming

	if isFarming then
		toggleButton.Text = "Farm: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 75)
	else
		toggleButton.Text = "Farm: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(210, 60, 60) 
	end
end)

local UseBucket = game:GetService("ReplicatedStorage").VerdantRemotes["VDT_Bucket.Used"]
local FirstCheckpoint = workspace.Scripted.CheckpointParts["1"]
local LocalPlayer = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Scripted = Workspace.Scripted.CheckpointParts["1"]:GetChildren()[2].Scripted
local PourProximityPrompt = Scripted.ProximityPosition.ProximityPrompt
local TakeTokensProximityPrompt = Scripted.TakeTokens.ProximityPrompt
local PourPos = PourProximityPrompt.Parent.CFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Verdant = require(ReplicatedStorage.Verdant)
local Events = require(Verdant.Events)
local SkillTreeLayouts = require(ReplicatedStorage.Shared.Registry.SkillTreeLayouts)
local PurchaseRemote = game:GetService("ReplicatedStorage").VerdantRemotes["VDT_SkillTree.Purchase"]

local LAYOUTS = SkillTreeLayouts.LAYOUTS
local coordKey = SkillTreeLayouts.coordKey

--thanks to gem for this function
function getClaimable(unlockedNodes, tokens, rebirths)
    local result = {}
    unlockedNodes = unlockedNodes or {}
    tokens = tokens or 0
    rebirths = rebirths or 0

    for category, nodes in pairs(LAYOUTS) do
        local owned = unlockedNodes[category] or {}
        local rootOwned = unlockedNodes.root or {}

        for _, node in ipairs(nodes) do
            if node.kind ~= "folder" and node.kind ~= "back" and not node.perkSlot then
                local key = coordKey(node.q, node.r)

                if not owned[key] then
                    local isAdj = false
                    for ownedKey in pairs(owned) do
                        local oq, or2 = ownedKey:match("(-?%d+),(-?%d+)")
                        oq, or2 = tonumber(oq), tonumber(or2)
                        if oq and or2 then
                            local dq = node.q - oq
                            local dr = node.r - or2
                            if math.max(math.abs(dq), math.abs(dr), math.abs(dq + dr)) == 1 then
                                isAdj = true
                                break
                            end
                        end
                    end

                    if category == "root" and node.q == 0 and node.r == 0 then
                        isAdj = true
                    end

                    if category ~= "root" and not owned["0,0"] then
                        for _, folder in ipairs(LAYOUTS.root) do
                            if folder.kind == "folder" and folder.opensCategory == category then
                                for ownedKey in pairs(rootOwned) do
                                    local oq, or2 = ownedKey:match("(-?%d+),(-?%d+)")
                                    oq, or2 = tonumber(oq), tonumber(or2)
                                    if oq and or2 then
                                        local dq = folder.q - oq
                                        local dr = folder.r - or2
                                        if math.max(math.abs(dq), math.abs(dr), math.abs(dq + dr)) == 1 then
                                            isAdj = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local rebirthOk = true
                    if node.requiresRebirth and node.requiresRebirth > 0 then
                        rebirthOk = node.requiresRebirth <= rebirths
                    end

                    local cost = SkillTreeLayouts.costFor(node)

                    if isAdj and rebirthOk and cost <= tokens then
                        table.insert(result, {
                            category = category,
                            q = node.q,
                            r = node.r,
                            key = key,
                            title = node.title,
                            cost = cost,
                        })
                    end
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return a.cost < b.cost
    end)

    return result
end

local DEBUG = true

local function purchaseAll()
    if isFarming then
        local unlockedNodes = Events.Profile:Get("SkillTree") or {}
        local tokens = Events.Profile:Get("Tokens") or 0
        local rebirths = Events.Profile:Get("RebirthCount") or 0

        local claimable = getClaimable(unlockedNodes, tokens, rebirths)

        for _, item in ipairs(claimable) do
            if DEBUG then
                warn("DEBUG: purchase all | purchasing "..item.title)
            end
            PurchaseRemote:InvokeServer(item.category, item.q, item.r)
        end
    end
end

local function getWaterModel()
    local success, result = pcall(function(...)
        return Workspace:FindFirstChild("Water") 
    end)
    if not result then
        if DEBUG then
            warn("DEBUG: getWaterModel returned "..tostring(result))
        end
        return nil
    end

    return result
end

local function getWaterLayer(self)
    local success, result = pcall(function(...)
        return self:QueryDescendants("#Texture")[1].Parent
    end)
    if not result then
        if DEBUG then
            warn("DEBUG: getWaterLayer returned "..tostring(result))
        end
        return nil
    end

    return result
end

local function returnBucketFill(self)
    local success, result = pcall(function(...)
        return LocalPlayer:GetAttribute("BucketFill")
    end)
    if not result then
        if DEBUG then
            warn("DEBUG: returnBucketFill returned "..tostring(result))
        end
        return 0
    end

    return result
end

local function useBucket()
    if isFarming then
        local success, result = pcall(function(...)
            local bucketFill = returnBucketFill(LocalPlayer)

            if bucketFill == nil or bucketFill ~= 1 then
                local waterModel = getWaterModel()
                if not waterModel then
                    return "water model -> nil"
                end
                local waterLayer = getWaterLayer(waterModel)
                if not waterLayer then
                    return "water layer -> nil"
                end
                
                UseBucket:FireServer(waterLayer)

                return true
            end
            return "Full"
        end)

        if typeof(result) ~= "boolean" then
            if DEBUG then
                warn("DEBUG: useBucket returned "..tostring(result))
            end
            return false
        end

        return true
    end
end

local function DrainAndCollect()
    if isFarming then
        local success, result = pcall(function(...)
            local mychar = LocalPlayer.Character
            if not mychar then return "no character" end    

            local bucketFill = returnBucketFill(LocalPlayer)
            if bucketFill == nil or bucketFill ~= 1 then return "not full" end

            local origin = mychar:GetPivot()

            if not origin or typeof(origin) ~= "CFrame" then
                return "failed to get origin"
            end

            mychar:PivotTo(PourPos)

            wait(0.2)

            if not PourProximityPrompt.Enabled then
                if TakeTokensProximityPrompt.Enabled then
                    fireproximityprompt(TakeTokensProximityPrompt)
                end
                return "runtime error"
            end

            fireproximityprompt(PourProximityPrompt)

            repeat
                wait()
            until TakeTokensProximityPrompt.Enabled

            fireproximityprompt(TakeTokensProximityPrompt)

            mychar:PivotTo(origin)

            return true
        end)

        if typeof(result) ~= "boolean" then
            if DEBUG then
                warn("DEBUG: pourTokens returned "..tostring(result))
            end
            return false
        end

        return true
    end
end

task.spawn(function()
    while wait(0.3) do
        useBucket()
    end
end)

while wait(1) do
    DrainAndCollect()

    purchaseAll()
end
