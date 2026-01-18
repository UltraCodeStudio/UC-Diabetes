---@class Player : OxClass
---@field source integer
---@field citizenid string
---@field type 'none'|'type1'|'type2'
---@field sugarLevel number
Player = lib.class('Player')

local ALLOWED_TYPES = { none = true, type1 = true, type2 = true }

local function normalizeInput(v)
    return tostring(v):lower():gsub("%s+", "")
end

function Player.fetchFromDBByCitizenId(citizenid)
    if not citizenid then return nil end
    return MySQL.single.await(
        'SELECT type, sugarlevel FROM uc_diabetes WHERE citizenid = ?',
        { citizenid }
    )
end

function Player.deleteRowByCitizenId(citizenid)
    if not citizenid then return end
    MySQL.update.await('DELETE FROM uc_diabetes WHERE citizenid = ?', { citizenid })
end

function Player:constructor(source, citizenid, dtype, sugarLevel)
    self.source = source
    self.citizenid = citizenid
    self.type = dtype or 'none'
    self.sugarLevel = tonumber(sugarLevel) or 50
    self:startSugarLoop()
end

function Player:useInsulin()
    if self.sugarLevel <= 0 then
        Notify(self.source, 'UC-Diabetes', 'You are too low on sugar to use insulin.', 'error')
        return
    end
    RemoveItem(Config.ItemNames.insulinPen, 1 ,self.source)
    TriggerClientEvent('UC-diabetes:client:playAnimation', self.source, Config.items.insulin.animation)
    self:setSugarLevel(self.sugarLevel - Config.items.insulin.sugarDecrease)
end

function Player:useEnergyTablet()
    if self.sugarLevel >= 100 then
        Notify(self.source, 'UC-Diabetes', 'You are already at maximum sugar level.', 'error')
        return
    end
    RemoveItem(Config.ItemNames.energyTablet, 1 ,self.source)
    TriggerClientEvent('UC-diabetes:client:playAnimation', self.source, Config.items.energyTablet.animation)
    self:setSugarLevel(self.sugarLevel + Config.items.energyTablet.sugarIncrease)
end

function Player:useBloodSugarMonitor()
    TriggerClientEvent('UC-diabetes:client:playAnimation', self.source, Config.items.bloodSugarMonitor.animation)
    TriggerClientEvent('UC-diabetes:client:playSound', self.source, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
    Notify(self.source, 'UC-Diabetes', 'Your current sugar level is ' .. tostring(self.sugarLevel) .. '%.', 'info')
end

function Player:getSugarDecreaseAmount()
    if self.type == 'type1' then
        return Config.Type1.SugarDecreaseAmount, Config.Type1.SugarDecreaseInterval
    elseif self.type == 'type2' then
        return Config.Type2.SugarDecreaseAmount, Config.Type2.SugarDecreaseInterval
    end
    return 0, 0
end

function Player:applyEffect(start, effect)
    if effect.screenEffect then
        TriggerClientEvent('UC-diabetes:client:applyScreenEffect', self.source, start, effect.screenEffect)
    end
    if effect.walkingSpeed then
        TriggerClientEvent('UC-diabetes:client:setWalkingSpeed', self.source, start, effect.walkingSpeed, effect.animation)
    end
    if effect.healthLoss and start then
        TriggerClientEvent('UC-diabetes:client:applyHealthLoss', self.source, effect.healthLoss)
    end
end

function Player:checkThresholds()
    local sugar = self.sugarLevel

    for name, effect in pairs(Config.Effects) do
        local shouldApply = false
        if name == 'highSugar' then
            shouldApply = sugar >= effect.threshold
        elseif name == 'lowSugar' then
            shouldApply = sugar <= effect.threshold
        end
        if shouldApply then
            Notify(
                self.source,
                'UC-Diabetes',
                ('Sugar level threshold reached: %s%%'):format(effect.threshold),
                'warning'
            )
            self:applyEffect(true, effect)
        else
            self:applyEffect(false, effect)
        end
    end

end

function Player:startSugarLoop()
    CreateThread(function()
        local SugarDecreaseAmount, SugarDecreaseInterval = self:getSugarDecreaseAmount()
        while Players and Players[self.source] do
            Citizen.Wait(SugarDecreaseInterval * 60000)
            if self.type ~= 'none' then
                self:setSugarLevel(self.sugarLevel - SugarDecreaseAmount)
            end
        end
    end)
end

function Player:getDiabetesType()
    return self.type
end

function Player:getSugarLevel()
    return self.sugarLevel
end



function Player:setDiabetesType(dtype)
    dtype = normalizeInput(dtype)

    if not ALLOWED_TYPES[dtype] then
        return false, 'invalid_type'
    end

    self.type = dtype

    if dtype == 'none' then
        Player.deleteRowByCitizenId(self.citizenid)

        if Players then
            Players[self.source] = nil
        end

        return true
    end

    MySQL.insert.await([[
        INSERT INTO uc_diabetes (citizenid, type)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE type = VALUES(type)
    ]], { self.citizenid, dtype })

    return true
end

function Player:setSugarLevel(level)
    level = tonumber(level) or 50

    if level < 0 then level = 0 end
    if level > 100 then level = 100 end

    self.sugarLevel = level
    self:checkThresholds()
    MySQL.insert.await([[
        INSERT INTO uc_diabetes (citizenid, sugarlevel)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE sugarlevel = VALUES(sugarlevel)
    ]], { self.citizenid, level })

    return true
end
