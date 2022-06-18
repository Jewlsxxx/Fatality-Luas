local function GetIndexLevel(Level)
    local Ret = ""
    for i = 0, Level do
        Ret = Ret .. "    "
    end
    return Ret
end

local function PrintTable(Tbl, TblName, Level)
    local Indent = GetIndexLevel(Level or 0)
    local Ret = ""
    if TblName then
        if Level then
            Ret = Ret .. Indent
        end
        Ret = Ret .. (TblName .. " = \n" .. Indent .. "{\n")
    else
        Ret = Ret .. Indent .. "{\n"
    end
    for i, v in pairs(Tbl) do
        if type(v) == "table" then
            Ret = Ret .. PrintTable(v, string.format("[\"%s\"]", i), Level and Level + 1 or 0)
        else
            local NameStr = type(i) == "number" and string.format("[%s]", i) or string.format("[\"%s\"]", i)
            local ValueStr = tostring(v)
            if type(v) == "string" then
                ValueStr = string.format("\"%s\"", ValueStr)
            end
            Ret = Ret .. string.format("%s%s = %s;\n", GetIndexLevel(Level and Level + 1 or 0), NameStr, ValueStr)
        end
    end
    Ret = Ret .. Indent .. "};\n"
    return Ret
end

local Database = {}
function Database:write(Table, DatabaseName)
    local File = io.open(string.format("lua\\%s.database", DatabaseName), "w")
    if File == nil then
        error("database error")
    end
    local DataString = PrintTable(Table, "local Data", -1) .. string.format("\nreturn Data")
    File:write(DataString)
    File:close()
end

function Database:read(DatabaseName)
    local File, Error = loadfile(string.format("lua\\%s.database", DatabaseName), "t")
    if not File then
        print(Error or "database error")
        return nil
    end
    
    return File()
end
return Database
