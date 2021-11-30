local Menu              = fatality.menu
local Config            = fatality.config
local Render            = fatality.render
local Callbacks         = fatality.callbacks
local EntityList        = csgo.interface_handler:get_entity_list()
local Globals           = csgo.interface_handler:get_global_vars()
local DebugOverlay      = csgo.interface_handler:get_debug_overlay()
local Success, Vector   = pcall(require, "libs\\vector")
if not Success then
    error("\nMissing vector library. Get it at https://fatality.win/threads/developers-extended-vector-api.9671/ and follow the download guide.")
end

local g_Config = 
{
    pMaster = Config:add_item("Hit effects", 1),
    pStyle  = Config:add_item("Hit effect style", 1),
    pAnim   = Config:add_item("Hit effect duration", 100),
    pSize   = Config:add_item("Hit effect size", 65),
    pColor  = Config:add_item("Hit effect color", 255),
    pAlpha  = Config:add_item("Hit effect alpha", 255),
}

local g_Menu = 
{
    pMaster = Menu:add_checkbox("Hit effects", "VISUALS", "MISC", "Beams", g_Config.pMaster),
    pAnim   = Menu:add_slider("Duration", "VISUALS", "MISC", "Beams", g_Config.pAnim, 1, 400, 1),
    pSize   = Menu:add_slider("Size", "VISUALS", "MISC", "Beams", g_Config.pSize, 1, 100, 1),
    pStyle  = Menu:add_combo("Style", "VISUALS", "MISC", "Beams", g_Config.pStyle),
    pColor  = Menu:add_combo("Color", "VISUALS", "MISC", "Beams", g_Config.pColor),

    pAlpha  = Menu:add_slider("Alpha", "VISUALS", "MISC", "Beams", g_Config.pAlpha, 10, 255, 1),
}

g_Menu.pStyle:add_item("Firework", g_Config.pStyle)
g_Menu.pStyle:add_item("Particle", g_Config.pStyle)

g_Menu.pColor:add_item("White", g_Config.pColor)
g_Menu.pColor:add_item("Red", g_Config.pColor)
g_Menu.pColor:add_item("Red-Orange", g_Config.pColor)
g_Menu.pColor:add_item("Orange", g_Config.pColor)
g_Menu.pColor:add_item("Yellow-Orange", g_Config.pColor)
g_Menu.pColor:add_item("Yellow", g_Config.pColor)
g_Menu.pColor:add_item("Yellow-Green", g_Config.pColor)
g_Menu.pColor:add_item("Green", g_Config.pColor)
g_Menu.pColor:add_item("Green-Blue", g_Config.pColor)
g_Menu.pColor:add_item("Blue", g_Config.pColor)
g_Menu.pColor:add_item("Light Blue", g_Config.pColor)
g_Menu.pColor:add_item("Blue-Purple", g_Config.pColor)
g_Menu.pColor:add_item("Purple", g_Config.pColor)
g_Menu.pColor:add_item("Purple-Red", g_Config.pColor)
g_Menu.pColor:add_item("Pink", g_Config.pColor)


local g_Colors = 
{
    {255, 255, 255},    -- red
    {255, 0, 0},        -- red
    {255, 115, 0},      -- red  orange
    {255, 170, 0},      -- orange
    {255, 211, 0},      -- yellow orange
    {255, 255, 0},      -- yellow
    {160, 240, 0},      -- yellow green
    {0, 205, 0},        -- green
    {50, 175, 175},     -- green blue
    {20, 64, 172},      -- blue
    {129, 159, 235},      -- light blue
    {57, 20, 176},      -- blue purple
    {115, 73, 204},      -- purple
    {205, 2, 98},       -- purple red
    {239, 161, 198},    -- pink
}

local g_Shots = {}
local g_iShotId = 0

local function Ease(x)
    return -(math.cos(math.pi * x) - 1) / 2
end

local function Clamp(v, mn, mx)
    return v < mn and mn or v > mx and mx or v
end

