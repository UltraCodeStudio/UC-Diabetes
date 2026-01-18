function GetCitizenid(src)
    if Config.Integrations.framework == "qbx" then
        local player = exports.qbx_core:GetPlayer(src)
        return player.PlayerData.citizenid
    end
    print("[ERROR] No Framework integration found.")
end

function RemoveItem(item, amount, src)
    if Config.Integrations.inventory == "ox" then
        if exports.ox_inventory:GetItemCount(src, item) <= 0 then
            Notify(src, "UC-Diabetes", "You don't have this item", "error")
            return false
        end
        exports.ox_inventory:RemoveItem(src, item, amount)
        return true
    end
    print("[ERROR] No Inventory integration found.")
end



function Notify(source,title,desc,type)
    if Config.Integrations.notify == "ox" then
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = desc,
            type = type
        })
        return true
    end
    print("[ERROR] No Notify integration found.")
end

