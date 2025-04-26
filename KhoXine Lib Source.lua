-- ProfessionalUI Library
-- A responsive and professional UI library for Roblox

local ProfessionalUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
ProfessionalUI.Config = {
    Theme = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(0, 180, 0),
        Error = Color3.fromRGB(255, 0, 0),
        Warning = Color3.fromRGB(255, 165, 0)
    },
    Animation = {
        Duration = 0.3,
        Style = Enum.EasingStyle.Quint,
        Direction = Enum.EasingDirection.Out
    },
    KeySystem = {
        Enabled = true,
        Keys = {},
        Attempts = 5,
        SaveKey = true
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

function Utility:Ripple(button)
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
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

function Utility:Dragify(frame)
    local dragToggle, dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

function Utility:SaveSetting(name, value)
    if not pcall(function()
        writefile("ProfessionalUI/" .. name .. ".json", HttpService:JSONEncode(value))
    end) then
        warn("Failed to save setting: " .. name)
    end
end

function Utility:LoadSetting(name)
    if not pcall(function()
        if isfile("ProfessionalUI/" .. name .. ".json") then
            return HttpService:JSONDecode(readfile("ProfessionalUI/" .. name .. ".json"))
        end
    end) then
        warn("Failed to load setting: " .. name)
        return nil
    end
end

-- Key System
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

function KeySystem:VerifyKey(key)
    for _, validKey in ipairs(ProfessionalUI.Config.KeySystem.Keys) do
        if key == validKey then
            if ProfessionalUI.Config.KeySystem.SaveKey then
                Utility:SaveSetting("key", key)
            end
            return true
        end
    end
    return false
end

function KeySystem:GetSavedKey()
    return Utility:LoadSetting("key")
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
    local keyWindow = Utility:Create("ScreenGui", {
        Name = "KeySystem",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game.CoreGui
    })
    
    local mainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -150, 0.5, -100),
        Size = UDim2.new(0, 300, 0, 200),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = keyWindow
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })
    
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = mainFrame
    })
    
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "Key System",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 18,
        Parent = mainFrame
    })
    
    local subtitle = Utility:Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Please enter your key to continue",
        TextColor3 = ProfessionalUI.Config.Theme.SubText,
        TextSize = 14,
        Parent = mainFrame
    })
    
    local keyBox = Utility:Create("TextBox", {
        Name = "KeyBox",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -125, 0, 80),
        Size = UDim2.new(0, 250, 0, 40),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter key here...",
        Text = "",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 14,
        ClearTextOnFocus = false,
        Parent = mainFrame
    })
    
    local keyBoxCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = keyBox
    })
    
    local submitButton = Utility:Create("TextButton", {
        Name = "SubmitButton",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -75, 0, 140),
        Size = UDim2.new(0, 150, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "Submit",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = mainFrame
    })
    
    local submitButtonCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = submitButton
    })
    
    local attemptsLabel = Utility:Create("TextLabel", {
        Name = "AttemptsLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Attempts remaining: " .. attempts,
        TextColor3 = ProfessionalUI.Config.Theme.SubText,
        TextSize = 12,
        Parent = mainFrame
    })
    
    Utility:Dragify(mainFrame)
    
    submitButton.MouseEnter:Connect(function()
        Utility:Tween(submitButton, {BackgroundColor3 = Color3.fromRGB(0, 100, 180)}, 0.2)
    end)
    
    submitButton.MouseLeave:Connect(function()
        Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent}, 0.2)
    end)
    
    submitButton.MouseButton1Click:Connect(function()
        Utility:Ripple(submitButton)
        
        local key = keyBox.Text
        if self:VerifyKey(key) then
            Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Success}, 0.2)
            submitButton.Text = "Success!"
            
            task.delay(1, function()
                Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -150, 1.5, 0)}, 0.5)
                task.delay(0.5, function()
                    keyWindow:Destroy()
                    callback(true)
                end)
            end)
        else
            attempts = attempts - 1
            attemptsLabel.Text = "Attempts remaining: " .. attempts
            
            Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Error}, 0.2)
            submitButton.Text = "Invalid Key"
            keyBox.Text = ""
            
            task.delay(1, function()
                Utility:Tween(submitButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent}, 0.2)
                submitButton.Text = "Submit"
            end)
            
            if attempts <= 0 then
                task.delay(1, function()
                    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -150, 1.5, 0)}, 0.5)
                    task.delay(0.5, function()
                        keyWindow:Destroy()
                        callback(false)
                    end)
                end)
            end
        end
    end)
    
    -- Initial animation
    mainFrame.Position = UDim2.new(0.5, -150, -0.5, 0)
    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -150, 0.5, -100)}, 0.5)
end

-- UI Components
local Components = {}

