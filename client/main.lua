
local function playAnim(animationSettings)
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end

    local dict = animationSettings.dict
    local clip = animationSettings.clip
    local duration = animationSettings.duration or 5000
    local flag = animationSettings.flag or 49

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end

    local propEnt
    if animationSettings.prop then
        local model = type(animationSettings.prop) == "string" and animationSettings.prop or animationSettings.prop.model
        local bone  = (animationSettings.prop.bone) or 18905
        local pos   = (animationSettings.prop.pos) or {0.12, 0.03, 0.02}
        local rot   = (animationSettings.prop.rot) or {10.0, 160.0, 10.0}

        local hash = joaat(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(10) end

        local coords = GetEntityCoords(ped)
        propEnt = CreateObject(hash, coords.x, coords.y, coords.z + 0.2, true, true, false)

        AttachEntityToEntity(
            propEnt, ped, GetPedBoneIndex(ped, bone),
            pos[1], pos[2], pos[3],
            rot[1], rot[2], rot[3],
            true, true, false, true, 1, true
        )
    end

    TaskPlayAnim(ped, dict, clip, 8.0, -8.0, duration, flag, 0.0, false, false, false)
    Wait(duration)
    StopAnimTask(ped, dict, clip, 1.0)

    if propEnt and DoesEntityExist(propEnt) then
        DetachEntity(propEnt, true, true)
        DeleteEntity(propEnt)
    end

    RemoveAnimDict(dict)
end

local function PlaySound(name, dict)
    PlaySoundFrontend(-1, name, dict, true)
end

local function setScreenEffect(start ,effectName, duration, loop)
    if start then
        StartScreenEffect(effectName, duration, loop)
        return
    else
        StopScreenEffect(effectName)
    end
end

local function setWalkingSpeed(start, speedMultiplier, animation)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    if start then
        RequestAnimSet(animation)
        while not HasAnimSetLoaded(animation) do
            Wait(0)
        end
        SetPedMovementClipset(ped, animation, 1.0)
    else
        ResetPedMovementClipset(ped, 0.0)
    end
end

local function applyHealthLoss(healthLoss)
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end

    local currentHealth = GetEntityHealth(ped)
    local newHealth = currentHealth - healthLoss
    if newHealth < 0 then newHealth = 0 end

    SetEntityHealth(ped, newHealth)
end



RegisterNetEvent('UC-diabetes:client:useInsulin', function()
   TriggerServerEvent('UC-diabetes:server:useInsulin')
end)

RegisterNetEvent('UC-diabetes:client:useEnergyTablet', function()
   TriggerServerEvent('UC-diabetes:server:useEnergyTablet')
end)

RegisterNetEvent('UC-diabetes:client:useBloodSugarMonitor', function()
   TriggerServerEvent('UC-diabetes:server:useBloodSugarMonitor')
end)

RegisterNetEvent('UC-diabetes:client:playSound', function(name, dict)
   PlaySound(name, dict)
end)

RegisterNetEvent('UC-diabetes:client:applyScreenEffect', function(start, effectName)
    setScreenEffect(start, effectName, 0, true)
end)

RegisterNetEvent('UC-diabetes:client:setWalkingSpeed', function(start, speedMultiplier, animation)
    setWalkingSpeed(start, speedMultiplier, animation)
end)

RegisterNetEvent('UC-diabetes:client:applyHealthLoss', function(healthLoss)
    applyHealthLoss(healthLoss)
end)

RegisterNetEvent('UC-diabetes:client:playAnimation', function(animationSettings)
   playAnim(animationSettings)
end)
