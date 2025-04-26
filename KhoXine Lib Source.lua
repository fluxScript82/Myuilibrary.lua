-- KhoXine Hub UI Library
-- A professional, feature-rich UI library for Roblox scripts
-- Version 1.0.0

local KhoXineHub = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Error handling
local function handleError(err)
    warn("[KhoXine Hub] Error: " .. tostring(err))
    return nil
end

-- Configuration
KhoXineHub.Config = {
    Theme = {
        Primary = Color3.fromRGB(24, 24, 36),
        Secondary = Color3.fromRGB(32, 32, 46),
        Tertiary = Color3.fromRGB(40, 40, 60),
        Accent = Color3.fromRGB(113, 93, 255),
        AccentDark = Color3.fromRGB(86, 70, 210),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 190),
        Success = Color3.fromRGB(72, 199, 142),
        Warning = Color3.fromRGB(255, 184, 57),
        Error = Color3.fromRGB(255, 75, 75),
        Background = Color3.fromRGB(18, 18, 24)
    },
    Animation = {
        TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        SpringInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        FadeInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    },
    Draggable = true,
    CornerRadius = UDim.new(0, 6),
    ZIndexBase = 10,
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    Version = "1.0.0"
}

-- Utility Functions
local function createInstance(className, properties)
    local success, instance = pcall(function()
        local inst = Instance.new(className)
        for property, value in pairs(properties) do
            inst[property] = value
        end
        return inst
    end)
    
    if success then
        return instance
    else
        handleError("Failed to create " .. className .. ": " .. tostring(instance))
        return nil
    end
end

local function createShadow(parent, size)
    local shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 30, 1, size or 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = parent.ZIndex - 1
    })
    return shadow
end

local function createStroke(parent, color, thickness)
    local stroke = createInstance("UIStroke", {
        Parent = parent,
        Color = color or KhoXineHub.Config.Theme.Accent,
        Thickness = thickness or 1,
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    return stroke
end

local function makeDraggable(frame, handle)
    if not KhoXineHub.Config.Draggable then return end
    
    handle = handle or frame
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function createRipple(parent)
    local ripple = createInstance("Frame", {
        Name = "Ripple",
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = parent.ZIndex + 1
    })
    
    local corner = createInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    
    TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Logo Creator
local function createLogo(parent)
    local logoContainer = createInstance("Frame", {
        Name = "LogoContainer",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0.5, -12),
        ZIndex = parent.ZIndex + 1
    })
    
    local logoText = createInstance("TextLabel", {
        Name = "LogoText",
        Parent = logoContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = KhoXineHub.Config.FontBold,
        Text = "K",
        TextColor3 = KhoXineHub.Config.Theme.Accent,
        TextSize = 18,
        ZIndex = parent.ZIndex + 1
    })
    
    local logoGlow = createInstance("ImageLabel", {
        Name = "LogoGlow",
        Parent = logoContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.5, 0, 1.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://4996891970",
        ImageColor3 = KhoXineHub.Config.Theme.Accent,
        ImageTransparency = 0.7,
        ZIndex = parent.ZIndex
    })
    
    -- Subtle animation
    task.spawn(function()
        while logoGlow and logoGlow.Parent do
            TweenService:Create(logoGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.5
            }):Play()
            task.wait(2)
            TweenService:Create(logoGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.7
            }):Play()
            task.wait(2)
        end
    end)
    
    return logoContainer
end

