-- Save the global print function for later
local _print = print
local g_Vector = {}
g_Vector.__index = g_Vector

function g_Vector.new(x, y, z)
    local szType = type(x)

    -- Most likely csgo.vector 3
    if szType == "userdata" then
        -- Check if there is a x, y, and z member variable
        local pVector = x
        if not pVector.x or not pVector.y or not pVector.z then
            return nil, error("Invalid parameter in vector.new with type (userdata)", 2)
        end
        return setmetatable({x = pVector.x, y = pVector.y, z = pVector.z}, g_Vector)
    -- Check if we are using either an already created vector object or a table with x, y, z / [1], [2], [3]
    elseif szType == "table" then
        local pTable = x
        if pTable.x and pTable.y and pTable.y then
            return setmetatable({x = pTable.x, y = pTable.y, z = pTable.z}, g_Vector)
        elseif pTable[1] and pTable[2] and pTable[3] then
            return setmetatable({x = pTable[1], y = pTable[2], z = pTable[3]}, g_Vector)
        end
        return nil, error("Invalid parameter in vector.new with type (table)", 2)
    -- Using the default creation 
    elseif szType == "number" then
        return setmetatable({x = x or 0, y = y or 0, z = z or 0}, g_Vector)
    end
    -- Return a table initalized to 0
    return setmetatable({x = 0, y = 0, z = 0}, g_Vector)
end

-- Alot of this shit is repetative
function g_Vector.__add(First, Second)
    local szType1, szType2 = type(First), type(Second)

    -- Check if there is even anything to add
    if szType1 == "nil" or szType2 == "nil" then
        return nil, error("Nil parameter(s) vector.__add (+)", 2)
    end

    if szType1 == "number" then
        return g_Vector.new(First + Second.x, First + Second.y, First + Second.z)
    elseif szType2 == "number" then
        return g_Vector.new(First.x + Second, First.y + Second, First.z + Second)
    end

    if not g_Vector:valid(First) then
        return nil, error("Invalid parameter #1 vector.__add (+)", 2)
    elseif not g_Vector:valid(Second) then
        return nil, error("Invalid parameter #2 vector.__add (+)", 2)
    end

    return g_Vector.new(First.x + Second.x, First.y + Second.y, First.z + Second.z)
end

function g_Vector.__sub(First, Second)
    local szType1, szType2 = type(First), type(Second)

    -- Check if there is even anything to subtract
    if szType1 == "nil" or szType2 == "nil" then
        return nil, error("Nil parameter(s) vector.__sub (-)", 2)
    end

    if szType1 == "number" then
        return g_Vector.new(First - Second.x, First - Second.y, First - Second.z)
    elseif szType2 == "number" then
        return g_Vector.new(First.x - Second, First.y - Second, First.z - Second)
    end

    if not g_Vector:valid(First) then
        return nil, error("Invalid parameter #1 vector.__sub (-)", 2)
    elseif not g_Vector:valid(Second) then
        return nil, error("Invalid parameter #2 vector.__sub (-)", 2)
    end

    return g_Vector.new(First.x - Second.x, First.y - Second.y, First.z - Second.z)
end

function g_Vector.__mul(First, Second)
    local szType1, szType2 = type(First), type(Second)

    -- Check if there is even anything to multiply
    if szType1 == "nil" or szType2 == "nil" then
        return nil, error("Nil parameter(s) vector.__mul (*)", 2)
    end

    if szType1 == "number" then
        return g_Vector.new(First * Second.x, First * Second.y, First * Second.z)
    elseif szType2 == "number" then
        return g_Vector.new(First.x * Second, First.y * Second, First.z * Second)
    end

    if not g_Vector:valid(First) then
        return nil, error("Invalid parameter #1 vector.__mul (*)", 2)
    elseif not g_Vector:valid(Second) then
        return nil, error("Invalid parameter #2 vector.__mul (*)", 2)
    end

    return g_Vector.new(First.x * Second.x, First.y * Second.y, First.z * Second.z)
end

