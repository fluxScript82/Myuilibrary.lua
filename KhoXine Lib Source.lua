-- Mafuyo UI Library
-- A draggable UI library for Roblox games

local MafuyoLib = {}
MafuyoLib.__index = MafuyoLib

-- Configuration
local config = {
    title = "Mafuyo",
    defaultColor = Color3.fromRGB(45, 45, 45),
    accentColor = Color3.fromRGB(255, 85, 127),
    textColor = Color3.fromRGB(255, 255, 255),
    cornerRadius = UDim.new(0, 6),
    defaultSize = UDim2.new(0, 400, 0, 300),
    minSize = UDim2.new(0, 80, 0, 30),
    defaultPosition = UDim2.new(0.5, -200, 0.5, -150),
    logoSize = UDim2.new(0, 25, 0, 25)
}

-- Create the main UI
function MafuyoLib.new(parent)
    local self = setmetatable({}, MafuyoLib)
    parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "MafuyoUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.Parent = parent
    
    -- Create main frame
    self.main = Instance.new("Frame")
    self.main.Name = "MainFrame"
    self.main.Size = config.defaultSize
    self.main.Position = config.defaultPosition
    self.main.BackgroundColor3 = config.defaultColor
    self.main.BorderSizePixel = 0
    self.main.Active = true
    self.main.Parent = self.gui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = config.cornerRadius
    corner.Parent = self.main
    
    -- Create title bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.BackgroundColor3 = config.accentColor
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.main
    
    -- Add corner radius to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = config.cornerRadius
    titleCorner.Parent = self.titleBar
    
    -- Create title text
    self.titleText = Instance.new("TextLabel")
    self.titleText.Name = "Title"
    self.titleText.Size = UDim2.new(1, -60, 1, 0)
    self.titleText.Position = UDim2.new(0, 35, 0, 0)
    self.titleText.BackgroundTransparency = 1
    self.titleText.Text = config.title
    self.titleText.TextColor3 = config.textColor
    self.titleText.TextSize = 16
    self.titleText.Font = Enum.Font.GothamSemibold
    self.titleText.TextXAlignment = Enum.TextXAlignment.Left
    self.titleText.Parent = self.titleBar
    
    -- Create logo frame
    self.logoFrame = Instance.new("Frame")
    self.logoFrame.Name = "LogoFrame"
    self.logoFrame.Size = config.logoSize
    self.logoFrame.Position = UDim2.new(0, 5, 0.5, -12.5)
    self.logoFrame.BackgroundTransparency = 1
    self.logoFrame.Parent = self.titleBar
    
    -- Create logo image (placeholder)
    self.logo = Instance.new("ImageLabel")
    self.logo.Name = "Logo"
    self.logo.Size = UDim2.new(1, 0, 1, 0)
    self.logo.BackgroundTransparency = 1
    self.logo.Image = ""  -- Set this to your logo image ID
    self.logo.Parent = self.logoFrame
    
    -- Create close button
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 25, 0, 25)
    self.closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    self.closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = config.textColor
    self.closeButton.TextSize = 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.titleBar
    
    -- Add corner radius to close button
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = self.closeButton
    
    -- Create minimize button
    self.minimizeButton = Instance.new("TextButton")
    self.minimizeButton.Name = "MinimizeButton"
    self.minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    self.minimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    self.minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
    self.minimizeButton.Text = "-"
    self.minimizeButton.TextColor3 = config.textColor
    self.minimizeButton.TextSize = 16
    self.minimizeButton.Font = Enum.Font.GothamBold
    self.minimizeButton.Parent = self.titleBar
    
    -- Add corner radius to minimize button
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = self.minimizeButton
    
    -- Create content frame
    self.content = Instance.new("Frame")
    self.content.Name = "Content"
    self.content.Size = UDim2.new(1, 0, 1, -30)
    self.content.Position = UDim2.new(0, 0, 0, 30)
    self.content.BackgroundTransparency = 1
    self.content.Parent = self.main
    
    -- Create small UI toggle button (when minimized)
    self.toggleButton = Instance.new("ImageButton")
    self.toggleButton.Name = "ToggleButton"
    self.toggleButton.Size = UDim2.new(0, 40, 0, 40)
    self.toggleButton.Position = UDim2.new(0, 10, 0, 10)
    self.toggleButton.BackgroundColor3 = config.accentColor
    self.toggleButton.Visible = false
    self.toggleButton.Parent = self.gui
    
    -- Add corner radius to toggle button
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)  -- Make it circular
    toggleCorner.Parent = self.toggleButton
    
    -- Create toggle button logo
    self.toggleLogo = Instance.new("ImageLabel")
    self.toggleLogo.Name = "ToggleLogo"
    self.toggleLogo.Size = UDim2.new(0.8, 0, 0.8, 0)
    self.toggleLogo.Position = UDim2.new(0.1, 0, 0.1, 0)
    self.toggleLogo.BackgroundTransparency = 1
    self.toggleLogo.Image = ""  -- Set this to your logo image ID
    self.toggleLogo.Parent = self.toggleButton
    
    -- Set up dragging
    self:setupDragging()
    
    -- Set up button functionality
    self:setupButtons()
    
    -- Create tabs container
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.Size = UDim2.new(1, 0, 0, 30)
    self.tabsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.tabsContainer.BorderSizePixel = 0
    self.tabsContainer.Parent = self.content
    
    -- Create tab content container
    self.tabContent = Instance.new("Frame")
    self.tabContent.Name = "TabContent"
    self.tabContent.Size = UDim2.new(1, 0, 1, -30)
    self.tabContent.Position = UDim2.new(0, 0, 0, 30)
    self.tabContent.BackgroundTransparency = 1
    self.tabContent.Parent = self.content
    
    self.tabs = {}
    self.activeTab = nil
    
    return self
