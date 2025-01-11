-- ====================|| VARIABLES || ==================== --

QBCore = exports['qb-core']:GetCoreObject()
CurrentPump = nil
CurrentObjects = { nozzle = nil, rope = nil }
-- ====================|| FUNCTIONS || ==================== --

local grabFuelFromPump = function()
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
    RopeLoadTextures()
    while not pump do
        Wait(0)
    end
    CurrentObjects.rope = AddRope(pump.x, pump.y, pump.z, 0.0, 0.0, 0.0, 3.0, 1, 1000.0, 0.0, 1.0, false, false, false, 1.0, true)
    while not CurrentObjects.rope do
        Wait(0)
    end
    ActivatePhysics(CurrentObjects.rope)
    Wait(50)
    local nozzlePos = GetEntityCoords(CurrentObjects.rope)
    nozzlePos = GetOffsetFromEntityInWorldCoords(CurrentObjects.rope, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(CurrentObjects.rope, CurrentPump, CurrentObjects.nozzle, pump.x, pump.y, pump.z + 1.45, nozzlePos.x, nozzlePos.y, nozzlePos.z, 5.0, false, false, '', '')
end

local removeObjects = function ()
    if CurrentObjects.nozzle then
        DeleteEntity(CurrentObjects.nozzle)
        CurrentObjects.nozzle = nil
    end
    if CurrentObjects.rope then
        DeleteEntity(CurrentObjects.rope)
        CurrentObjects.rope = nil
    end
end

local refillVehicleFuel = function (liter)
    if not CurrentPump then return end
    local veh, dis = QBCore.Functions.GetClosestVehicle()
    if not veh or veh == -1 then return end
    if dis > 5 then return end

    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, veh, 1000)
    Wait(1000)
    grabFuelFromPump()
    QBCore.Functions.LoadAnimDict('timetable@gardener@filling_can')
    TaskPlayAnim(ped, 'timetable@gardener@filling_can', 'gar_ig_5_filling_can', 2.0, 8.0, -1, 50, 0, false, false, false)

    QBCore.Functions.Progressbar('fueling_vehicle', 'Repostando vehículo', Config.RefillTime * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        removeObjects()
        QBCore.Functions.TriggerCallback('qb-fuel:server:refillVehicle', function (success)
            if not success then return QBCore.Functions.Notify('No tienes suficiente dinero', 'error') end
            SetFuel(veh, GetFuel(veh) + liter)
            QBCore.Functions.Notify('Vehículo repostado', 'success')
        end)
    end, function()
        removeObjects()
    end)
end

local showFuelMenu = function (ent)
    CurrentPump = ent
    local veh, dis = QBCore.Functions.GetClosestVehicle()
    if not veh or veh == -1 then return QBCore.Functions.Notify('No se encontró ningún vehículo cerca') end
    if dis > 5 then return QBCore.Functions.Notify('No hay vehículos cerca') end
    SendNUIMessage({
        action = 'show',
        price = Config.FuelPrice,
        currentFuel = GetFuel(veh),
    })
end

local hideFuelMenu = function ()
    SendNUIMessage({
        action = 'hide'
    })
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
    end
end

local setUpTarget = function ()
    for _, hash in pairs(Config.PumpModels) do
        exports['qb-target']:AddTargetModel(hash, {
            options = {
                {
                    num = 1,
                    icon = 'fa-solid fa-gas-pump',
                    label = 'Echar Gasolina',
                    action = showFuelMenu()
                },
                {
                    num = 2,
                    type = 'server',
                    event = 'qb-fuel:server:buyJerryCan',
                    icon = 'fa-solid fa-jar',
                    label = 'Comprar Bidón de Gasolina $' .. Config.JerryCanCost,
                },
                {
                    num = 3,
                    type = 'server',
                    event = 'qb-fuel:server:refillJerryCan',
                    icon = 'fa-solid fa-arrows-rotate',
                    label = 'Rellenar Bidón de Gasolina $' .. Config.JerryCanCost,
                    canInteract = function()
                        return GetSelectedPedWeapon(PlayerPedId()) == `WEAPON_PETROLCAN`
                    end
                }
            },
            distance = 1.5
        })
    end
end

local init = function ()
    SetFuelConsumptionState(true)
    SetFuelConsumptionRateMultiplier(Config.GlobalFuelConsumptionMultiplier)

    displayBlips()
    setUpTarget()
end

-- ====================|| NUI CALLBACKS || ==================== --

RegisterNuiCallback('hide', function (_, cb)
    hideFuelMenu()
    cb('ok')
end)

RegisterNuiCallback('refill', function (data, cb)
    refillVehicleFuel(data.liter)
    cb('ok')
end)

-- ====================|| INITIALIZATION || ==================== --

init()
