-- Enhanced ESP Script with Special UI and Aim Assist
local Config = {
    BoxESP = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    TeamColor = true,
    BoxOutline = true,
    
    NameESP = true,
    DistanceESP = true,
    HealthESP = true,
    SkeletonESP = true,
    
    TeamCheck = true,
    AllyColor = Color3.fromRGB(0, 255, 140),
    EnemyColor = Color3.fromRGB(255, 25, 25),
    
    BoxTrans = 0.7,
    TextTrans = 0.7,
    
    MaxDistance = 1000,
    TextSize = 16,
    
    -- Aim Assist Settings
    AimAssist = false,
    AimKey = Enum.UserInputType.MouseButton2, -- Right click
    AimFOV = 30, -- Field of view for aim assist
    AimSmoothness = 0.2, -- Lower = smoother
    InstantSnap = false, -- For mobile/phone
    
    -- UI Settings
    UIOpened = true
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ESPObjects = {}
local SkeletonConnections = {}
local TargetPlayer = nil
local GetPlayers = Players.GetPlayers
local WorldToViewportPoint = Camera.WorldToViewportPoint
local Toggled = true
local connection = nil

-- Death handling
local function CheckPlayerAlive()
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Enhanced Drawing Creation with Error Handling
local function CreateDrawing(type, props)
    local obj = nil
    pcall(function()
        obj = Drawing.new(type)
        for i,v in pairs(props) do
            pcall(function()
                obj[i] = v
            end)
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
        return plr.Team == LocalPlayer.Team and Config.AllyColor or Config.EnemyColor
    else
        return Config.BoxColor
    end
end

local function GetBoxSize(plr)
    local success, boxSize, boxPos = pcall(function()
        local char = plr.Character
        local hrp = char.HumanoidRootPart
        local head = char.Head
        
        local rootPos, rootVis = WorldToViewportPoint(Camera, hrp.Position)
        if not rootVis then return Vector2.new(), Vector2.new(), false end
        
        local headPos = WorldToViewportPoint(Camera, head.Position + Vector3.new(0, 0.5, 0))
        local legPos = WorldToViewportPoint(Camera, hrp.Position - Vector3.new(0, 3, 0))
        
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

local function GetLimbPositions(char, rigType)
    local limbs = {}
    
    pcall(function()
        if rigType == "R6" then
            local head = WorldToViewportPoint(Camera, char.Head.Position)
            local torso = WorldToViewportPoint(Camera, char.Torso.Position)
            local leftArm = WorldToViewportPoint(Camera, char["Left Arm"].Position)
            local rightArm = WorldToViewportPoint(Camera, char["Right Arm"].Position)
            local leftLeg = WorldToViewportPoint(Camera, char["Left Leg"].Position)
            local rightLeg = WorldToViewportPoint(Camera, char["Right Leg"].Position)
            
            limbs = {
                Head = Vector2.new(head.X, head.Y),
                Torso = Vector2.new(torso.X, torso.Y),
                LeftArm = Vector2.new(leftArm.X, leftArm.Y),
                RightArm = Vector2.new(rightArm.X, rightArm.Y),
                LeftLeg = Vector2.new(leftLeg.X, leftLeg.Y),
                RightLeg = Vector2.new(rightLeg.X, rightLeg.Y)
            }
        else -- R15 or other
            local head = char:FindFirstChild("Head") and WorldToViewportPoint(Camera, char.Head.Position)
            local upperTorso = char:FindFirstChild("UpperTorso") and WorldToViewportPoint(Camera, char.UpperTorso.Position)
            local lowerTorso = char:FindFirstChild("LowerTorso") and WorldToViewportPoint(Camera, char.LowerTorso.Position)
            local leftUpperArm = char:FindFirstChild("LeftUpperArm") and WorldToViewportPoint(Camera, char.LeftUpperArm.Position)
            local rightUpperArm = char:FindFirstChild("RightUpperArm") and WorldToViewportPoint(Camera, char.RightUpperArm.Position)
            local leftLowerArm = char:FindFirstChild("LeftLowerArm") and WorldToViewportPoint(Camera, char.LeftLowerArm.Position)
            local rightLowerArm = char:FindFirstChild("RightLowerArm") and WorldToViewportPoint(Camera, char.RightLowerArm.Position)
            local leftHand = char:FindFirstChild("LeftHand") and WorldToViewportPoint(Camera, char.LeftHand.Position)
            local rightHand = char:FindFirstChild("RightHand") and WorldToViewportPoint(Camera, char.RightHand.Position)
            local leftUpperLeg = char:FindFirstChild("LeftUpperLeg") and WorldToViewportPoint(Camera, char.LeftUpperLeg.Position)
            local rightUpperLeg = char:FindFirstChild("RightUpperLeg") and WorldToViewportPoint(Camera, char.RightUpperLeg.Position)
            local leftLowerLeg = char:FindFirstChild("LeftLowerLeg") and WorldToViewportPoint(Camera, char.LeftLowerLeg.Position)
            local rightLowerLeg = char:FindFirstChild("RightLowerLeg") and WorldToViewportPoint(Camera, char.RightLowerLeg.Position)
            local leftFoot = char:FindFirstChild("LeftFoot") and WorldToViewportPoint(Camera, char.LeftFoot.Position)
            local rightFoot = char:FindFirstChild("RightFoot") and WorldToViewportPoint(Camera, char.RightFoot.Position)
            
            limbs = {
                Head = head and Vector2.new(head.X, head.Y),
                UpperTorso = upperTorso and Vector2.new(upperTorso.X, upperTorso.Y),
                LowerTorso = lowerTorso and Vector2.new(lowerTorso.X, lowerTorso.Y),
                LeftUpperArm = leftUpperArm and Vector2.new(leftUpperArm.X, leftUpperArm.Y),
                RightUpperArm = rightUpperArm and Vector2.new(rightUpperArm.X, rightUpperArm.Y),
                LeftLowerArm = leftLowerArm and Vector2.new(leftLowerArm.X, leftLowerArm.Y),
                RightLowerArm = rightLowerArm and Vector2.new(rightLowerArm.X, rightLowerArm.Y),
                LeftHand = leftHand and Vector2.new(leftHand.X, leftHand.Y),
                RightHand = rightHand and Vector2.new(rightHand.X, rightHand.Y),
                LeftUpperLeg = leftUpperLeg and Vector2.new(leftUpperLeg.X, leftUpperLeg.Y),
                RightUpperLeg = rightUpperLeg and Vector2.new(rightUpperLeg.X, rightUpperLeg.Y),
                LeftLowerLeg = leftLowerLeg and Vector2.new(leftLowerLeg.X, leftLowerLeg.Y),
                RightLowerLeg = rightLowerLeg and Vector2.new(rightLowerLeg.X, rightLowerLeg.Y),
                LeftFoot = leftFoot and Vector2.new(leftFoot.X, leftFoot.Y),
                RightFoot = rightFoot and Vector2.new(rightFoot.X, rightFoot.Y)
            }
        end
    end)
    
    return limbs
end

local function CreateLine()
    return CreateDrawing("Line", {
        Visible = false,
        Thickness = 1.5,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = Config.BoxTrans
    })
end

local function CreatePlayerESP(plr)
    local esp = {
        Name = plr.Name,
        Player = plr,
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
        }),
        HealthBar = CreateDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Transparency = Config.BoxTrans + 0.2,
            Color = Color3.fromRGB(0, 255, 0),
            Visible = false
        }),
        HealthBarBG = CreateDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Transparency = Config.BoxTrans - 0.2,
            Color = Color3.fromRGB(40, 40, 40),
            Visible = false
        }),
        Skeleton = {
            Head = {
                UpperTorso = CreateLine()
            },
            UpperTorso = {
                LowerTorso = CreateLine(),
                LeftUpperArm = CreateLine(),
                RightUpperArm = CreateLine()
            },
            LowerTorso = {
                LeftUpperLeg = CreateLine(),
                RightUpperLeg = CreateLine()
            },
            LeftUpperArm = {
                LeftLowerArm = CreateLine()
            },
            RightUpperArm = {
                RightLowerArm = CreateLine()
            },
            LeftLowerArm = {
                LeftHand = CreateLine()
            },
            RightLowerArm = {
                RightHand = CreateLine()
            },
            LeftUpperLeg = {
                LeftLowerLeg = CreateLine()
            },
            RightUpperLeg = {
                RightLowerLeg = CreateLine()
            },
            LeftLowerLeg = {
                LeftFoot = CreateLine()
            },
            RightLowerLeg = {
                RightFoot = CreateLine()
            }
        },
        SkeletonR6 = {
            Head = {
                Torso = CreateLine()
            },
            Torso = {
                LeftArm = CreateLine(),
                RightArm = CreateLine(),
                LeftLeg = CreateLine(),
                RightLeg = CreateLine()
            }
        }
    }
    
    ESPObjects[plr] = esp
    return esp
