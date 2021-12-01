-- adapted from code i found online
-- credits to whoever made it
local json = {_version = "0.1.2"}
local encode
do
    local a, b, c, d, e = string.byte, string.find, string.format, string.gsub, string.match
    local f, g, h = table.concat, string.sub, string.rep
    local i, j = 1 / 0, -1 / 0
    local k = "[^ -!#-[%]^-\255]"
    local l
    do
        local n, o
        local p, q
        local function r(n)
            q[p] = tostring(n)
            p = p + 1
        end
        local s = e(tostring(0.5), "[^0-9]")
        local t = e(tostring(12345.12345), "[^0-9" .. s .. "]")
        if s == "." then
            s = nil
        end
        local u
        if s or t then
            u = true
            if s and b(s, "%W") then
                s = "%" .. s
            end
            if t and b(t, "%W") then
                t = "%" .. t
            end
        end
        local v = function(w)
            if j < w and w < i then
                local x = tostring(w)
                if u then
                    if t then
                        x = d(x, t, "")
                    end
                    if s then
                        x = d(x, s, ".")
                    end
                end
                q[p] = x
                p = p + 1
                return
            end
            error("invalid number")
        end
        local y
        local z = {
            ['"'] = '\\"',
            ["\\"] = "\\\\",
            ["\b"] = "\\b",
            ["\f"] = "\\f",
            ["\n"] = "\\n",
            ["\r"] = "\\r",
            ["\t"] = "\\t",
            __index = function(_, B)
                return c("\\u00%02X", a(B))
            end
        }
        setmetatable(z, z)
        local function C(x)
            q[p] = '"'
            if b(x, k) then
                x = d(x, k, z)
            end
            q[p + 1] = x
            q[p + 2] = '"'
            p = p + 3
        end
        local function D(E)
            local F = E[0]
            if type(F) == "number" then
                q[p] = "["
                p = p + 1
                for G = 1, F do
                    y(E[G])
                    q[p] = ","
                    p = p + 1
                end
                if F > 0 then
                    p = p - 1
                end
                q[p] = "]"
            else
                F = E[1]
                if F ~= nil then
                    q[p] = "["
                    p = p + 1
                    local G = 2
                    repeat
                        y(F)
                        F = E[G]
                        if F == nil then
                            break
                        end
                        G = G + 1
                        q[p] = ","
                        p = p + 1
                    until false
                    q[p] = "]"
                else
                    q[p] = "{"
                    p = p + 1
                    local F = p
                    for H, n in pairs(E) do
                        C(H)
                        q[p] = ":"
                        p = p + 1
                        y(n)
                        q[p] = ","
                        p = p + 1
                    end
                    if p > F then
                        p = p - 1
                    end
                    q[p] = "}"
                end
            end
            p = p + 1
        end
        local I = {boolean = r, number = v, string = C, table = D}
        setmetatable(I, I)
        function y(n)
            if n == o then
                q[p] = "null"
                p = p + 1
                return
            end
            return I[type(n)](n)
        end
        function l(J, K)
            n, o = J, K
            p, q = 1, {}
            y(n)
            return f(q)
        end
        function encode(n, L, M, N)
            local x, O = l(n)
            if not x then
                return x, O
            end
            L, M, N = L or "\n", M or "\t", N or " "
            local p, G, H, w, P, Q, R = 1, 0, 0, #x, {}, nil, nil
            local S = g(N, -1) == "\n"
            for T = 1, w do
                local B = g(x, T, T)
                if not R and (B == "{" or B == "[") then
                    P[p] = Q == ":" and f {B, L} or f {h(M, G), B, L}
                    G = G + 1
                elseif not R and (B == "}" or B == "]") then
                    G = G - 1
                    if Q == "{" or Q == "[" then
                        p = p - 1
                        P[p] = f {h(M, G), Q, B}
                    else
                        P[p] = f {L, h(M, G), B}
                    end
                elseif not R and B == "," then
                    P[p] = f {B, L}
                    H = -1
                elseif not R and B == ":" then
                    P[p] = f {B, N}
                    if S then
                        p = p + 1
                        P[p] = h(M, G)
                    end
                else
                    if B == '"' and Q ~= "\\" then
                        R = not R and true or nil
                    end
                    if G ~= H then
                        P[p] = h(M, G)
                        p, H = p + 1, G
                    end
                    P[p] = B
                end
                Q, p = B, p + 1
            end
            return f(P)
        end
    end
