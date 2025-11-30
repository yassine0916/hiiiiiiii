-- MZ Hub - مركز التحكم المتكامل
-- حقوق النشر ©️ "MZ Hub" صنع بواسطة "Unknow Boi"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- إعدادات الرؤية عبر الجدران
local Config = {
    BoxESP = true,
    NameESP = true,
    DistanceESP = true,
    TeamCheck = true,
    MaxDistance = 1000 -- إعادة المسافة القصوى للأداء الأقوى
}

-- متغيرات محلية
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- مفاتيح التحكم
local ESPEnabled = true
local HitboxEnabled = false
local UIVisible = false
local HitboxSizeMultiplier = 1.8

-- ألوان
local ESPColor = Color3.fromRGB(0, 255, 255)
local HitboxColor = Color3.fromRGB(255, 50, 50)

-- كائنات الرؤية والهيت بوكس
local ESPObjects = {}
local HitboxConnections = {}

-- قائمة الألوان
local ColorOptions = {
    {Name = "أزرق ساطع", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "أحمر نيون", Color = Color3.fromRGB(255, 50, 50)},
    {Name = "أخضر نيون", Color = Color3.fromRGB(50, 255, 50)},
    {Name = "أرجواني", Color = Color3.fromRGB(180, 0, 180)},
    {Name = "ذهبي", Color = Color3.fromRGB(255, 215, 0)},
    {Name = "وردي", Color = Color3.fromRGB(255, 105, 180)},
    {Name = "برتقالي", Color = Color3.fromRGB(255, 165, 0)}
}

-- =============================================
-- وظيفة الإشعار الترحيبي الجميل
-- =============================================
local function ShowWelcomeNotification()
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "WelcomeNotification"
    NotificationGui.Parent = CoreGui
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -200, 0.3, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = NotificationGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = MainFrame

    -- تأثير التدرج
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
    })
    gradient.Parent = MainFrame

    -- تأثير الظل
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 150, 255)
    shadow.Thickness = 3
    shadow.Transparency = 0.3
    shadow.Parent = MainFrame

    -- صورة المستخدم
    local UserImage = Instance.new("ImageLabel")
    UserImage.Size = UDim2.new(0, 80, 0, 80)
    UserImage.Position = UDim2.new(0.5, -40, 0, 20)
    UserImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UserImage.BorderSizePixel = 0
    UserImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    UserImage.Parent = MainFrame

    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(1, 0)
    imageCorner.Parent = UserImage

    local imageStroke = Instance.new("UIStroke")
    imageStroke.Color = Color3.fromRGB(0, 200, 255)
    imageStroke.Thickness = 3
    imageStroke.Parent = UserImage

    -- اسم المستخدم
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(0.8, 0, 0, 30)
    UsernameLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = player.Name
    UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextSize = 18
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Center
    UsernameLabel.Parent = MainFrame

    -- النص الترحيبي
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Size = UDim2.new(0.8, 0, 0, 60)
    WelcomeLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Text = "🎉 مرحبًا بعودتك أيها المستخدم!\nاستمتع بسكربت MZ Hub 🚀"
    WelcomeLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.TextSize = 16
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Center
    WelcomeLabel.TextYAlignment = Enum.TextYAlignment.Top
    WelcomeLabel.Parent = MainFrame

    -- حقوق النشر
    local CopyrightLabel = Instance.new("TextLabel")
    CopyrightLabel.Size = UDim2.new(0.8, 0, 0, 20)
    CopyrightLabel.Position = UDim2.new(0.1, 0, 0.9, 0)
    CopyrightLabel.BackgroundTransparency = 1
    CopyrightLabel.Text = "MZ Hub ©️ | By Unknow Boi"
    CopyrightLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    CopyrightLabel.Font = Enum.Font.Gotham
    CopyrightLabel.TextSize = 12
    CopyrightLabel.TextXAlignment = Enum.TextXAlignment.Center
    CopyrightLabel.Parent = MainFrame

    -- تأثيرات الظهور
    MainFrame.Position = UDim2.new(0.5, -200, 0.2, -100)
    MainFrame.BackgroundTransparency = 1
    UserImage.ImageTransparency = 1
    UsernameLabel.TextTransparency = 1
    WelcomeLabel.TextTransparency = 1
    CopyrightLabel.TextTransparency = 1

    -- تأثير الظهور
    local appearTween = TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -200, 0.3, -100),
        BackgroundTransparency = 0.1
    })
    
    local textTween = TweenService:Create(WelcomeLabel, TweenInfo.new(1, Enum.EasingStyle.Quint), {
        TextTransparency = 0
    })
    
    local imageTween = TweenService:Create(UserImage, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        ImageTransparency = 0
    })
    
    local nameTween = TweenService:Create(UsernameLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        TextTransparency = 0
    })
    
    local copyrightTween = TweenService:Create(CopyrightLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        TextTransparency = 0
    })

    -- تشغيل تأثيرات الظهور
    appearTween:Play()
    wait(0.3)
    imageTween:Play()
    wait(0.2)
    nameTween:Play()
    wait(0.2)
    textTween:Play()
    copyrightTween:Play()

    -- إزالة الإشعار بعد 5 ثواني
    wait(5)
    
    local disappearTween = TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -200, 0.2, -100),
        BackgroundTransparency = 1
    })
    
    local textDisappear = TweenService:Create(WelcomeLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        TextTransparency = 1
    })
    
    local imageDisappear = TweenService:Create(UserImage, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        ImageTransparency = 1
    })
    
    local nameDisappear = TweenService:Create(UsernameLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        TextTransparency = 1
    })
    
    local copyrightDisappear = TweenService:Create(CopyrightLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        TextTransparency = 1
    })

    textDisappear:Play()
    imageDisappear:Play()
    nameDisappear:Play()
    copyrightDisappear:Play()
    disappearTween:Play()

    wait(1)
    NotificationGui:Destroy()
