--[[
    ProfessionalUI v3
    A premium, unique UI library for Roblox with advanced key system
    
    Features:
    - Unique visual design with gradients, animations, and effects
    - Advanced key system with encryption, HWID binding, and expiration
    - Fully responsive and customizable
    - Comprehensive component library
]]

local ProfessionalUI = {
    Version = "3.0.0"
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
ProfessionalUI.Config = {
    Theme = {
        -- Base colors
        Primary = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(30, 30, 40),
        Tertiary = Color3.fromRGB(35, 35, 45),
        
        -- Accent colors
        Accent1 = Color3.fromRGB(90, 120, 255),  -- Primary accent (blue)
        Accent2 = Color3.fromRGB(180, 90, 255),  -- Secondary accent (purple)
        
        -- Text colors
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        
        -- Status colors
        Success = Color3.fromRGB(70, 200, 120),
        Error = Color3.fromRGB(255, 80, 80),
        Warning = Color3.fromRGB(255, 180, 30),
        
        -- Effects
        Glow = Color3.fromRGB(100, 130, 255),
        Transparency = 0.95,
        
        -- Gradients
        GradientEnabled = true,
        Gradient1 = Color3.fromRGB(90, 120, 255),
        Gradient2 = Color3.fromRGB(180, 90, 255)
    },
    
    Animation = {
        Duration = 0.3,
        Style = Enum.EasingStyle.Quint,
        Direction = Enum.EasingDirection.Out,
        
        -- Special animations
        PopDuration = 0.2,
        SlideDuration = 0.4,
        RotateDuration = 0.5
    },
    
    KeySystem = {
        Enabled = true,
        Keys = {},
        EncryptionKey = "PUI3_SECURE_KEY",
        Attempts = 5,
        SaveKey = true,
        CheckHWID = true,
        ServerCheck = false,
        ServerURL = "https://example.com/verify",
        AllowTrial = true,
        TrialTime = 300, -- 5 minutes in seconds
        KeyExpiration = true
    },
    
    Effects = {
        Blur = true,
        BlurSize = 15,
        Particles = true,
        Ripples = true,
        Sounds = true,
        SoundVolume = 0.5
    }
}

-- Utility Functions
local Utility = {}

function Utility:Create(instanceType, properties, children)
    local instance = Instance.new(instanceType)
    
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    
    return instance
end

function Utility:Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or ProfessionalUI.Config.Animation.Duration,
        style or ProfessionalUI.Config.Animation.Style,
        direction or ProfessionalUI.Config.Animation.Direction
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    
    return tween
end

function Utility:CreateSound(id, volume, parent)
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = volume or ProfessionalUI.Config.Effects.SoundVolume
    sound.Parent = parent or workspace
    return sound
end

function Utility:PlaySound(id)
    if not ProfessionalUI.Config.Effects.Sounds then return end
    
    local sound = Utility:CreateSound(id, ProfessionalUI.Config.Effects.SoundVolume, CoreGui)
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

function Utility:Ripple(button, color)
    if not ProfessionalUI.Config.Effects.Ripples then return end
    
    Utility:PlaySound("rbxassetid://6042583723")
    
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local targetSize = UDim2.new(0, button.AbsoluteSize.X * 1.5, 0, button.AbsoluteSize.X * 1.5)
    Utility:Tween(ripple, {Size = targetSize, BackgroundTransparency = 1}, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Utility:CreateGradient(parent, rotation, color1, color2)
    if not ProfessionalUI.Config.Theme.GradientEnabled then return end
    
    local gradient = Utility:Create("UIGradient", {
        Rotation = rotation or 45,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1 or ProfessionalUI.Config.Theme.Gradient1),
            ColorSequenceKeypoint.new(1, color2 or ProfessionalUI.Config.Theme.Gradient2)
        }),
        Parent = parent
    })
    
    return gradient
end

function Utility:CreateGlow(parent, color, size)
    local glow = Utility:Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = color or ProfessionalUI.Config.Theme.Glow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 30, 1, size or 30),
        ZIndex = -1,
        Parent = parent
    })
    
    return glow
end

function Utility:CreateBlur(parent)
    if not ProfessionalUI.Config.Effects.Blur then return end
    
    local blur = Utility:Create("BlurEffect", {
        Size = 0,
        Parent = game:GetService("Lighting")
    })
    
    Utility:Tween(blur, {Size = ProfessionalUI.Config.Effects.BlurSize}, 0.5)
    
    return blur
end

function Utility:RemoveBlur(blur)
    if not blur then return end
    
    Utility:Tween(blur, {Size = 0}, 0.5)
    task.delay(0.5, function()
        blur:Destroy()
    end)
end

function Utility:CreateParticles(parent, count, colors)
    if not ProfessionalUI.Config.Effects.Particles then return end
    
    local particles = {}
    colors = colors or {
        ProfessionalUI.Config.Theme.Accent1,
        ProfessionalUI.Config.Theme.Accent2
    }
    
    for i = 1, count or 20 do
        local particle = Utility:Create("Frame", {
            Name = "Particle_" .. i,
            BackgroundColor3 = colors[math.random(1, #colors)],
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5)),
            BackgroundTransparency = math.random(0, 0.5),
            ZIndex = 0,
            Parent = parent
        })
        
        local corner = Utility:Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = particle
        })
        
        -- Random movement
        spawn(function()
            while particle and particle.Parent do
                local randomPos = UDim2.new(
                    math.random(), math.random(-parent.AbsoluteSize.X/2, parent.AbsoluteSize.X/2),
                    math.random(), math.random(-parent.AbsoluteSize.Y/2, parent.AbsoluteSize.Y/2)
                )
                
                Utility:Tween(
                    particle, 
                    {Position = randomPos, BackgroundTransparency = math.random(0.5, 0.9)}, 
                    math.random(3, 8), 
                    Enum.EasingStyle.Sine, 
                    Enum.EasingDirection.InOut
                )
                
                wait(math.random(2, 5))
            end
        end)
        
        table.insert(particles, particle)
    end
    
    return particles
