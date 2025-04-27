--[[
    Mafuyo UI Library
    A comprehensive UI library for Roblox games
    
    Usage:
    local Mafuyo = require(game.ReplicatedStorage.MafuyoLibrary)
    local ui = Mafuyo.new()
    
    local myButton = ui:CreateButton({
        Text = "Click Me!",
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Callback = function()
            print("Button clicked!")
        end
    })
]]

local Mafuyo = {}
Mafuyo.__index = Mafuyo

-- Theme configuration
local DefaultTheme = {
    Primary = Color3.fromRGB(65, 105, 225), -- Royal Blue
    Secondary = Color3.fromRGB(100, 149, 237), -- Cornflower Blue
    Background = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(255, 215, 0), -- Gold
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    
    -- UI Element properties
    CornerRadius = UDim.new(0, 8),
    ButtonHeight = UDim.new(0, 40),
    Padding = UDim.new(0, 10),
    FontSize = Enum.FontSize.Size18,
    Font = Enum.Font.GothamSemibold,
    
    -- Animation properties
    HoverScale = 1.05,
    ClickScale = 0.95,
    AnimationSpeed = 0.15,
}

-- Utility functions
local function ApplyRoundedCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or DefaultTheme.CornerRadius
    corner.Parent = instance
    return corner
end

local function ApplyShadow(instance, transparency, offset)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217" -- Shadow image
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.Position = UDim2.fromOffset(offset or 2, offset or 2)
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Parent = instance
    return shadow
end

local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or DefaultTheme.AnimationSpeed,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    return tween
end

-- Constructor
function Mafuyo.new(theme)
    local self = setmetatable({}, Mafuyo)
    
    -- Apply custom theme or use default
    self.Theme = theme or DefaultTheme
    
    -- Create main GUI container
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MafuyoUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to parent to PlayerGui if possible
    local success, result = pcall(function()
        local Players = game:GetService("Players")
        if Players.LocalPlayer then
            self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
            return true
        end
        return false
    end)
    
    if not success or not result then
        -- Fallback to ReplicatedFirst if we can't access PlayerGui
        self.ScreenGui.Parent = game:GetService("ReplicatedFirst")
    end
    
    -- Create main frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MafuyoMainFrame"
    self.MainFrame.Size = UDim2.new(1, 0, 1, 0)
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame.Parent = self.ScreenGui
    
    -- Initialize components table
    self.Components = {}
    
    return self
end

-- Create a window
function Mafuyo:CreateWindow(config)
    config = config or {}
    
    local window = Instance.new("Frame")
    window.Name = config.Name or "MafuyoWindow"
    window.Size = config.Size or UDim2.new(0, 400, 0, 300)
    window.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
    window.AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5)
    window.BackgroundColor3 = config.BackgroundColor or self.Theme.Background
    window.BorderSizePixel = 0
    window.ZIndex = 2
    window.Parent = self.MainFrame
    
    -- Apply rounded corners
    ApplyRoundedCorners(window)
    
    -- Apply shadow
    ApplyShadow(window)
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self.Theme.Primary
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3
    titleBar.Parent = window
    
    ApplyRoundedCorners(titleBar, UDim.new(0, 8))
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title or "Mafuyo Window"
    titleText.TextColor3 = self.Theme.Text
    titleText.TextSize = 18
    titleText.Font = self.Theme.Font
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 4
    titleText.Parent = titleBar
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = self.Theme.Error
    closeButton.Text = "X"
    closeButton.TextColor3 = self.Theme.Text
    closeButton.TextSize = 18
    closeButton.Font = self.Theme.Font
    closeButton.ZIndex = 4
    closeButton.Parent = titleBar
    
    ApplyRoundedCorners(closeButton)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        window.Visible = false
    end)
    
    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Create content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = self.Theme.Secondary
    contentFrame.ZIndex = 3
    contentFrame.Parent = window
    
    -- Add padding to content
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = self.Theme.Padding
    padding.PaddingBottom = self.Theme.Padding
    padding.PaddingLeft = self.Theme.Padding
    padding.PaddingRight = self.Theme.Padding
    padding.Parent = contentFrame
    
    -- Add list layout to content
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = self.Theme.Padding
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame
    
    -- Auto-size content
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    -- Store window in components
    local windowObj = {
        Instance = window,
        ContentFrame = contentFrame,
        TitleBar = titleBar,
        Title = titleText,
        CloseButton = closeButton,
        Components = {}
    }
    
    table.insert(self.Components, windowObj)
    
    -- Return window object with methods
    return setmetatable({
        Window = windowObj,
        Parent = self
    }, {
        __index = function(_, key)
            if key == "AddButton" then
                return function(_, config)
                    return self:CreateButton(config, contentFrame)
                end
            elseif key == "AddLabel" then
                return function(_, config)
                    return self:CreateLabel(config, contentFrame)
                end
            elseif key == "AddToggle" then
                return function(_, config)
                    return self:CreateToggle(config, contentFrame)
                end
            elseif key == "AddSlider" then
                return function(_, config)
                    return self:CreateSlider(config, contentFrame)
                end
            elseif key == "AddTextbox" then
                return function(_, config)
                    return self:CreateTextbox(config, contentFrame)
                end
            elseif key == "AddDropdown" then
                return function(_, config)
                    return self:CreateDropdown(config, contentFrame)
                end
            elseif key == "AddColorPicker" then
                return function(_, config)
                    return self:CreateColorPicker(config, contentFrame)
                end
            elseif key == "AddSeparator" then
                return function(_, config)
                    return self:CreateSeparator(config, contentFrame)
                end
            end
        end
    })
