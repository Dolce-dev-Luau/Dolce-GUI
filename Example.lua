local CyberGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Dolce-dev-Luau/Cyber-GUI/refs/heads/main/src/init.lua"))()

-- Create window
local Window = CyberGUI:CreateWindow({
    Title = "Dolce Hub",
    SubTitle = "By Dolce Dev",
    Size = UDim2.new(0, 700, 0, 520),
    Position = UDim2.new(0.5, -350, 0.5, -260)
})

-- Main Tab
local MainTab = Window:AddTab({
    Title = "🛠 Control",
    Icon = "cyber"
})

-- Section: Weapons
local Section1 = MainTab:AddSection("Weapons System")

local Button1 = Section1:AddButton({
    Title = "⚡ Activate Railgun",
    Description = "Fire the electromagnetic railgun",
    ButtonText = "FIRE",
    Callback = function()
        print("⚡ RAILGUN FIRED!")
        CyberGUI:Notify({
            Title = "Railgun",
            Description = "Weapon system activated!",
            Duration = 3
        })
    end
})

local Toggle1 = Section1:AddToggle({
    Title = "🔋 Shield Generator",
    Description = "Toggle energy shield",
    Default = true,
    Callback = function(State)
        print("Shield:", State and "ACTIVE" or "OFFLINE")
    end
})

-- Section: Settings
local Section2 = MainTab:AddSection("System Settings")

local Slider1 = Section2:AddSlider({
    Title = "🌀 Power Output",
    Description = "Adjust energy output level",
    Min = 0,
    Max = 100,
    Default = 75,
    Callback = function(Value)
        print("Power:", Value .. "%")
    end
})

local Dropdown1 = Section2:AddDropdown({
    Title = "🎨 Color Theme",
    Description = "Select interface color scheme",
    Values = {"Neon Pink", "Cyan", "Purple", "Orange"},
    Default = 1,
    Callback = function(Value, Index)
        print("Theme selected:", Value)
        CyberGUI:Notify({
            Title = "Theme Changed",
            Description = "Now using: " .. Value,
            Duration = 2
        })
    end
})

local Input1 = Section2:AddInput({
    Title = "📝 System Command",
    Description = "Enter a command to execute",
    Placeholder = "type command...",
    Default = "",
    Callback = function(Text)
        print("Command executed:", Text)
    end
})

-- Second Tab
local SysTab = Window:AddTab({
    Title = "📊 Stats",
    Icon = "terminal"
})

local Section3 = SysTab:AddSection("System Status")

local StatsText = Section3:AddParagraph({
    Title = "System Information",
    Description = "CPU: 45% | RAM: 2.4GB | Temp: 62°C",
    Text = "Status: ONLINE\nUptime: 12h 34m\nConnections: 8"
})

-- Button to update stats
local RefreshBtn = Section3:AddButton({
    Title = "🔄 Refresh Stats",
    Description = "Update system information",
    ButtonText = "REFRESH",
    Callback = function()
        print("Stats refreshed!")
        CyberGUI:Notify({
            Title = "Stats Updated",
            Description = "System information refreshed",
            Duration = 2
        })
    end
})

-- Third Tab
local ToolsTab = Window:AddTab({
    Title = "🔧 Tools",
    Icon = "chip"
})

local Section4 = ToolsTab:AddSection("Utility Tools")

local Tool1 = Section4:AddButton({
    Title = "🔍 Network Scan",
    Description = "Scan for nearby connections",
    ButtonText = "SCAN",
    Callback = function()
        print("🔍 Scanning network...")
        CyberGUI:Notify({
            Title = "Scan Complete",
            Description = "Found 4 active connections",
            Duration = 3
        })
    end
})

local Tool2 = Section4:AddButton({
    Title = "💀 Emergency Shutdown",
    Description = "WARNING: This will shut down all systems!",
    ButtonText = "SHUTDOWN",
    Callback = function()
        print("💀 SYSTEM SHUTDOWN!")
        CyberGUI:Notify({
            Title = "⚠ SYSTEM SHUTDOWN",
            Description = "All systems are going offline!",
            Duration = 5
        })
    end
})

-- Theme toggle button
local ThemeBtn = Window.TitleBar.AddButton({
    Title = "🌓 Theme",
    Callback = function()
        local NewTheme = CyberGUI:ToggleTheme()
        print("Theme changed to:", NewTheme)
        CyberGUI:Notify({
            Title = "Theme Changed",
            Description = "Switched to " .. NewTheme .. " mode",
            Duration = 2
        })
    end
})

print("✅ CyberGUI loaded successfully!")