end

-- =============================================
-- وظائف توسيع الهيت بوكس (النظام الجديد)
-- =============================================
getgenv().HBE = false -- HBE Variable, use this to control whether the hitboxes are active or not.

local function GetCharParent()
    local charParent
    repeat wait() until player.Character
    for _, char in pairs(workspace:GetDescendants()) do
        if string.find(char.Name, player.Name) and char:FindFirstChild("Humanoid") then
            charParent = char.Parent
            break
        end
    end
    return charParent
end

-- pcall to avoid the script breaking on low level executors
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = function(Self, Key)
        if tostring(Self) == "HumanoidRootPart" and tostring(Key) == "Size" then
            return Vector3.new(2,2,1)
        end
        return old(Self, Key)
    end
    setreadonly(mt, true)
end)

local CHAR_PARENT = GetCharParent()
local HITBOX_BASE_SIZE = 15 -- الحجم الأساسي
local HITBOX_SIZE = Vector3.new(HITBOX_BASE_SIZE, HITBOX_BASE_SIZE, HITBOX_BASE_SIZE)

local function UpdateHitboxSize()
    local sizeValue = HITBOX_BASE_SIZE * HitboxSizeMultiplier
    HITBOX_SIZE = Vector3.new(sizeValue, sizeValue, sizeValue)
end

local function AssignHitboxes(targetPlayer)
    if targetPlayer == player then return end

    local hitbox_connection
    hitbox_connection = RunService.RenderStepped:Connect(function()
        local char = CHAR_PARENT:FindFirstChild(targetPlayer.Name)
        if getgenv().HBE then
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- تحديث الحجم بناءً على المضاعف
                UpdateHitboxSize()
                
                if char.HumanoidRootPart.Size ~= HITBOX_SIZE or char.HumanoidRootPart.Color ~= HitboxColor then
                    char.HumanoidRootPart.Size = HITBOX_SIZE
                    char.HumanoidRootPart.Color = HitboxColor
                    char.HumanoidRootPart.CanCollide = false
                    char.HumanoidRootPart.Transparency = 0.5
                    char.HumanoidRootPart.Material = Enum.Material.Neon
                end
            end
        else
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Size = Vector3.new(2,2,1)
                char.HumanoidRootPart.Transparency = 1
            end
        end
    end)
    
    HitboxConnections[targetPlayer] = hitbox_connection
