-- Button Element - Clickable button

local Button = {}
Button.__index = Button
Button.__type = "Button"

local Creator = require(script.Parent.Parent.Creator)
local New = Creator.New
local BaseElement = require(script.Parent.Parent.Components.Element)

function Button:New(Config, Parent, Library)
    assert(Config.Title, "Button - Missing Title")
    
    local Theme = Library:GetCurrentThemeColors()
    
    -- Create base element
    local Base = BaseElement.CreateBase(Config, Parent, Library)
    
    -- Create button
    local Btn = New("TextButton", {
        Parent = Base.MainFrame,
        Text = Config.ButtonText or "Click",
        Size = UDim2.new(0, 100, 0, 28),
        Position = UDim2.new(1, -110, 0.5, -14),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.2,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        BorderColor3 = Theme.Accent,
        ZIndex = 2,
        AutoButtonColor = false
    })
    
    -- Glow effect on hover
    local Glow = New("Frame", {
        Parent = Btn,
        Size = UDim2.new(1, 20, 1, 10),
        Position = UDim2.new(-0.5, -10, -0.5, -5),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0
    })
    
    -- Hover effects
    Btn.MouseEnter:Connect(function()
        Btn.BackgroundTransparency = 0.1
        Glow.BackgroundTransparency = 0.7
    end)
    
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundTransparency = 0.2
        Glow.BackgroundTransparency = 1
    end)
    
    Btn.MouseButton1Down:Connect(function()
        Btn.BackgroundTransparency = 0.0
    end)
    
    Btn.MouseButton1Up:Connect(function()
        Btn.BackgroundTransparency = 0.1
    end)
    
    -- Click callback
    Btn.MouseButton1Click:Connect(function()
        if Config.Callback then
            Library.SafeCallback(Config.Callback)
        end
    end)
    
    -- Return button object
    return {
        Base = Base,
        Button = Btn,
        Glow = Glow,
        SetText = function(Text)
            Btn.Text = Text
        end,
        SetEnabled = function(Enabled)
            Btn.Active = Enabled
            Btn.TextTransparency = Enabled and 0 or 0.5
        end
    }
end

return Button
