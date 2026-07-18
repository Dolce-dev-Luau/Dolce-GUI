-- CyberGUI - Main Entry Point
-- This is the file loaded by loadstring()
-- Equivalent to Fluent's main.lua

local CyberGUI = {}
CyberGUI.__index = CyberGUI

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ============================================================
-- DEPENDENCIES
-- ============================================================
local Creator = require(script.Creator)
local Themes = require(script.Themes)
local Elements = require(script.Elements)
local Components = require(script.Components)
local Icons = require(script.Icons)

-- ============================================================
-- CONSTANTS
-- ============================================================
local GUI_NAME = "CyberGUI"
local VERSION = "1.0.0"

-- ============================================================
-- STATE
-- ============================================================
local CurrentTheme = "Dark"
local ScreenGui = nil
local Library = {}
local ElementsTable = {}
local Notifications = {}
local Windows = {}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- Get icon by name
function CyberGUI.GetIcon(Name)
    return Icons[Name] or "❓"
end

-- Safe callback execution (prevents errors from crashing UI)
function CyberGUI.SafeCallback(Callback, ...)
    if type(Callback) == "function" then
        local Success, ErrorMessage = pcall(Callback, ...)
        if not Success then
            warn("[CyberGUI] Callback error:", ErrorMessage)
            -- Optionally show error in UI
            CyberGUI:Notify({
                Title = "⚠ Error",
                Description = "Callback failed: " .. tostring(ErrorMessage),
                Duration = 3
            })
        end
        return Success
    end
    return false
end

-- Version check
function CyberGUI:GetVersion()
    return VERSION
end

-- ============================================================
-- SCREENGUI MANAGEMENT
-- ============================================================

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
    
    -- Protect GUI (if ProtectGui is available)
    if ProtectGui then
        ProtectGui(ScreenGui)
    end
    
    return ScreenGui
end

function CyberGUI:GetScreenGui()
    if not ScreenGui or not ScreenGui.Parent then
        SetupScreenGui()
    end
    return ScreenGui
end

-- ============================================================
-- WINDOW CREATION
-- ============================================================

function CyberGUI:CreateWindow(Config)
    assert(Config and Config.Title, "CyberGUI:CreateWindow - Missing Title")
    
    -- Setup ScreenGui
    local Gui = SetupScreenGui()
    
    -- Create window using Window component
    local WindowFrame = Components.Window(Config, Gui, CyberGUI)
    
    -- Extend window with methods
    local Window = WindowFrame
    
    -- Add Tab method
    function Window:AddTab(TabConfig)
        assert(TabConfig and TabConfig.Title, "AddTab - Missing Title")
        return Components.Tab(TabConfig, self, CyberGUI)
    end
    
    -- Remove tab
    function Window:RemoveTab(Index)
        if self.TabsHolder and self.TabsHolder[Index] then
            self.TabsHolder[Index]:Destroy()
            table.remove(self.TabsHolder, Index)
        end
    end
    
    -- Get current tab
    function Window:GetCurrentTab()
        return self.CurrentTab or (self.TabsHolder and self.TabsHolder[1])
    end
    
    -- Get all tabs
    function Window:GetAllTabs()
        return self.TabsHolder or {}
    end
    
    -- Set window title
    function Window:SetTitle(NewTitle)
        if self.TitleLabel then
            self.TitleLabel.Text = NewTitle
        end
    end
    
    -- Set window size
    function Window:SetSize(NewSize)
        if self.MainFrame then
            self.MainFrame.Size = NewSize
        end
    end
    
    -- Set window position
    function Window:SetPosition(NewPosition)
        if self.MainFrame then
            self.MainFrame.Position = NewPosition
        end
    end
    
    -- Close window
    function Window:Close()
        if self.MainFrame then
            self.MainFrame:Destroy()
        end
        -- Remove from windows list
        for i, w in ipairs(Windows) do
            if w == self then
                table.remove(Windows, i)
                break
            end
        end
    end
    
    -- Show/Hide window
    function Window:Show()
        if self.MainFrame then
            self.MainFrame.Visible = true
        end
    end
    
    function Window:Hide()
        if self.MainFrame then
            self.MainFrame.Visible = false
        end
    end
    
    -- Minimize/Maximize toggle
    function Window:ToggleMaximize()
        if self.MainFrame then
            if self.MainFrame.Size == self.Config.Size then
                -- Maximize
                self.MainFrame.Size = UDim2.new(1, -20, 1, -20)
                self.MainFrame.Position = UDim2.new(0, 10, 0, 10)
            else
                -- Restore
                self.MainFrame.Size = self.Config.Size
                self.MainFrame.Position = self.Config.Position
            end
        end
    end
    
    -- Store window reference
    table.insert(Windows, Window)
    
    return Window
end

-- ============================================================
-- ELEMENT CREATION
-- ============================================================

