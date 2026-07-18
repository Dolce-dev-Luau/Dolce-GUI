-- Creator - Handles instance creation and theme management

local Creator = {}
Creator.__index = Creator

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local CurrentTheme = nil
local ThemeInstances = {} -- Track instances with ThemeTag for updates

-- Default properties for instances
local DefaultProperties = {
    Frame = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    },
    ImageLabel = {
        BackgroundTransparency = 1
    },
    TextLabel = {
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.new(1, 1, 1)
    },
    TextButton = {
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false
    },
    TextBox = {
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.new(1, 1, 1)
    },
    ScrollingFrame = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(255, 45, 93),
        ScrollBarImageTransparency = 0.5,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    }
}

-- Create instance with default properties
function Creator.New(ClassName, Properties, Children)
    Properties = Properties or {}
    Children = Children or {}
    
    -- Get default props for class
    local Defaults = DefaultProperties[ClassName] or {}
    
    -- Merge defaults with provided properties
    local FinalProperties = {}
    for Key, Value in pairs(Defaults) do
        FinalProperties[Key] = Value
    end
    for Key, Value in pairs(Properties) do
        FinalProperties[Key] = Value
    end
    
    -- Create instance
    local Instance = Instance.new(ClassName)
    
    -- Apply properties
    for Key, Value in pairs(FinalProperties) do
        if Key == "ThemeTag" then
            -- Handle theme tagging
            local Tag = Value
            if type(Tag) == "table" then
                Instance._ThemeTag = Tag
                table.insert(ThemeInstances, Instance)
                -- Apply current theme colors
                if CurrentTheme then
                    Creator.ApplyThemeToInstance(Instance, CurrentTheme)
                end
            end
        else
            pcall(function()
                Instance[Key] = Value
            end)
        end
    end
    
    -- Set parent
    if Properties.Parent then
        Instance.Parent = Properties.Parent
    end
    
    -- Add children
    for _, Child in ipairs(Children) do
        Child.Parent = Instance
    end
    
    return Instance
end

-- Apply theme colors to an instance
function Creator.ApplyThemeToInstance(Instance, Theme)
    local Tag = Instance._ThemeTag
    if not Tag then return end
    
    for Property, ThemeKey in pairs(Tag) do
        local Color = Theme[ThemeKey]
        if Color then
            pcall(function()
                Instance[Property] = Color
            end)
        end
    end
end

-- Update all theme instances
function Creator.UpdateTheme(Theme)
    CurrentTheme = Theme
    for _, Instance in ipairs(ThemeInstances) do
        if Instance and Instance.Parent then
            Creator.ApplyThemeToInstance(Instance, Theme)
        end
    end
end

-- Spring motor for smooth animations
function Creator.SpringMotor(Value, Target, Property)
    local CurrentValue = Value or 1
    local TargetValue = Target or 1
    local PropertyName = Property or "Size"
    
    return {
        SetTarget = function(NewTarget)
            TargetValue = NewTarget
        end,
        Step = function(Instance, DeltaTime)
            CurrentValue = CurrentValue + (TargetValue - CurrentValue) * 0.1
            pcall(function()
                Instance[PropertyName] = CurrentValue
            end)
        end,
        GetValue = function()
            return CurrentValue
        end
    }
end

-- Signal connection helper
function Creator.AddSignal(Signal, Callback)
    if not Signal then return end
    local Connection = Signal:Connect(Callback)
    return Connection
end

-- Destroy helper
function Creator.Destroy(Instance)
    if Instance then
        Instance:Destroy()
    end
end

return Creator
