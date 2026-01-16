local function normalizeInput(v)
    return tostring(v):lower():gsub("%s+", "")
end

local function checkTypeInput(dtype)
    local allowed = { type1 = true, type2 = true, none = true }
    return allowed[dtype] == true
end


function SetPlayerDiabetes(playerId, dtype)
    dtype = normalizeInput(dtype)

    local citizenid = GetCitizenid(playerId)
    if not citizenid then return end

    if dtype == 'none' then
        MySQL.update.await("DELETE FROM uc_diabetes WHERE citizenid = ?", { citizenid })
        RemovePlayer(playerId)
        return
    end

    MySQL.insert.await([[
        INSERT INTO uc_diabetes (citizenid, type)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE type = VALUES(type)
    ]], { citizenid, dtype })

    if not Players[playerId] then
        Players[playerId] = Player:new(playerId, citizenid, dtype)
    else
        Players[playerId]:setDiabetesTypeLocal(dtype)
    end
end



function GetDiabetesType(playerId)
    local citizenid = GetCitizenid(playerId)
    if not citizenid then return "none" end

    local row = MySQL.single.await('SELECT type FROM uc_diabetes WHERE citizenid = ?', { citizenid })
    return (row and row.type) or "none"
end


function SetSugarLevel(playerId, sugarLevel)
    local citizenid = GetCitizenid(playerId)
    if not citizenid then return end

    sugarLevel = tonumber(sugarLevel) or 50

    MySQL.insert.await([[
        INSERT INTO uc_diabetes (citizenid, sugarlevel)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE sugarlevel = VALUES(sugarlevel)
    ]], { citizenid, sugarLevel })

    if Players[playerId] then
        Players[playerId]:setSugarLevelLocal(sugarLevel)
    end
end

function GetSugarLevel(playerId)
    local citizenid = GetCitizenid(playerId)
    if not citizenid then return 50 end

    local row = MySQL.single.await('SELECT sugarlevel FROM uc_diabetes WHERE citizenid = ?', { citizenid })
    return (row and row.sugarlevel) or 50
end


function GetSugarLevel(playerId)
    local citizenid = GetCitizenid(playerId)
    local response = MySQL.query.await('SELECT sugarlevel FROM uc_diabetes WHERE citizenid = ?', { citizenid })
    if response[1] then
        return response[1].sugarLevel
    else
        return false
    end
end

lib.addCommand('setdiabetes', {
    help = 'Gives diabetes to a player',
    params = {
        { name = 'target', type = 'playerId', help = 'Target player\'s server id' },
        { name = 'type', type = 'string', help = 'none/type1/type2' },
    },
    restricted = 'group.admin'
}, function(source, args)
    local target = args.target
    local dtype = normalizeInput(args.type)

    if not target or not dtype or not checkTypeInput(dtype) then
        Notify(source, "UC-Diabetes", "Invalid type. Use none/type1/type2", "error")
        return
    end

    SetPlayerDiabetes(target, dtype)

    Notify(source, "UC-Diabetes", ("Set diabetes type to %s for player ID %s"):format(dtype, target), "success")
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    InitPlayer(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    RemovePlayer(source)
end)

function InitPlayer(playerId)
    if Players[playerId] then return end

    local citizenid = GetCitizenid(playerId)
    if not citizenid then return end

    local dtype = GetDiabetesType(playerId) -- DB read
    if dtype == 'none' then return end      -- only create objects for diabetics

    Players[playerId] = Player:new(playerId, citizenid, dtype)
end

function RemovePlayer(playerId)
    local p = Players[playerId]
    if not p then return end

    p.type = 'none'
    Players[playerId] = nil
end
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for _, playerId in ipairs(GetPlayers()) do
        InitPlayer(tonumber(playerId))
    end
end)


------CLASS INTERACTION------
lib.callback.register('UC-diabetes:server:getDiabetesType', function(source)
    return GetDiabetesType(source)
end)



