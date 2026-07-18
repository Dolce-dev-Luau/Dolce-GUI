-- CyberGUI - A Cyberpunk themed UI library for Roblox
-- Based on Fluent's architecture but with unique design

local CyberGUI = {}
CyberGUI.__index = CyberGUI

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Dependencies
local Creator = require(script.Creator)
local Themes = require(script.Themes)
local Elements = require(script.Elements)
local Components = require(script.Components)
local Icons = require(script.Icons)

-- Constants
local GUI_NAME = "CyberGUI"

-- Vars
local CurrentTheme = "Dark"
local ScreenGui = nil
local Library = {}
local ElementsTable = {}

-- Utility to get Icon
function CyberGUI.GetIcon(Name)
    return Icons[Name] or ""
end

-- Safe callback execution
function CyberGUI.SafeCallback(Callback, ...)
    if type(Callback) == "function" then
        local Success, ErrorMessage = pcall(Callback, ...)
        if not Success then
            warn("[CyberGUI] Callback error:", ErrorMessage)
        end
        return Success
    end
    return false
end

-- Setup ScreenGui
local function SetupScreenGui()
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
    
    ScreenGui = Creator.New("ScreenGui", {
        Name = GUI_NAME,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
        IgnoreGuiInset = true
    })
    
    -- Protect GUI
    if ProtectGui then
        ProtectGui(ScreenGui)
    end
end

-- Window constructor
function CyberGUI:CreateWindow(Config)
    assert(Config and Config.Title, "CyberGUI:CreateWindow - Missing Title")
    
    SetupScreenGui()
    
    local WindowFrame = Components.Window(Config, ScreenGui, CyberGUI)
    local Window = WindowFrame
    
    -- Add methods
    Window.__index = Window
    
    function Window:AddTab(TabConfig)
        assert(TabConfig and TabConfig.Title, "AddTab - Missing Title")
        return Components.Tab(TabConfig, self, CyberGUI)
    end
    
    function Window:RemoveTab(Index)
        if self.TabsHolder and self.TabsHolder[Index] then
            self.TabsHolder[Index]:Destroy()
            table.remove(self.TabsHolder, Index)
        end
    end
    
    function Window:GetCurrentTab()
        return self.CurrentTab or self.TabsHolder and self.TabsHolder[1]
    end
    
    function Window:GetAllTabs()
        return self.TabsHolder or {}
    end
    
    function Window:SetTitle(NewTitle)
        if self.TitleLabel then
            self.TitleLabel.Text = NewTitle
        end
    end
    
    function Window:SetSize(NewSize)
        if self.MainFrame then
            self.MainFrame.Size = NewSize
        end
    end
    
    -- Return window object
    return Window
end

-- Element creator methods
function CyberGUI:CreateElement(Type, Container, Config)
    local ElementModule = ElementsTable[Type]
    if not ElementModule then
        warn("[CyberGUI] Unknown element type:", Type)
        return nil
    end
    
    local Element = ElementModule:New(Config, Container, CyberGUI)
    return Element
end

-- Theme management
function CyberGUI:SetTheme(ThemeName)
    assert(Themes[ThemeName], "CyberGUI:SetTheme - Theme not found: " .. ThemeName)
    CurrentTheme = ThemeName
    Creator.UpdateTheme(Themes[CurrentTheme])
end

function CyberGUI:GetTheme()
    return CurrentTheme
end

function CyberGUI:GetCurrentThemeColors()
    return Themes[CurrentTheme]
end

function CyberGUI:ToggleTheme()
    local NewTheme = CurrentTheme == "Dark" and "Light" or "Dark"
    self:SetTheme(NewTheme)
    return NewTheme
end

-- Notification system
function CyberGUI:Notify(Config)
    Config = Config or {}
    assert(Config.Title, "CyberGUI:Notify - Missing Title")
    
    -- Create notification
    local Notification = Creator.New("Frame", {
        Name = "Notification",
        Parent = ScreenGui,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(0.5, -150, 0, 50),
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    
    -- Add border glow
    local Border = Creator.New("Frame", {
        Parent = Notification,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Color3.fromRGB(255, 45, 93),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    
    -- Title
    local Title = Creator.New("TextLabel", {
        Parent = Notification,
        Text = Config.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        ZIndex = 10
    })
    
    -- Description
    if Config.Description then
        local Desc = Creator.New("TextLabel", {
            Parent = Notification,
            Text = Config.Description,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 40),
            BackgroundTransparency = 1,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            ZIndex = 10
        })
    end
    
    -- Close button
    local CloseBtn = Creator.New("TextButton", {
        Parent = Notification,
        Text = "✕",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0, 5),
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 10
    })
    
    local function DestroyNotification()
        Notification:Destroy()
    end
    
    CloseBtn.MouseButton1Click:Connect(DestroyNotification)
    
    -- Auto destroy after 5 seconds
    task.delay(5, function()
        if Notification and Notification.Parent then
            DestroyNotification()
        end
    end)
    
    return Notification
end

-- Initialize elements
for _, ElementModule in ipairs(Elements) do
    local ElementType = ElementModule.__type
    if ElementType then
        ElementsTable[ElementType] = ElementModule
    end
end

-- Setup theme
CyberGUI:SetTheme("Dark")

-- Export
return CyberGUI
