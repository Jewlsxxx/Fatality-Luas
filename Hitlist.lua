-- Capture any funtions / classes / objects
local Menu              = fatality.menu
local Config            = fatality.config
local Input             = fatality.input
local Renderer          = fatality.render
local Callbacks         = fatality.callbacks
local Math              = fatality.math
local EntityList        = csgo.interface_handler:get_entity_list()
local Globals           = csgo.interface_handler:get_global_vars()
local Console           = csgo.interface_handler:get_cvar()
local Events            = csgo.interface_handler:get_events()
local Engine            = csgo.interface_handler:get_engine_client()
local Vector            = csgo.vector3
local Vector2D          = csgo.vector2

-- Wrapper for csgo.color
local function Color(r, g, b, a)
    return csgo.color(r and r or 255, g and g or 255, b and b or 255, a and a or 255)
end

-- Returns a table used for combo config item and name
local function ComboContainer(Name, DefaultValue)
    return
    {
        Name = Name,
        ConfigItem = Config:add_item("Hitlist " .. Name, DefaultValue and DefaultValue or 0)
    }
end

-- Re-define the lua function print() to do what we want
local function Print(Text, Col)
    Console:print_console("[Hitlist] \0", Color(208, 5, 70))
    Console:print_console(Text .. "\n", Col and Col or Color(255, 255, 255, 255))
end