end

local function UpdateSkeleton(esp, limbs, color, transparency, visible, isR6)
    pcall(function()
        if isR6 then
            if limbs.Head and limbs.Torso then
                esp.SkeletonR6.Head.Torso.From = limbs.Head
                esp.SkeletonR6.Head.Torso.To = limbs.Torso
                esp.SkeletonR6.Head.Torso.Color = color
                esp.SkeletonR6.Head.Torso.Transparency = transparency
                esp.SkeletonR6.Head.Torso.Visible = visible
            end
            
            if limbs.Torso then
                if limbs.LeftArm then
                    esp.SkeletonR6.Torso.LeftArm.From = limbs.Torso
                    esp.SkeletonR6.Torso.LeftArm.To = limbs.LeftArm
                    esp.SkeletonR6.Torso.LeftArm.Color = color
                    esp.SkeletonR6.Torso.LeftArm.Transparency = transparency
                    esp.SkeletonR6.Torso.LeftArm.Visible = visible
                end
                
                if limbs.RightArm then
                    esp.SkeletonR6.Torso.RightArm.From = limbs.Torso
                    esp.SkeletonR6.Torso.RightArm.To = limbs.RightArm
                    esp.SkeletonR6.Torso.RightArm.Color = color
                    esp.SkeletonR6.Torso.RightArm.Transparency = transparency
                    esp.SkeletonR6.Torso.RightArm.Visible = visible
                end
                
                if limbs.LeftLeg then
                    esp.SkeletonR6.Torso.LeftLeg.From = limbs.Torso
                    esp.SkeletonR6.Torso.LeftLeg.To = limbs.LeftLeg
                    esp.SkeletonR6.Torso.LeftLeg.Color = color
                    esp.SkeletonR6.Torso.LeftLeg.Transparency = transparency
                    esp.SkeletonR6.Torso.LeftLeg.Visible = visible
                end
                
                if limbs.RightLeg then
                    esp.SkeletonR6.Torso.RightLeg.From = limbs.Torso
                    esp.SkeletonR6.Torso.RightLeg.To = limbs.RightLeg
                    esp.SkeletonR6.Torso.RightLeg.Color = color
                    esp.SkeletonR6.Torso.RightLeg.Transparency = transparency
                    esp.SkeletonR6.Torso.RightLeg.Visible = visible
                end
            end
        else
            if limbs.Head and limbs.UpperTorso then
                esp.Skeleton.Head.UpperTorso.From = limbs.Head
                esp.Skeleton.Head.UpperTorso.To = limbs.UpperTorso
                esp.Skeleton.Head.UpperTorso.Color = color
                esp.Skeleton.Head.UpperTorso.Transparency = transparency
                esp.Skeleton.Head.UpperTorso.Visible = visible
            end
            
            if limbs.UpperTorso then
                if limbs.LowerTorso then
                    esp.Skeleton.UpperTorso.LowerTorso.From = limbs.UpperTorso
                    esp.Skeleton.UpperTorso.LowerTorso.To = limbs.LowerTorso
                    esp.Skeleton.UpperTorso.LowerTorso.Color = color
                    esp.Skeleton.UpperTorso.LowerTorso.Transparency = transparency
                    esp.Skeleton.UpperTorso.LowerTorso.Visible = visible
                end
                
                if limbs.LeftUpperArm then
                    esp.Skeleton.UpperTorso.LeftUpperArm.From = limbs.UpperTorso
                    esp.Skeleton.UpperTorso.LeftUpperArm.To = limbs.LeftUpperArm
                    esp.Skeleton.UpperTorso.LeftUpperArm.Color = color
                    esp.Skeleton.UpperTorso.LeftUpperArm.Transparency = transparency
                    esp.Skeleton.UpperTorso.LeftUpperArm.Visible = visible
                end
                
                if limbs.RightUpperArm then
                    esp.Skeleton.UpperTorso.RightUpperArm.From = limbs.UpperTorso
                    esp.Skeleton.UpperTorso.RightUpperArm.To = limbs.RightUpperArm
                    esp.Skeleton.UpperTorso.RightUpperArm.Color = color
                    esp.Skeleton.UpperTorso.RightUpperArm.Transparency = transparency
                    esp.Skeleton.UpperTorso.RightUpperArm.Visible = visible
                end
            end
            
            if limbs.LowerTorso then
                if limbs.LeftUpperLeg then
                    esp.Skeleton.LowerTorso.LeftUpperLeg.From = limbs.LowerTorso
                    esp.Skeleton.LowerTorso.LeftUpperLeg.To = limbs.LeftUpperLeg
                    esp.Skeleton.LowerTorso.LeftUpperLeg.Color = color
                    esp.Skeleton.LowerTorso.LeftUpperLeg.Transparency = transparency
                    esp.Skeleton.LowerTorso.LeftUpperLeg.Visible = visible
                end
                
                if limbs.RightUpperLeg then
                    esp.Skeleton.LowerTorso.RightUpperLeg.From = limbs.LowerTorso
                    esp.Skeleton.LowerTorso.RightUpperLeg.To = limbs.RightUpperLeg
                    esp.Skeleton.LowerTorso.RightUpperLeg.Color = color
                    esp.Skeleton.LowerTorso.RightUpperLeg.Transparency = transparency
                    esp.Skeleton.LowerTorso.RightUpperLeg.Visible = visible
                end
            end
            
            if limbs.LeftUpperArm and limbs.LeftLowerArm then
                esp.Skeleton.LeftUpperArm.LeftLowerArm.From = limbs.LeftUpperArm
                esp.Skeleton.LeftUpperArm.LeftLowerArm.To = limbs.LeftLowerArm
                esp.Skeleton.LeftUpperArm.LeftLowerArm.Color = color
                esp.Skeleton.LeftUpperArm.LeftLowerArm.Transparency = transparency
                esp.Skeleton.LeftUpperArm.LeftLowerArm.Visible = visible
            end
            
            if limbs.RightUpperArm and limbs.RightLowerArm then
                esp.Skeleton.RightUpperArm.RightLowerArm.From = limbs.RightUpperArm
                esp.Skeleton.RightUpperArm.RightLowerArm.To = limbs.RightLowerArm
                esp.Skeleton.RightUpperArm.RightLowerArm.Color = color
                esp.Skeleton.RightUpperArm.RightLowerArm.Transparency = transparency
                esp.Skeleton.RightUpperArm.RightLowerArm.Visible = visible
            end
            
            if limbs.LeftLowerArm and limbs.LeftHand then
                esp.Skeleton.LeftLowerArm.LeftHand.From = limbs.LeftLowerArm
                esp.Skeleton.LeftLowerArm.LeftHand.To = limbs.LeftHand
                esp.Skeleton.LeftLowerArm.LeftHand.Color = color
                esp.Skeleton.LeftLowerArm.LeftHand.Transparency = transparency
                esp.Skeleton.LeftLowerArm.LeftHand.Visible = visible
            end
            
            if limbs.RightLowerArm and limbs.RightHand then
                esp.Skeleton.RightLowerArm.RightHand.From = limbs.RightLowerArm
                esp.Skeleton.RightLowerArm.RightHand.To = limbs.RightHand
                esp.Skeleton.RightLowerArm.RightHand.Color = color
                esp.Skeleton.RightLowerArm.RightHand.Transparency = transparency
                esp.Skeleton.RightLowerArm.RightHand.Visible = visible
            end
            
            if limbs.LeftUpperLeg and limbs.LeftLowerLeg then
                esp.Skeleton.LeftUpperLeg.LeftLowerLeg.From = limbs.LeftUpperLeg
                esp.Skeleton.LeftUpperLeg.LeftLowerLeg.To = limbs.LeftLowerLeg
                esp.Skeleton.LeftUpperLeg.LeftLowerLeg.Color = color
                esp.Skeleton.LeftUpperLeg.LeftLowerLeg.Transparency = transparency
                esp.Skeleton.LeftUpperLeg.LeftLowerLeg.Visible = visible
            end
            
            if limbs.RightUpperLeg and limbs.RightLowerLeg then
                esp.Skeleton.RightUpperLeg.RightLowerLeg.From = limbs.RightUpperLeg
                esp.Skeleton.RightUpperLeg.RightLowerLeg.To = limbs.RightLowerLeg
                esp.Skeleton.RightUpperLeg.RightLowerLeg.Color = color
                esp.Skeleton.RightUpperLeg.RightLowerLeg.Transparency = transparency
                esp.Skeleton.RightUpperLeg.RightLowerLeg.Visible = visible
            end
            
            if limbs.LeftLowerLeg and limbs.LeftFoot then
                esp.Skeleton.LeftLowerLeg.LeftFoot.From = limbs.LeftLowerLeg
                esp.Skeleton.LeftLowerLeg.LeftFoot.To = limbs.LeftFoot
                esp.Skeleton.LeftLowerLeg.LeftFoot.Color = color
                esp.Skeleton.LeftLowerLeg.LeftFoot.Transparency = transparency
                esp.Skeleton.LeftLowerLeg.LeftFoot.Visible = visible
            end
            
            if limbs.RightLowerLeg and limbs.RightFoot then
                esp.Skeleton.RightLowerLeg.RightFoot.From = limbs.RightLowerLeg
                esp.Skeleton.RightLowerLeg.RightFoot.To = limbs.RightFoot
                esp.Skeleton.RightLowerLeg.RightFoot.Color = color
                esp.Skeleton.RightLowerLeg.RightFoot.Transparency = transparency
                esp.Skeleton.RightLowerLeg.RightFoot.Visible = visible
            end
        end
    end)
