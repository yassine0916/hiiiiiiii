-- MZ Hub - مركز التحكم
-- حقوق النشر ©️ "MZ server" صنع بواسطة "unknown boi"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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

-- مفاتيح التحكم
local ESPEnabled = true
local HitboxEnabled = false
local UIVisible = false

-- ألوان
local ESPColor = Color3.fromRGB(255, 0, 0)
local HitboxColor = Color3.fromRGB(255, 0, 0)

-- كائنات الرؤية والهيت بوكس
local ESPObjects = {}
local HitboxObjects = {}

-- قائمة الألوان
local ColorOptions = {
    {Name = "أحمر", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "أخضر", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "أزرق", Color = Color3.fromRGB(0, 100, 255)},
    {Name = "أصفر", Color = Color3.fromRGB(255, 255, 0)},
    {Name = "بنفسجي", Color = Color3.fromRGB(180, 0, 180)},
    {Name = "أبيض", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "برتقالي", Color = Color3.fromRGB(255, 165, 0)}
}

-- =============================================
-- وظائف الرؤية عبر الجدران (Highlights)
-- =============================================
local function CreateHighlightESP(plr)
    local highlight = Instance.new("Highlight")
    highlight.Name = "MZESP_Highlight"
    highlight.FillColor = ESPColor
    highlight.OutlineColor = ESPColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    if plr.Character then
        highlight.Adornee = plr.Character
        highlight.Parent = plr.Character
    end
    
    ESPObjects[plr] = highlight
    return highlight
end

local function UpdateHighlightESP()
    -- تنظيف الـ ESP القديم
    for plr, highlight in pairs(ESPObjects) do
        if not plr or not plr.Parent or not ESPEnabled then
            if highlight then
                highlight:Destroy()
            end
            ESPObjects[plr] = nil
        end
    end
    
    if not ESPEnabled then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local humanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and humanoidRootPart then
                local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                
                if distance <= Config.MaxDistance then
                    local highlight = ESPObjects[otherPlayer] or CreateHighlightESP(otherPlayer)
                    
                    if highlight then
                        highlight.FillColor = ESPColor
                        highlight.OutlineColor = ESPColor
                        highlight.Enabled = true
                        
                        if otherPlayer.Character and highlight.Adornee ~= otherPlayer.Character then
                            highlight.Adornee = otherPlayer.Character
                        end
                        
                        if not highlight.Parent and otherPlayer.Character then
                            highlight.Parent = otherPlayer.Character
                        end
                    end
                else
                    if ESPObjects[otherPlayer] then
                        ESPObjects[otherPlayer].Enabled = false
                    end
                end
            else
                if ESPObjects[otherPlayer] then
                    ESPObjects[otherPlayer].Enabled = false
                end
            end
        end
    end
end

-- =============================================
-- وظائف توسيع الهيت بوكس
-- =============================================
local function ExpandHitbox(character)
    if not character then return end
    
    local hitboxData = {}
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- حفظ البيانات الأصلية
            local originalSize = part.Size
            local originalTransparency = part.Transparency
            local originalColor = part.BrickColor
            local originalMaterial = part.Material
            
            -- توسيع الهيت بوكس
            part.Size = part.Size * 1.8
            part.Transparency = 0.4
            part.BrickColor = BrickColor.new(HitboxColor)
            part.Material = Enum.Material.Neon
            
            hitboxData[part] = {
                OriginalSize = originalSize,
                OriginalTransparency = originalTransparency,
                OriginalColor = originalColor,
                OriginalMaterial = originalMaterial
            }
        end
    end
    
    HitboxObjects[character] = hitboxData
end

local function ResetHitbox(character)
    if not character then return end
    
    local hitboxData = HitboxObjects[character]
    if hitboxData then
        for part, originalData in pairs(hitboxData) do
            if part and part.Parent then
                part.Size = originalData.OriginalSize
                part.Transparency = originalData.OriginalTransparency
                part.BrickColor = originalData.OriginalColor
                part.Material = originalData.OriginalMaterial
            end
        end
        HitboxObjects[character] = nil
    end
end

