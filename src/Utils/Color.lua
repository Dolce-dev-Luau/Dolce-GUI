-- Color Utilities - Helper functions for color manipulation

local Color = {}

-- Convert RGB to Hex
function Color.RGBToHex(R, G, B)
    return string.format("#%02X%02X%02X", R * 255, G * 255, B * 255)
end

-- Convert Hex to RGB (returns 0-1 values)
function Color.HexToRGB(Hex)
    Hex = Hex:gsub("#", "")
    local R = tonumber(Hex:sub(1, 2), 16) / 255
    local G = tonumber(Hex:sub(3, 4), 16) / 255
    local B = tonumber(Hex:sub(5, 6), 16) / 255
    return Color3.new(R, G, B)
end

-- Blend two colors
function Color.Blend(Color1, Color2, Alpha)
    Alpha = math.clamp(Alpha, 0, 1)
    return Color3.new(
        Color1.R + (Color2.R - Color1.R) * Alpha,
        Color1.G + (Color2.G - Color1.G) * Alpha,
        Color1.B + (Color2.B - Color1.B) * Alpha
    )
end

-- Darken a color
function Color.Darken(Color, Amount)
    Amount = math.clamp(Amount, 0, 1)
    return Color3.new(
        Color.R * (1 - Amount),
        Color.G * (1 - Amount),
        Color.B * (1 - Amount)
    )
end

-- Lighten a color
function Color.Lighten(Color, Amount)
    Amount = math.clamp(Amount, 0, 1)
    return Color3.new(
        Color.R + (1 - Color.R) * Amount,
        Color.G + (1 - Color.G) * Amount,
        Color.B + (1 - Color.B) * Amount
    )
end

-- Get complementary color
function Color.Complementary(Color)
    return Color3.new(1 - Color.R, 1 - Color.G, 1 - Color.B)
end

-- Check if color is dark (for text contrast)
function Color.IsDark(Color)
    local Brightness = 0.299 * Color.R + 0.587 * Color.G + 0.114 * Color.B
    return Brightness < 0.5
end

-- Get contrasting text color (black or white)
function Color.GetContrastColor(Color)
    return Color.IsDark(Color) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
end

-- Create a gradient between two colors
function Color.CreateGradient(Color1, Color2, Steps)
    local Gradient = {}
    for i = 0, Steps do
        local Alpha = i / Steps
        table.insert(Gradient, Color.Blend(Color1, Color2, Alpha))
    end
    return Gradient
end

return Color