end

local function HideSkeleton(esp)
    pcall(function()
        for _, parent in pairs(esp.Skeleton) do
            for _, line in pairs(parent) do
                line.Visible = false
            end
        end
        
        for _, parent in pairs(esp.SkeletonR6) do
            for _, line in pairs(parent) do
                line.Visible = false
            end
        end
    end)
end

local function IsR6(char)
    return char:FindFirstChild("Torso") ~= nil
end

local function UpdateESP()
    if not CheckPlayerAlive() then return end -- Continue even if dead
    
    for _, plr in ipairs(GetPlayers(Players)) do
        if plr ~= LocalPlayer then
            local esp = ESPObjects[plr] or CreatePlayerESP(plr)
            
            pcall(function()
                if IsAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local char = plr.Character
                    local hrp = char.HumanoidRootPart
                    local hum = char:FindFirstChild("Humanoid")
                    
                    local pos, vis = WorldToViewportPoint(Camera, hrp.Position)
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
                            
                            if Config.HealthESP and hum then
                                local hp = hum.Health / hum.MaxHealth
                                local barSize = Vector2.new(3, boxSize.Y * hp)
                                local barPos = boxPos + Vector2.new(-5, boxSize.Y * (1 - hp))
                                
                                esp.HealthBar.Size = barSize
                                esp.HealthBar.Position = barPos
                                esp.HealthBar.Color = Color3.fromRGB(255 - (255 * hp), (255 * hp), 0)
                                esp.HealthBar.Visible = true
                                
                                esp.HealthBarBG.Size = Vector2.new(3, boxSize.Y)
                                esp.HealthBarBG.Position = Vector2.new(boxPos.X - 5, boxPos.Y)
                                esp.HealthBarBG.Visible = true
                            else
                                esp.HealthBar.Visible = false
                                esp.HealthBarBG.Visible = false
                            end
                            
                            if Config.SkeletonESP then
                                local isR6 = IsR6(char)
                                local limbs = GetLimbPositions(char, isR6 and "R6" or "R15")
                                
                                UpdateSkeleton(esp, limbs, teamColor, Config.BoxTrans, true, isR6)
                            else
                                HideSkeleton(esp)
                            end
                        else
                            esp.Box.Visible = false
                            esp.BoxOutline.Visible = false
                            esp.Name.Visible = false
                            esp.Distance.Visible = false
                            esp.HealthBar.Visible = false
                            esp.HealthBarBG.Visible = false
                            HideSkeleton(esp)
                        end
                    else
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                        esp.Name.Visible = false
                        esp.Distance.Visible = false
                        esp.HealthBar.Visible = false
                        esp.HealthBarBG.Visible = false
                        HideSkeleton(esp)
                    end
                else
                    esp.Box.Visible = false
                    esp.BoxOutline.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.HealthBar.Visible = false
                    esp.HealthBarBG.Visible = false
                    HideSkeleton(esp)
                end
            end)
        end
    end
    
    for plr, esp in pairs(ESPObjects) do
        if not table.find(GetPlayers(Players), plr) then
            pcall(function()
                for _, drawing in pairs(esp) do
                    if typeof(drawing) == "table" then
                        if drawing.Remove then
                            drawing:Remove()
                        else
                            for _, subDraw in pairs(drawing) do
                                if typeof(subDraw) == "table" then
                                    for _, line in pairs(subDraw) do
                                        line:Remove()
                                    end
                                elseif subDraw.Remove then
                                    subDraw:Remove()
                                end
                            end
                        end
                    elseif drawing.Remove then
                        drawing:Remove()
                    end
                end
            end)
            
            ESPObjects[plr] = nil
        end
    end