end

-- Set up dragging functionality
function MafuyoLib:setupDragging()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        self.main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Make toggle button draggable too
    local toggleDragging = false
    local toggleDragInput
    local toggleDragStart
    local toggleStartPos
    
    local function updateToggleDrag(input)
        local delta = input.Position - toggleDragStart
        self.toggleButton.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
    end
    
    self.toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragging = true
            toggleDragStart = input.Position
            toggleStartPos = self.toggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    toggleDragging = false
                end
            end)
        end
    end)
    
    self.toggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == toggleDragInput and toggleDragging then
            updateToggleDrag(input)
        end
    end)
end

-- Set up button functionality
function MafuyoLib:setupButtons()
    -- Close button
    self.closeButton.MouseButton1Click:Connect(function()
        self.main.Visible = false
        self.toggleButton.Visible = true
    end)
    
    -- Minimize button
    self.minimizeButton.MouseButton1Click:Connect(function()
        self.main.Size = config.minSize
        self.content.Visible = false
        
        -- Adjust title bar for minimized state
        self.titleText.Text = "M"
        self.minimizeButton.Text = "+"
        
        -- Change minimize button behavior
        local oldFunc = self.minimizeButton.MouseButton1Click:Connect(function() end)
        oldFunc:Disconnect()
        
        self.minimizeButton.MouseButton1Click:Connect(function()
            self.main.Size = config.defaultSize
            self.content.Visible = true
            self.titleText.Text = config.title
            self.minimizeButton.Text = "-"
            
            -- Reset minimize button behavior
            self:setupButtons()
        end)
    end)
    
    -- Toggle button
    self.toggleButton.MouseButton1Click:Connect(function()
        if not self.toggleDragging then
            self.main.Visible = true
            self.toggleButton.Visible = false
        end
    end)
end

-- Set logo image
function MafuyoLib:setLogo(imageId)
    if typeof(imageId) == "string" then
        self.logo.Image = imageId
        self.toggleLogo.Image = imageId
    end
end

-- Create a new tab
function MafuyoLib:createTab(name)
    local tabIndex = #self.tabs + 1
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 80, 1, 0)
    tabButton.Position = UDim2.new(0, (tabIndex - 1) * 80, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = config.textColor
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.tabsContainer
    
    -- Create tab content
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Content"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 4
    tabFrame.Visible = false
    tabFrame.Parent = self.tabContent
    
    -- Add padding to tab content
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = tabFrame
    
    -- Add layout for tab content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabFrame
    
    -- Auto-size content
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab button click handler
    tabButton.MouseButton1Click:Connect(function()
        self:selectTab(name)
    end)
    
    local tab = {
        name = name,
        button = tabButton,
        frame = tabFrame
    }
    
    table.insert(self.tabs, tab)
    
    -- If this is the first tab, select it
    if #self.tabs == 1 then
        self:selectTab(name)
    end
    
    return tab
end

-- Select a tab
function MafuyoLib:selectTab(name)
    for _, tab in ipairs(self.tabs) do
        if tab.name == name then
            tab.button.BackgroundColor3 = config.accentColor
            tab.frame.Visible = true
            self.activeTab = tab
        else
            tab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            tab.frame.Visible = false
        end
    end
end

-- Add a button to a tab
function MafuyoLib:addButton(tabName, text, callback)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local button = Instance.new("TextButton")
            button.Name = text .. "Button"
            button.Size = UDim2.new(1, 0, 0, 30)
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = config.textColor
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.Parent = tab.frame
            
            -- Add corner radius
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = button
            
            -- Button hover effect
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end)
            
            -- Button click handler
            button.MouseButton1Click:Connect(callback)
            
            return button
        end
    end
