-- Mafuyo UI Library (Improved Version)
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
    
    -- Handle parent
    if parent == nil then
        parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create ScreenGui with protection
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "MafuyoUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Apply protection if possible
    pcall(function()
        self.gui.IgnoreGuiInset = true
        if syn and syn.protect_gui then
            syn.protect_gui(self.gui)
        end
    end)
    
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
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = self.main
    
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
    
    -- Fix the bottom corners of title bar
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Name = "BottomFrame"
    bottomFrame.Size = UDim2.new(1, 0, 0, 10)
    bottomFrame.Position = UDim2.new(0, 0, 1, -10)
    bottomFrame.BackgroundColor3 = config.accentColor
    bottomFrame.BorderSizePixel = 0
    bottomFrame.ZIndex = self.titleBar.ZIndex
    bottomFrame.Parent = self.titleBar
    
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
    self.toggleButton.Visible = false  -- Initially not visible
    self.toggleButton.ZIndex = 10  -- Make sure it's above other elements
    self.toggleButton.Parent = self.gui
    
    -- Add shadow to toggle button
    local toggleShadow = Instance.new("ImageLabel")
    toggleShadow.Name = "Shadow"
    toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleShadow.BackgroundTransparency = 1
    toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleShadow.Size = UDim2.new(1, 15, 1, 15)
    toggleShadow.ZIndex = 9
    toggleShadow.Image = "rbxassetid://6014261993"
    toggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    toggleShadow.ImageTransparency = 0.5
    toggleShadow.ScaleType = Enum.ScaleType.Slice
    toggleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    toggleShadow.Parent = self.toggleButton
    
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
    
    -- Add corner radius to tabs container
    local tabsCorner = Instance.new("UICorner")
    tabsCorner.CornerRadius = UDim.new(0, 4)
    tabsCorner.Parent = self.tabsContainer
    
    -- Fix the top corners of tabs container
    local topFrame = Instance.new("Frame")
    topFrame.Name = "TopFrame"
    topFrame.Size = UDim2.new(1, 0, 0, 10)
    topFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    topFrame.BorderSizePixel = 0
    topFrame.ZIndex = self.tabsContainer.ZIndex
    topFrame.Parent = self.tabsContainer
    
    -- Create tab content container
    self.tabContent = Instance.new("Frame")
    self.tabContent.Name = "TabContent"
    self.tabContent.Size = UDim2.new(1, 0, 1, -30)
    self.tabContent.Position = UDim2.new(0, 0, 0, 30)
    self.tabContent.BackgroundTransparency = 1
    self.tabContent.Parent = self.content
    
    self.tabs = {}
    self.activeTab = nil
    
    -- Add notification system
    self.notifications = {}
    self.notificationContainer = Instance.new("Frame")
    self.notificationContainer.Name = "NotificationContainer"
    self.notificationContainer.Size = UDim2.new(0, 250, 1, 0)
    self.notificationContainer.Position = UDim2.new(1, -260, 0, 0)
    self.notificationContainer.BackgroundTransparency = 1
    self.notificationContainer.Parent = self.gui
    
    return self
end

-- Set up dragging functionality with improved performance
function MafuyoLib:setupDragging()
    local UserInputService = game:GetService("UserInputService")
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
            
            -- Disconnect previous connection if it exists
            if self.dragConnection then
                self.dragConnection:Disconnect()
            end
            
            self.dragConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if self.dragConnection then
                        self.dragConnection:Disconnect()
                        self.dragConnection = nil
                    end
                end
            end)
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    -- Disconnect previous connection if it exists
    if self.dragInputConnection then
        self.dragInputConnection:Disconnect()
    end
    
    self.dragInputConnection = UserInputService.InputChanged:Connect(function(input)
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
            -- Set a flag to track if this is a drag or a click
            self.toggleDragging = false
            toggleDragging = true
            toggleDragStart = input.Position
            toggleStartPos = self.toggleButton.Position
            
            -- Disconnect previous connection if it exists
            if self.toggleDragConnection then
                self.toggleDragConnection:Disconnect()
            end
            
            self.toggleDragConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    toggleDragging = false
                    -- If we moved more than 5 pixels, consider it a drag
                    local endPos = input.Position
                    local dragDistance = (endPos - toggleDragStart).Magnitude
                    if dragDistance > 5 then
                        self.toggleDragging = true
                    end
                    
                    -- Small delay to allow click handler to check the flag
                    task.delay(0.1, function()
                        self.toggleDragging = false
                    end)
                    
                    if self.toggleDragConnection then
                        self.toggleDragConnection:Disconnect()
                        self.toggleDragConnection = nil
                    end
                end
            end)
        end
    end)
    
    self.toggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragInput = input
        end
    end)
    
    -- Disconnect previous connection if it exists
    if self.toggleDragInputConnection then
        self.toggleDragInputConnection:Disconnect()
    end
    
    self.toggleDragInputConnection = UserInputService.InputChanged:Connect(function(input)
        if input == toggleDragInput and toggleDragging then
            updateToggleDrag(input)
        end
    end)
