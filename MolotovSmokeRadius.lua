local Config        = fatality.config
local Menu          = fatality.menu
local Callbacks     = fatality.callbacks
local Engine        = csgo.interface_handler:get_engine_client()
local EntityList    = csgo.interface_handler:get_entity_list()
local Globals       = csgo.interface_handler:get_global_vars()

local function CheckLib(name, link)
    local Success, Lib  = pcall(require, "libs\\" .. name)

    if not Success then
        error(string.format("\nMissing %s library. Get it at %s and follow the download guide.", name, link))
    end
    return Lib
end

local Surface   = CheckLib("surface",       "https://fatality.win/threads/developers-render-extention.10402/")
local Netvar    = CheckLib("netvar",        "https://fatality.win/threads/developers-netvar-fix.10393/")
local Vector    = CheckLib("vector",        "https://fatality.win/threads/developers-extended-vector-api.9671/")
local SmokeColor    = Config:add_item("grenade_radius_smoke",   0)
local MolotovColor  = Config:add_item("grenade_radius_molotov", 0)
local AlphaSlider   = Config:add_item("grenade_radius_slider",  50)




local function InitCombo(combo, cfg_item)
    combo:add_item("Off", cfg_item)
    combo:add_item("White", cfg_item)
    combo:add_item("Red", cfg_item)
    combo:add_item("Green", cfg_item)
    combo:add_item("Blue", cfg_item)
    combo:add_item("Purple", cfg_item)
    combo:add_item("Pink", cfg_item)
    combo:add_item("Soft pink", cfg_item)
    combo:add_item("Yellow", cfg_item)
    combo:add_item("Orange", cfg_item)
    combo:add_item("Teal", cfg_item)
    combo:add_item("Denim", cfg_item)
end

local SmokeCombo    = Menu:add_combo("Smoke Radius", "Visuals", "Misc", "Various", SmokeColor)
local MolotovCombo  = Menu:add_combo("Molotov Radius", "Visuals", "Misc", "Various", MolotovColor)
Menu:add_slider("Alpha", "Visuals", "Misc", "Various", AlphaSlider, 0, 255, 1)

InitCombo(SmokeCombo, SmokeColor)
InitCombo(MolotovCombo, MolotovColor)


local Math      = { PI2 = math.pi * 2 }
local Drawing   = {}
local Style     = 
{
    FadeIn      = 0.25,
    FadeOut     = 0.5,
    RevTime     = 2,
    RevPercent  = 0.5,
    CircleSize  = 150,
    CircleIncr  = Math.PI2 / 60 
}

local Colors = 
{
    {255, 255, 255},    -- White
    {255, 0, 0},        -- Red
    {0, 255, 0},        -- Blue
    {0, 0, 255},        -- Green
    {92, 0, 128},       -- Purple
    {209, 67, 152},     -- Pink
    {255, 192, 203},    -- Soft pink
    {255, 255, 0},      -- Yellow
    {255, 123, 0},      -- Orange
    {0, 128, 128},      -- Teal
    {85, 85, 161},      -- Denim   
}


local SMOKELIFE     = 17.5
local MOLOTOVLIFE   = 7

Drawing.paint = function()
    
    if not Engine:is_in_game() then
        return
    end

    local MolotovColIdx = MolotovColor:get_int()
    local SmokeColIdx   = SmokeColor:get_int()

    Drawing.MolotovColor    = MolotovColIdx == 0    and nil or Colors[MolotovColIdx]
    Drawing.SmokeColor      = SmokeColIdx == 0      and nil or Colors[SmokeColIdx]
    Drawing.Alpha           = AlphaSlider:get_int()

    for Index = 0, EntityList:get_max_entities() do
        local Entity = EntityList:get_entity(Index)
        if not Entity then
            goto continue
        end

        local ClassID = Entity:get_class_id()

        local IsSmoke   = ClassID == 157
        local IsMolotov = ClassID == 100

        if not IsSmoke and not IsMolotov then
            goto continue
        end

        if (IsSmoke and not Drawing.SmokeColor) or (IsMolotov and not Drawing.MolotovColor) then
            goto continue
        end

        local vOrigin       = Vector(Netvar.GetVector(Index, "DT_BaseEntity", "m_vecOrigin")) - Vector(0, 0, 3)
        local EffectBegin   = Netvar.GetInt(Index, IsSmoke and "DT_SmokeGrenadeProjectile" or "DT_Inferno", IsSmoke and "m_nSmokeEffectTickBegin" or "m_nFireEffectTickBegin")
        local nTimeAlive    = Math.TickToTime(Globals.tickcount - EffectBegin)
        local Lifespan      = IsSmoke and SMOKELIFE or MOLOTOVLIFE
        local Color         = IsSmoke and Drawing.SmokeColor or Drawing.MolotovColor


        local flFadeIn = Math.Clamp(Style.FadeIn - (Style.FadeIn - nTimeAlive), 0, Style.FadeIn) / Style.FadeIn
        local flFadeOut = Math.Clamp(Lifespan - nTimeAlive, 0, Style.FadeOut) / Style.FadeOut

        Drawing.Circle3D(vOrigin, math.min(flFadeIn, flFadeOut), flFadeIn, Color[1], Color[2], Color[3])
        ::continue::
    end

end

Drawing.Circle3D = function(Position, AlphaMult, SizeMultiplier, r, g, b)

    local RevolutionPercentage = (Globals.realtime % Style.RevTime) / Style.RevTime
    local Angle = RevolutionPercentage * Math.PI2

    for i = Angle, Angle + Math.PI2 * Style.RevPercent, Style.CircleIncr do
        local P1    = Position + Vector(math.cos(i), math.sin(i), 0) * (Style.CircleSize * SizeMultiplier)
        local P2    = Position + Vector(math.cos(i + Style.CircleIncr), math.sin(i + Style.CircleIncr), 0) * (Style.CircleSize * SizeMultiplier)

        local x1, y1 = P1:to_screen()
        local x2, y2 = P2:to_screen()

        if x1 and x2 then
            Surface.Line(x1, y1, x2, y2, r, g, b, math.floor(255 * AlphaMult))
        end
    end

    for i = 0, Math.PI2, Style.CircleIncr do
        local NextAngle = (i + Style.CircleIncr) > Math.PI2 and 0 or i + Style.CircleIncr

        local P1    = Position + Vector(math.cos(i), math.sin(i), 0) * (Style.CircleSize * SizeMultiplier)
        local P2    = Position + Vector(math.cos(NextAngle), math.sin(NextAngle), 0) * (Style.CircleSize * SizeMultiplier)
        local P3    = Position

        local x1, y1 = P1:to_screen()
        local x2, y2 = P2:to_screen()
        local x3, y3 = P3:to_screen()

        if x1 and x2 and x3 then
            Surface.TriangleFilled(x1, y1, x2, y2, x3, y3, r, g, b, math.floor(Drawing.Alpha * AlphaMult))
        end
    end
end

Math.TickToTime = function (x)
    return Globals.interval_per_tick * x
end

Math.Clamp = function(v, mn, mx)
    return v < mn and mn or v > mx and mx or v
end


Callbacks:add("paint", Drawing.paint)
