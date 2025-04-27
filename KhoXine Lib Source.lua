--[[
    Mafuyo UI Library
    A sleek UI library for Roblox scripting tools
    
    Features:
    - Draggable UI windows
    - Small logo to toggle UI visibility
    - Comprehensive UI elements
    - Notification system
    - Clean, modern design
]]

local Mafuyo = {}
Mafuyo.__index = Mafuyo

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Constants
local TOGGLE_KEY = Enum.KeyCode.RightShift
local DRAG_SPEED = 0.1
local TWEEN_SPEED = 0.2

-- Theme
local Theme = {
    -- Main Colors
    Background = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(255, 0, 0), -- Red accent
    Text = Color3.fromRGB(255, 255, 255),
    DarkText = Color3.fromRGB(175, 175, 175),
    
    -- UI Elements
    TopBar = Color3.fromRGB(30, 30, 30),
    Section = Color3.fromRGB(35, 35, 35),
    Button = Color3.fromRGB(40, 40, 40),
    ButtonHover = Color3.fromRGB(50, 50, 50),
    Toggle = Color3.fromRGB(40, 40, 40),
    ToggleAccent = Color3.fromRGB(255, 0, 0),
    Slider = Color3.fromRGB(40, 40, 40),
    SliderAccent = Color3.fromRGB(255, 0, 0),
    Dropdown = Color3.fromRGB(40, 40, 40),
    
    -- Notification
    NotificationBackground = Color3.fromRGB(35, 35, 35),
    NotificationSuccess = Color3.fromRGB(0, 255, 0),
    NotificationError = Color3.fromRGB(255, 0, 0),
    NotificationInfo = Color3.fromRGB(0, 170, 255),
    NotificationWarning = Color3.fromRGB(255, 255, 0),
    
    -- Logo
    LogoBackground = Color3.fromRGB(30, 30, 30),
    LogoAccent = Color3.fromRGB(255, 0, 0),
}

-- Utility Functions
local function Create(instanceType)
    return function(properties)
        local instance = Instance.new(instanceType)
        for property, value in pairs(properties) do
            if property ~= "Parent" then
                instance[property] = value
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
        return instance
    end
end

local function MakeDraggable(topBarObject, object)
    local Dragging = false
    local DragInput, MousePos, FramePos
    
    topBarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MousePos = input.Position
            FramePos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    topBarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - MousePos
            TweenService:Create(object, TweenInfo.new(DRAG_SPEED), {
                Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
            }):Play()
        end
    end)
end

local function Tween(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or TWEEN_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function RoundBox(radius)
    return Create("UICorner")({
        CornerRadius = UDim.new(0, radius or 4)
    })
end

local function Shadow(instance, size, transparency)
    local shadow = Create("ImageLabel")({
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 12, 1, size or 12),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = instance
    })
    return shadow
end

-- Notification System
local NotificationHolder = nil

local function CreateNotificationHolder()
    if NotificationHolder then return NotificationHolder end
    
    NotificationHolder = Create("ScreenGui")({
        Name = "MafuyoNotifications",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })
    
    local Frame = Create("Frame")({
        Name = "NotificationFrame",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = NotificationHolder
    })
    
    local UIListLayout = Create("UIListLayout")({
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = Frame
    })
    
    return NotificationHolder
end