end

function Utility:Dragify(frame, dragSpeed)
    dragSpeed = dragSpeed or 0.1
    local dragToggle, dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Utility:Tween(frame, {Position = position}, dragSpeed)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

function Utility:Encrypt(data)
    if type(data) ~= "string" then
        data = HttpService:JSONEncode(data)
    end
    
    local encrypted = ""
    local key = ProfessionalUI.Config.KeySystem.EncryptionKey
    
    for i = 1, #data do
        local keyChar = string.byte(key, (i % #key) + 1)
        local dataChar = string.byte(data, i)
        local encryptedChar = bit32.bxor(dataChar, keyChar)
        encrypted = encrypted .. string.char(encryptedChar)
    end
    
    return encrypted
end

function Utility:Decrypt(data)
    local decrypted = ""
    local key = ProfessionalUI.Config.KeySystem.EncryptionKey
    
    for i = 1, #data do
        local keyChar = string.byte(key, (i % #key) + 1)
        local dataChar = string.byte(data, i)
        local decryptedChar = bit32.bxor(dataChar, keyChar)
        decrypted = decrypted .. string.char(decryptedChar)
    end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(decrypted)
    end)
    
    if success then
        return result
    else
        return decrypted
    end
end

function Utility:GetHWID()
    local hwid = {}
    
    -- Collect various identifying information
    table.insert(hwid, game:GetService("RbxAnalyticsService"):GetClientId())
    table.insert(hwid, LocalPlayer.UserId)
    table.insert(hwid, GuiService:GetDeviceId())
    
    -- Hash the combined data
    local combinedData = table.concat(hwid, "-")
    local hashedData = ""
    
    -- Simple hashing algorithm
    for i = 1, #combinedData do
        hashedData = hashedData .. string.char(bit32.bxor(string.byte(combinedData, i), 170))
    end
    
    return hashedData
end

function Utility:SaveSetting(name, value, encrypt)
    if encrypt then
        value = Utility:Encrypt(value)
    end
    
    if not pcall(function()
        if not isfolder("ProfessionalUI") then
            makefolder("ProfessionalUI")
        end
        writefile("ProfessionalUI/" .. name .. ".json", HttpService:JSONEncode(value))
    end) then
        warn("Failed to save setting: " .. name)
    end
end

function Utility:LoadSetting(name, decrypt)
    local success, result = pcall(function()
        if isfile("ProfessionalUI/" .. name .. ".json") then
            local data = HttpService:JSONDecode(readfile("ProfessionalUI/" .. name .. ".json"))
            if decrypt then
                data = Utility:Decrypt(data)
            end
            return data
        end
        return nil
    end)
    
    if success then
        return result
    else
        warn("Failed to load setting: " .. name)
        return nil
    end
end

-- Advanced Key System
local KeySystem = {}

function KeySystem:SetKeys(keys)
    if type(keys) == "string" then
        ProfessionalUI.Config.KeySystem.Keys = {keys}
    elseif type(keys) == "table" then
        ProfessionalUI.Config.KeySystem.Keys = keys
    else
        error("Keys must be a string or table")
    end
end

function KeySystem:AddKey(key, expiration, hwid)
    if type(key) ~= "string" then
        error("Key must be a string")
    end
    
    local keyData = {
        Key = key,
        Expiration = expiration, -- timestamp or nil for never
        HWID = hwid -- specific HWID or nil for any
    }
    
    table.insert(ProfessionalUI.Config.KeySystem.Keys, keyData)
end

function KeySystem:VerifyKey(key)
    -- Check if key is a simple string
    if type(key) == "string" then
        for _, validKey in ipairs(ProfessionalUI.Config.KeySystem.Keys) do
            if type(validKey) == "string" and key == validKey then
                if ProfessionalUI.Config.KeySystem.SaveKey then
                    Utility:SaveSetting("key", {
                        Key = key,
                        HWID = ProfessionalUI.Config.KeySystem.CheckHWID and Utility:GetHWID() or nil,
                        Timestamp = os.time()
                    }, true)
                end
                return true
            end
        end
    end
    
    -- Check if key is in the advanced key format
    for _, validKey in ipairs(ProfessionalUI.Config.KeySystem.Keys) do
        if type(validKey) == "table" then
            if key == validKey.Key then
                -- Check expiration
                if ProfessionalUI.Config.KeySystem.KeyExpiration and validKey.Expiration and os.time() > validKey.Expiration then
                    return false, "Key expired"
                end
                
                -- Check HWID
                if ProfessionalUI.Config.KeySystem.CheckHWID and validKey.HWID and validKey.HWID ~= Utility:GetHWID() then
                    return false, "HWID mismatch"
                end
                
                if ProfessionalUI.Config.KeySystem.SaveKey then
                    Utility:SaveSetting("key", {
                        Key = key,
                        HWID = ProfessionalUI.Config.KeySystem.CheckHWID and Utility:GetHWID() or nil,
                        Timestamp = os.time()
                    }, true)
                end
                
                return true
            end
        end
    end
    
    -- Server verification (simulated)
    if ProfessionalUI.Config.KeySystem.ServerCheck then
        -- Simulate server check with a delay
        wait(1)
        for _, validKey in ipairs(ProfessionalUI.Config.KeySystem.Keys) do
            if (type(validKey) == "string" and key == validKey) or 
               (type(validKey) == "table" and key == validKey.Key) then
                return true
            end
        end
    end
    
    return false
end

function KeySystem:GetSavedKey()
    local savedKeyData = Utility:LoadSetting("key", true)
    if not savedKeyData then return nil end
    
    -- Check HWID if enabled
    if ProfessionalUI.Config.KeySystem.CheckHWID and savedKeyData.HWID and savedKeyData.HWID ~= Utility:GetHWID() then
        return nil
    end
    
    return savedKeyData.Key
end

function KeySystem:StartTrial(callback)
    if not ProfessionalUI.Config.KeySystem.AllowTrial then
        callback(false)
        return
    end
    
    local trialData = Utility:LoadSetting("trial")
    if trialData and trialData.Used then
        callback(false, "Trial already used")
        return
    end
    
    -- Save trial data
    Utility:SaveSetting("trial", {
        Used = true,
        StartTime = os.time(),
        EndTime = os.time() + ProfessionalUI.Config.KeySystem.TrialTime
    })
    
    -- Start trial countdown
    local timeLeft = ProfessionalUI.Config.KeySystem.TrialTime
    local trialConnection
    
    trialConnection = RunService.Heartbeat:Connect(function()
        timeLeft = timeLeft - RunService.Heartbeat:Wait()
        
        if timeLeft <= 0 then
            trialConnection:Disconnect()
            callback(false, "Trial expired")
        end
    end)
    
    callback(true, timeLeft)
    
    return function()
        if trialConnection then
            trialConnection:Disconnect()
        end
    end
end

function KeySystem:Prompt(callback)
    if not ProfessionalUI.Config.KeySystem.Enabled then
        callback(true)
        return
    end
    
    local savedKey = self:GetSavedKey()
    if savedKey and self:VerifyKey(savedKey) then
        callback(true)
        return
    end
    
    local attempts = ProfessionalUI.Config.KeySystem.Attempts
    local blur = Utility:CreateBlur()
    
    -- Create key system UI
    local keyWindow = Utility:Create("ScreenGui", {
        Name = "KeySystem",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local mainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -200, 0.5, -150),
        Size = UDim2.new(0, 400, 0, 300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = keyWindow
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = mainFrame
    })
    
    -- Create gradient background
    Utility:CreateGradient(mainFrame, 135)
    
    -- Create glow effect
    Utility:CreateGlow(mainFrame, ProfessionalUI.Config.Theme.Glow, 50)
    
    -- Create particles
    Utility:CreateParticles(mainFrame, 15)
    
    -- Create top design element
    local topDesign = Utility:Create("Frame", {
        Name = "TopDesign",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = mainFrame
    })
    
    local topDesignCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = topDesign
    })
    
    local topDesignGradient = Utility:CreateGradient(topDesign, 90, 
        ProfessionalUI.Config.Theme.Accent1, 
        ProfessionalUI.Config.Theme.Accent2
    )
    
    -- Create logo
    local logoContainer = Utility:Create("Frame", {
        Name = "LogoContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 30),
        Size = UDim2.new(0, 80, 0, 80),
        AnchorPoint = Vector2.new(0.5, 0),
        Parent = mainFrame
    })
    
    local logoBackground = Utility:Create("Frame", {
        Name = "LogoBackground",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = logoContainer
    })
    
    local logoBackgroundCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0.5, 0),
        Parent = logoBackground
    })
    
    local logoGradient = Utility:CreateGradient(logoBackground, 45)
    
    local logoText = Utility:Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "PUI",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 30,
        Parent = logoContainer
    })
    
    local logoGlow = Utility:CreateGlow(logoContainer)
    
        -- Create title
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 120),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "PROFESSIONAL UI v3",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 22,
        Parent = mainFrame
    })
    
    local subtitle = Utility:Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 150),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Please enter your key to continue",
        TextColor3 = ProfessionalUI.Config.Theme.TextDark,
        TextSize = 14,
        Parent = mainFrame
    })
    
    -- Create key input
    local keyBox = Utility:Create("TextBox", {
        Name = "KeyBox",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -150, 0, 180),
        Size = UDim2.new(0, 300, 0, 40),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter key here...",
        Text = "",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 14,
        ClearTextOnFocus = false,
        Parent = mainFrame
    })
    
    local keyBoxCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = keyBox
    })
    
    local keyBoxGradient = Utility:CreateGradient(keyBox, 180, 
        Color3.fromRGB(40, 40, 50), 
        Color3.fromRGB(30, 30, 40)
    )
    
    -- Create submit button
    local submitButton = Utility:Create("TextButton", {
        Name = "SubmitButton",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -75, 0, 235),
        Size = UDim2.new(0, 150, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "SUBMIT",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = mainFrame
    })
    
    local submitButtonCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = submitButton
    })
    
    local submitButtonGradient = Utility:CreateGradient(submitButton, 90, 
        ProfessionalUI.Config.Theme.Accent1, 
        ProfessionalUI.Config.Theme.Accent2
    )
    
    -- Create trial button
    local trialButton = Utility:Create("TextButton", {
        Name = "TrialButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, -30),
        Size = UDim2.new(0, 150, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0),
        Font = Enum.Font.Gotham,
        Text = "Start Free Trial",
        TextColor3 = ProfessionalUI.Config.Theme.TextDark,
        TextSize = 14,
        Visible = ProfessionalUI.Config.KeySystem.AllowTrial,
        Parent = mainFrame
    })
    
    -- Create attempts label
    local attemptsLabel = Utility:Create("TextLabel", {
        Name = "AttemptsLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 1, -30),
        Size = UDim2.new(0, 150, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Attempts: " .. attempts,
        TextColor3 = ProfessionalUI.Config.Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = mainFrame
    })
    
    -- Create version label
    local versionLabel = Utility:Create("TextLabel", {
        Name = "VersionLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -30),
        Size = UDim2.new(0, 150, 0, 20),
        AnchorPoint = Vector2.new(1, 0),
        Font = Enum.Font.Gotham,
        Text = "v" .. ProfessionalUI.Version,
        TextColor3 = ProfessionalUI.Config.Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = mainFrame
    })
    
    -- Make window draggable
    Utility:Dragify(mainFrame)
    
    -- Button hover effects
    submitButton.MouseEnter:Connect(function()
        Utility:Tween(submitButton, {BackgroundColor3 = Color3.fromRGB(100, 130, 255)}, 0.2)
    end)
    
    submitButton.MouseLeave:Connect(function()
        Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1}, 0.2)
    end)
    
    trialButton.MouseEnter:Connect(function()
        Utility:Tween(trialButton, {TextColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
    end)
    
    trialButton.MouseLeave:Connect(function()
        Utility:Tween(trialButton, {TextColor3 = ProfessionalUI.Config.Theme.TextDark}, 0.2)
    end)
    
    -- Submit button functionality
    submitButton.MouseButton1Click:Connect(function()
        Utility:Ripple(submitButton)
        Utility:PlaySound("rbxassetid://6042583087")
        
        local key = keyBox.Text
        local success, message = self:VerifyKey(key)
        
        if success then
            -- Success animation
            Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Success}, 0.2)
            submitButton.Text = "SUCCESS!"
            
            -- Create success particles
            Utility:CreateParticles(mainFrame, 30, {ProfessionalUI.Config.Theme.Success})
            
            -- Play success sound
            Utility:PlaySound("rbxassetid://6042583087")
            
            task.delay(1, function()
                -- Slide out animation
                Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -200, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                
                task.delay(0.5, function()
                    Utility:RemoveBlur(blur)
                    keyWindow:Destroy()
                    callback(true)
                end)
            end)
        else
            -- Error animation
            Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Error}, 0.2)
            submitButton.Text = message or "INVALID KEY"
            
            -- Shake animation
            local originalPosition = mainFrame.Position
            for i = 1, 5 do
                Utility:Tween(mainFrame, {Position = originalPosition + UDim2.new(0, math.random(-10, 10), 0, 0)}, 0.05)
                wait(0.05)
            end
            Utility:Tween(mainFrame, {Position = originalPosition}, 0.1)
            
            -- Play error sound
            Utility:PlaySound("rbxassetid://6042583087")
            
            -- Update attempts
            attempts = attempts - 1
            attemptsLabel.Text = "Attempts: " .. attempts
            keyBox.Text = ""
            
            task.delay(1, function()
                Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1}, 0.2)
                submitButton.Text = "SUBMIT"
            end)
            
            if attempts <= 0 then
                task.delay(1, function()
                    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -200, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    
                    task.delay(0.5, function()
                        Utility:RemoveBlur(blur)
                        keyWindow:Destroy()
                        callback(false)
                    end)
                end)
            end
        end
    end)
    
    -- Trial button functionality
    trialButton.MouseButton1Click:Connect(function()
        Utility:Ripple(trialButton)
        Utility:PlaySound("rbxassetid://6042583087")
        
        -- Disable trial button
        trialButton.Text = "Starting trial..."
        trialButton.Active = false
        Utility:Tween(trialButton, {TextTransparency = 0.5}, 0.2)
        
        -- Start trial
        self:StartTrial(function(success, timeOrMessage)
            if success then
                -- Success animation
                Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Success}, 0.2)
                submitButton.Text = "TRIAL STARTED"
                
                -- Create success particles
                Utility:CreateParticles(mainFrame, 30, {ProfessionalUI.Config.Theme.Success})
                
                -- Play success sound
                Utility:PlaySound("rbxassetid://6042583087")
                
                task.delay(1, function()
                    -- Slide out animation
                    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -200, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    
                    task.delay(0.5, function()
                        Utility:RemoveBlur(blur)
                        keyWindow:Destroy()
                        callback(true, timeOrMessage)
                    end)
                end)
            else
                -- Error animation
                trialButton.Text = timeOrMessage or "Trial unavailable"
                Utility:Tween(trialButton, {TextColor3 = ProfessionalUI.Config.Theme.Error}, 0.2)
                
                -- Play error sound
                Utility:PlaySound("rbxassetid://6042583087")
                
                task.delay(2, function()
                    Utility:Tween(trialButton, {TextColor3 = ProfessionalUI.Config.Theme.TextDark}, 0.2)
                    trialButton.Text = "Start Free Trial"
                    trialButton.Active = true
                    Utility:Tween(trialButton, {TextTransparency = 0}, 0.2)
                end)
            end
        end)
    end)
    
    -- Initial animation
    mainFrame.Position = UDim2.new(0.5, -200, -0.5, 0)
    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -200, 0.5, -150)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Rotate logo
    spawn(function()
        while mainFrame and mainFrame.Parent do
            Utility:Tween(logoText, {Rotation = 5}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(2)
            Utility:Tween(logoText, {Rotation = -5}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(2)
        end
    end)
    
    -- Pulse glow effect
    spawn(function()
        while mainFrame and mainFrame.Parent do
            Utility:Tween(logoGlow, {ImageTransparency = 0.7}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1.5)
            Utility:Tween(logoGlow, {ImageTransparency = 0.3}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1.5)
        end
    end)
end

-- UI Components
local Components = {}

function Components:CreateWindow(title)
    local window = {}
    
    -- Create blur effect
    local blur = Utility:CreateBlur()
    
    -- Create main GUI
    local screenGui = Utility:Create("ScreenGui", {
        Name = "ProfessionalUI_v3",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local mainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        Parent = screenGui
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = mainFrame
    })
    
    -- Create gradient background
    Utility:CreateGradient(mainFrame, 135)
    
    -- Create glow effect
    Utility:CreateGlow(mainFrame, ProfessionalUI.Config.Theme.Glow, 50)
    
    -- Create particles
    Utility:CreateParticles(mainFrame, 20)
    
    -- Create top design element
    local topDesign = Utility:Create("Frame", {
        Name = "TopDesign",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = mainFrame
    })
    
    local topDesignCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = topDesign
    })
    
    local topDesignGradient = Utility:CreateGradient(topDesign, 90, 
        ProfessionalUI.Config.Theme.Accent1, 
        ProfessionalUI.Config.Theme.Accent2
    )
    
    -- Create top bar
    local topBar = Utility:Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 0, 50),
        Parent = mainFrame
    })
    
    local topBarCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = topBar
    })
    
    local topBarGradient = Utility:CreateGradient(topBar, 180, 
        Color3.fromRGB(40, 40, 50), 
        Color3.fromRGB(35, 35, 45)
    )
    
    -- Create logo
    local logoContainer = Utility:Create("Frame", {
        Name = "LogoContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 50, 0, 50),
        Parent = topBar
    })
    
    local logoBackground = Utility:Create("Frame", {
        Name = "LogoBackground",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 40),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = logoContainer
    })
    
    local logoBackgroundCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0.5, 0),
        Parent = logoBackground
    })
    
    local logoGradient = Utility:CreateGradient(logoBackground, 45)
    
    local logoText = Utility:Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "P",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 22,
        Parent = logoBackground
    })
    
    -- Create title
    local titleLabel = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "Professional UI v3",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    
    -- Create window controls
    local controlsContainer = Utility:Create("Frame", {
        Name = "ControlsContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -120, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Parent = topBar
    })
    
    local minimizeButton = Utility:Create("TextButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 24,
        Parent = controlsContainer
    })
    
    local closeButton = Utility:Create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 24,
        Parent = controlsContainer
    })

    -- Create content area
    local contentArea = Utility:Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 75),
        Size = UDim2.new(1, -30, 1, -90),
        Parent = mainFrame
    })
    
    -- Create sidebar
    local sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 180, 1, 0),
        Parent = contentArea
    })
    
    local sidebarCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = sidebar
    })
    
    local sidebarGradient = Utility:CreateGradient(sidebar, 180, 
        Color3.fromRGB(40, 40, 50), 
        Color3.fromRGB(35, 35, 45)
    )
    
    -- Create tab container
    local tabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        Active = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = ProfessionalUI.Config.Theme.Accent1,
        Parent = sidebar
    })
    
    local tabListLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContainer
    })
    
    local tabListPadding = Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tabContainer
    })
    
    -- Update canvas size when elements are added
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Create content container
    local contentContainer = Utility:Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 190, 0, 0),
        Size = UDim2.new(1, -190, 1, 0),
        Parent = contentArea
    })
    
    -- Make window draggable
    Utility:Dragify(mainFrame)
    
    -- Close button functionality
    closeButton.MouseEnter:Connect(function()
        Utility:Tween(closeButton, {TextColor3 = ProfessionalUI.Config.Theme.Error}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utility:Tween(closeButton, {TextColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        Utility:Ripple(closeButton)
        Utility:PlaySound("rbxassetid://6042583087")
        
        Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -400, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.delay(0.5, function()
            Utility:RemoveBlur(blur)
            screenGui:Destroy()
        end)
    end)
    
    -- Minimize button functionality
    local minimized = false
    local originalSize = mainFrame.Size
    local originalPosition = mainFrame.Position
    
    minimizeButton.MouseEnter:Connect(function()
        Utility:Tween(minimizeButton, {TextColor3 = ProfessionalUI.Config.Theme.Accent1}, 0.2)
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        Utility:Tween(minimizeButton, {TextColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        Utility:Ripple(minimizeButton)
        Utility:PlaySound("rbxassetid://6042583087")
        
        minimized = not minimized
        
        if minimized then
            Utility:Tween(mainFrame, {
                Size = UDim2.new(0, 800, 0, 60),
                Position = UDim2.new(0.5, -400, 1, -60)
            }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            
            contentArea.Visible = false
        else
            Utility:Tween(mainFrame, {
                Size = originalSize,
                Position = originalPosition
            }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            contentArea.Visible = true
        end
    end)
    
    -- Tab functionality
    local tabs = {}
    local selectedTab = nil
    
    function window:AddTab(name, icon)
        local tab = {}
        
        -- Create tab button
        local tabButton = Utility:Create("Frame", {
            Name = name .. "Tab",
            BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(0.9, 0, 0, 45),
            Parent = tabContainer
        })
        
        local tabButtonCorner = Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = tabButton
        })
        
        -- Create selection indicator
        local selectionIndicator = Utility:Create("Frame", {
            Name = "SelectionIndicator",
            BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0.7, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Visible = false,
            Parent = tabButton
        })
        
        local selectionIndicatorCorner = Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = selectionIndicator
        })
        
        local selectionIndicatorGradient = Utility:CreateGradient(selectionIndicator, 0, 
            ProfessionalUI.Config.Theme.Accent1, 
            ProfessionalUI.Config.Theme.Accent2
        )
        
        -- Create tab button content
        local tabButtonContent = Utility:Create("TextButton", {
            Name = "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = ProfessionalUI.Config.Theme.Text,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = tabButton
        })
        
        local iconImage
        if icon then
            iconImage = Utility:Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = icon,
                ImageColor3 = ProfessionalUI.Config.Theme.TextDark,
                Parent = tabButtonContent
            })
            
            local tabText = Utility:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 45, 0, 0),
                Size = UDim2.new(1, -55, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = name,
                TextColor3 = ProfessionalUI.Config.Theme.TextDark,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabButtonContent
            })
            
            tab.TabText = tabText
            tab.IconImage = iconImage
        else
            local tabText = Utility:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -25, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = name,
                TextColor3 = ProfessionalUI.Config.Theme.TextDark,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabButtonContent
            })
            
            tab.TabText = tabText
        end
        
        -- Create tab content
        local tabContent = Utility:Create("ScrollingFrame", {
            Name = name .. "Content",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ProfessionalUI.Config.Theme.Accent1,
            Visible = false,
            Parent = contentContainer
        })
        
        local contentLayout = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })
        
        local contentPadding = Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent
        })
        
        -- Update canvas size when elements are added
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab button functionality
        tabButtonContent.MouseEnter:Connect(function()
            if selectedTab ~= tab then
                Utility:Tween(tabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2)
                
                if tab.TabText then
                    Utility:Tween(tab.TabText, {TextColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
                end
                
                if tab.IconImage then
                    Utility:Tween(tab.IconImage, {ImageColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
                end
            end
        end)
        
        tabButtonContent.MouseLeave:Connect(function()
            if selectedTab ~= tab then
                Utility:Tween(tabButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Primary}, 0.2)
                
                if tab.TabText then
                    Utility:Tween(tab.TabText, {TextColor3 = ProfessionalUI.Config.Theme.TextDark}, 0.2)
                end
                
                if tab.IconImage then
                    Utility:Tween(tab.IconImage, {ImageColor3 = ProfessionalUI.Config.Theme.TextDark}, 0.2)
                end
            end
        end)
        
        tabButtonContent.MouseButton1Click:Connect(function()
            Utility:Ripple(tabButton)
            Utility:PlaySound("rbxassetid://6042583087")
            window:SelectTab(tab)
        end)
        
        -- Tab functions
        function tab:AddSection(sectionName)
            local section = {}
            
            local sectionFrame = Utility:Create("Frame", {
                Name = sectionName .. "Section",
                BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(0.95, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = tabContent
            })
            
            local sectionCorner = Utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 10),
                Parent = sectionFrame
            })
            
            local sectionGradient = Utility:CreateGradient(sectionFrame, 180, 
                Color3.fromRGB(40, 40, 50), 
                Color3.fromRGB(35, 35, 45)
            )
            
            -- Create section header
            local sectionHeader = Utility:Create("Frame", {
                Name = "Header",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = sectionFrame
            })
            
            local sectionTitle = Utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -15, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = ProfessionalUI.Config.Theme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionHeader
            })
            
            -- Create section accent
            local sectionAccent = Utility:Create("Frame", {
                Name = "Accent",
                BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 5, 0, 40),
                Parent = sectionHeader
            })
            
            local sectionAccentCorner = Utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 10),
                Parent = sectionAccent
            })
            
            local sectionAccentGradient = Utility:CreateGradient(sectionAccent, 0, 
                ProfessionalUI.Config.Theme.Accent1, 
                ProfessionalUI.Config.Theme.Accent2
            )
            
            -- Create section content
            local sectionContent = Utility:Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = sectionFrame
            })
            
            local sectionLayout = Utility:Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = sectionContent
            })
            
            local sectionPadding = Utility:Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 15),
                Parent = sectionContent
            })
            
            -- Section functions
            function section:AddButton(buttonText, callback)
                local buttonContainer = Utility:Create("Frame", {
                    Name = buttonText .. "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Parent = sectionContent
                })
                
                local button = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = buttonText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                    Parent = buttonContainer
                })
                
                local buttonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = button
                })
                
                local buttonGradient = Utility:CreateGradient(button, 90, 
                    ProfessionalUI.Config.Theme.Primary, 
                    Color3.fromRGB(35, 35, 45)
                )
                
                button.MouseEnter:Connect(function()
                    Utility:Tween(button, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.2)
                end)
                
                button.MouseLeave:Connect(function()
                    Utility:Tween(button, {BackgroundColor3 = ProfessionalUI.Config.Theme.Primary}, 0.2)
                end)
                
                button.MouseButton1Click:Connect(function()
                    Utility:Ripple(button)
                    Utility:PlaySound("rbxassetid://6042583087")
                    
                    if callback then callback() end
                end)
                
                return button
            end
            
            function section:AddToggle(toggleText, default, callback)
                local toggled = default or false
                
                local toggleContainer = Utility:Create("Frame", {
                    Name = toggleText .. "Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Parent = sectionContent
                })
                
                local toggleBackground = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = toggleContainer
                })
                
                local toggleBackgroundCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = toggleBackground
                })
                
                local toggleLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -65, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleBackground
                })
                
                local toggleButton = Utility:Create("Frame", {
                    Name = "ToggleButton",
                    BackgroundColor3 = toggled and ProfessionalUI.Config.Theme.Accent1 or Color3.fromRGB(60, 60, 70),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Parent = toggleBackground
                })
                
                local toggleButtonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleButton
                })
                
                local toggleButtonGradient
                if toggled then
                    toggleButtonGradient = Utility:CreateGradient(toggleButton, 90, 
                        ProfessionalUI.Config.Theme.Accent1, 
                        ProfessionalUI.Config.Theme.Accent2
                    )
                end
                
                local toggleCircle = Utility:Create("Frame", {
                    Name = "Circle",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(toggled and 1 or 0, toggled and -18 or 2, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Parent = toggleButton
                })
                
                local toggleCircleCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleCircle
                })
                
                local toggleHitbox = Utility:Create("TextButton", {
                    Name = "Hitbox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = toggleBackground
                })

                local function updateToggle()
                    if toggled then
                        Utility:Tween(toggleButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1}, 0.2)
                        Utility:Tween(toggleCircle, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.2)
                        
                        if not toggleButtonGradient then
                            toggleButtonGradient = Utility:CreateGradient(toggleButton, 90, 
                                ProfessionalUI.Config.Theme.Accent1, 
                                ProfessionalUI.Config.Theme.Accent2
                            )
                        end
                    else
                        Utility:Tween(toggleButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.2)
                        Utility:Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                        
                        if toggleButtonGradient then
                            toggleButtonGradient:Destroy()
                            toggleButtonGradient = nil
                        end
                    end
                    
                    if callback then callback(toggled) end
                end
                
                toggleHitbox.MouseButton1Click:Connect(function()
                    Utility:Ripple(toggleBackground)
                    Utility:PlaySound("rbxassetid://6042583087")
                    
                    toggled = not toggled
                    updateToggle()
                end)
                
                return {
                    Set = function(value)
                        toggled = value
                        updateToggle()
                    end,
                    Get = function()
                        return toggled
                    end
                }
            end
            
            function section:AddSlider(sliderText, min, max, default, callback)
                local sliderValue = default or min
                
                local sliderContainer = Utility:Create("Frame", {
                    Name = sliderText .. "Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 55),
                    Parent = sectionContent
                })
                
                local sliderBackground = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = sliderContainer
                })
                
                local sliderBackgroundCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = sliderBackground
                })
                
                local sliderLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 5),
                    Size = UDim2.new(1, -65, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sliderText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderBackground
                })
                
                local valueLabel = Utility:Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 5),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.GothamSemibold,
                    Text = tostring(sliderValue),
                    TextColor3 = ProfessionalUI.Config.Theme.Accent1,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderBackground
                })
                
                local sliderTrack = Utility:Create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 0, 35),
                    Size = UDim2.new(1, -30, 0, 6),
                    Parent = sliderBackground
                })
                
                local sliderTrackCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderTrack
                })
                
                local sliderFill = Utility:Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Accent1,
                    BorderSizePixel = 0,
                    Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0),
                    Parent = sliderTrack
                })
                
                local sliderFillCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderFill
                })
                
                local sliderFillGradient = Utility:CreateGradient(sliderFill, 90, 
                    ProfessionalUI.Config.Theme.Accent1, 
                    ProfessionalUI.Config.Theme.Accent2
                )
                
                local sliderThumb = Utility:Create("Frame", {
                    Name = "Thumb",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new((sliderValue - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex = 2,
                    Parent = sliderTrack
                })
                
                local sliderThumbCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderThumb
                })
                
                local sliderHitbox = Utility:Create("TextButton", {
                    Name = "Hitbox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = sliderBackground
                })
                
                local function updateSlider(value)
                    value = math.clamp(value, min, max)
                    value = math.floor(value + 0.5) -- Round to nearest integer
                    
                    sliderValue = value
                    valueLabel.Text = tostring(value)
                    
                    local percent = (value - min) / (max - min)
                    Utility:Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    Utility:Tween(sliderThumb, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.1)
                    
                    if callback then callback(value) end
                end
                
                sliderHitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local connection
                        
                        connection = RunService.RenderStepped:Connect(function()
                            local mousePos = UserInputService:GetMouseLocation()
                            local relativePos = mousePos.X - sliderTrack.AbsolutePosition.X
                            local percent = math.clamp(relativePos / sliderTrack.AbsoluteSize.X, 0, 1)
                            local value = min + (max - min) * percent
                            
                            updateSlider(value)
                        end)
                        
                        UserInputService.InputEnded:Connect(function(endedInput)
                            if endedInput.UserInputType == Enum.UserInputType.MouseButton1 then
                                if connection then
                                    connection:Disconnect()
                                end
                            end
                        end)
                    end
                end)
                
                return {
                    Set = function(value)
                        updateSlider(value)
                    end,
                    Get = function()
                        return sliderValue
                    end
                }
            end
            
            function section:AddDropdown(dropdownText, options, default, callback)
                local dropdown = {}
                local selected = default or options[1] or ""
                local open = false
                
                local dropdownContainer = Utility:Create("Frame", {
                    Name = dropdownText .. "Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    ClipsDescendants = true,
                    Parent = sectionContent
                })
                
                local dropdownBackground = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = dropdownContainer
                })
                
                local dropdownBackgroundCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = dropdownBackground
                })
                
                local dropdownLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -15, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = dropdownText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownBackground
                })
                
                local dropdownButton = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 0, 40),
                    Size = UDim2.new(1, -30, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = selected,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                    Parent = dropdownContainer
                })
                
                local dropdownButtonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = dropdownButton
                })
                
                local dropdownIcon = Utility:Create("ImageLabel", {
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0.5, 0),
                    Size = UDim2.new(0, 15, 0, 15),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = ProfessionalUI.Config.Theme.Text,
                    Parent = dropdownButton
                })
                
                local optionContainer = Utility:Create("Frame", {
                    Name = "OptionContainer",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 0, 80),
                    Size = UDim2.new(1, -30, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = dropdownContainer
                })
                
                local optionContainerCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = optionContainer
                })
                
                local optionList = Utility:Create("ScrollingFrame", {
                    Name = "OptionList",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = ProfessionalUI.Config.Theme.Accent1,
                    Parent = optionContainer
                })
                
                local optionListLayout = Utility:Create("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = optionList
                })
                
                local optionListPadding = Utility:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = optionList
                })
                
                -- Update canvas size when elements are added
                optionListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    optionList.CanvasSize = UDim2.new(0, 0, 0, optionListLayout.AbsoluteContentSize.Y + 10)
                end)
                
                -- Create option buttons
                for i, option in ipairs(options) do
                    local optionButton = Utility:Create("TextButton", {
                        Name = option .. "Option",
                        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.9, 0, 0, 30),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = ProfessionalUI.Config.Theme.Text,
                        TextSize = 14,
                        AutoButtonColor = false,
                        Parent = optionList
                    })
                    
                    local optionButtonCorner = Utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = optionButton
                    })
                    
                    optionButton.MouseEnter:Connect(function()
                        Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}, 0.2)
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.2)
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        Utility:Ripple(optionButton)
                        Utility:PlaySound("rbxassetid://6042583087")
                        
                        selected = option
                        dropdownButton.Text = selected
                        
                        if callback then callback(selected) end
                        
                        dropdown:Toggle()
                    end)
                end
                
                -- Dropdown functions
                function dropdown:Toggle()
                    open = not open
                    
                    if open then
                        dropdownContainer.Size = UDim2.new(0.9, 0, 0, 35 + 45 + math.min(#options * 35, 150))
                        optionContainer.Size = UDim2.new(1, -30, 0, math.min(#options * 35, 150))
                        optionContainer.Visible = true
                        Utility:Tween(dropdownIcon, {Rotation = 180}, 0.2)
                    else
                        Utility:Tween(dropdownIcon, {Rotation = 0}, 0.2)
                        Utility:Tween(dropdownContainer, {Size = UDim2.new(0.9, 0, 0, 80)}, 0.2)
                        task.delay(0.2, function()
                            optionContainer.Visible = false
                        end)
                    end
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    Utility:Ripple(dropdownButton)
                    Utility:PlaySound("rbxassetid://6042583087")
                    dropdown:Toggle()
                end)
                
                function dropdown:Set(option)
                    if table.find(options, option) then
                        selected = option
                        dropdownButton.Text = selected
                        
                        if callback then callback(selected) end
                    end
                end

                function dropdown:Get()
                    return selected
                end
                
                function dropdown:Refresh(newOptions, keepSelection)
                    options = newOptions
                    
                    -- Clear existing options
                    for _, child in ipairs(optionList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create new option buttons
                    for i, option in ipairs(options) do
                        local optionButton = Utility:Create("TextButton", {
                            Name = option .. "Option",
                            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                            BorderSizePixel = 0,
                            Size = UDim2.new(0.9, 0, 0, 30),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = ProfessionalUI.Config.Theme.Text,
                            TextSize = 14,
                            AutoButtonColor = false,
                            Parent = optionList
                        })
                        
                        local optionButtonCorner = Utility:Create("UICorner", {
                            CornerRadius = UDim.new(0, 6),
                            Parent = optionButton
                        })
                        
                        optionButton.MouseEnter:Connect(function()
                            Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}, 0.2)
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.2)
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            Utility:Ripple(optionButton)
                            Utility:PlaySound("rbxassetid://6042583087")
                            
                            selected = option
                            dropdownButton.Text = selected
                            
                            if callback then callback(selected) end
                            
                            dropdown:Toggle()
                        end)
                    end
                    
                    -- Update selection
                    if not keepSelection or not table.find(options, selected) then
                        selected = options[1] or ""
                        dropdownButton.Text = selected
                    end
                end
                
                return dropdown
            end
            
            function section:AddTextbox(boxText, placeholder, default, callback)
                local textboxContainer = Utility:Create("Frame", {
                    Name = boxText .. "Textbox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 70),
                    Parent = sectionContent
                })
                
                local textboxBackground = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = textboxContainer
                })
                
                local textboxBackgroundCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = textboxBackground
                })
                
                local textboxLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 5),
                    Size = UDim2.new(1, -15, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = boxText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxBackground
                })
                
                local textbox = Utility:Create("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 0, 30),
                    Size = UDim2.new(1, -30, 0, 35),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder or "Enter text...",
                    Text = default or "",
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    ClearTextOnFocus = false,
                    Parent = textboxBackground
                })
                
                local textboxCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = textbox
                })
                
                textbox.Focused:Connect(function()
                    Utility:Tween(textbox, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.2)
                end)
                
                textbox.FocusLost:Connect(function(enterPressed)
                    Utility:Tween(textbox, {BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary}, 0.2)
                    if callback then callback(textbox.Text, enterPressed) end
                end)
                
                return {
                    Set = function(value)
                        textbox.Text = value
                        if callback then callback(value, false) end
                    end,
                    Get = function()
                        return textbox.Text
                    end
                }
            end
            
            function section:AddKeybind(bindText, default, callback, changedCallback)
                local keybindContainer = Utility:Create("Frame", {
                    Name = bindText .. "Keybind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Parent = sectionContent
                })
                
                local keybindBackground = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = keybindContainer
                })
                
                local keybindBackgroundCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = keybindBackground
                })
                
                local keybindLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -95, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = bindText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindBackground
                })
                
                local keybindButton = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -80, 0.5, 0),
                    Size = UDim2.new(0, 70, 0, 25),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font = Enum.Font.GothamSemibold,
                    Text = default and default.Name or "None",
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = keybindBackground
                })
                
                local keybindButtonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybindButton
                })
                
                local currentKey = default
                local keyChanging = false
                
                keybindButton.MouseEnter:Connect(function()
                    Utility:Tween(keybindButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.2)
                end)
                
                keybindButton.MouseLeave:Connect(function()
                    Utility:Tween(keybindButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary}, 0.2)
                end)
                
                keybindButton.MouseButton1Click:Connect(function()
                    Utility:Ripple(keybindButton)
                    Utility:PlaySound("rbxassetid://6042583087")
                    
                    if keyChanging then return end
                    
                    keyChanging = true
                    keybindButton.Text = "..."
                    
                    local inputConnection
                    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            inputConnection:Disconnect()
                            
                            currentKey = input.KeyCode
                            keybindButton.Text = input.KeyCode.Name
                            keyChanging = false
                            
                            if changedCallback then changedCallback(currentKey) end
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if callback then callback() end
                    end
                end)
                
                return {
                    Set = function(key)
                        currentKey = key
                        keybindButton.Text = key.Name
                        
                        if changedCallback then changedCallback(currentKey) end
                    end,
                    Get = function()
                        return currentKey
                    end
                }
            end
            
            return section
        end
        
        tab.Button = tabButton
        tab.Content = tabContent
        tab.SelectionIndicator = selectionIndicator
        
        table.insert(tabs, tab)
        
        -- Select first tab by default
        if #tabs == 1 then
            window:SelectTab(tab)
        end
        
        return tab
    end
    
    function window:SelectTab(tab)
        if selectedTab == tab then return end
        
        -- Hide all tabs
        for _, t in ipairs(tabs) do
            if t ~= tab then
                Utility:Tween(t.Button, {BackgroundColor3 = ProfessionalUI.Config.Theme.Primary}, 0.2)
                t.Content.Visible = false
                t.SelectionIndicator.Visible = false
                
                if t.TabText then
                    Utility:Tween(t.TabText, {TextColor3 = ProfessionalUI.Config.Theme.TextDark}, 0.2)
                end
                
                if t.IconImage then
                    Utility:Tween(t.IconImage, {ImageColor3 = ProfessionalUI.Config.Theme.TextDark}, 0.2)
                end
            end
        end
        
        -- Show selected tab
        Utility:Tween(tab.Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2)
        tab.Content.Visible = true
        tab.SelectionIndicator.Visible = true
        
        if tab.TabText then
            Utility:Tween(tab.TabText, {TextColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
        end
        
        if tab.IconImage then
            Utility:Tween(tab.IconImage, {ImageColor3 = ProfessionalUI.Config.Theme.Text}, 0.2)
        end
        
        selectedTab = tab
    end
    
    -- Initial animation
    mainFrame.Position = UDim2.new(0.5, -400, -0.5, 0)
    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -400, 0.5, -250)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Return window object
    return window
end

-- Initialize the library
ProfessionalUI.KeySystem = KeySystem
ProfessionalUI.Components = Components
ProfessionalUI.Utility = Utility

return ProfessionalUI
