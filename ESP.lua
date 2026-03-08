local Services = setmetatable({}, {
    __index = function(self, key)
        local service = game:GetService(key)
        rawset(self, key, service)
        return service
    end
})

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ViewportSize = Camera.ViewportSize

local ESP_Internal = {
    _Registry = {},
    _Config = {
        BoxColor = Color3.fromRGB(255, 255, 255),
        LineColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(0, 255, 140),
        Thickness = 1
    }
}

local function SecureDraw(type, properties)
    local obj = Drawing.new(type)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

function ESP_Internal:Construct(Player)
    if Player == LocalPlayer then return end
    
    local Data = {
        Box = SecureDraw("Square", {Thickness = self._Config.Thickness, Color = self._Config.BoxColor, Filled = false}),
        Line = SecureDraw("Line", {Thickness = self._Config.Thickness, Color = self._Config.LineColor}),
        Label = SecureDraw("Text", {Size = 13, Center = true, Outline = true, Color = self._Config.TextColor})
    }

    self._Registry[Player] = Data
end

function ESP_Internal:Update()
    Services.RunService.RenderStepped:Connect(function()
        for Player, Visuals in pairs(self._Registry) do
            local Character = Player.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            
            if Root then
                local Position, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                
                if OnScreen then
                    local Distance = (Camera.CFrame.Position - Root.Position).Magnitude
                    local Factor = 1 / (Position.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                    local Size = Vector2.new(4.5 * Factor, 6 * Factor)
                    
                    local Level = 0
                    pcall(function() Level = Player.Data.Level.Value end)
                    
                    local PvpStatus = "Ready PVP"
                    pcall(function()
                        if Player.PlayerGui.Main.PvpDisabled.Visible then
                            PvpStatus = "Off PVP"
                        end
                    end)

                    Visuals.Box.Size = Size
                    Visuals.Box.Position = Vector2.new(Position.X - Size.X / 2, Position.Y - Size.Y / 2)
                    Visuals.Box.Visible = true

                    Visuals.Line.From = Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    Visuals.Line.To = Vector2.new(Position.X, Position.Y + Size.Y / 2)
                    Visuals.Line.Visible = true

                    Visuals.Label.Text = string.format("[%s]\nLvl: %d | Dist: %d\n%s", Player.Name, Level, math.floor(Distance), PvpStatus)
                    Visuals.Label.Position = Vector2.new(Position.X, Position.Y + Size.Y / 2 + 5)
                    Visuals.Label.Visible = true
                else
                    Visuals.Box.Visible = false
                    Visuals.Line.Visible = false
                    Visuals.Label.Visible = false
                end
            else
                Visuals.Box.Visible = false
                Visuals.Line.Visible = false
                Visuals.Label.Visible = false
            end
        end
    end)
end

function ESP_Internal:Deconstruct(Player)
    if self._Registry[Player] then
        for _, obj in pairs(self._Registry[Player]) do
            obj:Remove()
        end
        self._Registry[Player] = nil
    end
end

-- Initialization
for _, p in ipairs(Services.Players:GetPlayers()) do
    ESP_Internal:Construct(p)
end

Services.Players.PlayerAdded:Connect(function(p) ESP_Internal:Construct(p) end)
Services.Players.PlayerRemoving:Connect(function(p) ESP_Internal:Deconstruct(p) end)

task.spawn(function()
    ESP_Internal:Update()
end)