end

-- Set up button functionality with improved animations
function MafuyoLib:setupButtons()
    -- Close button
    self.closeButton.MouseButton1Click:Connect(function()
        -- Animate the main UI closing
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(
            self.main, 
            tweenInfo, 
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(self.main.Position.X.Scale, self.main.Position.X.Offset + self.main.AbsoluteSize.X/2, self.main.Position.Y.Scale, self.main.Position.Y.Offset + self.main.AbsoluteSize.Y/2)}
        )
        
        tween.Completed:Connect(function()
            self.main.Visible = false
            self.main.Size = config.defaultSize
            self.main.Position = UDim2.new(self.main.Position.X.Scale, self.main.Position.X.Offset - self.main.AbsoluteSize.X/2, self.main.Position.Y.Scale, self.main.Position.Y.Offset - self.main.AbsoluteSize.Y/2)
            
            -- Show and animate the toggle button
            self.toggleButton.Size = UDim2.new(0, 0, 0, 0)
            self.toggleButton.Visible = true
            
            local toggleTween = game:GetService("TweenService"):Create(
                self.toggleButton,
                tweenInfo,
                {Size = UDim2.new(0, 40, 0, 40)}
            )
            
            toggleTween:Play()
        end)
        
        tween:Play()
    end)
    
    -- Minimize button
    self.minimizeButton.MouseButton1Click:Connect(function()
        if self.content.Visible then
            -- Minimize
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                self.main, 
                tweenInfo, 
                {Size = config.minSize}
            )
            
            tween.Completed:Connect(function()
                self.content.Visible = false
                self.titleText.Text = "M"
                self.minimizeButton.Text = "+"
            end)
            
            tween:Play()
        else
            -- Maximize
            self.content.Visible = true
            self.titleText.Text = config.title
            self.minimizeButton.Text = "-"
            
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                self.main, 
                tweenInfo, 
                {Size = config.defaultSize}
            )
            
            tween:Play()
        end
    end)
    
    -- Toggle button
    self.toggleButton.MouseButton1Click:Connect(function()
        if not self.toggleDragging then
            -- Hide toggle button
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                self.toggleButton,
                tweenInfo,
                {Size = UDim2.new(0, 0, 0, 0)}
            )
            
            tween.Completed:Connect(function()
                self.toggleButton.Visible = false
                self.toggleButton.Size = UDim2.new(0, 40, 0, 40)
                
                -- Show and animate the main UI
                self.main.Size = UDim2.new(0, 0, 0, 0)
                self.main.Position = UDim2.new(self.toggleButton.Position.X.Scale, self.toggleButton.Position.X.Offset, self.toggleButton.Position.Y.Scale, self.toggleButton.Position.Y.Offset)
                self.main.Visible = true
                
                local mainTween = game:GetService("TweenService"):Create(
                    self.main,
                    tweenInfo,
                    {Size = config.defaultSize, Position = UDim2.new(self.toggleButton.Position.X.Scale, self.toggleButton.Position.X.Offset - config.defaultSize.X.Offset/2, self.toggleButton.Position.Y.Scale, self.toggleButton.Position.Y.Offset - config.defaultSize.Y.Offset/2)}
                )
                
                mainTween:Play()
            end)
            
            tween:Play()
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
    tabFrame.ScrollBarImageColor3 = config.accentColor
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
    
    -- Tab button hover effect
    tabButton.MouseEnter:Connect(function()
        if self.activeTab and self.activeTab.name ~= name then
            tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.activeTab and self.activeTab.name ~= name then
            tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
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

-- Select a tab with animation
function MafuyoLib:selectTab(name)
    for _, tab in ipairs(self.tabs) do
        if tab.name == name then
            -- Animate the tab selection
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                tab.button,
                tweenInfo,
                {BackgroundColor3 = config.accentColor}
            )
            
            tween:Play()
            tab.frame.Visible = true
            self.activeTab = tab
        else
            -- Animate the tab deselection
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                tab.button,
                tweenInfo,
                {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}
            )
            
            tween:Play()
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
            
            -- Add ripple effect
            local ripple = Instance.new("Frame")
            ripple.Name = "Ripple"
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.8
            ripple.BorderSizePixel = 0
            ripple.ZIndex = button.ZIndex + 1
            ripple.Visible = false
            
            -- Add corner radius to ripple
            local rippleCorner = Instance.new("UICorner")
            rippleCorner.CornerRadius = UDim.new(1, 0)
            rippleCorner.Parent = ripple
            
            ripple.Parent = button
            
            -- Button hover effect
            button.MouseEnter:Connect(function()
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = game:GetService("TweenService"):Create(
                    button,
                    tweenInfo,
                    {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}
                )
                
                tween:Play()
            end)
            
            button.MouseLeave:Connect(function()
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = game:GetService("TweenService"):Create(
                    button,
                    tweenInfo,
                    {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
                )
                
                tween:Play()
            end)
            
            -- Ripple effect
            button.MouseButton1Down:Connect(function(x, y)
                -- Create ripple effect at mouse position
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                local buttonPos = button.AbsolutePosition
                local buttonSize = button.AbsoluteSize
                
                local rippleX = mousePos.X - buttonPos.X
                local rippleY = mousePos.Y - buttonPos.Y
                
                ripple.Position = UDim2.new(0, rippleX, 0, rippleY)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.Visible = true
                
                local maxSize = math.max(buttonSize.X, buttonSize.Y) * 2
                
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = game:GetService("TweenService"):Create(
                    ripple,
                    tweenInfo,
                    {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1, Position = UDim2.new(0, rippleX - maxSize/2, 0, rippleY - maxSize/2)}
                )
                
                tween.Completed:Connect(function()
                    ripple.Visible = false
                end)
                
                tween:Play()
            end)
            
            -- Button click handler
            button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
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
            
            -- Add shadow to circle
            local circleShadow = Instance.new("ImageLabel")
            circleShadow.Name = "Shadow"
            circleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            circleShadow.BackgroundTransparency = 1
            circleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            circleShadow.Size = UDim2.new(1, 4, 1, 4)
            circleShadow.ZIndex = toggleCircle.ZIndex - 1
            circleShadow.Image = "rbxassetid://6014261993"
            circleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            circleShadow.ImageTransparency = 0.7
            circleShadow.ScaleType = Enum.ScaleType.Slice
            circleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            circleShadow.Parent = toggleCircle
            
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
                
                -- Animate the toggle
                local buttonTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local buttonTween = game:GetService("TweenService"):Create(
                    toggleButton,
                    buttonTweenInfo,
                    {BackgroundColor3 = enabled and config.accentColor or Color3.fromRGB(60, 60, 60)}
                )
                
                local circleTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local circleTween = game:GetService("TweenService"):Create(
                    toggleCircle,
                    circleTweenInfo,
                    {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
                )
                
                buttonTween:Play()
                circleTween:Play()
                
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
            
            -- Add shadow to button
            local buttonShadow = Instance.new("ImageLabel")
            buttonShadow.Name = "Shadow"
            buttonShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            buttonShadow.BackgroundTransparency = 1
            buttonShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            buttonShadow.Size = UDim2.new(1, 4, 1, 4)
            buttonShadow.ZIndex = sliderButton.ZIndex - 1
            buttonShadow.Image = "rbxassetid://6014261993"
            buttonShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            buttonShadow.ImageTransparency = 0.7
            buttonShadow.ScaleType = Enum.ScaleType.Slice
            buttonShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            buttonShadow.Parent = sliderButton
            
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
                
                -- Animate the slider
                local fillTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local fillTween = game:GetService("TweenService"):Create(
                    sliderFill,
                    fillTweenInfo,
                    {Size = UDim2.new(pos, 0, 1, 0)}
                )
                
                local buttonTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local buttonTween = game:GetService("TweenService"):Create(
                    sliderButton,
                    buttonTweenInfo,
                    {Position = UDim2.new(pos, -8, 0.7, -5)}
                )
                
                fillTween:Play()
                buttonTween:Play()
                
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

-- Add notification system
function MafuyoLib:notify(title, message, duration)
    duration = duration or 5
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 240, 0, 0)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.Position = UDim2.new(0, 0, 0, #self.notifications * 80)
    notification.Parent = self.notificationContainer
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notification
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 15, 1, 15)
    shadow.ZIndex = notification.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = notification
    
    -- Create title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = config.textColor
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
        -- Create message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -10, 0, 40)
    messageLabel.Position = UDim2.new(0, 5, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = config.textColor
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = notification
    
    -- Add notification to list
    table.insert(self.notifications, notification)
    
    -- Animate notification in
    notification:TweenSize(
        UDim2.new(0, 240, 0, 75),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    
    -- Close button handler
    closeButton.MouseButton1Click:Connect(function()
        self:removeNotification(notification)
    end)
    
    -- Auto close after duration
    task.delay(duration, function()
        self:removeNotification(notification)
    end)
    
    return notification
end

-- Remove notification
function MafuyoLib:removeNotification(notification)
    -- Find notification index
    local index = table.find(self.notifications, notification)
    if not index then return end
    
    -- Remove from list
    table.remove(self.notifications, index)
    
    -- Animate notification out
    notification:TweenSize(
        UDim2.new(0, 240, 0, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true,
        function()
            notification:Destroy()
        end
    )
    
    -- Reposition other notifications
    for i, notif in ipairs(self.notifications) do
        notif:TweenPosition(
            UDim2.new(0, 0, 0, (i - 1) * 80),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
    end
end

-- Set theme
function MafuyoLib:setTheme(theme)
    if type(theme) ~= "table" then return end
    
    -- Update config
    for key, value in pairs(theme) do
        if config[key] and typeof(config[key]) == typeof(value) then
            config[key] = value
        end
    end
    
    -- Update UI elements
    self.main.BackgroundColor3 = config.defaultColor
    self.titleBar.BackgroundColor3 = config.accentColor
    self.titleText.TextColor3 = config.textColor
    
    -- Update bottom frame
    if self.titleBar:FindFirstChild("BottomFrame") then
        self.titleBar.BottomFrame.BackgroundColor3 = config.accentColor
    end
    
    -- Update tabs
    if self.activeTab then
        self.activeTab.button.BackgroundColor3 = config.accentColor
    end
    
    -- Update toggle button
    self.toggleButton.BackgroundColor3 = config.accentColor
    
    -- Update all toggles
    for _, tab in ipairs(self.tabs) do
        for _, child in ipairs(tab.frame:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("ToggleContainer$") then
                local toggleButton = child:FindFirstChild("ToggleButton")
                if toggleButton then
                    local circle = toggleButton:FindFirstChild("Circle")
                    if circle and circle.Position.X.Scale > 0.5 then
                        toggleButton.BackgroundColor3 = config.accentColor
                    end
                end
            end
        end
    end
    
    -- Update all sliders
    for _, tab in ipairs(self.tabs) do
        for _, child in ipairs(tab.frame:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("SliderContainer$") then
                local track = child:FindFirstChild("Track")
                if track then
                    local fill = track:FindFirstChild("Fill")
                    if fill then
                        fill.BackgroundColor3 = config.accentColor
                    end
                end
            end
        end
    end
end

-- Destroy the UI
function MafuyoLib:destroy()
    -- Disconnect all connections
    if self.dragConnection then
        self.dragConnection:Disconnect()
    end
    
    if self.dragInputConnection then
        self.dragInputConnection:Disconnect()
    end
    
    if self.toggleDragConnection then
        self.toggleDragConnection:Disconnect()
    end
    
    if self.toggleDragInputConnection then
        self.toggleDragInputConnection:Disconnect()
    end
    
    -- Destroy the GUI
    self.gui:Destroy()
end

return MafuyoLib