function g_Vector.__div(First, Second)
    local szType1, szType2 = type(First), type(Second)

    -- Check if there is even anything to divide
    if szType1 == "nil" or szType2 == "nil" then
        return nil, error("Nil parameter(s) vector.__div (/)", 2)
    end

    if szType1 == "number" then
        return g_Vector.new(First / Second.x, First / Second.y, First / Second.z)
    elseif szType2 == "number" then
        return g_Vector.new(First.x / Second, First.y / Second, First.z / Second)
    end

    if not g_Vector:valid(First) then
        return nil, error("Invalid parameter #1 vector.__div (/)", 2)
    elseif not g_Vector:valid(Second) then
        return nil, error("Invalid parameter #2 vector.__div (/)", 2)
    end

    return g_Vector.new(First.x / Second.x, First.y / Second.y, First.z / Second.z)
end

function g_Vector.__pow(First, Second)
    local szType1, szType2 = type(First), type(Second)

    -- Check if there is even anything to raise to power
    if szType1 == "nil" or szType2 == "nil" then
        return nil, error("Nil parameter(s) vector.__pow (^)", 2)
    end

    if szType1 == "number" then
        return g_Vector.new(First ^ Second.x, First ^ Second.y, First ^ Second.z)
    elseif szType2 == "number" then
        return g_Vector.new(First.x ^ Second, First.y ^ Second, First.z ^ Second)
    end

    if not g_Vector:valid(First) then
        return nil, error("Invalid parameter #1 vector.__pow (^)", 2)
    elseif not g_Vector:valid(Second) then
        return nil, error("Invalid parameter #2 vector.__pow (^)", 2)
    end

    return g_Vector.new(First.x ^ Second.x, First.y ^ Second.y, First.z ^ Second.z)
end

