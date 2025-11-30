-- MZ Hub - مركز التحكم
-- حقوق النشر ©️ "MZ server" صنع بواسطة "unknown boi"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- إعدادات الإصابة التلقائية
local FOV_RADIUS = 100
local AUTO_AIM_ENABLED = true
local AIM_STRENGTH = 1.0  -- تتبع فوري

-- إعدادات الرؤية عبر الجدران
local Config = {
    BoxESP = true,
    NameESP = true,
    DistanceESP = true,
    TeamCheck = true,
    MaxDistance = 1000
}

-- متغيرات محلية
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local currentTarget = nil
local targetLock = false

-- مفاتيح التحكم
local AimbotEnabled = true
local ESPEnabled = true
local FOVCircleVisible = true
local UIVisible = false

-- كائنات الرؤية
local ESPObjects = {}

-- =============================================
-- دائرة مجال الرؤية
-- =============================================
local ScreenGui, Frame

local function createFOVCircle()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MZHub_FOVCircle"
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

-- تحديث دائرة الرؤية
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
-- وظائف الإصابة التلقائية الفورية
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

-- تتبع فوري للرأس
local function instantHeadLock(targetHead)
    if not targetHead or not Camera then return end
    local headPosition = targetHead.Position
    -- تتبع فوري - بدون تبطئة
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPosition)
end

-- تتبع مثالي للرأس
local function maintainHeadLock(targetHead)
    if not targetHead or not Camera then return end
    local headPosition = targetHead.Position
    -- تتبع فوري - البقاء على الرأس
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPosition)
end

-- =============================================
-- وظائف الرؤية عبر الجدران
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
-- تهيئة النظام الرئيسي
-- =============================================
local ControlGui, MainFrame, OpenCloseButton