end

-- AIM ASSIST FUNCTIONS
local function FindClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Config.AimFOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and IsAlive(LocalPlayer) then
            local character = player.Character
            local localCharacter = LocalPlayer.Character
            
            if character and localCharacter then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart and localHumanoidRootPart then
                    local screenPoint = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    local mouseLocation = UserInputService:GetMouseLocation()
                    
                    local distanceFromCursor = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
                    local worldDistance = (humanoidRootPart.Position - localHumanoidRootPart.Position).Magnitude
                    
                    if distanceFromCursor < closestDistance and worldDistance <= Config.MaxDistance then
                        closestDistance = distanceFromCursor
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function AimAtPlayer(player)
    if not player or not IsAlive(player) or not IsAlive(LocalPlayer) then return end
    
    local character = player.Character
    local localCharacter = LocalPlayer.Character
    
    if character and localCharacter then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart and localHumanoidRootPart then
            if Config.InstantSnap then
                -- Instant snap for mobile
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, humanoidRootPart.Position)
            else
                -- Smooth aim for PC
                local targetPosition = humanoidRootPart.Position
                local currentCFrame = Camera.CFrame
                local newCFrame = CFrame.new(currentCFrame.Position, targetPosition)
                
                Camera.CFrame = currentCFrame:Lerp(newCFrame, Config.AimSmoothness)
            end
        end
    end