function Components:CreateWindow(title)
    local window = {}
    
    -- Create main GUI
    local screenGui = Utility:Create("ScreenGui", {
        Name = "ProfessionalUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game.CoreGui
    })
    
    local mainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Parent = screenGui
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainFrame
    })
    
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = mainFrame
    })
    
    local topBar = Utility:Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = mainFrame
    })
    
    local topBarCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = topBar
    })
    
    local topBarFix = Utility:Create("Frame", {
        Name = "TopBarFix",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = topBar
    })
    
    local titleLabel = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "Professional UI",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    
    local closeButton = Utility:Create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 24,
        Parent = topBar
    })
    
    local minimizeButton = Utility:Create("TextButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, 0),
        Size = UDim2.new(0, 40, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = ProfessionalUI.Config.Theme.Text,
        TextSize = 24,
        Parent = topBar
    })
    
    local tabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = ProfessionalUI.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 150, 1, -60),
        Parent = mainFrame
    })
    
    local tabContainerCorner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = tabContainer
    })
    
    local tabList = Utility:Create("ScrollingFrame", {
        Name = "TabList",
        Active = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = ProfessionalUI.Config.Theme.Accent,
        Parent = tabContainer
    })
    
    local tabListLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList
    })
    
    local tabListPadding = Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = tabList
    })
    
    local contentContainer = Utility:Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 50),
        Size = UDim2.new(1, -180, 1, -60),
        Parent = mainFrame
    })

        -- Make window draggable
    Utility:Dragify(mainFrame)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        Utility:Ripple(closeButton)
        Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -300, 1.5, 0)}, 0.5)
        task.delay(0.5, function()
            screenGui:Destroy()
        end)
    end)
    
    -- Minimize button functionality
    local minimized = false
    local originalSize = mainFrame.Size
    
    minimizeButton.MouseButton1Click:Connect(function()
        Utility:Ripple(minimizeButton)
        minimized = not minimized
        
        if minimized then
            Utility:Tween(mainFrame, {Size = UDim2.new(0, 600, 0, 40)}, 0.3)
            tabContainer.Visible = false
            contentContainer.Visible = false
        else
            Utility:Tween(mainFrame, {Size = originalSize}, 0.3)
            tabContainer.Visible = true
            contentContainer.Visible = true
        end
    end)
    
    -- Tab functionality
    local tabs = {}
    local selectedTab = nil
    
    function window:AddTab(name, icon)
        local tab = {}
        
        -- Create tab button
        local tabButton = Utility:Create("TextButton", {
            Name = name .. "Tab",
            BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(0.9, 0, 0, 40),
            Font = Enum.Font.Gotham,
            Text = "  " .. name,
            TextColor3 = ProfessionalUI.Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = tabList
        })
        
        local tabButtonCorner = Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabButton
        })
        
        if icon then
            local iconImage = Utility:Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = icon,
                Parent = tabButton
            })
            
            tabButton.Text = "      " .. name
        end
        
        -- Create tab content
        local tabContent = Utility:Create("ScrollingFrame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = ProfessionalUI.Config.Theme.Accent,
            Visible = false,
            Parent = contentContainer
        })
        
        local contentLayout = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 10),
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
        tabButton.MouseEnter:Connect(function()
            if selectedTab ~= tab then
                Utility:Tween(tabButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if selectedTab ~= tab then
                Utility:Tween(tabButton, {BackgroundColor3 = ProfessionalUI.Config.Theme.Primary}, 0.2)
            end
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            Utility:Ripple(tabButton)
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
                CornerRadius = UDim.new(0, 8),
                Parent = sectionFrame
            })
            
            local sectionTitle = Utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -15, 0, 40),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = ProfessionalUI.Config.Theme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
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
                PaddingBottom = UDim.new(0, 10),
                Parent = sectionContent
            })
            
            -- Section functions
            function section:AddButton(buttonText, callback)
                local button = Utility:Create("TextButton", {
                    Name = buttonText .. "Button",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Font = Enum.Font.GothamBold,
                    Text = buttonText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                    Parent = sectionContent
                })
                
                local buttonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = button
                })
                
                button.MouseEnter:Connect(function()
                    Utility:Tween(button, {BackgroundColor3 = Color3.fromRGB(0, 100, 180)}, 0.2)
                end)
                
                button.MouseLeave:Connect(function()
                    Utility:Tween(button, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent}, 0.2)
                end)
                
                button.MouseButton1Click:Connect(function()
                    Utility:Ripple(button)
                    if callback then callback() end
                end)
                
                return button
            end
            
            function section:AddToggle(toggleText, default, callback)
                local toggled = default or false
                
                local toggleFrame = Utility:Create("Frame", {
                    Name = toggleText .. "Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Parent = sectionContent
                })
                
                local toggleLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
                
                local toggleButton = Utility:Create("Frame", {
                    Name = "ToggleButton",
                    BackgroundColor3 = toggled and ProfessionalUI.Config.Theme.Accent or Color3.fromRGB(80, 80, 80),
                    BorderSizePixel = 0,
                    Position = UDim280,80),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Parent = toggleFrame
                })
                
                local toggleButtonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 10),
                    Parent = toggleButton
                })
                
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
                
                local function updateToggle()
                    Utility:Tween(toggleButton, {BackgroundColor3 = toggled and ProfessionalUI.Config.Theme.Accent or Color3.fromRGB(80, 80, 80)}, 0.2)
                    Utility:Tween(toggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
                    
                    if callback then callback(toggled) end
                end
                
                toggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggled = not toggled
                        updateToggle()
                    end
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
                
                local sliderFrame = Utility:Create("Frame", {
                    Name = sliderText .. "Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 50),
                    Parent = sectionContent
                })
                
                local sliderLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -10, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sliderText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                
                local valueLabel = Utility:Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(sliderValue),
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderFrame
                })
                
                local sliderBackground = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 25),
                    Size = UDim2.new(1, -20, 0, 10),
                    Parent = sliderFrame
                })
                
                local sliderBackgroundCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = sliderBackground
                })
                
                local sliderFill = Utility:Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0),
                    Parent = sliderBackground
                })
                
                local sliderFillCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = sliderFill
                })
                
                local sliderButton = Utility:Create("TextButton", {
                    Name = "SliderButton",
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
                    
                    if callback then callback(value) end
                end
                
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local connection
                        
                        connection = RunService.RenderStepped:Connect(function()
                            local mousePos = UserInputService:GetMouseLocation()
                            local relativePos = mousePos.X - sliderBackground.AbsolutePosition.X
                            local percent = math.clamp(relativePos / sliderBackground.AbsoluteSize.X, 0, 1)
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
                
                local dropdownFrame = Utility:Create("Frame", {
                    Name = dropdownText .. "Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    ClipsDescendants = true,
                    Parent = sectionContent
                })
                
                local dropdownLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -10, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = dropdownText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownFrame
                })
                
                local dropdownButton = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = selected,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                    Parent = dropdownFrame
                })
                
                local dropdownButtonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
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
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 75),
                    Size = UDim2.new(1, -20, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = dropdownFrame
                })

                local optionContainerCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = optionContainer
                })
                
                local optionList = Utility:Create("ScrollingFrame", {
                    Name = "OptionList",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = ProfessionalUI.Config.Theme.Accent,
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
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
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
                        Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        Utility:Ripple(optionButton)
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
                        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 35 + 45 + math.min(#options * 35, 150))
                        optionContainer.Size = UDim2.new(1, -20, 0, math.min(#options * 35, 150))
                        optionContainer.Visible = true
                        Utility:Tween(dropdownIcon, {Rotation = 180}, 0.2)
                    else
                        Utility:Tween(dropdownIcon, {Rotation = 0}, 0.2)
                        Utility:Tween(dropdownFrame, {Size = UDim2.new(0.9, 0, 0, 70)}, 0.2)
                        task.delay(0.2, function()
                            optionContainer.Visible = false
                        end)
                    end
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    Utility:Ripple(dropdownButton)
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
                            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
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
                            Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            Utility:Tween(optionButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            Utility:Ripple(optionButton)
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
                local textboxFrame = Utility:Create("Frame", {
                    Name = boxText .. "Textbox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 70),
                    Parent = sectionContent
                })
                
                local textboxLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -10, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = boxText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxFrame
                })
                
                local textbox = Utility:Create("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 25),
                    Size = UDim2.new(1, -20, 0, 35),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder or "Enter text...",
                    Text = default or "",
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    ClearTextOnFocus = false,
                    Parent = textboxFrame
                })
                
                local textboxCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = textbox
                })
                
                textbox.FocusLost:Connect(function(enterPressed)
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
                local keybindFrame = Utility:Create("Frame", {
                    Name = bindText .. "Keybind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.9, 0, 0, 35),
                    Parent = sectionContent
                })
                
                local keybindLabel = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = bindText,
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindFrame
                })
                
                local keybindButton = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = ProfessionalUI.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0.5, 0),
                    Size = UDim2.new(0, 60, 0, 25),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font = Enum.Font.GothamBold,
                    Text = default and default.Name or "None",
                    TextColor3 = ProfessionalUI.Config.Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = keybindFrame
                })
                
                local keybindButtonCorner = Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybindButton
                })
                
                local currentKey = default
                local keyChanging = false
                
                keybindButton.MouseButton1Click:Connect(function()
                    Utility:Ripple(keybindButton)
                    
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
            end
        end
        
        -- Show selected tab
        Utility:Tween(tab.Button, {BackgroundColor3 = ProfessionalUI.Config.Theme.Accent}, 0.2)
        tab.Content.Visible = true
        
        selectedTab = tab
    end
    
    -- Initial animation
    mainFrame.Position = UDim2.new(0.5, -300, -0.5, 0)
    Utility:Tween(mainFrame, {Position = UDim2.new(0.5, -300, 0.5, -200)}, 0.5)
    
    return window
end

-- Initialize the library
ProfessionalUI.KeySystem = KeySystem
ProfessionalUI.Components = Components
ProfessionalUI.Utility = Utility

return ProfessionalUI
