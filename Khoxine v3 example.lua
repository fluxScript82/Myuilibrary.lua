-- Example usage of ProfessionalUI v3

local ProfessionalUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/ProfessionalUI/main/main.lua"))()

-- Configure the library
ProfessionalUI.Config.Theme = {
    -- Base colors
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(30, 30, 40),
    Tertiary = Color3.fromRGB(35, 35, 45),
    
    -- Accent colors (unique blue/purple gradient)
    Accent1 = Color3.fromRGB(90, 120, 255),  -- Primary accent (blue)
    Accent2 = Color3.fromRGB(180, 90, 255),  -- Secondary accent (purple)
    
    -- Text colors
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    
    -- Status colors
    Success = Color3.fromRGB(70, 200, 120),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 180, 30),
    
    -- Effects
    Glow = Color3.fromRGB(100, 130, 255),
    Transparency = 0.95,
    
    -- Gradients
    GradientEnabled = true,
    Gradient1 = Color3.fromRGB(90, 120, 255),
    Gradient2 = Color3.fromRGB(180, 90, 255)
}

-- Configure key system
ProfessionalUI.Config.KeySystem.Enabled = true
ProfessionalUI.Config.KeySystem.AllowTrial = true
ProfessionalUI.Config.KeySystem.TrialTime = 300 -- 5 minutes

-- Add keys with advanced options
ProfessionalUI.KeySystem:AddKey("PREMIUM-KEY-123", os.time() + 2592000) -- Key with 30-day expiration
ProfessionalUI.KeySystem:AddKey("LIFETIME-KEY-456") -- Lifetime key (no expiration)
ProfessionalUI.KeySystem:AddKey("HWID-KEY-789", nil, ProfessionalUI.Utility:GetHWID()) -- HWID-locked key

-- Initialize the key system
ProfessionalUI.KeySystem:Prompt(function(success, timeLeft)
    if success then
        -- Create the main window
        local window = ProfessionalUI.Components:CreateWindow("Professional UI v3 Suite")
        
        -- Create tabs with icons
        local mainTab = window:AddTab("Main", "rbxassetid://6026568198")
        local combatTab = window:AddTab("Combat", "rbxassetid://6034509993")
        local visualsTab = window:AddTab("Visuals", "rbxassetid://6031763426")
        local settingsTab = window:AddTab("Settings", "rbxassetid://6031280882")
        local creditsTab = window:AddTab("Credits", "rbxassetid://6022668888")
        
        -- Main Tab
        local automationSection = mainTab:AddSection("Automation")
        
        local aimbotToggle = automationSection:AddToggle("Aimbot", false, function(value)
            print("Aimbot:", value)
        end)
        
        automationSection:AddButton("Reset Aimbot System", function()
            print("Aimbot system reset")
            aimbotToggle:Set(false)
        end)
        
        local espSection = mainTab:AddSection("ESP Settings")
        
        espSection:AddSlider("ESP Range", 100, 1000, 750, function(value)
            print("ESP Range set to:", value)
        end)
        
        local players = {}
        for _, player in ipairs(game.Players:GetPlayers()) do
            table.insert(players, player.Name)
        end
        
        local targetDropdown = espSection:AddDropdown("Target Player", players, players[1], function(selected)
            print("Target Player:", selected)
        end)
        
        game.Players.PlayerAdded:Connect(function(player)
            table.insert(players, player.Name)
            targetDropdown:Refresh(players, true)
        end)
        
        game.Players.PlayerRemoving:Connect(function(player)
            local index = table.find(players, player.Name)
            if index then
                table.remove(players, index)
                targetDropdown:Refresh(players, true)
            end
        end)
        
        espSection:AddKeybind("Target Keybind", Enum.KeyCode.Q, function()
            print("Target keybind pressed")
        end)
        
        -- Combat Tab
        local aimSection = combatTab:AddSection("Aim Settings")
        
        aimSection:AddToggle("Silent Aim", false, function(value)
            print("Silent Aim:", value)
        end)
        
        aimSection:AddSlider("Aim FOV", 10, 500, 120, function(value)
            print("Aim FOV set to:", value)
        end)
        
        aimSection:AddSlider("Headshot Chance", 0, 100, 70, function(value)
            print("Headshot Chance set to:", value .. "%")
        end)
        
        local weaponSection = combatTab:AddSection("Weapon Modifications")
        
        weaponSection:AddToggle("No Recoil", false, function(value)
            print("No Recoil:", value)
        end)
        
        weaponSection:AddToggle("Infinite Ammo", false, function(value)
            print("Infinite Ammo:", value)
        end)
        
        weaponSection:AddSlider("Fire Rate", 100, 1000, 500, function(value)
            print("Fire Rate set to:", value)
        end)
        
        -- Visuals Tab
        local playerESPSection = visualsTab:AddSection("Player ESP")
        
        playerESPSection:AddToggle("Box ESP", false, function(value)
            print("Box ESP:", value)
        end)
        
        playerESPSection:AddToggle("Name ESP", false, function(value)
            print("Name ESP:", value)
        end)
        
        playerESPSection:AddToggle("Health Bar", false, function(value)
            print("Health Bar:", value)
        end)
        
        local worldSection = visualsTab:AddSection("World Settings")
        
        worldSection:AddToggle("Full Bright", false, function(value)
            print("Full Bright:", value)
        end)
        
        worldSection:AddToggle("No Fog", false, function(value)
            print("No Fog:", value)
        end)
        
        worldSection:AddSlider("Time of Day", 0, 24, 12, function(value)
            print("Time of Day set to:", value)
        end)
        
        -- Settings Tab
        local generalSection = settingsTab:AddSection("General Settings")
        
        generalSection:AddToggle("Save Settings", true, function(value)
            print("Save Settings:", value)
        end)
        
        generalSection:AddToggle("Auto-Launch", false, function(value)
            print("Auto-Launch:", value)
        end)
        
        generalSection:AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function()
            print("UI Toggled")
        end)
        
        local themeSection = settingsTab:AddSection("Theme Settings")
        
        local themes = {"Default", "Dark", "Light", "Blue", "Purple", "Green", "Red", "Orange"}
        themeSection:AddDropdown("Theme", themes, "Default", function(selected)
            print("Theme selected:", selected)
        end)
        
        themeSection:AddToggle("Enable Particles", true, function(value)
            ProfessionalUI.Config.Effects.Particles = value
            print("Particles:", value)
        end)
        
        themeSection:AddToggle("Enable Sounds", true, function(value)
            ProfessionalUI.Config.Effects.Sounds = value
            print("Sounds:", value)
        end)
        
        -- Credits Tab
        local creditsSection = creditsTab:AddSection("Credits")
        
        creditsSection:AddButton("Developer: YourName", function()
            setclipboard("https://github.com/yourusername")
        end)
        
        creditsSection:AddButton("Join Discord", function()
            setclipboard("https://discord.gg/yourdiscord")
        end)
        
        local versionSection = creditsTab:AddSection("Version Info")
        
        versionSection:AddTextbox("Current Version", "v3.0.0", "v3.0.0", function() end)
        
        if timeLeft then
            local trialSection = creditsTab:AddSection("Trial Information")
            
            local timeLeftMinutes = math.floor(timeLeft / 60)
            local timeLeftSeconds = timeLeft % 60
            
            trialSection:AddTextbox("Time Remaining", timeLeftMinutes .. "m " .. timeLeftSeconds .. "s", nil, function() end)
            
            trialSection:AddButton("Purchase Premium", function()
                setclipboard("https://example.com/purchase")
            end)
        end
    else
        print("Key verification failed")
    end
end)
