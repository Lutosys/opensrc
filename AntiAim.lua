local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local window = Rayfield:CreateWindow({
    name = "Anti Aim",
    subtitle = "by l10",
    theme = "Default"
})

local tab = window:CreateTab({
    name = "Main",
    icon = 0
})

local radiusx = 5
local radiusy = 5
local radiusz = 5

local rs = game:GetService("RunService")
local conn

tab:CreateToggle({
    name = "Toggle Anti Aim",
    currentvalue = false,
    flag = "AntiAimToggle",
    callback = function(Value)
        if Value then
            if conn then
                conn:Disconnect()
                conn = nil
            end

            conn = rs.Heartbeat:Connect(function(a0: number)
                local char = game:GetService("Players").LocalPlayer.Character
                if not char then return end 

                local hrp = char:FindFirstChild("HumanoidRootPart", true)
                if not hrp then 
                    hrp = char.PrimaryPart
                    if not hrp then
                        return
                    end                
                end

                local oldcf = hrp.CFrame
                local oldvel = hrp.Velocity
                local oldrootvel = hrp.RotVelocity
                local randomness = CFrame.new(Vector3.new(math.random(1,radiusx),math.random(1,radiusy),math.random(1,radiusz)))

                hrp.CFrame = hrp.CFrame * randomness
                rs:BindToRenderStep("10111", 101, function(delta: number)
                    hrp.CFrame = oldcf
                    hrp.Velocity = oldvel
                    hrp.RotVelocity = oldrootvel
                    rs:UnbindFromRenderStep("10111")
                end)
            end)
        else
            if conn then
                conn:Disconnect()
                conn = nil
            end
        end
    end
})

tab:CreateSlider({
    name = "X Radius",
    range = {1, 100},
    increment = 1,
    value = 5,
    flag = "XRadius",
    callback = function(Value)
        radiusx = Value
    end
})

tab:CreateSlider({
    name = "Y Radius",
    range = {1, 100},
    increment = 1,
    value = 5,
    flag = "YRadius",
    callback = function(Value)
        radiusy = Value
    end
})

tab:CreateSlider({
    name = "Z Radius",
    range = {1, 100},
    increment = 1,
    value = 5,
    flag = "ZRadius",
    callback = function(Value)
        radiusz = Value
    end
})
