
Players = Players or {}

local function normalizeInput(v)
    return tostring(v):lower():gsub("%s+", "")
end

local function checkTypeInput(dtype)
    local allowed = { type1 = true, type2 = true, none = true }
    return allowed[dtype] == true
end

function InitPlayer(playerId)
    playerId = tonumber(playerId)
    if not playerId or Players[playerId] then return end

    local citizenid = GetCitizenid(playerId)
    if not citizenid then return end

    local row = Player.fetchFromDBByCitizenId(citizenid)
    local dtype = (row and row.type) or 'none'

    if dtype == 'none' then return end 

    Players[playerId] = Player:new(playerId, citizenid, dtype, row and row.sugarlevel)
end

function RemovePlayer(playerId)
    playerId = tonumber(playerId)
    if not playerId then return end
    Players[playerId] = nil
end

function SetPlayerDiabetes(playerId, dtype)
    playerId = tonumber(playerId)
    if not playerId then return end

    dtype = normalizeInput(dtype)

    if not checkTypeInput(dtype) then
        return false, 'invalid_type'
    end

    if Players[playerId] then
        return Players[playerId]:setDiabetesType(dtype)
    end

    local citizenid = GetCitizenid(playerId)
    if not citizenid then return false, 'no_citizenid' end

    if dtype == 'none' then
        Player.deleteRowByCitizenId(citizenid)
        return true
    end

    Players[playerId] = Player:new(playerId, citizenid, dtype, 50)
    return Players[playerId]:setDiabetesType(dtype)
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
        Notify(source, 'UC-Diabetes', 'Invalid type. Use none/type1/type2', 'error')
        return
    end

    local ok, err = SetPlayerDiabetes(target, dtype)
    if not ok then
        Notify(source, 'UC-Diabetes', ('Failed to set diabetes (%s)'):format(err or 'unknown'), 'error')
        return
    end

    Notify(source, 'UC-Diabetes', ('Set diabetes type to %s for player ID %s'):format(dtype, target), 'success')
end)

RegisterNetEvent('UC-diabetes:server:useInsulin', function()
    if Players[source] then
        return Players[source]:useInsulin()
    else
        return Notify(source, 'UC-Diabetes', 'You do not have diabetes.', 'error')
    end
end)

RegisterNetEvent('UC-diabetes:server:useEnergyTablet', function()
    if Players[source] then
        return Players[source]:useEnergyTablet()
    else
        return Notify(source, 'UC-Diabetes', 'You do not have diabetes.', 'error')
    end
end)

RegisterNetEvent('UC-diabetes:server:useBloodSugarMonitor', function()
     if Players[source] then
        return Players[source]:useBloodSugarMonitor()
    else
        return Notify(source, 'UC-Diabetes', 'You do not have diabetes.', 'error')
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    InitPlayer(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    RemovePlayer(source)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for _, playerId in ipairs(GetPlayers()) do
        InitPlayer(tonumber(playerId))
    end
end)

lib.callback.register('UC-diabetes:server:getDiabetesType', function(source)
    if Players[source] then
        return Players[source]:getDiabetesType()
    end
    return 'none'
end)
