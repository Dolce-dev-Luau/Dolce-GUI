-- Dropdown Element - Select from list of options

local Dropdown = {}
Dropdown.__index = Dropdown
Dropdown.__type = "Dropdown"

local Creator = require(script.Parent.Parent.Creator)
local New = Creator.New
local BaseElement = require(script.Parent.Parent.Components.Element)

function Dropdown:New(Config, Parent, Library)
    assert(Config.Title, "Dropdown - Missing Title")
    assert(Config.Values and #Config.Values > 0, "Dropdown - Missing Values")
    
    local Theme = Library:GetCurrentThemeColors()
    local SelectedIndex = Config.Default or 1
    local Expanded = false
    local Options = {}
    
    -- Create base element
    local Base = BaseElement.CreateBase(Config, Parent, Library)
    
    -- Main button
    local DropdownBtn = New("TextButton", {
        Parent = Base.MainFrame,
        Text = Config.Values[SelectedIndex] or "",
        Size = UDim2.new(0.4, -30, 0, 28),
        Position = UDim2.new(0.6, -10, 0.5, -14),
        BackgroundColor3 = Theme.BackgroundTertiary,
        BackgroundTransparency = 0.3,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0,
        ZIndex = 2,
        AutoButtonColor = false,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Arrow
    local Arrow = New("TextLabel", {
        Parent = DropdownBtn,
        Text = "▼",
        TextColor3 = Theme.TextSecondary,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -25, 0, 0),
        BackgroundTransparency = 1,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 3
    })
    
    -- Dropdown list (initially hidden)
    local DropdownList = New("ScrollingFrame", {
        Parent = Base.MainFrame,
        Size = UDim2.new(0.4, -10, 0, 0),
        Position = UDim2.new(0.6, -10, 1, 2),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 5,
        ClipsDescendants = true,
        Visible = false,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    -- Create option buttons
    local function CreateOptions()
        -- Clear existing options
        for _, child in ipairs(DropdownList:GetChildren()) do
            child:Destroy()
        end
        
        local CanvasSize = 0
        
        for i, Value in ipairs(Config.Values) do
            local OptionBtn = New("TextButton", {
                Parent = DropdownList,
                Text = Value,
                TextColor3 = (i == SelectedIndex) and Theme.Accent or Theme.Text,
                Size = UDim2.new(1, -4, 0, 30),
                Position = UDim2.new(0, 2, 0, CanvasSize),
                BackgroundColor3 = (i == SelectedIndex) and Theme.Hover or Theme.Background,
                BackgroundTransparency = (i == SelectedIndex) and 0.3 or 0.5,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex = 6,
                AutoButtonColor = false
            })
            
            OptionBtn.MouseButton1Click:Connect(function()
                SelectedIndex = i
                DropdownBtn.Text = Value
                Arrow.Text = "▼"
                Expanded = false
                DropdownList.Visible = false
                
                if Config.Callback then
                    Library.SafeCallback(Config.Callback, Value, i)
                end
                
                CreateOptions() -- Refresh options to update selected state
            end)
            
            OptionBtn.MouseEnter:Connect(function()
                OptionBtn.BackgroundTransparency = 0.2
            end)
            
            OptionBtn.MouseLeave:Connect(function()
                OptionBtn.BackgroundTransparency = (i == SelectedIndex) and 0.3 or 0.5
            end)
            
            CanvasSize = CanvasSize + 30
        end
        
        -- Update canvas size
        DropdownList.CanvasSize = UDim2.new(0, 0, 0, CanvasSize + 4)
        DropdownList.Size = UDim2.new(0.4, -10, 0, math.min(CanvasSize + 4, 120))
    end
    
    -- Toggle dropdown
    DropdownBtn.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        DropdownList.Visible = Expanded
        Arrow.Text = Expanded and "▲" or "▼"
        
        if Expanded then
            CreateOptions()
        end
    end)
    
    -- Close dropdown on click outside
    local function CloseDropdown()
        if Expanded then
            Expanded = false
            DropdownList.Visible = false
            Arrow.Text = "▼"
        end
    end
    
    -- Click outside to close
    Library:GetCurrentThemeColors() -- Just a placeholder, we'll use a different method
    
    -- Return dropdown object
    return {
        Base = Base,
        Button = DropdownBtn,
        List = DropdownList,
        Options = Options,
        SelectedIndex = SelectedIndex,
        SetSelected = function(Index)
            if Config.Values[Index] then
                SelectedIndex = Index
                DropdownBtn.Text = Config.Values[Index]
                if Config.Callback then
                    Library.SafeCallback(Config.Callback, Config.Values[Index], Index)
                end
                CreateOptions()
            end
        end,
        GetSelected = function() return Config.Values[SelectedIndex] end,
        GetSelectedIndex = function() return SelectedIndex end,
        AddOption = function(Value)
            table.insert(Config.Values, Value)
            if Expanded then
                CreateOptions()
            end
        end
    }
end

return Dropdown
