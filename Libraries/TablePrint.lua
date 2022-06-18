local Console = csgo.interface_handler:get_cvar()

local function GetIndexLevel(Level)
    local Ret = ""
    for i = 0, Level do
        Ret = Ret .. "   "
    end
    return Ret
end

local col = csgo.color(208, 5, 70, 255)
local White = csgo.color(200, 200, 200, 255)

local TypeColors = 
{
    ["string"] = csgo.color(138, 195, 101, 255);
    ["number"] = csgo.color(199, 154, 94, 255);
    ["local"] = csgo.color(198, 120, 221, 255);
}

local function PrintTable(Tbl, TblName, Level)
    local Indent = GetIndexLevel(Level or 1)
    if TblName then
        if Level == -1 then
            Console:print_console("local \0", TypeColors["local"] or White)
            Console:print_console(TblName .. "\0", col)
        else
            local szNameType = type(TblName)
            Console:print_console(Indent .. "\0", White)
            Console:print_console(szNameType == "string" and "[\0" or "[\0", White)
            if szNameType == "string" then
                Console:print_console("\"" .. TblName .. "\"\0", TypeColors[szNameType] or White)
            else
                Console:print_console(TblName .. "\0", TypeColors[szNameType] or White)
            end
            Console:print_console(szNameType == "string" and "]\0" or "]\0", White)
        end
        Console:print_console(" = \n" .. Indent .. "{\n", White)
    else
        Console:print_console(Indent .. "{\n", White)
    end
    for i, v in pairs(Tbl) do
        local szValueType = type(v)
        local szKeyType = type(i)
        if szValueType == "table" then
            PrintTable(v, i, Level and Level + 1 or 0)
        else
            local NameStr = type(i) == "number" and string.format("%s", i) or string.format("\"%s\"", i)
            local ValueStr = tostring(v)
            if szValueType == "string" then
                ValueStr = string.format("\"%s\"", ValueStr)
            end
            Console:print_console(GetIndexLevel(Level and Level + 1 or -1) .. "[\0", White)
            Console:print_console(NameStr .. "\0", TypeColors[szKeyType] or col)
            Console:print_console("]\0", White)
            Console:print_console(" = ", White)
            Console:print_console(ValueStr .. "\0", TypeColors[szValueType] or col)
            Console:print_console(";\n", White)
        end
    end
    Console:print_console(Indent .. "};\n", White)
end

return PrintTable
