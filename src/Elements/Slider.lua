-- Slider Element - Value slider with number input

local Slider = {}
Slider.__index = Slider
Slider.__type = "Slider"

local Creator = require(script.Parent.Parent.Creator)
local New = Creator.New
local BaseElement = require(script.Parent.Parent.Components.Element)

function Slider:New(Config, Parent, Library)
    assert(Config.Title, "Slider - Missing Title")
    assert(Config.Min ~= nil and Config.Max ~= nil, "Slider - Missing Min/Max values")
    
    local Theme = Library:GetCurrentThemeColors()
    local Value = Config.Default or Config.Min
    local Min = Config.Min
    local Max = Config.Max
    
    -- Create base element
    local Base = BaseElement.CreateBase(Config, Parent, Library)
    
    -- Value display
    local ValueLabel = New("TextLabel", {
        Parent = Base.MainFrame,
        Text = tostring(Value),
        TextColor3 = Theme.Accent,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0, 4),
        BackgroundTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 2
    })
    
    -- Slider track
    local Track = New("Frame", {
        Parent = Base.MainFrame,
        Size = UDim2.new(0.7, -80, 0, 4),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundColor3 = Theme.BackgroundTertiary,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    -- Slider fill
    local Fill = New("Frame", {
        Parent = Track,
        Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    -- Slider knob
    local Knob = New("Frame", {
        Parent = Track,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((Value - Min) / (Max - Min), -7, 0.5, -7),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 4
    })
    
    -- Knob glow
    local KnobGlow = New("Frame", {
        Parent = Knob,
        Size = UDim2.new(2, 0, 2, 0),
        Position = UDim2.new(-0.5, 0, -0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0
    })
    
    -- Update slider value
    local function UpdateValue(NewValue)
        Value = math.clamp(NewValue, Min, Max)
        local Percent = (Value - Min) / (Max - Min)
        
        -- Update UI
        Fill.Size = UDim2.new(Percent, 0, 1, 0)
        Knob.Position = UDim2.new(Percent, -7, 0.5, -7)
        ValueLabel.Text = Config.Decimals and string.format("%." .. Config.Decimals .. "f", Value) or tostring(math.floor(Value))
        
        -- Call callback
        if Config.Callback then
            Library.SafeCallback(Config.Callback, Value)
        end
    end
    
    -- Mouse drag on track
    local Dragging = false
    
    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            local X = Input.Position.X - Track.AbsolutePosition.X
            local Percent = math.clamp(X / Track.AbsoluteSize.X, 0, 1)
            UpdateValue(Min + Percent * (Max - Min))
        end
    end)
    
    Track.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local X = Input.Position.X - Track.AbsolutePosition.X
            local Percent = math.clamp(X / Track.AbsoluteSize.X, 0, 1)
            UpdateValue(Min + Percent * (Max - Min))
        end
    end)
    
    Track.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    -- Knob hover effects
    Knob.MouseEnter:Connect(function()
        Knob.BackgroundTransparency = 0.1
        KnobGlow.BackgroundTransparency = 0.5
    end)
    
    Knob.MouseLeave:Connect(function()
        Knob.BackgroundTransparency = 0.3
        KnobGlow.BackgroundTransparency = 1
    end)
    
    -- Return slider object
    return {
        Base = Base,
        Track = Track,
        Fill = Fill,
        Knob = Knob,
        ValueLabel = ValueLabel,
        SetValue = UpdateValue,
        GetValue = function() return Value end,
        SetRange = function(NewMin, NewMax)
            Min = NewMin
            Max = NewMax
            UpdateValue(Value)
        end
    }
end

return Slider