local function initializeSystem()
    print("🔄 جاري تهيئة MZ Hub...")
    
    -- إنشاء دائرة الرؤية
    createFOVCircle()
    
    -- إنشاء واجهة التحكم
    ControlGui = Instance.new("ScreenGui")
    ControlGui.Name = "MZHub_Controls"
    ControlGui.Parent = CoreGui
    ControlGui.ResetOnSpawn = false

    -- الحاوية الرئيسية
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 220, 0, 200)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ControlGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- تأثير ظل
    local Shadow = Instance.new("UIStroke")
    Shadow.Color = Color3.fromRGB(0, 0, 0)
    Shadow.Thickness = 2
    Shadow.Transparency = 0.7
    Shadow.Parent = MainFrame

    -- العنوان
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Title.BackgroundTransparency = 0.1
    Title.Text = "MZ Hub "
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title

    -- حاوية مفاتيح التحكم
    local TogglesContainer = Instance.new("Frame")
    TogglesContainer.Size = UDim2.new(1, -20, 1, -70)
    TogglesContainer.Position = UDim2.new(0, 10, 0, 45)
    TogglesContainer.BackgroundTransparency = 1
    TogglesContainer.Parent = MainFrame

    -- مفتاح الإصابة التلقائية
    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Size = UDim2.new(1, 0, 0, 32)
    AimbotToggle.Position = UDim2.new(0, 0, 0, 0)
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    AimbotToggle.BorderSizePixel = 0
    AimbotToggle.Text = "🎯 الإصابة التلقائية: تشغيل"
    AimbotToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    AimbotToggle.Font = Enum.Font.SourceSansSemibold
    AimbotToggle.TextSize = 14
    AimbotToggle.Parent = TogglesContainer

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = AimbotToggle

    -- مفتاح الرؤية عبر الجدران
    local ESPToggle = Instance.new("TextButton")
    ESPToggle.Size = UDim2.new(1, 0, 0, 32)
    ESPToggle.Position = UDim2.new(0, 0, 0, 38)
    ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ESPToggle.BorderSizePixel = 0
    ESPToggle.Text = "👁️ الرؤية عبر الجدران: تشغيل"
    ESPToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    ESPToggle.Font = Enum.Font.SourceSansSemibold
    ESPToggle.TextSize = 14
    ESPToggle.Parent = TogglesContainer
    ToggleCorner:Clone().Parent = ESPToggle

    -- مفتاح دائرة الرؤية
    local FOVToggle = Instance.new("TextButton")
    FOVToggle.Size = UDim2.new(1, 0, 0, 32)
    FOVToggle.Position = UDim2.new(0, 0, 0, 76)
    FOVToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    FOVToggle.BorderSizePixel = 0
    FOVToggle.Text = "🔴 دائرة الرؤية: تشغيل"
    FOVToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    FOVToggle.Font = Enum.Font.SourceSansSemibold
    FOVToggle.TextSize = 14
    FOVToggle.Parent = TogglesContainer
    ToggleCorner:Clone().Parent = FOVToggle

    -- حقوق النشر
    local CopyrightLabel = Instance.new("TextLabel")
    CopyrightLabel.Size = UDim2.new(1, -20, 0, 20)
    CopyrightLabel.Position = UDim2.new(0, 10, 1, -25)
    CopyrightLabel.BackgroundTransparency = 1
    CopyrightLabel.Text = "حقوق النشر ©️ 'MZ Hub' صنع بواسطة 'unknown boi'"
    CopyrightLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    CopyrightLabel.Font = Enum.Font.SourceSans
    CopyrightLabel.TextSize = 10
    CopyrightLabel.TextXAlignment = Enum.TextXAlignment.Left
    CopyrightLabel.Parent = TogglesContainer

    -- زر الإغلاق
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 14
    CloseButton.Parent = MainFrame
    ToggleCorner:Clone().Parent = CloseButton

    -- زر الفتح/الإغلاق الرئيسي مع صورة
    OpenCloseButton = Instance.new("TextButton")
    OpenCloseButton.Size = UDim2.new(0, 60, 0, 60)
    OpenCloseButton.Position = UDim2.new(0, 20, 0, 20)
    OpenCloseButton.BackgroundColor3 = Color3.fromRGB(45, 100, 180)
    OpenCloseButton.BorderSizePixel = 0
    OpenCloseButton.Text = ""
    OpenCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenCloseButton.Font = Enum.Font.SourceSansBold
    OpenCloseButton.TextSize = 20
    OpenCloseButton.Visible = true
    OpenCloseButton.Parent = ControlGui

    local OpenCloseCorner = Instance.new("UICorner")
    OpenCloseCorner.CornerRadius = UDim.new(0, 15)
    OpenCloseCorner.Parent = OpenCloseButton

    -- تأثير ظل للزر الرئيسي
    local ButtonShadow = Instance.new("UIStroke")
    ButtonShadow.Color = Color3.fromRGB(0, 0, 0)
    ButtonShadow.Thickness = 2
    ButtonShadow.Transparency = 0.5
    ButtonShadow.Parent = OpenCloseButton

    -- صورة الزر الرئيسي
    local ButtonImage = Instance.new("ImageLabel")
    ButtonImage.Size = UDim2.new(0.7, 0, 0.7, 0)
    ButtonImage.Position = UDim2.new(0.15, 0, 0.15, 0)
    ButtonImage.BackgroundTransparency = 1
    ButtonImage.Image = "rbxassetid://10734996320"  -- صورة تروس أو أي أيقونة مناسبة
    ButtonImage.Parent = OpenCloseButton

    -- نص الزر الرئيسي
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Size = UDim2.new(1, 0, 0, 15)
    ButtonText.Position = UDim2.new(0, 0, 0.85, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = "MZ Hub"
    ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonText.Font = Enum.Font.SourceSansBold
    ButtonText.TextSize = 12
    ButtonText.Parent = OpenCloseButton

    -- =============================================
    -- وظائف الأزرار
    -- =============================================
    AimbotToggle.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        local status = AimbotEnabled and "تشغيل" or "إيقاف"
        AimbotToggle.Text = "🎯 الإصابة التلقائية: " .. status
        AimbotToggle.TextColor3 = AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        -- تأثير عند النقر
        local tween = TweenService:Create(AimbotToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(AimbotToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
        tween:Play()
    end)

    ESPToggle.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        local status = ESPEnabled and "تشغيل" or "إيقاف"
        ESPToggle.Text = "👁️ الرؤية عبر الجدران: " .. status
        ESPToggle.TextColor3 = ESPEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        -- تأثير عند النقر
        local tween = TweenService:Create(ESPToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(ESPToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
        tween:Play()
    end)

    FOVToggle.MouseButton1Click:Connect(function()
        FOVCircleVisible = not FOVCircleVisible
        local status = FOVCircleVisible and "تشغيل" or "إيقاف"
        FOVToggle.Text = "🔴 دائرة الرؤية: " .. status
        FOVToggle.TextColor3 = FOVCircleVisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        -- تأثير عند النقر
        local tween = TweenService:Create(FOVToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(FOVToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
        tween:Play()
    end)

    -- وظيفة زر الفتح/الإغلاق
    OpenCloseButton.MouseButton1Click:Connect(function()
        UIVisible = not UIVisible
        MainFrame.Visible = UIVisible
        
        if UIVisible then
            -- تأثير عند الفتح
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(255, 60, 60),
                Rotation = 45
            })
            tween:Play()
            ButtonImage.Image = "rbxassetid://10734996320"  -- تغيير الصورة عند الفتح
        else
            -- تأثير عند الإغلاق
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 100, 180),
                Rotation = 0
            })
            tween:Play()
            ButtonImage.Image = "rbxassetid://118614421027521"  -- إعادة الصورة الأصلية
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        UIVisible = false
        
        -- تأثير عند الإغلاق
        local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 100, 180),
            Rotation = 0
        })
        tween:Play()
        ButtonImage.Image = "rbxassetid://118614421027521"
    end)

    -- جعل زر الفتح/الإغلاق قابلاً للسحب
    local dragging = false
    local dragStart, startPos

    OpenCloseButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = OpenCloseButton.Position
            
            -- تأثير عند السحب
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(65, 120, 200)
            })
            tween:Play()
        end
    end)

    OpenCloseButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            OpenCloseButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    OpenCloseButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            
            -- تأثير بعد السحب
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.1), {
                BackgroundColor3 = UIVisible and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 100, 180)
            })
            tween:Play()
        end
    end)

    -- جعل الإطار الرئيسي قابلاً للسحب
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

    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            frameDragging = false
        end
    end)

    -- =============================================
    -- الحلقة الرئيسية - الإصابة التلقائية الفورية
    -- =============================================
    RunService.RenderStepped:Connect(function()
        -- تحديث دائرة الرؤية
        updateFOVCircle()
        
        -- نظام الإصابة التلقائية الفورية
        if AimbotEnabled then
            local newTarget = findBestTarget()
            
            if newTarget then
                if not currentTarget or currentTarget ~= newTarget then
                    -- هدف جديد - تتبع فوري
                    instantHeadLock(newTarget)
                    currentTarget = newTarget
                    targetLock = true
                else
                    -- نفس الهدف - تتبع مثالي
                    maintainHeadLock(currentTarget)
                end
            else
                currentTarget = nil
                targetLock = false
            end
        end
        
        -- نظام الرؤية عبر الجدران
        UpdateESP()
    end)

    -- =============================================
    -- يعمل دائمًا (حتى عند الموت)
    -- =============================================
    player.CharacterAdded:Connect(function(character)
        print("🔄 إعادة ولادة الشخصية - MZ Hub يعمل!")
    end)

    player.CharacterRemoving:Connect(function(character)
        print("💀 وفاة الشخصية - MZ Hub لا يزال يعمل!")
    end)

    -- التنظيف
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == player then
            if ScreenGui then ScreenGui:Destroy() end
            if ControlGui then ControlGui:Destroy() end
        end
    end)

    print("🎉 تم تحميل MZ Hub بنجاح!")
    print("⚡ تتبع فوري للرأس - فائق السرعة!")
    print("✅ دائرة رؤية حمراء بحجم 100 - تعمل!")
    print("✅ النظام يعمل بكفاءة!")
    print("🚀 MZ Hub نشط وجاهز للاستخدام!")
    print("📱 حقوق النشر ©️ 'MZ Hub' صنع بواسطة 'unknown boi'")
end

-- =============================================
-- بدء تشغيل MZ Hub
-- =============================================
print("🎮 MZ Hub - مركز التحكم المتكامل")
print("⚡ جاري التهيئة...")
print("📝 حقوق النشر ©️ 'MZ Hub' صنع بواسطة 'unknown boi'")
initializeSystem()
