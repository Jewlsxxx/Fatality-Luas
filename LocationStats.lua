local Menu              = fatality.menu
local Config            = fatality.config
local Input             = fatality.input
local Render            = fatality.render
local Callbacks         = fatality.callbacks
local Math              = fatality.math
local EntityList        = csgo.interface_handler:get_entity_list()
local Globals           = csgo.interface_handler:get_global_vars()
local Console           = csgo.interface_handler:get_cvar()
local Events            = csgo.interface_handler:get_events()
local Engine            = csgo.interface_handler:get_engine_client()
local Inspect           = require("(Misc)TableInspect")

-- Color of the print header "[ Location Stats ]"
local PrintColor        = csgo.color(66, 135, 245, 255)

local json = { _version = "0.1.2" } local encode do local a, b, c, d, e = string.byte, string.find, string.format, string.gsub, string.match; local f, g, h = table.concat, string.sub, string.rep; local i, j = 1 / 0, -1 / 0; local k = '[^ -!#-[%]^-\255]' local l; do local n, o; local p, q; local function r(n) q[p] = tostring(n) p = p + 1 end local s = e(tostring(0.5), '[^0-9]') local t = e(tostring(12345.12345), '[^0-9' .. s .. ']') if s == '.' then s = nil end local u; if s or t then u = true; if s and b(s, '%W') then s = '%' .. s end if t and b(t, '%W') then t = '%' .. t end end local v = function(w) if j < w and w < i then local x = tostring(w) if u then if t then x = d(x, t, '') end if s then x = d(x, s, '.') end end q[p] = x; p = p + 1; return end error('invalid number') end; local y; local z = { ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', __index = function(_, B) return c('\\u00%02X', a(B)) end } setmetatable(z, z) local function C(x) q[p] = '"' if b(x, k) then x = d(x, k, z) end q[p + 1] = x; q[p + 2] = '"' p = p + 3 end local function D(E) local F = E[0] if type(F) == 'number' then q[p] = '[' p = p + 1; for G = 1, F do y(E[G]) q[p] = ',' p = p + 1 end if F > 0 then p = p - 1 end q[p] = ']' else F = E[1] if F ~= nil then q[p] = '[' p = p + 1; local G = 2; repeat y(F) F = E[G] if F == nil then break end G = G + 1; q[p] = ',' p = p + 1 until false; q[p] = ']' else q[p] = '{' p = p + 1; local F = p; for H, n in pairs(E) do C(H) q[p] = ':' p = p + 1; y(n) q[p] = ',' p = p + 1 end if p > F then p = p - 1 end q[p] = '}' end end p = p + 1 end local I = { boolean = r, number = v, string = C, table = D } setmetatable(I, I) function y(n) if n == o then q[p] = 'null' p = p + 1; return end return I[type(n)](n) end function l(J, K) n, o = J, K; p, q = 1, {} y(n) return f(q) end function encode(n, L, M, N) local x, O = l(n) if not x then return x, O end L, M, N = L or "\n", M or "\t", N or " " local p, G, H, w, P, Q, R = 1, 0, 0, #x, {}, nil, nil; local S = g(N, -1) == "\n" for T = 1, w do local B = g(x, T, T) if not R and (B == "{" or B == "[") then P[p] = Q == ":" and f {B, L} or f {h(M, G), B, L} G = G + 1 elseif not R and (B == "}" or B == "]") then G = G - 1; if Q == "{" or Q == "[" then p = p - 1; P[p] = f {h(M, G), Q, B} else P[p] = f {L, h(M, G), B} end elseif not R and B == "," then P[p] = f {B, L} H = -1 elseif not R and B == ":" then P[p] = f {B, N} if S then p = p + 1; P[p] = h(M, G) end else if B == '"' and Q ~= "\\" then R = not R and true or nil end if G ~= H then P[p] = h(M, G) p, H = p + 1, G end P[p] = B end Q, p = B, p + 1 end return f(P) end end end local escape_char_map = { [ "\\" ] = "\\", [ "\"" ] = "\"", [ "\b" ] = "b", [ "\f" ] = "f", [ "\n" ] = "n", [ "\r" ] = "r", [ "\t" ] = "t", } local escape_char_map_inv = { [ "/" ] = "/" } local parse local function create_set(...) local res = {} for i = 1, select("#", ...) do res[ select(i, ...) ] = true end return res end local space_chars   = create_set(" ", "\t", "\r", "\n") local delim_chars   = create_set(" ", "\t", "\r", "\n", "]", "}", ",") local escape_chars  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u") local literals      = create_set("true", "false", "null") local literal_map = { [ "true"  ] = true, [ "false" ] = false, [ "null"  ] = nil, } local function next_char(str, idx, set, negate) for i = idx, #str do if set[str:sub(i, i)] ~= negate then return i end end return #str + 1 end local function decode_error(str, idx, msg) local line_count = 1 local col_count = 1 for i = 1, idx - 1 do col_count = col_count + 1 if str:sub(i, i) == "\n" then line_count = line_count + 1 col_count = 1 end end error( string.format("%s at line %d col %d", msg, line_count, col_count) ) end local function codepoint_to_utf8(n) local f = math.floor if n <= 0x7f then return string.char(n) elseif n <= 0x7ff then return string.char(f(n / 64) + 192, n % 64 + 128) elseif n <= 0xffff then return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128) elseif n <= 0x10ffff then return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128, f(n % 4096 / 64) + 128, n % 64 + 128) end error( string.format("invalid unicode codepoint '%x'", n) ) end local function parse_unicode_escape(s) local n1 = tonumber( s:sub(1, 4),  16 ) local n2 = tonumber( s:sub(7, 10), 16 ) if n2 then return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000) else return codepoint_to_utf8(n1) end end local function parse_string(str, i) local res = "" local j = i + 1 local k = j while j <= #str do local x = str:byte(j) if x < 32 then decode_error(str, j, "control character in string") elseif x == 92 then res = res .. str:sub(k, j - 1) j = j + 1 local c = str:sub(j, j) if c == "u" then local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1) or str:match("^%x%x%x%x", j + 1) or decode_error(str, j - 1, "invalid unicode escape in string") res = res .. parse_unicode_escape(hex) j = j + #hex else if not escape_chars[c] then decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string") end res = res .. escape_char_map_inv[c] end k = j + 1 elseif x == 34 then res = res .. str:sub(k, j - 1) return res, j + 1 end j = j + 1 end decode_error(str, i, "expected closing quote for string") end local function parse_number(str, i) local x = next_char(str, i, delim_chars) local s = str:sub(i, x - 1) local n = tonumber(s) if not n then decode_error(str, i, "invalid number '" .. s .. "'") end return n, x end local function parse_literal(str, i) local x = next_char(str, i, delim_chars) local word = str:sub(i, x - 1) if not literals[word] then decode_error(str, i, "invalid literal '" .. word .. "'") end return literal_map[word], x end local function parse_array(str, i) local res = {} local n = 1 i = i + 1 while 1 do local x i = next_char(str, i, space_chars, true) if str:sub(i, i) == "]" then i = i + 1 break end x, i = parse(str, i) res[n] = x n = n + 1 i = next_char(str, i, space_chars, true) local chr = str:sub(i, i) i = i + 1 if chr == "]" then break end if chr ~= "," then decode_error(str, i, "expected ']' or ','") end end return res, i end local function parse_object(str, i) local res = {} i = i + 1 while 1 do local key, val i = next_char(str, i, space_chars, true) if str:sub(i, i) == "}" then i = i + 1 break end if str:sub(i, i) ~= '"' then decode_error(str, i, "expected string for key") end key, i = parse(str, i) i = next_char(str, i, space_chars, true) if str:sub(i, i) ~= ":" then decode_error(str, i, "expected ':' after key") end i = next_char(str, i + 1, space_chars, true) val, i = parse(str, i) res[key] = val i = next_char(str, i, space_chars, true) local chr = str:sub(i, i) i = i + 1 if chr == "}" then break end if chr ~= "," then decode_error(str, i, "expected '}' or ','") end end return res, i end local char_func_map = { [ '"' ] = parse_string, [ "0" ] = parse_number, [ "1" ] = parse_number, [ "2" ] = parse_number, [ "3" ] = parse_number, [ "4" ] = parse_number, [ "5" ] = parse_number, [ "6" ] = parse_number, [ "7" ] = parse_number, [ "8" ] = parse_number, [ "9" ] = parse_number, [ "-" ] = parse_number, [ "t" ] = parse_literal, [ "f" ] = parse_literal, [ "n" ] = parse_literal, [ "[" ] = parse_array, [ "{" ] = parse_object, } parse = function(str, idx) local chr = str:sub(idx, idx) local f = char_func_map[chr] if f then return f(str, idx) end decode_error(str, idx, "unexpected character '" .. chr .. "'") end function json.decode(str) if type(str) ~= "string" then error("expected argument of type string, got " .. type(str)) end local res, idx = parse(str, next_char(str, 1, space_chars, true)) idx = next_char(str, idx, space_chars, true) if idx <= #str then decode_error(str, idx, "trailing garbage") end return res end function json.encode(Value) return encode(Value,"\n", "   ") end function string.insert(str1, str2, pos) return str1:sub(1,pos)..str2..str1:sub(pos+1) end 