end

-- AIM ASSIST CONNECTION
local aimConnection
local function StartAimAssist()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Config.AimKey or (Config.InstantSnap and input.UserInputType == Enum.UserInputType.Touch) then
            local closestPlayer = FindClosestPlayer()
            if closestPlayer then
                AimAtPlayer(closestPlayer)
            end
        end
    end)
end

local function StopAimAssist()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end

-- ESP TOGGLE FUNCTIONS
local function CleanupESP()
    for _, esp in pairs(ESPObjects) do
        pcall(function()
            for _, drawing in pairs(esp) do
                if typeof(drawing) == "table" then
                    if drawing.Remove then
                        drawing:Remove()
                    else
                        for _, subDraw in pairs(drawing) do
                            if typeof(subDraw) == "table" then
                                for _, line in pairs(subDraw) do
                                    line:Remove()
                                end
                            elseif subDraw.Remove then
                                subDraw:Remove()
                            end
                        end
                    end
                elseif drawing.Remove then
                    drawing:Remove()
                end
            end
        end)
    end
    
    ESPObjects = {}
end

local function ToggleESP()
    Toggled = not Toggled
    if not Toggled then
        if connection then
            connection:Disconnect()
            connection = nil
        end
        CleanupESP()
    else
        connection = RunService.RenderStepped:Connect(UpdateESP)
    end
    return Toggled
