-- Complete Aimbot & ESP System with WORKING FOV Circle
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Aimbot Configuration
local FOV_RADIUS = 80
local AIM_SNAP_STRENGTH = 0.9
local AUTO_AIM_ENABLED = true
local RAINBOW_SPEED = 3

-- ESP Configuration (Health removed)
local Config = {
    BoxESP = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    TeamColor = true,
    BoxOutline = true,
    
    NameESP = true,
    DistanceESP = true,
    HealthESP = false,
    SkeletonESP = false,
    
    TeamCheck = true,
    AllyColor = Color3.fromRGB(0, 255, 140),
    EnemyColor = Color3.fromRGB(255, 25, 25),
    
    BoxTrans = 0.7,
    TextTrans = 0.7,
    
    MaxDistance = 1000,
    TextSize = 16
}

-- Local variables
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local fovCircle = nil
local currentTarget = nil
local targetLock = false

-- UI Toggles
local AimbotEnabled = true
local ESPEnabled = true
local FOVCircleVisible = false
local UIVisible = false

-- ESP Objects
local ESPObjects = {}

-- SIMPLE FOV CIRCLE CREATION
local function createFOVCircle()
    if not Drawing then 
        print("❌ Drawing library not available")
        return nil
    end
    
    local success, circle = pcall(function()
        local drawing = Drawing.new("Circle")
        drawing.Visible = false
        drawing.Radius = FOV_RADIUS
        drawing.Thickness = 2
        drawing.Color = Color3.new(1, 0, 0)
        drawing.Filled = false
        drawing.Transparency = 0.8
        return drawing
    end)
    
    if success and circle then
        print("✅ FOV Circle created successfully!")
        return circle
    else
        print("❌ Failed to create FOV circle")
        return nil
    end
end

-- Initialize FOV Circle
fovCircle = createFOVCircle()

-- SIMPLE FOV UPDATE
local function updateFOVCircle()
    if not fovCircle then
        fovCircle = createFOVCircle()
        if not fovCircle then return end
    end
    
    if not Camera then 
        Camera = workspace.CurrentCamera
        if not Camera then return end
    end
    
    -- Always update position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = screenCenter
    fovCircle.Radius = FOV_RADIUS
    
    -- Update visibility and colors
    if FOVCircleVisible then
        local rainbowTime = tick() * RAINBOW_SPEED
        local r = math.sin(rainbowTime) * 0.5 + 0.5
        local g = math.sin(rainbowTime + 2) * 0.5 + 0.5
        local b = math.sin(rainbowTime + 4) * 0.5 + 0.5
        fovCircle.Color = Color3.new(r, g, b)
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end

-- AIMBOT FUNCTIONS
local function isTargetVisible(targetPart)
    if not targetPart then return false end
    if not Camera then return false end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    if player.Character then
        raycastParams.FilterDescendantsInstances = {player.Character}
    end
    
    local raycastResult = workspace:Raycast(origin, (targetPos - origin), raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        return hitPart:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function findBestTarget()
    local bestTarget = nil
    local closestDistance = FOV_RADIUS
    if not Camera then return nil end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local head = otherPlayer.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local screenPoint, visible = Camera:WorldToScreenPoint(head.Position)
                
                if visible then
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (screenPos - screenCenter).Magnitude
                    
                    if distance <= FOV_RADIUS and distance < closestDistance then
                        if isTargetVisible(head) then
                            bestTarget = head
                            closestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function instantHeadLock(targetHead)
    if not targetHead or not Camera then return end
    local headPosition = targetHead.Position
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPosition)
end

local function maintainHeadLock(targetHead)
    if not targetHead or not Camera then return end
    local headPosition = targetHead.Position
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPosition)
end

-- ESP FUNCTIONS (No Health)
local function CreateDrawing(type, props)
    local obj = nil
    pcall(function()
        obj = Drawing.new(type)
        for i,v in pairs(props) do
            obj[i] = v
        end
    end)
    return obj
end

local function IsAlive(plr)
    local success, result = pcall(function()
        return plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
    end)
    return success and result or false
end

local function GetTeamColor(plr)
    if Config.TeamColor and plr.Team and plr.Team.TeamColor then
        return plr.Team.TeamColor.Color
    elseif Config.TeamCheck then
        return plr.Team == player.Team and Config.AllyColor or Config.EnemyColor
    else
        return Config.BoxColor
    end
end

