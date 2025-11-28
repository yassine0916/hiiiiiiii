-- Nxr Hub - Complete Working Script
getgenv().NxrHub = {
    ESP = true,
    AutoAim = false,
    Hitboxes = false
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create Main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NxrHub"
ScreenGui.Parent = game.CoreGui

-- Rainbow Colors
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),    -- Red
    Color3.fromRGB(255, 165, 0),  -- Orange
    Color3.fromRGB(255, 255, 0),  -- Yellow
    Color3.fromRGB(0, 255, 0),    -- Green
    Color3.fromRGB(0, 0, 255),    -- Blue
    Color3.fromRGB(75, 0, 130),   -- Indigo
    Color3.fromRGB(238, 130, 238) -- Violet
}

-- Circular Toggle Button with Rainbow Border
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = ""
ToggleButton.Parent = ScreenGui

-- Make button circular
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

-- Rainbow Border Effect
local RainbowBorder = Instance.new("UIStroke")
RainbowBorder.Color = rainbowColors[1]
RainbowBorder.Thickness = 3
RainbowBorder.Parent = ToggleButton

-- Button Icon
local ButtonIcon = Instance.new("TextLabel")
ButtonIcon.Size = UDim2.new(1, 0, 1, 0)
ButtonIcon.Position = UDim2.new(0, 0, 0, 0)
ButtonIcon.BackgroundTransparency = 1
ButtonIcon.Text = "☰"
ButtonIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ButtonIcon.Font = Enum.Font.GothamBold
ButtonIcon.TextSize = 20
ButtonIcon.Parent = ToggleButton

-- Animate Rainbow Border
spawn(function()
    while true do
        for i = 1, #rainbowColors do
            TweenService:Create(RainbowBorder, TweenInfo.new(0.5), {Color = rainbowColors[i]}):Play()
            wait(0.5)
        end
    end
end)

-- Make button movable
local dragging = false
local dragInput, dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 55, 0, 55)}):Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 60)}):Play()
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Circular Main Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Circular menu shape
local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(1, 0)
MenuCorner.Parent = MainFrame

-- Rainbow border for menu
local MenuBorder = Instance.new("UIStroke")
MenuBorder.Color = rainbowColors[1]
MenuBorder.Thickness = 3
MenuBorder.Parent = MainFrame

-- Menu title
local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.Position = UDim2.new(0, 0, 0, 10)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "Nxr Hub"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextSize = 18
MenuTitle.Parent = MainFrame

-- Circular buttons
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0, 50, 0, 50)
ESPToggle.Position = UDim2.new(0.3, 0, 0.3, 0)
ESPToggle.AnchorPoint = Vector2.new(0.5, 0.5)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ESPToggle.BorderSizePixel = 0
ESPToggle.Text = "ESP"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.TextSize = 12
ESPToggle.Parent = MainFrame

local AutoAimToggle = Instance.new("TextButton")
AutoAimToggle.Size = UDim2.new(0, 50, 0, 50)
AutoAimToggle.Position = UDim2.new(0.7, 0, 0.3, 0)
AutoAimToggle.AnchorPoint = Vector2.new(0.5, 0.5)
AutoAimToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AutoAimToggle.BorderSizePixel = 0
AutoAimToggle.Text = "AIM"
AutoAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoAimToggle.Font = Enum.Font.GothamBold
AutoAimToggle.TextSize = 12
AutoAimToggle.Parent = MainFrame

local HitboxToggle = Instance.new("TextButton")
HitboxToggle.Size = UDim2.new(0, 50, 0, 50)
HitboxToggle.Position = UDim2.new(0.3, 0, 0.7, 0)
HitboxToggle.AnchorPoint = Vector2.new(0.5, 0.5)
HitboxToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
HitboxToggle.BorderSizePixel = 0
HitboxToggle.Text = "BOX"
HitboxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxToggle.Font = Enum.Font.GothamBold
HitboxToggle.TextSize = 12
HitboxToggle.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 50, 0, 50)
CloseButton.Position = UDim2.new(0.7, 0, 0.7, 0)
CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

-- Make all buttons circular
for _, button in pairs({ESPToggle, AutoAimToggle, HitboxToggle, CloseButton}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 2
    stroke.Parent = button
end

-- Animate Menu Border
spawn(function()
    while true do
        for i = 1, #rainbowColors do
            if MainFrame.Visible then
                TweenService:Create(MenuBorder, TweenInfo.new(0.5), {Color = rainbowColors[i]}):Play()
            end
            wait(0.5)
        end
    end
end)

-- SIMPLE ESP FUNCTION
local ESPObjects = {}
local ESPConnection = nil

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 0, 0)
    esp.Box.Visible = false
    
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Visible = false
    
    esp.Distance.Size = 14
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(175, 175, 175)
    esp.Distance.Visible = false
    
    ESPObjects[player] = esp
    return esp
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local esp = ESPObjects[player] or CreateESP(player)
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    local boxSize = Vector2.new(2000 / distance, 3000 / distance)
                    local boxPosition = Vector2.new(position.X - boxSize.X / 2, position.Y - boxSize.Y / 2)
                    
                    -- Box ESP
                    esp.Box.Size = boxSize
                    esp.Box.Position = boxPosition
                    esp.Box.Visible = getgenv().NxrHub.ESP
                    
                    -- Name ESP
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(position.X, position.Y - boxSize.Y / 2 - 20)
                    esp.Name.Visible = getgenv().NxrHub.ESP
                    
                    -- Distance ESP
                    esp.Distance.Text = math.floor(distance) .. "m"
                    esp.Distance.Position = Vector2.new(position.X, position.Y + boxSize.Y / 2 + 5)
                    esp.Distance.Visible = getgenv().NxrHub.ESP
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
            end
        end
    end
