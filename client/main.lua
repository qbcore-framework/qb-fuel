-- ====================|| VARIABLES || ==================== --

QBCore = exports['qb-core']:GetCoreObject()
CurrentPump = nil
CurrentObjects = { nozzle = nil, rope = nil }
CurrentVehicle = nil
NozzleBones = { { bone = 'door_dside_r', ped = 'left' }, { bone = 'door_pside_r', ped = 'right' }, { bone = 'door_dside_f', ped = 'left' }, { bone = 'door_pside_f', ped = 'right' },  { bone = 'bonnet' },  { bone = 'boot' } }
Blips = {}

-- ====================|| FUNCTIONS || ==================== --

local removeObjects = function ()
    CurrentPump = nil
    if CurrentVehicle then 
        Entity(CurrentVehicle).state:set('nozzleAttached', false, true)
        FreezeEntityPosition(CurrentVehicle, false)
        CurrentVehicle = nil
    end
    if CurrentObjects.nozzle then
        DeleteEntity(CurrentObjects.nozzle)
        CurrentObjects.nozzle = nil
        ClearPedTasks(PlayerPedId())
    end
    if CurrentObjects.rope then
        DeleteRope(CurrentObjects.rope)
        RopeUnloadTextures()
        CurrentObjects.rope = nil
    end
    LocalPlayer.state:set('hasNozzle', false, true)
end

local refuelVehicle = function (veh)
    if not veh or not DoesEntityExist(veh) then return QBCore.Functions.Notify(Lang:t('error.no_vehicle')) end
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    local canLiter = GetAmmoInPedWeapon(ped, `WEAPON_PETROLCAN`)
    local vehFuel = math.floor(GetFuel(veh) or 0)
    if canLiter == 0 then return QBCore.Functions.Notify(Lang:t('error.no_fuel_can'), 'error') end
    if vehFuel == 100 then return QBCore.Functions.Notify(Lang:t('error.vehicle_full'), 'error') end
    local liter = canLiter + vehFuel > 100 and 100 - vehFuel or canLiter

    QBCore.Functions.LoadAnimDict('timetable@gardener@filling_can')
    TaskPlayAnim(ped, 'timetable@gardener@filling_can', 'gar_ig_5_filling_can', 2.0, 8.0, -1, 50, 0, false, false, false)

    QBCore.Functions.Progressbar('fueling_vehicle', Lang:t('progress.refueling'), Config.RefillTimePerLitre * liter * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('qb-fuel:server:setCanFuel', canLiter - liter)
        SetPedAmmo(ped, `WEAPON_PETROLCAN`, canLiter - liter)
        SetFuel(veh, vehFuel + liter)
        QBCore.Functions.Notify(Lang:t('success.refueled'), 'success')
        ClearPedTasks(ped)
    end, function() end)
end