local function UpdateHitboxes()
    -- إعادة تعيين الهيت بوكس إذا تم إيقاف التشغيل
    if not HitboxEnabled then
        for character, _ in pairs(HitboxObjects) do
            ResetHitbox(character)
        end
        return
    end
    
    -- تحديث الهيت بوكس
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local humanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and humanoidRootPart then
                local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                
                if distance <= Config.MaxDistance then
                    -- توسيع الهيت بوكس
                    if not HitboxObjects[otherPlayer.Character] then
                        ExpandHitbox(otherPlayer.Character)
                    else
                        -- تحديث اللون إذا تغير
                        for part, _ in pairs(HitboxObjects[otherPlayer.Character]) do
                            if part and part.Parent then
                                part.BrickColor = BrickColor.new(HitboxColor)
                            end
                        end
                    end
                else
                    ResetHitbox(otherPlayer.Character)
                end
            else
                ResetHitbox(otherPlayer.Character)
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
    UpdateHighlightESP()
    
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
    UpdateHitboxes()
    
    return ColorOptions[nextIndex].Name
end

-- =============================================
-- تهيئة النظام الرئيسي
-- =============================================
local ControlGui, MainFrame, OpenCloseButton

local function initializeSystem()
    print("🔄 جاري تهيئة MZ Hub...")
    
    -- إنشاء واجهة التحكم
    ControlGui = Instance.new("ScreenGui")
    ControlGui.Name = "MZHub_Controls"
    ControlGui.Parent = CoreGui
    ControlGui.ResetOnSpawn = false

    -- الحاوية الرئيسية
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 280, 0, 320)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -160)
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
    Title.Text = "MZ Hub - مركز التحكم"
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

    -- مفتاح الرؤية عبر الجدران
    local ESPToggle = Instance.new("TextButton")
    ESPToggle.Size = UDim2.new(1, 0, 0, 32)
    ESPToggle.Position = UDim2.new(0, 0, 0, 0)
    ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ESPToggle.BorderSizePixel = 0
    ESPToggle.Text = "👁️ الرؤية عبر الجدران: تشغيل"
    ESPToggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    ESPToggle.Font = Enum.Font.SourceSansSemibold
    ESPToggle.TextSize = 14
    ESPToggle.Parent = TogglesContainer

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ESPToggle

    -- زر تغيير لون الرؤية
    local ESPColorButton = Instance.new("TextButton")
    ESPColorButton.Size = UDim2.new(0.45, 0, 0, 28)
    ESPColorButton.Position = UDim2.new(0.52, 0, 0, 2)
    ESPColorButton.BackgroundColor3 = ESPColor
    ESPColorButton.BorderSizePixel = 0
    ESPColorButton.Text = "تغيير اللون"
    ESPColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPColorButton.Font = Enum.Font.SourceSansSemibold
    ESPColorButton.TextSize = 12
    ESPColorButton.Parent = TogglesContainer
    ToggleCorner:Clone().Parent = ESPColorButton

    -- مفتاح توسيع الهيت بوكس
    local HitboxToggle = Instance.new("TextButton")
    HitboxToggle.Size = UDim2.new(1, 0, 0, 32)
    HitboxToggle.Position = UDim2.new(0, 0, 0, 40)
    HitboxToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    HitboxToggle.BorderSizePixel = 0
    HitboxToggle.Text = "🎯 توسيع الهيت بوكس: إيقاف"
    HitboxToggle.TextColor3 = Color3.fromRGB(255, 50, 50)
    HitboxToggle.Font = Enum.Font.SourceSansSemibold
    HitboxToggle.TextSize = 14
    HitboxToggle.Parent = TogglesContainer
    ToggleCorner:Clone().Parent = HitboxToggle

    -- زر تغيير لون الهيت بوكس
    local HitboxColorButton = Instance.new("TextButton")
    HitboxColorButton.Size = UDim2.new(0.45, 0, 0, 28)
    HitboxColorButton.Position = UDim2.new(0.52, 0, 0, 42)
    HitboxColorButton.BackgroundColor3 = HitboxColor
    HitboxColorButton.BorderSizePixel = 0
    HitboxColorButton.Text = "تغيير اللون"
    HitboxColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxColorButton.Font = Enum.Font.SourceSansSemibold
    HitboxColorButton.TextSize = 12
    HitboxColorButton.Parent = TogglesContainer
    ToggleCorner:Clone().Parent = HitboxColorButton

    -- معلومات الألوان الحالية
    local ColorInfo = Instance.new("TextLabel")
    ColorInfo.Size = UDim2.new(1, 0, 0, 40)
    ColorInfo.Position = UDim2.new(0, 0, 0, 80)
    ColorInfo.BackgroundTransparency = 1
    ColorInfo.Text = "الألوان الحالية:\nالرؤية: أحمر\nالهيت بوكس: أحمر"
    ColorInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    ColorInfo.Font = Enum.Font.SourceSans
    ColorInfo.TextSize = 12
    ColorInfo.TextXAlignment = Enum.TextXAlignment.Left
    ColorInfo.Parent = TogglesContainer

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
    ButtonImage.Image = "rbxassetid://10734996320"
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
    ESPToggle.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        local status = ESPEnabled and "تشغيل" or "إيقاف"
        ESPToggle.Text = "👁️ الرؤية عبر الجدران: " .. status
        ESPToggle.TextColor3 = ESPEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        -- تحديث الـ ESP
        UpdateHighlightESP()
        
        -- تأثير عند النقر
        local tween = TweenService:Create(ESPToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(ESPToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
        tween:Play()
    end)

    ESPColorButton.MouseButton1Click:Connect(function()
        local newColorName = ChangeESPColor()
        ESPColorButton.BackgroundColor3 = ESPColor
        
        -- تحديث معلومات الألوان
        ColorInfo.Text = "الألوان الحالية:\nالرؤية: " .. newColorName .. "\nالهيت بوكس: " .. ColorInfo.Text:match("الهيت بوكس: (%w+)")
        
        -- تأثير عند النقر
        local tween = TweenService:Create(ESPColorButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(ESPColorButton, TweenInfo.new(0.1), {BackgroundColor3 = ESPColor})
        tween:Play()
    end)

    HitboxToggle.MouseButton1Click:Connect(function()
        HitboxEnabled = not HitboxEnabled
        local status = HitboxEnabled and "تشغيل" or "إيقاف"
        HitboxToggle.Text = "🎯 توسيع الهيت بوكس: " .. status
        HitboxToggle.TextColor3 = HitboxEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        -- تحديث الهيت بوكس
        UpdateHitboxes()
        
        -- تأثير عند النقر
        local tween = TweenService:Create(HitboxToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(HitboxToggle, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)})
        tween:Play()
    end)

    HitboxColorButton.MouseButton1Click:Connect(function()
        local newColorName = ChangeHitboxColor()
        HitboxColorButton.BackgroundColor3 = HitboxColor
        
        -- تحديث معلومات الألوان
        ColorInfo.Text = "الألوان الحالية:\nالرؤية: " .. ColorInfo.Text:match("الرؤية: (%w+)") .. "\nالهيت بوكس: " .. newColorName
        
        -- تأثير عند النقر
        local tween = TweenService:Create(HitboxColorButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(HitboxColorButton, TweenInfo.new(0.1), {BackgroundColor3 = HitboxColor})
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
        else
            -- تأثير عند الإغلاق
            local tween = TweenService:Create(OpenCloseButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 100, 180),
                Rotation = 0
            })
            tween:Play()
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
    -- الحلقة الرئيسية
    -- =============================================
    RunService.RenderStepped:Connect(function()
        -- تحديث الرؤية عبر الجدران
        UpdateHighlightESP()
        
        -- تحديث الهيت بوكس
        UpdateHitboxes()
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

    -- تنظيف عند مغادرة اللاعب
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == player then
            if ControlGui then ControlGui:Destroy() end
            -- تنظيف الـ ESP
            for _, highlight in pairs(ESPObjects) do
                if highlight then
                    highlight:Destroy()
                end
            end
            -- تنظيف الهيت بوكس
            for character, _ in pairs(HitboxObjects) do
                ResetHitbox(character)
            end
        end
    end)

    print("🎉 تم تحميل MZ Hub بنجاح!")
    print("👁️ نظام الرؤية عبر الجدران (Highlights) - نشط!")
    print("🎯 نظام توسيع الهيت بوكس - جاهز!")
    print("🎨 أزرار تغيير الألوان - تعمل!")
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
