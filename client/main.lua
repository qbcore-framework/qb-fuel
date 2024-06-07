-- Events

RegisterNetEvent('qb-fuel:client:refuelVehicle', function(price, payment)
    local ped = PlayerPedId()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local money = QBCore.Functions.GetPlayerData().money

    if not IsVehicleValid(vehicle) then
        QBCore.Functions.Notify('No vehicle nearby.', 'error')
        return
    end

    if money[payment] < price then
        QBCore.Functions.Notify('You don\'t have enough money', 'error')
        return
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 5000)
    Wait(2000)
    QBCore.Functions.RequestAnimDict('amb@world_human_security_shine_torch@male@base')

    TaskPlayAnim(ped, 'amb@world_human_security_shine_torch@male@base', 'base', 8.0, 1.0, -1, 1, 0, 0, 0, 0)
    getRefuel = true

    QBCore.Functions.Progressbar('refueling_', 'Refueling....', math.random(8000, 10000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        StopAnimTask(ped, 'amb@world_human_security_shine_torch@male@base', 'base', 3.0)
        getRefuel = false
        SetFuel(vehicle, 100)
        TriggerServerEvent('qb-fuel:server:removePayment', price, payment, GetPlayerServerId(PlayerId()))
        TriggerEvent('qb-fuel:client:returnNozzle')
    end, function()
        StopAnimTask(ped, 'amb@world_human_security_shine_torch@male@base', 'base', 3.0)
        getRefuel = false
        TriggerEvent('qb-fuel:client:returnNozzle')
        QBCore.Functions.Notify('Refueling Cancelled', 'error')
    end)
end)

RegisterNetEvent('qb-fuel:client:takeNozzle', function()
    if getNozzle then
        return QBCore.Functions.Notify('You already have a nozzle.', 'error')
    end

    local ped = PlayerPedId()
    local nozzle = 'prop_cs_fuel_nozle'

    QBCore.Functions.RequestAnimDict('anim@am_hold_up@male')
    TaskPlayAnim(ped, 'anim@am_hold_up@male', 'shoplift_high', 2.0, 8.0, 1000, 50, 0, 0, 0, 0)

    QBCore.Functions.LoadModel(nozzle)
    nozzleProp = CreateObject(nozzle, 1.0, 1.0, 1.0, 1, 1, 0)

    if DoesEntityExist(nozzleProp) then
        getNozzle = true
        AttachEntityToEntity(nozzleProp, ped, GetPedBoneIndex(ped, 18905), 0.13, 0.04, 0.01, -42.0, -115.0, -63.42, 0, 1, 0, 1, 0, 1)
    end
end)

RegisterNetEvent('qb-fuel:client:returnNozzle', function()
    if not getNozzle then
        return QBCore.Functions.Notify('You don\'t have a nozzle to return.', 'error')
    end

    if nozzleProp then
        getNozzle = false
        DeleteObject(nozzleProp)
        nozzleProp = nil
    end
end)

RegisterNetEvent('qb-fuel:client:openRefuelMenu', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()

    if not IsVehicleValid(vehicle) then
        QBCore.Functions.Notify('No vehicle nearby.', 'error')
        return
    end

    local fuel = GetVehicleFuelLevel(vehicle)
    local price = RoundNumber(Shared.FuelPrice - fuel) * Shared.FuelPriceMultiplier

    if fuel < 90 then
        TriggerServerEvent('qb-fuel:server:openFuelMenu', price)
    else
        QBCore.Functions.Notify('Vehicle fuel tank is above 90%, you can\'t refuel.', 'error')
    end
end)

RegisterNetEvent('qb-fuel:client:openFuelMenu', function(price)
    local playerData = QBCore.Functions.GetPlayerData()
    local money = playerData.money

    local input = exports['qb-input']:ShowInput({
        header = 'Fuel Station',
        submitText = 'Accept Charge: $' .. price,
        inputs = {
            {
                text = 'Payment Methods',
                name = 'type',
                type = 'select',
                options = {
                    { value = 'cash', text = 'Cash' },
                    { value = 'bank', text = 'Bank' }
                }
            }
        },
    })

    if input then
        local payment = input.type
        local availableFunds = money[payment] or 0

        if availableFunds >= price then
            TriggerEvent('qb-fuel:client:refuelVehicle', price, payment)
        else
            QBCore.Functions.Notify('You don\'t have enough money', 'error')
        end
    else
        QBCore.Functions.Notify('Input not received.', 'error')
    end
end)

RegisterNetEvent('qb-fuel:client:addVehFuel', function(fuel)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if not IsPedInAnyVehicle(ped) then
        QBCore.Functions.Notify('You must be inside a vehicle to use this command.', 'error')
        return
    end

    SetFuel(veh, fuel)
    QBCore.Functions.Notify('Added ' .. fuel .. ' units of fuel to the vehicle.', 'error')
end)

-- Functions

local function HandleFuelStationInteraction()
    exports['qb-target']:AddTargetBone(boneModels, {
        options = {
            {
                type = 'client',
                event = 'qb-fuel:client:openRefuelMenu',
                icon = 'fas fa-gas-pump',
                label = 'Refuel Vehicle',
                canInteract = function()
                    if checkStation and getNozzle then
                        return true
                    end
                    return false
                end
            }
        },
        distance = 2.0
    })

    exports['qb-target']:AddTargetModel(propModels, {
        options = {
            {
                type = 'client',
                event = 'qb-fuel:client:takeNozzle',
                icon = 'fas fa-gas-pump',
                label = 'Take Nozzle',
                canInteract = function()
                    local ped = PlayerPedId()
                    if not IsPedInAnyVehicle(ped) and not getNozzle and not getRefuel then
                        return true
                    end
                    return false
                end
            },
            {
                type = 'client',
                event = 'qb-fuel:client:returnNozzle',
                icon = 'fas fa-gas-pump',
                label = 'Return Nozzle',
                canInteract = function()
                    if getNozzle and not getRefuel then
                        return true
                    end
                    return false
                end
            }
        },
        distance = 2.0
    })

    for index, gasStation in ipairs(Shared.FuelStations) do
        stationZones[index] = PolyZone:Create(gasStation.poly, {
            name = 'FuelStation' .. index,
            minZ = gasStation.minZ,
            maxZ = gasStation.maxZ,
            debugPoly = false
        })

        stationZones[index]:onPlayerInOut(function(inside)
            checkStation = inside
        end)
    end
end

local function InitializeFuelSystem()
    CreateThread(MonitorVehicleFuelConsumption)
    CreateThread(HandleFuelStationInteraction)

    if Shared.NearestFuelBlips then
        CreateThread(UpdateClosestStationBlip)
    else
        CreateThread(CreateStationBlips)
    end
end

InitializeFuelSystem()