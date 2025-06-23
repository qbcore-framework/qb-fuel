-- ====================|| VARIABLES || ==================== --

local QBCore = exports['qb-core']:GetCoreObject()
local CurrentPump = nil
local CurrentObjects = { nozzle = nil, rope = nil }
local CurrentVehicle = nil
local Blips = {}

-- ====================|| FUNCTIONS || ==================== --

local loadAnimDict = function (dict)
    if not DoesAnimDictExist(dict) then return end
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(20)
    end
end

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
    local vehFuel = math.floor(exports['qb-fuel']:GetFuel(veh) or 0)

    if canLiter == 0 then return QBCore.Functions.Notify(Lang:t('error.no_fuel_can'), 'error') end
    if vehFuel == 100 then return QBCore.Functions.Notify(Lang:t('error.vehicle_full'), 'error') end

    local liter = canLiter + vehFuel > 100 and 100 - vehFuel or canLiter

    loadAnimDict('timetable@gardener@filling_can')
    TaskPlayAnim(ped, 'timetable@gardener@filling_can', 'gar_ig_5_filling_can', 2.0, 8.0, -1, 50, 0, false, false, false)

    QBCore.Functions.Progressbar('fueling_vehicle', Lang:t('progress.refueling'), Config.RefillTimePerLitre * liter * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('qb-fuel:server:setCanFuel', canLiter - liter)
        SetPedAmmo(ped, `WEAPON_PETROLCAN`, canLiter - liter)
        exports['qb-fuel']:SetFuel(veh, vehFuel + liter)
        QBCore.Functions.Notify(Lang:t('success.refueled'), 'success')
        ClearPedTasks(ped)
    end, function() end)
end

local grabFuelFromPump = function(ent)
    CurrentPump = ent
    if not CurrentPump then return end

	local ped = PlayerPedId()
	local pump = GetEntityCoords(CurrentPump)
    loadAnimDict('anim@am_hold_up@male')
    TaskPlayAnim(ped, 'anim@am_hold_up@male', 'shoplift_high', 2.0, 8.0, -1, 50, 0, false, false, false)
    Wait(300)

    CurrentObjects.nozzle = CreateObject('prop_cs_fuel_nozle', 0, 0, 0, true, true, true)

    AttachEntityToEntity(CurrentObjects.nozzle, ped, GetPedBoneIndex(ped, 0x49D9), 0.11, 0.02, 0.02, -80.0, -90.0, 15.0, true, true, false, true, 1, true)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(0)
    end

    CurrentObjects.rope = AddRope(pump.x, pump.y, pump.z - 1.0, 0.0, 0.0, 0.0, 3.5, 3, 2000.0, 0.0, 2.0, false, false, false, 1.0, true)
    ActivatePhysics(CurrentObjects.rope)
    Wait(50)

    local nozzlePos = GetOffsetFromEntityInWorldCoords(CurrentObjects.nozzle, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(CurrentObjects.rope, CurrentPump, CurrentObjects.nozzle, pump.x, pump.y, pump.z + 1.45, nozzlePos.x, nozzlePos.y + 0.02, nozzlePos.z, 5.0, false, false, '', '')
    LocalPlayer.state:set('hasNozzle', true, true)

    CreateThread(function()
        while DoesRopeExist(CurrentObjects.rope) do
            Wait(500)
            if RopeGetDistanceBetweenEnds(CurrentObjects.rope) > 8.0 then
                QBCore.Functions.Notify(Lang:t('error.too_far'), 'error')
                break
            end
        end

        removeObjects()
    end)
end

local getVehicleCurrentSide = function(veh)
    local pump = CurrentPump
    if not pump or not DoesEntityExist(pump) then return end

    local pumpPos = GetEntityCoords(pump)
    local vehPos = GetEntityCoords(veh)
    local vehForward = GetEntityForwardVector(veh)

    local toPump = {
        x = pumpPos.x - vehPos.x,
        y = pumpPos.y - vehPos.y
    }

    local crossZ = vehForward.x * toPump.y - vehForward.y * toPump.x

    if crossZ > 0 then
        return "left"
    else
        return "right"
    end
end

local nozzleToVehicle = function (veh)
    if getVehicleCurrentSide(veh) ~= 'left' then return QBCore.Functions.Notify(Lang:t('error.wrong_side'), 'error') end

    local isBike = false
    local nozzleModifiedPosition = {
        x = 0.0,
        y = 0.0,
        z = 0.0
    }
    local tankBone = -1
    local vehClass = GetVehicleClass(veh)

    if vehClass == 8 then
        tankBone = GetEntityBoneIndexByName(veh, "petrolcap")
        if tankBone == -1 then
            tankBone = GetEntityBoneIndexByName(veh, "petroltank")
        end
        if tankBone == -1 then
            tankBone = GetEntityBoneIndexByName(veh, "engine")
        end
        isBike = true
    elseif vehClass ~= 13 then
        tankBone = GetEntityBoneIndexByName(veh, "petrolcap")
        if tankBone == -1 then
            tankBone = GetEntityBoneIndexByName(veh, "petroltank_l")
        end
        if tankBone == -1 then
            tankBone = GetEntityBoneIndexByName(veh, "hub_lr")
        end
        if tankBone == -1 then
            tankBone = GetEntityBoneIndexByName(veh, "handle_dside_r")
            nozzleModifiedPosition.x = 0.1
            nozzleModifiedPosition.y = -0.5
            nozzleModifiedPosition.z = -0.6
        end
    end

    local wheelPos = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "wheel_lr"))
    local wheelRPos = GetOffsetFromEntityGivenWorldCoords(veh, wheelPos.x, wheelPos.y, wheelPos.z)

    DetachEntity(CurrentObjects.nozzle, false, true)
    local dimMin, dimMax = GetModelDimensions(GetEntityModel(veh))

    local diff = dimMax.z - wheelRPos.z

    local divisor = (dimMax - dimMin).z < 1.4 and (1.87 * (dimMax - dimMin).z) / 1.24 or (2.7 * (dimMax - dimMin).z) / 2.3
    local zCoords = diff / divisor

    LocalPlayer.state:set('hasNozzle', false, true)

    if isBike then
        AttachEntityToEntity(CurrentObjects.nozzle, veh, tankBone, 0.0 + nozzleModifiedPosition.x, -0.2 + nozzleModifiedPosition.y, 0.2 + nozzleModifiedPosition.z, -80.0, 0.0, 0.0, true, true, false, false, 1, true)
    else
        AttachEntityToEntity(CurrentObjects.nozzle, veh, tankBone, -0.18 + nozzleModifiedPosition.x, 0.0 + nozzleModifiedPosition.y, zCoords, -125.0, -90.0, -90.0, true, true, false, false, 1, true)
    end

    Entity(veh).state:set('nozzleAttached', true, true)
    CurrentVehicle = veh
    FreezeEntityPosition(CurrentObjects.nozzle, true)
    FreezeEntityPosition(CurrentVehicle, true)

    CreateThread((function ()
        while DoesEntityExist(CurrentObjects.nozzle) and DoesEntityExist(CurrentVehicle) and Entity(veh).state.nozzleAttached do
            Wait(1000)
        end

        removeObjects()
    end))
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

    loadAnimDict('timetable@gardener@filling_can')
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
        exports['qb-fuel']:SetFuel(veh, math.floor(exports['qb-fuel']:GetFuel(veh) or 0) + liter)
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
        currentFuel = math.floor(exports['qb-fuel']:GetFuel(veh) or 0),
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

    SendNUIMessage({
        action = 'setLanguage',
        language = GetConvar('qb_locale', 'en')
    })
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