local function GetBoxSize(plr)
    local success, boxSize, boxPos = pcall(function()
        local char = plr.Character
        local hrp = char.HumanoidRootPart
        local head = char.Head
        
        local rootPos, rootVis = Camera:WorldToViewportPoint(hrp.Position)
        if not rootVis then return Vector2.new(), Vector2.new(), false end
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        local boxSize = Vector2.new(math.abs(headPos.Y - legPos.Y) * 0.6, math.abs(headPos.Y - legPos.Y))
        local boxPos = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
        
        return boxSize, boxPos, true
    end)
    
    if success then
        return boxSize, boxPos, true
    else
        return Vector2.new(), Vector2.new(), false
    end
end

local function GetDistance(pos)
    local success, dist = pcall(function()
        return (Camera.CFrame.Position - pos).Magnitude
    end)
    return success and math.floor(dist) or 0
end

-- ESP without health bars
local function CreatePlayerESP(plr)
    local esp = {
        Box = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Transparency = Config.BoxTrans,
            Color = Config.BoxColor,
            Visible = false
        }),
        BoxOutline = CreateDrawing("Square", {
            Thickness = 3,
            Filled = false,
            Transparency = Config.BoxTrans,
            Color = Color3.fromRGB(0, 0, 0),
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Text = plr.Name,
            Size = Config.TextSize,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Color = Config.BoxColor,
            Transparency = Config.TextTrans,
            Visible = false
        }),
        Distance = CreateDrawing("Text", {
            Size = Config.TextSize - 2,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Color = Color3.fromRGB(175, 175, 175),
            Transparency = Config.TextTrans,
            Visible = false
        })
    }
    
    ESPObjects[plr] = esp
    return esp
end

local function UpdateESP()
    if not ESPEnabled then
        for _, esp in pairs(ESPObjects) do
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
        end
        return
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local esp = ESPObjects[plr] or CreatePlayerESP(plr)
            
            pcall(function()
                if IsAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local char = plr.Character
                    local hrp = char.HumanoidRootPart
                    
                    local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
                    local dist = GetDistance(hrp.Position)
                    
                    if vis and dist <= Config.MaxDistance then
                        local boxSize, boxPos, validBox = GetBoxSize(plr)
                        local teamColor = GetTeamColor(plr)
                        
                        if validBox then
                            if Config.BoxESP then
                                esp.Box.Size = boxSize
                                esp.Box.Position = boxPos
                                esp.Box.Color = teamColor
                                esp.Box.Visible = true
                                
                                if Config.BoxOutline then
                                    esp.BoxOutline.Size = boxSize
                                    esp.BoxOutline.Position = boxPos
                                    esp.BoxOutline.Visible = true
                                else
                                    esp.BoxOutline.Visible = false
                                end
                            else
                                esp.Box.Visible = false
                                esp.BoxOutline.Visible = false
                            end
                            
                            if Config.NameESP then
                                esp.Name.Text = plr.Name
                                esp.Name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 15)
                                esp.Name.Color = teamColor
                                esp.Name.Visible = true
                            else
                                esp.Name.Visible = false
                            end
                            
                            if Config.DistanceESP then
                                esp.Distance.Text = tostring(dist) .. "m"
                                esp.Distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 3)
                                esp.Distance.Visible = true
                            else
                                esp.Distance.Visible = false
                            end
                        else
                            esp.Box.Visible = false
                            esp.BoxOutline.Visible = false
                            esp.Name.Visible = false
                            esp.Distance.Visible = false
                        end
                    else
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                        esp.Name.Visible = false
                        esp.Distance.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.BoxOutline.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                end
            end)
        end
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle (SIMPLE AND RELIABLE)
    updateFOVCircle()
    
    -- Aimbot System
    if AimbotEnabled then
        local newTarget = findBestTarget()
        
        if newTarget then
            if not currentTarget or currentTarget ~= newTarget then
                instantHeadLock(newTarget)
                currentTarget = newTarget
                targetLock = true
            else
                maintainHeadLock(currentTarget)
            end
        else
            currentTarget = nil
            targetLock = false
        end
    end
    
    -- ESP System
    UpdateESP()
end)

-- SIMPLE UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotTesting"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.BackgroundTransparency = 0.1
Title.Text = "Aimbot Testing"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Toggle Buttons Container
local TogglesContainer = Instance.new("Frame")
TogglesContainer.Size = UDim2.new(1, -20, 1, -50)
TogglesContainer.Position = UDim2.new(0, 10, 0, 50)
TogglesContainer.BackgroundTransparency = 1
TogglesContainer.Parent = MainFrame

