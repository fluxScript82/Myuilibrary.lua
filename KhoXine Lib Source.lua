-- KhoXine Hub UI Library
-- A comprehensive UI library for Roblox scripts

local KhoXineHub = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
KhoXineHub.Config = {
    Theme = {
        Primary = Color3.fromRGB(41, 53, 68),
        Secondary = Color3.fromRGB(35, 47, 62),
        Accent = Color3.fromRGB(86, 180, 233),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(72, 199, 142),
        Error = Color3.fromRGB(245, 59, 87)
    },
    Animation = {
        TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    },
    Draggable = true
}

-- Utility Functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function makeDraggable(frame)
    if not KhoXineHub.Config.Draggable then return end
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create Main Window
function KhoXineHub:CreateWindow(title)
    -- Parent ScreenGui
    local ScreenGui = createInstance("ScreenGui", {
        Name = "KhoXineHub",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    local MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -200, 0.5, -150),
        Size = UDim2.new(0, 400, 0, 300),
        ClipsDescendants = true
    })
    
    -- Apply corner radius
    local Corner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = createInstance("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local TitleCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TitleBar
    })
    
    local TitleFix = createInstance("Frame", {
        Name = "TitleFix",
        Parent = TitleBar,
        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0)
    })
    
    -- KhoXine Hub Title
    local HubTitle = createInstance("TextLabel", {
        Name = "HubTitle",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "KhoXine Hub",
        TextColor3 = KhoXineHub.Config.Theme.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Section Title
    local SectionTitle = createInstance("TextLabel", {
        Name = "SectionTitle",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, -40, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "",
        TextColor3 = KhoXineHub.Config.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Close Button
    local CloseButton = createInstance("TextButton", {
        Name = "CloseButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = KhoXineHub.Config.Theme.Text,
        TextSize = 20
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Content Container
    local ContentContainer = createInstance("ScrollingFrame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = KhoXineHub.Config.Theme.Accent,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local UIListLayout = createInstance("UIListLayout", {
        Parent = ContentContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local UIPadding = createInstance("UIPadding", {
        Parent = ContentContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    -- Make window draggable
    makeDraggable(MainFrame)
    
    -- Window object
    local Window = {}
    
    -- Add Section
    function Window:AddSection(title)
        local SectionFrame = createInstance("Frame", {
            Name = "Section",
            Parent = ContentContainer,
            BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        local SectionCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = SectionFrame
        })
        
        local SectionTitle = createInstance("TextLabel", {
            Name = "SectionTitle",
            Parent = SectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.GothamSemibold,
            Text = title or "Section",
            TextColor3 = KhoXineHub.Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local SectionContainer = createInstance("Frame", {
            Name = "SectionContainer",
            Parent = SectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 30),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        local SectionUIListLayout = createInstance("UIListLayout", {
            Parent = SectionContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
        
        local SectionUIPadding = createInstance("UIPadding", {
            Parent = SectionContainer,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        -- Section object
        local Section = {}
        
        -- Add Button
        function Section:AddButton(text, callback)
            callback = callback or function() end
            
            local Button = createInstance("TextButton", {
                Name = "Button",
                Parent = SectionContainer,
                BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text or "Button",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                AutoButtonColor = false
            })
            
            local ButtonCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Button
            })
            
            -- Button hover and click effects
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, KhoXineHub.Config.Animation.TweenInfo, {
                    BackgroundColor3 = Color3.fromRGB(
                        KhoXineHub.Config.Theme.Primary.R * 255 + 15,
                        KhoXineHub.Config.Theme.Primary.G * 255 + 15,
                        KhoXineHub.Config.Theme.Primary.B * 255 + 15
                    )
                }):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, KhoXineHub.Config.Animation.TweenInfo, {
                    BackgroundColor3 = KhoXineHub.Config.Theme.Primary
                }):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = KhoXineHub.Config.Theme.Accent
                }):Play()
                
                callback()
                
                task.delay(0.1, function()
                    TweenService:Create(Button, KhoXineHub.Config.Animation.TweenInfo, {
                        BackgroundColor3 = KhoXineHub.Config.Theme.Primary
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
                Size = UDim2.new(1, 0, 0, 30)
            })
            
            local ToggleLabel = createInstance("TextLabel", {
                Name = "ToggleLabel",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text or "Toggle",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ToggleButton = createInstance("Frame", {
                Name = "ToggleButton",
                Parent = ToggleFrame,
                BackgroundColor3 = default and KhoXineHub.Config.Theme.Accent or KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
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
                Position = UDim2.new(default and 0.5 or 0, default and 0 or 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            
            local ToggleCircleCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleCircle
            })
            
            local Toggled = default
            
            local function UpdateToggle()
                Toggled = not Toggled
                
                TweenService:Create(ToggleButton, KhoXineHub.Config.Animation.TweenInfo, {
                    BackgroundColor3 = Toggled and KhoXineHub.Config.Theme.Accent or KhoXineHub.Config.Theme.Primary
                }):Play()
                
                TweenService:Create(ToggleCircle, KhoXineHub.Config.Animation.TweenInfo, {
                    Position = Toggled 
                        and UDim2.new(0.5, 0, 0.5, -8) 
                        or UDim2.new(0, 2, 0.5, -8)
                }):Play()
                
                callback(Toggled)
            end
            
            ToggleButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    UpdateToggle()
                end
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
            default = default or min
            callback = callback or function() end
            
            local SliderFrame = createInstance("Frame", {
                Name = "Slider",
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50)
            })
            
            local SliderLabel = createInstance("TextLabel", {
                Name = "SliderLabel",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text or "Slider",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SliderValue = createInstance("TextLabel", {
                Name = "SliderValue",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -40, 0, 0),
                Size = UDim2.new(0, 40, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local SliderBackground = createInstance("Frame", {
                Name = "SliderBackground",
                Parent = SliderFrame,
                BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 10)
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
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
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
                Size = UDim2.new(0, 16, 0, 16)
            })
            
            local SliderCircleCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderCircle
            })
            
            local Value = default
            
            local function UpdateSlider(input)
                local pos = UDim2.new(math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1), 0, 1, 0)
                SliderFill.Size = pos
                
                local value = math.floor(min + ((max - min) * pos.X.Scale))
                SliderValue.Text = tostring(value)
                Value = value
                
                callback(value)
            end
            
            SliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    UpdateSlider(input)
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(input)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
                    callback(value)
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
                Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = true
            })
            
            local DropdownLabel = createInstance("TextLabel", {
                Name = "DropdownLabel",
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text or "Dropdown",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local DropdownButton = createInstance("TextButton", {
                Name = "DropdownButton",
                Parent = DropdownFrame,
                BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = default or "Select...",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                AutoButtonColor = false
            })
            
            local DropdownButtonCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = DropdownButton
            })
            
            local DropdownIcon = createInstance("TextLabel", {
                Name = "DropdownIcon",
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0, 0),
                Size = UDim2.new(0, 25, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "▼",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14
            })
            
            local DropdownContent = createInstance("Frame", {
                Name = "DropdownContent",
                Parent = DropdownFrame,
                BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 65),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false
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
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 30 + 35 + (#options * 25) + 10)
                    DropdownContent.Size = UDim2.new(1, 0, 0, (#options * 25) + 10)
                    DropdownContent.Visible = true
                    TweenService:Create(DropdownIcon, KhoXineHub.Config.Animation.TweenInfo, {
                        Rotation = 180
                    }):Play()
                else
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                    DropdownContent.Visible = false
                    TweenService:Create(DropdownIcon, KhoXineHub.Config.Animation.TweenInfo, {
                        Rotation = 0
                    }):Play()
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
            
            for i, option in ipairs(options) do
                local OptionButton = createInstance("TextButton", {
                    Name = "Option",
                    Parent = DropdownContent,
                    BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = KhoXineHub.Config.Theme.Text,
                    TextSize = 14,
                    AutoButtonColor = false
                })
                
                local OptionButtonCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = OptionButton
                })
                
                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, KhoXineHub.Config.Animation.TweenInfo, {
                        BackgroundColor3 = Color3.fromRGB(
                            KhoXineHub.Config.Theme.Secondary.R * 255 + 15,
                            KhoXineHub.Config.Theme.Secondary.G * 255 + 15,
                            KhoXineHub.Config.Theme.Secondary.B * 255 + 15
                        )
                    }):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, KhoXineHub.Config.Animation.TweenInfo, {
                        BackgroundColor3 = KhoXineHub.Config.Theme.Secondary
                    }):Play()
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    SelectedOption = option
                    DropdownButton.Text = option
                    ToggleDropdown()
                    callback(option)
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
                        callback(value)
                    end
                end,
                Add = function(self, option)
                    if not table.find(options, option) then
                        table.insert(options, option)
                        
                        local OptionButton = createInstance("TextButton", {
                            Name = "Option",
                            Parent = DropdownContent,
                            BackgroundColor3 = KhoXineHub.Config.Theme.Secondary,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 25),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = KhoXineHub.Config.Theme.Text,
                            TextSize = 14,
                            AutoButtonColor = false
                        })
                        
                        local OptionButtonCorner = createInstance("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = OptionButton
                        })
                        
                        OptionButton.MouseEnter:Connect(function()
                            TweenService:Create(OptionButton, KhoXineHub.Config.Animation.TweenInfo, {
                                BackgroundColor3 = Color3.fromRGB(
                                    KhoXineHub.Config.Theme.Secondary.R * 255 + 15,
                                    KhoXineHub.Config.Theme.Secondary.G * 255 + 15,
                                    KhoXineHub.Config.Theme.Secondary.B * 255 + 15
                                )
                            }):Play()
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            TweenService:Create(OptionButton, KhoXineHub.Config.Animation.TweenInfo, {
                                BackgroundColor3 = KhoXineHub.Config.Theme.Secondary
                            }):Play()
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            SelectedOption = option
                            DropdownButton.Text = option
                            ToggleDropdown()
                            callback(option)
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
                            callback(SelectedOption)
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
                Size = UDim2.new(1, 0, 0, 50)
            })
            
            local TextBoxLabel = createInstance("TextLabel", {
                Name = "TextBoxLabel",
                Parent = TextBoxFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text or "TextBox",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local TextBoxInput = createInstance("TextBox", {
                Name = "TextBoxInput",
                Parent = TextBoxFrame,
                BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                PlaceholderText = placeholder,
                Text = default,
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                ClearTextOnFocus = false
            })
            
            local TextBoxInputCorner = createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = TextBoxInput
            })
            
            TextBoxInput.FocusLost:Connect(function(enterPressed)
                callback(TextBoxInput.Text, enterPressed)
            end)
            
            -- TextBox object
            local TextBox = {
                Value = default,
                Set = function(self, value)
                    TextBoxInput.Text = value
                    callback(value, false)
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
                Size = UDim2.new(1, 0, 0, 20)
            })
            
            local Label = createInstance("TextLabel", {
                Name = "Label",
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text or "Label",
                TextColor3 = KhoXineHub.Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Label object
            local LabelObj = {
                Set = function(self, text)
                    Label.Text = text
                end
            }
            
            return LabelObj
        end
        
        return Section
    end
    
    -- Add Notification
    function Window:AddNotification(title, text, duration)
        title = title or "Notification"
        text = text or "This is a notification"
        duration = duration or 3
        
        local NotificationFrame = createInstance("Frame", {
            Name = "Notification",
            Parent = ScreenGui,
            BackgroundColor3 = KhoXineHub.Config.Theme.Primary,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -250, 1, -100),
            Size = UDim2.new(0, 250, 0, 80),
            AnchorPoint = Vector2.new(1, 1)
        })
        
        local NotificationCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = NotificationFrame
        })
        
        local NotificationTitle = createInstance("TextLabel", {
            Name = "NotificationTitle",
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamSemibold,
            Text = title,
            TextColor3 = KhoXineHub.Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local NotificationText = createInstance("TextLabel", {
            Name = "NotificationText",
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 30),
            Size = UDim2.new(1, -20, 0, 40),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = KhoXineHub.Config.Theme.TextDark,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        -- Animation
        NotificationFrame.Position = UDim2.new(1, 50, 1, -100)
        TweenService:Create(NotificationFrame, KhoXineHub.Config.Animation.TweenInfo, {
            Position = UDim2.new(1, -20, 1, -100)
        }):Play()
        
        task.delay(duration, function()
            TweenService:Create(NotificationFrame, KhoXineHub.Config.Animation.TweenInfo, {
                Position = UDim2.new(1, 300, 1, -100)
            }):Play()
            
            task.delay(0.5, function()
                NotificationFrame:Destroy()
            end)
        end)
    end
    
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
