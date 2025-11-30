-- COMPLETE AIMBOT & ESP WITH WORKING FOV CIRCLE
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Aimbot Configuration
local FOV_RADIUS = 80
local AUTO_AIM_ENABLED = true

-- ESP Configuration
local Config = {
    BoxESP = true,
    NameESP = true,
    DistanceESP = true,
    TeamCheck = true,
    MaxDistance = 1000
}

-- Local variables
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local currentTarget = nil

-- UI Toggles
local AimbotEnabled = true
local ESPEnabled = true
local FOVCircleVisible = true  -- VISIBLE BY DEFAULT
local UIVisible = false

-- FOV Circle Colors
local FOVColors = {
    Color3.new(1, 1, 1),  -- White
    Color3.new(1, 0, 0),  -- Red
    Color3.new(0, 1, 0),  -- Green
    Color3.new(0, 0, 1),  -- Blue
    Color3.new(1, 1, 0),  -- Yellow
    Color3.new(1, 0, 1),  -- Pink
    Color3.new(0, 1, 1)   -- Cyan
}
local currentColorIndex = 1

-- ESP Objects
local ESPObjects = {}

-- WORKING FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true  -- VISIBLE IMMEDIATELY
fovCircle.Radius = FOV_RADIUS
fovCircle.Thickness = 3
fovCircle.Color = FOVColors[currentColorIndex]  -- Start with white
fovCircle.Filled = false
fovCircle.Transparency = 1

print("FOV CIRCLE CREATED - VISIBLE ON SCREEN!")

-- UPDATE FOV CIRCLE POSITION
local function updateFOVCircle()
    if not Camera then 
        Camera = workspace.CurrentCamera
        if not Camera then return end
    end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = screenCenter
    fovCircle.Radius = FOV_RADIUS
    fovCircle.Color = FOVColors[currentColorIndex]  -- Update color
    
    if FOVCircleVisible then
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end

-- CHANGE FOV COLOR
local function changeFOVColor()
    currentColorIndex = currentColorIndex + 1
    if currentColorIndex > #FOVColors then
        currentColorIndex = 1
    end
    fovCircle.Color = FOVColors[currentColorIndex]
    
    local colorNames = {"WHITE", "RED", "GREEN", "BLUE", "YELLOW", "PINK", "CYAN"}
    print("FOV Circle Color: " .. colorNames[currentColorIndex])
end

-- AIMBOT FUNCTIONS (WORK EVEN WHEN DEAD)
local function isTargetVisible(targetPart)
    if not targetPart or not Camera then return false end
    
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
            
            -- Check if target is alive (but we don't care if WE are dead)
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

-- ESP FUNCTIONS (WORK EVEN WHEN DEAD)
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
    return plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

local function GetTeamColor(plr)
    if Config.TeamCheck and plr.Team then
        return plr.Team == player.Team and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 25, 25)
    else
        return Color3.fromRGB(255, 255, 255)
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