local phi = math.pi * (3. - math.sqrt(5.))
local function g_CalcSphere(iSampleCount, flRadius)
	local aPoints, iAlpha = {}, g_Config.pAlpha:get_int()
	for i = 1, iSampleCount do
		local y = 1 - (i / (iSampleCount - 1)) * 2
		local flRad = math.sqrt(1 - y * y)
		local flTheta = phi * i

		local x = math.cos(flTheta) * flRad
		local z = math.sin(flTheta) * flRad
        local flVar = Clamp(math.random(), 0, 0.3)
		aPoints[#aPoints + 1] =  
        {
            m_vecPosition   = Vector(x * flRadius, y * flRadius, z * flRadius),
            m_vecVariation  = Vector(flVar, flVar, flVar),
            m_flAlpha       = math.floor(math.random() * iAlpha),
        }
	end
	return aPoints
end

local function g_Paint()
    local bMaster       = g_Config.pMaster:get_bool()
    local pLocalPlayer  = EntityList:get_localplayer()
    if not bMaster or not pLocalPlayer then
        g_Shots = {}
        return
    end
    local iAnim = g_Config.pAnim:get_int()
    local aColor = g_Colors[g_Config.pColor:get_int() + 1]
    -- Scale our animtime slider
    local flIncrement = ((1 / ((iAnim * 10) / 1000)) * Globals.frametime)
    for iKey, pShot in pairs(g_Shots) do
        local bFireworkStyle = pShot.m_szStyle == "Firework"
        if pShot.m_flAnimTime >= (bFireworkStyle and 2 or 0.97) then
            g_Shots[iKey] = nil
            goto continue
        end

		pShot.m_flAnimTime = pShot.m_flAnimTime + flIncrement

        for iPointKey = 1, #pShot.m_vecPoints - 1 do
            local pPoint = pShot.m_vecPoints[iPointKey]
			local vecPoint = pPoint.m_vecPosition
			local vecCorrected, flCorrected = pShot.m_vecPosition + vecPoint, pShot.m_flAnimTime
			local vecStatic, vecLerp
			
			if pShot.m_flAnimTime < 1 then
				vecStatic, vecLerp = pShot.m_vecPosition, pShot.m_vecPosition:lerp(vecCorrected, Ease(flCorrected))
			else
				flCorrected = (2 - pShot.m_flAnimTime)
				vecStatic, vecLerp = vecCorrected, pShot.m_vecPosition:lerp(vecCorrected, Ease(1 - flCorrected))
			end

            local pScreen1, pScreen2 = vecStatic:csgo(), vecLerp:csgo()
			if pScreen1:to_screen() and pScreen2:to_screen() then
                local vecVariation = pPoint.m_vecVariation
                local vecColor = Vector(aColor)
                vecColor = (vecColor - (vecColor * vecVariation)):floored()
                if bFireworkStyle then
                    DebugOverlay:add_line_overlay(vecStatic:csgo(), vecLerp:csgo(), csgo.color(vecColor.x, vecColor.y, vecColor.z, math.floor(Ease(flCorrected) * pPoint.m_flAlpha)), true, Globals.frametime * 4)
                else
                    local pUseScreen = pShot.m_flAnimTime > 1 and pScreen1 or pScreen2
                    Render:rect_filled(pUseScreen.x, pUseScreen.y, 2, 2, csgo.color(vecColor.x, vecColor.y, vecColor.z, math.floor(Ease(1 - pShot.m_flAnimTime) * pPoint.m_flAlpha)))
                end
            end
		end
        ::continue::
    end
end

local function g_RegisteredShot(Shot)
    if not g_Config.pMaster:get_bool() or not Shot.victim or not Shot.hurt then
        return
    end
    local iShotId = g_iShotId
    local szStyle = g_Config.pStyle:get_int() == 0 and "Firework" or "Particle"
    g_Shots[iShotId] = {}
    g_Shots[iShotId].m_vecPosition = Vector(Shot.hitpos.x, Shot.hitpos.y, Shot.hitpos.z)
	g_Shots[iShotId].m_flAnimTime = 0
    g_Shots[iShotId].m_szStyle = szStyle
	g_Shots[iShotId].m_vecPoints = g_CalcSphere(szStyle == "Particle" and 150 or 75, g_Config.pSize:get_int())

    g_iShotId = g_iShotId + 1
    if g_iShotId > 150 then 
        g_iShotId = 0 
    end
end

Callbacks:add("paint", g_Paint)
Callbacks:add("registered_shot", g_RegisteredShot)