end

-- Create a button
function Mafuyo:CreateButton(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local button = Instance.new("TextButton")
    button.Name = config.Name or "MafuyoButton"
    button.Size = config.Size or UDim2.new(1, 0, 0, 40)
    button.Position = config.Position or UDim2.new(0, 0, 0, 0)
    button.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    button.BackgroundColor3 = config.BackgroundColor or self.Theme.Primary
    button.Text = config.Text or "Button"
    button.TextColor3 = config.TextColor or self.Theme.Text
    button.TextSize = config.TextSize or 16
    button.Font = config.Font or self.Theme.Font
    button.BorderSizePixel = 0
    button.ZIndex = 3
    button.AutoButtonColor = false
    button.Parent = parent
    
    -- Apply rounded corners
    ApplyRoundedCorners(button)
    
    -- Button animations
    local originalSize = button.Size
    local originalPosition = button.Position
    
    button.MouseEnter:Connect(function()
        CreateTween(button, {BackgroundColor3 = self.Theme.Secondary}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, {BackgroundColor3 = self.Theme.Primary}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        CreateTween(button, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset * self.Theme.ClickScale)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        CreateTween(button, {Size = originalSize}):Play()
        if config.Callback then
            config.Callback()
        end
    end)
    
    -- Store button in components
    local buttonObj = {
        Instance = button,
        Type = "Button",
        Config = config
    }
    
    table.insert(self.Components, buttonObj)
    
    -- Return button object
    return buttonObj
end

-- Create a label
function Mafuyo:CreateLabel(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local label = Instance.new("TextLabel")
    label.Name = config.Name or "MafuyoLabel"
    label.Size = config.Size or UDim2.new(1, 0, 0, 30)
    label.Position = config.Position or UDim2.new(0, 0, 0, 0)
    label.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    label.BackgroundTransparency = config.BackgroundTransparency or 1
    label.BackgroundColor3 = config.BackgroundColor or self.Theme.Background
    label.Text = config.Text or "Label"
    label.TextColor3 = config.TextColor or self.Theme.Text
    label.TextSize = config.TextSize or 16
    label.Font = config.Font or self.Theme.Font
    label.TextXAlignment = config.TextXAlignment or Enum.TextXAlignment.Left
    label.TextWrapped = config.TextWrapped or true
    label.BorderSizePixel = 0
    label.ZIndex = 3
    label.Parent = parent
    
    -- Store label in components
    local labelObj = {
        Instance = label,
        Type = "Label",
        Config = config
    }
    
    table.insert(self.Components, labelObj)
    
    -- Return label object with update method
    return setmetatable(labelObj, {
        __index = function(_, key)
            if key == "SetText" then
                return function(_, text)
                    label.Text = text
                end
            end
        end
    })
end

-- Create a toggle
function Mafuyo:CreateToggle(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local toggle = Instance.new("Frame")
    toggle.Name = config.Name or "MafuyoToggle"
    toggle.Size = config.Size or UDim2.new(1, 0, 0, 40)
    toggle.Position = config.Position or UDim2.new(0, 0, 0, 0)
    toggle.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    toggle.BackgroundColor3 = config.BackgroundColor or self.Theme.Background
    toggle.BackgroundTransparency = 1
    toggle.BorderSizePixel = 0
    toggle.ZIndex = 3
    toggle.Parent = parent
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Toggle"
    label.TextColor3 = config.TextColor or self.Theme.Text
    label.TextSize = config.TextSize or 16
    label.Font = config.Font or self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = toggle
    
    -- Create toggle background
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "Background"
    toggleBackground.Size = UDim2.new(0, 50, 0, 24)
    toggleBackground.Position = UDim2.new(1, -50, 0.5, 0)
    toggleBackground.AnchorPoint = Vector2.new(0, 0.5)
    toggleBackground.BackgroundColor3 = self.Theme.Secondary
    toggleBackground.BorderSizePixel = 0
    toggleBackground.ZIndex = 4
    toggleBackground.Parent = toggle
    
    ApplyRoundedCorners(toggleBackground, UDim.new(0, 12))
    
    -- Create toggle indicator
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(0, 2, 0.5, 0)
    toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
    toggleIndicator.BackgroundColor3 = self.Theme.Text
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.ZIndex = 5
    toggleIndicator.Parent = toggleBackground
    
    ApplyRoundedCorners(toggleIndicator, UDim.new(0, 10))
    
    -- Set initial state
    local toggled = config.Default or false
    
    local function updateToggle()
        if toggled then
            CreateTween(toggleBackground, {BackgroundColor3 = self.Theme.Primary}):Play()
            CreateTween(toggleIndicator, {Position = UDim2.new(1, -22, 0.5, 0)}):Play()
        else
            CreateTween(toggleBackground, {BackgroundColor3 = self.Theme.Secondary}):Play()
            CreateTween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, 0)}):Play()
        end
    end
    
    updateToggle()
    
    -- Make toggle clickable
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggled = not toggled
            updateToggle()
            
            if config.Callback then
                config.Callback(toggled)
            end
        end
    end)
    
    -- Adjust label width
    label.Size = UDim2.new(1, -60, 1, 0)
    
    -- Store toggle in components
    local toggleObj = {
        Instance = toggle,
        Background = toggleBackground,
        Indicator = toggleIndicator,
        Type = "Toggle",
        Config = config,
        Value = toggled
    }

        table.insert(self.Components, toggleObj)
    
    -- Return toggle object with methods
    return setmetatable(toggleObj, {
        __index = function(_, key)
            if key == "SetValue" then
                return function(_, value)
                    toggled = value
                    toggleObj.Value = toggled
                    updateToggle()
                    
                    if config.Callback then
                        config.Callback(toggled)
                    end
                end
            elseif key == "GetValue" then
                return function()
                    return toggled
                end
            end
        end
    })
