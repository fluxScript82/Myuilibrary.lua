-- Load the library
local MafuyoLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/fluxScript82/Myuilibrary.lua/refs/heads/main/KhoXine%20Lib%20Source.lua"))()

-- Create a new UI
local UI = MafuyoLib.new()

-- Set your logo (optional)
UI:setLogo("rbxassetid://YOUR_LOGO_ID")

-- Create tabs
local mainTab = UI:createTab("Main")
local settingsTab = UI:createTab("Settings")

-- Add elements to tabs
UI:addButton("Main", "Click Me", function()
    print("Button clicked!")
end)

UI:addToggle("Settings", "Enable Feature", false, function(enabled)
    print("Toggle set to: " .. tostring(enabled))
end)

UI:addSlider("Settings", "Speed", 0, 100, 50, function(value)
    print("Slider value: " .. value)
end)
