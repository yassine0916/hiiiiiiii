-- MZ Hub - By Unknown Boi
-- واجهة MZ Hub - صنعت بواسطة Unknown Boi

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- اللغة العربية
local ArabicText = {
    MainTitle = "MZ Hub",
    Copyright = "صنع بواسطة Unknown Boi",
    OpenClose = "فتح/إغلاق",
    ESP = "الرؤية عبر الجدران",
    Hitbox = "توسيع هيت بوكس",
    Color = "تغيير اللون",
    On = "تشغيل",
    Off = "إيقاف",
    Red = "أحمر",
    Green = "أخضر",
    Blue = "أزرق",
    Yellow = "أصفر",
    Purple = "بنفسجي"
}

-- المتغيرات
local ESPEnabled = false
local HitboxEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local HitboxColor = Color3.fromRGB(255, 0, 0)
local ESPInstances = {}
local HitboxInstances = {}

-- إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MZHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- زر الفتح/الإغلاق الرئيسي
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 100, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = ArabicText.OpenClose
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.BorderSizePixel = 0
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui

-- النافذة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- العنوان
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = ArabicText.MainTitle
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BorderSizePixel = 0
Title.Parent = MainFrame

-- حقوق النشر
local Copyright = Instance.new("TextLabel")
Copyright.Name = "Copyright"
Copyright.Size = UDim2.new(1, 0, 0, 20)
Copyright.Position = UDim2.new(0, 0, 0, 40)
Copyright.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Copyright.TextColor3 = Color3.fromRGB(200, 200, 200)
Copyright.Text = ArabicText.Copyright
Copyright.Font = Enum.Font.Gotham
Copyright.TextSize = 12
Copyright.BorderSizePixel = 0
Copyright.Parent = MainFrame

-- إطار المحتوى
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- قسم ESP
local ESPFrame = Instance.new("Frame")
ESPFrame.Name = "ESPFrame"
ESPFrame.Size = UDim2.new(1, 0, 0, 100)
ESPFrame.Position = UDim2.new(0, 0, 0, 0)
ESPFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ESPFrame.BorderSizePixel = 0
ESPFrame.Parent = ContentFrame

local ESPTitle = Instance.new("TextLabel")
ESPTitle.Name = "ESPTitle"
ESPTitle.Size = UDim2.new(1, 0, 0, 30)
ESPTitle.Position = UDim2.new(0, 0, 0, 0)
ESPTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTitle.Text = ArabicText.ESP
ESPTitle.Font = Enum.Font.GothamBold
ESPTitle.TextSize = 16
ESPTitle.BorderSizePixel = 0
ESPTitle.Parent = ESPFrame

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0, 80, 0, 30)
ESPToggle.Position = UDim2.new(0, 10, 0, 40)
ESPToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Text = ArabicText.Off
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.TextSize = 14
ESPToggle.BorderSizePixel = 0
ESPToggle.Parent = ESPFrame

local ESPColorButton = Instance.new("TextButton")
ESPColorButton.Name = "ESPColorButton"
ESPColorButton.Size = UDim2.new(0, 80, 0, 30)
ESPColorButton.Position = UDim2.new(0, 100, 0, 40)
ESPColorButton.BackgroundColor3 = ESPColor
ESPColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPColorButton.Text = ArabicText.Color
ESPColorButton.Font = Enum.Font.GothamBold
ESPColorButton.TextSize = 14
ESPColorButton.BorderSizePixel = 0
ESPColorButton.Parent = ESPFrame

-- قسم Hitbox
local HitboxFrame = Instance.new("Frame")
HitboxFrame.Name = "HitboxFrame"
HitboxFrame.Size = UDim2.new(1, 0, 0, 150)
HitboxFrame.Position = UDim2.new(0, 0, 0, 110)
HitboxFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HitboxFrame.BorderSizePixel = 0
HitboxFrame.Parent = ContentFrame

local HitboxTitle = Instance.new("TextLabel")
HitboxTitle.Name = "HitboxTitle"
HitboxTitle.Size = UDim2.new(1, 0, 0, 30)
HitboxTitle.Position = UDim2.new(0, 0, 0, 0)
HitboxTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HitboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxTitle.Text = ArabicText.Hitbox
HitboxTitle.Font = Enum.Font.GothamBold
HitboxTitle.TextSize = 16
HitboxTitle.BorderSizePixel = 0
HitboxTitle.Parent = HitboxFrame

local HitboxToggle = Instance.new("TextButton")
HitboxToggle.Name = "HitboxToggle"
HitboxToggle.Size = UDim2.new(0, 80, 0, 30)
HitboxToggle.Position = UDim2.new(0, 10, 0, 40)
HitboxToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
HitboxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxToggle.Text = ArabicText.Off
HitboxToggle.Font = Enum.Font.GothamBold
HitboxToggle.TextSize = 14
HitboxToggle.BorderSizePixel = 0
HitboxToggle.Parent = HitboxFrame

-- أزرار تغيير ألوان Hitbox
local ColorButtonsFrame = Instance.new("Frame")
ColorButtonsFrame.Name = "ColorButtonsFrame"
ColorButtonsFrame.Size = UDim2.new(1, -20, 0, 60)
ColorButtonsFrame.Position = UDim2.new(0, 10, 0, 80)
ColorButtonsFrame.BackgroundTransparency = 1
ColorButtonsFrame.Parent = HitboxFrame

