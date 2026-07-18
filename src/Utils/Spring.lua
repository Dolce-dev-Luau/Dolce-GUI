-- Spring Animation - Physics-based spring system
-- Based on Flipper library concept

local Spring = {}

local RunService = game:GetService("RunService")

-- Spring class
local SpringClass = {}
SpringClass.__index = SpringClass

function SpringClass:New(Value, Properties)
    Properties = Properties or {}
    
    local self = setmetatable({
        _Value = Value or 0,
        _Target = Value or 0,
        _Velocity = 0,
        _Stiffness = Properties.Stiffness or 180,
        _Damping = Properties.Damping or 15,
        _Mass = Properties.Mass or 1,
        _Threshold = Properties.Threshold or 0.001,
        _Connected = false,
        _Callbacks = {}
    }, SpringClass)
    
    return self
end

function SpringClass:SetTarget(Target)
    self._Target = Target
    if not self._Connected then
        self:_Connect()
    end
end

function SpringClass:SetValue(Value)
    self._Value = Value
    self._Target = Value
    self._Velocity = 0
end

function SpringClass:GetValue()
    return self._Value
end

function SpringClass:OnUpdate(Callback)
    if type(Callback) == "function" then
        table.insert(self._Callbacks, Callback)
    end
end

function SpringClass:_Connect()
    if self._Connected then return end
    self._Connected = true
    
    local Connection
    Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        if not self._Connected then
            Connection:Disconnect()
            return
        end
        
        -- Spring physics
        local Stiffness = self._Stiffness
        local Damping = self._Damping
        local Mass = self._Mass
        
        local Force = -Stiffness * (self._Value - self._Target)
        local DampingForce = -Damping * self._Velocity
        local Acceleration = (Force + DampingForce) / Mass
        
        self._Velocity = self._Velocity + Acceleration * DeltaTime
        self._Value = self._Value + self._Velocity * DeltaTime
        
        -- Check if settled
        if math.abs(self._Velocity) < self._Threshold and math.abs(self._Value - self._Target) < self._Threshold then
            self._Value = self._Target
            self._Velocity = 0
            self._Connected = false
            Connection:Disconnect()
        end
        
        -- Call callbacks
        for _, Callback in ipairs(self._Callbacks) do
            pcall(Callback, self._Value)
        end
    end)
end

function SpringClass:Destroy()
    self._Connected = false
    self._Callbacks = {}
end

-- Create a spring motor for UI elements
function Spring.CreateMotor(StartValue, Instance, Property, Properties)
    Properties = Properties or {}
    
    local Spring = SpringClass:New(StartValue, Properties)
    
    Spring:OnUpdate(function(Value)
        pcall(function()
            Instance[Property] = Value
        end)
    end)
    
    return Spring
end

-- Easing functions
function Spring.EaseInOut(Value, Duration, Callback)
    local Start = tick()
    local Connection
    
    Connection = RunService.Heartbeat:Connect(function()
        local Elapsed = tick() - Start
        local Progress = math.min(Elapsed / Duration, 1)
        
        -- Smoothstep
        local Smooth = Progress * Progress * (3 - 2 * Progress)
        
        if Callback then
            Callback(Smooth)
        end
        
        if Progress >= 1 then
            Connection:Disconnect()
        end
    end)
    
    return Connection
end

return Spring
