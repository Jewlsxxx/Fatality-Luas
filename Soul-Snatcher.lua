local Menu              = fatality.menu
local Config            = fatality.config
local Render            = fatality.render
local Callbacks         = fatality.callbacks
local Math              = fatality.math
local EntityList        = csgo.interface_handler:get_entity_list()
local Globals           = csgo.interface_handler:get_global_vars()
local Events            = csgo.interface_handler:get_events()
local DebugOverlay      = csgo.interface_handler:get_debug_overlay()  
local Vector            = csgo.vector3

local function Clamp(Value, Min, Max)
    return Value < Min and Min or (Value > Max and Max or Value)
end

local function Dist(one, two)
    return math.sqrt((one.x - two.x)^2 + (one.y - two.y)^2 + (one.z - two.z)^2)
end

local function VectorSubtract(o, t)
    if type(t) ~= "userdata" then
        return Vector(o.x - t, o.y - t, o.z - t)
    else
        return Vector(o.x - t.x, o.y - t.y, o.z - t.z)
    end
end

local function VectorMutl(o, t)
    if type(t) ~= "userdata" then
        return Vector(o.x * t, o.y * t, o.z * t)
    else
        return Vector(o.x * t.x, o.y * t.y, o.z * t.z)
    end
end

local function AngleVectors(Angle)
    local SP, SY, CP, CY
    SP = math.sin(math.rad(Angle.x))
    CP = math.cos(math.rad(Angle.x))

    SY = math.sin(math.rad(Angle.y))
    CY = math.cos(math.rad(Angle.y))

    return Vector(CP * CY, CP * SY, -SP)
end

local function Ease(x) 
    return x < 0.5 and 4 * x * x * x or 1 - math.pow(-2 * x + 2, 3) / 2;
end

local function Color(R, G, B, A)
    local Ret = 
    {
        r = R ~= nil and Clamp(math.floor(R), 0, 255) or 255,
        g = G ~= nil and Clamp(math.floor(G), 0, 255) or 255,
        b = B ~= nil and Clamp(math.floor(B), 0, 255) or 255,
        a = A ~= nil and Clamp(math.floor(A), 0, 255) or 255,
    }
    Ret.c = function()
        return csgo.color(Ret.r, Ret.g, Ret.b, Ret.a)
    end
    return Ret
end

-- From imgui
local function RgbToHsv(r, g, b)
    local K = 0;
    if (g < b) then
    
        local temp = g
        g = b
        b = temp
        K = -1;
    
    end
    if (r < g) then

        local temp = r
        r = g
        g = temp
        K = -2 / 6 - K;

    end

    local  chroma = r - (g < b and g or b);
    return
    {
        h = math.abs(K + (g - b) / (6 * chroma + 1e-20));
        s = chroma / (r + 1e-20);
        v = r
    }
end

-- From here https://gist.github.com/GigsD4X/8513963
local function HsvToRgb( hue, saturation, value )
	-- Returns the RGB equivalent of the given HSV-defined color
	-- (adapted from some code found around the web)

	-- If it's achromatic, just return the value
	if saturation == 0 then
		return {r = value, g = value, b = value};
	end;

	-- Get the hue sector
	local hue_sector = math.floor( hue / 60 );
	local hue_sector_offset = ( hue / 60 ) - hue_sector;

	local p = value * ( 1 - saturation );
	local q = value * ( 1 - saturation * hue_sector_offset );
	local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) );

	if hue_sector == 0 then
		return {r = value, g = t, b = p};
	elseif hue_sector == 1 then
		return {r = q, g = value, b = p};
	elseif hue_sector == 2 then
		return {r = p, g = value, b = t};
	elseif hue_sector == 3 then
		return {r = p, g = q, b = value};
	elseif hue_sector == 4 then
		return {r = t, g = p, b = value};
	elseif hue_sector == 5 then
		return {r = value, g = p, b = q};
	end;
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function ComboItem(Name, DefaultValue)
    return
    {
        Name = Name,
        ConfigItem = Config:add_item("Soul Snatch " .. Name, DefaultValue and DefaultValue or 0)
    }
end