local colors = {
    {Name = ArabicText.Red, Color = Color3.fromRGB(255, 0, 0)},
    {Name = ArabicText.Green, Color = Color3.fromRGB(0, 255, 0)},
    {Name = ArabicText.Blue, Color = Color3.fromRGB(0, 0, 255)},
    {Name = ArabicText.Yellow, Color = Color3.fromRGB(255, 255, 0)},
    {Name = ArabicText.Purple, Color = Color3.fromRGB(255, 0, 255)}
}

for i, colorInfo in ipairs(colors) do
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = colorInfo.Name
    ColorButton.Size = UDim2.new(0.45, 0, 0, 25)
    ColorButton.Position = UDim2.new((i-1)%2 * 0.5, 5, math.floor((i-1)/2) * 0.5, 5)
    ColorButton.BackgroundColor3 = colorInfo.Color
    ColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorButton.Text = colorInfo.Name
    ColorButton.Font = Enum.Font.Gotham
    ColorButton.TextSize = 12
    ColorButton.BorderSizePixel = 0
    ColorButton.Parent = ColorButtonsFrame
end

-- إضافة الصورة (يمكنك استبدال الرابط بصورة الخاصة بك)
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0.8, 0, 0, -70)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://1234567890" -- ضع رابط الصورة هنا
Logo.Parent = MainFrame

-- وضع الواجهة على الشاشة
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- وظائف التحكم
local function ToggleGUI()
    MainFrame.Visible = not MainFrame.Visible
end

local function UpdateESP()
    for _, esp in pairs(ESPInstances) do
        if esp then
            esp:Remove()
        end
    end
    ESPInstances = {}
    
    if not ESPEnabled then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = otherPlayer.Character
            local humanoidRootPart = character.HumanoidRootPart
            
            -- Highlight ESP
            local highlight = Instance.new("Highlight")
            highlight.Name = "MZESP"
            highlight.Adornee = character
            highlight.FillColor = ESPColor
            highlight.OutlineColor = ESPColor
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Parent = character
            
            -- Track Line
            local beam = Instance.new("Beam")
            beam.Name = "MZTrackLine"
            beam.Color = ColorSequence.new(ESPColor)
            beam.Width0 = 0.2
            beam.Width1 = 0.2
            
            local attachment0 = Instance.new("Attachment")
            attachment0.Name = "MZAttachment0"
            attachment0.Parent = humanoidRootPart
            
            local attachment1 = Instance.new("Attachment")
            attachment1.Name = "MZAttachment1"
            attachment1.Parent = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Parent = workspace
            
            table.insert(ESPInstances, highlight)
            table.insert(ESPInstances, beam)
            table.insert(ESPInstances, attachment0)
            table.insert(ESPInstances, attachment1)
        end
    end
end

local function UpdateHitbox()
    for _, hitbox in pairs(HitboxInstances) do
        if hitbox then
            hitbox:Remove()
        end
    end
    HitboxInstances = {}
    
    if not HitboxEnabled then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local character = otherPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid then
                -- توسيع الهيت بوكس
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * 2
                        part.Transparency = 0.5
                        part.BrickColor = BrickColor.new(HitboxColor)
                        
                        local originalSize = part.Size
                        local originalTransparency = part.Transparency
                        local originalColor = part.BrickColor
                        
                        table.insert(HitboxInstances, {
                            Part = part,
                            OriginalSize = originalSize,
                            OriginalTransparency = originalTransparency,
                            OriginalColor = originalColor
                        })
                    end
                end
            end
        end
    end
end

local function ResetHitbox()
    for _, hitboxData in pairs(HitboxInstances) do
        if hitboxData.Part and hitboxData.Part.Parent then
            hitboxData.Part.Size = hitboxData.OriginalSize
            hitboxData.Part.Transparency = hitboxData.OriginalTransparency
            hitboxData.Part.BrickColor = hitboxData.OriginalColor
        end
    end
    HitboxInstances = {}
end

-- الأحداث
ToggleButton.MouseButton1Click:Connect(ToggleGUI)

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ESPToggle.Text = ArabicText.On
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ESPToggle.Text = ArabicText.Off
    end
    UpdateESP()
end)

ESPColorButton.MouseButton1Click:Connect(function()
    local currentIndex = 1
    for i, colorInfo in ipairs(colors) do
        if colorInfo.Color == ESPColor then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #colors) + 1
    ESPColor = colors[nextIndex].Color
    ESPColorButton.BackgroundColor3 = ESPColor
    UpdateESP()
end)

HitboxToggle.MouseButton1Click:Connect(function()
    HitboxEnabled = not HitboxEnabled
    if HitboxEnabled then
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        HitboxToggle.Text = ArabicText.On
        UpdateHitbox()
    else
        HitboxToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        HitboxToggle.Text = ArabicText.Off
        ResetHitbox()
    end
end)

for _, colorInfo in ipairs(colors) do
    local button = ColorButtonsFrame:FindFirstChild(colorInfo.Name)
    if button then
        button.MouseButton1Click:Connect(function()
            HitboxColor = colorInfo.Color
            if HitboxEnabled then
                UpdateHitbox()
            end
        end)
    end
end

-- تحديث ESP باستمرار
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
end)

-- إعادة التعيين عند الموت
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        -- الاستمرار في العمل حتى بعد الموت
        wait(1)
    end)
end)

-- جعل الواجهة مناسبة للهاتف
local function SetupMobileControls()
    local touchStartPos
    local frameStartPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = input.Position
            frameStartPos = MainFrame.Position
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and touchStartPos then
            local delta = input.Position - touchStartPos
            MainFrame.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStartPos = nil
            frameStartPos = nil
        end
    end)
end

SetupMobileControls()

print("MZ Hub loaded successfully! - By Unknown Boi")
print("تم تحميل MZ Hub بنجاح! - صنع بواسطة Unknown Boi")
