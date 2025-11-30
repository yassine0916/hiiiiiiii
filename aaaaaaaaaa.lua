-- MZ Hub Script
-- Copyright: MZ Hub by Unknown Boi
-- Language: Arabic

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- GUI Variables
local MZHub, MainFrame, OpenButton
local guiVisible = false
local espEnabled = false
local hitboxEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local hitboxColor = Color3.fromRGB(0, 255, 0)
local hitboxSize = 5

-- Storage for ESP and Hitbox objects
local espObjects = {}
local hitboxHighlights = {}
local originalSizes = {}

-- Create Open Button First
function createOpenButton()
    OpenButton = Instance.new("TextButton")
    OpenButton.Name = "MZOpenButton"
    OpenButton.Parent = CoreGui
    OpenButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    OpenButton.BorderSizePixel = 0
    OpenButton.Position = UDim2.new(0, 20, 0.5, -30)
    OpenButton.Size = UDim2.new(0, 60, 0, 60)
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.Text = "MZ"
    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.TextSize = 18
    OpenButton.ZIndex = 100
    OpenButton.Visible = true
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = OpenButton
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = OpenButton
    
    -- Click effect
    OpenButton.MouseButton1Click:Connect(function()
        toggleGUI(not guiVisible)
    end)
    
    return OpenButton
end

-- Create Main GUI
function createMainGUI()
    -- Create ScreenGui
    MZHub = Instance.new("ScreenGui")
    MZHub.Name = "MZHub"
    MZHub.Parent = CoreGui
    MZHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MZHub.Enabled = true

    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MZHub
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Visible = false
    
    -- Smooth corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = MainFrame
    
    -- Shadow effect
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 4
    shadow.Transparency = 0.7
    shadow.Parent = MainFrame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 15)
    topBarCorner.Parent = TopBar

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "MZ Hub - مركز إم زد"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -45, 0.5, -12)
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = CloseButton

    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Parent = MainFrame
    TabsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Position = UDim2.new(0, 0, 0, 50)
    TabsContainer.Size = UDim2.new(0, 100, 0, 350)

    -- Content Container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = MainFrame
    Content.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Content.BorderSizePixel = 0
    Content.Position = UDim2.new(0, 100, 0, 50)
    Content.Size = UDim2.new(0, 250, 0, 350)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 10)
    contentCorner.Parent = Content

    -- Create Tabs
    local ESPTab = createTabButton("ESP - الرؤية", UDim2.new(0, 10, 0, 20), TabsContainer, true)
    local CombatTab = createTabButton("Combat - القتال", UDim2.new(0, 10, 0, 80), TabsContainer, false)

    -- Create Content Frames
    local ESPContent = createESPContent(Content)
    local CombatContent = createCombatContent(Content)
    
    ESPContent.Visible = true
    CombatContent.Visible = false

    -- Button Events
    CloseButton.MouseButton1Click:Connect(function()
        toggleGUI(false)
    end)

    ESPTab.MouseButton1Click:Connect(function()
        ESPContent.Visible = true
        CombatContent.Visible = false
        ESPTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        CombatTab.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)

    CombatTab.MouseButton1Click:Connect(function()
        ESPContent.Visible = false
        CombatContent.Visible = true
        CombatTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        ESPTab.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)

    -- Make draggable
    makeDraggable(TopBar, MainFrame)

    return MainFrame
end

