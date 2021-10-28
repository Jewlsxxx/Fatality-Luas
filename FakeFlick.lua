local Menu              = fatality.menu
local Input             = fatality.input
local Render            = fatality.render
local Callbacks         = fatality.callbacks
local EntityList        = csgo.interface_handler:get_entity_list()
local Globals           = csgo.interface_handler:get_global_vars()

-- This is the key you hold to flick
local Key = 0x4
-- This is the key you press to toggle the side
local InvertKey = 0x05

-- https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

local References = 
{
    DoubleTap       = Menu:get_reference("Rage", "Aimbot", "Aimbot", "Double tap");
    Jitter          = Menu:get_reference("Rage", "Anti-Aim", "General", "Jitter");
    AAOverride      = Menu:get_reference("Rage", "Anti-Aim", "General", "Antiaim override");
    YawAddCheck     = Menu:get_reference("Rage", "Anti-Aim", "General", "Yaw add");
    YawAdd          = Menu:get_reference("Rage", "Anti-Aim", "General", "Add");
    FakeType        = Menu:get_reference("Rage", "Anti-Aim", "General", "Fake type");
    FakeAmt         = Menu:get_reference("Rage", "Anti-Aim", "General", "Fake amount");
    FreeStandFake   = Menu:get_reference("Rage", "Anti-Aim", "General", "Freestand Fake");
}
local PrevStates = {}

local MenuTypes = 
{
    YawAdd = "int";
    FakeType = "int";
    FakeAmt = "int";
    FreeStandFake = "int"
}

local ResetStates = false

local Keys = {}

local IndFont = Render:create_font("verdana", 28, 900, true);

local function OnPaint()
    -- From my gui
    for i = 0x1, 0xFE do
        if not Keys[i] then
            Keys[i] = {}
        end
        local IsKeyDown     = Input:is_key_down(i);
        Keys[i].Pressed     = Keys[i].Held ~= nil and (not Keys[i].Held and IsKeyDown)
        Keys[i].Held        = Keys[i].Held == nil and false or IsKeyDown
        Keys[i].Released    = Keys[i].OldHeld and not Keys[i].Held
        Keys[i].OldHeld     = Keys[i].Held
        if Keys[i].Pressed then 
            if Keys[i].Toggled  == nil then
                Keys[i].Toggled = true
            else
                Keys[i].Toggled = not Keys[i].Toggled
            end
        end
    end

    if not EntityList:get_localplayer() then
        ResetStates = true
        return end

    local TickcountModulo  = Globals.tickcount % 17
    local ScreenSize    = Render:screen_size()
    local ScreenHalf    = {ScreenSize.x / 2, ScreenSize.y / 2}

    local EPeekFreestand = Keys[Key].Held
    local Invert         = Keys[InvertKey].Toggled

    if EPeekFreestand then
        ResetStates = true
        References.DoubleTap:set_bool(true)
        References.YawAddCheck:set_bool(true)
        References.AAOverride:set_bool(false)
        References.Jitter:set_bool(false)
        References.FakeType:set_int(2)
        References.FakeAmt:set_int(-100)
        References.FreeStandFake:set_int(0)

        if TickcountModulo == 15 then
            References.YawAdd:set_int(Invert and -90 or 90)
        else
            References.YawAdd:set_int(0)
        end

        local LowAlphaBlack = csgo.color( 0, 0, 0, 100)
        local Blue          = csgo.color( 17, 152, 199, 255)

        local Ind = "PEEK"
        local IndSize = Render:text_size(IndFont, Ind)
        local IndPos = {10, 649 - IndSize.y - 12}
        Render:text(IndFont, IndPos[1], IndPos[2], Ind, Blue)
        Render:rect_filled(IndPos[1], IndPos[2] + IndSize.y, IndSize.x, 4, LowAlphaBlack)
        Render:rect_filled(IndPos[1] + 1, IndPos[2] + IndSize.y + 1, (IndSize.x * (TickcountModulo / 17)) - 1, 2, Blue)

        local SideHeight = 15
        local SideSpacing = 15
        local SidePos = {ScreenHalf[1] - SideSpacing, ScreenHalf[2] - SideHeight / 2 + 1}
        Render:rect_filled(SidePos[1], SidePos[2], 2, SideHeight,  LowAlphaBlack)
        Render:rect_filled(SidePos[1] + SideSpacing * 2, SidePos[2], 2, SideHeight,  LowAlphaBlack)

        Render:rect_filled(SidePos[1] + (SideSpacing * (Invert and 0 or 2)), SidePos[2], 2, SideHeight, Blue)
    else
        if ResetStates then
            for i, v in pairs(References) do
                if PrevStates[i] then
                    if MenuTypes[i] == "int" then
                        References[i]:set_int(PrevStates[i])
                    else
                        References[i]:set_bool(PrevStates[i])
                    end
                end
            end
            ResetStates = false
        else
            for i, v in pairs(References) do
                if MenuTypes[i] == "int" then
                    PrevStates[i] = References[i]:get_int()
                else
                    PrevStates[i] = References[i]:get_bool()
                end
            end
        end
    end
end

Callbacks:add("paint", OnPaint)