end

local function StartESP()
    if ESPConnection then
        ESPConnection:Disconnect()
    end
    
    -- Create ESP for all players
    for _, player in ipairs(Players:GetPlayers()) do
        CreateESP(player)
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
    
    -- Start updating
    ESPConnection = RunService.RenderStepped:Connect(UpdateESP)
end

local function StopESP()
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    
    -- Remove all ESP drawings
    for _, esp in pairs(ESPObjects) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end
    ESPObjects = {}
end

-- AUTO AIM FUNCTION
local AimConnection = nil

local function AutoAim()
    if not getgenv().NxrHub.AutoAim then return end
    if not LocalPlayer.Character then return end
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local closestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character then
        local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            localRoot.CFrame = CFrame.lookAt(localRoot.Position, targetRoot.Position)
        end
    end
end

local function StartAutoAim()
    if AimConnection then
        AimConnection:Disconnect()
    end
    AimConnection = RunService.RenderStepped:Connect(AutoAim)
end

local function StopAutoAim()
    if AimConnection then
        AimConnection:Disconnect()
        AimConnection = nil
    end
end

-- HITBOX FUNCTION
local HitboxConnection = nil
local HitboxSize = Vector3.new(10, 10, 10)

local function UpdateHitboxes()
    if not getgenv().NxrHub.Hitboxes then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Size = HitboxSize
                rootPart.Transparency = 0.5
                rootPart.Color = Color3.fromRGB(255, 0, 0)
                rootPart.Material = Enum.Material.Neon
            end
        end
    end
end

local function ResetHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Size = Vector3.new(2, 2, 1)
                rootPart.Transparency = 1
            end
        end
    end
end

local function StartHitboxes()
    if HitboxConnection then
        HitboxConnection:Disconnect()
    end
    HitboxConnection = RunService.RenderStepped:Connect(UpdateHitboxes)
end

local function StopHitboxes()
    if HitboxConnection then
        HitboxConnection:Disconnect()
        HitboxConnection = nil
    end
    ResetHitboxes()
end

-- Toggle Menu Function
local menuOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    
    if menuOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 200)}):Play()
        TweenService:Create(ButtonIcon, TweenInfo.new(0.3), {Rotation = 90}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(ButtonIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
        wait(0.3)
        MainFrame.Visible = false
    end
end)

-- ESP Toggle Function
ESPToggle.MouseButton1Click:Connect(function()
    getgenv().NxrHub.ESP = not getgenv().NxrHub.ESP
    if getgenv().NxrHub.ESP then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StartESP()
        print("ESP Enabled")
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        StopESP()
        print("ESP Disabled")
    end
end)

-- AutoAim Toggle Function
AutoAimToggle.MouseButton1Click:Connect(function()
    getgenv().NxrHub.AutoAim = not getgenv().NxrHub.AutoAim
    if getgenv().NxrHub.AutoAim then
        AutoAimToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StartAutoAim()
        print("AutoAim Enabled")
    else
        AutoAimToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        StopAutoAim()
        print("AutoAim Disabled")
    end
end)

-- Hitbox Toggle Function
HitboxToggle.MouseButton1Click:Connect(function()
    getgenv().NxrHub.Hitboxes = not getgenv().NxrHub.Hitboxes
    if getgenv().NxrHub.Hitboxes then
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StartHitboxes()
        print("Hitboxes Enabled")
    else
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        StopHitboxes()
        print("Hitboxes Disabled")
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    menuOpen = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(ButtonIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
    wait(0.3)
    MainFrame.Visible = false
end)

-- Add button press effects
local function addButtonEffect(button)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end)
end

addButtonEffect(ESPToggle)
addButtonEffect(AutoAimToggle)
addButtonEffect(HitboxToggle)
addButtonEffect(CloseButton)

-- Start ESP automatically
wait(1)
StartESP()

print("🎯 Nxr Hub Loaded Successfully!")
print("📱 Tap the rainbow circle to open menu")
print("🎯 ESP: Auto Started")
print("🎯 AutoAim: Ready")
print("🎯 Hitboxes: Ready")