-- Tab Button Creation
function createTabButton(text, position, parent, isActive)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = isActive and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(50, 50, 70)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(0, 80, 0, 50)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.TextWrapped = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- Create ESP Content
function createESPContent(parent)
    local ESPContent = Instance.new("Frame")
    ESPContent.Name = "ESPContent"
    ESPContent.Parent = parent
    ESPContent.BackgroundTransparency = 1
    ESPContent.Size = UDim2.new(1, 0, 1, 0)
    
    -- ESP Toggle
    local ESPToggle = createButton("تفعيل ESP - تشغيل الرؤية", UDim2.new(0.1, 0, 0.1, 0), ESPContent)
    local ESPStatus = createStatusLabel("الحالة: غير مفعل", UDim2.new(0.1, 0, 0.3, 0), ESPContent, Color3.fromRGB(255, 80, 80))
    
    -- ESP Color
    local ESPColor = createButton("تغيير لون ESP", UDim2.new(0.1, 0, 0.45, 0), ESPContent)
    ESPColor.BackgroundColor3 = espColor

    ESPToggle.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        toggleESP(espEnabled)
        ESPStatus.Text = espEnabled and "الحالة: مفعل" or "الحالة: غير مفعل"
        ESPStatus.TextColor3 = espEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        
        -- Smooth button color change
        tweenObject(ESPToggle, {
            BackgroundColor3 = espEnabled and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        }, 0.2)
    end)

    ESPColor.MouseButton1Click:Connect(function()
        espColor = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
        tweenObject(ESPColor, {BackgroundColor3 = espColor}, 0.3)
        updateESPColors()
    end)

    return ESPContent
end

-- Create Combat Content
function createCombatContent(parent)
    local CombatContent = Instance.new("Frame")
    CombatContent.Name = "CombatContent"
    CombatContent.Parent = parent
    CombatContent.BackgroundTransparency = 1
    CombatContent.Size = UDim2.new(1, 0, 1, 0)
    
    -- Hitbox Toggle
    local HitboxToggle = createButton("تفعيل توسيع الهيت بوكس", UDim2.new(0.1, 0, 0.1, 0), CombatContent)
    local HitboxStatus = createStatusLabel("الحالة: غير مفعل", UDim2.new(0.1, 0, 0.3, 0), CombatContent, Color3.fromRGB(255, 80, 80))
    
    -- Hitbox Color
    local HitboxColor = createButton("تغيير لون الهيت بوكس", UDim2.new(0.1, 0, 0.45, 0), CombatContent)
    HitboxColor.BackgroundColor3 = hitboxColor
    
    -- Hitbox Size
    local HitboxSize = createTextBox("حجم الهيت بوكس", UDim2.new(0.1, 0, 0.65, 0), CombatContent, tostring(hitboxSize))

    HitboxToggle.MouseButton1Click:Connect(function()
        hitboxEnabled = not hitboxEnabled
        toggleHitboxExpander(hitboxEnabled)
        HitboxStatus.Text = hitboxEnabled and "الحالة: مفعل" or "الحالة: غير مفعل"
        HitboxStatus.TextColor3 = hitboxEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        
        tweenObject(HitboxToggle, {
            BackgroundColor3 = hitboxEnabled and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        }, 0.2)
    end)

    HitboxColor.MouseButton1Click:Connect(function()
        hitboxColor = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
        tweenObject(HitboxColor, {BackgroundColor3 = hitboxColor}, 0.3)
        updateHitboxColors()
    end)

    HitboxSize.FocusLost:Connect(function()
        local newSize = tonumber(HitboxSize.Text)
        if newSize and newSize > 0 and newSize <= 10 then
            hitboxSize = newSize
            if hitboxEnabled then
                toggleHitboxExpander(false)
                wait(0.1)
                toggleHitboxExpander(true)
            end
        else
            HitboxSize.Text = tostring(hitboxSize)
        end
    end)

    return CombatContent
end

-- UI Helper Functions
function createButton(text, position, parent)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(0.8, 0, 0, 50)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.TextWrapped = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    return button
end

function createStatusLabel(text, position, parent, color)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = UDim2.new(0.8, 0, 0, 30)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 16
    label.TextWrapped = true
    
    return label
end

function createTextBox(placeholder, position, parent, text)
    local textBox = Instance.new("TextBox")
    textBox.Parent = parent
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    textBox.BorderSizePixel = 0
    textBox.Position = position
    textBox.Size = UDim2.new(0.8, 0, 0, 40)
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = placeholder
    textBox.Text = text
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textBox
    
    return textBox
end