----------------------------------------------------------------------
--                          Wrapper functions                       --
----------------------------------------------------------------------
-- Join this shit into one line cuz its huge
local Vector = {} Vector.__index = Vector function Vector.new(x, y, z) if type(x) == "table" then return setmetatable({x = x.x or x[1], y = x.y or x[2], z = x.z or x[3]}, Vector) end return setmetatable({x = x or 0, y = y or 0, z = z or 0}, Vector) end function Vector.__add(First, Second) if type(First) == "number" then return Vector.new(First + Second.x, First + Second.y, First + Second.z) elseif type(Second) == "number" then return Vector.new(Second + First.x, Second + First.y, Second + First.z) end return Vector.new(First.x + Second.x, First.y + Second.y, First.z + Second.z) end function Vector.__sub(First, Second) if type(First) == "number" then return Vector.new(First - Second.x, First - Second.y, First - Second.z) elseif type(Second) == "number" then return Vector.new(First.x - Second, First.y - Second, First.z - Second) end return Vector.new(First.x - Second.x, First.y - Second.y, First.z - Second.z) end function Vector.__mul(First, Second) if type(First) == "number" then return Vector.new(First * Second.x, First * Second.y, First * Second.z) elseif type(Second) == "number" then return Vector.new(Second * First.x, Second * First.y, Second * First.z) end return Vector.new(First.x * Second.x, First.y * Second.y, First.z * Second.z) end function Vector.__div(First, Second) if type(First) == "number" then return Vector.new(First / Second.x, First / Second.y, First / Second.z) elseif type(Second) == "number" then return Vector.new(First.x / Second, First.y / Second, First.z / Second) end return Vector.new(First.x / Second.x, First.y / Second.y, First.z / Second.z) end function Vector.__pow(First, Second) if type(First) == "number" then return Vector.new(First ^ Second.x, First ^ Second.y, First ^ Second.z) elseif type(Second) == "number" then return Vector.new(Second ^ First.x, Second ^ First.y, Second ^ First.z) end return Vector.new(First.x ^ Second.x, First.y ^ Second.y, First.z ^ Second.z) end function Vector.__eq(First, Second) return First.x == Second.x and First.y == Second.y and First.z == Second.z end function Vector:DistTo(Other) return (self - Other):Length() end function Vector:Length() return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z) end function Vector:Normalize() local Length = self:Length() self.x = self.x / Length self.y = self.y / Length self.z = self.z / Length end function Vector:Normalized() local Ret = self:Cloned() Ret:Normalize() return Ret end function Vector:Cloned() return Vector.new(self.x, self.y, self.z) end function Vector:Dot(Other) return ((self.x * Other.x) + (self.y * Other.y) + (self.z * Other.z)); end function Vector:cs() return csgo.vector3(self.x, self.y, self.z) end function Vector:PrintData() return string.format("(%f, %f, %f)", self.x, self.y, self.z) end setmetatable(Vector, { __call = function(Table, ...) return Vector.new(...) end })
local Database = {_version = "1.0"} function Database:write(Table, DatabaseName) local File = io.open(string.format("lua\\%s.json", DatabaseName), "w") if File == nil then Print("database error") end local DatabaseValue = json.encode(Table) File:write(DatabaseValue) File:close() end function Database:read(DatabaseName) local File = io.open(string.format("lua\\%s.json", DatabaseName), "rb") if not File then return nil end local Content = File:read("*a") File:close() Content = string.insert(Content, "\n", 0) return Content end

local function Color(r, g, b, a)
   return 
   {
       r = r or 255,
       g = g or 255,
       b = b or 255,
       a = a or 255,
       c = csgo.color(r or 255, g or 255, b or 255, a or 255),
   }
end