function CyberGUI:CreateElement(Type, Container, Config)
    local ElementModule = ElementsTable[Type]
    if not ElementModule then
        warn("[CyberGUI] Unknown element type:", Type)
        return nil
    end
    
    local Element = ElementModule:New(Config, Container, CyberGUI)
    return Element
end

-- Register elements
for _, ElementModule in ipairs(Elements) do
    local ElementType = ElementModule.__type
    if ElementType then
        ElementsTable[ElementType] = ElementModule
    end
end

-- ============================================================
-- THEME MANAGEMENT
-- ============================================================

function CyberGUI:SetTheme(ThemeName)
    assert(Themes[ThemeName], "CyberGUI:SetTheme - Theme not found: " .. ThemeName)
    CurrentTheme = ThemeName
    Creator.UpdateTheme(Themes[CurrentTheme])
    
    -- Update all windows
    for _, Window in ipairs(Windows) do
        if Window and Window.UpdateTheme then
            Window:UpdateTheme()
        end
    end
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

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================

function CyberGUI:Notify(Config)
    Config = Config or {}
    assert(Config.Title, "CyberGUI:Notify - Missing Title")
    
    local Theme = self:GetCurrentThemeColors()
    local Duration = Config.Duration or 4
    
    -- Get ScreenGui
    local Gui = self:GetScreenGui()
    
    -- Create notification frame
    local Notification = Creator.New("Frame", {
        Name = "Notification",
        Parent = Gui,
        Size = UDim2.new(0, 320, 0, 80),
        Position = UDim2.new(0.5, -160, 0, 50),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    
    -- Neon border glow
    local Border = Creator.New("Frame", {
        Parent = Notification,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    
    -- Title
    local Title = Creator.New("TextLabel", {
        Parent = Notification,
        Text = Config.Title,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -30, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        ZIndex = 10
    })
    
    -- Description
    if Config.Description then
        local Desc = Creator.New("TextLabel", {
            Parent = Notification,
            Text = Config.Description,
            TextColor3 = Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -30, 0, 22),
            Position = UDim2.new(0, 10, 0, 36),
            BackgroundTransparency = 1,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            ZIndex = 10
        })
    end
    
    -- Close button
    local CloseBtn = Creator.New("TextButton", {
        Parent = Notification,
        Text = "✕",
        TextColor3 = Theme.TextSecondary,
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
    
    -- Animation: slide in
    Notification.Position = UDim2.new(0.5, -160, 0, -100)
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0, 50)
    }):Play()
    
    -- Auto destroy after duration
    task.delay(Duration, function()
        if Notification and Notification.Parent then
            -- Slide out animation
            TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -160, 0, -100)
            }):Play()
            task.delay(0.3, DestroyNotification)
        end
    end)
    
    return Notification
end

-- ============================================================
-- UTILITY: GET ALL WINDOWS
-- ============================================================

function CyberGUI:GetWindows()
    return Windows
end

function CyberGUI:GetWindowByTitle(Title)
    for _, Window in ipairs(Windows) do
        if Window.Config and Window.Config.Title == Title then
            return Window
        end
    end
    return nil
end

function CyberGUI:CloseAllWindows()
    for _, Window in ipairs(Windows) do
        Window:Close()
    end
    Windows = {}
end

-- ============================================================
-- UTILITY: CREATE CONFIRMATION DIALOG
-- ============================================================

function CyberGUI:Confirm(Config)
    Config = Config or {}
    assert(Config.Title, "CyberGUI:Confirm - Missing Title")
    assert(Config.Message, "CyberGUI:Confirm - Missing Message")
    
    -- Create a simple confirmation dialog using a new window
    local ConfirmWindow = self:CreateWindow({
        Title = Config.Title,
        Size = UDim2.new(0, 400, 0, 180),
        Position = UDim2.new(0.5, -200, 0.5, -90)
    })
    
    local Tab = ConfirmWindow:AddTab({ Title = "Confirm" })
    local Section = Tab:AddSection("")
    
    -- Message
    local Paragraph = Section:AddParagraph({
        Title = "⚠ " .. Config.Title,
        Description = Config.Message,
        Text = Config.Details or ""
    })
    
    -- Buttons
    Section:AddButton({
        Title = "✅ Confirm",
        Description = "Confirm action",
        ButtonText = "YES",
        Callback = function()
            ConfirmWindow:Close()
            if Config.ConfirmCallback then
                self.SafeCallback(Config.ConfirmCallback)
            end
        end
    })
    
    Section:AddButton({
        Title = "❌ Cancel",
        Description = "Cancel action",
        ButtonText = "NO",
        Callback = function()
            ConfirmWindow:Close()
            if Config.CancelCallback then
                self.SafeCallback(Config.CancelCallback)
            end
        end
    })
    
    return ConfirmWindow
end
-- Set default theme
CyberGUI:SetTheme("Dark")

return CyberGUI
