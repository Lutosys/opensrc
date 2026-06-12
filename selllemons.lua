local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Sell Lemons",
    Footer = "v1.0.0",
    ToggleKeybind = Enum.KeyCode.RightControl,
    Center = true,
    AutoShow = true
})

local MainTab = Window:AddTab("Main", "home")

local LeftGroupbox = MainTab:AddLeftGroupbox("Automation")

local AutoRebirthToggle = LeftGroupbox:AddToggle("AutoRebirthToggle1", {
    Text = "Auto Rebirth",
    Default = false,
    Callback = function(Value)

    end
})

local RebirthMultiplerSlider = LeftGroupbox:AddSlider("RebirthMultiplerSlider1", {
    Text = "Multipler",
    Default = 5,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        
    end
})

LeftGroupbox:AddDivider()

local AutoEvolveToggle = LeftGroupbox:AddToggle("AutoEvolveToggle1", {
    Text = "Auto Evolve",
    Default = false,
    Callback = function(Value)

    end
})

LeftGroupbox:AddDivider()

local AutoAscendToggle = LeftGroupbox:AddToggle("AutoAscendToggle1", {
    Text = "Auto Ascend",
    Default = false,
    Callback = function(Value)

    end
})

LeftGroupbox:AddDivider()

local AutoUpgradeToggles1 = LeftGroupbox:AddToggle("AutoUpgradeToggles1", {
    Text = "Auto Upgrade Income",
    Default = false,
    Callback = function(Value)

    end
})

local AutoPurchaseButtons = LeftGroupbox:AddToggle("AutoPurchaseButtons1", {
    Text = "Auto Purchase Buttons",
    Default = false,
    Callback = function(Value)

    end
})

local AutoWeakIncome = LeftGroupbox:AddToggle("AutoWeakIncome1", {
    Text = "Auto Wake Incomes",
    Default = false,
    Callback = function(Value)

    end
})

local AutoBuyPowers = LeftGroupbox:AddToggle("AutoBuyPowers1", {
    Text = "Auto Buy Powers",
    Default = false,
    Callback = function(Value)

    end
})


local RightGroupbox = MainTab:AddRightGroupbox("Collection")

local AutoColectFruitToggle = RightGroupbox:AddToggle("AutoColectFruitToggle1", {
    Text = "Auto Collect Fruit",
    Default = false,
    Callback = function(Value)

    end
})

local OwnerTycoon = nil

while OwnerTycoon == nil do
    task.wait(0.5)
    for i, v in pairs(game.Workspace:GetChildren()) do
        if v.Name:match("Tycoon") then
            local Owner = v:FindFirstChild("Owner")
            if Owner and Owner.Value == game.Players.LocalPlayer then
                OwnerTycoon = v 
                break
            end
        end
    end
end

local function checkLastButton()
    local success, isConditionMet = pcall(function()
        local lastButton = OwnerTycoon.Purchases.Staircase.Buttons.Structure["Staircase Platform Final"]
        
        if lastButton:GetAttribute("Purchased") == true then
            return true
        elseif lastButton:GetAttribute("Shown") == true then
            return true
        else
            return false
        end
    end)
    
    return success and isConditionMet
end

local getPotentialInvestors = filtergc("function", {Name = "GetPotentialInvestors"}, true)
local getInvestors = filtergc("function", {Name = "GetInvestors"}, true)
local registries = filtergc("table", {Keys = {"RebirthRemote", "BonusChanged", "Destroying", "Root", "RebirthAvailable", "Discovered", "Maid", "Rebirthed"}})
local balances = filtergc("table", {Keys = {"CashChanged", "CashSpentChanged"}})
local Balance = require(game:GetService("ReplicatedStorage").Balance)
local allLevelsDump = filtergc("function", {Name = "GetAllLevels"}, true)
local getCashDump = filtergc("function", {Name = "GetCash"}, true)
local getAllLevels = type(allLevelsDump) == "table" and allLevelsDump[1] or allLevelsDump
local getCash = type(getCashDump) == "table" and getCashDump[1] or getCashDump
local upgradeRegistries = filtergc("table", {Keys = {"Signals", "LevelChanged", "Upgrades"}})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tycoon = require(ReplicatedStorage.Modules.Tycoon.Tycoon)
local TycoonAnalyzer = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonAnalyzer)
local TycoonRoot = Tycoon.getLocal()
local Purchases = TycoonRoot:GetComponent(TycoonAnalyzer):GetPurchases()
local Task = require(ReplicatedStorage.Core.Task)
local Huge = require(game:GetService("ReplicatedStorage").Modules.Huge)


local AutoUpgradeOptions = {
    "Lemon Republic",
    "LemonX",
    "LemonDash",
    "Lemon Robotics",
    "Lemon Stand",
    "Lemon Trading",
    "Lemon Depot",
    "Lemon Labs"
}

local function CheckCountForRebirth()
	local current = getInvestors(balances[10])

	if current > Huge.toHuge(10^84) then
		return true
	end	
	return false
end