local ConfigItems = 
{
    Toggle  = Config:add_item("Soul Snatch Toggle", 1),
    Combo   = Config:add_item("Soul Snatch Combo", 0),
    ComboItems = 
    {
        ComboItem("Pink"),
        ComboItem("Blue"),
        ComboItem("Green"),
        ComboItem("Orange"),
    },
    ReleaseCombo = Config:add_item("Soul Snatch ReleaseCombo", 0),
    ReleaseComboItems = 
    {
        ComboItem("On Round End", 0),
        ComboItem("On Death", 1),
    },
}

local MenuItems = 
{
    Toggle  = Menu:add_checkbox("Soul Snatcher", "Visuals", "Misc", "Beams", ConfigItems["Toggle"]),
    Combo   = Menu:add_combo("Color Palette", "Visuals", "Misc", "Beams", ConfigItems["Combo"]),
    ReleaseCombo = Menu:add_multi_combo("Release Modes", "Visuals", "Misc", "Beams", ConfigItems["ReleaseCombo"]),
}

for i = 1, #ConfigItems["ComboItems"] do
    local CurrentItem = ConfigItems["ComboItems"][i]
    MenuItems["Combo"]:add_item(CurrentItem.Name, CurrentItem.ConfigItem) --Add all of our items to our combo
end

for i = 1, #ConfigItems["ReleaseComboItems"] do
    local CurrentItem = ConfigItems["ReleaseComboItems"][i]
    MenuItems["ReleaseCombo"]:add_item(CurrentItem.Name, CurrentItem.ConfigItem) --Add all of our items to our combo
end

local Colors = 
{
    -- Pink
    {
        Color(217, 63, 89),
        Color(201, 68, 115),
        Color(138, 32, 86),
        Color(207, 74, 180),
        Color(114, 26, 117),
        Color(100, 26, 117),
        Color(84, 26, 117),
        Color(131, 46, 179),
    },
    -- Blue
    {
        Color(86, 46, 179),
        Color(48, 46, 179),
        Color(69, 94, 222),
        Color(97, 110, 173),
        Color(97, 131, 173),
        Color(80, 165, 191),
        Color(135, 237, 255),
        Color(84, 199, 176),
    },
    -- Green
    {
        Color(84, 199, 165),
        Color(48, 176, 125),
        Color(31, 184, 110),
        Color(5, 255, 43),
        Color(185, 245, 113),
        Color(153, 204, 65),
        Color(131, 166, 71),
        Color(144, 201, 46),
    },
    -- Orange
    {
        Color(173, 123, 16),
        Color(133, 92, 7),
        Color(161, 136, 48),
        Color(201, 162, 22),
        Color(201, 135, 22),
        Color(201, 162, 4),
        Color(184, 158, 55),
        Color(163, 146, 78),
    },
}

local SoulSnatcher = 
{
    LocalPlayer         = EntityList:get_localplayer(),
    RotationAngle       = 0,
    -- Only adding this to the table so we dont have to calculate it multiple times
    RotationIncrement   = 0,
    -- How far we go for the line. the lower the more smooth however bigger fps hit
    LineIncrement       = 0.075,
    Radius              = 20,
    MaxZRadius          = 60,
    Length              = (math.pi * 2) * 0.1,
    GrowTime            = 0.5,

    ReleaseSouls        = false,
    HitboxPosition      = 0,

    -- 360 degrees of radians
    Radian360           = math.pi * 2,
}

local Souls = {}

local function NewSoul(Position)
    return
    {
        Position        = Position,
        Velocity        = Clamp(math.random() * 2, 0.5, 999),
        EndRoundTime    = 0,
        KillTime        = 0,
        zRadius         = Clamp(math.random() * SoulSnatcher["MaxZRadius"], 5, SoulSnatcher["MaxZRadius"])
    }
end

SoulSnatcher["Update"] = function ()
    -- Keep our local player updated
    SoulSnatcher["LocalPlayer"] = EntityList:get_localplayer()
    -- Adjust our rotation angle so the souls go around our body
    SoulSnatcher["RotationIncrement"] = ((SoulSnatcher["Radian360"] / 2.5) * Globals.frametime)
    SoulSnatcher["RotationAngle"] = Clamp(SoulSnatcher["RotationAngle"] + SoulSnatcher["RotationIncrement"], 0, SoulSnatcher["Radian360"])
    if SoulSnatcher["RotationAngle"] == SoulSnatcher["Radian360"] then
        SoulSnatcher["RotationAngle"] = 0 end
    