end

local function InitializeHitboxes()
    getgenv().HBE = HitboxEnabled
    
    -- تنظيف الاتصالات القديمة
    for _, connection in pairs(HitboxConnections) do
        connection:Disconnect()
    end
    HitboxConnections = {}
    
    if HitboxEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                AssignHitboxes(otherPlayer)
            end
        end
    else
        -- إعادة تعيين الهيت بوكس لجميع اللاعبين
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                otherPlayer.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
                otherPlayer.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end

-- =============================================
-- وظائف الرؤية عبر الجدران القوية
-- =============================================
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function CreateESP(player)
    local esp = {
        Box = CreateDrawing("Square", {
            Thickness = 2,
            Filled = false,
            Color = ESPColor,
            Visible = false
        }),
        Name = CreateDrawing("Text", {
            Text = player.Name,
            Size = 16,
            Center = true,
            Outline = true,
            Color = ESPColor,
            Visible = false
        }),
        Distance = CreateDrawing("Text", {
            Size = 14,
            Center = true,
            Outline = true,
            Color = ESPColor,
            Visible = false
        }),
        HealthBar = CreateDrawing("Line", {
            Thickness = 3,
            Color = Color3.fromRGB(0, 255, 0),
            Visible = false
        }),
        HealthBarBackground = CreateDrawing("Line", {
            Thickness = 3,
            Color = Color3.fromRGB(255, 0, 0),
            Visible = false
        })
    }
    
    ESPObjects[player] = esp
    return esp
end

local function GetTeamColor(targetPlayer)
    if Config.TeamCheck and targetPlayer.Team and player.Team then
        return targetPlayer.Team == player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
    return ESPColor
end

local function CalculateBox(playerCharacter)
    if not playerCharacter then return nil, nil, false end
    
    local humanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
    local head = playerCharacter:FindFirstChild("Head")
    
    if not humanoidRootPart or not head then return nil, nil, false end
    
    local rootPos, rootVisible = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not rootVisible then return nil, nil, false end
    
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
    local feetPos = Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    
    if not headPos or not feetPos then return nil, nil, false end
    
    local boxHeight = math.abs(headPos.Y - feetPos.Y)
    local boxWidth = boxHeight * 0.6
    
    local boxPosition = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
    local boxSize = Vector2.new(boxWidth, boxHeight)
    
    return boxPosition, boxSize, true
end

local function GetDistance(playerCharacter)
    if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then return 0 end
    return math.floor((playerCharacter.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude)
end

local function UpdateESP()
    if not ESPEnabled then
        for _, esp in pairs(ESPObjects) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
        end
        return
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local esp = ESPObjects[targetPlayer] or CreateESP(targetPlayer)
            local character = targetPlayer.Character
            
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                local humanoid = character.Humanoid
                
                if humanoid.Health > 0 then
                    local distance = GetDistance(character)
                    
                    if distance <= Config.MaxDistance then
                        local boxPosition, boxSize, valid = CalculateBox(character)
                        
                        if valid then
                            local teamColor = GetTeamColor(targetPlayer)
                            
                            -- Box ESP
                            if Config.BoxESP then
                                esp.Box.Position = boxPosition
                                esp.Box.Size = boxSize
                                esp.Box.Color = teamColor
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
                            end
                            
                            -- Name ESP
                            if Config.NameESP then
                                esp.Name.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y - 20)
                                esp.Name.Text = targetPlayer.Name
                                esp.Name.Color = teamColor
                                esp.Name.Visible = true
                            else
                                esp.Name.Visible = false
                            end
                            
                            -- Distance ESP
                            if Config.DistanceESP then
                                esp.Distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                                esp.Distance.Text = tostring(distance) .. "m"
                                esp.Distance.Color = teamColor
                                esp.Distance.Visible = true
                            else
                                esp.Distance.Visible = false
                            end
                            
                            -- Health Bar
                            local healthPercentage = humanoid.Health / humanoid.MaxHealth
                            local healthBarLength = boxSize.X * healthPercentage
                            
                            esp.HealthBarBackground.From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y + 10)
                            esp.HealthBarBackground.To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y + 10)
                            esp.HealthBarBackground.Visible = true
                            
                            esp.HealthBar.From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y + 10)
                            esp.HealthBar.To = Vector2.new(boxPosition.X + healthBarLength, boxPosition.Y + boxSize.Y + 10)
                            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercentage), 255 * healthPercentage, 0)
                            esp.HealthBar.Visible = true
                        else
                            esp.Box.Visible = false
                            esp.Name.Visible = false
                            esp.Distance.Visible = false
                            esp.HealthBar.Visible = false
                            esp.HealthBarBackground.Visible = false
                        end
                    else
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.Distance.Visible = false
                        esp.HealthBar.Visible = false
                        esp.HealthBarBackground.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.HealthBar.Visible = false
                    esp.HealthBarBackground.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthBarBackground.Visible = false
            end
        end
    end