end

-- Create a slider
function Mafuyo:CreateSlider(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or min, min, max)
    
    local slider = Instance.new("Frame")
    slider.Name = config.Name or "MafuyoSlider"
    slider.Size = config.Size or UDim2.new(1, 0, 0, 60)
    slider.Position = config.Position or UDim2.new(0, 0, 0, 0)
    slider.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    slider.BackgroundTransparency = 1
    slider.BorderSizePixel = 0
    slider.ZIndex = 3
    slider.Parent = parent
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Slider"
    label.TextColor3 = config.TextColor or self.Theme.Text
    label.TextSize = config.TextSize or 16
    label.Font = config.Font or self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = slider
    
    -- Create value display
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Name = "Value"
    valueDisplay.Size = UDim2.new(0, 50, 0, 20)
    valueDisplay.Position = UDim2.new(1, 0, 0, 0)
    valueDisplay.AnchorPoint = Vector2.new(1, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(default)
    valueDisplay.TextColor3 = config.TextColor or self.Theme.Text
    valueDisplay.TextSize = config.TextSize or 16
    valueDisplay.Font = config.Font or self.Theme.Font
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.ZIndex = 4
    valueDisplay.Parent = slider
    
    -- Create slider background
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "Background"
    sliderBackground.Size = UDim2.new(1, 0, 0, 10)
    sliderBackground.Position = UDim2.new(0, 0, 0, 30)
    sliderBackground.BackgroundColor3 = self.Theme.Secondary
    sliderBackground.BorderSizePixel = 0
    sliderBackground.ZIndex = 4
    sliderBackground.Parent = slider
    
    ApplyRoundedCorners(sliderBackground, UDim.new(0, 5))
    
    -- Create slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 5
    sliderFill.Parent = sliderBackground
    
    ApplyRoundedCorners(sliderFill, UDim.new(0, 5))
    
    -- Create slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.BackgroundColor3 = self.Theme.Text
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 6
    sliderKnob.Parent = sliderBackground
    
    ApplyRoundedCorners(sliderKnob, UDim.new(0, 10))
    
    -- Slider functionality
    local dragging = false
    local value = default
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pos
        
        if config.RoundValues then
            value = math.round(value)
        end
        
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pos, 0, 0.5, 0)
        valueDisplay.Text = tostring(value)
        
        if config.Callback then
            config.Callback(value)
        end
    end
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    -- Store slider in components
    local sliderObj = {
        Instance = slider,
        Background = sliderBackground,
        Fill = sliderFill,
        Knob = sliderKnob,
        Type = "Slider",
        Config = config,
        Value = value
    }
    
    table.insert(self.Components, sliderObj)
    
    -- Return slider object with methods
    return setmetatable(sliderObj, {
        __index = function(_, key)
            if key == "SetValue" then
                return function(_, newValue)
                    value = math.clamp(newValue, min, max)
                    sliderObj.Value = value
                    
                    local pos = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(pos, 0, 0.5, 0)
                    valueDisplay.Text = tostring(value)
                    
                    if config.Callback then
                        config.Callback(value)
                    end
                end
            elseif key == "GetValue" then
                return function()
                    return value
                end
            end
        end
    })
