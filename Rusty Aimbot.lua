local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local TargetPlayer = nil
local Highlight = nil
local FirstLock = true
local LockedTarget = nil 
local MenuVisible = true

-- GUI Menu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local TitleButton = Instance.new("TextButton")
TitleButton.Size = UDim2.new(1, 0, 0.3, 0)
TitleButton.Position = UDim2.new(0, 0, 0, 0)
TitleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
TitleButton.TextColor3 = Color3.new(1, 1, 1)
TitleButton.Text = "Rusty Aimbot"
TitleButton.Font = Enum.Font.SourceSansBold
TitleButton.TextScaled = true
TitleButton.Parent = Frame

local ToggleButton = Instance.new("TextLabel")
ToggleButton.Size = UDim2.new(1, 0, 0.7, 0)
ToggleButton.Position = UDim2.new(0, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "Press Q to Toggle Aimbot"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.Visible = false
ToggleButton.Parent = Frame

TitleButton.MouseButton1Click:Connect(function()
    ToggleButton.Visible = not ToggleButton.Visible
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent then
        AimbotEnabled = not AimbotEnabled
        ToggleButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 200, 0)
    elseif input.KeyCode == Enum.KeyCode.V and not gameProcessedEvent then
        MenuVisible = not MenuVisible
        Frame.Visible = MenuVisible
    end
end)

local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mouse = LocalPlayer:GetMouse()
    local mousePos = mouse.Hit.p

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local distance = (rootPart.Position - mousePos).Magnitude

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function LockOn()
    if LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild("HumanoidRootPart") then
        TargetPlayer = LockedTarget
    else
        TargetPlayer = GetClosestPlayer()
        LockedTarget = TargetPlayer
    end
    
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = TargetPlayer.Character.HumanoidRootPart
        local humanoid = TargetPlayer.Character:FindFirstChild("Humanoid")

        if Highlight then
            Highlight:Destroy()
        end
        Highlight = Instance.new("Highlight")
        Highlight.Parent = TargetPlayer.Character
        Highlight.FillColor = Color3.fromRGB(200, 200, 200)
        
        if humanoid then
            if humanoid.Health <= 0 then
                LockedTarget = nil
            end
        end

        if FirstLock then
            FirstLock = false
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, rootPart.Position)
        end
        
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, rootPart.Position)
    else
        if Highlight then
            Highlight:Destroy()
            Highlight = nil
        end
        TargetPlayer = nil
        FirstLock = true
        LockedTarget = nil
    end
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        LockOn()
    else
        if Highlight then
            Highlight:Destroy()
            Highlight = nil
        end
        TargetPlayer = nil
        FirstLock = true
        LockedTarget = nil
    end
end)