local function Print(Text, ...)
   local PrintValue = tostring(Text)
   for i, v in ipairs({...}) do
       PrintValue = string.format("%s %s", PrintValue, tostring(v))
   end
   Console:print_console("[ Location Stats ] \0", PrintColor)
   Console:print_console(string.format("%s\n", PrintValue), Color().c)
end

local function Clamp(Value, Min, Max)
   return Value < Min and Min or (Value > Max and Max or Value)
end

----------------------------------------------------------------------
--                              Lua Data                            --
----------------------------------------------------------------------

local WeaponType = 
{
    "Auto";
    "Scout";
    "Awp";
    "Heavy Pistol";
    "Pistol";
    "Rifle";
    "Smg";
    "Shotgun";
}

local WeaponNameID = 
{
    ["scar20"]      = WeaponType[1];
    ["g3sg1"]       = WeaponType[1];
    ["awp"]         = WeaponType[3];
    ["ssg08"]       = WeaponType[2];

    ["deagle"]      = WeaponType[4];

    ["p250"]        = WeaponType[5];
    ["tec9"]        = WeaponType[5];
    ["glock"]       = WeaponType[5];
    ["elite"]       = WeaponType[5];
    ["hkp2000"]     = WeaponType[5];
    ["fiveseven"]   = WeaponType[5];

    ["ak47"]        = WeaponType[6];
    ["galilar"]     = WeaponType[6];
    ["sg556"]       = WeaponType[6];
    ["m4a1"]        = WeaponType[6];
    ["famas"]       = WeaponType[6];
    ["aug"]         = WeaponType[6];
    ["negev"]       = WeaponType[6];
    ["m249"]        = WeaponType[6];

    ["bizon"]       = WeaponType[7];
    ["p90"]         = WeaponType[7];
    ["ump45"]       = WeaponType[7];
    ["mp7"]         = WeaponType[7];
    ["mac10"]       = WeaponType[7];
    ["mp9"]         = WeaponType[7];

    ["nova"]        = WeaponType[8];
    ["sawedoff"]    = WeaponType[8];
    ["xm1014"]      = WeaponType[8];
    ["mag7"]        = WeaponType[8];
}

local InfoOrder = 
{
    "Kills",
    "HeadshotRatio";
    "Shots";
    "AvgHitchance";
    "AvgDmg";
    "AvgBacktrack";
}

local InfoFormatted = 
{
    ["Kills"]           = "Total Kills: ";
    ["HeadshotRatio"]   = "Headshot: ";
    ["Shots"]           = "Hit/Miss Ratio: ";
    ["AvgHitchance"]    = "Avg. Hitchance: ";
    ["AvgDmg"]          = "Avg. Damage: ";
    ["AvgBacktrack"]    = "Avg. Backtrack: ";
}

local DPIScales = 
{
    0.75,
    1.00,
    1.25,
    1.50,
    2.00,
}

local DPIScaleString = 
{
    "75%",
    "100%",
    "125%",
    "150%",
    "200%",
}

local LocationStats = 
{
    _debug              = false;

    DatabaseName        = "FatalityLocationStats";
    LocalPlayer         = EntityList:get_localplayer();
    LocalPosition       = nil;
    CurrentWeaponType   = nil;
    ScreenSize          = nil;

    MaxBundleDistance   = 750;
    MaxBundleInfoDistance = 500;
    CurrentBundle       = nil;
    
    HasSaved            = false;

    Style               = {};

    Colors = 
    {
        Grab            = Color(38, 33, 72);    -- Color of the grab area
        GradientLeft    = Color(55, 39, 180);   -- Color of the left gradient
        GradientRight   = Color(171, 7, 74);    -- Color of the right gradient
        GradientCenter  = Color(109, 27, 133);  -- Color of the center gradient
        Border          = Color(62, 56, 93);    -- Color of the border
        TabUnderline    = Color(208, 5, 70);    -- Color of the line under selected tab
        EffectPink      = Color(255, 0, 72);    -- Color of pink in glitch effect
        EffectBlue      = Color(50, 52, 255);   -- Color of blue in glitch effect
        Background      = Color(13, 11, 32);    -- Color of the background
        GroupBackgrund  = Color(30, 22, 54);    -- Color of the second background layer
        CheckboxOff     = Color(30, 24, 67);
        CheckboxOn      = Color(207, 7, 87);
        CheckboxOutline = Color(60, 53, 93);

        White           = Color(180, 180, 200);
        Value           = Color(166, 73, 109);
    };

    MapName             = nil;
    Locations           = {};
    LocationBundles     = {};
    TypeTimes           = {};

    BundleAnimations    = {};
    InfoAnimations      = {};

    Dpi                 = nil,
    DpiFonts            = {};
    Font                = nil;
    HasCustomFont       = false;
}

----------------------------------------------------------------------
--                             Menu stuff                           --
----------------------------------------------------------------------

-- Returns a table used for combo config item and name
local function ComboContainer(Name, DefaultValue)
    return
    {
        Name = Name,
        ConfigItem = Config:add_item("Hitlist " .. Name, DefaultValue and DefaultValue or 0)
    }
end

local ConfigItems = 
{
    DPI         = Config:add_item("Location Stats - DPI Combo", 1);
    ItemCombo   = Config:add_item("Location Stats - Item Combo", 0);
    Items = 
    {
        ComboContainer("Total Kills", 1);
        ComboContainer("Headshot %", 1);
        ComboContainer("Hit/Miss Ratio", 1);
        ComboContainer("Avg. Hitchance", 1);
        ComboContainer("Avg. Damage", 1);
        ComboContainer("Avg. Backtrack", 0);
    };
    InfoTypeCombo = Config:add_item("Location Stats - Info Type Combo", 0);
    InfoTypeItems = 
    {
        ComboContainer("Show Map Stats", 1);
        ComboContainer("Show Location Stats", 1);
        ComboContainer("Show Locations", 1);
    }
}

local MenuItems = 
{
    InfoTypeCombo = Menu:add_multi_combo("Location Stats", "Visuals", "Esp", "World", ConfigItems.InfoTypeCombo);
    DPI         = Menu:add_combo("DPI Scale", "Visuals", "Esp", "World", ConfigItems.DPI);
    ItemCombo   = Menu:add_multi_combo("Info Items", "Visuals", "Esp", "World", ConfigItems.ItemCombo);
}

for StringIndex = 1, #DPIScaleString do
    MenuItems.DPI:add_item(DPIScaleString[StringIndex], Config.DPI)
end

for ItemIndex = 1, #ConfigItems.Items do
    local CurrentItem = ConfigItems.Items[ItemIndex]
    MenuItems.ItemCombo:add_item(CurrentItem.Name, CurrentItem.ConfigItem)
