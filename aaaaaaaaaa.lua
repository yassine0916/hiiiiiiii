-- MZ Hub Script
-- Copyright: MZ Hub by Unknown Boi
-- Language: Arabic

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- GUI Variables
local MZHub, MainFrame, OpenButton
local guiVisible = true
local espEnabled = false
local hitboxEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local hitboxColor = Color3.fromRGB(0, 255, 0)
local hitboxSize = 5

-- Storage for ESP and Hitbox objects
local espObjects = {}
local trackLines = {}
local originalSizes = {}
local hitboxHighlights = {}

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

-- Create Open/Close Button
function createOpenButton()
    OpenButton = Instance.new("TextButton")
    OpenButton.Name = "OpenButton"
    OpenButton.Parent = CoreGui
    OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    OpenButton.BorderSizePixel = 0
    OpenButton.Position = UDim2.new(0, 10, 0.5, -25)
    OpenButton.Size = UDim2.new(0, 50, 0, 50)
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.Text = "MZ"
    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.TextSize = 16
    OpenButton.ZIndex = 100
    OpenButton.Visible = true
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = OpenButton
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 2
    stroke.Parent = OpenButton
    
    return OpenButton
end

-- Create Main GUI
function createGUI()
    MZHub = Instance.new("ScreenGui")
    MZHub.Name = "MZHub"
    MZHub.Parent = CoreGui
    MZHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MZHub.Enabled = true

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MZHub
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Visible = false
    
    -- Smooth corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = MainFrame
    
    -- Shadow effect
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 3
    shadow.Transparency = 0.8
    shadow.Parent = MainFrame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -35, 0, 8)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = CloseButton

    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Parent = MainFrame
    TabsContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    TabsContainer.Size = UDim2.new(0, 100, 0, 410)

    -- Content Container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = MainFrame
    Content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Content.BorderSizePixel = 0
    Content.Position = UDim2.new(0, 100, 0, 40)
    Content.Size = UDim2.new(0, 250, 0, 410)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = Content

    -- Create Tabs
    local tabs = {
        {Name = "ESP", Text = "ESP - الرؤية"},
        {Name = "Combat", Text = "Combat - القتال"}
    }
    
    local tabButtons = {}
    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.Name .. "Tab"
        tabButton.Parent = TabsContainer
        tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(35, 35, 35)
        tabButton.BorderSizePixel = 0
        tabButton.Position = UDim2.new(0, 10, 0, 10 + ((i-1) * 50))
        tabButton.Size = UDim2.new(0, 80, 0, 40)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = tab.Text
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 12
        tabButton.TextWrapped = true
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        tabButtons[tab.Name] = tabButton
    end

    -- ESP Content
    local ESPContent = createESPContent(Content)
    ESPContent.Visible = true

    -- Combat Content
    local CombatContent = createCombatContent(Content)
    CombatContent.Visible = false

    -- Button Events
    CloseButton.MouseButton1Click:Connect(function()
        toggleGUI(false)
    end)

    OpenButton.MouseButton1Click:Connect(function()
        toggleGUI(not MainFrame.Visible)
    end)

    tabButtons.ESP.MouseButton1Click:Connect(function()
        ESPContent.Visible = true
        CombatContent.Visible = false
        tabButtons.ESP.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabButtons.Combat.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    tabButtons.Combat.MouseButton1Click:Connect(function()
        ESPContent.Visible = false
        CombatContent.Visible = true
        tabButtons.Combat.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabButtons.ESP.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)

    -- Make draggable
    makeDraggable(TopBar, MainFrame)

    return MainFrame
end

-- Create ESP Content
function createESPContent(parent)
    local ESPContent = Instance.new("Frame")
    ESPContent.Name = "ESPContent"
    ESPContent.Parent = parent
    ESPContent.BackgroundTransparency = 1
    ESPContent.Size = UDim2.new(1, 0, 1, 0)
    
    -- ESP Toggle
    local ESPToggle = createButton("تفعيل ESP - تشغيل الرؤية", UDim2.new(0.1, 0, 0.05, 0), ESPContent)
    local ESPStatus = createStatusLabel("الحالة: غير مفعل", UDim2.new(0.1, 0, 0.2, 0), ESPContent, Color3.fromRGB(255, 50, 50))
    
    -- ESP Color
    local ESPColor = createButton("تغيير لون ESP", UDim2.new(0.1, 0, 0.3, 0), ESPContent)
    ESPColor.BackgroundColor3 = espColor

    ESPToggle.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        toggleESP(espEnabled)
        ESPStatus.Text = espEnabled and "الحالة: مفعل" or "الحالة: غير مفعل"
        ESPStatus.TextColor3 = espEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        tweenObject(ESPToggle, {BackgroundColor3 = espEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(60, 60, 60)}, 0.2)
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
    local HitboxToggle = createButton("تفعيل توسيع الهيت بوكس", UDim2.new(0.1, 0, 0.05, 0), CombatContent)
    local HitboxStatus = createStatusLabel("الحالة: غير مفعل", UDim2.new(0.1, 0, 0.2, 0), CombatContent, Color3.fromRGB(255, 50, 50))
    
    -- Hitbox Color
    local HitboxColor = createButton("تغيير لون الهيت بوكس", UDim2.new(0.1, 0, 0.3, 0), CombatContent)
    HitboxColor.BackgroundColor3 = hitboxColor
    
    -- Hitbox Size
    local HitboxSize = createTextBox("حجم الهيت بوكس", UDim2.new(0.1, 0, 0.45, 0), CombatContent, tostring(hitboxSize))

    HitboxToggle.MouseButton1Click:Connect(function()
        hitboxEnabled = not hitboxEnabled
        toggleHitboxExpander(hitboxEnabled)
        HitboxStatus.Text = hitboxEnabled and "الحالة: مفعل" or "الحالة: غير مفعل"
        HitboxStatus.TextColor3 = hitboxEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        tweenObject(HitboxToggle, {BackgroundColor3 = hitboxEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(60, 60, 60)}, 0.2)
    end)

    HitboxColor.MouseButton1Click:Connect(function()
        hitboxColor = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
        tweenObject(HitboxColor, {BackgroundColor3 = hitboxColor}, 0.3)
        updateHitboxColors()
    end)

    HitboxSize.FocusLost:Connect(function()
        local newSize = tonumber(HitboxSize.Text)
        if newSize and newSize > 0 and newSize <= 20 then
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

-- UI Creation Helper Functions
function createButton(text, position, parent)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(0.8, 0, 0, 45)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.TextWrapped = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
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
    label.TextSize = 14
    label.TextWrapped = true
    
    return label
end

function createTextBox(placeholder, position, parent, text)
    local textBox = Instance.new("TextBox")
    textBox.Parent = parent
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
    corner.CornerRadius = UDim.new(0, 6)
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

-- Toggle GUI Function
function toggleGUI(show)
    if show then
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
        MainFrame.Size = UDim2.new(0, 10, 0, 10)
        
        tweenObject(MainFrame, {
            Size = UDim2.new(0, 350, 0, 450)
        }, 0.4)
        
        tweenObject(OpenButton, {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }, 0.3)
    else
        tweenObject(MainFrame, {
            Size = UDim2.new(0, 10, 0, 10)
        }, 0.4)
        
        tweenObject(OpenButton, {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0
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
        
        -- Handle character respawns
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                otherPlayer.CharacterAdded:Connect(function(character)
                    wait(1)
                    if espEnabled then
                        createESP(character)
                    end
                end)
            end
        end
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

-- Hitbox Functions (FIXED - properly turns off)
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
                highlight.Transparency = 0.4
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
        
        -- Connect to new players
        Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function(character)
                wait(1)
                if hitboxEnabled then
                    applyHitboxExpander(character)
                end
            end)
        end)
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

-- Initialize
createOpenButton()
createGUI()

-- Mobile optimization
if UserInputService.TouchEnabled then
    OpenButton.Size = UDim2.new(0, 60, 0, 60)
    OpenButton.TextSize = 18
end

print("MZ Hub loaded! Created by Unknown Boi")
print("✅ Smooth UI with open/close button")
print("✅ ESP System with toggle")
print("✅ Hitbox Expander with proper toggle (turns off completely)")
print("✅ Mobile optimized")
print("✅ Arabic language interface")
