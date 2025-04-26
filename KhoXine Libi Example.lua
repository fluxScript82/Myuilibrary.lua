local KhoXineHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/fluxScript82/Myuilibrary.lua/refs/heads/main/KhoXine%20Lib%20Source.lua"))()

-- Create a window
local Window = KhoXineHub:CreateWindow("KhoXine Hub", {
    Size = UDim2.new(0, 500, 0, 400)
})

-- Create tabs
local MainTab = Window:AddTab("Main", "rbxassetid://7733960981")
local SettingsTab = Window:AddTab("Settings", "rbxassetid://7734053495")

-- Add sections to tabs
local FeaturesSection = MainTab:AddSection("Features")
local ConfigSection = SettingsTab:AddSection("Configuration")

-- Add components to sections
FeaturesSection:AddButton("Activate Speed", function()
    -- Your code here
    Window:AddNotification("Success", "Speed activated!", {type = "success"})
end)

local SpeedToggle = FeaturesSection:AddToggle("Auto Farm", false, function(value)
    -- Your code here
    print("Auto Farm:", value)
end)

local SpeedSlider = FeaturesSection:AddSlider("Speed Multiplier", 1, 10, 2, function(value)
    -- Your code here
    print("Speed set to:", value)
end)

ConfigSection:AddDropdown("Theme", {"Default", "Dark", "Light", "Custom"}, "Default", function(option)
    -- Your code here
    print("Theme changed to:", option)
end)

ConfigSection:AddColorPicker("Accent Color", Color3.fromRGB(113, 93, 255), function(color)
    -- Your code here
    print("Color changed to:", color)
end)