function makeDraggable(dragPart, mainFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Smooth Tween Function
function tweenObject(object, properties, duration)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Toggle GUI Function
function toggleGUI(show)
    guiVisible = show
    
    if show then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 10, 0, 10)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        -- Smooth open animation
        tweenObject(MainFrame, {
            Size = UDim2.new(0, 350, 0, 400)
        }, 0.4)
        
        tweenObject(OpenButton, {
            BackgroundColor3 = Color3.fromRGB(60, 140, 220)
        }, 0.3)
    else
        -- Smooth close animation
        tweenObject(MainFrame, {
            Size = UDim2.new(0, 10, 0, 10)
        }, 0.4)
        
        tweenObject(OpenButton, {
            BackgroundColor3 = Color3.fromRGB(40, 120, 200)
        }, 0.3)
        
        wait(0.4)
        MainFrame.Visible = false
    end
end

-- ESP Functions
function createESP(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") or espObjects[character] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "MZESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = espColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0.2
    highlight.Parent = character
    
    espObjects[character] = highlight
end

function removeESP(character)
    if espObjects[character] then
        espObjects[character]:Destroy()
        espObjects[character] = nil
    end
end

function toggleESP(state)
    espEnabled = state
    
    if state then
        -- Add ESP to all players
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                createESP(otherPlayer.Character)
            end
        end
        
        -- Connect to new players
        Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function(character)
                wait(1)
                if espEnabled then
                    createESP(character)
                end
            end)
        end)
    else
        -- Remove all ESP
        for character, _ in pairs(espObjects) do
            removeESP(character)
        end
    end
end

function updateESPColors()
    for character, highlight in pairs(espObjects) do
        if highlight then
            highlight.FillColor = espColor
            highlight.OutlineColor = espColor
        end
    end
end

-- Hitbox Functions
function applyHitboxExpander(character)
    if not character or hitboxHighlights[character] then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        hitboxHighlights[character] = {}
        originalSizes[character] = {}
        
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                -- Store original size
                originalSizes[character][part] = part.Size
                
                -- Apply size expansion
                part.Size = part.Size * hitboxSize
                
                -- Create visual highlight
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = "MZHitbox"
                highlight.Adornee = part
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 10
                highlight.Size = part.Size
                highlight.Color3 = hitboxColor
                highlight.Transparency = 0.3
                highlight.Parent = part
                
                table.insert(hitboxHighlights[character], highlight)
            end
        end
    end
end

function removeHitboxExpander(character)
    if hitboxHighlights[character] then
        -- Remove visual highlights
        for _, highlight in ipairs(hitboxHighlights[character]) do
            if highlight then
                highlight:Destroy()
            end
        end
        hitboxHighlights[character] = nil
        
        -- Restore original sizes
        if originalSizes[character] then
            for part, originalSize in pairs(originalSizes[character]) do
                if part and part.Parent then
                    part.Size = originalSize
                end
            end
            originalSizes[character] = nil
        end
    end
end

function toggleHitboxExpander(state)
    hitboxEnabled = state
    
    if state then
        -- Apply to all players
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                applyHitboxExpander(otherPlayer.Character)
            end
        end
    else
        -- Remove from all players
        for character, _ in pairs(hitboxHighlights) do
            removeHitboxExpander(character)
        end
        table.clear(hitboxHighlights)
        table.clear(originalSizes)
    end
end

function updateHitboxColors()
    for character, highlights in pairs(hitboxHighlights) do
        for _, highlight in ipairs(highlights) do
            if highlight then
                highlight.Color3 = hitboxColor
            end
        end
    end
end

-- Initialize the script
createOpenButton()
createMainGUI()

-- Mobile optimization
if UserInputService.TouchEnabled then
    OpenButton.Size = UDim2.new(0, 70, 0, 70)
    OpenButton.TextSize = 20
end

print("🎮 MZ Hub loaded successfully!")
print("📱 Created by Unknown Boi")
print("🔧 Features: ESP, Hitbox Expander, Arabic UI")
print("💡 Click the MZ button to open the menu!")
