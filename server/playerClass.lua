Players = {}
---@class Player : OxClass
---@field source integer
---@field citizenid string
---@field type enum('none', 'type1', 'type2')
---@field sugarLevel number
---@field getDiabetesType fun(self: Player): enum('none', 'type1', 'type2')
---@field setDiabetesType fun(self: Player, type: enum('none', 'type1', 'type2'))
local Player = lib.class('Player')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for _, player in ipairs(Players) do
            print(player.citizenid .. " has diabetes type " .. player.type)
        end
    end
end)

function Player:constructor(source, citizenid, type)
    self.source = source
    self.citizenid = citizenid
    self.type = type or 'none'
    self:setSugarLevel(50)
    self:sugarLevelLoop()
    self:setDiabetesType(type)
end

function Player:sugarLevelLoop()
    Citizen.CreateThread(function()
        while self.type ~= 'none' do
            Citizen.Wait(1000) -- Check every minute

            if self.type == 'type1' then
                print(self.source .. "'s sugar level is " .. self.sugarLevel)
                
            elseif self.type == 'type2' then
                -- Logic for Type 2 diabetes sugar level management
            end
        end
    end)
end

function Player:setSugarLevel(level)
    SetSugarLevel(self.source, level)
    self.sugarLevel = level
end

function Player:getSugarLevel()
    self.sugarLevel = GetSugarLevel(self.source)
    return self.sugarLevel
end

function Player:getDiabetesType()
    self.type = GetDiabetesType(self.source)
    return self.type
end

function Player:setDiabetesType(type)
    self.type = type
    if type == 'none' then
        RemovePlayer(self.source)
        return
    end
    SetDiabetesType(self.source, type)

end

function InitPlayer(playerId)
    if Players[playerId] then return end
    local citizenid = GetCitizenid(playerId)
    local diabetesType = GetDiabetesType(playerId)
    Players[playerId] = Player:new(playerId, citizenid, diabetesType)
end

function RemovePlayer(source)
    local player = Players[source]
    if not player then return end
    Players[source] = nil
end


RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    InitPlayer(src)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    for i, player in ipairs(Players) do
        if player.source == src then
            RemovePlayer(src)
            break
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
        -- Re-initialize players on resource start
        for _, playerId in ipairs(GetPlayers()) do
           InitPlayer(playerId)
        end
    end
end)