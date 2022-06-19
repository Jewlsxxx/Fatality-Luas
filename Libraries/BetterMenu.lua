local Menu = fatality.menu
local Config = fatality.config

local BetterMenu = 
{
    prefix = nil,
    items = {},
}

BetterMenu.__index = BetterMenu

function BetterMenu.new()
    return setmetatable({items = {}}, BetterMenu)
end

function BetterMenu:init(szName)
    if not szName then
        error("Better Menu! Initialization failed! Nil prefix.", 2)
    end

    self.prefix = szName
    self.items  = {}
end

-- Purpose:
-- Checks if function has sufficient menu placement arguments
local function ArgCheck(szFuncName, szControlName, szTabName, szSubtabName, szGroupName)
    local szStart = string.format("Better Menu! %s. bad argument. ", szFuncName)

    if not szControlName then
        error(szStart .. "Control name expected, got no value", 2)
    end

    if not szTabName then
        error(szStart .. "Tab name expected, got no value", 2)
    end

    if not szSubtabName then
        error(szStart .. "Subtab name expected, got no value", 2)
    end

    if not szGroupName then
        error(szStart .. "Group name expected, got no value", 2)
    end
end

-- Purpose:
-- Checks if there is an item with name already
function BetterMenu:CheckConfig(szFuncName, szName)
    if self.items[szName] then
        error(string.format("Better Menu! %s. tried to create config item with existing name: %s", szFuncName, szName))
    end
end


function BetterMenu:add_checkbox(szName, szTabName, szSubtabName, szGroupName, bDefaultValue, szUserCfgName)
    local szFuncName = "add_checkbox"
    if not self.prefix then
        error(string.format("Better Menu! %s. Prefix is nil. Did you call :init( )?", szFuncName), 2)
    end

    ArgCheck(szFuncName, szName, szTabName, szSubtabName, szGroupName)

    local szCfgName = szUserCfgName or (string.format("%s_%s", self.prefix, szName))
    self:CheckConfig(szFuncName, szCfgName)

    self.items[szCfgName] = Config:add_item(szCfgName, bDefaultValue and 1 or 0)
    Menu:add_checkbox(szName, szTabName, szSubtabName, szGroupName, self.items[szCfgName])
    return self.items[szCfgName]
end

function BetterMenu:add_slider(szName, iMin, iMax, szTabName, szSubtabName, szGroupName, iInitial, flStep, szUserCfgName)
    local szFuncName = "add_slider"
    if not self.prefix then
        error(string.format("Better Menu! %s. Prefix is nil. Did you call :init( )?", szFuncName), 2)
    end

    ArgCheck(szFuncName, szName, szTabName, szSubtabName, szGroupName)

    local szErrorStart = string.format("Better Menu! %s. bad argument.", szFuncName)
    if not iMin then
        error(szErrorStart .. "Min expected, got no value", 2)
    end

    if not iMax then
        error(szErrorStart .. "Min expected, got no value", 2)
    end

    if iMin > iMax then
        error(szErrorStart .. "Min greater than Max", 2)
    end

    local szCfgName = szUserCfgName or (string.format("%s_%s", self.prefix, szName))
    self:CheckConfig(szFuncName, szCfgName)


    self.items[szCfgName] = Config:add_item(szCfgName, iInitial or 0)
    Menu:add_slider(szName, szTabName, szSubtabName, szGroupName, self.items[szCfgName], iMin, iMax, flStep or 1)
    return self.items[szCfgName]
end

function BetterMenu:add_combo(szName, arrItems, szTabName, szSubtabName, szGroupName, iInitial, szUserCfgName)
    
    local szFuncName = "add_combo"
    if not self.prefix then
        error(string.format("Better Menu! %s. Prefix is nil. Did you call :init( )?", szFuncName), 2)
    end

    ArgCheck(szFuncName, szName, szTabName, szSubtabName, szGroupName)

    local szCfgName = szUserCfgName or (string.format("%s_%s", self.prefix, szName))
    self:CheckConfig(szFuncName, szCfgName)

    if type(arrItems) ~= "table" then
        error(string.format("Better Menu! %s. item array is not of type table. Name: %s", szFuncName, szName), 2)
    end

    self.items[szCfgName] = Config:add_item(szCfgName, iInitial or 0)

    local pCombo = Menu:add_combo(szName, szTabName, szSubtabName, szGroupName, self.items[szCfgName])

    for i = 1, #arrItems do
        pCombo:add_item(arrItems[i], self.items[szCfgName])
    end

    return self.items[szCfgName]
end

function BetterMenu:add_multi_combo(szName, arrItems, szTabName, szSubtabName, szGroupName, szUserCfgName)
    local szFuncName = "add_multi_combo"
    if not self.prefix then
        error(string.format("Better Menu! %s. Prefix is nil. Did you call :init( )?", szFuncName), 2)
    end

    ArgCheck(szFuncName, szName, szTabName, szSubtabName, szGroupName)

    local szCfgName = szUserCfgName or (string.format("%s_%s", self.prefix, szName))
    self:CheckConfig(szFuncName, szCfgName)

    if type(arrItems) ~= "table" then
        error(string.format("Better Menu! %s. item array is not of type table. Name: %s", szFuncName, szName), 2)
    end

    -- Config value of multi combo serves no purpose
    local pMultiCombo = Menu:add_multi_combo(szName, szTabName, szSubtabName, szGroupName, Config:add_item(szCfgName .. "_mcombo", 0))
    
    local Ret = {}
    for i = 1, #arrItems do
        local Item = arrItems[i]
        local bTable = type(Item) == "table"

        local szItemName, iInitial = bTable and Item[1] or Item, bTable and (Item[2] and 1) or 0

        local pItemCfg = Config:add_item(string.format("%s_%s", szCfgName, szItemName),  iInitial)
        pMultiCombo:add_item(szItemName, pItemCfg)
        Ret[#Ret + 1] = pItemCfg
    end

    return pMultiCombo, Ret
end

function BetterMenu:add_button(szName, szTabName, szSubtabName, szGroupName, pFunc, szUserCfgName)
    local szFuncName = "add_button"
    if not self.prefix then
        error(string.format("Better Menu! %s. Prefix is nil. Did you call :init( )?", szFuncName), 2)
    end

    ArgCheck(szFuncName, szName, szTabName, szSubtabName, szGroupName)

    local szCfgName = szUserCfgName or (string.format("%s_%s", self.prefix, szName))
    self:CheckConfig(szFuncName, szCfgName)

    if not pFunc then
        error(string.format("Better Menu! %s. bad argument. Function expected got nil. Name: %s", szFuncName, szName), 2)
    end

    return Menu:add_button(szName, szTabName, szSubtabName, szGroupName, pFunc)
end

return BetterMenu.new()