end

-- Add a toggle to a tab
function MafuyoLib:addToggle(tabName, text, default, callback)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local toggleContainer = Instance.new("Frame")
            toggleContainer.Name = text .. "ToggleContainer"
            toggleContainer.Size = UDim2.new(1, 0, 0, 30)
            toggleContainer.BackgroundTransparency = 1
            toggleContainer.Parent = tab.frame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Name = "Label"
            toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = text
            toggleLabel.TextColor3 = config.textColor
            toggleLabel.TextSize = 14
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleContainer
            
            local toggleButton = Instance.new("Frame")
            toggleButton.Name = "ToggleButton"
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -40, 0.5, -10)
            toggleButton.BackgroundColor3 = default and config.accentColor or Color3.fromRGB(60, 60, 60)
            toggleButton.Parent = toggleContainer
            
            -- Add corner radius
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = toggleButton
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.Parent = toggleButton
            
            -- Add corner radius to circle
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle
            
            -- Make the whole container clickable
            local toggleClick = Instance.new("TextButton")
            toggleClick.Name = "ClickArea"
            toggleClick.Size = UDim2.new(1, 0, 1, 0)
            toggleClick.BackgroundTransparency = 1
            toggleClick.Text = ""
            toggleClick.Parent = toggleContainer
            
            local enabled = default or false
            
            toggleClick.MouseButton1Click:Connect(function()
                enabled = not enabled
                
                toggleButton.BackgroundColor3 = enabled and config.accentColor or Color3.fromRGB(60, 60, 60)
                toggleCircle:TweenPosition(
                    enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Enum.EasingDirection.InOut,
                    Enum.EasingStyle.Quad,
                    0.15,
                    true
                )
                
                if callback then
                    callback(enabled)
                end
            end)
            
            return toggleContainer
        end
    end
end

-- Add a slider to a tab
function MafuyoLib:addSlider(tabName, text, min, max, default, callback)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local sliderContainer = Instance.new("Frame")
            sliderContainer.Name = text .. "SliderContainer"
            sliderContainer.Size = UDim2.new(1, 0, 0, 50)
            sliderContainer.BackgroundTransparency = 1
            sliderContainer.Parent = tab.frame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Name = "Label"
            sliderLabel.Size = UDim2.new(1, 0, 0, 20)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = text
            sliderLabel.TextColor3 = config.textColor
            sliderLabel.TextSize = 14
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderContainer
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "Value"
            valueLabel.Size = UDim2.new(0, 40, 0, 20)
            valueLabel.Position = UDim2.new(1, -40, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = config.textColor
            valueLabel.TextSize = 14
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.Parent = sliderContainer
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Name = "Track"
            sliderTrack.Size = UDim2.new(1, 0, 0, 6)
            sliderTrack.Position = UDim2.new(0, 0, 0.7, 0)
            sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderContainer
            
            -- Add corner radius
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = sliderTrack
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = config.accentColor
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            
            -- Add corner radius
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Name = "SliderButton"
            sliderButton.Size = UDim2.new(0, 16, 0, 16)
            sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.7, -5)
            sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderButton.Text = ""
            sliderButton.Parent = sliderContainer
            
            -- Add corner radius
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(1, 0)
            buttonCorner.Parent = sliderButton
            
            -- Make the whole track clickable
            local trackButton = Instance.new("TextButton")
            trackButton.Name = "TrackButton"
            trackButton.Size = UDim2.new(1, 0, 0, 20)
            trackButton.Position = UDim2.new(0, 0, 0.6, -7)
            trackButton.BackgroundTransparency = 1
            trackButton.Text = ""
            trackButton.Parent = sliderContainer
            
            local value = default
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(min + (max - min) * pos)
                
                value = newValue
                valueLabel.Text = tostring(value)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                sliderButton.Position = UDim2.new(pos, -8, 0.7, -5)
                
                if callback then
                    callback(value)
                end
            end
            
            local dragging = false
            
            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            sliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            trackButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(input)
                    dragging = true
                end
            end)
            
            trackButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            return sliderContainer
        end
    end