-- Fatality colors
local Colors =
{
    Grab            = Color(38, 33, 72); -- Color of the grab area`
    GradientLeft    = Color(55, 39, 180);-- Color of the left gradient
    GradientRight   = Color(171, 7, 74); -- Color of the right gradient
    GradientCenter  = Color(109, 27, 133); -- Color of the center gradient
    Border          = Color(62, 56, 93); -- Color of the border
    TabUnderline    = Color(208, 5, 70); -- Color of the line under selected tab
    EffectPink      = Color(255, 0, 72); -- Color of pink in glitch effect
    EffectBlue      = Color(50, 52, 255);-- Color of blue in glitch effect
    Background      = Color(13, 11, 32); -- Color of the background
    GroupBackgrund  = Color(30, 22, 54); -- Color of the second background layer

}

-- Hitlist visual data
local Hitlist = 
{
    FileName    = "Fatality Hitlist By Jewls";
    Position    = Vector2D(Renderer:screen_size().x * 0.5, 30);
    OldPositon  = Vector2D(Renderer:screen_size().x * 0.5, 30);
    
    ScreenSize  = Renderer:screen_size(),
    OldScreeenSize  = Vector2D(-1, -1),
    PositionTimerWait = 0.5;        -- How long it will wait in seconds to save position
    PositionSaveTimer = 0;          -- Used to count down to save position every now and then
    PositionWaitState = false;      -- Used to save once
    GradientAnimTime  = 1;
    GradientSwitch    = false;
    GradientWait      = 6;
    FirstUsableItem   = nil;
    BackgroundSpacing = 5;          -- Used to space the info out on the y to fit another background layer it
    ItemNameSizes = {};
    MaxData     = 10;
    GlitchAnimTime = 0;
    GlitchAnimWait = 0.2;
    GlitchSwitch = false;
    GlithInfoWait =  5;
    GrabOffset  = Vector2D(0, 0);
    Held        = false;
    ClickedOff = false;
}

-- Container for fonts to be refrenced later
local Fonts = {}

-- Container for our config values to be referenced later
local ConfigValues = 
{
    Toggle  = Config:add_item("Hitlist Toggle", 0);
    HitOnly = Config:add_item("Hitlist Hit Only Glitch", 0),
    Console = Config:add_item("Hitlist Console Log", 0);
    Combo   = Config:add_item("Hitlist Combo", 0);
    Items   = 
    {
        -- Used to create config items and addd to mutli combo
        -- If you want to add to this all you have to do is copy one of these, change the name, and place it where you want. It goes in order. Then ctrl + f this to get to the next part (awjndlkjawjkdbnajklwbndjalbwjkdbwak)
        -- Format Name, inital value. If empty value will be 0
        ComboContainer("Shot");
        ComboContainer("Player", 1);
        ComboContainer("Targeted", 1);
        ComboContainer("Hit", 1);
        ComboContainer("Hitchance", 1);
        ComboContainer("Pred. Dmg", 1);
        ComboContainer("Damage", 1);
        ComboContainer("Backtrack", 1);
        ComboContainer("Break LC");
        ComboContainer("Delayed");
        ComboContainer("Miss Reason", 1);
    };
}

local MenuValues = 
{
    Toggle  = Menu:add_checkbox("Hitlist", "visuals", "misc", "various", ConfigValues["Toggle"]);
    HitOnly = Menu:add_checkbox("Only Glitch On Hit", "visuals", "misc", "various", ConfigValues["HitOnly"]);
    Console = Menu:add_checkbox("Console Log", "visuals", "misc", "various", ConfigValues["Console"]);
    Items   = Menu:add_multi_combo( "Items", "visuals", "misc", "various", ConfigValues["Combo"]);
}

-- Will be filled with shot information
local HitlistData = {}

local function UpdateDpi()
    local Scale = Hitlist.ScreenSize.x / 1920

    Hitlist.ItemSpacing = Vector2D(math.floor(20 * Scale), math.floor(3 * Scale));
    Hitlist.Padding     = Vector2D(math.floor(5 * Scale), math.floor(5 * Scale));
    Hitlist.BackgroundSpacing = math.floor(5 * Scale)
    Fonts.Verdana       =  Renderer:create_font("verdana", math.floor(12 * Scale), 400, false );
end

-- Called when local player is nil or a new round has started
local function ClearData()
    HitlistData = {}
end

-- Called when the lua is loaded
local function Initalize()
    UpdateDpi()
    for i = 1, #ConfigValues["Items"] do
        local CurrentItem = ConfigValues["Items"][i]
        Hitlist["ItemNameSizes"][i] = Renderer:text_size(Fonts["Verdana"], CurrentItem.Name) --Only need to get theses one time
        MenuValues["Items"]:add_item(CurrentItem.Name, CurrentItem.ConfigItem) --Add all of our items to our combo
    end
    local FileTable = {}
    local File, Error = loadfile(Hitlist["FileName"] .. ".cfg", "t", FileTable) --Load file name
    if File then -- Check if file was found
        File() -- Run chunk
        Hitlist["Position"] = FileTable.Position -- Set our position to last save
        Print("Welcome back") -- Greet user
    else -- File was not found or there was an error
        local File = io.open(Hitlist["FileName"] .. ".cfg",'w') -- Write to file name
        File:write(string.format("Position = { \n x = %i,\n y = %i, }", Renderer:screen_size().x * 0.5, 30)) -- Set an inital value
        File:close()
        Print("Hello first time user") -- Greet user
    end
end



-- Returns table of config indexes
local function GetUseableItems()
    Hitlist["FirstUsableItem"] = nil
    local ReturnValue = {}
    for i = 1, #ConfigValues["Items"] do
        -- Item is active add the index to the return value
        if ConfigValues["Items"][i].ConfigItem:get_bool() then
            if not Hitlist["FirstUsableItem"] then
                Hitlist["FirstUsableItem"] = ConfigValues["Items"][i].Name
            end
            ReturnValue[#ReturnValue + 1] = i
        end
    end
    -- If we have no items return nil for saftey check
    return #ReturnValue > 0 and ReturnValue or nil
end

local function CalculateHitlistWidth()
    local UseableItems = GetUseableItems();
    -- Get useable items. If non return 0
    if not UseableItems then
        return 0 end
    
    local Width = 0;
    -- Loop through usable items and add name size and spacing to width
    for i = 1, #UseableItems do
        Width = Width + Hitlist["ItemNameSizes"][UseableItems[i]].x + (Hitlist["ItemSpacing"].x * 2) -- ItemSpacing + Text Size + Item Spacing
    end
    return Width
end

local function HitgroupIDToText(Index)
    if Index == 1 then
        return 'Head'
    elseif Index == 2 then
        return 'Chest'
    elseif Index == 3 then
        return 'Stomach'
    elseif Index == 4 or Index == 5 then
        return 'Arms'
    elseif Index == 6 or Index == 7 then
        return 'Legs'
    end
    return '-'
end

local function FormatMissReason(Shot)
    if not EntityList:get_localplayer():is_alive() then
        return "Death"
    end
    if Shot.hurt then -- We hit the player
        return "-"
    elseif not Shot.hurt and Shot.hit then -- Didnt hit the player but impact intersects player
        return "?"
    elseif not Shot.hit then -- Impact doesnt intersect player. we missed due to spread
        if not EntityList:get_player(Shot.victim):is_alive() then
            return "Death"
        end
        return "Spread"
    end
    return "-" -- Fallback
end

local function CheckNameLength(Name)
    if #Name > 7 then
        return string.format("%s..", Name:sub(1, 7))
    end
    return Name
end

local function IsPointInBounds(Point, Min, Max)
    return Point.x >= Min.x and Point.x <= Max.x and Point.y >= Min.y and Point.y <= Max.y;
end

local function Clamp(Value, Min, Max)
    return Value < Min and Min or (Value > Max and Max or Value)
end

local function SavePosition()
    -- Calculate increment
    local Increment = ((1 / Hitlist["PositionTimerWait"]) * Globals.frametime)

    -- If our position has changed reset the timer, state, and set old position to current position
    if (Hitlist["Position"].x ~= Hitlist["OldPositon"].x or Hitlist["Position"].y ~= Hitlist["OldPositon"].y) then 
        Hitlist["PositionSaveTimer"] = 1
        Hitlist["PositionWaitState"] = true
        Hitlist["OldPositon"] = Hitlist["Position"]
    end

    -- Increment the timer so we dont write to file 30000 times in 1 second
    Hitlist["PositionSaveTimer"] = Clamp(Hitlist["PositionSaveTimer"] - Increment, 0, 1)

    if ( Hitlist["PositionSaveTimer"] == 0 and Hitlist["PositionWaitState"]) then -- Our time is done and state is ready to go
        Hitlist["PositionWaitState"] = false; -- Reset state
        local File = io.open(Hitlist["FileName"] .. ".cfg",'w')
        -- Format file to table
        File:write(string.format("Position = { \n x = %i,\n y = %i, }", Hitlist["Position"].x, Hitlist["Position"].y)) 
        File:close()
    end
end

local function HandleMovement(Width)
    local CursorPos = Input:get_mouse_pos()
    local Min = Hitlist["Position"]
    local ySizeOffset = (Hitlist["ItemNameSizes"][1].y + (Hitlist["ItemSpacing"].y * 2) + 3)
    local Max = Vector2D(Min.x + Width, Min.y + ySizeOffset)
    if Input:is_key_down(0x1) then
        -- Check whether we are in bounds or was in bounds when we clicked
        -- This fixes the issue where you stop dragging if you move to fast
        local PointInBounds = IsPointInBounds(CursorPos, Min, Max)

        -- Check if point is out of bounds and we are not already dragging
        if not PointInBounds and not Hitlist["Held"] then
            Hitlist["ClickedOff"] = true;
        end
        
        -- If this click was off the hitlist then dont run any movement
        if Hitlist["ClickedOff"] then
            goto continue end

        if (PointInBounds or Hitlist["Held"]) then
            if not Hitlist["Held"] then
                Hitlist["GrabOffset"] = Vector2D(CursorPos.x - Min.x, CursorPos.y - Min.y) -- We arent holding aka first click. Set our grab delta
            end
            -- We are holding now
            Hitlist["Held"] = true 
            -- Move position based of grab delta
            Hitlist["Position"] = Vector2D(CursorPos.x - Hitlist["GrabOffset"].x, CursorPos.y - Hitlist["GrabOffset"].y)
        end
        ::continue::
    else
        -- We are no longer pressing mouse one stop holding
        Hitlist["Held"] = false
        Hitlist["ClickedOff"] = false;
    end
    -- Clamp out position. Stay on screen!!!
    local ScreenSize = Renderer:screen_size()
    Hitlist["Position"].x = Clamp( Hitlist["Position"].x, 0, ScreenSize.x - Width)
    Hitlist["Position"].y = Clamp( Hitlist["Position"].y, 0, ScreenSize.y - ySizeOffset)

end

-- Called every frame
local function OnPaint()
    if not ConfigValues["Toggle"]:get_bool() then
        return end
    
    if not EntityList:get_localplayer() then
        -- Our local player is nil (most likely not in game) clear data
        ClearData()
    end
    
    Hitlist.ScreenSize = Renderer:screen_size()

    if Hitlist.OldScreeenSize.x ~= Hitlist.ScreenSize.x or Hitlist.OldScreeenSize.y ~= Hitlist.ScreenSize.y then
        UpdateDpi()
        Hitlist.OldScreeenSize = Hitlist.ScreenSize
    end


    local UseableItems = GetUseableItems();
    -- We have no items to render
    if not UseableItems then
        return end

    local HitlistWidth = CalculateHitlistWidth();
    -- Should never happen (fail safe)
    if HitlistWidth == 0 then
        return end
    
    -- Check our position saving state
    SavePosition() 
    -- Handle hitlist movement
    HandleMovement(HitlistWidth)

    -- Calculate increment
    local GradientIncrement = ((1 / Hitlist["GradientWait"]) * Globals.frametime) 

    Hitlist["GradientAnimTime"] = Clamp(Hitlist["GradientAnimTime"] + (Hitlist["GradientSwitch"] and GradientIncrement or -GradientIncrement), 0.6, 1) -- Clamp animtime to wanted alphas
    if Hitlist["GradientAnimTime"] == 0.6 then -- Switch when at alpha
        Hitlist["GradientSwitch"] = true
    elseif Hitlist["GradientAnimTime"] == 1 then
        Hitlist["GradientSwitch"] = false
    end

    local GlitchIncrement = ((1 / Hitlist["GlitchAnimWait"]) * Globals.frametime) 

    Hitlist["GlitchAnimTime"] = Clamp(Hitlist["GlitchAnimTime"] + (Hitlist["GlitchSwitch"] and GlitchIncrement or -GlitchIncrement), 0, 1) -- Clamp animtime to wanted alphas
    if Hitlist["GlitchAnimTime"] == 0 then -- Switch when at alpha
        Hitlist["GlitchSwitch"] = true
    elseif Hitlist["GlitchAnimTime"] == 1 then
        Hitlist["GlitchSwitch"] = false
    end

    local GradientAlpha       = math.floor(255 * Hitlist["GradientAnimTime"])
    Colors["GradientLeft"]    = Color(55, 39, 180, GradientAlpha);  -- Color of the left gradient
    Colors["GradientRight"]   = Color(171, 7, 74, GradientAlpha);   -- Color of the right gradient
    Colors["GradientCenter"]  = Color(109, 27, 133, GradientAlpha); -- Color of the center gradient

    local Position = Hitlist["Position"]
    local TextSpacing = Hitlist["ItemNameSizes"][1].y + (Hitlist["ItemSpacing"].y * 2) -- ItemSpacing.y + TextSize.y + ItemSpacing.y
    local ItemHeight = TextSpacing + 3 -- Will always at least be this tall to fit our elements

    Renderer:rect_filled(Position.x, Position.y, HitlistWidth, ItemHeight, Colors["Grab"]) -- Rectangle at very top that is behind item names
    Renderer:rect_fade(Position.x, Position.y + TextSpacing, HitlistWidth / 2, 2, Colors["GradientLeft"], Colors["GradientCenter"], true )
    Renderer:rect_fade(Position.x + HitlistWidth / 2, Position.y + TextSpacing, HitlistWidth / 2, 2, Colors["GradientCenter"], Colors["GradientRight"], true )

    if #HitlistData > 0 then 
        Renderer:rect_fade(Position.x, Position.y + TextSpacing + 2, HitlistWidth, 6, Color(0, 0, 0, 255), Color(0, 0, 0, 50), false ) -- Black gradient 
        -- Clamp our height so we can only hold so many items
        local Height = Clamp(#HitlistData, 0, Hitlist["MaxData"]) * TextSpacing
        Renderer:rect_filled(Position.x, Position.y + TextSpacing + 2, HitlistWidth, Height + Hitlist["BackgroundSpacing"] * 2, Colors["Background"]) -- Back background
        Renderer:rect_filled(Position.x + Hitlist["Padding"].x, Position.y + TextSpacing + 2 + Hitlist["Padding"].y, HitlistWidth - Hitlist["Padding"].x * 2, Height + Hitlist["BackgroundSpacing"] * 2 - Hitlist["Padding"].y * 2, Colors["GroupBackgrund"]) -- Upper background
        Renderer:rect(Position.x + Hitlist["Padding"].x, Position.y + TextSpacing + 2 + Hitlist["Padding"].y, HitlistWidth - Hitlist["Padding"].x * 2, Height + Hitlist["BackgroundSpacing"] * 2 - Hitlist["Padding"].y * 2, Colors["Border"]) -- Upper background border
    end

    Renderer:rect(Position.x - 1, Position.y - 1, HitlistWidth + 1, ItemHeight + (Clamp(#HitlistData, 0, Hitlist["MaxData"]) * TextSpacing) + (#HitlistData == 0 and 1 or 1 + (Hitlist["BackgroundSpacing"] * 2)), Colors["Border"]) --Full border
    local TextOffset = 0
    -- Loop through all the items we have selected

    for i = 1, #UseableItems do
        local Index = UseableItems[i]
        local ItemName = ConfigValues["Items"][Index].Name
        local CenterPosition = Vector2D(Position.x + TextOffset + (Hitlist["ItemNameSizes"][Index].x / 2 + Hitlist["ItemSpacing"].x), Position.y + (Hitlist["ItemNameSizes"][1].y + (Hitlist["ItemSpacing"].y * 2)) / 2)

        -- Render the name of the info (Index, Player, ect)
        local OffPosAmnt = 1
        local ItemPos = Vector2D(CenterPosition.x - (Hitlist["ItemNameSizes"][Index].x / 2), CenterPosition.y - (Hitlist["ItemNameSizes"][Index].y / 2))

        local Move =  (OffPosAmnt * 2) * Hitlist["GlitchAnimTime"]
        local Move2 =  (OffPosAmnt * 2) * (1 - Hitlist["GlitchAnimTime"])

        Renderer:text(Fonts.Verdana, ItemPos.x - OffPosAmnt + Move, ItemPos.y + OffPosAmnt - Move, ItemName, Colors["EffectPink"] )
        Renderer:text(Fonts.Verdana, ItemPos.x - OffPosAmnt + Move2, ItemPos.y + OffPosAmnt - Move2, ItemName, Colors["EffectBlue"] )


        Renderer:text(Fonts.Verdana, ItemPos.x, ItemPos.y, ItemName, Color(255, 255, 255, 255) )
        
        if i ~= 1 then
            -- If it isnt the first info element render a spacer at the seperating point
            Renderer:rect_filled(Position.x + TextOffset, Position.y + Hitlist["ItemSpacing"].y, 1, TextSpacing - Hitlist["ItemSpacing"].y * 2, Color(255, 255, 255, 100))
        end

        -- Draw the info value
        for j = 1, #HitlistData do
            if (#HitlistData - j >= Hitlist["MaxData"]) then
                goto continue end
            if ItemName == Hitlist["FirstUsableItem"] then
                if HitlistData[j].Missed then
                    Renderer:rect_filled( Position.x + Hitlist["Padding"].x, Position.y + Hitlist["Padding"].y + 2 + TextSpacing * (#HitlistData + 1 - j), 1, TextSpacing, Colors["TabUnderline"])
                end
                HitlistData[j]["GlitchTime"] = Clamp(HitlistData[j]["GlitchTime"] - ((1 / Hitlist["GlithInfoWait"]) * Globals.frametime), 0, 1) -- Increment timer if this is our first item (so we only do it once per frame)
            end
            local Text = HitlistData[j][ItemName]
            local TextSize = Renderer:text_size(Fonts.Verdana, Text)
            -- Make sure we arent over our set max

            if HitlistData[j]["GlitchTime"] > 0 then
                if ConfigValues["HitOnly"]:get_bool() and HitlistData[j]["Missed"] then
                    goto skip end
                Renderer:text(Fonts.Verdana, CenterPosition.x - (TextSize.x / 2) - OffPosAmnt + Move, 1 + Hitlist["BackgroundSpacing"] + CenterPosition.y - (Hitlist["ItemNameSizes"][Index].y / 2) + TextSpacing * (#HitlistData + 1 - j) + OffPosAmnt - Move, HitlistData[j][ItemName], Colors["EffectPink"] )
                Renderer:text(Fonts.Verdana, CenterPosition.x - (TextSize.x / 2) - OffPosAmnt + Move2, 1 + Hitlist["BackgroundSpacing"] + CenterPosition.y - (Hitlist["ItemNameSizes"][Index].y / 2) + TextSpacing * (#HitlistData + 1 - j) + OffPosAmnt - Move2, HitlistData[j][ItemName], Colors["EffectBlue"] )
                ::skip::
            end
            
            Renderer:text(Fonts.Verdana, CenterPosition.x - (TextSize.x / 2), 1 + Hitlist["BackgroundSpacing"] + CenterPosition.y - (Hitlist["ItemNameSizes"][Index].y / 2) + TextSpacing * (#HitlistData + 1 - j), HitlistData[j][ItemName], Color(255, 255, 255, 255) )
            ::continue::
        end
        -- Add to our offset
        TextOffset = TextOffset + (Hitlist["ItemNameSizes"][Index].x + (Hitlist["ItemSpacing"].x * 2))
    end
end

-- Called when the server registers a shot
local function OnRegisteredShot(Shot)

    local Player = EntityList:get_player(Shot.victim)
    if not Player then
        return end

    local ShotInfo = Shot.shot_info
    HitlistData[#HitlistData + 1] =
    {
        Shot = #HitlistData + 1,
        Player = CheckNameLength(Player:get_name()),
        Targeted = HitgroupIDToText(Shot.target_hitgroup),
        Hit = HitgroupIDToText(Shot.hit_hitgroup),
        Hitchance = string.format("%.0f%s", Shot.hitchance, "%"),
        ["Pred. Dmg"] = Shot.target_damage == -1 and "-" or Shot.target_damage,
        Damage = Shot.hurt and Shot.hit_damage or "-",
        Backtrack = string.format("%it", ShotInfo.backtrack_ticks),
        ["Miss Reason"] = FormatMissReason(Shot),
        ["Break LC"] = ShotInfo.breaking_lc and "True" or "False",
        Delayed = ShotInfo.delayed_shot and "True" or "False",
        Missed = not Shot.hurt;
        GlitchTime = 1;
        -- awjndlkjawjkdbnajklwbndjalbwjkdbwak
        -- place an element in here with the same name of ur element. if it has a space do it like this ["element name"] = ...
        -- example MyElement = shot.some_info the hitlist will update to it because it is fully dynamic
    }
    if ConfigValues["Console"]:get_bool() then
        local HasValue = false
        local LastViableName = -1
        -- Pretty shitty way to do this but itll work
        for i = 1, #ConfigValues["Items"] do
            if ConfigValues["Items"][i].ConfigItem:get_bool() then
                HasValue = true
                LastViableName = ConfigValues["Items"][i].Name
            end
        end
        if not HasValue then
            return end
        Console:print_console("[Hitlist] \0", Colors["TabUnderline"])
        for i = 1, #ConfigValues["Items"] do
            local ConfigValue = ConfigValues["Items"][i]
            if ConfigValue.ConfigItem:get_bool() then
                local Value = tostring(HitlistData[#HitlistData][ConfigValue.Name])
                if Value:sub(#Value , #Value) == "%" then 
                    Value = Value:sub(0, #Value - 1)
                end
                --print( Value:sub(#Value, #Value))
                Console:print_console(ConfigValue.Name .. " \0", Color())
                Console:print_console(Value, Colors['TabUnderline'])
                if not (ConfigValue.Name == LastViableName) then
                    Console:print_console(" \0", Color())
                else
                    Console:print_console(" \n", Color())
                end
            end
        end
    end
end

-- Called when an event is triggered (Game events: https://wiki.alliedmods.net/Counter-Strike:_Global_Offensive_Events)
local function GameEvents(Event)
    local EventName = Event:get_name()
    if EventName == "round_start" then
        ClearData()
    end
end

-- Initalize the lua
Initalize()
-- Add Events
Events:add_event("round_start")
-- Set up callbacks
Callbacks:add("registered_shot", OnRegisteredShot)
Callbacks:add("events", GameEvents)
Callbacks:add("paint", OnPaint)