end

-- Create a textbox
function Mafuyo:CreateTextbox(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local textbox = Instance.new("Frame")
    textbox.Name = config.Name or "MafuyoTextbox"
    textbox.Size = config.Size or UDim2.new(1, 0, 0, 60)
    textbox.Position = config.Position or UDim2.new(0, 0, 0, 0)
    textbox.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    textbox.BackgroundTransparency = 1
    textbox.BorderSizePixel = 0
    textbox.ZIndex = 3
    textbox.Parent = parent
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Textbox"
    label.TextColor3 = config.TextColor or self.Theme.Text
    label.TextSize = config.TextSize or 16
    label.Font = config.Font or self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = textbox
    
    -- Create input box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "Input"
    inputBox.Size = UDim2.new(1, 0, 0, 30)
    inputBox.Position = UDim2.new(0, 0, 0, 25)
    inputBox.BackgroundColor3 = self.Theme.Secondary
    inputBox.PlaceholderText = config.PlaceholderText or "Enter text..."
    inputBox.Text = config.Default or ""
    inputBox.TextColor3 = self.Theme.Text
    inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    inputBox.TextSize = 14
    inputBox.Font = config.Font or self.Theme.Font
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.BorderSizePixel = 0
    inputBox.ZIndex = 4
    inputBox.Parent = textbox
    
    ApplyRoundedCorners(inputBox)
    
    -- Input box functionality
    inputBox.Focused:Connect(function()
        CreateTween(inputBox, {BackgroundColor3 = self.Theme.Primary}):Play()
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        CreateTween(inputBox, {BackgroundColor3 = self.Theme.Secondary}):Play()
        
        if enterPressed and config.Callback then
            config.Callback(inputBox.Text)
        end
    end)
    
    -- Store textbox in components
    local textboxObj = {
        Instance = textbox,
        Input = inputBox,
        Type = "Textbox",
        Config = config,
        Value = inputBox.Text
    }
    
    table.insert(self.Components, textboxObj)
    
    -- Return textbox object with methods
    return setmetatable(textboxObj, {
        __index = function(_, key)
            if key == "SetValue" then
                return function(_, text)
                    inputBox.Text = text
                    textboxObj.Value = text
                    
                    if config.Callback then
                        config.Callback(text)
                    end
                end
            elseif key == "GetValue" then
                return function()
                    return inputBox.Text
                end
            end
        end
    })
end

-- Create a dropdown
function Mafuyo:CreateDropdown(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local options = config.Options or {}
    local default = config.Default or (options[1] or "")
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = config.Name or "MafuyoDropdown"
    dropdown.Size = config.Size or UDim2.new(1, 0, 0, 60)
    dropdown.Position = config.Position or UDim2.new(0, 0, 0, 0)
    dropdown.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    dropdown.BackgroundTransparency = 1
    dropdown.BorderSizePixel = 0
    dropdown.ZIndex = 3
    dropdown.Parent = parent
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Dropdown"
    label.TextColor3 = config.TextColor or self.Theme.Text
    label.TextSize = config.TextSize or 16
    label.Font = config.Font or self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = dropdown
    
    -- Create dropdown button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(1, 0, 0, 30)
    dropdownButton.Position = UDim2.new(0, 0, 0, 25)
    dropdownButton.BackgroundColor3 = self.Theme.Secondary
    dropdownButton.Text = default
    dropdownButton.TextColor3 = self.Theme.Text
    dropdownButton.TextSize = 14
    dropdownButton.Font = config.Font or self.Theme.Font
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.BorderSizePixel = 0
    dropdownButton.ZIndex = 4
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = dropdown
    
    -- Add padding to text
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = dropdownButton
    
    ApplyRoundedCorners(dropdownButton)
    
    -- Create dropdown arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -25, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(0, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = self.Theme.Text
    arrow.TextSize = 14
    arrow.Font = Enum.Font.SourceSans
    arrow.ZIndex = 5
    arrow.Parent = dropdownButton
    
    -- Create dropdown container
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Name = "Container"
    dropdownContainer.Size = UDim2.new(1, 0, 0, 0)
    dropdownContainer.Position = UDim2.new(0, 0, 1, 5)
    dropdownContainer.BackgroundColor3 = self.Theme.Secondary
    dropdownContainer.BorderSizePixel = 0
    dropdownContainer.ZIndex = 10
    dropdownContainer.Visible = false
    dropdownContainer.ClipsDescendants = true
    dropdownContainer.Parent = dropdownButton
    
    ApplyRoundedCorners(dropdownContainer)
    
    -- Create list layout for options
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownContainer
    
    -- Add options
    local optionButtons = {}
    local containerSize = 0
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. i
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = self.Theme.Text
        optionButton.TextSize = 14
        optionButton.Font = config.Font or self.Theme.Font
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.BorderSizePixel = 0
        optionButton.ZIndex = 11
        optionButton.Parent = dropdownContainer
        
        -- Add padding to text
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 10)
        optionPadding.Parent = optionButton
        
        -- Option button functionality
        optionButton.MouseEnter:Connect(function()
            CreateTween(optionButton, {BackgroundTransparency = 0.8}):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            CreateTween(optionButton, {BackgroundTransparency = 1}):Play()
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            
            -- Close dropdown
            CreateTween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            wait(self.Theme.AnimationSpeed)
            dropdownContainer.Visible = false
            arrow.Text = "▼"
            
            if config.Callback then
                config.Callback(option)
            end
        end)
        
        table.insert(optionButtons, optionButton)
        containerSize = containerSize + 30
    end
    
    -- Dropdown functionality
    local isOpen = false
    
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            dropdownContainer.Visible = true
            CreateTween(dropdownContainer, {Size = UDim2.new(1, 0, 0, containerSize)}):Play()
            arrow.Text = "▲"
        else
            CreateTween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            wait(self.Theme.AnimationSpeed)
            dropdownContainer.Visible = false
            arrow.Text = "▼"
        end
    end)
    
    -- Close dropdown when clicking elsewhere
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local guiObjects = game:GetService("Players").LocalPlayer:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            local isClickingDropdown = false
            
            for _, obj in ipairs(guiObjects) do
                if obj == dropdownButton or obj:IsDescendantOf(dropdownContainer) then
                    isClickingDropdown = true
                    break
                end
            end
            
            if not isClickingDropdown and isOpen then
                isOpen = false
                CreateTween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}):Play()
                wait(self.Theme.AnimationSpeed)
                dropdownContainer.Visible = false
                arrow.Text = "▼"
            end
        end
    end)
    
    -- Store dropdown in components
    local dropdownObj = {
        Instance = dropdown,
        Button = dropdownButton,
        Container = dropdownContainer,
        Options = optionButtons,
        Type = "Dropdown",
        Config = config,
        Value = default
    }

        table.insert(self.Components, dropdownObj)
    
    -- Return dropdown object with methods
    return setmetatable(dropdownObj, {
        __index = function(_, key)
            if key == "SetValue" then
                return function(_, option)
                    if table.find(options, option) then
                        dropdownButton.Text = option
                        dropdownObj.Value = option
                        
                        if config.Callback then
                            config.Callback(option)
                        end
                    end
                end
            elseif key == "GetValue" then
                return function()
                    return dropdownButton.Text
                end
            elseif key == "AddOption" then
                return function(_, option)
                    if not table.find(options, option) then
                        table.insert(options, option)
                        
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = "Option_" .. #options
                        optionButton.Size = UDim2.new(1, 0, 0, 30)
                        optionButton.BackgroundTransparency = 1
                        optionButton.Text = option
                        optionButton.TextColor3 = self.Theme.Text
                        optionButton.TextSize = 14
                        optionButton.Font = config.Font or self.Theme.Font
                        optionButton.TextXAlignment = Enum.TextXAlignment.Left
                        optionButton.BorderSizePixel = 0
                        optionButton.ZIndex = 11
                        optionButton.Parent = dropdownContainer
                        
                        -- Add padding to text
                        local optionPadding = Instance.new("UIPadding")
                        optionPadding.PaddingLeft = UDim.new(0, 10)
                        optionPadding.Parent = optionButton
                        
                        -- Option button functionality
                        optionButton.MouseEnter:Connect(function()
                            CreateTween(optionButton, {BackgroundTransparency = 0.8}):Play()
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            CreateTween(optionButton, {BackgroundTransparency = 1}):Play()
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            dropdownButton.Text = option
                            
                            -- Close dropdown
                            CreateTween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}):Play()
                            wait(self.Theme.AnimationSpeed)
                            dropdownContainer.Visible = false
                            arrow.Text = "▼"
                            
                            if config.Callback then
                                config.Callback(option)
                            end
                        end)
                        
                        table.insert(optionButtons, optionButton)
                        containerSize = containerSize + 30
                    end
                end
            elseif key == "RemoveOption" then
                return function(_, option)
                    local index = table.find(options, option)
                    if index then
                        table.remove(options, index)
                        optionButtons[index]:Destroy()
                        table.remove(optionButtons, index)
                        containerSize = containerSize - 30
                        
                        -- Rename remaining options
                        for i, button in ipairs(optionButtons) do
                            button.Name = "Option_" .. i
                        end
                        
                        -- If current value is removed, set to first option
                        if dropdownButton.Text == option and #options > 0 then
                            dropdownButton.Text = options[1]
                            dropdownObj.Value = options[1]
                            
                            if config.Callback then
                                config.Callback(options[1])
                            end
                        end
                    end
                end
            end
        end
    })