end

-- Add a text input to a tab
function MafuyoLib:addTextbox(tabName, text, placeholder, callback)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local textboxContainer = Instance.new("Frame")
            textboxContainer.Name = text .. "TextboxContainer"
            textboxContainer.Size = UDim2.new(1, 0, 0, 50)
            textboxContainer.BackgroundTransparency = 1
            textboxContainer.Parent = tab.frame
            
            local textboxLabel = Instance.new("TextLabel")
            textboxLabel.Name = "Label"
            textboxLabel.Size = UDim2.new(1, 0, 0, 20)
            textboxLabel.BackgroundTransparency = 1
            textboxLabel.Text = text
            textboxLabel.TextColor3 = config.textColor
            textboxLabel.TextSize = 14
            textboxLabel.Font = Enum.Font.Gotham
            textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            textboxLabel.Parent = textboxContainer
            
            local textbox = Instance.new("TextBox")
            textbox.Name = "Textbox"
            textbox.Size = UDim2.new(1, 0, 0, 30)
            textbox.Position = UDim2.new(0, 0, 0.5, 0)
            textbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            textbox.BorderSizePixel = 0
            textbox.PlaceholderText = placeholder or ""
            textbox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
            textbox.Text = ""
            textbox.TextColor3 = config.textColor
            textbox.TextSize = 14
            textbox.Font = Enum.Font.Gotham
            textbox.Parent = textboxContainer
            
            -- Add corner radius
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = textbox
            
            -- Add padding
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.Parent = textbox
            
            -- Textbox focus/unfocus effects
            textbox.Focused:Connect(function()
                textbox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            textbox.FocusLost:Connect(function(enterPressed)
                textbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                
                if enterPressed and callback then
                    callback(textbox.Text)
                end
            end)
            
            return textboxContainer
        end
    end
end

-- Add a dropdown to a tab
function MafuyoLib:addDropdown(tabName, text, options, callback)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local dropdownContainer = Instance.new("Frame")
            dropdownContainer.Name = text .. "DropdownContainer"
            dropdownContainer.Size = UDim2.new(1, 0, 0, 50)
            dropdownContainer.BackgroundTransparency = 1
            dropdownContainer.Parent = tab.frame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Name = "Label"
            dropdownLabel.Size = UDim2.new(1, 0, 0, 20)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Text = text
            dropdownLabel.TextColor3 = config.textColor
            dropdownLabel.TextSize = 14
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownContainer
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "DropdownButton"
            dropdownButton.Size = UDim2.new(1, 0, 0, 30)
            dropdownButton.Position = UDim2.new(0, 0, 0.5, 0)
            dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            dropdownButton.BorderSizePixel = 0
            dropdownButton.Text = options[1] or "Select..."
            dropdownButton.TextColor3 = config.textColor
            dropdownButton.TextSize = 14
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.Parent = dropdownContainer
            
            -- Add corner radius
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = dropdownButton
            
            -- Add arrow icon
            local arrow = Instance.new("TextLabel")
            arrow.Name = "Arrow"
            arrow.Size = UDim2.new(0, 20, 0, 20)
            arrow.Position = UDim2.new(1, -25, 0.5, -10)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = config.textColor
            arrow.TextSize = 14
            arrow.Font = Enum.Font.Gotham
            arrow.Parent = dropdownButton
            
            -- Create dropdown menu
            local dropdownMenu = Instance.new("Frame")
            dropdownMenu.Name = "DropdownMenu"
            dropdownMenu.Size = UDim2.new(1, 0, 0, #options * 30)
            dropdownMenu.Position = UDim2.new(0, 0, 1, 5)
            dropdownMenu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            dropdownMenu.BorderSizePixel = 0
            dropdownMenu.Visible = false
            dropdownMenu.ZIndex = 10
            dropdownMenu.Parent = dropdownButton
            
            -- Add corner radius
            local menuCorner = Instance.new("UICorner")
            menuCorner.CornerRadius = UDim.new(0, 4)
            menuCorner.Parent = dropdownMenu
            
            -- Create option buttons
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = option .. "Option"
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
                optionButton.BackgroundTransparency = 1
                optionButton.Text = option
                optionButton.TextColor3 = config.textColor
                optionButton.TextSize = 14
                optionButton.Font = Enum.Font.Gotham
                optionButton.ZIndex = 10
                optionButton.Parent = dropdownMenu
                
                -- Option hover effect
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundTransparency = 0.8
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundTransparency = 1
                end)
                
                -- Option click handler
                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    dropdownMenu.Visible = false
                    arrow.Text = "▼"
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            -- Toggle dropdown menu
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownMenu.Visible = not dropdownMenu.Visible
                arrow.Text = dropdownMenu.Visible and "▲" or "▼"
            end)
            
            -- Close dropdown when clicking elsewhere
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local guiObjects = game:GetService("Players").LocalPlayer:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
                    local isInDropdown = false
                    
                    for _, obj in ipairs(guiObjects) do
                        if obj:IsDescendantOf(dropdownMenu) or obj == dropdownButton then
                            isInDropdown = true
                            break
                        end
                    end
                    
                    if not isInDropdown and dropdownMenu.Visible then
                        dropdownMenu.Visible = false
                        arrow.Text = "▼"
                    end
                end
            end)
            
            return dropdownContainer
        end
    end
