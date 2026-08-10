if not isfile("mm2data.lua") then
    local result = request({
        Url = "https://raw.githubusercontent.com/Lutosys/opensrc/refs/heads/main/mm2meshes.lua",
        Method = "GET",
    })
    if result.Success then
        writefile("mm2data.lua", result.Body)
    end
end

data = loadfile("mm2data.lua")() or nil
if not data then
    return warn("failed to load data")
end

local function findMeshAndTexture(node)
    if not node or type(node) ~= "table" then return nil end

    local props = node.Props
    if props then
        local meshId = props.MeshId or props.MeshID
        if meshId and meshId ~= "" then
            local textureId = props.TextureId or props.TextureID or ""
            local scale = props.Scale or Vector3.new(0.045,0.045,0.045)
            local size = props.Size or Vector3.new(0.045,0.045,0.045)
            return {
                meshid = meshId, 
                textureid = textureId, 
                scale = scale, 
                size = size
            }
        end
    end

    if node.Display and type(node.Display) == "table" then
        for _, child in ipairs(node.Display) do
            local res = findMeshAndTexture(child)
            if res then return res end
        end
    end
    
    return nil
end
local function getWeaponData(name)
    local weaponData = data[name]
    if not weaponData then
        return nil
    end

    local found = findMeshAndTexture(weaponData)
    if found then
        return found
    end

    return nil
end

local function applyWeaponMesh(refPart, weaponData, weaponName, weapontype)
    if not weaponData then
        return
    end
    if not weaponData.meshid then
        return
    end

    if weaponData.meshid:find("79401392") then
        if weapontype == "Gun" then
            local tool = refPart:FindFirstAncestorOfClass("Tool")
            if tool then
                tool.Grip = CFrame.fromMatrix(
                    Vector3.new(0, -0.699999988, -0.300000012),
                    Vector3.new(1, 0, 0), 
                    Vector3.new(0, 0, 1), 
                    Vector3.new(0, -1, 0)
                )
            end
        end
    elseif weaponData.meshid:find("6600918074") then
        if weapontype == "Gun" then
            local tool = refPart:FindFirstAncestorOfClass("Tool")
            if tool then
                tool.Grip = CFrame.new(1, -0.359999988, 0.00000012, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            end
        end
    else
        if weapontype == "Gun" then
            local tool = refPart:FindFirstAncestorOfClass("Tool")
            if tool then
                tool.Grip = CFrame.fromMatrix(
                    Vector3.new(0, -0.5, 0.7),
                    Vector3.new(1, 0, 0),
                    Vector3.new(0, 1, 0),
                    Vector3.new(0, 0, 1)
                )
            end
        end
    end

    if refPart:IsA("MeshPart") then
        local specialMesh = refPart:FindFirstChildOfClass("SpecialMesh")
        if specialMesh then
            specialMesh:Destroy()
        end
        refPart.Size = weaponData.size
        refPart.MeshId = weaponData.meshid
        refPart.TextureID = weaponData.textureid
    else
        local mesh = refPart:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.Name = "Mesh"
            mesh.Parent = refPart
        end
        refPart.Size = weaponData.size
        mesh.MeshId = weaponData.meshid
        mesh.TextureId = weaponData.textureid
        mesh.Scale = weaponData.scale
    end
end

local InventoryModule = require(game.ReplicatedStorage.Modules.InventoryModule)
local ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
local Sync = require(game.ReplicatedStorage.Database.Sync)

for name, itemData in pairs(Sync.Weapons) do
    itemData.SortWithinGroup = itemData.SortWithinGroup or 0
    itemData.SortGroup = itemData.SortGroup or nil
    itemData.Name = itemData.Name or itemData.ItemName or name
    itemData.Rarity = itemData.Rarity or "Common"

    if Sync.Rarities[itemData.Rarity] then
        local weaponMeshInfo = getWeaponData(name)
        if weaponMeshInfo and weaponMeshInfo.meshid and weaponMeshInfo.textureid and weaponMeshInfo.scale and weaponMeshInfo.size then
            ProfileData.Weapons.Owned[name] = 1
        end
    end
end

local UpdateInventory = filtergc("table", {Keys = {"UpdateInventory"}}, true).UpdateInventory
for key, func in pairs(getgc()) do
    if typeof(func) == "function" and islclosure(func) and debug.info(func, "l") == 122 and #debug.getupvalues(func) == 2 then
        UpdateInventory(debug.getupvalue(func, 2), InventoryModule.MyInventory)
    end
end

local function isMurder()
    local success, result = pcall(function()
        for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if typeof(v) == "Instance" and v:IsA("Tool") and v:GetAttribute("ItemType") == "Knife" then
                return true
            end
        end
        
        for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if typeof(v) == "Instance" and v:IsA("Tool") and v:GetAttribute("ItemType") == "Knife" then
                return true
            end
        end
        
        return false
    end)
    
    if success then
        return result
    end
    
    return false
end

game.Workspace.ChildAdded:Connect(function(ch)
    if ch and ch:IsA("BasePart") and ch.Name == "StuckKnife" then
        local mesh = ch:WaitForChild("Mesh")
        if mesh then
            local equippedKnifeName = ProfileData.Weapons.Equipped.Knife
            local knifedata = getWeaponData(equippedKnifeName)
            if knifedata then
                if isMurder() then
                    mesh.MeshId = knifedata.meshid
                    mesh.TextureId = knifedata.textureid
                    mesh.Scale = knifedata.scale
                end
            end
        end
    end
end)

while wait() do
    local char = game.Players.LocalPlayer.Character
    if char then
        local equippedKnifeName = ProfileData.Weapons.Equipped.Knife
        local equippedGunName = ProfileData.Weapons.Equipped.Gun

        for _, tool in pairs(char:GetChildren()) do
            if tool and tool:IsA("Tool") then
                local itemType = tool:GetAttribute("ItemType")
                local Handle = tool:FindFirstChild("Handle")
                if Handle then
                    if itemType == "Knife" and equippedKnifeName then
                        local knifedata = getWeaponData(equippedKnifeName)
                        if knifedata and knifedata.meshid and knifedata.textureid and knifedata.scale and knifedata.size then
                            applyWeaponMesh(Handle, knifedata, equippedKnifeName, "Knife")
                        end
                    elseif itemType == "Gun" and equippedGunName then
                        local gundata = getWeaponData(equippedGunName)
                        if gundata and gundata.meshid and gundata.textureid and gundata.scale and gundata.size then
                            applyWeaponMesh(Handle, gundata, equippedGunName, "Gun")
                        end
                    end
                end
            end
        end

        local DisplayRefGun = char:FindFirstChild("DisplayRefGun")
        if DisplayRefGun then
            local refVal = DisplayRefGun.Value
            if refVal and typeof(refVal) == "Instance" and equippedGunName then
                local gundata = getWeaponData(equippedGunName)
                if gundata and gundata.meshid and gundata.textureid and gundata.scale and gundata.size then
                    applyWeaponMesh(refVal, gundata, equippedGunName)
                end
            end
        end

        local DisplayRefKnife = char:FindFirstChild("DisplayRefKnife")
        if DisplayRefKnife then
            local refVal = DisplayRefKnife.Value
            if refVal and typeof(refVal) == "Instance" and equippedKnifeName then
                local knifedata = getWeaponData(equippedKnifeName)
                if knifedata and knifedata.meshid and knifedata.textureid and knifedata.scale and knifedata.size then
                    applyWeaponMesh(refVal, knifedata, equippedKnifeName)
                end
            end
        end
    end
end