end

-- Create a color picker
function Mafuyo:CreateColorPicker(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    
    local colorPicker = Instance.new("Frame")
    colorPicker.Name = config.Name or "MafuyoColorPicker"
    colorPicker.Size = config.Size or UDim2.new(1, 0, 0, 60)
    colorPicker.Position = config.Position or UDim2.new(0, 0, 0, 0)
    colorPicker.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    colorPicker.BackgroundTransparency = 1
    colorPicker.BorderSizePixel = 0
    colorPicker.ZIndex = 3
    colorPicker.Parent = parent
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Color Picker"
    label.TextColor3 = config.TextColor or self.Theme.Text
    label.TextSize = config.TextSize or 16
    label.Font = config.Font or self.Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = colorPicker
    
    -- Create color display
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Name = "Display"
    colorDisplay.Size = UDim2.new(0, 40, 0, 40)
    colorDisplay.Position = UDim2.new(1, -40, 0, 0)
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.ZIndex = 4
    colorDisplay.Parent = colorPicker
    
    ApplyRoundedCorners(colorDisplay)
    
    -- Create color picker button
    local pickerButton = Instance.new("TextButton")
    pickerButton.Name = "Button"
    pickerButton.Size = UDim2.new(1, 0, 1, 0)
    pickerButton.BackgroundTransparency = 1
    pickerButton.Text = ""
    pickerButton.ZIndex = 5
    pickerButton.Parent = colorDisplay
    
    -- Create color picker panel
    local pickerPanel = Instance.new("Frame")
    pickerPanel.Name = "Panel"
    pickerPanel.Size = UDim2.new(0, 200, 0, 220)
    pickerPanel.Position = UDim2.new(1, -200, 1, 10)
    pickerPanel.BackgroundColor3 = self.Theme.Background
    pickerPanel.BorderSizePixel = 0
    pickerPanel.ZIndex = 100
    pickerPanel.Visible = false
    pickerPanel.Parent = colorPicker
    
    ApplyRoundedCorners(pickerPanel)
    ApplyShadow(pickerPanel)
    
    -- Create color palette
    local colorPalette = Instance.new("ImageButton")
    colorPalette.Name = "Palette"
    colorPalette.Size = UDim2.new(1, -20, 0, 150)
    colorPalette.Position = UDim2.new(0, 10, 0, 10)
    colorPalette.Image = "rbxassetid://6523286724"
    colorPalette.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    colorPalette.BorderSizePixel = 0
    colorPalette.ZIndex = 101
    colorPalette.Parent = pickerPanel
    
    ApplyRoundedCorners(colorPalette)
    
    -- Create color palette selector
    local paletteSelector = Instance.new("Frame")
    paletteSelector.Name = "Selector"
    paletteSelector.Size = UDim2.new(0, 10, 0, 10)
    paletteSelector.AnchorPoint = Vector2.new(0.5, 0.5)
    paletteSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    paletteSelector.BorderSizePixel = 0
    paletteSelector.ZIndex = 102
    paletteSelector.Parent = colorPalette
    
    ApplyRoundedCorners(paletteSelector, UDim.new(1, 0))
    
    -- Create hue slider
    local hueSlider = Instance.new("ImageButton")
    hueSlider.Name = "HueSlider"
    hueSlider.Size = UDim2.new(1, -20, 0, 20)
    hueSlider.Position = UDim2.new(0, 10, 0, 170)
    hueSlider.Image = "rbxassetid://6523291212"
    hueSlider.BackgroundTransparency = 1
    hueSlider.BorderSizePixel = 0
    hueSlider.ZIndex = 101
    hueSlider.Parent = pickerPanel
    
    ApplyRoundedCorners(hueSlider)
    
    -- Create hue selector
    local hueSelector = Instance.new("Frame")
    hueSelector.Name = "Selector"
    hueSelector.Size = UDim2.new(0, 5, 1, 0)
    hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSelector.BorderSizePixel = 0
    hueSelector.ZIndex = 102
    hueSelector.Parent = hueSlider
    
    ApplyRoundedCorners(hueSelector)
    
    -- Create RGB display
    local rgbDisplay = Instance.new("TextLabel")
    rgbDisplay.Name = "RGBDisplay"
    rgbDisplay.Size = UDim2.new(1, -20, 0, 20)
    rgbDisplay.Position = UDim2.new(0, 10, 0, 195)
    rgbDisplay.BackgroundTransparency = 1
    rgbDisplay.Text = "RGB: 255, 255, 255"
    rgbDisplay.TextColor3 = self.Theme.Text
    rgbDisplay.TextSize = 14
    rgbDisplay.Font = self.Theme.Font
    rgbDisplay.ZIndex = 101
    rgbDisplay.Parent = pickerPanel
    
    -- Color picker functionality
    local hue, saturation, value = 0, 0, 1
    local selectedColor = default
    
    local function updateColor()
        local hsv = Color3.fromHSV(hue, saturation, value)
        selectedColor = hsv
        colorDisplay.BackgroundColor3 = hsv
        colorPalette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        
        local r, g, b = math.floor(hsv.R * 255 + 0.5), math.floor(hsv.G * 255 + 0.5), math.floor(hsv.B * 255 + 0.5)
        rgbDisplay.Text = string.format("RGB: %d, %d, %d", r, g, b)
        
        if config.Callback then
            config.Callback(hsv)
        end
    end
    
    -- Initialize from default color
    do
        local h, s, v = Color3.toHSV(default)
        hue, saturation, value = h, s, v
        
        -- Set initial positions
        hueSelector.Position = UDim2.new(h, 0, 0, 0)
        paletteSelector.Position = UDim2.new(s, 0, 1 - v, 0)
        
        updateColor()
    end
    
    -- Hue slider functionality
    hueSlider.MouseButton1Down:Connect(function(x)
        local offset = math.clamp((x - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
        hueSelector.Position = UDim2.new(offset, 0, 0, 0)
        hue = offset
        updateColor()
    end)
    
    -- Color palette functionality
    colorPalette.MouseButton1Down:Connect(function(x, y)
        local xOffset = math.clamp((x - colorPalette.AbsolutePosition.X) / colorPalette.AbsoluteSize.X, 0, 1)
        local yOffset = math.clamp((y - colorPalette.AbsolutePosition.Y) / colorPalette.AbsoluteSize.Y, 0, 1)
        paletteSelector.Position = UDim2.new(xOffset, 0, yOffset, 0)
        saturation = xOffset
        value = 1 - yOffset
        updateColor()
    end)
    
    -- Toggle color picker panel
    local isOpen = false
    
    pickerButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        pickerPanel.Visible = isOpen
    end)
    
    -- Close panel when clicking elsewhere
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local guiObjects = game:GetService("Players").LocalPlayer:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            local isClickingPanel = false
            
            for _, obj in ipairs(guiObjects) do
                if obj == pickerButton or obj:IsDescendantOf(pickerPanel) then
                    isClickingPanel = true
                    break
                end
            end
            
            if not isClickingPanel and isOpen then
                isOpen = false
                pickerPanel.Visible = false
            end
        end
    end)
    
    -- Store color picker in components
    local colorPickerObj = {
        Instance = colorPicker,
        Display = colorDisplay,
        Panel = pickerPanel,
        Type = "ColorPicker",
        Config = config,
        Value = selectedColor
    }
    
    table.insert(self.Components, colorPickerObj)
    
    -- Return color picker object with methods
    return setmetatable(colorPickerObj, {
        __index = function(_, key)
            if key == "SetValue" then
                return function(_, color)
                    local h, s, v = Color3.toHSV(color)
                    hue, saturation, value = h, s, v
                    
                    -- Update positions
                    hueSelector.Position = UDim2.new(h, 0, 0, 0)
                    paletteSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                    
                    selectedColor = color
                    colorPickerObj.Value = color
                    updateColor()
                end
            elseif key == "GetValue" then
                return function()
                    return selectedColor
                end
            end
        end
    })
end

-- Create a separator
function Mafuyo:CreateSeparator(config, parent)
    config = config or {}
    parent = parent or self.MainFrame
    
    local separator = Instance.new("Frame")
    separator.Name = config.Name or "MafuyoSeparator"
    separator.Size = config.Size or UDim2.new(1, 0, 0, 1)
    separator.Position = config.Position or UDim2.new(0, 0, 0, 0)
    separator.AnchorPoint = config.AnchorPoint or Vector2.new(0, 0)
    separator.BackgroundColor3 = config.Color or self.Theme.Secondary
    separator.BorderSizePixel = 0
    separator.ZIndex = 3
    separator.Parent = parent
    
    -- Store separator in components
    local separatorObj = {
        Instance = separator,
        Type = "Separator",
        Config = config
    }
    
    table.insert(self.Components, separatorObj)
    
    -- Return separator object
    return separatorObj
end

-- Destroy the UI
function Mafuyo:Destroy()
    self.ScreenGui:Destroy()
end

return Mafuyo
