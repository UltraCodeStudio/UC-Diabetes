local function checkTypeInput(type)
    local allowed = {"type1", "type2", "none"}
    for _, v in pairs(allowed) do
        if v == type then
            return true
        end
    end
    return false
end

local function setDiabetesType(playerId, type)
    print(playerId)
    local citizenid = GetCitizenid(playerId)
    local diabetesType = type
    MySQL.insert([[
        INSERT INTO uc_diabetes (citizenid, type)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE type = ?
    ]], { citizenid, diabetesType, diabetesType })
end

local function getDiabetesType(playerId)
    local citizenid = GetCitizenid(playerId)
    local response = MySQL.query.await('SELECT type FROM uc_diabetes WHERE citizenid = ?', { citizenid })
    if response[1] then
        return response[1].type
    else
        return "none"
    end
end

lib.addCommand('setdiabetes', {
    help = 'Gives diabetes to a player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'type',
            type = 'string',
            help = 'None/Type1/Type2',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local target = args.target
    local type = string.lower(args.type)
    if type and target then

        if not checkTypeInput(type) then
            print("Not a valid diabetes type!")
            return
        end

        print("Setting diabetes type to: " .. type .. " for player: " .. target)
        setDiabetesType(target, type)
    end
end)

lib.callback.register('UC-diabetes:server:getDiabetesType', function(source)
    return getDiabetesType(source)
end)



