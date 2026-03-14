local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

_G.TP_Mode = "None"
local LastPos = nil

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = ".-.-.-.-.-.-.-."

local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 95, 0, 32)
MainBtn.Position = UDim2.new(0, 15, 0.5, -15)
MainBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainBtn.Text = "Teleport Behind"
MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainBtn.Font = Enum.Font.GothamBold
MainBtn.TextSize = 10
MainBtn.Draggable = true
MainBtn.Active = true
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)
local MainStroke = Instance.new("UIStroke", MainBtn)
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1.2
MainStroke.ApplyStrokeMode = "Border"

local DropDown = Instance.new("Frame", MainBtn)
DropDown.Size = UDim2.new(1, 0, 0, 0)
DropDown.Position = UDim2.new(0, 0, 1, 5)
DropDown.BackgroundTransparency = 1
DropDown.ClipsDescendants = true
Instance.new("UIListLayout", DropDown).Padding = UDim.new(0, 5)

local function CreateSubBtn(Name, Mode)
    local btn = Instance.new("TextButton", DropDown)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.Text = Name
    btn.TextColor3 = Color3.fromRGB(255, 60, 60)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 8
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(60, 20, 20)
    s.Thickness = 1
    s.ApplyStrokeMode = "Border"

    btn.MouseButton1Click:Connect(function()
        if _G.TP_Mode == Mode then
            _G.TP_Mode = "None"
            if LastPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LastPos
                LastPos = nil
            end
        else
            if _G.TP_Mode == "None" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LastPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            _G.TP_Mode = Mode
        end
    end)
    return btn, s
end

local InstBtn, InstStroke = CreateSubBtn("INSTANT-TP", "Instant")
local TwnBtn, TwnStroke = CreateSubBtn("TWEEN-TP", "Tween")

local Open = false
MainBtn.MouseButton1Click:Connect(function()
    Open = not Open
    local TargetHeight = Open and 70 or 0
    TweenService:Create(DropDown, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        local Root = LocalPlayer.Character.HumanoidRootPart
        local Target = nil
        local ShortestDist = math.huge 

        -- Scan for Target
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if d < ShortestDist then ShortestDist = d; Target = p.Character.HumanoidRootPart end
            end
        end

        -- Update UI Text with Proximity
        local DistText = (Target) and "["..math.floor(ShortestDist).."s]" or "[N/A]"
        InstBtn.Text = "INSTANT " .. DistText
        TwnBtn.Text = "TWEEN " .. DistText

        -- Color Sync
        InstBtn.TextColor3 = (_G.TP_Mode == "Instant") and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 60, 60)
        InstStroke.Color = (_G.TP_Mode == "Instant") and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(60, 20, 20)
        TwnBtn.TextColor3 = (_G.TP_Mode == "Tween") and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 60, 60)
        TwnStroke.Color = (_G.TP_Mode == "Tween") and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(60, 20, 20)

        -- Execute
        if _G.TP_Mode ~= "None" and Target then
            local Goal = Target.CFrame * CFrame.new(0, 0, 4.2)
            if _G.TP_Mode == "Instant" then
                Root.CFrame = Goal
            elseif _G.TP_Mode == "Tween" then
                TweenService:Create(Root, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = Goal}):Play()
            end
        end
    end)
end)