-- Create Main Window
function KhoXineHub:CreateWindow(title, config)
    config = config or {}
    local windowConfig = {
        Title = title or "KhoXine Hub",
        Size = config.Size or UDim2.new(0, 450, 0, 350),
        Position = config.Position or UDim2.new(0.5, -225, 0.5, -175),
        MinSize = config.MinSize or Vector2.new(400, 300),
        Theme = config.Theme or KhoXineHub.Config.Theme
    }
    
    -- Check if there's already a UI
    pcall(function()
        if CoreGui:FindFirstChild("KhoXineHubGUI") then
            CoreGui.KhoXineHubGUI:Destroy()
        end
    end)
    
    -- Parent ScreenGui
    local ScreenGui = createInstance("ScreenGui", {
        Name = "KhoXineHubGUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    -- Main Frame
    local MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = KhoXineHub.Config.Theme.Background,
        BorderSizePixel = 0,
        Position = windowConfig.Position,
        Size = windowConfig.Size,
        ClipsDescendants = true,
        ZIndex = KhoXineHub.Config.ZIndexBase
    })
    
    -- Apply corner radius
    local Corner = createInstance("UICorner", {
        CornerRadius = KhoXineHub.Config.CornerRadius,
        Parent = MainFrame
    })
    
    -- Create shadow
    createShadow(MainFrame, 40)
    
    -- Title Bar
    local TitleBar = createInstance("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    local TitleCorner = createInstance("UICorner", {
        CornerRadius = KhoXineHub.Config.CornerRadius,
        Parent = TitleBar
    })
    
    local TitleFix = createInstance("Frame", {
        Name = "TitleFix",
        Parent = TitleBar,
        BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    -- Create logo
    local Logo = createLogo(TitleBar)
    
    local TitleText = createInstance("TextLabel", {
        Name = "TitleText",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = KhoXineHub.Config.FontBold,
        Text = windowConfig.Title,
        TextColor3 = KhoXineHub.Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    -- Version label
    local VersionLabel = createInstance("TextLabel", {
        Name = "VersionLabel",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0.5, 2),
        Size = UDim2.new(0, 100, 0, 14),
        Font = KhoXineHub.Config.Font,
        Text = "v" .. KhoXineHub.Config.Version,
        TextColor3 = KhoXineHub.Config.Theme.TextDark,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    -- Close Button
    local CloseButton = createInstance("TextButton", {
        Name = "CloseButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -36, 0, 0),
        Size = UDim2.new(0, 36, 1, 0),
        Font = KhoXineHub.Config.FontBold,
        Text = "×",
        TextColor3 = KhoXineHub.Config.Theme.Text,
        TextSize = 20,
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, KhoXineHub.Config.Animation.FadeInfo, {
            TextColor3 = KhoXineHub.Config.Theme.Error
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, KhoXineHub.Config.Animation.FadeInfo, {
            TextColor3 = KhoXineHub.Config.Theme.Text
        }):Play()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        -- Fade out animation
        TweenService:Create(MainFrame, KhoXineHub.Config.Animation.TweenInfo, {
            Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, 1.5, 0)
        }):Play()
        
        task.delay(0.3, function()
            ScreenGui:Destroy()
        end)
    end)
    
    -- Minimize Button
    local MinimizeButton = createInstance("TextButton", {
        Name = "MinimizeButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -72, 0, 0),
        Size = UDim2.new(0, 36, 1, 0),
        Font = KhoXineHub.Config.FontBold,
        Text = "−",
        TextColor3 = KhoXineHub.Config.Theme.Text,
        TextSize = 20,
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, KhoXineHub.Config.Animation.FadeInfo, {
            TextColor3 = KhoXineHub.Config.Theme.Accent
        }):Play()
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, KhoXineHub.Config.Animation.FadeInfo, {
            TextColor3 = KhoXineHub.Config.Theme.Text
        }):Play()
    end)
    
    local minimized = false
    local originalSize = MainFrame.Size
    
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            TweenService:Create(MainFrame, KhoXineHub.Config.Animation.TweenInfo, {
                Size = UDim2.new(0, MainFrame.AbsoluteSize.X, 0, 36)
            }):Play()
            MinimizeButton.Text = "+"
        else
            TweenService:Create(MainFrame, KhoXineHub.Config.Animation.TweenInfo, {
                Size = originalSize
            }):Play()
            MinimizeButton.Text = "−"
        end
    end)
    
    -- Tab System
    local TabContainer = createInstance("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(0, 120, 1, -36),
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    local TabContainerCorner = createInstance("UICorner", {
        CornerRadius = KhoXineHub.Config.CornerRadius,
        Parent = TabContainer
    })
    
    local TabContainerFix = createInstance("Frame", {
        Name = "TabContainerFix",
        Parent = TabContainer,
        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0),
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    local TabScrollFrame = createInstance("ScrollingFrame", {
        Name = "TabScrollFrame",
        Parent = TabContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = KhoXineHub.Config.Theme.Accent,
        ScrollBarImageTransparency = 0.5,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ZIndex = KhoXineHub.Config.ZIndexBase + 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local TabList = createInstance("UIListLayout", {
        Parent = TabScrollFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local TabPadding = createInstance("UIPadding", {
        Parent = TabScrollFrame,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })
    
    -- Content Container
    local ContentFrame = createInstance("Frame", {
        Name = "ContentFrame",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 120, 0, 36),
        Size = UDim2.new(1, -120, 1, -36),
        ZIndex = KhoXineHub.Config.ZIndexBase + 1
    })
    
    -- Make window draggable
    makeDraggable(MainFrame, TitleBar)
    
    -- Window object
    local Window = {
        Gui = ScreenGui,
        Tabs = {},
        ActiveTab = nil
    }
    
    -- Add Tab
    function Window:AddTab(title, icon)
        local tabId = title:gsub("%s+", ""):lower()
        
        -- Tab Button
        local TabButton = createInstance("TextButton", {
            Name = "Tab_" .. tabId,
            Parent = TabScrollFrame,
            BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = KhoXineHub.Config.Font,
            Text = "",
            TextColor3 = KhoXineHub.Config.Theme.TextDark,
            TextSize = 14,
            ZIndex = KhoXineHub.Config.ZIndexBase + 2
        })

        local TabButtonCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton
        })
        
        local TabIcon = createInstance("ImageLabel", {
            Name = "TabIcon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Image = icon or "rbxassetid://7733715400", -- Default icon
            ImageColor3 = KhoXineHub.Config.Theme.TextDark,
            ZIndex = KhoXineHub.Config.ZIndexBase + 2
        })
        
        local TabText = createInstance("TextLabel", {
            Name = "TabText",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -35, 1, 0),
            Font = KhoXineHub.Config.Font,
            Text = title,
            TextColor3 = KhoXineHub.Config.Theme.TextDark,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = KhoXineHub.Config.ZIndexBase + 2
        })
        
        local TabIndicator = createInstance("Frame", {
            Name = "TabIndicator",
            Parent = TabButton,
            BackgroundColor3 = KhoXineHub.Config.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 2, 0, 20),
            Visible = false,
            ZIndex = KhoXineHub.Config.ZIndexBase + 2
        })
        
        local TabIndicatorCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = TabIndicator
        })
        
        -- Tab Content
        local TabContent = createInstance("ScrollingFrame", {
            Name = "Content_" .. tabId,
            Parent = ContentFrame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = KhoXineHub.Config.Theme.Accent,
            ScrollBarImageTransparency = 0.5,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            Visible = false,
            ZIndex = KhoXineHub.Config.ZIndexBase + 2,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local ContentList = createInstance("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local ContentPadding = createInstance("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Tab object
        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Sections = {}
        }
        
        -- Tab selection logic
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(tabId)
        end)
        
        -- Hover effects
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= tabId then
                TweenService:Create(TabButton, KhoXineHub.Config.Animation.FadeInfo, {
                    BackgroundTransparency = 0.8
                }):Play()
                
                TweenService:Create(TabText, KhoXineHub.Config.Animation.FadeInfo, {
                    TextColor3 = KhoXineHub.Config.Theme.Text
                }):Play()
                
                TweenService:Create(TabIcon, KhoXineHub.Config.Animation.FadeInfo, {
                    ImageColor3 = KhoXineHub.Config.Theme.Text
                }):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= tabId then
                TweenService:Create(TabButton, KhoXineHub.Config.Animation.FadeInfo, {
                    BackgroundTransparency = 1
                }):Play()
                
                TweenService:Create(TabText, KhoXineHub.Config.Animation.FadeInfo, {
                    TextColor3 = KhoXineHub.Config.Theme.TextDark
                }):Play()
                
                TweenService:Create(TabIcon, KhoXineHub.Config.Animation.FadeInfo, {
                    ImageColor3 = KhoXineHub.Config.Theme.TextDark
                }):Play()
            end
        end)
        
        -- Add Section
        function Tab:AddSection(title)
            local SectionFrame = createInstance("Frame", {
                Name = "Section",
                Parent = TabContent,
                BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = KhoXineHub.Config.ZIndexBase + 3
            })
            
            local SectionCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SectionFrame
            })
            
            createShadow(SectionFrame, 20)
            
            local SectionTitle = createInstance("TextLabel", {
                Name = "SectionTitle",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 0, 40),
                Font = KhoXineHub.Config.FontBold,
                Text = title or "Section",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = KhoXineHub.Config.ZIndexBase + 3
            })
            
            local SectionDivider = createInstance("Frame", {
                Name = "SectionDivider",
                Parent = SectionFrame,
                BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 15, 0, 40),
                Size = UDim2.new(1, -30, 0, 1),
                ZIndex = KhoXineHub.Config.ZIndexBase + 3
            })
            
            local SectionContainer = createInstance("Frame", {
                Name = "SectionContainer",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 50),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = KhoXineHub.Config.ZIndexBase + 3
            })
            
            local SectionUIListLayout = createInstance("UIListLayout", {
                Parent = SectionContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            local SectionUIPadding = createInstance("UIPadding", {
                Parent = SectionContainer,
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 15)
            })
            
            -- Section object
            local Section = {}
            
            -- Add Button
            function Section:AddButton(text, callback)
                callback = callback or function() end
                
                local Button = createInstance("TextButton", {
                    Name = "Button",
                    Parent = SectionContainer,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36),
                    Font = KhoXineHub.Config.Font,
                    Text = "",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ButtonCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Button
                })
                
                local ButtonLabel = createInstance("TextLabel", {
                    Name = "ButtonLabel",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Button",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                -- Button hover and click effects
                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, KhoXineHub.Config.Animation.FadeInfo, {
                        BackgroundColor3 = Color3.fromRGB(
                            KhoXineHub.Config.Theme.Secondary.R * 255 + 15,
                            KhoXineHub.Config.Theme.Secondary.G * 255 + 15,
                            KhoXineHub.Config.Theme.Secondary.B * 255 + 15
                        )
                    }):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, KhoXineHub.Config.Animation.FadeInfo, {
                        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary
                    }):Play()
                end)
                
                Button.MouseButton1Down:Connect(function()
                    createRipple(Button)
                    
                    TweenService:Create(Button, KhoXineHub.Config.Animation.FadeInfo, {
                        BackgroundColor3 = KhoXineHub.Config.Theme.Accent
                    }):Play()
                    
                    -- Call the callback function in protected mode
                    local success, err = pcall(callback)
                    if not success then
                        handleError(err)
                    end
                    
                    task.delay(0.2, function()
                        TweenService:Create(Button, KhoXineHub.Config.Animation.FadeInfo, {
                            BackgroundColor3 = KhoXineHub.Config.Theme.Secondary
                        }):Play()
                    end)
                end)
                
                return Button
            end
            
            -- Add Toggle
            function Section:AddToggle(text, default, callback)
                default = default or false
                callback = callback or function() end
                
                local ToggleFrame = createInstance("Frame", {
                    Name = "Toggle",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ToggleLabel = createInstance("TextLabel", {
                    Name = "ToggleLabel",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -56, 1, 0),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Toggle",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ToggleButton = createInstance("Frame", {
                    Name = "ToggleButton",
                    Parent = ToggleFrame,
                    BackgroundColor3 = default and KhoXineHub.Config.Theme.Accent or KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -46, 0.5, -10),
                    Size = UDim2.new(0, 46, 0, 20),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ToggleButtonCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })
                
                local ToggleCircle = createInstance("Frame", {
                    Name = "ToggleCircle",
                    Parent = ToggleButton,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Text,
                    BorderSizePixel = 0,
                    Position = UDim2.new(default and 0.57 or 0, default and 0 or 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ToggleCircleCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })
                
                local ToggleHitbox = createInstance("TextButton", {
                    Name = "ToggleHitbox",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local Toggled = default
                
                local function UpdateToggle()
                    Toggled = not Toggled
                    
                    TweenService:Create(ToggleButton, KhoXineHub.Config.Animation.TweenInfo, {
                        BackgroundColor3 = Toggled and KhoXineHub.Config.Theme.Accent or KhoXineHub.Config.Theme.Secondary
                    }):Play()
                    
                    TweenService:Create(ToggleCircle, KhoXineHub.Config.Animation.TweenInfo, {
                        Position = Toggled 
                            and UDim2.new(0.57, 0, 0.5, -8) 
                            or UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                    
                    -- Call the callback function in protected mode
                    local success, err = pcall(function()
                        callback(Toggled)
                    end)
                    
                    if not success then
                        handleError(err)
                    end
                end
                
                ToggleHitbox.MouseButton1Click:Connect(function()
                    createRipple(ToggleFrame)
                    UpdateToggle()
                end)
                
                -- Toggle object
                local Toggle = {
                    Value = default,
                    Set = function(self, value)
                        if value ~= Toggled then
                            UpdateToggle()
                        end
                    end
                }
                
                return Toggle
            end
            
            -- Add Slider
            function Section:AddSlider(text, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = math.clamp(default or min, min, max)
                callback = callback or function() end
                
                local SliderFrame = createInstance("Frame", {
                    Name = "Slider",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local SliderLabel = createInstance("TextLabel", {
                    Name = "SliderLabel",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Slider",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local SliderValue = createInstance("TextLabel", {
                    Name = "SliderValue",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = KhoXineHub.Config.Font,
                    Text = tostring(default),
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local SliderBackground = createInstance("Frame", {
                    Name = "SliderBackground",
                    Parent = SliderFrame,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 10),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local SliderBackgroundCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBackground
                })
                
                local SliderFill = createInstance("Frame", {
                    Name = "SliderFill",
                    Parent = SliderBackground,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local SliderFillCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                
                local SliderCircle = createInstance("Frame", {
                    Name = "SliderCircle",
                    Parent = SliderFill,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = KhoXineHub.Config.Theme.Text,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local SliderCircleCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderCircle
                })
                
                local SliderHitbox = createInstance("TextButton", {
                    Name = "SliderHitbox",
                    Parent = SliderBackground,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local Value = default

                local function UpdateSlider(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1), 0, 1, 0)
                    SliderFill.Size = pos
                    
                    local value = math.floor(min + ((max - min) * pos.X.Scale))
                    SliderValue.Text = tostring(value)
                    Value = value
                    
                    -- Call the callback function in protected mode
                    local success, err = pcall(function()
                        callback(value)
                    end)
                    
                    if not success then
                        handleError(err)
                    end
                end
                
                SliderHitbox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        UpdateSlider(input)
                        local connection
                        connection = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                UpdateSlider(input)
                            end
                        end)
                        
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                if connection then
                                    connection:Disconnect()
                                end
                            end
                        end)
                    end
                end)
                
                -- Slider object
                local Slider = {
                    Value = default,
                    Set = function(self, value)
                        value = math.clamp(value, min, max)
                        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        SliderValue.Text = tostring(value)
                        Value = value
                        
                        -- Call the callback function in protected mode
                        local success, err = pcall(function()
                            callback(value)
                        end)
                        
                        if not success then
                            handleError(err)
                        end
                    end
                }
                
                return Slider
            end
            
            -- Add Dropdown
            function Section:AddDropdown(text, options, default, callback)
                options = options or {}
                default = default or options[1]
                callback = callback or function() end
                
                local DropdownFrame = createInstance("Frame", {
                    Name = "Dropdown",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local DropdownLabel = createInstance("TextLabel", {
                    Name = "DropdownLabel",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 36),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Dropdown",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local DropdownButton = createInstance("TextButton", {
                    Name = "DropdownButton",
                    Parent = DropdownFrame,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 36),
                    Font = KhoXineHub.Config.Font,
                    Text = default or "Select...",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local DropdownButtonCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton
                })
                
                local DropdownIcon = createInstance("ImageLabel", {
                    Name = "DropdownIcon",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://7072706663", -- Arrow down icon
                    ImageColor3 = KhoXineHub.Config.Theme.Text,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local DropdownContent = createInstance("Frame", {
                    Name = "DropdownContent",
                    Parent = DropdownFrame,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 77),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 5
                })
                
                local DropdownContentCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownContent
                })
                
                local DropdownUIListLayout = createInstance("UIListLayout", {
                    Parent = DropdownContent,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5)
                })
                
                local DropdownUIPadding = createInstance("UIPadding", {
                    Parent = DropdownContent,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                })
                
                local DropdownOpen = false
                local SelectedOption = default
                
                local function ToggleDropdown()
                    DropdownOpen = not DropdownOpen
                    
                    if DropdownOpen then
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 36 + 41 + (#options * 30) + 10)
                        DropdownContent.Size = UDim2.new(1, 0, 0, (#options * 30) + 10)
                        DropdownContent.Visible = true
                        TweenService:Create(DropdownIcon, KhoXineHub.Config.Animation.TweenInfo, {
                            Rotation = 180
                        }):Play()
                    else
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 36 + 36)
                        DropdownContent.Visible = false
                        TweenService:Create(DropdownIcon, KhoXineHub.Config.Animation.TweenInfo, {
                            Rotation = 0
                        }):Play()
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    createRipple(DropdownButton)
                    ToggleDropdown()
                end)
                
                for i, option in ipairs(options) do
                    local OptionButton = createInstance("TextButton", {
                        Name = "Option",
                        Parent = DropdownContent,
                        BackgroundColor3 = KhoXineHub.Config.Theme.Tertiary,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = KhoXineHub.Config.Font,
                        Text = option,
                        TextColor3 = KhoXineHub.Config.Theme.Text,
                        TextSize = 14,
                        AutoButtonColor = false,
                        ZIndex = KhoXineHub.Config.ZIndexBase + 5
                    })
                    
                    local OptionButtonCorner = createInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        TweenService:Create(OptionButton, KhoXineHub.Config.Animation.FadeInfo, {
                            BackgroundColor3 = Color3.fromRGB(
                                KhoXineHub.Config.Theme.Tertiary.R * 255 + 15,
                                KhoXineHub.Config.Theme.Tertiary.G * 255 + 15,
                                KhoXineHub.Config.Theme.Tertiary.B * 255 + 15
                            )
                        }):Play()
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        TweenService:Create(OptionButton, KhoXineHub.Config.Animation.FadeInfo, {
                            BackgroundColor3 = KhoXineHub.Config.Theme.Tertiary
                        }):Play()
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        createRipple(OptionButton)
                        SelectedOption = option
                        DropdownButton.Text = option
                        ToggleDropdown()
                        
                        -- Call the callback function in protected mode
                        local success, err = pcall(function()
                            callback(option)
                        end)
                        
                        if not success then
                            handleError(err)
                        end
                    end)
                end
                
                -- Dropdown object
                local Dropdown = {
                    Value = default,
                    Options = options,
                    Set = function(self, value)
                        if table.find(options, value) then
                            SelectedOption = value
                            DropdownButton.Text = value
                            
                            -- Call the callback function in protected mode
                            local success, err = pcall(function()
                                callback(value)
                            end)
                            
                            if not success then
                                handleError(err)
                            end
                        end
                    end,
                    Add = function(self, option)
                        if not table.find(options, option) then
                            table.insert(options, option)
                            
                            local OptionButton = createInstance("TextButton", {
                                Name = "Option",
                                Parent = DropdownContent,
                                BackgroundColor3 = KhoXineHub.Config.Theme.Tertiary,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, 30),
                                Font = KhoXineHub.Config.Font,
                                Text = option,
                                TextColor3 = KhoXineHub.Config.Theme.Text,
                                TextSize = 14,
                                AutoButtonColor = false,
                                ZIndex = KhoXineHub.Config.ZIndexBase + 5
                            })
                            
                            local OptionButtonCorner = createInstance("UICorner", {
                                CornerRadius = UDim.new(0, 4),
                                Parent = OptionButton
                            })
                            
                            OptionButton.MouseEnter:Connect(function()
                                TweenService:Create(OptionButton, KhoXineHub.Config.Animation.FadeInfo, {
                                    BackgroundColor3 = Color3.fromRGB(
                                        KhoXineHub.Config.Theme.Tertiary.R * 255 + 15,
                                        KhoXineHub.Config.Theme.Tertiary.G * 255 + 15,
                                        KhoXineHub.Config.Theme.Tertiary.B * 255 + 15
                                    )
                                }):Play()
                            end)
                            
                            OptionButton.MouseLeave:Connect(function()
                                TweenService:Create(OptionButton, KhoXineHub.Config.Animation.FadeInfo, {
                                    BackgroundColor3 = KhoXineHub.Config.Theme.Tertiary
                                }):Play()
                            end)
                            
                            OptionButton.MouseButton1Click:Connect(function()
                                createRipple(OptionButton)
                                SelectedOption = option
                                DropdownButton.Text = option
                                ToggleDropdown()
                                
                                -- Call the callback function in protected mode
                                local success, err = pcall(function()
                                    callback(option)
                                end)
                                
                                if not success then
                                    handleError(err)
                                end
                            end)
                        end
                    end,
                    Remove = function(self, option)
                        local index = table.find(options, option)
                        if index then
                            table.remove(options, index)
                            for _, child in pairs(DropdownContent:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == option then
                                    child:Destroy()
                                    break
                                end
                            end
                            
                            if SelectedOption == option then
                                SelectedOption = options[1] or "Select..."
                                DropdownButton.Text = SelectedOption
                                
                                -- Call the callback function in protected mode
                                local success, err = pcall(function()
                                    callback(SelectedOption)
                                end)
                                
                                if not success then
                                    handleError(err)
                                end
                            end
                        end
                    end
                }
                
                return Dropdown
            end
            
            -- Add TextBox
            function Section:AddTextBox(text, placeholder, default, callback)
                placeholder = placeholder or "Enter text..."
                default = default or ""
                callback = callback or function() end
                
                local TextBoxFrame = createInstance("Frame", {
                    Name = "TextBox",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local TextBoxLabel = createInstance("TextLabel", {
                    Name = "TextBoxLabel",
                    Parent = TextBoxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "TextBox",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local TextBoxInput = createInstance("TextBox", {
                    Name = "TextBoxInput",
                    Parent = TextBoxFrame,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 36),
                    Font = KhoXineHub.Config.Font,
                    PlaceholderText = placeholder,
                    Text = default,
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    ClearTextOnFocus = false,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local TextBoxInputCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextBoxInput
                })

                local TextBoxPadding = createInstance("UIPadding", {
                    Parent = TextBoxInput,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                })
                
                TextBoxInput.Focused:Connect(function()
                    TweenService:Create(TextBoxInput, KhoXineHub.Config.Animation.FadeInfo, {
                        BackgroundColor3 = Color3.fromRGB(
                            KhoXineHub.Config.Theme.Secondary.R * 255 + 15,
                            KhoXineHub.Config.Theme.Secondary.G * 255 + 15,
                            KhoXineHub.Config.Theme.Secondary.B * 255 + 15
                        )
                    }):Play()
                    
                    createStroke(TextBoxInput, KhoXineHub.Config.Theme.Accent, 1)
                end)
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    TweenService:Create(TextBoxInput, KhoXineHub.Config.Animation.FadeInfo, {
                        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary
                    }):Play()
                    
                    if TextBoxInput:FindFirstChildOfClass("UIStroke") then
                        TextBoxInput:FindFirstChildOfClass("UIStroke"):Destroy()
                    end
                    
                    -- Call the callback function in protected mode
                    local success, err = pcall(function()
                        callback(TextBoxInput.Text, enterPressed)
                    end)
                    
                    if not success then
                        handleError(err)
                    end
                end)
                
                -- TextBox object
                local TextBox = {
                    Value = default,
                    Set = function(self, value)
                        TextBoxInput.Text = value
                        
                        -- Call the callback function in protected mode
                        local success, err = pcall(function()
                            callback(value, false)
                        end)
                        
                        if not success then
                            handleError(err)
                        end
                    end
                }
                
                return TextBox
            end
            
            -- Add Label
            function Section:AddLabel(text)
                local LabelFrame = createInstance("Frame", {
                    Name = "Label",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local Label = createInstance("TextLabel", {
                    Name = "Label",
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Label",  0, 1, 0),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Label",
                    TextColor3 = KhoXineHub.Config.Theme.TextDark,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                -- Label object
                local LabelObj = {
                    Set = function(self, text)
                        Label.Text = text
                    end
                }
                
                return LabelObj
            end
            
            -- Add Separator
            function Section:AddSeparator()
                local SeparatorFrame = createInstance("Frame", {
                    Name = "Separator",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 10),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local Separator = createInstance("Frame", {
                    Name = "Line",
                    Parent = SeparatorFrame,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                return SeparatorFrame
            end
            
            -- Add ColorPicker
            function Section:AddColorPicker(text, default, callback)
                default = default or Color3.fromRGB(255, 255, 255)
                callback = callback or function() end
                
                local ColorPickerFrame = createInstance("Frame", {
                    Name = "ColorPicker",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ColorPickerLabel = createInstance("TextLabel", {
                    Name = "ColorPickerLabel",
                    Parent = ColorPickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -46, 1, 0),
                    Font = KhoXineHub.Config.Font,
                    Text = text or "Color Picker",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ColorDisplay = createInstance("Frame", {
                    Name = "ColorDisplay",
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -36, 0.5, -12),
                    Size = UDim2.new(0, 36, 0, 24),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ColorDisplayCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorDisplay
                })
                
                local ColorPickerButton = createInstance("TextButton", {
                    Name = "ColorPickerButton",
                    Parent = ColorDisplay,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = KhoXineHub.Config.ZIndexBase + 4
                })
                
                local ColorPickerPopup = createInstance("Frame", {
                    Name = "ColorPickerPopup",
                    Parent = MainFrame,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, -125, 0.5, -125),
                    Size = UDim2.new(0, 250, 0, 250),
                    Visible = false,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 10
                })
                
                local ColorPickerPopupCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ColorPickerPopup
                })
                
                createShadow(ColorPickerPopup, 30)
                
                local ColorPickerTitle = createInstance("TextLabel", {
                    Name = "ColorPickerTitle",
                    Parent = ColorPickerPopup,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -30, 0, 36),
                    Font = KhoXineHub.Config.FontBold,
                    Text = "Color Picker",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 10
                })
                
                local ColorPickerClose = createInstance("TextButton", {
                    Name = "ColorPickerClose",
                    Parent = ColorPickerPopup,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -36, 0, 0),
                    Size = UDim2.new(0, 36, 0, 36),
                    Font = KhoXineHub.Config.FontBold,
                    Text = "×",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 20,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 10
                })
                
                local ColorPickerHue = createInstance("ImageLabel", {
                    Name = "ColorPickerHue",
                    Parent = ColorPickerPopup,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 45),
                    Size = UDim2.new(1, -30, 0, 20),
                    Image = "rbxassetid://3641079629",
                    ZIndex = KhoXineHub.Config.ZIndexBase + 10
                })
                
                local ColorPickerHueCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorPickerHue
                })
                
                local HueSelector = createInstance("Frame", {
                    Name = "HueSelector",
                    Parent = ColorPickerHue,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 5, 1, 0),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 11
                })
                
                local HueSelectorCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 2),
                    Parent = HueSelector
                })
                
                local ColorPickerSatVal = createInstance("ImageLabel", {
                    Name = "ColorPickerSatVal",
                    Parent = ColorPickerPopup,
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 0, 75),
                    Size = UDim2.new(1, -30, 0, 120),
                    Image = "rbxassetid://4155801252",
                    ZIndex = KhoXineHub.Config.ZIndexBase + 10
                })
                
                local ColorPickerSatValCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorPickerSatVal
                })
                
                local SatValSelector = createInstance("Frame", {
                    Name = "SatValSelector",
                    Parent = ColorPickerSatVal,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = KhoXineHub.Config.ZIndexBase + 11
                })
                
                local SatValSelectorCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SatValSelector
                })
                
                local ColorPickerConfirm = createInstance("TextButton", {
                    Name = "ColorPickerConfirm",
                    Parent = ColorPickerPopup,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 1, -50),
                    Size = UDim2.new(1, -30, 0, 36),
                    Font = KhoXineHub.Config.Font,
                    Text = "Confirm",
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    ZIndex = KhoXineHub.Config.ZIndexBase + 10
                })
                
                local ColorPickerConfirmCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorPickerConfirm
                })
                
                local SelectedColor = default
                local Hue, Sat, Val = 0, 0, 1
                
                local function UpdateColor()
                    SelectedColor = Color3.fromHSV(Hue, Sat, Val)
                    ColorDisplay.BackgroundColor3 = SelectedColor
                    ColorPickerSatVal.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                end
                
                ColorPickerButton.MouseButton1Click:Connect(function()
                    ColorPickerPopup.Visible = not ColorPickerPopup.Visible
                end)
                
                ColorPickerClose.MouseButton1Click:Connect(function()
                    ColorPickerPopup.Visible = false
                end)
                
                ColorPickerConfirm.MouseButton1Click:Connect(function()
                    createRipple(ColorPickerConfirm)
                    ColorPickerPopup.Visible = false
                    
                    -- Call the callback function in protected mode
                    local success, err = pcall(function()
                        callback(SelectedColor)
                    end)
                    
                    if not success then
                        handleError(err)
                    end
                end)
                
                ColorPickerHue.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local connection
                        connection = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                local hueX = math.clamp((input.Position.X - ColorPickerHue.AbsolutePosition.X) / ColorPickerHue.AbsoluteSize.X, 0, 1)
                                HueSelector.Position = UDim2.new(hueX, 0, 0, 0)
                                Hue = hueX
                                UpdateColor()
                            end
                        end)
                        
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                if connection then
                                    connection:Disconnect()
                                end
                            end
                        end)
                        
                        local hueX = math.clamp((input.Position.X - ColorPickerHue.AbsolutePosition.X) / ColorPickerHue.AbsoluteSize.X, 0, 1)
                        HueSelector.Position = UDim2.new(hueX, 0, 0, 0)
                        Hue = hueX
                        UpdateColor()
                    end
                end)
                
                ColorPickerSatVal.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local connection
                        connection = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                local satX = math.clamp((input.Position.X - ColorPickerSatVal.AbsolutePosition.X) / ColorPickerSatVal.AbsoluteSize.X, 0, 1)
                                local valY = math.clamp((input.Position.Y - ColorPickerSatVal.AbsolutePosition.Y) / ColorPickerSatVal.AbsoluteSize.Y, 0, 1)
                                SatValSelector.Position = UDim2.new(satX, 0, valY, 0)
                                Sat = satX
                                Val = 1 - valY
                                UpdateColor()
                            end
                        end)
                        
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                if connection then
                                    connection:Disconnect()
                                end
                            end
                        end)
                        
                        local satX = math.clamp((input.Position.X - ColorPickerSatVal.AbsolutePosition.X) / ColorPickerSatVal.AbsoluteSize.X, 0, 1)
                        local valY = math.clamp((input.Position.Y - ColorPickerSatVal.AbsolutePosition.Y) / ColorPickerSatVal.AbsoluteSize.Y, 0, 1)
                        SatValSelector.Position = UDim2.new(satX, 0, valY, 0)
                        Sat = satX
                        Val = 1 - valY
                        UpdateColor()
                    end
                end)
                
                -- ColorPicker object
                local ColorPicker = {
                    Value = default,
                    Set = function(self, color)
                        SelectedColor = color
                        ColorDisplay.BackgroundColor3 = color
                        
                        local h, s, v = color:ToHSV()
                        Hue, Sat, Val = h, s, v
                        
                        HueSelector.Position = UDim2.new(h, 0, 0, 0)
                        SatValSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                        ColorPickerSatVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        
                        -- Call the callback function in protected mode
                        local success, err = pcall(function()
                            callback(color)
                        end)
                        
                        if not success then
                            handleError(err)
                        end
                    end
                }
                
                return ColorPicker
            end
            
            return Section
        end
        
        -- Store tab in window
        Window.Tabs[tabId] = Tab
        
        -- Select first tab by default
        if not Window.ActiveTab then
            Window:SelectTab(tabId)
        end
        
        return Tab
    end
    
    -- Select Tab
    function Window:SelectTab(tabId)
        -- Hide all tabs
        for id, tab in pairs(Window.Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundTransparency = 1
            tab.Button.TabIndicator.Visible = false
            tab.Button.TabText.TextColor3 = KhoXineHub.Config.Theme.TextDark
            tab.Button.TabIcon.ImageColor3 = KhoXineHub.Config.Theme.TextDark
        end
        
        -- Show selected tab
        if Window.Tabs[tabId] then
            Window.Tabs[tabId].Content.Visible = true
            Window.Tabs[tabId].Button.BackgroundTransparency = 0.9
            Window.Tabs[tabId].Button.TabIndicator.Visible = true
            Window.Tabs[tabId].Button.TabText.TextColor3 = KhoXineHub.Config.Theme.Text
            Window.Tabs[tabId].Button.TabIcon.ImageColor3 = KhoXineHub.Config.Theme.Accent
            Window.ActiveTab = tabId
        end
    end

        -- Add Notification
    function Window:AddNotification(title, text, options)
        options = options or {}
        local notifType = options.type or "info" -- info, success, warning, error
        local duration = options.duration or 3
        
        -- Determine notification color based on type
        local notifColor
        if notifType == "success" then
            notifColor = KhoXineHub.Config.Theme.Success
        elseif notifType == "warning" then
            notifColor = KhoXineHub.Config.Theme.Warning
        elseif notifType == "error" then
            notifColor = KhoXineHub.Config.Theme.Error
        else
            notifColor = KhoXineHub.Config.Theme.Accent
        end
        
        -- Create notification container if it doesn't exist
        if not ScreenGui:FindFirstChild("NotificationContainer") then
            local NotificationContainer = createInstance("Frame", {
                Name = "NotificationContainer",
                Parent = ScreenGui,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 1, -20),
                Size = UDim2.new(0, 300, 1, -40),
                AnchorPoint = Vector2.new(1, 1),
                ZIndex = KhoXineHub.Config.ZIndexBase + 20
            })
            
            local NotificationList = createInstance("UIListLayout", {
                Parent = NotificationContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 10)
            })
        end
        
        local NotificationContainer = ScreenGui.NotificationContainer
        
        -- Create notification
        local NotificationFrame = createInstance("Frame", {
            Name = "Notification",
            Parent = NotificationContainer,
            BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0), -- Will be tweened
            AnchorPoint = Vector2.new(1, 1),
            ClipsDescendants = true,
            ZIndex = KhoXineHub.Config.ZIndexBase + 20
        })
        
        local NotificationCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = NotificationFrame
        })
        
        createShadow(NotificationFrame, 20)
        
        local NotificationAccent = createInstance("Frame", {
            Name = "NotificationAccent",
            Parent = NotificationFrame,
            BackgroundColor3 = notifColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0),
            ZIndex = KhoXineHub.Config.ZIndexBase + 20
        })
        
        local NotificationAccentCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = NotificationAccent
        })
        
        local NotificationAccentFix = createInstance("Frame", {
            Name = "NotificationAccentFix",
            Parent = NotificationAccent,
            BackgroundColor3 = notifColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -6, 0, 0),
            Size = UDim2.new(0, 6, 1, 0),
            ZIndex = KhoXineHub.Config.ZIndexBase + 20
        })
        
        local NotificationTitle = createInstance("TextLabel", {
            Name = "NotificationTitle",
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -25, 0, 20),
            Font = KhoXineHub.Config.FontBold,
            Text = title or "Notification",
            TextColor3 = KhoXineHub.Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = KhoXineHub.Config.ZIndexBase + 20
        })
        
        local NotificationText = createInstance("TextLabel", {
            Name = "NotificationText",
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 35),
            Size = UDim2.new(1, -25, 0, 0), -- Will be adjusted based on text
            Font = KhoXineHub.Config.Font,
            Text = text or "",
            TextColor3 = KhoXineHub.Config.Theme.TextDark,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = KhoXineHub.Config.ZIndexBase + 20
        })
        
        -- Calculate text height
        local textSize = game:GetService("TextService"):GetTextSize(
            NotificationText.Text,
            NotificationText.TextSize,
            NotificationText.Font,
            Vector2.new(NotificationText.AbsoluteSize.X, math.huge)
        )
        
        local textHeight = math.max(20, textSize.Y)
        NotificationText.Size = UDim2.new(1, -25, 0, textHeight)
        
        -- Set notification height
        local notifHeight = 45 + textHeight
        NotificationFrame.Size = UDim2.new(1, 0, 0, notifHeight)
        
        -- Animation
        NotificationFrame.Position = UDim2.new(1, 300, 1, 0)
        TweenService:Create(NotificationFrame, KhoXineHub.Config.Animation.TweenInfo, {
            Position = UDim2.new(1, 0, 1, 0)
        }):Play()
        
        -- Auto-close
        task.delay(duration, function()
            TweenService:Create(NotificationFrame, KhoXineHub.Config.Animation.TweenInfo, {
                Position = UDim2.new(1, 300, 1, 0)
            }):Play()
            
            task.delay(0.5, function()
                NotificationFrame:Destroy()
            end)
        end)
        
        return NotificationFrame
    end
    
    -- Fade in animation for window
    MainFrame.Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X/2, -0.5, 0)
    TweenService:Create(MainFrame, KhoXineHub.Config.Animation.TweenInfo, {
        Position = windowConfig.Position
    }):Play()
    
    return Window
end

-- Set Theme
function KhoXineHub:SetTheme(theme)
    for key, value in pairs(theme) do
        if KhoXineHub.Config.Theme[key] then
            KhoXineHub.Config.Theme[key] = value
        end
    end
end

return KhoXineHub