end

-- =============================================
-- وظائف تغيير الألوان
-- =============================================
local function ChangeESPColor()
    local currentIndex = 1
    for i, colorInfo in ipairs(ColorOptions) do
        if colorInfo.Color == ESPColor then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #ColorOptions) + 1
    ESPColor = ColorOptions[nextIndex].Color
    
    -- تحديث الـ ESP باللون الجديد
    UpdateESP()
    
    return ColorOptions[nextIndex].Name
end

local function ChangeHitboxColor()
    local currentIndex = 1
    for i, colorInfo in ipairs(ColorOptions) do
        if colorInfo.Color == HitboxColor then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #ColorOptions) + 1
    HitboxColor = ColorOptions[nextIndex].Color
    
    -- تحديث الهيت بوكس باللون الجديد
    if HitboxEnabled then
        InitializeHitboxes()
    end
    
    return ColorOptions[nextIndex].Name
end

-- =============================================
-- تهيئة النظام الرئيسي مع واجهة محسنة
-- =============================================
local ControlGui, MainFrame, OpenCloseButton

local function createModernUI()
    -- إنشاء واجهة التحكم الرئيسية
    ControlGui = Instance.new("ScreenGui")
    ControlGui.Name = "MZHub_Premium"
    ControlGui.Parent = CoreGui
    ControlGui.ResetOnSpawn = false
    ControlGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- زر الفتح/الإغلاق الرئيسي (دائري حديث)
    OpenCloseButton = Instance.new("ImageButton")
    OpenCloseButton.Name = "MainToggle"
    OpenCloseButton.Size = UDim2.new(0, 70, 0, 70)
    OpenCloseButton.Position = UDim2.new(0, 25, 0.5, -35)
    OpenCloseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    OpenCloseButton.Image = "http://www.roblox.com/asset/?id=118614421027521" -- الصورة المخصصة
    OpenCloseButton.ScaleType = Enum.ScaleType.Fit
    OpenCloseButton.Parent = ControlGui

    -- جعل الزر دائري
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = OpenCloseButton

    -- تأثير ظل متقدم
    local buttonShadow = Instance.new("UIStroke")
    buttonShadow.Color = Color3.fromRGB(0, 0, 0)
    buttonShadow.Thickness = 3
    buttonShadow.Transparency = 0.3
    buttonShadow.Parent = OpenCloseButton

    -- تأثير توهج
    local buttonGlow = Instance.new("UIGradient")
    buttonGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
    })
    buttonGlow.Rotation = 45
    buttonGlow.Parent = OpenCloseButton

    -- النافذة الرئيسية (تصميم حديث)
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainPanel"
    MainFrame.Size = UDim2.new(0, 350, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ControlGui

    -- زوايا دائرية للنافذة
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = MainFrame

    -- تأثير ظل للنافذة
    local mainShadow = Instance.new("UIStroke")
    mainShadow.Color = Color3.fromRGB(0, 100, 255)
    mainShadow.Thickness = 2
    mainShadow.Transparency = 0.8
    mainShadow.Parent = MainFrame

    -- خلفية متدرجة للنافذة
    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
    })
    backgroundGradient.Parent = MainFrame

    -- رأس النافذة
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    Header.BackgroundTransparency = 0.1
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = Header

    -- تأثير التدرج للرأس
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    })
    headerGradient.Parent = Header

    -- العنوان الرئيسي
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MZ HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- العنوان الفرعي
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0.7, 0, 0, 15)
    Subtitle.Position = UDim2.new(0.05, 0, 0.6, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "مركز التحكم المتكامل"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header

    -- زر الإغلاق
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(0.9, 0, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Image = "http://www.roblox.com/asset/?id=118614421027521"
    CloseButton.Parent = Header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = CloseButton

    -- حاوية المحتوى
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -70)
    ContentContainer.Position = UDim2.new(0, 10, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- بطاقة الرؤية عبر الجدران
    local ESPCard = Instance.new("Frame")
    ESPCard.Size = UDim2.new(1, 0, 0, 100)
    ESPCard.Position = UDim2.new(0, 0, 0, 0)
    ESPCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ESPCard.BackgroundTransparency = 0.1
    ESPCard.BorderSizePixel = 0
    ESPCard.Parent = ContentContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = ESPCard

    local cardShadow = Instance.new("UIStroke")
    cardShadow.Color = Color3.fromRGB(50, 50, 70)
    cardShadow.Thickness = 1
    cardShadow.Parent = ESPCard

    -- عنوان البطاقة
    local ESPTitle = Instance.new("TextLabel")
    ESPTitle.Size = UDim2.new(1, -20, 0, 25)
    ESPTitle.Position = UDim2.new(0, 10, 0, 5)
    ESPTitle.BackgroundTransparency = 1
    ESPTitle.Text = "👁️ الرؤية عبر الجدران"
    ESPTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPTitle.Font = Enum.Font.GothamBold
    ESPTitle.TextSize = 16
    ESPTitle.TextXAlignment = Enum.TextXAlignment.Left
    ESPTitle.Parent = ESPCard

    -- زر تبديل الرؤية
    local ESPToggle = Instance.new("TextButton")
    ESPToggle.Size = UDim2.new(0, 120, 0, 35)
    ESPToggle.Position = UDim2.new(0, 10, 0, 35)
    ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    ESPToggle.Text = "مفعل"
    ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggle.Font = Enum.Font.GothamBold
    ESPToggle.TextSize = 14
    ESPToggle.Parent = ESPCard

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = ESPToggle

    -- زر تغيير لون الرؤية
    local ESPColorButton = Instance.new("TextButton")
    ESPColorButton.Size = UDim2.new(0, 120, 0, 35)
    ESPColorButton.Position = UDim2.new(0, 140, 0, 35)
    ESPColorButton.BackgroundColor3 = ESPColor
    ESPColorButton.Text = "🎨 تغيير اللون"
    ESPColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPColorButton.Font = Enum.Font.GothamBold
    ESPColorButton.TextSize = 14
    ESPColorButton.Parent = ESPCard
    toggleCorner:Clone().Parent = ESPColorButton

    -- بطاقة توسيع الهيت بوكس
    local HitboxCard = Instance.new("Frame")
    HitboxCard.Size = UDim2.new(1, 0, 0, 150)
    HitboxCard.Position = UDim2.new(0, 0, 0, 110)
    HitboxCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    HitboxCard.BackgroundTransparency = 0.1
    HitboxCard.BorderSizePixel = 0
    HitboxCard.Parent = ContentContainer
    cardCorner:Clone().Parent = HitboxCard
    cardShadow:Clone().Parent = HitboxCard

    -- عنوان البطاقة
    local HitboxTitle = Instance.new("TextLabel")
    HitboxTitle.Size = UDim2.new(1, -20, 0, 25)
    HitboxTitle.Position = UDim2.new(0, 10, 0, 5)
    HitboxTitle.BackgroundTransparency = 1
    HitboxTitle.Text = "🎯 توسيع الهيت بوكس"
    HitboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxTitle.Font = Enum.Font.GothamBold
    HitboxTitle.TextSize = 16
    HitboxTitle.TextXAlignment = Enum.TextXAlignment.Left
    HitboxTitle.Parent = HitboxCard

    -- زر تبديل الهيت بوكس
    local HitboxToggle = Instance.new("TextButton")
    HitboxToggle.Size = UDim2.new(0, 120, 0, 35)
    HitboxToggle.Position = UDim2.new(0, 10, 0, 35)
    HitboxToggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    HitboxToggle.Text = "معطل"
    HitboxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxToggle.Font = Enum.Font.GothamBold
    HitboxToggle.TextSize = 14
    HitboxToggle.Parent = HitboxCard
    toggleCorner:Clone().Parent = HitboxToggle

    -- زر تغيير لون الهيت بوكس
    local HitboxColorButton = Instance.new("TextButton")
    HitboxColorButton.Size = UDim2.new(0, 120, 0, 35)
    HitboxColorButton.Position = UDim2.new(0, 140, 0, 35)
    HitboxColorButton.BackgroundColor3 = HitboxColor
    HitboxColorButton.Text = "🎨 تغيير اللون"
    HitboxColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxColorButton.Font = Enum.Font.GothamBold
    HitboxColorButton.TextSize = 14
    HitboxColorButton.Parent = HitboxCard
    toggleCorner:Clone().Parent = HitboxColorButton

    -- شريط تحكم حجم الهيت بوكس
    local SizeSliderContainer = Instance.new("Frame")
    SizeSliderContainer.Size = UDim2.new(1, -20, 0, 50)
    SizeSliderContainer.Position = UDim2.new(0, 10, 0, 80)
    SizeSliderContainer.BackgroundTransparency = 1
    SizeSliderContainer.Parent = HitboxCard

    -- عنوان الشريط
    local SizeLabel = Instance.new("TextLabel")
    SizeLabel.Size = UDim2.new(1, 0, 0, 20)
    SizeLabel.Position = UDim2.new(0, 0, 0, 0)
    SizeLabel.BackgroundTransparency = 1
    SizeLabel.Text = "حجم الهيت بوكس: 1.8x"
    SizeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    SizeLabel.Font = Enum.Font.Gotham
    SizeLabel.TextSize = 12
    SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    SizeLabel.Parent = SizeSliderContainer

    -- خلفية الشريط
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Size = UDim2.new(1, 0, 0, 6)
    SliderBackground.Position = UDim2.new(0, 0, 0, 25)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SizeSliderContainer

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = SliderBackground

    -- الشريط الأمامي
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((HitboxSizeMultiplier - 1) / 2, 0, 1, 0)  -- من 1x إلى 3x
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBackground

    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = SliderFill

    -- نقطة التحكم
    local SliderThumb = Instance.new("TextButton")
    SliderThumb.Size = UDim2.new(0, 20, 0, 20)
    SliderThumb.Position = UDim2.new((HitboxSizeMultiplier - 1) / 2, -10, 0, -7)
    SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderThumb.Text = ""
    SliderThumb.Parent = SliderBackground

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = SliderThumb

    local thumbShadow = Instance.new("UIStroke")
    thumbShadow.Color = Color3.fromRGB(0, 0, 0)
    thumbShadow.Thickness = 2
    thumbShadow.Transparency = 0.5
    thumbShadow.Parent = SliderThumb

    -- بطاقة المعلومات
    local InfoCard = Instance.new("Frame")
    InfoCard.Size = UDim2.new(1, 0, 0, 80)
    InfoCard.Position = UDim2.new(0, 0, 0, 270)
    InfoCard.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    InfoCard.BackgroundTransparency = 0.1
    InfoCard.BorderSizePixel = 0
    InfoCard.Parent = ContentContainer
    cardCorner:Clone().Parent = InfoCard
    cardShadow:Clone().Parent = InfoCard

    -- معلومات الألوان
    local ColorInfo = Instance.new("TextLabel")
    ColorInfo.Size = UDim2.new(1, -20, 1, -10)
    ColorInfo.Position = UDim2.new(0, 10, 0, 5)
    ColorInfo.BackgroundTransparency = 1
    ColorInfo.Text = "🎨 الألوان الحالية:\nالرؤية: أزرق ساطع\nالهيت بوكس: أحمر نيون"
    ColorInfo.TextColor3 = Color3.fromRGB(200, 200, 255)
    ColorInfo.Font = Enum.Font.Gotham
    ColorInfo.TextSize = 12
    ColorInfo.TextXAlignment = Enum.TextXAlignment.Left
    ColorInfo.TextYAlignment = Enum.TextYAlignment.Top
    ColorInfo.Parent = InfoCard

    -- حقوق النشر
    local CopyrightLabel = Instance.new("TextLabel")
    CopyrightLabel.Size = UDim2.new(1, -20, 0, 20)
    CopyrightLabel.Position = UDim2.new(0, 10, 1, -25)
    CopyrightLabel.BackgroundTransparency = 1
    CopyrightLabel.Text = "MZ Hub ©️ | By Unknow Boi"
    CopyrightLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    CopyrightLabel.Font = Enum.Font.Gotham
    CopyrightLabel.TextSize = 10
    CopyrightLabel.TextXAlignment = Enum.TextXAlignment.Center
    CopyrightLabel.Parent = ContentContainer

    -- =============================================
    -- وظائف التحكم
    -- =============================================
    local function createRippleEffect(button)
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.Parent = button
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local tween = TweenService:Create(ripple, TweenInfo.new(0.5), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            ripple:Destroy()
        end)
    end

    -- وظيفة تحديث الشريط
    local function updateSlider(value)
        -- تحديد القيمة بين 1 و 3
        HitboxSizeMultiplier = math.clamp(value, 1.0, 3.0)
        
        -- تحديث واجهة المستخدم
        SizeLabel.Text = string.format("حجم الهيت بوكس: %.1fx", HitboxSizeMultiplier)
        SliderFill.Size = UDim2.new((HitboxSizeMultiplier - 1) / 2, 0, 1, 0)
        SliderThumb.Position = UDim2.new((HitboxSizeMultiplier - 1) / 2, -10, 0, -7)
        
        -- تحديث الهيت بوكس إذا كان مفعلاً
        if HitboxEnabled then
            InitializeHitboxes()
        end
    end

    -- وظيفة السحب على الشريط
    local sliderDragging = false
    
    SliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = true
            createRippleEffect(SliderThumb)
        end
    end)
    
    SliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = input.Position.X
            local absolutePos = SliderBackground.AbsolutePosition.X
            local absoluteSize = SliderBackground.AbsoluteSize.X
            
            local relativePos = (mousePos - absolutePos) / absoluteSize
            local newValue = 1 + (relativePos * 2)  -- من 1 إلى 3
            
            updateSlider(newValue)
            createRippleEffect(SliderBackground)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local absolutePos = SliderBackground.AbsolutePosition.X
            local absoluteSize = SliderBackground.AbsoluteSize.X
            
            local relativePos = math.clamp((mousePos - absolutePos) / absoluteSize, 0, 1)
            local newValue = 1 + (relativePos * 2)  -- من 1 إلى 3
            
            updateSlider(newValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = false
        end
    end)

    -- وظيفة زر الفتح/الإغلاق
    OpenCloseButton.MouseButton1Click:Connect(function()
        UIVisible = not UIVisible
        MainFrame.Visible = UIVisible
        
        createRippleEffect(OpenCloseButton)
        
        if UIVisible then
            -- تأثير عند الفتح
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(255, 100, 100),
                Rotation = 180
            })
            tween:Play()
        else
            -- تأثير عند الإغلاق
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 255),
                Rotation = 0
            })
            tween:Play()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        UIVisible = false
        
        local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 150, 255),
            Rotation = 0
        })
        tween:Play()
    end)

    -- أحداث الأزرار
    ESPToggle.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        ESPToggle.Text = ESPEnabled and "مفعل" or "معطل"
        ESPToggle.BackgroundColor3 = ESPEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 60, 60)
        
        createRippleEffect(ESPToggle)
        UpdateESP()
    end)

    ESPColorButton.MouseButton1Click:Connect(function()
        local newColorName = ChangeESPColor()
        ESPColorButton.BackgroundColor3 = ESPColor
        ColorInfo.Text = "🎨 الألوان الحالية:\nالرؤية: " .. newColorName .. "\nالهيت بوكس: " .. ColorInfo.Text:match("الهيت بوكس: (%w+ %w+)")
        
        createRippleEffect(ESPColorButton)
    end)

    HitboxToggle.MouseButton1Click:Connect(function()
        HitboxEnabled = not HitboxEnabled
        HitboxToggle.Text = HitboxEnabled and "مفعل" or "معطل"
        HitboxToggle.BackgroundColor3 = HitboxEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 60, 60)
        
        createRippleEffect(HitboxToggle)
        InitializeHitboxes()
    end)

    HitboxColorButton.MouseButton1Click:Connect(function()
        local newColorName = ChangeHitboxColor()
        HitboxColorButton.BackgroundColor3 = HitboxColor
        ColorInfo.Text = "🎨 الألوان الحالية:\nالرؤية: " .. ColorInfo.Text:match("الرؤية: (%w+ %w+)") .. "\nالهيت بوكس: " .. newColorName
        
        createRippleEffect(HitboxColorButton)
    end)

    -- جعل النافذة قابلة للسحب
    local dragging = false
    local dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    Header.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- جعل الزر الرئيسي قابلاً للسحب
    local buttonDragging = false
    local buttonDragStart, buttonStartPos

    OpenCloseButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            buttonDragging = true
            buttonDragStart = input.Position
            buttonStartPos = OpenCloseButton.Position
        end
    end)

    OpenCloseButton.InputChanged:Connect(function(input)
        if buttonDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - buttonDragStart
            OpenCloseButton.Position = UDim2.new(buttonStartPos.X.Scale, buttonStartPos.X.Offset + delta.X, buttonStartPos.Y.Scale, buttonStartPos.Y.Offset + delta.Y)
        end
    end)

    OpenCloseButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            buttonDragging = false
        end
    end)

    return {
        MainFrame = MainFrame,
        OpenCloseButton = OpenCloseButton,
        ESPToggle = ESPToggle,
        HitboxToggle = HitboxToggle,
        ESPColorButton = ESPColorButton,
        HitboxColorButton = HitboxColorButton,
        ColorInfo = ColorInfo,
        SizeLabel = SizeLabel
    }
