local function checkTypeInput(type)
    local allowed = {"type1", "type2", "none"}
    for _, v in pairs(allowed) do
        if v == type then
            return true
        end
    end
    return false
end

local function normalizeInput(string)
    return tostring(string):lower():gsub("%s+", "")
end

function SetDiabetesType(playerId, diabetesType)
    local citizenid = GetCitizenid(playerId)
    if not citizenid then return end

    diabetesType = normalizeInput(diabetesType)

    if diabetesType == "none" then
        MySQL.update(
            "DELETE FROM uc_diabetes WHERE citizenid = ?",
            { citizenid }
        )
        return
    end

    MySQL.insert([[
        INSERT INTO uc_diabetes (citizenid, type)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE type = VALUES(type)
    ]], { citizenid, diabetesType })
end


function GetDiabetesType(playerId)
    local citizenid = GetCitizenid(playerId)
    local response = MySQL.query.await('SELECT type FROM uc_diabetes WHERE citizenid = ?', { citizenid })
    if response[1] then
        return response[1].type
    else
        return "none"
    end
end

function SetSugarLevel(playerId, sugarLevel)
    local citizenid = GetCitizenid(playerId)
    local sugarLevel = sugarLevel
    MySQL.insert([[
        INSERT INTO uc_diabetes (citizenid, sugarlevel)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE sugarlevel = ?
    ]], { citizenid, sugarLevel, sugarLevel })
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
    local type = normalizeInput(args.type)
    if type and target then

        if not checkTypeInput(type) then
            print("Not a valid diabetes type!")
            return
        end
        
        Players[target]:setDiabetesType(type)
        
        
        
        Notify(source, "UC-Diabetes", "Set diabetes type to "..type.." for player ID "..target, "success")
    end
end)

------Main Loop------
Citizen.CreateThread(function()

end)


------CLASS INTERACTION------
lib.callback.register('UC-diabetes:server:getDiabetesType', function(source)
    return Players[source] and Players[source]:getDiabetesType() or 'none'
end)