end

-- SPECIAL UI CREATION
local function CreateSpecialUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SpecialESPUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Circle Toggle Button
    local CircleButton = Instance.new("TextButton")
    CircleButton.Name = "CircleToggle"
    CircleButton.Size = UDim2.new(0, 60, 0, 60)
    CircleButton.Position = UDim2.new(1, -70, 0.5, -30)
    CircleButton.AnchorPoint = Vector2.new(0, 0.5)
    CircleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    CircleButton.BorderSizePixel = 0
    CircleButton.Text = "⚡"
    CircleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CircleButton.Font = Enum.Font.GothamBold
    CircleButton.TextSize = 20
    CircleButton.Parent = ScreenGui
    CircleButton.BackgroundTransparency = 0.2
    CircleButton.AutoButtonColor = false

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = CircleButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(100, 100, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = CircleButton

    -- Control Panel
    local ControlPanel = Instance.new("Frame")
    ControlPanel.Name = "ControlPanel"
    ControlPanel.Size = UDim2.new(0, 200, 0, 300)
    ControlPanel.Position = UDim2.new(1, -210, 0.5, -150)
    ControlPanel.AnchorPoint = Vector2.new(0, 0.5)
    ControlPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ControlPanel.BorderSizePixel = 0
    ControlPanel.Visible = Config.UIOpened
    ControlPanel.Parent = ScreenGui

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 12)
    PanelCorner.Parent = ControlPanel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(80, 80, 120)
    PanelStroke.Thickness = 2
    PanelStroke.Parent = ControlPanel

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Title.BorderSizePixel = 0
    Title.Text = "ESP CONTROLS"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = ControlPanel

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title

    -- Toggle Buttons Container
    local TogglesContainer = Instance.new("ScrollingFrame")
    TogglesContainer.Name = "TogglesContainer"
    TogglesContainer.Size = UDim2.new(1, -10, 1, -50)
    TogglesContainer.Position = UDim2.new(0, 5, 0, 45)
    TogglesContainer.BackgroundTransparency = 1
    TogglesContainer.BorderSizePixel = 0
    TogglesContainer.ScrollBarThickness = 4
    TogglesContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
    TogglesContainer.Parent = ControlPanel

    -- Toggle Button Template
    local function CreateToggle(name, configKey, defaultValue)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = TogglesContainer

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "Label"
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "Toggle"
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
        ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
        ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 10)
        ToggleCorner.Parent = ToggleButton

        ToggleButton.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        end)

        return ToggleFrame
    end

    -- Create Toggles
    local toggles = {
        {"Box ESP", "BoxESP", true},
        {"Name ESP", "NameESP", true},
        {"Distance", "DistanceESP", true},
        {"Health Bar", "HealthESP", true},
        {"Skeleton", "SkeletonESP", true},
        {"Team Colors", "TeamColor", true},
        {"Box Outline", "BoxOutline", true},
        {"Aim Assist", "AimAssist", false},
        {"Instant Snap", "InstantSnap", false}
    }

    for i, toggleData in ipairs(toggles) do
        local toggle = CreateToggle(toggleData[1], toggleData[2], toggleData[3])
        toggle.Position = UDim2.new(0, 0, 0, (i-1) * 35)
        TogglesContainer.CanvasSize = UDim2.new(0, 0, 0, #toggles * 35)
    end

    -- Main ESP Toggle
    local MainToggle = Instance.new("TextButton")
    MainToggle.Name = "MainToggle"
    MainToggle.Size = UDim2.new(1, -20, 0, 40)
    MainToggle.Position = UDim2.new(0, 10, 1, -50)
    MainToggle.BackgroundColor3 = Toggled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    MainToggle.BorderSizePixel = 0
    MainToggle.Text = Toggled and "ESP: ON" or "ESP: OFF"
    MainToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainToggle.Font = Enum.Font.GothamBold
    MainToggle.TextSize = 16
    MainToggle.Parent = ControlPanel

    local MainToggleCorner = Instance.new("UICorner")
    MainToggleCorner.CornerRadius = UDim.new(0, 8)
    MainToggleCorner.Parent = MainToggle

    MainToggle.MouseButton1Click:Connect(function()
        local status = ToggleESP()
        MainToggle.Text = status and "ESP: ON" or "ESP: OFF"
        MainToggle.BackgroundColor3 = status and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        CircleButton.BackgroundColor3 = status and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(50, 25, 25)
    end)

    -- Circle Button Functionality
    CircleButton.MouseButton1Click:Connect(function()
        Config.UIOpened = not Config.UIOpened
        ControlPanel.Visible = Config.UIOpened
        
        -- Animate the circle button
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(CircleButton, tweenInfo, {
            Rotation = Config.UIOpened and 45 or 0,
            BackgroundColor3 = Config.UIOpened and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(25, 25, 25)
        })
        tween:Play()
    end)

    -- Make UI draggable
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        ControlPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ControlPanel.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return ScreenGui
end

-- INITIALIZE EVERYTHING
local function Initialize()
    -- Create UI
    CreateSpecialUI()
    
    -- Start ESP
    connection = RunService.RenderStepped:Connect(UpdateESP)
    
    -- Start Aim Assist if enabled
    if Config.AimAssist then
        StartAimAssist()
    end
    
    -- Handle respawn
    LocalPlayer.CharacterAdded:Connect(function()
        -- ESP continues working automatically
    end)
end

-- Start the script
Initialize()