end

for ItemIndex = 1, #ConfigItems.InfoTypeItems do
    local CurrentItem = ConfigItems.InfoTypeItems[ItemIndex]
    MenuItems.InfoTypeCombo:add_item(CurrentItem.Name, CurrentItem.ConfigItem)
end

----------------------------------------------------------------------
--                          Member functions                        --
----------------------------------------------------------------------

function LocationStats:Initalize()
    -- Read our databse.
    local DatabaseRead = Database:read(self.DatabaseName)
    -- If there wasnt a databse file
    if not DatabaseRead then
        -- Create a file
        Database:write({}, self.DatabaseName)
    else
        self.LocationBundles = json.decode(DatabaseRead)
    end
    -- Get our formated map name
    self.MapName = self:FormatMapName(Engine:get_map_name())

    -- Create our DPI scaled fonts
    local _75Scale = Render:create_font("Josefin Sans SemiBold", math.floor(20 * 0.75), 600, 0)
    for DPI_Index = 1, #DPIScales do
        local CurrentScale = DPIScales[DPI_Index]
        local TextFont = nil
        -- If this is the first index (75%) scale check for font size to determine if we have the menu font
        if DPI_Index == 1 then
            -- If we have the font then set the bool to true and set our text font to our 75% scaled font
            local TxtWidth = Render:text_size(_75Scale, "1").x
            if TxtWidth == 3.0 then
                self.HasCustomFont = true
                TextFont = _75Scale
            -- Otherwise use verdana
            else
                TextFont = Render:create_font("verdana", math.floor(15 * CurrentScale), 400, 0)
            end
            if self._debug then
                Print("Has Font:", self.HasCustomFont)
                Print("Size:", TxtWidth)
            end
        else
            TextFont = self.HasCustomFont and Render:create_font("Josefin Sans SemiBold", math.floor(20 * CurrentScale), 600, 0) or Render:create_font("verdana", math.floor(15 * CurrentScale), 400, 0)
        end
        -- Set this scale to the scaled font
        self.DpiFonts[CurrentScale] = TextFont
    end

    for WeaponTypeIndex = 1, #WeaponType do
        self.TypeTimes[WeaponType[WeaponTypeIndex]] = 0
    end
end

function LocationStats:CreateBundle(Info)
    return 
    {
        Position        = self.LocalPosition;
        Shots           = 1;
        Hits            = Info.Hit and 1 or 0;
        Kills           = Info.Kill and 1 or 0;
        TotalHeadshots  = Info.Headshot and 1 or 0;
        HeadshotRatio   = Info.Headshot and 1 or 0;

        AvgHitchance    = Info.Hitchance;
        TotalHitchance  = Info.Hitchance;

        TotalDamage     = Info.Damage;
        AvgDmg          = Info.Damage;

        BacktrackShots  = Info.Backtrack ~= 0 and 1 or 0;
        TotalBacktrack  = Info.Backtrack;
        AvgBacktrack    = Info.Backtrack;
    }
end

function LocationStats:NewGlobalValues()
    return 
    {
        Shots           = 0;
        Hits            = 0;
        Kills           = 0;
        TotalHeadshots  = 0;
        HeadshotRatio   = 0;

        AvgHitchance    = 0;
        TotalHitchance  = 0;

        TotalDamage     = 0;
        AvgDmg          = 0;

        BacktrackShots  = 0;
        TotalBacktrack  = 0;
        AvgBacktrack    = 0;
    }
end
    