end

-- Add a color picker to a tab
function MafuyoLib:addColorPicker(tabName, text, default, callback)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local colorPickerContainer = Instance.new("Frame")
            colorPickerContainer.Name = text .. "ColorPickerContainer"
            colorPickerContainer.Size = UDim2.new(1, 0, 0, 50)
            colorPickerContainer.BackgroundTransparency = 1
            colorPickerContainer.Parent = tab.frame
            
            local colorPickerLabel = Instance.new("TextLabel")
            colorPickerLabel.Name = "Label"
            colorPickerLabel.Size = UDim2.new(1, -50, 0, 20)
            colorPickerLabel.BackgroundTransparency = 1
            colorPickerLabel.Text = text
            colorPickerLabel.TextColor3 = config.textColor
            colorPickerLabel.TextSize = 14
            colorPickerLabel.Font = Enum.Font.Gotham
            colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
            colorPickerLabel.Parent = colorPickerContainer
            
            local colorDisplay = Instance.new("Frame")
            colorDisplay.Name = "ColorDisplay"
            colorDisplay.Size = UDim2.new(0, 30, 0, 30)
            colorDisplay.Position = UDim2.new(1, -40, 0.5, -15)
            colorDisplay.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
            colorDisplay.BorderSizePixel = 0
            colorDisplay.Parent = colorPickerContainer
            
            -- Add corner radius
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = colorDisplay
            
            -- Make color display clickable
            local colorButton = Instance.new("TextButton")
            colorButton.Name = "ColorButton"
            colorButton.Size = UDim2.new(1, 0, 1, 0)
            colorButton.BackgroundTransparency = 1
            colorButton.Text = ""
            colorButton.Parent = colorDisplay
            
            -- Create color picker popup
            local colorPicker = Instance.new("Frame")
            colorPicker.Name = "ColorPicker"
            colorPicker.Size = UDim2.new(0, 200, 0, 220)
            colorPicker.Position = UDim2.new(1, -200, 1, 10)
            colorPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            colorPicker.BorderSizePixel = 0
            colorPicker.Visible = false
            colorPicker.ZIndex = 10
            colorPicker.Parent = colorPickerContainer
            
            -- Add corner radius
            local pickerCorner = Instance.new("UICorner")
            pickerCorner.CornerRadius = UDim.new(0, 4)
            pickerCorner.Parent = colorPicker
            
            -- Create color palette
            local colorPalette = Instance.new("ImageLabel")
            colorPalette.Name = "ColorPalette"
            colorPalette.Size = UDim2.new(0, 180, 0, 180)
            colorPalette.Position = UDim2.new(0.5, -90, 0, 10)
            colorPalette.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            colorPalette.BorderSizePixel = 0
            colorPalette.Image = "rbxassetid://3157191308"
            colorPalette.ZIndex = 10
            colorPalette.Parent = colorPicker
            
            -- Add corner radius
            local paletteCorner = Instance.new("UICorner")
            paletteCorner.CornerRadius = UDim.new(0, 4)
            paletteCorner.Parent = colorPalette
            
            -- Create color selector
            local colorSelector = Instance.new("Frame")
            colorSelector.Name = "ColorSelector"
            colorSelector.Size = UDim2.new(0, 10, 0, 10)
            colorSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            colorSelector.BorderSizePixel = 0
            colorSelector.ZIndex = 11
            colorSelector.Parent = colorPalette
            
            -- Add corner radius
            local selectorCorner = Instance.new("UICorner")
            selectorCorner.CornerRadius = UDim.new(1, 0)
            selectorCorner.Parent = colorSelector
            
            -- Create apply button
            local applyButton = Instance.new("TextButton")
            applyButton.Name = "ApplyButton"
            applyButton.Size = UDim2.new(0, 180, 0, 20)
            applyButton.Position = UDim2.new(0.5, -90, 1, -25)
            applyButton.BackgroundColor3 = config.accentColor
            applyButton.BorderSizePixel = 0
            applyButton.Text = "Apply"
            applyButton.TextColor3 = config.textColor
            applyButton.TextSize = 14
            applyButton.Font = Enum.Font.Gotham
            applyButton.ZIndex = 10
            applyButton.Parent = colorPicker
            
            -- Add corner radius
            local applyCorner = Instance.new("UICorner")
            applyCorner.CornerRadius = UDim.new(0, 4)
            applyCorner.Parent = applyButton
            
            -- Toggle color picker
            colorButton.MouseButton1Click:Connect(function()
                colorPicker.Visible = not colorPicker.Visible
            end)
            
            -- Color palette functionality
            local selectedColor = default or Color3.fromRGB(255, 255, 255)
            
            local function updateColor(input)
                local relativeX = math.clamp((input.Position.X - colorPalette.AbsolutePosition.X) / colorPalette.AbsoluteSize.X, 0, 1)
                local relativeY = math.clamp((input.Position.Y - colorPalette.AbsolutePosition.Y) / colorPalette.AbsoluteSize.Y, 0, 1)
                
                colorSelector.Position = UDim2.new(relativeX, -5, relativeY, -5)
                
                -- Convert position to HSV, then to RGB
                local h = 1 - relativeX
                local s = relativeY
                local v = 1
                
                -- HSV to RGB conversion
                local hi = math.floor(h * 6)
                local f = h * 6 - hi
                local p = v * (1 - s)
                local q = v * (1 - f * s)
                local t = v * (1 - (1 - f) * s)
                
                local r, g, b
                
                if hi == 0 or hi == 6 then
                    r, g, b = v, t, p
                elseif hi == 1 then
                    r, g, b = q, v, p
                elseif hi == 2 then
                    r, g, b = p, v, t
                elseif hi == 3 then
                    r, g, b = p, q, v
                elseif hi == 4 then
                    r, g, b = t, p, v
                elseif hi == 5 then
                    r, g, b = v, p, q
                end
                
                selectedColor = Color3.fromRGB(r * 255, g * 255, b * 255)
            end
            
            local dragging = false
            
            colorPalette.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateColor(input)
                end
            end)
            
            colorPalette.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateColor(input)
                end
            end)
            
            -- Apply button functionality
            applyButton.MouseButton1Click:Connect(function()
                colorDisplay.BackgroundColor3 = selectedColor
                colorPicker.Visible = false
                
                if callback then
                    callback(selectedColor)
                end
            end)
            
            -- Close color picker when clicking elsewhere
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local guiObjects = game:GetService("Players").LocalPlayer:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
                    local isInColorPicker = false
                    
                    for _, obj in ipairs(guiObjects) do
                        if obj:IsDescendantOf(colorPicker) or obj == colorDisplay then
                            isInColorPicker = true
                            break
                        end
                    end
                    
                    if not isInColorPicker and colorPicker.Visible then
                        colorPicker.Visible = false
                    end
                end
            end)
            
            return colorPickerContainer
        end
    end
end

-- Add a label to a tab
function MafuyoLib:addLabel(tabName, text)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local label = Instance.new("TextLabel")
            label.Name = text .. "Label"
            label.Size = UDim2.new(1, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = config.textColor
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tab.frame
            
            return label
        end
    end
end

-- Add a separator to a tab
function MafuyoLib:addSeparator(tabName)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            local separator = Instance.new("Frame")
            separator.Name = "Separator"
            separator.Size = UDim2.new(1, 0, 0, 1)
            separator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            separator.BorderSizePixel = 0
            separator.Parent = tab.frame
            
            return separator
        end
    end
end

return MafuyoLib
