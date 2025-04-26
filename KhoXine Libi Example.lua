local ProfessionalUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/ProfessionalUI/main/main.lua"))()

-- Configure the library
ProfessionalUI.Config.Theme.Accent = Color3.fromRGB(0, 120, 215) -- Blue accent color
ProfessionalUI.Config.KeySystem.Enabled = true
ProfessionalUI.KeySystem:SetKeys({"ProfessionalUI", "Demo123"}) -- Set valid keys

-- Initialize the key system
ProfessionalUI.KeySystem:Prompt(function(success)
    if success then
        -- Create the main window
        local window = ProfessionalUI.Components:CreateWindow("Professional UI Suite")
        
        -- Create tabs
        local mainTab = window:AddTab("Main", "rbxassetid://6026568198")
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
        
        -- Settings Tab
        local generalSection = settingsTab:AddSection("General Settings")
        
        generalSection:AddToggle("Save Settings", true, function(value)
            print("Save Settings:", value)
        end)
        
        generalSection:AddToggle("Auto-Launch", false, function(value)
            print("Auto-Launch:", value)
        end)
        
        local themeSection = settingsTab:AddSection("Theme Settings")
        
        local themes = {"Default", "Dark", "Light", "Blue", "Red", "Green"}
        themeSection:AddDropdown("Theme", themes, "Default", function(selected)
            print("Theme selected:", selected)
        end)
        
        themeSection:AddTextbox("Custom Accent Color", "0,120,215", nil, function(text)
            print("Custom color:", text)
        end)
        
        -- Credits Tab
        local creditsSection = creditsTab:AddSection("Credits")
        
        creditsSection:AddButton("Developer: YourName", function()
            setclipboard("https://github.com/yourusername")
        end)
        
        creditsSection:AddButton("Join Discord", function()
            setclipboard("https://discord.gg/yourdiscord")
        end)
    else
        print("Key verification failed")
    end
end)