end

-- =============================================
-- تهيئة النظام الرئيسي
-- =============================================
local function initializeSystem()
    print("🎮 جاري تحميل MZ Hub v2.0...")
    
    -- عرض الإشعار الترحيبي
    ShowWelcomeNotification()
    
    -- إنشاء الواجهة
    local UI = createModernUI()
    
    -- الحلقة الرئيسية للتحديث
    RunService.RenderStepped:Connect(function()
        UpdateESP()
    end)

    -- إضافة لاعبين جدد
    Players.PlayerAdded:Connect(function(newPlayer)
        if getgenv().HBE then
            AssignHitboxes(newPlayer)
        end
    end)

    -- التأكد من استمرار العمل بعد الموت
    player.CharacterAdded:Connect(function(character)
        print("🔄 MZ Hub: إعادة ولادة - النظام يعمل!")
        -- تحديث CHAR_PARENT عند إعادة الولادة
        CHAR_PARENT = GetCharParent()
    end)

    -- التنظيف عند المغادرة
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == player then
            if ControlGui then ControlGui:Destroy() end
            -- تنظيف الـ ESP
            for _, esp in pairs(ESPObjects) do
                if esp then
                    for _, drawing in pairs(esp) do
                        drawing:Remove()
                    end
                end
            end
            -- تنظيف اتصالات الهيت بوكس
            for _, connection in pairs(HitboxConnections) do
                connection:Disconnect()
            end
        end
    end)

    print("🎉 MZ Hub v2.0 - تم التحميل بنجاح!")
    print("✨ واجهة حديثة - تصميم احترافي")
    print("👁️ نظام ESP قوي - Boxes, Names, Distance, Health")
    print("🎯 نظام الهيت بوكس المتقدم - مع شريط تحكم الحجم")
    print("🖼️ إشعار ترحيبي جميل - بصورة المستخدم")
    print("🎨 ألوان متعددة - تخصيص كامل")
    print("💎 MZ Hub ©️ | By Unknow Boi")
end

-- بدء التشغيل
initializeSystem()