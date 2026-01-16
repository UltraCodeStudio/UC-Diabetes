Players = {}

---@class Player : OxClass
---@field source integer
---@field citizenid string
---@field type string
---@field sugarLevel number
Player = lib.class('Player')

CreateThread(function()
    while true do
        Wait(5000)
        for src, player in pairs(Players) do
            print(src, player.citizenid .. " has diabetes type " .. player.type)
        end
    end
end)

function Player:constructor(source, citizenid, dtype)
    self.source = source
    self.citizenid = citizenid
    self.type = dtype or 'none'
    self.sugarLevel = 50

    self:startSugarLoop()
end

function Player:startSugarLoop()
    CreateThread(function()
        while Players[self.source] do
            Wait(5000)

            if self.type ~= 'none' then
                print(self.source .. " sugar=" .. tostring(self.sugarLevel) .. " type=" .. self.type)
                -- tick logic here
            end
        end

        self._loopRunning = false
    end)
end

function Player:setDiabetesTypeLocal(dtype)
    self.type = dtype
end

function Player:setSugarLevelLocal(level)
    self.sugarLevel = level
end


