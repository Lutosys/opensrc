local data = setmetatable({}, {
    __mode = "k"
})

local blocked = setmetatable({}, {
    __mode = "k"
})

local ScreenGui = {
	ScreenGui = Instance.new("ScreenGui"),
	ScrollingFrame = Instance.new("ScrollingFrame"),
	TextLabel = Instance.new("TextLabel"),
	Template = Instance.new("TextButton"),
	UIListLayout = Instance.new("UIListLayout"),
}

ScreenGui.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ScrollingFrame.Parent = ScreenGui.ScreenGui
ScreenGui.TextLabel.Parent = ScreenGui.ScrollingFrame
ScreenGui.UIListLayout.Parent = ScreenGui.ScrollingFrame

ScreenGui.ScreenGui.Name = "ScreenGui"
ScreenGui.ScreenGui.ResetOnSpawn = true
ScreenGui.ScreenGui.IgnoreGuiInset = false
ScreenGui.ScreenGui.DisplayOrder = 0

ScreenGui.ScrollingFrame.Name = "ScrollingFrame"
ScreenGui.ScrollingFrame.ZIndex = 1
ScreenGui.ScrollingFrame.Position = UDim2.new(0.118254878, 0, 0.115897439, 0)
ScreenGui.ScrollingFrame.Size = UDim2.new(0, 417, 0, 406)
ScreenGui.ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScreenGui.ScrollingFrame.BackgroundTransparency = 0
ScreenGui.ScrollingFrame.Visible = true
ScreenGui.ScrollingFrame.AnchorPoint = Vector2.new(0, 0)
ScreenGui.ScrollingFrame.ClipsDescendants = true

ScreenGui.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 50000)
ScreenGui.ScrollingFrame.ScrollBarThickness = 12
ScreenGui.ScrollingFrame.ScrollingEnabled = true
ScreenGui.ScrollingFrame.BorderSizePixel = 0

ScreenGui.TextLabel.Name = "TextLabel"
ScreenGui.TextLabel.ZIndex = 1
ScreenGui.TextLabel.Position = UDim2.new(0.0723306537, 0, 0.110769227, 0)
ScreenGui.TextLabel.Size = UDim2.new(0, 417, 0, 50)
ScreenGui.TextLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScreenGui.TextLabel.BackgroundTransparency = 0
ScreenGui.TextLabel.Text = "remote blocker with raknet click to block"
ScreenGui.TextLabel.TextScaled = false
ScreenGui.TextLabel.TextSize = 14
ScreenGui.TextLabel.Font = Enum.Font.SourceSans
ScreenGui.TextLabel.TextColor3 = Color3.fromRGB(0,0,0)
ScreenGui.TextLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
ScreenGui.TextLabel.TextStrokeTransparency = 1
ScreenGui.TextLabel.TextWrapped = false
ScreenGui.TextLabel.TextXAlignment = Enum.TextXAlignment.Center
ScreenGui.TextLabel.TextYAlignment = Enum.TextYAlignment.Center
ScreenGui.TextLabel.TextTransparency = 0
ScreenGui.TextLabel.Visible = true
ScreenGui.TextLabel.AnchorPoint = Vector2.new(0, 0)
ScreenGui.TextLabel.ClipsDescendants = false

ScreenGui.Template.Name = "Template"
ScreenGui.Template.ZIndex = 1
ScreenGui.Template.Position = UDim2.new(0, 0, 0.0515759327, 0)
ScreenGui.Template.Size = UDim2.new(0, 417, 0, 50)
ScreenGui.Template.BackgroundColor3 = Color3.fromRGB(255,255,255)
ScreenGui.Template.BackgroundTransparency = 0
ScreenGui.Template.Text = "RemoteName"
ScreenGui.Template.TextScaled = true
ScreenGui.Template.TextSize = 14
ScreenGui.Template.Font = Enum.Font.SourceSans
ScreenGui.Template.TextColor3 = Color3.fromRGB(0,0,0)
ScreenGui.Template.TextStrokeColor3 = Color3.fromRGB(0,0,0)
ScreenGui.Template.TextStrokeTransparency = 1
ScreenGui.Template.TextWrapped = true
ScreenGui.Template.TextXAlignment = Enum.TextXAlignment.Center
ScreenGui.Template.TextYAlignment = Enum.TextYAlignment.Center
ScreenGui.Template.TextTransparency = 0
ScreenGui.Template.Visible = false
ScreenGui.Template.AnchorPoint = Vector2.new(0, 0)
ScreenGui.Template.ClipsDescendants = false

ScreenGui.UIListLayout.Name = "UIListLayout"
ScreenGui.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScreenGui.UIListLayout.Padding = UDim.new(0, 0)
ScreenGui.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
ScreenGui.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ScreenGui.UIListLayout.FillDirection = Enum.FillDirection.Vertical

local function createbutton(text, callback)
    local newButton = ScreenGui.Template:Clone()
    newButton.Parent = ScreenGui.ScrollingFrame
    newButton.Visible = true
    newButton.Text = text
    newButton.Name = text

    newButton.MouseButton1Click:Connect(function()
        table.insert(blocked, text)
    end)
end

local function destroyButton(text)
    if ScreenGui.ScrollingFrame:FindFirstChild(text) then
        ScreenGui.ScrollingFrame:FindFirstChild(text):Destroy()
    end
end

local function ValidObject(obj)
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or 
        obj:IsA("UnreliableRemoteEvent") or obj:IsA("BindableEvent") or 
        obj:IsA("BindableFunction") then
        return true
    end
    return false
end

local function CacheInit()
    for key, obj in next, game:GetDescendants() do
        if ValidObject(obj) then
            local cleaned = string.gsub(obj:GetDebugId(), "1_", "")
            if cleaned and tonumber(cleaned) ~= nil then
                data[tonumber(cleaned)] = obj
                createbutton(obj.Name)
            end
        end
    end

    game.DescendantAdded:Connect(function(obj)
        if ValidObject(obj) then
            local cleaned = string.gsub(obj:GetDebugId(), "1_", "")
            if cleaned and tonumber(cleaned) ~= nil  then
                data[tonumber(cleaned)] = obj
                createbutton(obj.Name)
            end
        end
    end)

    game.DescendantRemoving:Connect(function(obj)
        if ValidObject(obj) then
            local cleaned = string.gsub(obj:GetDebugId(), "1_", "")
            if cleaned and tonumber(cleaned) ~= nil  then
                data[tonumber(cleaned)] = nil
                destroyButton(obj.Name)
            end
        end
    end)
end

CacheInit()

raknet.add_send_hook(function(packet)
    if packet.PacketId == 0x83 then
        local b = packet.AsBuffer
        local length = buffer.len(b)        
        for i = 0, length - 1 do
            local item = buffer.readu8(b, i)
            if item == 0x07 or item == 0x03 then
                pcall(function(...)
                    for i = 1, length - 4 do 
                        local inst = data[buffer.readu32(b, i)]
                        if inst then
                            if table.find(blocked, tostring(inst)) then
                                warn("blocked packet for: "..tostring(inst))
                                return packet:Block()
                            end
                        end
                    end
                end)
            end
        end
    end
end)
