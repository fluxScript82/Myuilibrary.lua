local KhoXineHub = loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL"))()

-- Create a window (the section title will appear next to "KhoXine Hub")
local Window = KhoXineHub:CreateWindow("Main Menu")

-- Create a section for player modifications
local PlayerSection = Window:AddSection("Player")

-- Add a speed slider
local SpeedSlider = PlayerSection:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Add a jump power slider
local JumpSlider = PlayerSection:AddSlider("Jump Power", 50, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

-- Create a section for game features
local GameSection = Window:AddSection("Game Features")

-- Add a toggle for ESP
local ESPToggle = GameSection:AddToggle("Enable ESP", false, function(value)
    -- Your ESP code here
    print("ESP Enabled: " .. tostring(value))
end)

-- Add a button to teleport to spawn
GameSection:AddButton("Teleport to Spawn", function()
    -- Your teleport code here
    print("Teleporting to spawn...")
end)

-- Create a section for settings
local SettingsSection = Window:AddSection("Settings")

-- Add a dropdown for themes
local ThemeDropdown = SettingsSection:AddDropdown("Theme", {"Default", "Dark", "Light", "Ocean"}, "Default", function(value)
    if value == "Dark" then
        KhoXineHub:SetTheme({
            Primary = Color3.fromRGB(25, 25, 25),
            Secondary = Color3.fromRGB(30, 30, 30),
            Accent = Color3.fromRGB(255, 75, 75)
        })
    elseif value == "Light" then
        KhoXineHub:SetTheme({
            Primary = Color3.fromRGB(230, 230, 230),
            Secondary = Color3.fromRGB(240, 240, 240),
            Accent = Color3.fromRGB(0, 120, 215),
            Text = Color3.fromRGB(50, 50, 50)
        })
    elseif value == "Ocean" then
        KhoXineHub:SetTheme({
            Primary = Color3.fromRGB(35, 47, 62),
            Secondary = Color3.fromRGB(28, 40, 55),
            Accent = Color3.fromRGB(0, 170, 255)
        })
    end
end)

-- Show a notification when the script loads
Window:AddNotification("KhoXine Hub", "Script loaded successfully!", 5)
