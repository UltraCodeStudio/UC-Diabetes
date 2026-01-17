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

function Player:useInsulin(amount)
    if self.sugarLevel <= 0 then
        Notify(self.source, 'UC-Diabetes', 'You are too low on sugar to use insulin.', 'error')
        return
    end
    self:setSugarLevel(self.sugarLevel - amount)
end

function Player:useEnergyTablet(amount)
    if self.sugarLevel >= 100 then
        Notify(self.source, 'UC-Diabetes', 'You are already at maximum sugar level.', 'error')
        return
    end
    self:setSugarLevel(self.sugarLevel + amount)
end

function Player:startSugarLoop()
    CreateThread(function()
        while Players and Players[self.source] do
            Wait(5000)

            if self.type ~= 'none' then
                print(self.source .. " sugar=" .. tostring(self.sugarLevel) .. " type=" .. self.type)
                local delta = (self.type == 'type1') and -2 or -1
                self:setSugarLevel(self.sugarLevel + delta)
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

    MySQL.insert.await([[
        INSERT INTO uc_diabetes (citizenid, sugarlevel)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE sugarlevel = VALUES(sugarlevel)
    ]], { self.citizenid, level })

    return true
end