function Mafuyo:Notify(title, message, notificationType, duration)
    notificationType = notificationType or "Info"
    duration = duration or 5
    
    local typeColors = {
        Success = Theme.NotificationSuccess,
        Error = Theme.NotificationError,
        Info = Theme.NotificationInfo,
        Warning = Theme.NotificationWarning
    }
    
    local color = typeColors[notificationType] or Theme.NotificationInfo
    
    local Holder = CreateNotificationHolder()
    local Frame = Holder.NotificationFrame
    
    local Notification = Create("Frame")({
        Name = "Notification",
        BackgroundColor3 = Theme.NotificationBackground,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = Frame
    })
    
    RoundBox(6).Parent = Notification
    Shadow(Notification, 15, 0.2)
    
    local Bar = Create("Frame")({
        Name = "Bar",
        BackgroundColor3 = color,
        Size = UDim2.new(0, 5, 1, 0),
        Parent = Notification
    })
    
    RoundBox(6).Parent = Bar
    
    local Content = Create("Frame")({
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -15, 1, 0),
        Parent = Notification
    })
    
    local Title = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, -10, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Content
    })
    
    local Message = Create("TextLabel")({
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, -10, 0, 0),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = Theme.DarkText,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = Content
    })
    
    -- Calculate text height
    local textSize = game:GetService("TextService"):GetTextSize(
        Message.Text,
        Message.TextSize,
        Message.Font,
        Vector2.new(Message.AbsoluteSize.X, math.huge)
    )
    
    local height = math.max(60, textSize.Y + 40)
    Message.Size = UDim2.new(1, -10, 0, textSize.Y)
    
    -- Animate in
    Notification.Size = UDim2.new(1, 0, 0, height)
    Notification.BackgroundTransparency = 1
    Bar.BackgroundTransparency = 1
    Title.TextTransparency = 1
    Message.TextTransparency = 1
    
    Tween(Notification, {BackgroundTransparency = 0}, 0.3)
    Tween(Bar, {BackgroundTransparency = 0}, 0.3)
    Tween(Title, {TextTransparency = 0}, 0.3)
    Tween(Message, {TextTransparency = 0}, 0.3)
    
    -- Progress bar
    local ProgressBar = Create("Frame")({
        Name = "ProgressBar",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = Notification
    })
    
    Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration)
    
    -- Remove after duration
    task.delay(duration, function()
        Tween(Notification, {BackgroundTransparency = 1}, 0.3)
        Tween(Bar, {BackgroundTransparency = 1}, 0.3)
        Tween(Title, {TextTransparency = 1}, 0.3)
        Tween(Message, {TextTransparency = 1}, 0.3)
        Tween(ProgressBar, {BackgroundTransparency = 1}, 0.3)
        
        task.wait(0.35)
        Notification:Destroy()
    end)
    
    return Notification
end

-- Create Logo
function Mafuyo:CreateLogo()
    -- Create logo container
    local LogoFrame = Create("Frame")({
        Name = "MafuyoLogo",
        BackgroundColor3 = Theme.LogoBackground,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(0, 50, 0, 50),
        ZIndex = 1000,
        Parent = self.GUI
    })
    
    RoundBox(8).Parent = LogoFrame
    Shadow(LogoFrame, 10, 0.3)
    
    -- Create logo accent
    local LogoAccent = Create("Frame")({
        Name = "Accent",
        BackgroundColor3 = Theme.LogoAccent,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 1001,
        Parent = LogoFrame
    })
    
    RoundBox(8).Parent = LogoAccent
    
    -- Create logo text
    local LogoText = Create("TextLabel")({
        Name = "Text",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "M",
        TextColor3 = Theme.Text,
        TextSize = 24,
        ZIndex = 1001,
        Parent = LogoFrame
    })
    
    -- Create hitbox
    local LogoButton = Create("TextButton")({
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 1002,
        Parent = LogoFrame
    })
    
    -- Make logo draggable
    MakeDraggable(LogoFrame, LogoFrame)
    
    -- Logo click functionality
    LogoButton.MouseButton1Click:Connect(function()
        self.Toggled = not self.Toggled
        
        for _, window in pairs(self.Windows) do
            window.Frame.Visible = self.Toggled
        end
        
        -- Animate logo
        if self.Toggled then
            Tween(LogoFrame, {Rotation = 0}, 0.3)
            Tween(LogoAccent, {BackgroundColor3 = Theme.LogoAccent}, 0.3)
        else
            Tween(LogoFrame, {Rotation = 45}, 0.3)
            Tween(LogoAccent, {BackgroundColor3 = Theme.DarkText}, 0.3)
        end
    end)
    
    -- Logo hover effects
    LogoButton.MouseEnter:Connect(function()
        Tween(LogoFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
    end)
    
    LogoButton.MouseLeave:Connect(function()
        Tween(LogoFrame, {BackgroundColor3 = Theme.LogoBackground}, 0.2)
    end)
    
    return LogoFrame
end

-- Main UI Creation
function Mafuyo.new()
    local self = setmetatable({}, Mafuyo)
    
    -- Create main GUI
    self.GUI = Create("ScreenGui")({
        Name = "MafuyoUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })
    
    -- Create logo
    self.Logo = self:CreateLogo()
    
    -- Create watermark
    self.Watermark = Create("Frame")({
        Name = "Watermark",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 80, 0, 20),
        Size = UDim2.new(0, 200, 0, 30),
        Parent = self.GUI
    })
    
    RoundBox(6).Parent = self.Watermark
    Shadow(self.Watermark)
    
    local WatermarkLabel = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Mafuyo | v1.0.0",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Parent = self.Watermark
    })
    
    local WatermarkAccent = Create("Frame")({
        Name = "Accent",
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = self.Watermark
    })
    
    RoundBox(6).Parent = WatermarkAccent
    
    -- Toggle UI with keybind
    self.Toggled = true
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == TOGGLE_KEY then
            self.Toggled = not self.Toggled
            
            for _, window in pairs(self.Windows) do
                window.Frame.Visible = self.Toggled
            end
            
            -- Animate logo
            if self.Toggled then
                Tween(self.Logo, {Rotation = 0}, 0.3)
                Tween(self.Logo.Accent, {BackgroundColor3 = Theme.LogoAccent}, 0.3)
            else
                Tween(self.Logo, {Rotation = 45}, 0.3)
                Tween(self.Logo.Accent, {BackgroundColor3 = Theme.DarkText}, 0.3)
            end
        end
    end)
    
    -- Initialize windows table
    self.Windows = {}
    
    -- Initialize keybinds
    self.Keybinds = {}
    
    -- Process keybinds
    RunService.Heartbeat:Connect(function()
        for key, callback in pairs(self.Keybinds) do
            if UserInputService:IsKeyDown(key) then
                callback()
            end
        end
    end)
    
    return self
