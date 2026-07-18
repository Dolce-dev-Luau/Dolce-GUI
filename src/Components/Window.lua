-- Window Component - Main window with title bar and tab system

local Components = {}

local Creator = require(script.Parent.Parent.Creator)
local Themes = require(script.Parent.Parent.Themes)
local New = Creator.New

function Components.Window(Config, ScreenGui, Library)
    local Theme = Library:GetCurrentThemeColors()
    
    -- Main frame
    local MainFrame = New("Frame", {
        Name = "CyberWindow",
        Parent = ScreenGui,
        Size = Config.Size or UDim2.new(0, 600, 0, 450),
        Position = Config.Position or UDim2.new(0.5, -300, 0.5, -225),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1
    })
    
    -- Neon border glow (top)
    local GlowTop = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    -- Neon border glow (bottom)
    local GlowBottom = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    -- Neon border glow (left)
    local GlowLeft = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    -- Neon border glow (right)
    local GlowRight = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(1, -2, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    -- Title bar
    local TitleBarHeight = 40
    local TitleBar = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, TitleBarHeight),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    -- Title
    local TitleLabel = New("TextLabel", {
        Parent = TitleBar,
        Text = Config.Title,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        ZIndex = 4
    })
    
    -- Subtitle
    if Config.SubTitle then
        local SubTitle = New("TextLabel", {
            Parent = TitleBar,
            Text = Config.SubTitle,
            TextColor3 = Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -100, 0, 20),
            Position = UDim2.new(0, 12, 0, 22),
            BackgroundTransparency = 1,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            ZIndex = 4
        })
    end
    
    -- Window controls
    local ControlSize = 24
    local ControlsPos = UDim2.new(1, -(ControlSize + 12), 0, 8)
    
    -- Close button
    local CloseBtn = New("TextButton", {
        Parent = TitleBar,
        Text = "✕",
        TextColor3 = Theme.TextSecondary,
        Size = UDim2.new(0, ControlSize, 0, ControlSize),
        Position = ControlsPos,
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 4
    })
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame:Destroy()
    end)
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.TextColor3 = Theme.Error
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.TextColor3 = Theme.TextSecondary
    end)
    
    -- Minimize button
    local MinBtn = New("TextButton", {
        Parent = TitleBar,
        Text = "─",
        TextColor3 = Theme.TextSecondary,
        Size = UDim2.new(0, ControlSize, 0, ControlSize),
        Position = UDim2.new(1, -((ControlSize + 12) * 2 + 4), 0, 8),
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 4
    })
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        -- Could add minimize animation
    end)
    
    -- Maximize button
    local MaxBtn = New("TextButton", {
        Parent = TitleBar,
        Text = "□",
        TextColor3 = Theme.TextSecondary,
        Size = UDim2.new(0, ControlSize, 0, ControlSize),
        Position = UDim2.new(1, -((ControlSize + 12) * 3 + 8), 0, 8),
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ZIndex = 4
    })
    local IsMaximized = false
    MaxBtn.MouseButton1Click:Connect(function()
        IsMaximized = not IsMaximized
        if IsMaximized then
            MainFrame.Size = UDim2.new(0, 800, 0, 600)
            MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
            MaxBtn.Text = "☐"
        else
            MainFrame.Size = Config.Size or UDim2.new(0, 600, 0, 450)
            MainFrame.Position = Config.Position or UDim2.new(0.5, -300, 0.5, -225)
            MaxBtn.Text = "□"
        end
    end)
    
    -- Drag functionality
    local Dragging = false
    local DragStart = nil
    local FrameStart = nil
    
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            FrameStart = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    TitleBar.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            local XScale = MainFrame.Position.X.Scale + Delta.X / ScreenGui.AbsoluteSize.X
            local YScale = MainFrame.Position.Y.Scale + Delta.Y / ScreenGui.AbsoluteSize.Y
            MainFrame.Position = UDim2.new(XScale, FrameStart.X.Offset + Delta.X, YScale, FrameStart.Y.Offset + Delta.Y)
        end
    end)
    
    -- Tab holder
    local TabHeight = 36
    local TabHolder = New("ScrollingFrame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 180, 1, -(TitleBarHeight + TabHeight + 4)),
        Position = UDim2.new(0, 0, 0, TitleBarHeight + TabHeight + 2),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        ZIndex = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    -- Tab buttons container
    local TabButtons = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 180, 0, TabHeight),
        Position = UDim2.new(0, 0, 0, TitleBarHeight),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    -- Content container
    local ContentContainer = New("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -184, 1, -(TitleBarHeight + TabHeight + 6)),
        Position = UDim2.new(0, 184, 0, TitleBarHeight + TabHeight + 2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
        ClipsDescendants = true
    })
    
    -- Return window object
    return {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        TabHolder = TabHolder,
        TabButtons = TabButtons,
        ContentContainer = ContentContainer,
        TabsHolder = {},
        CurrentTab = nil,
        GlowTop = GlowTop,
        GlowBottom = GlowBottom,
        GlowLeft = GlowLeft,
        GlowRight = GlowRight,
        Config = Config,
        ScreenGui = ScreenGui,
        Library = Library
    }
end

return Components.Window
