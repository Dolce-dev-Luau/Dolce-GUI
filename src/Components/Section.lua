-- Section Component - Groups elements in a tab

local Section = {}
Section.__index = Section

local Creator = require(script.Parent.Parent.Creator)
local New = Creator.New

function Section:New(Config, Tab, Library)
    assert(Config and Config.Title, "Section - Missing Title")
    
    local Theme = Library:GetCurrentThemeColors()
    
    -- Section container
    local SectionFrame = New("Frame", {
        Parent = Tab.Content,
        Name = "Section_" .. Config.Title,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    -- Section header with neon line
    local Header = New("Frame", {
        Parent = SectionFrame,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    -- Neon line
    local NeonLine = New("Frame", {
        Parent = Header,
        Size = UDim2.new(0, 40, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 3
    })
    
    -- Title
    local Title = New("TextLabel", {
        Parent = Header,
        Text = Config.Title,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        ZIndex = 2
    })
    
    -- Elements container
    local ElementsContainer = New("Frame", {
        Parent = SectionFrame,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    -- Store elements
    local Elements = {}
    
    -- Section object with methods
    local SectionObject = {
        Frame = SectionFrame,
        Header = Header,
        Title = Title,
        NeonLine = NeonLine,
        ElementsContainer = ElementsContainer,
        Elements = Elements,
        Config = Config
    }
    
    -- Method to add element
    function SectionObject:AddElement(ElementType, ElementConfig)
        local ElementModule = require(script.Parent.Parent.Elements)[ElementType]
        if not ElementModule then
            warn("[CyberGUI] Unknown element type:", ElementType)
            return nil
        end
        
        -- Create element
        local Element = ElementModule:New(ElementConfig, ElementsContainer, Library)
        
        -- Recalculate layout
        local TotalHeight = 0
        for _, child in ipairs(ElementsContainer:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Element" then
                TotalHeight = TotalHeight + child.Size.Y.Offset + 4
            end
        end
        ElementsContainer.Size = UDim2.new(1, 0, 0, TotalHeight)
        
        table.insert(Elements, Element)
        return Element
    end
    
    -- Auto-generate Add[Element] methods
    local ElementsList = require(script.Parent.Parent.Elements)
    for _, ElementModule in ipairs(ElementsList) do
        local Type = ElementModule.__type
        if Type then
            SectionObject["Add" .. Type] = function(self, Config)
                return self:AddElement(Type, Config)
            end
        end
    end
    
    return SectionObject
end

return Section
