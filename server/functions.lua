function GetCitizenid(src)
    local player = exports.qbx_core:GetPlayer(src)
    return player.PlayerData.citizenid
end

function Notify(source,title,desc,type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = title,
        description = desc,
        type = type
    })
end