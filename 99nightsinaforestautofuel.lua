local utility = {
    RequestStartDraggingItem = game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem,
    StopDraggingItem = game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem,
    Items = workspace.Items,
    MainFire = workspace.Map.Campground.MainFire,
}

utility.BringAllToFire = function(self)
    local success, errormessage = pcall(function()
        local fuels = self.Items:QueryDescendants("[$BurnFuel]")
        for _, fuelsource in ipairs(fuels) do
            self.RequestStartDraggingItem:FireServer(fuelsource)
            fuelsource:MoveTo(self.MainFire:GetPivot().Position)
            self.StopDraggingItem:FireServer(fuelsource)
        end
    end)
    if success then
        return "success"
    end
    return warn("error: "..tostring(errormessage))
end

while wait(1) do
    utility:BringAllToFire()
end
