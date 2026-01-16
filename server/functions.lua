function GetCitizenid(src)
    local player = exports.qbx_core:GetPlayer(src)
    return player.PlayerData.citizenid
end