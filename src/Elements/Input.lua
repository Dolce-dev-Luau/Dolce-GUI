-- Input Element - Text input field

local Input = {}
Input.__index = Input
Input.__type = "Input"

local Creator = require(script.Parent.Parent.Creator)
local New = Creator.New
local BaseElement = require(script.Parent.Parent.Components.Element)

function Input:New(Config, Parent, Library)
    assert(Config.Title, "Input - Missing Title")
    
    local Theme = Library:GetCurrentThemeColors()
    local Text = Config.Default or ""
    
    -- Create base element
    local Base = BaseElement.CreateBase(Config, Parent, Library)
    
    -- Input box
    local InputBox = New("TextBox", {
        Parent = Base.MainFrame,
        Text = Text,
        PlaceholderText = Config.Placeholder or "Type here...",
        Size = UDim2.new(0.4, -30, 0, 28),
        Position = UDim2.new(0.6, -10, 0.5, -14),
        BackgroundColor3 = Theme.BackgroundTertiary,
        BackgroundTransparency = 0.3,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0,
        ZIndex = 2,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })
    
    -- Focus effects
    InputBox.Focused:Connect(function()
        InputBox.BackgroundTransparency = 0.1
        InputBox.TextColor3 = Theme.Accent
    end)
    
    InputBox.FocusLost:Connect(function(EnterPressed)
        InputBox.BackgroundTransparency = 0.3
        InputBox.TextColor3 = Theme.Text
        
        if EnterPressed and Config.Callback then
            Library.SafeCallback(Config.Callback, InputBox.Text)
        end
    end)
    
    -- Return input object
    return {
        Base = Base,
        InputBox = InputBox,
        SetText = function(NewText)
            InputBox.Text = NewText
        end,
        GetText = function()
            return InputBox.Text
        end,
        SetPlaceholder = function(NewPlaceholder)
            InputBox.PlaceholderText = NewPlaceholder
        end,
        Clear = function()
            InputBox.Text = ""
        end
    }
end

return Input
