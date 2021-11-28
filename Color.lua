local _floor, _print = math.floor, print
local g_Color = {}
g_Color.__index = g_Color

local function Clamp(v, mn, mx)
    return v < mn and mn or v > mx and mx or v
end

function g_Color.new(r, g, b, a)
    local szType = type(r)
    if szType == "table" then
        local pTable = r
        if pTable.r and pTable.g and pTable.b and pTable.a then
            return setmetatable({r = pTable.r, g = pTable.g, b = pTable.b, a = pTable.a}, g_Color)
        elseif pTable[1] and pTable[2] and pTable[3] and pTable[4] then
            return setmetatable({r = pTable[1], g = pTable[2], b = pTable[3], a = pTable[4]}, g_Color)
        end
        return nil, error("Invalid parameter in color.new with type (table)", 2)
    -- Using the default creation 
    elseif szType == "number" then
        return setmetatable({r = r or 255, g = g or 255, b = b or 255, a = a or 255}, g_Color)
    end
    -- If no arguments are passed
    return setmetatable({r = 255, g = 255, b = 255, a = 255}, g_Color)
end

function g_Color.__add(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__add (+)")
    end

    if szType1 == "number" then
        return g_Color.new(First + Second.r, First + Second.g, First + Second.b, First + Second.a)
    elseif szType2 == "number" then
        return g_Color.new(First.r + Second, First.g + Second, First.b + Second, First.a + Second)
    end

    if not g_Color:valid(First) then
        return nil, error("Invalid parameter #1 color.__add (+)", 2)
    elseif not g_Color:valid(Second) then
        return nil, error("Invalid parameter #2 color.__add (+)", 2)
    end

    return g_Color.new(First.r + Second.r, First.g + Second.g, First.b + Second.b, First.a + Second.a)
end

function g_Color.__sub(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__sub (-)")
    end

    if szType1 == "number" then
        return g_Color.new(First - Second.r, First - Second.g, First - Second.b, First - Second.a)
    elseif szType2 == "number" then
        return g_Color.new(First.r - Second, First.g - Second, First.b - Second, First.a - Second)
    end

    if not g_Color:valid(First) then
        return nil, error("Invalid parameter #1 color.__sub (-)", 2)
    elseif not g_Color:valid(Second) then
        return nil, error("Invalid parameter #2 color.__sub (-)", 2)
    end

    return g_Color.new(First.r - Second.r, First.g - Second.g, First.b - Second.b, First.a - Second.a)
end

function g_Color.__mul(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__mul (*)")
    end

    if szType1 == "number" then
        return g_Color.new(First * Second.r, First * Second.g, First * Second.b, First * Second.a)
    elseif szType2 == "number" then
        return g_Color.new(First.r * Second, First.g * Second, First.b * Second, First.a * Second)
    end

    if not g_Color:valid(First) then
        return nil, error("Invalid parameter #1 color.__mul (*)", 2)
    elseif not g_Color:valid(Second) then
        return nil, error("Invalid parameter #2 color.__mul (*)", 2)
    end

    return g_Color.new(First.r * Second.r, First.g * Second.g, First.b * Second.b, First.a * Second.a)
end

function g_Color.__div(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__div (/)")
    end

    if szType1 == "number" then
        return g_Color.new(First / Second.r, First / Second.g, First / Second.b, First / Second.a)
    elseif szType2 == "number" then
        return g_Color.new(First.r / Second, First.g / Second, First.b / Second, First.a / Second)
    end

    if not g_Color:valid(First) then
        return nil, error("Invalid parameter #1 color.__div (/)", 2)
    elseif not g_Color:valid(Second) then
        return nil, error("Invalid parameter #2 color.__div (/)", 2)
    end

    return g_Color.new(First.r / Second.r, First.g / Second.g, First.b / Second.b, First.a / Second.a)
end

function g_Color.__pow(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__pow (^)")
    end

    if szType1 == "number" then
        return g_Color.new(First ^ Second.r, First ^ Second.g, First ^ Second.b, First ^ Second.a)
    elseif szType2 == "number" then
        return g_Color.new(First.r ^ Second, First.g ^ Second, First.b ^ Second, First.a ^ Second)
    end

    if not g_Color:valid(First) then
        return nil, error("Invalid parameter #1 color.__pow (^)", 2)
    elseif not g_Color:valid(Second) then
        return nil, error("Invalid parameter #2 color.__pow (^)", 2)
    end

    return g_Color.new(First.r ^ Second.r, First.g ^ Second.g, First.b ^ Second.b, First.a ^ Second.a)
end

function g_Color.__mod(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__mod (%)")
    end

    if szType1 == "number" then
        return g_Color.new(First % Second.r, First % Second.g, First % Second.b, First % Second.a)
    elseif szType2 == "number" then
        return g_Color.new(First.r % Second, First.g % Second, First.b % Second, First.a % Second)
    end

    if not g_Color:valid(First) then
        return nil, error("Invalid parameter #1 color.__mod (%)", 2)
    elseif not g_Color:valid(Second) then
        return nil, error("Invalid parameter #2 color.__mod (%)", 2)
    end

    return g_Color.new(First.r % Second.r, First.g % Second.g, First.b % Second.b, First.a % Second.a)
end

function g_Color.__eq(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameters color.__eq (==)")
    end

    if szType1 == "number" then
        return First == Second.r and First == Second.g and First == Second.b and First == Second.a
    elseif szType2 == "number" then
        return First.r == Second and First.g == Second and First.b == Second and First.a == Second
    end

    if not g_Color:valid(First) then
        return false, error("Invalid parameter #1 color.__eq (==)", 2)
    elseif not g_Color:valid(Second) then
        return false, error("Invalid parameter #2 color.__eq (==)", 2)
    end

    return First.r == Second.r and First.g == Second.g and First.b == Second.b and First.a == Second.a
end

function g_Color.__lt()
    return false, error("Cannot compare colors with (<)")
end

function g_Color.__gt()
    return false, error("Cannot compare colors with (>)")
end

function g_Color.__le()
    return false, error("Cannot compare colors with (<=)")
end

function g_Color.__ge()
    return false, error("Cannot compare colors with (>=)")
end

function g_Color:copied()
    return g_Color.new(self.r, self.g, self.b, self.a)
end

function g_Color:csgo()
    return csgo.color(_floor(Clamp(self.r, 0, 255) + 0.5), _floor(Clamp(self.b, 0, 255) + 0.5), _floor(Clamp(self.g, 0, 255) + 0.5), _floor(Clamp(self.a, 0, 255) + 0.5))
end

function g_Color:scale(flScale)
    if flScale == nil then
        return nil, error("Invalid parameter #1 color:scale")
    end
    self.r = self.r * flScale
    self.g = self.g * flScale
    self.b = self.b * flScale
    self.a = self.a * flScale
end

function g_Color:scaled(flScale)
    if flScale == nil then
        return nil, error("Invalid parameter #1 color:scaled")
    end

    return self:copied() * flScale
end

function g_Color:unpack()
    return self.r, self.g, self.b, self.a
end

function g_Color:reset(r, g, b, a)
    self.r = r or 255
    self.g = g or 255
    self.b = b or 255
    self.a = a or 255
end

function g_Color:fade(other, percentage)
    if not g_Color:valid(other) then
        return nil, error("Invalid parameter #1 color:fade")
    end

    if percentage == nil then
        return nil, error("Invalid parameter #2 color:fade")
    end
    return other + ((self - other) * percentage)
end

function g_Color:valid(External)
    -- We are trying to use this as a non member function
    if External then
        return type(External) == "table" and External.r ~= nil and External.g ~= nil and External.b ~= nil and External.a ~= nil
    else
        return type(self) == "table" and self.r ~= nil and self.g ~= nil and self.b ~= nil and self.a ~= nil
    end
end

print = function(...)
    local aParams = {...}

    local szPrintStr = ""
    for iKey, Value in pairs(aParams) do
        if type(Value) == "table" and Value.r and Value.g and Value.b and Value.a then
            szPrintStr = szPrintStr .. string.format("(%0.0f, %0.0f, %0.0f, %0.0f)", Value.r, Value.g, Value.b, Value.a)
        else
            szPrintStr = szPrintStr .. tostring(Value)
        end
    end
    _print(szPrintStr)
end
setmetatable(g_Color, { __call = function(Table, ...) return g_Color.new(...) end })
return g_Color