-- Aimbot Toggle
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(1, 0, 0, 40)
AimbotToggle.Position = UDim2.new(0, 0, 0, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
AimbotToggle.BorderSizePixel = 0
AimbotToggle.Text = "Aimbot: ON"
AimbotToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
AimbotToggle.Font = Enum.Font.SourceSansSemibold
AimbotToggle.TextSize = 16
AimbotToggle.Parent = TogglesContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = AimbotToggle

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, 0, 0, 40)
ESPToggle.Position = UDim2.new(0, 0, 0, 50)
ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ESPToggle.BorderSizePixel = 0
ESPToggle.Text = "ESP: ON"
ESPToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
ESPToggle.Font = Enum.Font.SourceSansSemibold
ESPToggle.TextSize = 16
ESPToggle.Parent = TogglesContainer
ToggleCorner:Clone().Parent = ESPToggle

-- FOV Circle Toggle
local FOVToggle = Instance.new("TextButton")
FOVToggle.Size = UDim2.new(1, 0, 0, 40)
FOVToggle.Position = UDim2.new(0, 0, 0, 100)
FOVToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
FOVToggle.BorderSizePixel = 0
FOVToggle.Text = "FOV Circle: OFF"
FOVToggle.TextColor3 = Color3.fromRGB(255, 50, 50)
FOVToggle.Font = Enum.Font.SourceSansSemibold
FOVToggle.TextSize = 16
FOVToggle.Parent = TogglesContainer
ToggleCorner:Clone().Parent = FOVToggle

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame
ToggleCorner:Clone().Parent = CloseButton

-- Open/Close Button (ALWAYS VISIBLE)
local OpenCloseButton = Instance.new("TextButton")
OpenCloseButton.Size = UDim2.new(0, 60, 0, 60)
OpenCloseButton.Position = UDim2.new(0, 20, 0, 20)
OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
OpenCloseButton.BorderSizePixel = 0
OpenCloseButton.Text = "☰"
OpenCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseButton.Font = Enum.Font.SourceSansBold
OpenCloseButton.TextSize = 24
OpenCloseButton.Visible = true
OpenCloseButton.Parent = ScreenGui

local OpenCloseCorner = Instance.new("UICorner")
OpenCloseCorner.CornerRadius = UDim.new(1, 0)
OpenCloseCorner.Parent = OpenCloseButton

-- Toggle Functions
AimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    AimbotToggle.TextColor3 = AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
end)

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
    ESPToggle.TextColor3 = ESPEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
end)

FOVToggle.MouseButton1Click:Connect(function()
    FOVCircleVisible = not FOVCircleVisible
    FOVToggle.Text = "FOV Circle: " .. (FOVCircleVisible and "ON" or "OFF")
    FOVToggle.TextColor3 = FOVCircleVisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    
    if FOVCircleVisible then
        print("🌈 FOV Circle is now VISIBLE - Look at screen center!")
    else
        print("🎯 FOV Circle is now HIDDEN")
    end
end)

-- Open/Close Button Function
OpenCloseButton.MouseButton1Click:Connect(function()
    UIVisible = not UIVisible
    MainFrame.Visible = UIVisible
    
    if UIVisible then
        OpenCloseButton.Text = "✕"
        OpenCloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    else
        OpenCloseButton.Text = "☰"
        OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    UIVisible = false
    OpenCloseButton.Text = "☰"
    OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
end)

-- Make UI draggable
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Auto-respawn support
player.CharacterAdded:Connect(function(character)
    print("🔄 Character respawned - System still active")
end)

player.CharacterRemoving:Connect(function(character)
    print("💀 Character died - System still active")
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        if fovCircle then
            pcall(function() fovCircle:Remove() end)
        end
        ScreenGui:Destroy()
    end
end)

print("🎯 AIMBOT TESTING SYSTEM LOADED! 🎯")
print("=====================================")
print("Features:")
print("- 🔥 Instant Head-Lock Aimbot")
print("- 🎯 ESP with Box, Name, Distance (No Health)")
print("- 🌈 Rainbow FOV Circle")
print("- 📱 Phone-Friendly UI")
print("- 💀 Works when dead/respawning")
print("")
print("To test FOV Circle:")
print("1. Click the BLUE CIRCLE button")
print("2. Click 'FOV Circle: OFF' to turn it ON")
print("3. Look at screen center - Rainbow circle should appear!")
print("4. If not working, check console for error messages")