end

function Mafuyo:CreateWindow(title)
    title = title or "Mafuyo"
    
    -- Create window
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    -- Create main frame
    Window.Frame = Create("Frame")({
        Name = "Window",
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Parent = self.GUI
    })
    
    RoundBox(6).Parent = Window.Frame
    Shadow(Window.Frame)
    
    -- Create top bar
    Window.TopBar = Create("Frame")({
        Name = "TopBar",
        BackgroundColor3 = Theme.TopBar,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = Window.Frame
    })
    
    local topBarCorner = RoundBox(6)
    topBarCorner.Parent = Window.TopBar
    
    -- Make window draggable
    MakeDraggable(Window.TopBar, Window.Frame)

        -- Create title
    Window.Title = Create("TextLabel")({
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window.TopBar
    })
    
    -- Create close button
    Window.CloseButton = Create("TextButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Parent = Window.TopBar
    })
    
    Window.CloseButton.MouseButton1Click:Connect(function()
        Window.Frame.Visible = false
        self.Toggled = false
        
        -- Animate logo
        Tween(self.Logo, {Rotation = 45}, 0.3)
        Tween(self.Logo.Accent, {BackgroundColor3 = Theme.DarkText}, 0.3)
    end)
    
    -- Create minimize button
    Window.MinimizeButton = Create("TextButton")({
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Parent = Window.TopBar
    })
    
    local minimized = false
    local originalSize = Window.Frame.Size
    
    Window.MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            Tween(Window.Frame, {Size = UDim2.new(0, 600, 0, 30)})
            for _, tab in pairs(Window.Tabs) do
                tab.Frame.Visible = false
            end
        else
            Tween(Window.Frame, {Size = originalSize})
            if Window.ActiveTab then
                Window.ActiveTab.Frame.Visible = true
            end
        end
    end)
    
    -- Create tab container
    Window.TabContainer = Create("Frame")({
        Name = "TabContainer",
        BackgroundColor3 = Theme.TopBar,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = Window.Frame
    })
    
    -- Create tab button holder
    Window.TabButtonHolder = Create("ScrollingFrame")({
        Name = "TabButtonHolder",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Parent = Window.TabContainer
    })
    
    local TabButtonList = Create("UIListLayout")({
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = Window.TabButtonHolder
    })
    
    local TabButtonPadding = Create("UIPadding")({
        PaddingLeft = UDim.new(0, 5),
        Parent = Window.TabButtonHolder
    })
    
    -- Create tab content container
    Window.TabContentContainer = Create("Frame")({
        Name = "TabContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60),
        Parent = Window.Frame
    })
    
    -- Tab creation function
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Sections = {}
        
        -- Create tab button
        Tab.Button = Create("TextButton")({
            Name = name.."Button",
            BackgroundColor3 = Theme.Button,
            Size = UDim2.new(0, 100, 1, -5),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = Theme.DarkText,
            TextSize = 12,
            Parent = Window.TabButtonHolder
        })
        
        RoundBox(4).Parent = Tab.Button
        
        -- Create tab content frame
        Tab.Frame = Create("ScrollingFrame")({
            Name = name.."Tab",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            Parent = Window.TabContentContainer
        })
        
        local ContentList = Create("UIListLayout")({
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = Tab.Frame
        })
        
        local ContentPadding = Create("UIPadding")({
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            Parent = Tab.Frame
        })
        
        -- Update canvas size when elements are added
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Frame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab button functionality
        Tab.Button.MouseButton1Click:Connect(function()
            -- Deselect all tabs
            for _, tab in pairs(Window.Tabs) do
                Tween(tab.Button, {BackgroundColor3 = Theme.Button})
                Tween(tab.Button, {TextColor3 = Theme.DarkText})
                tab.Frame.Visible = false
            end
            
            -- Select this tab
            Tween(Tab.Button, {BackgroundColor3 = Theme.Accent})
            Tween(Tab.Button, {TextColor3 = Theme.Text})
            Tab.Frame.Visible = true
            Window.ActiveTab = Tab
        end)
        
        -- Section creation function
        function Tab:CreateSection(name)
            local Section = {}
            Section.Name = name
            
            -- Create section frame
            Section.Frame = Create("Frame")({
                Name = name.."Section",
                BackgroundColor3 = Theme.Section,
                Size = UDim2.new(1, 0, 0, 40), -- Will be resized based on content
                Parent = Tab.Frame
            })
            
            RoundBox(6).Parent = Section.Frame
            Shadow(Section.Frame, 6, 0.5)
            
            -- Create section title
            Section.Title = Create("TextLabel")({
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Section.Frame
            })
            
            -- Create section content
            Section.Content = Create("Frame")({
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0), -- Will be resized based on content
                Parent = Section.Frame
            })
            
            local SectionList = Create("UIListLayout")({
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = Section.Content
            })
            
            local SectionPadding = Create("UIPadding")({
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                Parent = Section.Content
            })
            
            -- Update section size when elements are added
            SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Content.Size = UDim2.new(1, 0, 0, SectionList.AbsoluteContentSize.Y)
                Section.Frame.Size = UDim2.new(1, 0, 0, SectionList.AbsoluteContentSize.Y + 40)
            end)
            
            -- Button creation function
            function Section:CreateButton(text, callback)
                callback = callback or function() end
                
                local Button = {}
                
                -- Create button
                Button.Frame = Create("TextButton")({
                    Name = text.."Button",
                    BackgroundColor3 = Theme.Button,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Parent = Section.Content
                })
                
                RoundBox(4).Parent = Button.Frame
                
                -- Button functionality
                Button.Frame.MouseEnter:Connect(function()
                    Tween(Button.Frame, {BackgroundColor3 = Theme.ButtonHover})
                end)
                
                Button.Frame.MouseLeave:Connect(function()
                    Tween(Button.Frame, {BackgroundColor3 = Theme.Button})
                end)
                
                Button.Frame.MouseButton1Click:Connect(function()
                    callback()
                    
                    -- Click effect
                    Tween(Button.Frame, {BackgroundColor3 = Theme.Accent}, 0.1)
                    task.wait(0.1)
                    Tween(Button.Frame, {BackgroundColor3  0.1)
                    task.wait(0.1)
                    Tween(Button.Frame, {BackgroundColor3 = Theme.Button}, 0.1)
                end)
                
                return Button
            end
            
            -- Toggle creation function
            function Section:CreateToggle(text, default, callback)
                default = default or false
                callback = callback or function() end
                
                local Toggle = {}
                Toggle.Value = default
                
                -- Create toggle frame
                Toggle.Frame = Create("Frame")({
                    Name = text.."Toggle",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = Section.Content
                })
                
                -- Create toggle label
                Toggle.Label = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Toggle.Frame
                })
                
                -- Create toggle button
                Toggle.Button = Create("Frame")({
                    Name = "Button",
                    BackgroundColor3 = default and Theme.ToggleAccent or Theme.Toggle,
                    Position = UDim2.new(1, -40, 0.5, -8),
                    Size = UDim2.new(0, 40, 0, 16),
                    Parent = Toggle.Frame
                })
                
                RoundBox(8).Parent = Toggle.Button
                
                -- Create toggle indicator
                Toggle.Indicator = Create("Frame")({
                    Name = "Indicator",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Theme.Text,
                    Position = default and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Parent = Toggle.Button
                })
                
                RoundBox(6).Parent = Toggle.Indicator
                
                -- Create hitbox
                Toggle.Hitbox = Create("TextButton")({
                    Name = "Hitbox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Toggle.Frame
                })
                
                -- Toggle functionality
                local function UpdateToggle()
                    Tween(Toggle.Button, {BackgroundColor3 = Toggle.Value and Theme.ToggleAccent or Theme.Toggle})
                    Tween(Toggle.Indicator, {Position = Toggle.Value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
                    callback(Toggle.Value)
                end
                
                Toggle.Hitbox.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                end)
                
                -- Set default value
                if default then
                    callback(true)
                end
                
                -- Toggle methods
                function Toggle:SetValue(value)
                    Toggle.Value = value
                    UpdateToggle()
                end
                
                return Toggle
            end
            
            -- Slider creation function
            function Section:CreateSlider(text, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = default or min
                callback = callback or function() end
                
                local Slider = {}
                Slider.Value = default
                
                -- Create slider frame
                Slider.Frame = Create("Frame")({
                    Name = text.."Slider",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = Section.Content
                })
                
                -- Create slider label
                Slider.Label = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Slider.Frame
                })
                
                -- Create value label
                Slider.ValueLabel = Create("TextLabel")({
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(default),
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Slider.Frame
                })
                
                -- Create slider background
                Slider.Background = Create("Frame")({
                    Name = "Background",
                    BackgroundColor3 = Theme.Slider,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 10),
                    Parent = Slider.Frame
                })
                
                RoundBox(5).Parent = Slider.Background
                
                -- Create slider fill
                Slider.Fill = Create("Frame")({
                    Name = "Fill",
                    BackgroundColor3 = Theme.SliderAccent,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = Slider.Background
                })
                
                RoundBox(5).Parent = Slider.Fill
                
                -- Create slider hitbox
                Slider.Hitbox = Create("TextButton")({
                    Name = "Hitbox",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = Slider.Background
                })
                
                -- Slider functionality
                local isDragging = false
                
                Slider.Hitbox.MouseButton1Down:Connect(function()
                    isDragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                Slider.Hitbox.MouseMoved:Connect(function(_, y)
                    if isDragging then
                        local percentage = math.clamp((UserInputService:GetMouseLocation().X - Slider.Background.AbsolutePosition.X) / Slider.Background.AbsoluteSize.X, 0, 1)
                        local value = math.floor(min + (max - min) * percentage)
                        
                        Slider.Value = value
                        Slider.ValueLabel.Text = tostring(value)
                        Slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
                        
                        callback(value)
                    end
                end)
                
                -- Slider methods
                function Slider:SetValue(value)
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    
                    local percentage = (value - min) / (max - min)
                    Slider.ValueLabel.Text = tostring(value)
                    Slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
                    
                    callback(value)
                end
                
                return Slider
            end
            
            -- Add other UI element creation functions here...
            
            return Section
        end
        
        -- Add tab to window tabs
        table.insert(Window.Tabs, Tab)
        
        -- Select this tab if it's the first one
        if #Window.Tabs == 1 then
            Tab.Button.BackgroundColor3 = Theme.Accent
            Tab.Button.TextColor3 = Theme.Text
            Tab.Frame.Visible = true
            Window.ActiveTab = Tab
        end
        
        return Tab
    end
    
    -- Add window to windows table
    table.insert(self.Windows, Window)
    
    return Window
end

-- Return the library
return Mafuyo