function LocationStats:CalculateBundles(SingleWeaponType, Info)

    -- Check if this type doesnt have any bundles
    if not self.LocationBundles[self.MapName][SingleWeaponType].Bundles then
        -- If that is the case just create one with the info
        self.LocationBundles[self.MapName][SingleWeaponType].Bundles = {}
        self.LocationBundles[self.MapName][SingleWeaponType].Bundles[1] = self:CreateBundle(Info)
        return
    end

    local FoundBundle = false
    -- Loop through all the bundles on this type
    for BundleIndex = 1, #self.LocationBundles[self.MapName][SingleWeaponType].Bundles do
        local CurrentBundle = self.LocationBundles[self.MapName][SingleWeaponType].Bundles[BundleIndex]

        -- Check if this position is close enough to this bundle
        if self.LocalPosition:DistTo(Vector(CurrentBundle.Position)) < self.MaxBundleInfoDistance then
            -- Set the bool to true
            FoundBundle = true
            -- Check if we hit
            if Info.Hit then
                -- Add to our hits
                CurrentBundle.Hits = CurrentBundle.Hits + 1
                -- Add to our dmg
                CurrentBundle.TotalDamage = CurrentBundle.TotalDamage + Info.Damage
                -- Check if we hit a headshot
                if Info.Headshot then
                    -- Add a headshot for the ratio
                    CurrentBundle.TotalHeadshots = CurrentBundle.TotalHeadshots + 1
                end
            end
            
            if Info.Backtrack ~= 0 then 
                -- Absolute neg values cuz they are fwd track which is close enough to the same thing
                CurrentBundle.TotalBacktrack    = CurrentBundle.TotalBacktrack + Info.Backtrack
                CurrentBundle.BacktrackShots    = CurrentBundle.BacktrackShots + 1
            end

            if Info.Kill then
                CurrentBundle.Kills    = CurrentBundle.Kills + 1
            end
            
            CurrentBundle.TotalHitchance    = CurrentBundle.TotalHitchance + Info.Hitchance
            CurrentBundle.Shots             = CurrentBundle.Shots + 1

            -- Calculate our averages n stuff
            CurrentBundle.AvgHitchance      = CurrentBundle.TotalHitchance /  Clamp(CurrentBundle.Shots, 1, 2^1024)
            CurrentBundle.AvgDmg            = CurrentBundle.TotalDamage /  Clamp(CurrentBundle.Hits, 1, 2^1024)
            CurrentBundle.HeadshotRatio     = CurrentBundle.TotalHeadshots /  Clamp(CurrentBundle.Hits, 1, 2^1024)
            CurrentBundle.AvgBacktrack      = CurrentBundle.TotalBacktrack / Clamp(CurrentBundle.BacktrackShots, 1, 2^1024)
        end
    end

    -- If we haven't found any bundles then make a new one
    if not FoundBundle then
        self.LocationBundles[self.MapName][SingleWeaponType].Bundles[#self.LocationBundles[self.MapName][SingleWeaponType].Bundles + 1] = self:CreateBundle(Info)
    end   
end

function LocationStats:GetOrigin()
    if not self.LocalPlayer then
        if self._debug then
            Print("Invalid local player. Function: LocationStats:GetOrigin()")
        end
      return Vector(0, 0, 0)
   end
   local EyePos = self.LocalPlayer:get_eye_pos()
   -- Create a new vector object for our position
   -- Gheto fix for crouch until netvars are fixed... philip i beg
   return Vector(EyePos.x, EyePos.y, EyePos.z - (Input:is_key_down(0x11) and 48 or 72))
end

-- Purpose:
-- Removes trailing ".bsp"
-- Temporary fix for workshop maps like de_dust2_old until netvars are fixed
function LocationStats:FormatMapName(Name)

    if Name:find("workshop") then
        if Name:find("de_dust2") then
            return "de_dust2_old"
        end
    end

    return string.sub(Name, 6, #Name - 4)
end

function LocationStats:PrettyMapName(Name)
    if Name:find("workshop") then
        return "Custom"
    end

    local Last3 = string.sub(Name, #Name - 2, #Name)
    
    local Ret = string.sub(Name, 4, #Name)

    if Last3 == "old" then
        local StrLen = string.len(Ret)
        Ret = ("%s%s%s"):format(Ret:sub(1,(StrLen - 3)-1), " ", Ret:sub((StrLen - 3)+1))
        Ret = ("%s%s%s"):format(Ret:sub(1,(StrLen - 2)-1), "O", Ret:sub((StrLen - 2)+1))
    end
    Ret = ("%s%s%s"):format(Ret:sub(1,1-1), string.upper(Ret:sub(1,1)), Ret:sub(1+1))

    return Ret
end

-- Purpose:
-- Formats large numbers into a more readable value
-- For example 1520 -> 1.5k
function LocationStats:FormatNumber(Number)
	local NumberAsString = tostring(Number)
    if Number < 1000 then
        return NumberAsString
    elseif Number < 1000000 then
        return(NumberAsString:sub(1, #NumberAsString - 3) .. '.' .. NumberAsString:sub(#NumberAsString - 2, #NumberAsString - 2) .. 'k')
    elseif Number < 100000000 then
        return(NumberAsString:sub(1, #NumberAsString - 6) .. '.'.. NumberAsString:sub(#NumberAsString - 5, #NumberAsString - 5) ..'m')
    elseif Number > 99999999 and Number < 1000000000 then
        return(NumberAsString:sub(1, #NumberAsString - 6) ..'m')
    elseif Number > 999999999 and Number < 100000000000 then
        return(NumberAsString:sub(1, #NumberAsString - 9) .. '.'.. NumberAsString:sub(#NumberAsString - 8, #NumberAsString - 8) ..'b')
    elseif Number > 100000000000 then
        return(NumberAsString:sub(1, #NumberAsString - 9) ..'b')
    end
end

function LocationStats:BundleAnimValues()
    return 
    {
        DistTime        = 0;
        InfoTime        = 0;
        EnableTime     = 0;
    }
end

function LocationStats:DrawBundle(BundleInfo, Animations, Type, BundleIndex)
    local LocationState = ConfigItems.InfoTypeItems[2].ConfigItem:get_bool()
    local WorldLocationState = ConfigItems.InfoTypeItems[3].ConfigItem:get_bool()

    local DistTimeIncr = ((1 / 0.125) * Globals.frametime)
    local Dist = self.LocalPosition:DistTo(BundleInfo.Position)
    Animations.DistTime = Clamp(Animations.DistTime + ((WorldLocationState and Dist <= self.MaxBundleDistance) and DistTimeIncr or -DistTimeIncr), 0, 1)
    Animations.InfoTime = Clamp(Animations.InfoTime + (Dist <= self.MaxBundleInfoDistance and DistTimeIncr or -DistTimeIncr), -0.1, 1)
    Animations.EnableTime = Clamp(Animations.EnableTime + (LocationState and DistTimeIncr or -DistTimeIncr), 0, 1)


    if math.min(Animations.TypeTime, Animations.EnableTime) <= 0 then
        return end
        
    -- Prevent render of bundles that were close enough while u had the weapon out but far away now
    if Animations.TypeTime < 0.25 then
        Animations.DistTime = 0
        Animations.InfoTime = 0
    end

    local Style     = self.Style
    local Colors    = self.Colors

    local Sp = Vector(BundleInfo.Position):cs()
    if Sp:to_screen() and Animations.DistTime > 0 then
        local Alpha = math.floor(225 * math.min(Animations.DistTime, Animations.TypeTime, Animations.EnableTime))

        local ShotString = self:FormatNumber(BundleInfo.Shots)
        local Shots     = string.format("Location %i", BundleIndex)
        local ShotsSize = Render:text_size(self.Font, Shots)
        local Size      =  Vector(ShotsSize.x + Style.Padding * 2, ShotsSize.y)

        if not self.HasCustomFont then
            Size.y = Size.y + Style.Padding * 2
        end
        local Position = Vector(Sp.x - (Size.x / 2), Sp.y - (Size.y / 2))

        Render:rect_filled(Position.x, Position.y, Size.x, Size.y, Color(Colors.Grab.r, Colors.Grab.g, Colors.Grab.b, Alpha).c)
        Render:rect(Position.x, Position.y, Size.x, Size.y, Color(Colors.Border.r, Colors.Border.g, Colors.Border.b, Alpha).c)
        
        local GradientSize = 2 * self.Dpi
        Render:rect_fade(Position.x, Position.y + Size.y - GradientSize - 1, Size.x / 2, GradientSize, Color(Colors.GradientLeft.r, Colors.GradientLeft.g, Colors.GradientLeft.b, Alpha).c, Color(Colors.GradientCenter.r, Colors.GradientCenter.g, Colors.GradientCenter.b, Alpha).c, true)
        Render:rect_fade(Position.x + Size.x / 2, Position.y + Size.y - GradientSize - 1, Size.x / 2, GradientSize, Color(Colors.GradientCenter.r, Colors.GradientCenter.g, Colors.GradientCenter.b, Alpha).c, Color(Colors.GradientRight.r, Colors.GradientRight.g, Colors.GradientRight.b, Alpha).c, true)

        Render:text(self.Font, Position.x + (Size.x / 2) - (ShotsSize.x / 2), Position.y + (Size.y / 2) - (ShotsSize.y / 2) - GradientSize, Shots, Color(Colors.White.r, Colors.White.g, Colors.White.b,  math.floor(255 * math.min(Animations.DistTime, Animations.TypeTime))).c)
    end

    if Dist <= (self.MaxBundleInfoDistance * 0.75) and Animations.EnableTime == 1 then
        self.CurrentBundle = BundleIndex
    end

    if Type ~= nil and Animations.InfoTime > 0 then
        local ItemAmount = 1
        for i = 1, #InfoOrder do
            if ConfigItems.Items[i].ConfigItem:get_bool() then
                ItemAmount = ItemAmount + 1
            end
        end
        local Alpha =  math.floor(255 * math.min(Clamp(Animations.InfoTime, 0, 1), Animations.TypeTime))

        local TypeSize  = Render:text_size(self.Font, Type)
        local Position  = Vector(self.ScreenSize.x / 192, self.ScreenSize.y / 1.8)
        local Size      = Vector(160 * self.Dpi, 3 * self.Dpi + (TypeSize.y + (self.HasCustomFont and 0 or Style.Padding * 1.25)) * ItemAmount)
        local BeginHeader       = string.format("%s [", Type)
        local MidHeader         = string.format("Location %i", BundleIndex)
        local FullHeaderSize    = Render:text_size(self.Font, string.format("%s [Location %i]", Type, BundleIndex))
        local BeginHeaderSize   = Render:text_size(self.Font, BeginHeader)
        local MidHeaderSize     = Render:text_size(self.Font, MidHeader)


        Render:rect_filled(Position.x, Position.y, Size.x, Size.y, Color(Colors.Grab.r, Colors.Grab.g, Colors.Grab.b, Alpha).c)
        Render:rect(Position.x, Position.y, Size.x, Size.y, Color(Colors.Border.r, Colors.Border.g, Colors.Border.b, Alpha).c)

        Render:text(self.Font, Position.x + (Size.x / 2) - (FullHeaderSize.x / 2), Position.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding), BeginHeader, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
        Render:text(self.Font, Position.x + (Size.x / 2) - (FullHeaderSize.x / 2) + BeginHeaderSize.x, Position.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding), MidHeader, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
        Render:text(self.Font, Position.x + (Size.x / 2) - (FullHeaderSize.x / 2) + BeginHeaderSize.x + MidHeaderSize.x, Position.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding), "]", Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)

        --Render:rect_filled(Position.x + Style.Padding , Position.y + FullHeaderSize.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding * 1.5), Size.x - (Style.Padding * 2), 1 * self.Dpi, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
        local AlphaLow = math.floor(75 * math.min(Clamp(Animations.InfoTime, 0, 1), Animations.TypeTime))
        Render:rect_fade(Position.x + Style.Padding, Position.y + FullHeaderSize.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding * 1.5), Size.x / 2, 2, Color(Colors.White.r, Colors.White.g, Colors.White.b, AlphaLow).c, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c, true)
        Render:rect_fade(Position.x + Size.x / 2 + Style.Padding, Position.y + FullHeaderSize.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding * 1.5), Size.x / 2 - Style.Padding * 2, 2, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c, Color(Colors.White.r, Colors.White.g, Colors.White.b, AlphaLow).c, true)

        local Stack = 0
        for i = 1, #InfoOrder do
            if not ConfigItems.Items[i].ConfigItem:get_bool() then
                goto continue
            end
            Stack = Stack + 1
            local CurrentInfo = InfoOrder[i]

            local Label = InfoFormatted[CurrentInfo] or CurrentInfo
            local Value = BundleInfo[CurrentInfo] or 0
            if CurrentInfo == "HeadshotRatio" then
                Value = string.format("%0.0f", Value * 100)
            elseif CurrentInfo == "AvgHitchance" then
                Value = string.format("%0.0f", Value)
            elseif CurrentInfo == "AvgDmg" then
                Value = math.floor(Value)
            elseif CurrentInfo == "AvgBacktrack" then
                Value = string.format("%i", math.floor(Value))
            end

            local LabelSize = Render:text_size(self.Font, Label)

            local YPos = Position.y + FullHeaderSize.y + (self.HasCustomFont and -4 * self.Dpi or Style.Padding * 2) + Style.Padding + ((Stack - 1) * (LabelSize.y + (self.HasCustomFont and 0 or Style.Padding)))
            Render:text(self.Font, Position.x + Style.Padding, YPos, Label, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
            if CurrentInfo == "Shots" then
                local FirstValue = self:FormatNumber(BundleInfo.Hits)
                local FirstValueSize = Render:text_size(self.Font, FirstValue)
                local Seperator = "/"
                local SeperatorSize = Render:text_size(self.Font, Seperator)
                local SecondValue = self:FormatNumber(BundleInfo.Shots - BundleInfo.Hits)
                Render:text(self.Font, Position.x + Style.Padding + LabelSize.x, YPos, FirstValue, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
                Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + FirstValueSize.x, YPos, Seperator, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
                Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + FirstValueSize.x + SeperatorSize.x, YPos, SecondValue, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
            else
                Render:text(self.Font, Position.x + Style.Padding + LabelSize.x, YPos, Value, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
            end

            if CurrentInfo == "AvgHitchance" or CurrentInfo == "HeadshotRatio" then
                local ValueSize = Render:text_size(self.Font, Value)
                Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + ValueSize.x, YPos, "%", Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
            elseif CurrentInfo == "AvgBacktrack" then
                local ValueSize = Render:text_size(self.Font, Value)
                Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + ValueSize.x, YPos, "t", Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
            end
            ::continue::
        end
    end
end

function LocationStats:DrawGlobal(GlobalInfo, Animations, Type)
    local GlobalState = ConfigItems.InfoTypeItems[1].ConfigItem:get_bool()
    -- This is redundant however it is easier to read and cleaner to work with
    -- rather thank rigging LocationStats:DrawBundle to work on global
    local AnimIncr = ((1 / 0.125) * Globals.frametime)
    Animations.InfoTime = Clamp(Animations.InfoTime + ((self.CurrentBundle == nil and GlobalState) and AnimIncr or -AnimIncr), 0, 1)

    if Animations.InfoTime <= 0 or not GlobalInfo then 
        return end

    local Style     = self.Style
    local Colors    = self.Colors

    -- Check which items we have enabled to get height
    local ItemAmount = 1
    for i = 1, #InfoOrder do
        if ConfigItems.Items[i].ConfigItem:get_bool() then
            ItemAmount = ItemAmount + 1
        end
    end

    local Alpha =  math.floor(255 * math.min(Animations.InfoTime, Animations.TypeTime))

    local TypeSize  = Render:text_size(self.Font, Type)
    local Position  = Vector(self.ScreenSize.x / 192, self.ScreenSize.y / 1.8)
    local Size      = Vector(160 * self.Dpi, 3 * self.Dpi + (TypeSize.y + (self.HasCustomFont and 0 or Style.Padding * 1.25)) * ItemAmount)

    local BeginHeader       = string.format("%s [", Type)
    local MidHeader         = self:PrettyMapName(self.MapName)
    local FullHeaderSize    = Render:text_size(self.Font,  string.format("%s [%s]", Type, self:PrettyMapName(self.MapName)))
    local BeginHeaderSize   = Render:text_size(self.Font,  BeginHeader)
    local MidHeaderSize     = Render:text_size(self.Font, MidHeader)


    Render:rect_filled(Position.x, Position.y, Size.x, Size.y, Color(Colors.Grab.r, Colors.Grab.g, Colors.Grab.b, Alpha).c)
    Render:rect(Position.x, Position.y, Size.x, Size.y, Color(Colors.Border.r, Colors.Border.g, Colors.Border.b, Alpha).c)

    Render:text(self.Font, Position.x + (Size.x / 2) - (FullHeaderSize.x / 2), Position.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding), BeginHeader, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
    Render:text(self.Font, Position.x + (Size.x / 2) - (FullHeaderSize.x / 2) + BeginHeaderSize.x, Position.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding), MidHeader, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
    Render:text(self.Font, Position.x + (Size.x / 2) - (FullHeaderSize.x / 2) + BeginHeaderSize.x + MidHeaderSize.x, Position.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding), "]", Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)

    --Render:rect_filled(Position.x + Style.Padding , Position.y + FullHeaderSize.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding * 1.5), Size.x - (Style.Padding * 2), 1 * self.Dpi, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
    local AlphaLow = math.floor(75 * math.min(Clamp(Animations.InfoTime, 0, 1), Animations.TypeTime))
    Render:rect_fade(Position.x + Style.Padding, Position.y + FullHeaderSize.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding * 1.5), Size.x / 2, 2, Color(Colors.White.r, Colors.White.g, Colors.White.b, AlphaLow).c, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c, true)
    Render:rect_fade(Position.x + Size.x / 2 + Style.Padding, Position.y + FullHeaderSize.y + (self.HasCustomFont and -2 * self.Dpi or Style.Padding * 1.5), Size.x / 2 - Style.Padding * 2, 2, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c, Color(Colors.White.r, Colors.White.g, Colors.White.b, AlphaLow).c, true)

    local Stack = 0
    for i = 1, #InfoOrder do
        if not ConfigItems.Items[i].ConfigItem:get_bool() then
            goto continue
        end
        -- Increment our Y pos index
        Stack = Stack + 1
        -- Get the var name in correct order
        local CurrentInfo = InfoOrder[i]
        -- Check if we have this label formatted otherwise use the var name
        local Label = InfoFormatted[CurrentInfo] or CurrentInfo
        local Value = GlobalInfo[CurrentInfo] or nil

        -- Format values
        if CurrentInfo == "HeadshotRatio" then
            Value = string.format("%0.0f", Value * 100)
        elseif CurrentInfo == "AvgHitchance" then
            Value = string.format("%0.0f", Value)
        elseif CurrentInfo == "AvgDmg" then
            Value = math.floor(Value)
        elseif CurrentInfo == "AvgBacktrack" then
            Value = string.format("%i", math.floor(Value))
        end

        local LabelSize = Render:text_size(self.Font, Label)
        
        local YPos = Position.y + FullHeaderSize.y + (self.HasCustomFont and -4 * self.Dpi or Style.Padding * 2) + Style.Padding + ((Stack - 1) * (LabelSize.y + (self.HasCustomFont and 0 or Style.Padding)))
        Render:text(self.Font, Position.x + Style.Padding, YPos, Label, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
        if CurrentInfo == "Shots" then
            local FirstValue = self:FormatNumber(GlobalInfo.Hits)
            local FirstValueSize = Render:text_size(self.Font, FirstValue)
            local Seperator = "/"
            local SeperatorSize = Render:text_size(self.Font, Seperator)
            local SecondValue = self:FormatNumber(GlobalInfo.Shots - GlobalInfo.Hits)
            Render:text(self.Font, Position.x + Style.Padding + LabelSize.x, YPos, FirstValue, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
            Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + FirstValueSize.x, YPos, Seperator, Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
            Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + FirstValueSize.x + SeperatorSize.x, YPos, SecondValue, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
        else
            Render:text(self.Font, Position.x + Style.Padding + LabelSize.x, YPos, Value, Color(Colors.Value.r, Colors.Value.g, Colors.Value.b, Alpha).c)
        end

        if CurrentInfo == "AvgHitchance" or CurrentInfo == "HeadshotRatio" then
            local ValueSize = Render:text_size(self.Font, Value)
            Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + ValueSize.x, YPos, "%", Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
        elseif CurrentInfo == "AvgBacktrack" then
            local ValueSize = Render:text_size(self.Font, Value)
            Render:text(self.Font, Position.x + Style.Padding + LabelSize.x + ValueSize.x, YPos, "t", Color(Colors.White.r, Colors.White.g, Colors.White.b, Alpha).c)
        end
        ::continue::
    end    
end

----------------------------------------------------------------------
--                          Member Callbacks                        --
----------------------------------------------------------------------

function LocationStats:OnRegisteredShot(Shot)

    -- Filter out shot info
    if not self.CurrentWeaponType or not Shot.victim or Shot.hitchance == -1 then
        return end
    local Player = EntityList:get_player(Shot.victim)
    if not Player then
        return end
    local Info = 
    {
        Hitchance   = Shot.hitchance;
        Damage      = Shot.hit_damage == -1 and 0 or Shot.hit_damage;
        Backtrack   = Shot.shot_info.backtrack_ticks;
        Headshot    = Shot.hit_hitgroup == 1;
        Hit         = Shot.hurt;
        Kill        = Shot.hit_damage == -1 and false or not Player:is_alive();
    }
    -- Check for nil table
    if not self.LocationBundles[self.MapName][self.CurrentWeaponType].GlobalValues then
        self.LocationBundles[self.MapName][self.CurrentWeaponType].GlobalValues = self:NewGlobalValues()
    end

    local GlobalValues = self.LocationBundles[self.MapName][self.CurrentWeaponType].GlobalValues
    if Info.Hit then
        -- Add to our hits
        GlobalValues.Hits = GlobalValues.Hits + 1
        -- Add to our dmg
        GlobalValues.TotalDamage = GlobalValues.TotalDamage + Info.Damage
        -- Check if we hit a headshot
        if Info.Headshot then
            -- Add a headshot for the ratio
            GlobalValues.TotalHeadshots = GlobalValues.TotalHeadshots + 1
        end
    end
    -- Check if we backtracked or forward tracked
    if Info.Backtrack ~= 0 then 
        GlobalValues.TotalBacktrack    = GlobalValues.TotalBacktrack + Info.Backtrack
        GlobalValues.BacktrackShots    = GlobalValues.BacktrackShots + 1
    end
    
    if Info.Kill then
        GlobalValues.Kills    = GlobalValues.Kills + 1
    end
    
    GlobalValues.TotalHitchance    = GlobalValues.TotalHitchance + Info.Hitchance
    GlobalValues.Shots             = GlobalValues.Shots + 1

    -- Calculate our averages n stuff
    GlobalValues.AvgHitchance      = GlobalValues.TotalHitchance / Clamp(GlobalValues.Shots, 1, 2^1024)
    GlobalValues.AvgDmg            = GlobalValues.TotalDamage / Clamp(GlobalValues.Hits, 1, 2^1024)
    GlobalValues.HeadshotRatio     = GlobalValues.TotalHeadshots / Clamp(GlobalValues.Hits, 1, 2^1024)
    GlobalValues.AvgBacktrack      = GlobalValues.TotalBacktrack / Clamp(GlobalValues.BacktrackShots, 1, 2^1024)

    self:CalculateBundles(self.CurrentWeaponType, Info)
    -- Save
    Database:write(self.LocationBundles, self.DatabaseName)
end

function LocationStats:OnLevelInit()
    -- Get our formated map name
    self.MapName = self:FormatMapName(Engine:get_map_name())

    -- Nil our weapon type to avoid incorrect weapontype 
    self.CurrentWeaponType = nil
end

-- Purpose:
-- Temporary fix getting local player weapon since netvars are broken
function LocationStats:OnItemEquip(Event)
    -- Nothing to check if we are invalid or dead
    if not self.LocalPlayer or not self.LocalPlayer:is_alive() then
        return
    end

    local Player = EntityList:get_player_from_id(Event:get_int("userid"))

    -- The player isnt invald and we were the one that switched the weapon
    if Player and Player:get_index() == self.LocalPlayer:get_index() then
        -- Convert the event weapon to a nice weapon name
        self.CurrentWeaponType = WeaponNameID[Event:get_string("item")]
    end
end

function LocationStats:Paint() 
    self.LocalPlayer = EntityList:get_localplayer()

    if not self.LocalPlayer then
        -- Nil our weapon type to avoid incorrect weapontype 
        self.CurrentWeaponType = nil
        return
    end
    -- Get the screen's size
    local _ss = Render:screen_size()
    self.ScreenSize = Vector(_ss.x, _ss.y)

    -- Get our position
    self.LocalPosition = self:GetOrigin()

    -- Get our dpi
    self.Dpi = DPIScales[ConfigItems.DPI:get_int() + 1]

    -- Get our current font per dpi
    self.Font = self.DpiFonts[self.Dpi]

    -- Adjust our style to dpi
    self.Style = 
    {
        Padding = 4 * self.Dpi;
    }

    -- Check nil table
    if not self.LocationBundles[self.MapName] then
        self.LocationBundles[self.MapName] = {}
    end

    -- Reset our current bundle state
    self.CurrentBundle = nil
    for WeaponTypeIndex = 1, #WeaponType do
        local CurrentType = WeaponType[WeaponTypeIndex]
        -- Check nil type
        if not self.LocationBundles[self.MapName][CurrentType] then
            self.LocationBundles[self.MapName][CurrentType] = {}
        end

        -- Increment our type fade out
        local TypeTimeIncr = ((1 / 0.25) * Globals.frametime)
        self.TypeTimes[CurrentType] = Clamp(self.TypeTimes[CurrentType] + ((CurrentType == self.CurrentWeaponType) and TypeTimeIncr or -TypeTimeIncr), 0, 1)

        -- Check if we have bundles for this type and our type fade time isnt 0 
        if not self.LocationBundles[self.MapName][CurrentType].Bundles or self.TypeTimes[CurrentType] == 0 then
            goto continue end

        -- Check nil animations
        if not self.BundleAnimations[CurrentType] then
            self.BundleAnimations[CurrentType] = {}
        end

        for BundleIndex = 1, #self.LocationBundles[self.MapName][CurrentType].Bundles do
            local CurrentBundle = self.LocationBundles[self.MapName][CurrentType].Bundles[BundleIndex] 

            -- Check nil animation index
            if not self.BundleAnimations[CurrentType][BundleIndex] then
                self.BundleAnimations[CurrentType][BundleIndex] = self:BundleAnimValues()
            end
            self.BundleAnimations[CurrentType][BundleIndex].TypeTime = self.TypeTimes[CurrentType]
            self:DrawBundle(CurrentBundle, self.BundleAnimations[CurrentType][BundleIndex], CurrentType, BundleIndex)
        end
        
        -- Safety check
        if not self.BundleAnimations[CurrentType]["Global Anims"] then
            self.BundleAnimations[CurrentType]["Global Anims"] = self:BundleAnimValues()
        end
        -- Safety check
        if not self.LocationBundles[self.MapName][CurrentType].GlobalValues then
            self.LocationBundles[self.MapName][CurrentType].GlobalValues = self:NewGlobalValues()
        end

        self.BundleAnimations[CurrentType]["Global Anims"].TypeTime = self.TypeTimes[CurrentType]
        self:DrawGlobal(self.LocationBundles[self.MapName][CurrentType].GlobalValues, self.BundleAnimations[CurrentType]["Global Anims"], CurrentType)

        ::continue::
    end
end

----------------------------------------------------------------------
--                             Callbacks                            --
--                      Call our member functions                   --
----------------------------------------------------------------------

local function OnPaint()
    LocationStats:Paint()
end

local function OnRegisteredShot(Shot)
    LocationStats:OnRegisteredShot(Shot)
end

local function OnLevelInit()
    LocationStats:OnLevelInit()
end

local function OnGameEvents(Event)
    local EventName = Event:get_name()

    if EventName == "item_equip" then
        LocationStats:OnItemEquip(Event)
    end
end

-- Do our startup
LocationStats:Initalize()

Events:add_event("item_equip")
Callbacks:add("paint",              OnPaint)
Callbacks:add("registered_shot",    OnRegisteredShot)
Callbacks:add("level_init",         OnLevelInit)
Callbacks:add("events",             OnGameEvents)
