-- COMPLETE AIMBOT & ESP WITH INSTANT HEAD TRACKING
-- Copyright ©️ "MZ server" made by "unknown boi"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Language Selection
local chosenLanguage = nil
local Languages = {
    English = {
        title = "Aimbot - FOV 100",
        aimbot = "Aimbot: ON",
        esp = "ESP: ON", 
        fovCircle = "FOV Circle: ON",
        close = "X",
        open = "☰",
        closeText = "✕",
        selectLanguage = "Select Language / اختر اللغة",
        english = "English",
        arabic = "العربية",
        copyright = "Copyright ©️ 'MZ server' made by 'unknown boi'",
        loaded = "System Loaded!",
        working = "System Working!",
        respawned = "Character respawned - System working!",
        died = "Character died - System STILL WORKING!",
        redCircle = "RED FOV CIRCLE SIZE 100 - WORKING!",
        active = "ACTIVE!"
    },
    Arabic = {
        title = "الإصابة التلقائية - مجال الرؤية 100",
        aimbot = "الإصابة التلقائية: تشغيل",
        esp = "الرؤية عبر الجدران: تشغيل", 
        fovCircle = "دائرة الرؤية: تشغيل",
        close = "X",
        open = "☰",
        closeText = "✕",
        selectLanguage = "Select Language / اختر اللغة",
        english = "English",
        arabic = "العربية",
        copyright = "حقوق النشر ©️ 'MZ server' صنع بواسطة 'unknown boi'",
        loaded = "تم تحميل النظام!",
        working = "النظام يعمل!",
        respawned = "إعادة ولادة الشخصية - النظام يعمل!",
        died = "وفاة الشخصية - النظام لا يزال يعمل!",
        redCircle = "دائرة رؤية حمراء بحجم 100 - تعمل!",
        active = "نشط!"
    }
}

-- Aimbot Configuration
local FOV_RADIUS = 100
local AUTO_AIM_ENABLED = true
local AIM_STRENGTH = 1.0  -- INSTANT SNAP

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
local targetLock = false

-- UI Toggles
local AimbotEnabled = true
local ESPEnabled = true
local FOVCircleVisible = true
local UIVisible = false

-- ESP Objects
local ESPObjects = {}

-- =============================================
-- LANGUAGE SELECTION UI
-- =============================================
local function createLanguageSelection()
    local LangGui = Instance.new("ScreenGui")
    LangGui.Name = "LanguageSelection"
    LangGui.Parent = CoreGui
    LangGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = LangGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.BackgroundTransparency = 0.1
    Title.Text = "Select Language / اختر اللغة"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    -- English Button
    local EnglishBtn = Instance.new("TextButton")
    EnglishBtn.Size = UDim2.new(0.8, 0, 0, 40)
    EnglishBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
    EnglishBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    EnglishBtn.BorderSizePixel = 0
    EnglishBtn.Text = "English"
    EnglishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    EnglishBtn.Font = Enum.Font.SourceSansSemibold
    EnglishBtn.TextSize = 16
    EnglishBtn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = EnglishBtn

    -- Arabic Button
    local ArabicBtn = Instance.new("TextButton")
    ArabicBtn.Size = UDim2.new(0.8, 0, 0, 40)
    ArabicBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    ArabicBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ArabicBtn.BorderSizePixel = 0
    ArabicBtn.Text = "العربية"
    ArabicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ArabicBtn.Font = Enum.Font.SourceSansSemibold
    ArabicBtn.TextSize = 16
    ArabicBtn.Parent = MainFrame
    BtnCorner:Clone().Parent = ArabicBtn

    -- Copyright Label
    local CopyrightLabel = Instance.new("TextLabel")
    CopyrightLabel.Size = UDim2.new(1, 0, 0, 20)
    CopyrightLabel.Position = UDim2.new(0, 0, 0.9, 0)
    CopyrightLabel.BackgroundTransparency = 1
    CopyrightLabel.Text = "Copyright ©️ 'MZ server' made by 'unknown boi'"
    CopyrightLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    CopyrightLabel.Font = Enum.Font.SourceSans
    CopyrightLabel.TextSize = 12
    CopyrightLabel.Parent = MainFrame

    EnglishBtn.MouseButton1Click:Connect(function()
        chosenLanguage = Languages.English
        LangGui:Destroy()
        initializeSystem()
    end)

    ArabicBtn.MouseButton1Click:Connect(function()
        chosenLanguage = Languages.Arabic
        LangGui:Destroy()
        initializeSystem()
    end)

    return LangGui
end

-- =============================================
-- WORKING FOV CIRCLE
-- =============================================
local ScreenGui, Frame