task.spawn(function()
	while wait(1) do
		if Toggles.AutoEvolveToggle1.Value then
            if not checkLastButton() and CheckCountForRebirth() == false then
                pcall(function()
                    OwnerTycoon:WaitForChild("Remotes"):WaitForChild("Evolve"):InvokeServer()
                end)
            end
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if Toggles.AutoRebirthToggle1.Value then
            if not checkLastButton() and CheckCountForRebirth() == false then
                local potential = getPotentialInvestors(registries[10])
                local current = getInvestors(balances[10])

                if potential and current then
                    local multiplier = Huge.log10(Options.RebirthMultiplerSlider1.Value) 
                    
                    local threshold = Huge.add(current, Huge.log10(multiplier))

                    if potential >= threshold then
                        pcall(function()
                            OwnerTycoon.Remotes.Rebirth:InvokeServer()
							print("INVOKED SERVER")
                        end)
                        
                        task.wait(3) 
                    end
                end
            end
		end
	end
end)

task.spawn(function()
	while wait(1) do
		if Toggles.AutoWeakIncome1.Value then
			pcall(function()
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonStand")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonX")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonRepublic")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonDash")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonRobotics")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonTrading")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonDepot")
				OwnerTycoon.Remotes.WakeIncomeStream:InvokeServer("LemonLabs")
			end)
		end
	end
end)

local function cleanString(str)
    local noSpaces = str:gsub("%s+", "")
    local noDashes = noSpaces:gsub("%-", "")
    return noDashes
end

local function getPurchaseButtons()
    local buttons = {}
    if OwnerTycoon and OwnerTycoon:FindFirstChild("Purchases") then
        for _, v in ipairs(OwnerTycoon.Purchases:GetDescendants()) do
            if v.Name == "Purchase" then
                table.insert(buttons, v)
            end
        end
    end
    return buttons
end

task.spawn(function()
	while true do
		task.wait()

		if Toggles.AutoPurchaseButtons1.Value == false then
			continue	
		end

		for index, purchase in pairs(Balance.PurchaseOrder) do
			local buttonTable = Purchases[purchase]
			if buttonTable and (buttonTable:IsEnabled() and not buttonTable:IsPurchased()) then
				buttonTable:TryPurchaseAsync()
			end
		end
	end
end)

task.spawn(function()
	while true do
		wait(1)
		if Toggles.AutoUpgradeToggles1.Value == false then
			continue	
		end

		for i, v in pairs(OwnerTycoon.Purchases:GetDescendants()) do
			if v.Name == "Upgrade" then
				if v.Parent and table.find(AutoUpgradeOptions, v.Parent.Name) then
                    pcall(function()
                        v:InvokeServer(1)
                        v:InvokeServer(5)
                        v:InvokeServer(25)
                        v:InvokeServer(100)
                        v:InvokeServer(500)
                    end)
				end
			end
		end
	end
end)

task.spawn(function()
	local TELEPORT_OFFSET = Vector3.new(0, 5, 0)

	while true do 
		wait()
		if Toggles.AutoColectFruitToggle1.Value == false then
			continue	
		end

		local player = game.Players.LocalPlayer
		local char = player and player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if hrp then
			local workspaceDescendants = game.Workspace:GetDescendants()

			for _, v in ipairs(workspaceDescendants) do
				if v.Name == "LemonTree" then
					
					for _, fruit in ipairs(v:GetChildren()) do
						if fruit.Name == "Fruit" then
							local clickpart = fruit:FindFirstChild("ClickPart")
							local cd = clickpart and clickpart:FindFirstChild("ClickDetector")

							if cd and hrp.Parent then
								char:PivotTo(clickpart.CFrame * CFrame.new(TELEPORT_OFFSET))
								
								task.wait(0.05) 

								fireclickdetector(cd)

								task.wait(0.05)
							end
						end
					end

				end
			end
		end
		task.wait(15) 
	end
end)

task.spawn(function()
	while wait(1) do
		if Toggles.AutoAscendToggle1.Value then
			pcall(function()
				OwnerTycoon:WaitForChild("Remotes"):WaitForChild("Ascend"):InvokeServer()
			end)
		end
	end
end)

task.spawn(function()
	while wait(1) do
		if Toggles.AutoBuyPowers1.Value then
			pcall(function()
				local args = {
					"ClickFruitValue"
				}
				OwnerTycoon:WaitForChild("Remotes"):WaitForChild("UpgradePowerLevel"):InvokeServer(unpack(args))
			end)
		end
	end
end)

--[[
local args = {
	"Manage"
}
workspace:WaitForChild("Tycoon8"):WaitForChild("Remotes"):WaitForChild("UpgradePowerLevel"):InvokeServer(unpack(args))
local args = {
	"ClickFruitValue"
}
OwnerTycoon:WaitForChild("Remotes"):WaitForChild("UpgradePowerLevel"):InvokeServer(unpack(args))
local args = {
	"WalkSpeed"
}
workspace:WaitForChild("Tycoon8"):WaitForChild("Remotes"):WaitForChild("UpgradePowerLevel"):InvokeServer(unpack(args))
local args = {
	"UpgradeStack"
}
workspace:WaitForChild("Tycoon8"):WaitForChild("Remotes"):WaitForChild("UpgradePowerLevel"):InvokeServer(unpack(args))
local args = {
	"BuyNext"
}
workspace:WaitForChild("Tycoon3"):WaitForChild("Remotes"):WaitForChild("UpgradePowerLevel"):InvokeServer(unpack(args))
--]]