local grabFuelFromPump = function(ent)
    CurrentPump = ent
    if not CurrentPump then return end
	local ped = PlayerPedId()
	local pump = GetEntityCoords(CurrentPump)
    QBCore.Functions.LoadAnimDict('anim@am_hold_up@male')
    TaskPlayAnim(ped, 'anim@am_hold_up@male', 'shoplift_high', 2.0, 8.0, -1, 50, 0, false, false, false)
    Wait(300)
    CurrentObjects.nozzle = CreateObject('prop_cs_fuel_nozle', 0, 0, 0, true, true, true)
    AttachEntityToEntity(CurrentObjects.nozzle, ped, GetPedBoneIndex(ped, 0x49D9), 0.11, 0.02, 0.02, -80.0, -90.0, 15.0, true, true, false, true, 1, true)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(0)
    end
    CurrentObjects.rope = AddRope(pump.x, pump.y, pump.z - 1.0, 0.0, 0.0, 0.0, 3.0, 3, 50.0, 1.0, 1.0, false, false, false, 0.0, true)
    ActivatePhysics(CurrentObjects.rope)
    Wait(50)
    local nozzlePos = GetOffsetFromEntityInWorldCoords(CurrentObjects.nozzle, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(CurrentObjects.rope, CurrentPump, CurrentObjects.nozzle, pump.x, pump.y, pump.z + 1.45, nozzlePos.x, nozzlePos.y + 0.02, nozzlePos.z   , 5.0, false, false, '', '')
    LocalPlayer.state:set('hasNozzle', true, true)
    
    CreateThread(function()
        while DoesRopeExist(CurrentObjects.rope) do
            Wait(500)
            if RopeGetDistanceBetweenEnds(CurrentObjects.rope) > 8.0 then
                QBCore.Functions.Notify(Lang:t('error.too_far'), 'error')
                removeObjects()
                break
            end
        end
    end)
end

local getPedCurrentSide = function (veh)
    local ped = PlayerPedId()
    local pedPos = (CurrentPump and DoesEntityExist(CurrentPump)) and GetEntityCoords(CurrentPump) or GetEntityCoords(ped)
    local vehPos = GetEntityCoords(veh)
    local vehHeading = GetEntityHeading(veh)
    
    local toPlayer = {
        x = pedPos.x - vehPos.x,
        z = pedPos.z - vehPos.z
    }

    local headingRadians = math.rad(vehHeading)

    local forward = {
        x = math.sin(headingRadians),
        z = math.cos(headingRadians)
    }

    local cross_y = (forward.x * toPlayer.z) - (forward.z * toPlayer.x)

    local THRESHOLD = 0.1

    if cross_y > THRESHOLD then
        return "left"
    elseif cross_y < -THRESHOLD then
        return "right"
    end
    return "left"
end

local getIdealNozzlePosition = function (veh)
    local pedSide = getPedCurrentSide(veh)
    for _, v in pairs(NozzleBones) do
        local boneIndex = GetEntityBoneIndexByName(veh, v.bone)
        if boneIndex ~= -1 then
            if v.ped and v.ped == pedSide then
                return boneIndex, v.bone
            elseif not v.ped then
                return boneIndex, v.bone
            end
        end
    end
    return -1
end

local nozzleToVehicle = function (veh)
    DetachEntity(CurrentObjects.nozzle, false, true)
    LocalPlayer.state:set('hasNozzle', false, true)
    local yRot = getPedCurrentSide(veh) == 'left' and 180.0 or 0.0
    AttachEntityToEntity(CurrentObjects.nozzle, veh, getIdealNozzlePosition(veh), 0.1, -1.5, 0.3, -60.0, yRot + 0.0, 90.0, true, true, false, false, 1, true)
    Entity(veh).state:set('nozzleAttached', true, true)
    CurrentVehicle = veh
    FreezeEntityPosition(CurrentVehicle, true)
end

local refillVehicleFuel = function (liter)
    if not liter then return end
    if QBCore.PlayerData.money[Config.MoneyType] < liter * Config.FuelPrice then return QBCore.Functions.Notify(Lang:t('error.no_money'), 'error') end
    if not CurrentPump then return end
    local veh, dis = QBCore.Functions.GetClosestVehicle()
    if not veh or veh == -1 or not DoesEntityExist(veh) then return QBCore.Functions.Notify(Lang:t('error.no_nozzle'), 'error') end
    if not Entity(veh).state['nozzleAttached'] then return QBCore.Functions.Notify(Lang:t('error.no_nozzle'), 'error') end
    if dis > 5 then return end

    local ped = PlayerPedId()
    ClearPedTasks(ped)
    TaskTurnPedToFaceEntity(ped, veh, 1000)

    TaskGoStraightToCoordRelativeToEntity(ped, CurrentObjects.nozzle, 0.0, 0.0, 0.0, 1.0, 1000)
    Wait(1500)

    QBCore.Functions.LookAtEntity(veh, 5000, 5.0)
    Wait(500)

    QBCore.Functions.LoadAnimDict('timetable@gardener@filling_can')
    TaskPlayAnim(ped, 'timetable@gardener@filling_can', 'gar_ig_5_filling_can', 2.0, 8.0, -1, 50, 0, false, false, false)

    QBCore.Functions.Progressbar('fueling_vehicle', Lang:t('progress.refueling'), Config.RefillTimePerLitre * liter * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        local success = QBCore.Functions.TriggerCallback('qb-fuel:server:refillVehicle', liter)
        if not success then return QBCore.Functions.Notify(Lang:t('error.no_money'), 'error') end
        removeObjects()
        SetFuel(veh, math.floor(GetFuel(veh) or 0) + liter)
        QBCore.Functions.Notify(Lang:t('success.refueled'), 'success')
        ClearPedTasks(ped)
    end, function()
        removeObjects()
    end)
end

local showFuelMenu = function ()
    if not CurrentPump then return end
    local veh, dis = QBCore.Functions.GetClosestVehicle()
    if not veh or veh == -1 then return QBCore.Functions.Notify(Lang:t('error.no_vehicle')) end
    if dis > 5 then return QBCore.Functions.Notify(Lang:t('error.no_vehicle')) end
    SendNUIMessage({
        action = 'show',
        price = Config.FuelPrice,
        currentFuel = math.floor(GetFuel(veh) or 0),
    })
    SetNuiFocus(true, true)
end

local hideFuelMenu = function ()
    SendNUIMessage({
        action = 'hide'
    })
    SetNuiFocus(false, false)
end

local displayBlips = function ()
    for _, station in ipairs(Config.GasStations) do
        local blip = AddBlipForCoord(station.x, station.y, station.z)
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipDisplay(blip, Config.Blip.Display)
        SetBlipAsShortRange(blip, Config.Blip.ShortRange)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blip.Text)
        EndTextCommandSetBlipName(blip)
        Blips[#Blips + 1] = blip
    end
end

local deloadBlips = function ()
    for _, blip in ipairs(Blips) do
        RemoveBlip(blip)
    end
end

local setUpTarget = function ()
    for _, hash in pairs(Config.PumpModels) do
        exports['qb-target']:AddTargetModel(hash, {
            options = {
                {
                    num = 1,
                    icon = 'fa-solid fa-gas-pump',
                    label = Lang:t('target.get_nozzle'),
                    canInteract = function()
                        return CurrentObjects.nozzle == nil
                    end,
                    action = grabFuelFromPump
                },
                {
                    num = 2,
                    icon = 'fa-solid fa-gas-pump',
                    label = Lang:t('target.return_nozzle'),
                    canInteract = function()
                        return LocalPlayer.state['hasNozzle']
                    end,
                    action = removeObjects
                },
                {
                    num = 3,
                    icon = 'fa-solid fa-gas-pump',
                    label = Lang:t('target.put_fuel'),
                    canInteract = function()
                        return CurrentPump ~= nil
                    end,
                    action = showFuelMenu
                },
                {
                    num = 4,
                    type = 'server',
                    event = 'qb-fuel:server:buyJerryCan',
                    icon = 'fa-solid fa-jar',
                    label = Lang:t('target.buy_jerrycan', { price = Config.JerryCanCost }),
                },
                {
                    num = 5,
                    type = 'server',
                    event = 'qb-fuel:server:refillJerryCan',
                    icon = 'fa-solid fa-arrows-rotate',
                    label = Lang:t('target.refill_jerrycan', { price = Config.JerryCanCost }),
                    canInteract = function()
                        return GetSelectedPedWeapon(PlayerPedId()) == `WEAPON_PETROLCAN`
                    end
                }
            },
            distance = 1.5
        })
    end

    exports['qb-target']:AddGlobalVehicle({
        options = {
            {
                num = 1,
                icon = 'fa-solid fa-gas-pump',
                label = Lang:t('target.refill_fuel'),
                action = refuelVehicle,
                canInteract = function()
                    return GetSelectedPedWeapon(PlayerPedId()) == `WEAPON_PETROLCAN`
                end
            },
            {
                num = 2,
                icon = 'fa-solid fa-gas-pump',
                label = Lang:t('target.nozzle_put'),
                action = nozzleToVehicle,
                canInteract = function()
                    return LocalPlayer.state['hasNozzle']
                end
            },
            {
                num = 3,
                icon = 'fa-solid fa-gas-pump',
                label = Lang:t('target.nozzle_remove'),
                action = removeObjects,
                canInteract = function(ent)
                    return Entity(ent).state['nozzleAttached']
                end
            }
        },
        distance = 3
    })
end

local init = function ()
    SetFuelConsumptionState(true)
    SetFuelConsumptionRateMultiplier(Config.GlobalFuelConsumptionMultiplier)

    displayBlips()
    setUpTarget()
end

-- ====================|| NUI CALLBACKS || ==================== --

RegisterNuiCallback('close', function (_, cb)
    hideFuelMenu()
    cb('ok')
end)

RegisterNuiCallback('refill', function (data, cb)
    if not data or not data.liter then return end
    hideFuelMenu()
    refillVehicleFuel(data.liter)
    cb('ok')
end)

-- ====================|| EVENTS || ==================== --

AddEventHandler('onResourceStop', function (res)
    if GetCurrentResourceName() ~= res then return end
    removeObjects()
    deloadBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    removeObjects()
    deloadBlips()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(pData)
    QBCore.PlayerData = pData
end)

-- ====================|| INITIALIZATION || ==================== --

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    init()
end)

CreateThread(function()
    Wait(500) -- Wait for QBCore to load
    if LocalPlayer.state.isLoggedIn then
        init()
    end
end)