local function createFOVCircle()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileFOVCircle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = CoreGui

    Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
    Frame.Position = UDim2.new(0.5, -FOV_RADIUS, 0.5, -FOV_RADIUS)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICircle = Instance.new("UICorner")
    UICircle.CornerRadius = UDim.new(0.5, 0)
    UICircle.Parent = Frame

    local Outline = Instance.new("UIStroke")
    Outline.Color = Color3.fromRGB(255, 0, 0)
    Outline.Thickness = 4
    Outline.Transparency = 0
    Outline.Parent = Frame
end

-- UPDATE FOV CIRCLE
local function updateFOVCircle()
    if not Camera then 
        Camera = workspace.CurrentCamera 
        if not Camera then return end 
    end
    
    local Viewport = Camera.ViewportSize
    if Viewport.X == 0 or Viewport.Y == 0 then return end
    
    local CenterX = Viewport.X / 2
    local CenterY = Viewport.Y / 2
    
    Frame.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
    Frame.Position = UDim2.new(0, CenterX - FOV_RADIUS, 0, CenterY - FOV_RADIUS)
    
    if FOVCircleVisible then
        ScreenGui.Enabled = true
    else
        ScreenGui.Enabled = false
    end
end

-- =============================================
-- INSTANT AIMBOT FUNCTIONS
-- =============================================
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

-- INSTANT HEAD SNAP AND FOLLOW
local function instantHeadLock(targetHead)
    if not targetHead or not Camera then return end
    local headPosition = targetHead.Position
    -- INSTANT SNAP - NO SMOOTHING
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPosition)
end

-- PERFECT HEAD TRACKING
local function maintainHeadLock(targetHead)
    if not targetHead or not Camera then return end
    local headPosition = targetHead.Position
    -- INSTANT FOLLOW - STAYS ON HEAD
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPosition)
end

-- =============================================
-- ESP FUNCTIONS
-- =============================================
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

-- =============================================
-- MAIN SYSTEM
-- =============================================
local ControlGui, MainFrame, OpenCloseButton