end

local function OnPaint()
    -- Update our lua
    SoulSnatcher.Update()

    -- If we have untoggled or we are invalid then release souls and reset round end state
    if not ConfigItems["Toggle"]:get_bool() or not SoulSnatcher["LocalPlayer"] then
        SoulSnatcher["ReleaseSouls"] = false
        Souls = {}
    return end
    -- Dont render if we arent alive
    if not SoulSnatcher["LocalPlayer"]:is_alive() then 
        return end

    -- If the round hasnt ended then continue to update our position
    if not SoulSnatcher["ReleaseSouls"] then
        SoulSnatcher["HitboxPosition"] = SoulSnatcher["LocalPlayer"]:get_hitbox_pos(2)
    end

    -- This stuff is used alot
    local ColorPallete = Colors[ConfigItems["Combo"]:get_int() + 1]
    local Radius = SoulSnatcher["Radius"] 
    local Position = SoulSnatcher["HitboxPosition"]
    for SoulIndex = 1, #Souls do 
        local CurrentSoul = Souls[SoulIndex]
        -- Animate our round end movement
        if not SoulSnatcher["ReleaseSouls"] then
            CurrentSoul["EndRoundTime"] = 0
        else
            local Increment = ((1 / CurrentSoul["Velocity"]) * Globals.frametime)
            CurrentSoul["EndRoundTime"] = Clamp(CurrentSoul["EndRoundTime"] + Increment, 0, 1)
            --SoulSnatcher["HitboxPosition"].z = SoulSnatcher["HitboxPosition"].z + (50 * SoulSnatcher["EndRoundAnimTime"])
        end

        -- Dont clamp it we need extra
        CurrentSoul["KillTime"] = CurrentSoul["KillTime"] + ((1 / SoulSnatcher["GrowTime"]) * Globals.frametime) 
        -- Use this to space the "souls" correctly
        local AngleIndex = SoulSnatcher["RotationAngle"] + SoulSnatcher["Radian360"] * (SoulIndex / #Souls)
        local AngleLength = AngleIndex + (SoulSnatcher["Length"]) * Clamp(CurrentSoul["KillTime"] - 1, 0, 1)
        local IsMultiple = SoulIndex % 2
        -- The color we want to use
        local WantedColor =  ColorPallete[SoulIndex] and ColorPallete[SoulIndex] or ColorPallete[SoulIndex % #ColorPallete + 1]

        if CurrentSoul["KillTime"] > 1 and CurrentSoul["EndRoundTime"] ~= 1 then
            -- If the round has endex then lerp this souls position
            if SoulSnatcher["ReleaseSouls"] then
                local x = Lerp(CurrentSoul["Position"].x, SoulSnatcher["HitboxPosition"].x, Ease(1 - CurrentSoul["EndRoundTime"]))
                local y = Lerp(CurrentSoul["Position"].y, SoulSnatcher["HitboxPosition"].y, Ease(1 - CurrentSoul["EndRoundTime"]))
                local z = Lerp(CurrentSoul["Position"].z + 2000, SoulSnatcher["HitboxPosition"].z, Ease(1 - CurrentSoul["EndRoundTime"]))
                Position = Vector(x, y, z)
            end
            for i = AngleIndex, AngleLength, SoulSnatcher["LineIncrement"] do
                local NA = (i + SoulSnatcher["LineIncrement"]) > AngleLength and AngleLength or (i + SoulSnatcher["LineIncrement"])
                -- Position is just hitbox position + sin and cos times radius
                local P1 = Vector(Position.x + (math.cos(i) * Radius), Position.y + (math.sin(i) * Radius), (Position.z - CurrentSoul["zRadius"] * 0.75) + ((IsMultiple == 1 and math.cos(math.cos(i)) or math.cos(math.sin(i))) * CurrentSoul["zRadius"]))
                local P2 = Vector(Position.x + (math.cos(NA) * Radius), Position.y + (math.sin(NA) * Radius), (Position.z -  CurrentSoul["zRadius"] * 0.75) + ((IsMultiple == 1 and math.cos(math.cos(NA)) or math.cos(math.sin(NA))) * CurrentSoul["zRadius"]))
                local Percentage = Clamp((i - AngleIndex) / (AngleLength - AngleIndex), 0.3, 1)
                -- Convert to hsv then lower v (brightness) and convert back to rgb
                local HSV = RgbToHsv(WantedColor.r, WantedColor.g, WantedColor.b)
                local NewRGB = HsvToRgb(HSV.h * 360, HSV.s, HSV.v * Clamp(Percentage * 1.5, 0, 1))

                DebugOverlay:add_line_overlay( P1, P2, Color(NewRGB.r, NewRGB.g, NewRGB.b).c(), false, Globals.frametime * 1.9)
            end
        end

        local LineLength = 0.1
        if CurrentSoul["KillTime"] >= 1 + LineLength then
            goto continue end
        
        local FirstPoint = Vector(Position.x + (math.cos(AngleIndex) * Radius), Position.y + (math.sin(AngleIndex) * Radius), (Position.z -  CurrentSoul["zRadius"] * 0.75) + ((IsMultiple == 1 and math.cos(math.cos(AngleIndex)) or math.cos(math.sin(AngleIndex))) * CurrentSoul["zRadius"]))
        local LastPoint = Vector(Position.x + (math.cos(AngleLength) * Radius), Position.y + (math.sin(AngleLength) * Radius), (Position.z -  CurrentSoul["zRadius"] * 0.75) + ((IsMultiple == 1 and math.cos(math.cos(AngleLength)) or math.cos(math.sin(AngleLength))) * CurrentSoul["zRadius"]))

        local FirstPointDist = Dist(FirstPoint, CurrentSoul["Position"])
        local LastPointDist = Dist(LastPoint, CurrentSoul["Position"])
        if LastPointDist < FirstPointDist then
            FirstPointDist = LastPointDist
        end
        local Forward = AngleVectors(Math:calc_angle(LastPointDist < FirstPointDist and LastPoint or FirstPoint, CurrentSoul["Position"]))

        local FirstPosition = VectorSubtract(CurrentSoul["Position"], VectorMutl(Forward, (FirstPointDist * Ease(CurrentSoul["KillTime"] - LineLength))))
        local SecondPosition = VectorSubtract(CurrentSoul["Position"], VectorMutl(Forward, (FirstPointDist * Clamp(Ease(CurrentSoul["KillTime"]), 0, 1))))
            
        DebugOverlay:add_line_overlay(FirstPosition, SecondPosition, WantedColor.c(), true, Globals.frametime * 1.9)
        ::continue::
    end
end

local function OnPlayerDeath(Event)
    if not SoulSnatcher["LocalPlayer"] then
        Souls = {}
        return end

    local Attacker = EntityList:get_player_from_id(Event:get_int("attacker"))
    local Victim = EntityList:get_player_from_id(Event:get_int("userid"))

    -- If we died release them
    if Victim:get_index() == SoulSnatcher["LocalPlayer"]:get_index() then
        if ConfigItems["ReleaseComboItems"][2].ConfigItem:get_bool() then
            Souls = {}
        end
        return
    end

    -- Check if we were attacker
    if Attacker:get_index() ~= SoulSnatcher["LocalPlayer"]:get_index() then
        return end

    -- Set the position to their pelvis cuz why not
    local Position = Victim:get_hitbox_pos(2)
    Souls[#Souls + 1] = NewSoul(Position and Position or Vector(0, 0, 0))
end

local function OnGameEvent(Event)
    local EventName = Event:get_name()
    if EventName == "player_death" then
        OnPlayerDeath(Event)
    elseif EventName == "round_end" then
        if ConfigItems["ReleaseComboItems"][1].ConfigItem:get_bool() then
            SoulSnatcher["ReleaseSouls"] = true
        end
    elseif EventName == "round_start" then
        if ConfigItems["ReleaseComboItems"][1].ConfigItem:get_bool() then
            Souls = {}
        end
        SoulSnatcher["ReleaseSouls"] = false
    end
end

local function OnLevelInit() 
    SoulSnatcher["ReleaseSouls"] = false
    Souls = {}
end

Events:add_event("round_end")
Events:add_event("round_start")
Events:add_event("player_death")

Callbacks:add("paint", OnPaint)
Callbacks:add("events", OnGameEvent)
Callbacks:add("level_init", OnLevelInit)
