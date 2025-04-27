--[[
    Mafuyo UI Library
    A sleek UI library for Roblox scripting tools
    
    Usage:
    local Mafuyo = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/MafuyoLib/main/source.lua"))()
    local Window = Mafuyo:CreateWindow("Mafuyo Cheats")
    
    local PlayerTab = Window:CreateTab("Player")
    local SpeedSection = PlayerTab:CreateSection("Movement")
    
    SpeedSection:CreateToggle("Speed Hack", false, function(enabled)
        -- Speed hack code here
    end)
    
    SpeedSection:CreateSlider("Speed Value", 16, 100, 16, function(value)
        -- Set speed value
    end)
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
    
    -- Create watermark
    self.Watermark = Create("Frame")({
        Name = "Watermark",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 20, 0, 20),
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
                        local percentage = math.clamp((Mouse.X - Slider.Background.AbsolutePosition.X) / Slider.Background.AbsoluteSize.X, 0, 1)
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
            
            -- Dropdown creation function
            function Section:CreateDropdown(text, options, default, callback)
                options = options or {}
                default = default or options[1] or ""
                callback = callback or function() end
                
                local Dropdown = {}
                Dropdown.Value = default
                Dropdown.Options = options
                Dropdown.Open = false
                
                -- Create dropdown frame
                Dropdown.Frame = Create("Frame")({
                    Name = text.."Dropdown",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    ClipsDescendants = true,
                    Parent = Section.Content
                })
                
                -- Create dropdown label
                Dropdown.Label = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Dropdown.Frame
                })
                
                -- Create dropdown button
                Dropdown.Button = Create("TextButton")({
                    Name = "Button",
                    BackgroundColor3 = Theme.Dropdown,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    Parent = Dropdown.Frame
                })
                
                RoundBox(4).Parent = Dropdown.Button
                
                -- Create dropdown arrow
                Dropdown.Arrow = Create("TextLabel")({
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = "▼",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Parent = Dropdown.Button
                })
                
                -- Create dropdown container
                Dropdown.Container = Create("Frame")({
                    Name = "Container",
                    BackgroundColor3 = Theme.Dropdown,
                    Position = UDim2.new(0, 0, 0, 42),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    Parent = Dropdown.Frame
                })
                
                RoundBox(4).Parent = Dropdown.Container
                
                -- Create option holder
                Dropdown.OptionHolder = Create("ScrollingFrame")({
                    Name = "OptionHolder",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    Parent = Dropdown.Container
                })
                
                local OptionList = Create("UIListLayout")({
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Dropdown.OptionHolder
                })
                
                -- Update canvas size when options are added
                OptionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    Dropdown.OptionHolder.CanvasSize = UDim2.new(0, 0, 0, OptionList.AbsoluteContentSize.Y)
                end)
                
                -- Dropdown functionality
                local function CreateOption(option)
                    local Option = Create("TextButton")({
                        Name = option.."Option",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Theme.Text,
                        TextSize = 14,
                        Parent = Dropdown.OptionHolder
                    })

                    Option.MouseEnter:Connect(function()
                        Tween(Option, {BackgroundTransparency = 0.8})
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        Tween(Option, {BackgroundTransparency = 1})
                    end)
                    
                    Option.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        Dropdown.Button.Text = option
                        
                        Dropdown:Toggle()
                        callback(option)
                    end)
                    
                    return Option
                end
                
                -- Add options
                for _, option in ipairs(options) do
                    CreateOption(option)
                end
                
                -- Toggle dropdown
                function Dropdown:Toggle()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        Dropdown.Frame.Size = UDim2.new(1, 0, 0, 40 + math.min(#Dropdown.Options * 20, 100))
                        Dropdown.Container.Visible = true
                        Dropdown.Container.Size = UDim2.new(1, 0, 0, math.min(#Dropdown.Options * 20, 100))
                        Dropdown.OptionHolder.Size = UDim2.new(1, 0, 1, 0)
                        Dropdown.Arrow.Text = "▲"
                    else
                        Dropdown.Frame.Size = UDim2.new(1, 0, 0, 40)
                        Dropdown.Arrow.Text = "▼"
                        Dropdown.Container.Visible = false
                    end
                end
                
                Dropdown.Button.MouseButton1Click:Connect(function()
                    Dropdown:Toggle()
                end)
                
                -- Dropdown methods
                function Dropdown:SetValue(value)
                    if table.find(Dropdown.Options, value) then
                        Dropdown.Value = value
                        Dropdown.Button.Text = value
                        callback(value)
                    end
                end
                
                function Dropdown:AddOption(option)
                    if not table.find(Dropdown.Options, option) then
                        table.insert(Dropdown.Options, option)
                        CreateOption(option)
                    end
                end
                
                function Dropdown:RemoveOption(option)
                    local index = table.find(Dropdown.Options, option)
                    if index then
                        table.remove(Dropdown.Options, index)
                        
                        for _, child in pairs(Dropdown.OptionHolder:GetChildren()) do
                            if child:IsA("TextButton") and child.Text == option then
                                child:Destroy()
                                break
                            end
                        end
                        
                        if Dropdown.Value == option then
                            Dropdown.Value = Dropdown.Options[1] or ""
                            Dropdown.Button.Text = Dropdown.Value
                            callback(Dropdown.Value)
                        end
                    end
                end
                
                return Dropdown
            end
            
            -- Textbox creation function
            function Section:CreateTextbox(text, placeholder, default, callback)
                placeholder = placeholder or ""
                default = default or ""
                callback = callback or function() end
                
                local Textbox = {}
                Textbox.Value = default
                
                -- Create textbox frame
                Textbox.Frame = Create("Frame")({
                    Name = text.."Textbox",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = Section.Content
                })
                
                -- Create textbox label
                Textbox.Label = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Textbox.Frame
                })
                
                -- Create textbox
                Textbox.Box = Create("TextBox")({
                    Name = "Box",
                    BackgroundColor3 = Theme.Dropdown,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    Text = default,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    ClearTextOnFocus = false,
                    Parent = Textbox.Frame
                })
                
                RoundBox(4).Parent = Textbox.Box
                
                -- Textbox functionality
                Textbox.Box.Focused:Connect(function()
                    Tween(Textbox.Box, {BackgroundColor3 = Theme.Accent})
                end)
                
                Textbox.Box.FocusLost:Connect(function(enterPressed)
                    Tween(Textbox.Box, {BackgroundColor3 = Theme.Dropdown})
                    
                    if enterPressed then
                        Textbox.Value = Textbox.Box.Text
                        callback(Textbox.Box.Text)
                    end
                end)
                
                -- Textbox methods
                function Textbox:SetValue(value)
                    Textbox.Value = value
                    Textbox.Box.Text = value
                    callback(value)
                end
                
                return Textbox
            end
            
            -- Keybind creation function
            function Section:CreateKeybind(text, default, callback)
                default = default or Enum.KeyCode.Unknown
                callback = callback or function() end
                
                local Keybind = {}
                Keybind.Value = default
                Keybind.Listening = false
                
                -- Create keybind frame
                Keybind.Frame = Create("Frame")({
                    Name = text.."Keybind",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = Section.Content
                })
                
                -- Create keybind label
                Keybind.Label = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Keybind.Frame
                })
                
                -- Create keybind button
                Keybind.Button = Create("TextButton")({
                    Name = "Button",
                    BackgroundColor3 = Theme.Button,
                    Position = UDim2.new(1, -70, 0.5, -10),
                    Size = UDim2.new(0, 70, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = default.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Parent = Keybind.Frame
                })
                
                RoundBox(4).Parent = Keybind.Button
                
                -- Keybind functionality
                Keybind.Button.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    Keybind.Button.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if Keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        Keybind.Value = input.KeyCode
                        Keybind.Button.Text = input.KeyCode.Name
                        Keybind.Listening = false
                    end
                end)
                
                -- Register keybind
                self.Keybinds[default] = callback
                
                -- Keybind methods
                function Keybind:SetValue(value)
                    -- Remove old keybind
                    self.Keybinds[Keybind.Value] = nil
                    
                    -- Set new keybind
                    Keybind.Value = value
                    Keybind.Button.Text = value.Name
                    self.Keybinds[value] = callback
                end
                
                return Keybind
            end
            
            -- Label creation function
            function Section:CreateLabel(text)
                local Label = {}
                
                -- Create label
                Label.Frame = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Section.Content
                })
                
                -- Label methods
                function Label:SetText(value)
                    Label.Frame.Text = value
                end
                
                return Label
            end
            
            -- Separator creation function
            function Section:CreateSeparator()
                local Separator = {}
                
                -- Create separator
                Separator.Frame = Create("Frame")({
                    Name = "Separator",
                    BackgroundColor3 = Theme.Button,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = Section.Content
                })
                
                return Separator
            end
            
            -- ColorPicker creation function
            function Section:CreateColorPicker(text, default, callback)
                default = default or Color3.fromRGB(255, 255, 255)
                callback = callback or function() end
                
                local ColorPicker = {}
                ColorPicker.Value = default
                ColorPicker.Open = false
                
                -- Create color picker frame
                ColorPicker.Frame = Create("Frame")({
                    Name = text.."ColorPicker",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = Section.Content
                })
                
                -- Create color picker label
                ColorPicker.Label = Create("TextLabel")({
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPicker.Frame
                })
                
                -- Create color display
                ColorPicker.Display = Create("Frame")({
                    Name = "Display",
                    BackgroundColor3 = default,
                    Position = UDim2.new(1, -30, 0.5, -10),
                    Size = UDim2.new(0, 30, 0, 20),
                    Parent = ColorPicker.Frame
                })
                
                RoundBox(4).Parent = ColorPicker.Display
                
                -- Create color picker button
                ColorPicker.Button = Create("TextButton")({
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = ColorPicker.Display
                })
                
                -- Create color picker container
                ColorPicker.Container = Create("Frame")({
                    Name = "Container",
                    BackgroundColor3 = Theme.Section,
                    Position = UDim2.new(1, 10, 0, 0),
                    Size = UDim2.new(0, 200, 0, 200),
                    Visible = false,
                    ZIndex = 10,
                    Parent = ColorPicker.Frame
                })
                
                RoundBox(6).Parent = ColorPicker.Container
                Shadow(ColorPicker.Container)
                
                -- Create color picker functionality
                -- This is a simplified version, you would need to implement a full HSV color picker
                
                -- Toggle color picker
                ColorPicker.Button.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    ColorPicker.Container.Visible = ColorPicker.Open
                end)
                
                -- ColorPicker methods
                function ColorPicker:SetValue(value)
                    ColorPicker.Value = value
                    ColorPicker.Display.BackgroundColor3 = value
                    callback(value)
                end
                
                return ColorPicker
            end
            
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