end
local escape_char_map_inv = {["/"] = "/"}
local parse
local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end
local space_chars = create_set(" ", "\t", "\r", "\n")
local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals = create_set("true", "false", "null")
local literal_map = {["true"] = true, ["false"] = false, ["null"] = nil}
local function next_char(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end

local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
        col_count = col_count + 1
        if str:sub(i, i) == "\n" then
            line_count = line_count + 1
            col_count = 1
        end
    end
    error(string.format("%s at line %d col %d", msg, line_count, col_count))
end

local function codepoint_to_utf8(n)
    local f = math.floor
    if n <= 0x7f then
        return string.char(n)
    elseif n <= 0x7ff then
        return string.char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
        return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
        return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128, f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error(string.format("invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
    local n1 = tonumber(s:sub(1, 4), 16)
    local n2 = tonumber(s:sub(7, 10), 16)
    if n2 then
        return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
        return codepoint_to_utf8(n1)
    end
end

local function parse_string(str, i)
    local res = ""
    local j = i + 1
    local k = j
    while j <= #str do
        local x = str:byte(j)
        if x < 32 then
            decode_error(str, j, "control character in string")
        elseif x == 92 then
            res = res .. str:sub(k, j - 1)
            j = j + 1
            local c = str:sub(j, j)
            if c == "u" then
                local hex =
                    str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1) or str:match("^%x%x%x%x", j + 1) or
                    decode_error(str, j - 1, "invalid unicode escape in string")
                res = res .. parse_unicode_escape(hex)
                j = j + #hex
            else
                if not escape_chars[c] then
                    decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                end
                res = res .. escape_char_map_inv[c]
            end
            k = j + 1
        elseif x == 34 then
            res = res .. str:sub(k, j - 1)
            return res, j + 1
        end
        j = j + 1
    end
    decode_error(str, i, "expected closing quote for string")
end

local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
        decode_error(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
end

local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
        decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
end

local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
        local x
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end
        x, i = parse(str, i)
        res[n] = x
        n = n + 1
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected ']' or ','")
        end
    end
    return res, i
end
local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end
        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)
        val, i = parse(str, i)
        res[key] = val
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected '}' or ','")
        end
    end
    return res, i
end
local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object
}
parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
        return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
end

function json.decode(str)
    if type(str) ~= "string" then
        error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
        decode_error(str, idx, "trailing garbage")
    end
    return res
end

function json.encode(tbl)
    return encode(tbl, "\n", "   ") .. "\n"
end

-- lol
function json.beautify(str)
    return json.encode(json.decode(str))
end

local Console = csgo.interface_handler:get_cvar()

local g_JsonColors = 
{
    ["value"] = csgo.color(176, 98, 117, 255),
    ["string"] = csgo.color(138, 195, 101, 255),
    ["number"] = csgo.color(199, 154, 94, 255),
    ["white"] = csgo.color(200, 200, 200, 255),
}

local g_JsonNSearch = 
{
    [[ %d+]],
    [[ -%d+]],
    [[ true]],
    [[ false]],
}

function json.print(str, beautify)
    local szFormated = beautify and json.beautify(str) or str
    for line in szFormated:gmatch('[^\r\n]+') do
        local iIndex1, iIndex2 = string.find(line, [[%s+".-":]])
        if iIndex1 and iIndex2 then
            Console:print_console(line:sub(iIndex1, iIndex2 - 1) .. "\0", g_JsonColors["value"])
            Console:print_console(":\0", g_JsonColors["white"])
            line = line:sub(iIndex2 + 1, line:len())
        end
        local iStringIndex1, iStringIndex2 = string.find(line, [[ ".-"]])
        local iNumberIndex1, iNumberIndex2
        for i = 1, #g_JsonNSearch do
            iNumberIndex1, iNumberIndex2 = string.find(line, g_JsonNSearch[i])
            if iNumberIndex1 then
                break
            end
        end

        local col = g_JsonColors["white"]
        if iStringIndex1 then
            col = g_JsonColors["string"]
        elseif iNumberIndex1 then
            col = g_JsonColors["number"]
        end

        if string.find(line, [[,]]) then
            Console:print_console(line:sub(0, line:len() - 1) .. "\0", col)
            Console:print_console(",\n", g_JsonColors["white"])
        else
            Console:print_console(line .. "\n", col)
        end
    end
end

return json
