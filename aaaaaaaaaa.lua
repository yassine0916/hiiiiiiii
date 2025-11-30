-- MZ Hub - Simple Working Version
-- Copyright: MZ Hub by Unknown Boi

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local guiVisible = false
local espEnabled = false
local hitboxEnabled = false

-- Create the Open Button FIRST
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "MZOpenButton"
OpenButton.Parent = game.CoreGui
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
OpenButton.BorderSizePixel = 0
OpenButton.Position = UDim2.new(0, 20, 0.5, -30)
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "MZ"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 18
OpenButton.ZIndex = 999
OpenButton.Visible = true

-- Make it round
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = OpenButton

-- Add outline
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Parent = OpenButton

print("MZ Button created!")

-- Create Main GUI
local MZHub = Instance.new("ScreenGui")
MZHub.Name = "MZHub"
MZHub.Parent = game.CoreGui
MZHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MZHub
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Visible = false

-- Make corners round
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "MZ Hub - مركز إم زد"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = CloseButton

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = MainFrame
Content.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 10, 0, 50)
Content.Size = UDim2.new(1, -20, 1, -60)

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = Content

-- ESP Toggle Button
local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Parent = Content
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ESPToggle.BorderSizePixel = 0
ESPToggle.Position = UDim2.new(0.1, 0, 0.1, 0)
ESPToggle.Size = UDim2.new(0.8, 0, 0, 50)
ESPToggle.Font = Enum.Font.Gotham
ESPToggle.Text = "تفعيل ESP - تشغيل الرؤية"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 14
ESPToggle.TextWrapped = true

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = ESPToggle

-- ESP Status
local ESPStatus = Instance.new("TextLabel")
ESPStatus.Name = "ESPStatus"
ESPStatus.Parent = Content
ESPStatus.BackgroundTransparency = 1
ESPStatus.Position = UDim2.new(0.1, 0, 0.3, 0)
ESPStatus.Size = UDim2.new(0.8, 0, 0, 30)
ESPStatus.Font = Enum.Font.GothamBold
ESPStatus.Text = "الحالة: غير مفعل"
ESPStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
ESPStatus.TextSize = 16

-- ESP Color Button
local ESPColor = Instance.new("TextButton")
ESPColor.Name = "ESPColor"
ESPColor.Parent = Content
ESPColor.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ESPColor.BorderSizePixel = 0
ESPColor.Position = UDim2.new(0.1, 0, 0.45, 0)
ESPColor.Size = UDim2.new(0.8, 0, 0, 50)
ESPColor.Font = Enum.Font.Gotham
ESPColor.Text = "تغيير لون ESP"
ESPColor.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPColor.TextSize = 14
ESPColor.TextWrapped = true

local espColorCorner = Instance.new("UICorner")
espColorCorner.CornerRadius = UDim.new(0, 8)
espColorCorner.Parent = ESPColor

-- Hitbox Toggle
local HitboxToggle = Instance.new("TextButton")
HitboxToggle.Name = "HitboxToggle"
HitboxToggle.Parent = Content
HitboxToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
HitboxToggle.BorderSizePixel = 0
HitboxToggle.Position = UDim2.new(0.1, 0, 0.65, 0)
HitboxToggle.Size = UDim2.new(0.8, 0, 0, 50)
HitboxToggle.Font = Enum.Font.Gotham
HitboxToggle.Text = "تفعيل توسيع الهيت بوكس"
HitboxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxToggle.TextSize = 14
HitboxToggle.TextWrapped = true

local hitboxCorner = Instance.new("UICorner")
hitboxCorner.CornerRadius = UDim.new(0, 8)
hitboxCorner.Parent = HitboxToggle

-- Hitbox Status
local HitboxStatus = Instance.new("TextLabel")
HitboxStatus.Name = "HitboxStatus"
HitboxStatus.Parent = Content
HitboxStatus.BackgroundTransparency = 1
HitboxStatus.Position = UDim2.new(0.1, 0, 0.85, 0)
HitboxStatus.Size = UDim2.new(0.8, 0, 0, 30)
HitboxStatus.Font = Enum.Font.GothamBold
HitboxStatus.Text = "الحالة: غير مفعل"
HitboxStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
HitboxStatus.TextSize = 16

-- Make draggable
local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Toggle GUI Function
local function toggleGUI(show)
    guiVisible = show
    
    if show then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 10, 0, 10)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        -- Open animation
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 300, 0, 350)
        })
        tween:Play()
        
        -- Change button color
        OpenButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    else
        -- Close animation
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 10, 0, 10)
        })
        tween:Play()
        
        -- Reset button color
        OpenButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        
        wait(0.3)
        MainFrame.Visible = false
    end