local function initializeSystem()
    print("🔄 Initializing system with language: " .. (chosenLanguage == Languages.English and "English" or "Arabic"))
    
    -- Create FOV Circle
    createFOVCircle()
    
    -- Create Control UI
    ControlGui = Instance.new("ScreenGui")
    ControlGui.Name = "AimbotControls"
    ControlGui.Parent = CoreGui
    ControlGui.ResetOnSpawn = false

    -- Main Container
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 200, 0, 180)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BackgroundTransparency = 0.3
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ControlGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.BackgroundTransparency = 0.1
    Title.Text = chosenLanguage.title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.Parent = MainFrame

    -- Toggle Buttons Container
    local TogglesContainer = Instance.new("Frame")
    TogglesContainer.Size = UDim2.new(1, -20, 1, -60)
    TogglesContainer.Position = UDim2.new(0, 10, 0, 40)
    TogglesContainer.BackgroundTransparency = 1
    TogglesContainer.Parent = MainFrame

    -- Aimbot Toggle
    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Size = UDim2.new(1, 0, 0, 30)
    AimbotToggle.Position = UDim2.new(0, 0, 0, 0)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    AimbotToggle.BorderSizePixel = 0
    AimbotToggle.Text = chosenLanguage.aimbot
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
    ESPToggle.Text = chosenLanguage.esp
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
    FOVToggle.Text = chosenLanguage.fovCircle
    FOVToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    FOVToggle.Font = Enum.Font.SourceSansSemibold
    FOVToggle.TextSize = 14
    FOVToggle.Parent = TogglesContainer
    ToggleCorner:Clone().Parent = FOVToggle

    -- Copyright Label
    local CopyrightLabel = Instance.new("TextLabel")
    CopyrightLabel.Size = UDim2.new(1, -20, 0, 20)
    CopyrightLabel.Position = UDim2.new(0, 10, 1, -25)
    CopyrightLabel.BackgroundTransparency = 1
    CopyrightLabel.Text = chosenLanguage.copyright
    CopyrightLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    CopyrightLabel.Font = Enum.Font.SourceSans
    CopyrightLabel.TextSize = 10
    CopyrightLabel.TextXAlignment = Enum.TextXAlignment.Left
    CopyrightLabel.Parent = TogglesContainer

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = chosenLanguage.close
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 14
    CloseButton.Parent = MainFrame
    ToggleCorner:Clone().Parent = CloseButton

    -- Open/Close Button (MOVABLE)
    OpenCloseButton = Instance.new("TextButton")
    OpenCloseButton.Size = UDim2.new(0, 50, 0, 50)
    OpenCloseButton.Position = UDim2.new(0, 20, 0, 20)
    OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    OpenCloseButton.BorderSizePixel = 0
    OpenCloseButton.Text = chosenLanguage.open
    OpenCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenCloseButton.Font = Enum.Font.SourceSansBold
    OpenCloseButton.TextSize = 20
    OpenCloseButton.Visible = true
    OpenCloseButton.Parent = ControlGui

    local OpenCloseCorner = Instance.new("UICorner")
    OpenCloseCorner.CornerRadius = UDim.new(1, 0)
    OpenCloseCorner.Parent = OpenCloseButton

    -- =============================================
    -- BUTTON FUNCTIONS
    -- =============================================
    AimbotToggle.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        local status = AimbotEnabled and "ON" or "OFF"
        if chosenLanguage == Languages.English then
            AimbotToggle.Text = "Aimbot: " .. status
        else
            AimbotToggle.Text = "الإصابة التلقائية: " .. (status == "ON" and "تشغيل" or "إيقاف")
        end
        AimbotToggle.TextColor3 = AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end)

    ESPToggle.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        local status = ESPEnabled and "ON" or "OFF"
        if chosenLanguage == Languages.English then
            ESPToggle.Text = "ESP: " .. status
        else
            ESPToggle.Text = "الرؤية عبر الجدران: " .. (status == "ON" and "تشغيل" or "إيقاف")
        end
        ESPToggle.TextColor3 = ESPEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end)

    FOVToggle.MouseButton1Click:Connect(function()
        FOVCircleVisible = not FOVCircleVisible
        local status = FOVCircleVisible and "ON" or "OFF"
        if chosenLanguage == Languages.English then
            FOVToggle.Text = "FOV Circle: " .. status
        else
            FOVToggle.Text = "دائرة الرؤية: " .. (status == "ON" and "تشغيل" or "إيقاف")
        end
        FOVToggle.TextColor3 = FOVCircleVisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end)

    -- Open/Close Button Function
    OpenCloseButton.MouseButton1Click:Connect(function()
        UIVisible = not UIVisible
        MainFrame.Visible = UIVisible
        
        if UIVisible then
            OpenCloseButton.Text = chosenLanguage.closeText
            OpenCloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        else
            OpenCloseButton.Text = chosenLanguage.open
            OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        UIVisible = false
        OpenCloseButton.Text = chosenLanguage.open
        OpenCloseButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    end)

    -- Make Open/Close Button Draggable
    local dragging = false
    local dragStart, startPos

    OpenCloseButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = OpenCloseButton.Position
        end
    end)

    OpenCloseButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            OpenCloseButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Make Main Frame Draggable
    local frameDragging = false
    local frameDragStart, frameStartPos

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            frameDragging = true
            frameDragStart = input.Position
            frameStartPos = MainFrame.Position
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if frameDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - frameDragStart
            MainFrame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            frameDragging = false
        end
    end)

    -- =============================================
    -- MAIN LOOP - INSTANT AIMBOT
    -- =============================================
    RunService.RenderStepped:Connect(function()
        -- UPDATE FOV CIRCLE
        updateFOVCircle()
        
        -- INSTANT AIMBOT SYSTEM
        if AimbotEnabled then
            local newTarget = findBestTarget()
            
            if newTarget then
                if not currentTarget or currentTarget ~= newTarget then
                    -- NEW TARGET - INSTANT SNAP
                    instantHeadLock(newTarget)
                    currentTarget = newTarget
                    targetLock = true
                else
                    -- SAME TARGET - PERFECT FOLLOW
                    maintainHeadLock(currentTarget)
                end
            else
                currentTarget = nil
                targetLock = false
            end
        end
        
        -- ESP SYSTEM
        UpdateESP()
    end)

    -- =============================================
    -- ALWAYS WORK (EVEN WHEN DEAD)
    -- =============================================
    player.CharacterAdded:Connect(function(character)
        print(chosenLanguage.respawned)
    end)

    player.CharacterRemoving:Connect(function(character)
        print(chosenLanguage.died)
    end)

    -- Cleanup
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == player then
            if ScreenGui then ScreenGui:Destroy() end
            if ControlGui then ControlGui:Destroy() end
        end
    end)

    print("🎯 " .. chosenLanguage.loaded)
    print("⚡ INSTANT HEAD TRACKING - ULTRA FAST!")
    print("✅ " .. chosenLanguage.redCircle)
    print("✅ " .. chosenLanguage.working)
    print("✅ " .. chosenLanguage.active)
    print("📱 " .. chosenLanguage.copyright)
end

-- =============================================
-- START SCRIPT
-- =============================================
print("Copyright ©️ 'MZ server' made by 'unknown boi'")
print("Please select your language...")
createLanguageSelection()
