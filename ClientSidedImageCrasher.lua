local url = getgenv().target or "https://preview.redd.it/i-asked-an-ai-what-would-ksi-look-like-if-he-had-a-very-big-v0-f9p6hu5r52ja1.png?width=1024&format=png&auto=webp&s=a0928c942e12a35e2ba416d647134f611bf3b6ff"

local function GetImageId()
    --print("started")

    local image = request({
        Url = url,
        Method = "GET"
    })

    --print("did request")

    if not image.Success then
        --warn("Failed to get image :" ..tostring(image.StatusCode))
        return ""
    end

    --print("success get")

    local pngname = math.random(1,100000)..".png"

    --print("got random name")

    local temp = writefile(pngname, image.Body)

    --print("made temp")

    if not isfile(pngname) then
        --warn("failed to create the image file")
        return ""
    end

    --print("passed isfile")

    local imageId = getcustomasset(pngname)
    if not imageId then 
        --warn("failed to get image id")
        return ""
    end

    --print("got imageid")

    delfile(pngname)

    if isfile(pngname) then
        --warn("failed to delete the image file")
        return ""
    end

    return imageId or ""
end 

local Image = GetImageId()

--print(Image)

if not tostring(Image):find("rbxasset") then
    --warn("no image gotten")
    return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = gethui()

local Frame = Instance.new("ImageLabel")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(1, 0, 1, 0)  
Frame.Position = UDim2.new(0, 0, 0, 0)
Frame.Visible = true
Frame.Transparency = 0.999999
Frame.Image = Image or ""

repeat
    task.wait()
    print(Frame.IsLoaded)
until Frame.IsLoaded ~= ""

Frame.Transparency = 0

--print("MADE VISIBLE")

wait(0.1)

local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:FindFirstChild('RobloxGui')

RobloxGui.Enabled = false  

game:GetService("ScriptContext"):SetTimeout(9999999999)

game:GetService("RunService").RenderStepped:Connect(function()
    task.spawn(function()
        while true do end
    end)
end)