end

-- Button Events
OpenButton.MouseButton1Click:Connect(function()
    toggleGUI(not guiVisible)
end)

CloseButton.MouseButton1Click:Connect(function()
    toggleGUI(false)
end)

-- ESP Variables
local espObjects = {}
local espColor = Color3.fromRGB(255, 0, 0)

-- ESP Functions
local function createESP(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "MZESP"
    highlight.Adornee = character
    highlight.FillColor = espColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    espObjects[character] = highlight
end

local function removeESP(character)
    if espObjects[character] then
        espObjects[character]:Destroy()
        espObjects[character] = nil
    end
end

local function toggleESP(state)
    espEnabled = state
    ESPStatus.Text = state and "الحالة: مفعل" or "الحالة: غير مفعل"
    ESPStatus.TextColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    
    if state then
        -- Enable ESP
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                createESP(otherPlayer.Character)
            end
        end
        ESPToggle.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        -- Disable ESP
        for character, _ in pairs(espObjects) do
            removeESP(character)
        end
        ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

-- Hitbox Variables
local hitboxHighlights = {}
local originalSizes = {}
local hitboxColor = Color3.fromRGB(0, 255, 0)
local hitboxSize = 3

-- Hitbox Functions
local function applyHitboxExpander(character)
    if not character then return end
    
    hitboxHighlights[character] = {}
    originalSizes[character] = {}
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- Store original size
            originalSizes[character][part] = part.Size
            
            -- Expand size
            part.Size = part.Size * hitboxSize
            
            -- Add visual
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "MZHitbox"
            box.Adornee = part
            box.AlwaysOnTop = true
            box.Size = part.Size
            box.Color3 = hitboxColor
            box.Transparency = 0.3
            box.Parent = part
            
            table.insert(hitboxHighlights[character], box)
        end
    end
end

local function removeHitboxExpander(character)
    if hitboxHighlights[character] then
        -- Remove visuals
        for _, box in ipairs(hitboxHighlights[character]) do
            box:Destroy()
        end
        
        -- Restore sizes
        if originalSizes[character] then
            for part, size in pairs(originalSizes[character]) do
                if part then
                    part.Size = size
                end
            end
        end
        
        hitboxHighlights[character] = nil
        originalSizes[character] = nil
    end
end

local function toggleHitboxExpander(state)
    hitboxEnabled = state
    HitboxStatus.Text = state and "الحالة: مفعل" or "الحالة: غير مفعل"
    HitboxStatus.TextColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    
    if state then
        -- Enable hitbox
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                applyHitboxExpander(otherPlayer.Character)
            end
        end
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        -- Disable hitbox
        for character, _ in pairs(hitboxHighlights) do
            removeHitboxExpander(character)
        end
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end

-- Connect button events
ESPToggle.MouseButton1Click:Connect(function()
    toggleESP(not espEnabled)
end)

ESPColor.MouseButton1Click:Connect(function()
    -- Random color
    espColor = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
    ESPColor.BackgroundColor3 = espColor
    
    -- Update existing ESP
    for _, highlight in pairs(espObjects) do
        if highlight then
            highlight.FillColor = espColor
            highlight.OutlineColor = espColor
        end
    end
end)

HitboxToggle.MouseButton1Click:Connect(function()
    toggleHitboxExpander(not hitboxEnabled)
end)

-- Handle player connections
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        wait(1)
        if espEnabled then
            createESP(character)
        end
        if hitboxEnabled then
            applyHitboxExpander(character)
        end
    end)
end)

-- Initial setup for existing players
for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
        if espEnabled then
            createESP(otherPlayer.Character)
        end
        if hitboxEnabled then
            applyHitboxExpander(otherPlayer.Character)
        end
    end
end

-- Mobile optimization
if UserInputService.TouchEnabled then
    OpenButton.Size = UDim2.new(0, 80, 0, 80)
    OpenButton.TextSize = 22
    ESPToggle.Size = UDim2.new(0.8, 0, 0, 60)
    ESPColor.Size = UDim2.new(0.8, 0, 0, 60)
    HitboxToggle.Size = UDim2.new(0.8, 0, 0, 60)
end

print("✅ MZ Hub Loaded Successfully!")
print("🎮 Created by Unknown Boi")
print("🔵 Look for the blue MZ button on your screen!")
print("📱 Mobile Optimized")
print("🎯 Features: ESP & Hitbox Expander")