function g_Vector.__mod(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return nil, error("Nil parameter(s) vector.__mod (%)", 2)
    end

    if szType1 == "number" then
        return g_Vector.new(First % Second.x, First % Second.y, First % Second.z)
    elseif szType2 == "number" then
        return g_Vector.new(First.x % Second, First.y % Second, First.z % Second)
    end

    if not g_Vector:valid(First) then
        return nil, error("Invalid parameter #1 vector.__mod (%)", 2)
    elseif not g_Vector:valid(Second) then
        return nil, error("Invalid parameter #2 vector.__mod (%)", 2)
    end

    return g_Vector.new(First.x % Second.x, First.y % Second.y, First.z % Second.z)
end

function g_Vector.__eq(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameter(s) vector.__eq (==)", 2)
    end

    if szType1 == "number" then
        return First == Second.x and First == Second.y and First == Second.z
    elseif szType2 == "number" then
        return First.x == Second and First.y == Second and First.z == Second
    end

    if not g_Vector:valid(First) then
        return false, error("Invalid parameter #1 vector.__eq (==)", 2)
    elseif not g_Vector:valid(Second) then
        return false, error("Invalid parameter #2 vector.__eq (==)", 2)
    end

    return First.x == Second.x and First.y == Second.y and First.z == Second.z
end

function g_Vector.__lt(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameter(s) vector.__lt (<)", 2)
    end

    if szType1 == "number" then
        return First < Second:length()
    elseif szType2 == "number" then
        return First:length() < Second
    end

    if not g_Vector:valid(First) then
        return false, error("Invalid parameter #1 vector.__lt (<)", 2)
    elseif not g_Vector:valid(Second) then
        return false, error("Invalid parameter #2 vector.__lt (<)", 2)
    end

    return First:length() < Second:length()
end

function g_Vector.__gt(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameter(s) vector.__gt (>)", 2)
    end

    if szType1 == "number" then
        return First > Second:length()
    elseif szType2 == "number" then
        return First:length() > Second
    end

    if not g_Vector:valid(First) then
        return false, error("Invalid parameter #1 vector.__gt (>)", 2)
    elseif not g_Vector:valid(Second) then
        return false, error("Invalid parameter #2 vector.__gt (>)", 2)
    end

    return First:length() > Second:length()
end

function g_Vector.__le(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameter(s) vector.__le (<=)", 2)
    end

    if szType1 == "number" then
        return First <= Second:length()
    elseif szType2 == "number" then
        return First:length() <= Second
    end

    if not g_Vector:valid(First) then
        return false, error("Invalid parameter #1 vector.__le (<=)", 2)
    elseif not g_Vector:valid(Second) then
        return false, error("Invalid parameter #2 vector.__le (<=)", 2)
    end

    return First:length() <= Second:length()
end

function g_Vector.__ge(First, Second)
    local szType1, szType2 = type(First), type(Second)

    if szType1 == "nil" or szType2 == "nil" then
        return false, error("Nil parameter(s) vector.__ge (>=)", 2)
    end

    if szType1 == "number" then
        return First >= Second:length()
    elseif szType2 == "number" then
        return First:length() >= Second
    end

    if not g_Vector:valid(First) then
        return false, error("Invalid parameter #1 vector.__ge (>=)", 2)
    elseif not g_Vector:valid(Second) then
        return false, error("Invalid parameter #2 vector.__ge (>=)", 2)
    end

    return First:length() >= Second:length()
end

function g_Vector:coppied()
    return g_Vector.new(self.x, self.y, self.z)
end

function g_Vector:csgo()
    return csgo.vector3(self.x, self.y, self.z)
end

function g_Vector:valid(External)
    -- We are trying to use this as a non member function
    if External then
        return External and External.x ~= nil and External.y ~= nil and External.z ~= nil
    else
        return self and self.x ~= nil and self.y ~= nil and self.z ~= nil
    end
end

function g_Vector:to(Other)
    if not g_Vector:valid(Other) then
        return 0, error("Invalid parameter #1 vector:to")
    end

    return Other - self
end

function g_Vector:scale(flScale)
    if flScale == nil then
        return nil, error("Invalid parameter #1 vector:scale")
    end
    self.x = self.x * flScale
    self.y = self.y * flScale
    self.z = self.z * flScale
end

function g_Vector:scaled(flScale)
    if flScale == nil then
        return nil, error("Invalid parameter #1 vector:scaled")
    end

    return self:coppied() * flScale
end

function g_Vector:unpack()
    return self.x, self.y, self.z
end

function g_Vector:length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function g_Vector:lengthsqr()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function g_Vector:length2D()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function g_Vector:length2Dsqr()
    return self.x * self.x + self.y * self.y
end

function g_Vector:normalize()
    local fllength = self:length()
    self.x = self.x / fllength
    self.y = self.y / fllength
    self.z = self.z / fllength
end

function g_Vector:normalized()
    local Ret = self:coppied()
    Ret:normalize()
    return Ret
end

function g_Vector:dot(Other)
    if not g_Vector:valid(Other) then
        return 0, error("Invalid parameter #1 vector:dot")
    end

    return ((self.x * Other.x) + (self.y * Other.y) + (self.z * Other.z))
end

function g_Vector:dist(Other)
    if not g_Vector:valid(Other) then
        return 0, error("Invalid parameter #1 vector:dist")
    end

    return (Other - self):length()
end

function g_Vector:dist2D(Other)
    if not g_Vector:valid(Other) then
        return 0, error("Invalid parameter #1 vector:dist2D")
    end

    return (Other - self):length2D()
end

function g_Vector:reset(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

-- Format the print function to work with our pretty vectors
print = function(...)
    local aParams = {...}

    local szPrintStr = ""
    for iKey, Value in pairs(aParams) do
        if type(Value) == "table" and Value.x and Value.y and Value.z then
            szPrintStr = szPrintStr .. string.format("(%0.3f, %0.3f, %0.3f)", Value.x, Value.y, Value.z)
        else
            szPrintStr = szPrintStr .. tostring(Value)
        end
    end
    _print(szPrintStr)
end
setmetatable(g_Vector, { __call = function(Table, ...) return g_Vector.new(...) end })
return g_Vector