local function CreatePlayerESP(plr)
    local esp = {
        Box = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Transparency = 0.7,
            Color = Color3.new(1, 1, 1),
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Text = plr.Name,
            Size = 16,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 1, 1),
            Transparency = 0.7,
            Visible = false
        }),
        Distance = CreateDrawing("Text", {
            Size = 14,
            Center = true,
            Outline = true,
            Color = Color3.new(0.7, 0.7, 0.7),
            Transparency = 0.7,
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
            esp.Name.Visible = false
            esp.Distance.Visible = false
        end
        return
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local esp = ESPObjects[plr] or CreatePlayerESP(plr)
            
            pcall(function()
                -- Check if target is alive (we don't care if WE are dead)
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
                            else
                                esp.Box.Visible = false
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
                            esp.Name.Visible = false
                            esp.Distance.Visible = false
                        end
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
            end)
        end
    end
end

-- MAIN LOOP (ALWAYS RUNS EVEN WHEN DEAD)
RunService.RenderStepped:Connect(function()
    -- UPDATE FOV CIRCLE (ALWAYS WORKS)
    updateFOVCircle()
    
    -- AIMBOT SYSTEM (WORKS EVEN WHEN DEAD)
    if AimbotEnabled then
        local newTarget = findBestTarget()
        
        if newTarget then
            instantHeadLock(newTarget)
            currentTarget = newTarget
        else
            currentTarget = nil
        end
    end
    
    -- ESP SYSTEM (WORKS EVEN WHEN DEAD)
    UpdateESP()
end)

-- SIMPLE UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotTesting"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 190)  -- Increased height for color button
MainFrame.Position = UDim2.new(0, 10, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.BackgroundTransparency = 0.1
Title.Text = "Aimbot"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Toggle Buttons Container
local TogglesContainer = Instance.new("Frame")
TogglesContainer.Size = UDim2.new(1, -20, 1, -40)
TogglesContainer.Position = UDim2.new(0, 10, 0, 40)
TogglesContainer.BackgroundTransparency = 1
TogglesContainer.Parent = MainFrame

-- Aimbot Toggle
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(1, 0, 0, 30)
AimbotToggle.Position = UDim2.new(0, 0, 0, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
AimbotToggle.BorderSizePixel = 0
AimbotToggle.Text = "Aimbot: ON"
AimbotToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
AimbotToggle.Font = Enum.Font.SourceSansSemibold
AimbotToggle.TextSize = 14
AimbotToggle.Parent = TogglesContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = AimbotToggle

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, 0, 0, 30)
ESPToggle.Position = UDim2.new(0, 0, 0, 35)
ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ESPToggle.BorderSizePixel = 0
ESPToggle.Text = "ESP: ON"
ESPToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
ESPToggle.Font = Enum.Font.SourceSansSemibold
ESPToggle.TextSize = 14
ESPToggle.Parent = TogglesContainer
ToggleCorner:Clone().Parent = ESPToggle

-- FOV Circle Toggle
local FOVToggle = Instance.new("TextButton")
FOVToggle.Size = UDim2.new(1, 0, 0, 30)
FOVToggle.Position = UDim2.new(0, 0, 0, 70)
FOVToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
FOVToggle.BorderSizePixel = 0
FOVToggle.Text = "FOV Circle: ON"
FOVToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
FOVToggle.Font = Enum.Font.SourceSansSemibold
FOVToggle.TextSize = 14
FOVToggle.Parent = TogglesContainer
ToggleCorner:Clone().Parent = FOVToggle

-- FOV Color Changer Button
local ColorButton = Instance.new("TextButton")
ColorButton.Size = UDim2.new(1, 0, 0, 30)
ColorButton.Position = UDim2.new(0, 0, 0, 105)
ColorButton.BackgroundColor3 = FOVColors[currentColorIndex]  -- Show current color
ColorButton.BorderSizePixel = 0
ColorButton.Text = "Change FOV Color"
ColorButton.TextColor3 = Color3.new(0, 0, 0)  -- Black text for visibility
ColorButton.Font = Enum.Font.SourceSansSemibold
ColorButton.TextSize = 12
ColorButton.Parent = TogglesContainer
ToggleCorner:Clone().Parent = ColorButton

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame
ToggleCorner:Clone().Parent = CloseButton

-- Open/Close Button
local OpenCloseButton = Instance.new("TextButton")
OpenCloseButton.Size = UDim2.new(0, 50, 0, 50)
OpenCloseButton.Position = UDim2.new(0, 20, 0, 20)
OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
OpenCloseButton.BorderSizePixel = 0
OpenCloseButton.Text = "☰"
OpenCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseButton.Font = Enum.Font.SourceSansBold
OpenCloseButton.TextSize = 20
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
end)

-- Color Changer Function
ColorButton.MouseButton1Click:Connect(function()
    changeFOVColor()
    ColorButton.BackgroundColor3 = FOVColors[currentColorIndex]  -- Update button color
    
    local colorNames = {"WHITE", "RED", "GREEN", "BLUE", "YELLOW", "PINK", "CYAN"}
    ColorButton.Text = "Color: " .. colorNames[currentColorIndex]
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
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
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

-- AUTO-RESPAWN SUPPORT - SYSTEM ALWAYS WORKS
player.CharacterAdded:Connect(function(character)
    print("🔄 Character respawned - System still working!")
end)

player.CharacterRemoving:Connect(function(character)
    print("💀 Character died - System STILL WORKING!")
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

print("🎯 AIMBOT SYSTEM LOADED!")
print("✅ FOV CIRCLE IS VISIBLE ON SCREEN!")
print("✅ WORKS EVEN WHEN YOU DIE!")
print("✅ COLOR CHANGER BUTTON ADDED!")
print("✅ AIMBOT IS WORKING!")
print("✅ ESP IS ENABLED!")
print("Click the blue button to open controls")
